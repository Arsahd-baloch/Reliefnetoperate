import { pool } from '../../config/database.js';
import { createError } from '../../middleware/errorHandler.js';
import { stripe } from '../../config/stripe.js';
import { env } from '../../config/env.js';
export class DonationsService {
    async createStripeSession(input, donorId) {
        const campaignResult = await pool.query(`SELECT id, title, status FROM campaigns WHERE id = $1 AND deleted_at IS NULL`, [input.campaign_id]);
        if (campaignResult.rows.length === 0) {
            throw createError('Campaign not found', 404);
        }
        if (campaignResult.rows[0].status !== 'ACTIVE') {
            throw createError('Campaign is not accepting donations', 400);
        }
        const campaign = campaignResult.rows[0];
        const session = await stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            line_items: [
                {
                    price_data: {
                        currency: 'pkr',
                        product_data: {
                            name: `Donation to ${campaign.title}`,
                            description: `Campaign ID: ${campaign.id}`,
                        },
                        unit_amount: input.amount_pkr * 100, // Stripe expects cents/lowest denomination
                    },
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: `${env.CORS_ORIGINS.split(',')[0]}/donation-success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `${env.CORS_ORIGINS.split(',')[0]}/campaigns/${campaign.id}`,
            metadata: {
                donor_id: donorId.toString(),
                campaign_id: campaign.id.toString(),
                amount_pkr: input.amount_pkr.toString(),
            },
        });
        return { sessionId: session.id, url: session.url };
    }
    async handleStripeWebhook(signature, rawBody) {
        let event;
        try {
            event = stripe.webhooks.constructEvent(rawBody, signature, env.STRIPE_WEBHOOK_SECRET);
        }
        catch (err) {
            throw createError(`Webhook Error: ${err.message}`, 400);
        }
        if (event.type === 'checkout.session.completed') {
            const session = event.data.object;
            const { donor_id, campaign_id, amount_pkr } = session.metadata;
            const client = await pool.connect();
            try {
                await client.query('BEGIN');
                // Check if donation already processed (idempotency)
                const existing = await client.query('SELECT id FROM donations WHERE gateway_ref = $1', [session.id]);
                if (existing.rows.length === 0) {
                    const result = await client.query(`INSERT INTO donations
               (donor_id, campaign_id, amount_pkr, status, payment_method, gateway_ref)
             VALUES ($1, $2, $3, 'CONFIRMED', 'STRIPE', $4)
             RETURNING id`, [parseInt(donor_id), parseInt(campaign_id), parseFloat(amount_pkr), session.id]);
                    const donationId = result.rows[0].id;
                    await client.query(`INSERT INTO ledger_entries (type, amount_pkr, from_user_id, ref_table, ref_id)
             VALUES ('DONATION', $1, $2, 'donations', $3)`, [parseFloat(amount_pkr), parseInt(donor_id), donationId]);
                }
                await client.query('COMMIT');
            }
            catch (err) {
                await client.query('ROLLBACK');
                throw err;
            }
            finally {
                client.release();
            }
        }
        return { received: true };
    }
    async createDonation(input, donorId) {
        const campaignResult = await pool.query(`SELECT id, status FROM campaigns WHERE id = $1 AND deleted_at IS NULL`, [input.campaign_id]);
        if (campaignResult.rows.length === 0) {
            throw createError('Campaign not found', 404);
        }
        if (campaignResult.rows[0].status !== 'ACTIVE') {
            throw createError('Campaign is not accepting donations', 400);
        }
        try {
            // updated_at maintained by trigger; raised_pkr maintained by sync_campaign_raised_pkr trigger
            const result = await pool.query(`INSERT INTO donations
           (donor_id, campaign_id, amount_pkr, status, payment_method, gateway_ref, receipt_url)
         VALUES ($1, $2, $3, 'PENDING', 'BANK_TRANSFER', $4, $5)
         RETURNING id, donor_id, campaign_id, amount_pkr, status, payment_method,
                   gateway_ref, receipt_url, created_at`, [donorId, input.campaign_id, input.amount_pkr, input.reference_number, input.receipt_url ?? null]);
            return result.rows[0];
        }
        catch (err) {
            if (err.code === '23505') {
                throw createError('Reference number already used by another donation', 409);
            }
            throw err;
        }
    }
    async approveDonation(donationId, adminId, ip, role) {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const donationResult = await client.query(`SELECT d.id, d.donor_id, d.campaign_id, d.amount_pkr, d.status, c.ngo_id
         FROM donations d
         JOIN campaigns c ON c.id = d.campaign_id
         WHERE d.id = $1 FOR UPDATE`, [donationId]);
            if (donationResult.rows.length === 0) {
                throw createError('Donation not found', 404);
            }
            const donation = donationResult.rows[0];
            if (donation.status !== 'PENDING') {
                throw createError(`Donation already ${donation.status}`, 409);
            }
            // If actor is an NGO, ensure they own the campaign
            if (role === 'NGO') {
                const ngoCheck = await client.query('SELECT id FROM ngo_profiles WHERE user_id = $1 AND id = $2', [adminId, donation.ngo_id]);
                if (ngoCheck.rows.length === 0) {
                    throw createError('You do not have permission to approve this donation', 403);
                }
            }
            // updated_at and raised_pkr both maintained by triggers
            await client.query(`UPDATE donations SET status = 'CONFIRMED', approved_by = $2 WHERE id = $1`, [donationId, adminId]);
            await client.query(`INSERT INTO ledger_entries (type, amount_pkr, from_user_id, ref_table, ref_id)
         VALUES ('DONATION', $1, $2, 'donations', $3)`, [donation.amount_pkr, donation.donor_id, donationId]);
            await client.query(`INSERT INTO audit_logs (admin_id, action_type, target_entity, target_id, metadata, ip_address)
         VALUES ($1, 'APPROVE_DONATION', 'donations', $2, $3, $4)`, [adminId, donationId, JSON.stringify({ amount: donation.amount_pkr, donor_id: donation.donor_id }), ip || null]);
            await client.query('COMMIT');
            return { ...donation, status: 'CONFIRMED', approved_by: adminId };
        }
        catch (err) {
            await client.query('ROLLBACK');
            throw err;
        }
        finally {
            client.release();
        }
    }
    async rejectDonation(donationId, adminId, ip, role) {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const donationResult = await client.query(`SELECT d.id, d.donor_id, d.campaign_id, d.amount_pkr, d.status, c.ngo_id
         FROM donations d
         JOIN campaigns c ON c.id = d.campaign_id
         WHERE d.id = $1 FOR UPDATE`, [donationId]);
            if (donationResult.rows.length === 0) {
                throw createError('Donation not found', 404);
            }
            const donation = donationResult.rows[0];
            if (donation.status !== 'PENDING') {
                throw createError(`Donation already ${donation.status}`, 409);
            }
            // If actor is an NGO, ensure they own the campaign
            if (role === 'NGO') {
                const ngoCheck = await client.query('SELECT id FROM ngo_profiles WHERE user_id = $1 AND id = $2', [adminId, donation.ngo_id]);
                if (ngoCheck.rows.length === 0) {
                    throw createError('You do not have permission to reject this donation', 403);
                }
            }
            // updated_at maintained by trigger
            await client.query(`UPDATE donations SET status = 'REJECTED', rejected_by = $2 WHERE id = $1`, [donationId, adminId]);
            await client.query(`INSERT INTO audit_logs (admin_id, action_type, target_entity, target_id, metadata, ip_address)
         VALUES ($1, 'REJECT_DONATION', 'donations', $2, $3, $4)`, [adminId, donationId, JSON.stringify({ amount: donation.amount_pkr, donor_id: donation.donor_id }), ip || null]);
            await client.query('COMMIT');
            return { ...donation, status: 'REJECTED', rejected_by: adminId };
        }
        catch (err) {
            await client.query('ROLLBACK');
            throw err;
        }
        finally {
            client.release();
        }
    }
    async getDonationsByDonor(donorId) {
        const result = await pool.query(`SELECT d.id, d.donor_id, d.campaign_id, d.amount_pkr, d.status,
              d.payment_method, d.gateway_ref, d.receipt_url, d.created_at,
              c.title AS campaign_title
       FROM donations d
       LEFT JOIN campaigns c ON c.id = d.campaign_id AND c.deleted_at IS NULL
       WHERE d.donor_id = $1
       ORDER BY d.created_at DESC`, [donorId]);
        return result.rows;
    }
    async getDonationsByCampaign(campaignId) {
        const result = await pool.query(`SELECT d.id, d.donor_id, d.campaign_id, d.amount_pkr, d.status,
              d.payment_method, d.gateway_ref, d.created_at,
              u.name AS donor_name
       FROM donations d
       LEFT JOIN users u ON u.id = d.donor_id AND u.deleted_at IS NULL
       WHERE d.campaign_id = $1
       ORDER BY d.created_at DESC`, [campaignId]);
        return result.rows;
    }
    async getDonationsByNgo(ngoUserId, status) {
        const conditions = ['c.ngo_id = (SELECT id FROM ngo_profiles WHERE user_id = $1)'];
        const values = [ngoUserId];
        if (status) {
            conditions.push(`d.status = $${values.length + 1}`);
            values.push(status);
        }
        const query = `
      SELECT d.id, d.donor_id, d.campaign_id, d.amount_pkr, d.status,
             d.payment_method, d.gateway_ref, d.receipt_url, d.created_at,
             c.title AS campaign_title, u.name AS donor_name
      FROM donations d
      JOIN campaigns c ON c.id = d.campaign_id
      JOIN users u ON u.id = d.donor_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY d.created_at DESC
    `;
        const result = await pool.query(query, values);
        return result.rows;
    }
}
export const donationsService = new DonationsService();
//# sourceMappingURL=donations.service.js.map