import { pool } from '../../config/database.js';
import { createError } from '../../middleware/errorHandler.js';
import { notificationService } from '../notifications/notification.service.js';
export class InKindService {
    async createDonation(input, donorId) {
        const result = await pool.query(`INSERT INTO inkind_donations
         (donor_id, title, description, photo_url, address_text, latitude, longitude)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, donor_id, title, description, photo_url, address_text,
                 latitude, longitude, status, created_at, updated_at`, [
            donorId,
            input.title,
            input.description ?? null,
            input.photo_url ?? null,
            input.address_text,
            input.latitude,
            input.longitude,
        ]);
        return result.rows[0];
    }
    async getBoard() {
        const result = await pool.query(`SELECT d.id, d.title, d.description, d.photo_url, d.address_text,
              d.latitude, d.longitude, d.status, d.created_at,
              u.name AS donor_name
       FROM inkind_donations d
       JOIN users u ON u.id = d.donor_id
       WHERE d.status = 'AVAILABLE'
       ORDER BY d.created_at DESC`);
        return result.rows;
    }
    async getMyDonations(donorId) {
        const result = await pool.query(`SELECT d.id, d.title, d.description, d.photo_url, d.address_text,
              d.latitude, d.longitude, d.status, d.created_at,
              COUNT(r.id)                                       AS request_count,
              COUNT(r.id) FILTER (WHERE r.status = 'PENDING')  AS pending_count
       FROM inkind_donations d
       LEFT JOIN inkind_requests r ON r.donation_id = d.id
       WHERE d.donor_id = $1
       GROUP BY d.id
       ORDER BY d.created_at DESC`, [donorId]);
        return result.rows;
    }
    async getDonationById(donationId) {
        const result = await pool.query(`SELECT d.id, d.title, d.description, d.photo_url, d.address_text,
              d.latitude, d.longitude, d.status, d.created_at,
              u.name AS donor_name
       FROM inkind_donations d
       JOIN users u ON u.id = d.donor_id
       WHERE d.id = $1`, [donationId]);
        if (result.rows.length === 0)
            throw createError('Donation not found', 404);
        return result.rows[0];
    }
    async createRequest(donationId, beneficiaryId, input) {
        const donation = await pool.query(`SELECT status FROM inkind_donations WHERE id = $1`, [donationId]);
        if (donation.rows.length === 0)
            throw createError('Donation not found', 404);
        if (donation.rows[0].status !== 'AVAILABLE') {
            throw createError('This donation is no longer available', 409);
        }
        try {
            const result = await pool.query(`INSERT INTO inkind_requests
           (donation_id, beneficiary_id, message, phone, email)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`, [donationId, beneficiaryId, input.message ?? null, input.phone, input.email ?? null]);
            const request = result.rows[0];
            // Auto-create chat room for coordination
            const roomResult = await pool.query(`INSERT INTO chat_rooms (inkind_request_id, created_by)
         VALUES ($1, $2)
         RETURNING id`, [request.id, beneficiaryId]);
            await pool.query(`UPDATE inkind_requests SET chat_room_id = $1 WHERE id = $2`, [roomResult.rows[0].id, request.id]);
            // Notify donor about new request
            notificationService.notifyInKindRequest(donation.rows[0].donor_id, donationId, donation.rows[0].title, 'A beneficiary' // Could fetch name if needed
            );
            return { ...request, chat_room_id: roomResult.rows[0].id };
        }
        catch (err) {
            if (err.code === '23505')
                throw createError('You have already requested this item', 409);
            throw err;
        }
    }
    async getRequests(donationId, donorId) {
        const donation = await pool.query(`SELECT donor_id FROM inkind_donations WHERE id = $1`, [donationId]);
        if (donation.rows.length === 0)
            throw createError('Donation not found', 404);
        if (donation.rows[0].donor_id !== donorId)
            throw createError('Forbidden', 403);
        const result = await pool.query(`SELECT r.id, r.donation_id, r.beneficiary_id, r.message, r.phone, r.email,
              r.status, r.donor_shared_phone, r.accepted_at, r.created_at,
              u.name AS beneficiary_name
       FROM inkind_requests r
       JOIN users u ON u.id = r.beneficiary_id
       WHERE r.donation_id = $1
       ORDER BY r.created_at ASC`, [donationId]);
        return result.rows;
    }
    async acceptRequest(requestId, donorId, input) {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const reqResult = await client.query(`SELECT r.id, r.donation_id, r.beneficiary_id, r.status,
                d.donor_id, d.status AS donation_status, d.title AS donation_title
         FROM inkind_requests r
         JOIN inkind_donations d ON d.id = r.donation_id
         WHERE r.id = $1
         FOR UPDATE`, [requestId]);
            if (reqResult.rows.length === 0)
                throw createError('Request not found', 404);
            const row = reqResult.rows[0];
            if (row.donor_id !== donorId)
                throw createError('Forbidden', 403);
            if (row.status !== 'PENDING')
                throw createError(`Request already ${row.status}`, 409);
            if (row.donation_status !== 'AVAILABLE')
                throw createError('Donation no longer available', 409);
            const donationId = row.donation_id;
            await client.query(`UPDATE inkind_requests
         SET status = 'ACCEPTED', donor_shared_phone = $2, accepted_at = NOW()
         WHERE id = $1`, [requestId, input.donor_shared_phone ?? null]);
            // updated_at maintained by trigger on inkind_donations
            await client.query(`UPDATE inkind_donations SET status = 'ACCEPTED' WHERE id = $1`, [donationId]);
            await client.query(`UPDATE inkind_requests
         SET status = 'REJECTED'
         WHERE donation_id = $1 AND id != $2 AND status = 'PENDING'`, [donationId, requestId]);
            // Auto-create a chat room between donor and beneficiary
            const roomResult = await client.query(`INSERT INTO chat_rooms (inkind_request_id, created_by)
         VALUES ($1, $2)
         ON CONFLICT DO NOTHING
         RETURNING id`, [requestId, donorId]);
            let chatRoomId = null;
            if (roomResult.rows.length > 0) {
                chatRoomId = roomResult.rows[0].id;
            }
            else {
                const existingRoom = await client.query(`SELECT id FROM chat_rooms WHERE inkind_request_id = $1`, [requestId]);
                chatRoomId = existingRoom.rows[0]?.id ?? null;
            }
            if (chatRoomId) {
                await client.query(`UPDATE inkind_requests SET chat_room_id = $1 WHERE id = $2`, [chatRoomId, requestId]);
            }
            await client.query('COMMIT');
            // Notify accepted beneficiary
            notificationService.notifyInKindAccepted(row.beneficiary_id, donationId, row.donation_title);
            return {
                ...row,
                status: 'ACCEPTED',
                donor_shared_phone: input.donor_shared_phone ?? null,
                chat_room_id: chatRoomId,
            };
        }
        catch (err) {
            await client.query('ROLLBACK');
            throw err;
        }
        finally {
            client.release();
        }
    }
    async rejectRequest(requestId, donorId) {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const reqResult = await client.query(`SELECT r.id, r.donation_id, r.beneficiary_id, r.status, d.donor_id, d.title AS donation_title
         FROM inkind_requests r
         JOIN inkind_donations d ON d.id = r.donation_id
         WHERE r.id = $1
         FOR UPDATE`, [requestId]);
            if (reqResult.rows.length === 0)
                throw createError('Request not found', 404);
            const row = reqResult.rows[0];
            if (row.donor_id !== donorId)
                throw createError('Forbidden', 403);
            if (row.status !== 'PENDING')
                throw createError(`Request already ${row.status}`, 409);
            await client.query(`UPDATE inkind_requests SET status = 'REJECTED' WHERE id = $1`, [requestId]);
            await client.query('COMMIT');
            // Notify rejected beneficiary
            notificationService.notifyInKindRejected(row.beneficiary_id, row.donation_id, row.donation_title);
            return { ...row, status: 'REJECTED' };
        }
        catch (err) {
            await client.query('ROLLBACK');
            throw err;
        }
        finally {
            client.release();
        }
    }
    async completeDonation(donationId, beneficiaryId) {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const donationResult = await client.query(`SELECT d.id, d.title, d.donor_id, d.status, r.beneficiary_id
         FROM inkind_donations d
         JOIN inkind_requests r ON r.donation_id = d.id AND r.status = 'ACCEPTED'
         WHERE d.id = $1
         FOR UPDATE`, [donationId]);
            if (donationResult.rows.length === 0)
                throw createError('Donation or accepted request not found', 404);
            const donation = donationResult.rows[0];
            if (donation.beneficiary_id !== beneficiaryId)
                throw createError('Only the assigned beneficiary can confirm receipt', 403);
            if (donation.status !== 'ACCEPTED')
                throw createError(`Donation cannot be completed from ${donation.status} status`, 409);
            await client.query(`UPDATE inkind_donations SET status = 'COMPLETED', updated_at = NOW() WHERE id = $1`, [donationId]);
            await client.query('COMMIT');
            // Notify donor that it's completed
            notificationService.notifyInKindCompleted(donation.donor_id, donationId, donation.title);
            return { id: donationId, status: 'COMPLETED' };
        }
        catch (err) {
            await client.query('ROLLBACK');
            throw err;
        }
        finally {
            client.release();
        }
    }
    async getMyRequests(beneficiaryId) {
        const result = await pool.query(`SELECT
         r.id, r.donation_id, r.status, r.message, r.phone, r.email,
         r.donor_shared_phone, r.accepted_at, r.created_at, r.chat_room_id,
         d.title        AS donation_title,
         d.description  AS donation_description,
         d.photo_url    AS donation_photo_url,
         d.address_text AS donation_address,
         d.status       AS donation_status,
         u.name         AS donor_name,
         d.donor_id
       FROM inkind_requests r
       JOIN inkind_donations d ON d.id = r.donation_id
       JOIN users u ON u.id = d.donor_id
       WHERE r.beneficiary_id = $1
       ORDER BY r.created_at DESC`, [beneficiaryId]);
        return result.rows;
    }
    async getAdminRecords() {
        const result = await pool.query(`SELECT
         d.id           AS donation_id,
         d.title,
         d.photo_url,
         d.address_text,
         d.status       AS donation_status,
         r.status       AS request_status,
         r.accepted_at,
         donor.name     AS donor_name,
         r.donor_shared_phone,
         bene.name      AS beneficiary_name,
         r.phone        AS beneficiary_phone,
         r.email        AS beneficiary_email,
         r.chat_room_id
       FROM inkind_donations d
       JOIN inkind_requests r   ON r.donation_id = d.id AND r.status = 'ACCEPTED'
       JOIN users donor         ON donor.id = d.donor_id
       JOIN users bene          ON bene.id = r.beneficiary_id
       WHERE d.status IN ('ACCEPTED', 'COMPLETED')
       ORDER BY r.accepted_at DESC NULLS LAST, d.updated_at DESC`);
        return result.rows;
    }
}
export const inKindService = new InKindService();
//# sourceMappingURL=inkind.service.js.map