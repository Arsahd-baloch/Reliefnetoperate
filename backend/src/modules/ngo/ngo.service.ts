import { pool } from '../../config/database.js';
import { createError } from '../../middleware/errorHandler.js';

export class NgoService {
  /**
   * Get NGO profile ID for a user.
   */
  async getNgoIdByUserId(userId: number): Promise<number | null> {
    const result = await pool.query(
      'SELECT id FROM ngo_profiles WHERE user_id = $1 AND deleted_at IS NULL',
      [userId]
    );
    return result.rows[0]?.id || null;
  }

  /**
   * Get NGO dashboard statistics.
   */
  async getDashboardStats(userId: number) {
    const ngoId = await this.getNgoIdByUserId(userId);
    if (!ngoId) throw createError('NGO profile not found', 404);

    const [campaignStats, donationStats] = await Promise.all([
      pool.query(`
        SELECT
          COUNT(*) as total_count,
          COUNT(*) FILTER (WHERE status = 'ACTIVE') as active_count,
          COALESCE(SUM(raised_pkr), 0) as total_raised,
          COALESCE(SUM(goal_pkr), 0) as total_goal
        FROM campaigns
        WHERE ngo_id = $1 AND deleted_at IS NULL
      `, [ngoId]),
      pool.query(`
        SELECT 
          COUNT(*) as donation_count,
          COALESCE(SUM(amount_pkr), 0) as donation_sum
        FROM donations d
        JOIN campaigns c ON c.id = d.campaign_id
        WHERE c.ngo_id = $1 AND d.status = 'CONFIRMED'
      `, [ngoId])
    ]);

    const c = campaignStats.rows[0];
    const d = donationStats.rows[0];

    return {
      campaigns: {
        total: parseInt(c.total_count, 10),
        active: parseInt(c.active_count, 10),
        total_raised: parseFloat(c.total_raised),
        total_goal: parseFloat(c.total_goal),
      },
      donations: {
        count: parseInt(d.donation_count, 10),
        total_amount: parseFloat(d.donation_sum),
      }
    };
  }

  /**
   * Get full NGO profile.
   */
  async getProfile(userId: number) {
    const result = await pool.query(`
      SELECT np.id, np.user_id, np.org_name, np.registration_number, np.status,
             np.wallet_balance, np.verified_at, np.created_at,
             np.bank_name, np.account_title, np.account_number,
             u.name, u.email, u.created_at as user_joined_at
      FROM ngo_profiles np
      JOIN users u ON u.id = np.user_id AND u.deleted_at IS NULL
      WHERE np.user_id = $1 AND np.deleted_at IS NULL
    `, [userId]);

    if (result.rows.length === 0) throw createError('NGO profile not found', 404);
    return result.rows[0];
  }

  /**
   * Update NGO profile.
   */
  async updateProfile(userId: number, input: any) {
    const fields: string[] = [];
    const values: any[] = [];
    let idx = 1;

    for (const [key, value] of Object.entries(input)) {
      if (value !== undefined) {
        fields.push(`${key} = $${idx++}`);
        values.push(value);
      }
    }

    if (fields.length === 0) return this.getProfile(userId);

    values.push(userId);
    const query = `
      UPDATE ngo_profiles 
      SET ${fields.join(', ')} 
      WHERE user_id = $${idx} AND deleted_at IS NULL
      RETURNING *
    `;

    const result = await pool.query(query, values);
    if (result.rows.length === 0) throw createError('NGO profile not found', 404);
    return result.rows[0];
  }

  /**
   * Get NGO campaigns (paginated).
   */
  async getCampaigns(userId: number) {
    const ngoId = await this.getNgoIdByUserId(userId);
    if (!ngoId) throw createError('NGO profile not found', 404);

    const result = await pool.query(`
      SELECT id, ngo_id, created_by, title, description,
             goal_pkr, raised_pkr, spent_pkr, status,
             created_at, updated_at
      FROM campaigns
      WHERE ngo_id = $1 AND deleted_at IS NULL
      ORDER BY created_at DESC
    `, [ngoId]);

    return result.rows;
  }

  /**
   * Public profile data.
   */
  async getPublicProfile(ngoId: number) {
    const [profile, campaigns] = await Promise.all([
      pool.query(
        'SELECT org_name, registration_number, status, verified_at, created_at, bank_name, account_title, account_number FROM ngo_profiles WHERE id = $1 AND deleted_at IS NULL',
        [ngoId]
      ),
      pool.query(`
        SELECT id, title, status, raised_pkr, goal_pkr, created_at
        FROM campaigns
        WHERE ngo_id = $1 AND status != 'DRAFT' AND deleted_at IS NULL
        ORDER BY created_at DESC
      `, [ngoId])
    ]);

    if (profile.rows.length === 0) throw createError('NGO not found', 404);

    return {
      profile: profile.rows[0],
      campaigns: campaigns.rows
    };
  }
}

export const ngoService = new NgoService();
