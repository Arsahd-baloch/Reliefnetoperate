-- ============================================================
-- DisasterAid V2.1 — DEMO SEED
-- Run this ONCE against the deployed Railway PostgreSQL database
-- after all 015 migrations have applied.
--
-- HOW TO RUN:
--   psql "$DATABASE_PUBLIC_URL" -f scripts/demo_seed.sql
--   (get DATABASE_PUBLIC_URL from Railway → your Postgres service → Variables)
--
-- DEMO LOGIN CREDENTIALS  (all passwords: password123)
-- ┌──────────────────┬──────────────────────────┬─────────────┐
-- │ Role             │ Email                    │ Password    │
-- ├──────────────────┼──────────────────────────┼─────────────┤
-- │ ADMIN            │ admin@demo.pk            │ password123 │
-- │ NGO              │ ngo@demo.pk              │ password123 │
-- │ NGO (2nd)        │ ngo2@demo.pk             │ password123 │
-- │ COORDINATOR      │ coordinator@demo.pk      │ password123 │
-- │ VOLUNTEER        │ volunteer@demo.pk        │ password123 │
-- │ VOLUNTEER (2nd)  │ volunteer2@demo.pk       │ password123 │
-- │ DONOR            │ donor@demo.pk            │ password123 │
-- │ DONOR (2nd)      │ donor2@demo.pk           │ password123 │
-- │ BENEFICIARY      │ beneficiary@demo.pk      │ password123 │
-- │ BENEFICIARY (2nd)│ beneficiary2@demo.pk     │ password123 │
-- └──────────────────┴──────────────────────────┴─────────────┘
-- ============================================================

BEGIN;

-- ── SECTION 0: SCHEMA ADDITIONS (fill gaps missing from migrations) ──────────
-- deliveries.quantity_delivered and deliveries.status are used by the
-- deliveries service but were never added to a migration file.

ALTER TABLE deliveries
  ADD COLUMN IF NOT EXISTS quantity_delivered NUMERIC(10,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'PENDING';

-- ── SECTION 1: DEMO USERS ────────────────────────────────────────────────────
-- role_ids: DONOR=1  BENEFICIARY=2  VOLUNTEER=3  NGO=4  COORDINATOR=5  ADMIN=6
-- All password hashes = bcrypt('password123', 10)

INSERT INTO users (id, email, name, password_hash, role_id, status) VALUES
-- Admin
(701, 'admin@demo.pk',          'Demo Admin',          '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 6, 'ACTIVE'),

-- NGOs
(710, 'ngo@demo.pk',            'Khidmat Foundation',  '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 4, 'ACTIVE'),
(711, 'ngo2@demo.pk',           'Aman Relief Trust',   '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 4, 'ACTIVE'),

-- Coordinator
(720, 'coordinator@demo.pk',    'Zara Coordinator',    '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 5, 'ACTIVE'),

-- Volunteers
(730, 'volunteer@demo.pk',      'Bilal Volunteer',     '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 3, 'ACTIVE'),
(731, 'volunteer2@demo.pk',     'Nadia Volunteer',     '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 3, 'ACTIVE'),

-- Donors
(740, 'donor@demo.pk',          'Hassan Donor',        '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 1, 'ACTIVE'),
(741, 'donor2@demo.pk',         'Ayesha Donor',        '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 1, 'ACTIVE'),

-- Beneficiaries
(750, 'beneficiary@demo.pk',    'Usman Beneficiary',   '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 2, 'ACTIVE'),
(751, 'beneficiary2@demo.pk',   'Sana Beneficiary',    '$2b$10$WGUcO88IrQxm0ZbR2msEZ../XO5XEbOiff78x0IuPYhiw.985Nb0u', 2, 'ACTIVE')

ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  email         = EXCLUDED.email,
  password_hash = EXCLUDED.password_hash,
  status        = EXCLUDED.status;

-- ── SECTION 2: NGO PROFILES ──────────────────────────────────────────────────
INSERT INTO ngo_profiles
  (id, user_id, org_name, registration_number, status,
   wallet_balance, bank_name, account_title, account_number,
   latitude, longitude)
VALUES
(50, 710, 'Khidmat Foundation', 'NGO-2024-001', 'ACTIVE',
 385000.00, 'MCB Bank', 'Khidmat Foundation', '1234567890123',
 24.8607, 67.0011),

(51, 711, 'Aman Relief Trust', 'NGO-2024-002', 'ACTIVE',
 125000.00, 'HBL Bank', 'Aman Relief Trust', '9876543210123',
 31.5204, 74.3587)

ON CONFLICT (id) DO UPDATE SET
  wallet_balance = EXCLUDED.wallet_balance,
  bank_name      = EXCLUDED.bank_name,
  account_title  = EXCLUDED.account_title,
  account_number = EXCLUDED.account_number;

-- ── SECTION 3: VOLUNTEER PROFILES ────────────────────────────────────────────
-- volunteer_type is NOT NULL after migration 011; constraint:
--   INDEPENDENT → ngo_id IS NULL  |  NGO → ngo_id IS NOT NULL
INSERT INTO volunteer_profiles
  (id, user_id, volunteer_type, skills, rating, completed_tasks, total_earned,
   latitude, longitude, status)
VALUES
(50, 730, 'INDEPENDENT', ARRAY['First Aid','Driving','Urdu'],  4.7, 8, 45000.00, 24.8607, 67.0011, 'ACTIVE'),
(51, 731, 'INDEPENDENT', ARRAY['Medical','Packing','English'], 4.9, 3, 18000.00, 31.5204, 74.3587, 'ACTIVE')

ON CONFLICT (id) DO NOTHING;

-- ── SECTION 4: CAMPAIGNS ─────────────────────────────────────────────────────
-- raised_pkr starts at 0; sync_campaign_raised_pkr trigger (migration 011) will
-- update it automatically when CONFIRMED donations are inserted below.
INSERT INTO campaigns
  (id, ngo_id, created_by, title, description,
   goal_pkr, raised_pkr, spent_pkr, status, latitude, longitude)
VALUES
(50, 50, 710, 'Karachi Flood Emergency 2026',
 'Urgent relief for 2,000 flood-affected families. Providing food packs, clean water, and shelter kits.',
 2000000.00, 0, 0, 'ACTIVE', 24.8607, 67.0011),

(51, 50, 710, 'Winter Blanket Drive — Balochistan',
 'Distributing 5,000 blankets to remote Balochistan villages before the coldest months.',
 750000.00, 0, 0, 'ACTIVE', 29.5592, 67.6264),

(52, 51, 711, 'Orphan Education Fund',
 'Supporting 150 orphans with school fees, uniforms, and stationery for the full academic year.',
 500000.00, 0, 0, 'ACTIVE', 31.5204, 74.3587),

(53, 51, 711, 'Ramadan Ration Packs',
 'Distributing 1,000 complete Ramadan ration packs to deserving families across Punjab.',
 300000.00, 0, 0, 'DRAFT', 31.4504, 73.1350),

(54, 50, 710, 'Earthquake Response — Gilgit 2025',
 'Completed campaign: provided emergency tents and supplies after the 2025 earthquake.',
 1000000.00, 0, 0, 'COMPLETED', 35.9220, 74.3087)

ON CONFLICT (id) DO UPDATE SET
  raised_pkr = EXCLUDED.raised_pkr,
  spent_pkr  = EXCLUDED.spent_pkr,
  status     = EXCLUDED.status;

-- ── SECTION 5: TASKS (every status in the workflow) ──────────────────────────
-- validate_task_claimer trigger fires on INSERT when claimed_by IS NOT NULL.
-- Volunteer profiles (section 3) must exist first — they do. ✓
INSERT INTO tasks
  (id, campaign_id, beneficiary_id, created_by, claimed_by, coordinator_id,
   source_type, title, description, category, family_size, items_needed,
   latitude, longitude, location_text, budget_pkr, urgency, status)
VALUES
-- ── OPEN tasks: volunteer can claim these live in the app ──
(50, 50, 750, 710, NULL, NULL,
 'NGO_CAMPAIGN', 'Deliver Food Pack to Usman Family',
 'Family of 6. Ration pack: flour 20kg + rice 10kg + cooking oil 2L. Road accessible.',
 'FOOD', 6, '[{"item":"Flour 20kg"},{"item":"Rice 10kg"},{"item":"Oil 2L"}]',
 24.8607, 67.0011, 'Orangi Town, Karachi', 4500.00, 'HIGH', 'OPEN'),

(51, 51, 751, 710, NULL, NULL,
 'NGO_CAMPAIGN', 'Blankets for Sana Family — Cold Emergency',
 'Family of 4 with 2 young children. Urgent blanket delivery needed before tonight.',
 'SHELTER', 4, '[{"item":"Blanket x4"},{"item":"Warm Jacket x2"}]',
 29.5592, 67.6264, 'Khuzdar, Balochistan', 6000.00, 'CRITICAL', 'OPEN'),

(52, NULL, 750, 750, NULL, NULL,
 'BENEFICIARY_REQUEST', 'Need Insulin — Diabetic Emergency',
 'I am diabetic and cannot afford medication this month. Need insulin and syringes.',
 'MEDICAL', 1, '[{"item":"Insulin 30 units"},{"item":"Syringes x30"}]',
 24.9200, 67.0700, 'Korangi, Karachi', 3500.00, 'HIGH', 'OPEN'),

-- ── CLAIMED: volunteer picked it up, not started yet ──
(53, 50, 751, 710, 730, 720,
 'NGO_CAMPAIGN', 'Clean Water Delivery — 20 Gallons',
 'Deliver 20 gallons of filtered water to the flood camp. Truck access available.',
 'WATER', 10, '[{"item":"Water Gallon x20"}]',
 24.8500, 67.0200, 'Lyari, Karachi', 2500.00, 'MEDIUM', 'CLAIMED'),

-- ── IN_PROGRESS: volunteer actively delivering ──
(54, 52, 750, 711, 731, 720,
 'NGO_CAMPAIGN', 'School Supplies for Ali Orphanage',
 'Deliver 3 school bags, stationery sets, and uniforms (sizes 8–12) to Ali Orphanage.',
 'EDUCATION', 8, '[{"item":"School Bag x3"},{"item":"Stationery Set x8"},{"item":"Uniform x3"}]',
 31.5204, 74.3587, 'Gulberg, Lahore', 8500.00, 'MEDIUM', 'IN_PROGRESS'),

-- ── SUBMITTED: volunteer submitted delivery proof, awaiting coordinator ──
(55, 50, 751, 710, 730, 720,
 'NGO_CAMPAIGN', 'Emergency Medicine Delivery — TB Clinic',
 'Anti-TB medication for 15 patients at Lyari Community Health Center.',
 'MEDICAL', 15, '[{"item":"TB Medicine Kit x15"}]',
 24.8700, 67.0100, 'Lyari, Karachi', 15000.00, 'CRITICAL', 'SUBMITTED'),

-- ── COORDINATOR_VERIFIED: coordinator approved, payment pending ──
(56, 52, 750, 711, 731, 720,
 'NGO_CAMPAIGN', 'Monthly Ration Pack — March 2026',
 'Complete ration pack for 5 families. Coordinator has verified delivery evidence.',
 'FOOD', 5, '[{"item":"Ration Pack x5"}]',
 31.5204, 74.3587, 'Johar Town, Lahore', 5500.00, 'MEDIUM', 'COORDINATOR_VERIFIED'),

-- ── PAID: fully completed, historical record ──
(57, 54, 750, 710, 730, 720,
 'NGO_CAMPAIGN', 'Earthquake Tent Distribution — Feb 2026',
 'Successfully distributed 10 tents to earthquake-affected families. Fully paid.',
 'SHELTER', 10, '[{"item":"Emergency Tent x10"}]',
 35.9220, 74.3087, 'Gilgit City', 20000.00, 'CRITICAL', 'PAID'),

-- ── FLAGGED: coordinator flagged anomaly ──
(58, 50, 751, 710, 730, 720,
 'NGO_CAMPAIGN', 'Suspected Duplicate Delivery — North Karachi',
 'Coordinator flagged: GPS coordinates in the delivery report do not match expected zone.',
 'FOOD', 3, '[{"item":"Food Pack x3"}]',
 24.8600, 67.0050, 'North Karachi', 3000.00, 'MEDIUM', 'FLAGGED')

ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

-- ── SECTION 6: TASK EVENTS (audit trail) ─────────────────────────────────────
INSERT INTO task_events (task_id, user_id, event_type, metadata) VALUES
(53, 730, 'CLAIMED',   '{"note":"Volunteer claimed via app"}'),
(54, 731, 'CLAIMED',   '{"note":"Claimed by Nadia"}'),
(54, 731, 'STARTED',   '{"note":"Volunteer started task"}'),
(55, 730, 'CLAIMED',   NULL),
(55, 730, 'STARTED',   NULL),
(55, 730, 'SUBMITTED', '{"note":"Delivery submitted with photo proof"}'),
(56, 731, 'CLAIMED',   NULL),
(56, 731, 'STARTED',   NULL),
(56, 731, 'SUBMITTED', '{"note":"5 ration packs delivered"}'),
(56, 720, 'VERIFIED',  '{"coordinator":"Zara","approved":true}'),
(57, 730, 'CLAIMED',   NULL),
(57, 730, 'STARTED',   NULL),
(57, 730, 'SUBMITTED', '{"note":"All 10 tents distributed"}'),
(57, 720, 'VERIFIED',  NULL),
(57, 701, 'PAID',      '{"amount":20000}'),
(58, 730, 'CLAIMED',   NULL),
(58, 730, 'STARTED',   NULL),
(58, 720, 'FLAGGED',   '{"reason":"GPS mismatch — coordinates differ 12 km from expected delivery zone"}');

-- ── SECTION 7: DELIVERIES ────────────────────────────────────────────────────
-- Column storage_keys was renamed from photo_urls in migration 011.
-- quantity_delivered and status added in SECTION 0 above.
INSERT INTO deliveries
  (id, task_id, volunteer_id, storage_keys, gps_latitude, gps_longitude,
   notes, quantity_delivered, status, verified_by, verified_at, submitted_at)
VALUES
-- Delivery for task 55 (SUBMITTED — coordinator has not yet verified)
(50, 55, 730,
 ARRAY['https://placehold.co/400x300.jpg?text=TB+Delivery+Proof'],
 24.8700, 67.0100,
 'All 15 TB kits delivered to Dr. Farhan at the Lyari clinic. Signed receipt obtained.',
 15, 'PENDING', NULL, NULL, NOW() - INTERVAL '2 hours'),

-- Delivery for task 56 (COORDINATOR_VERIFIED)
(51, 56, 731,
 ARRAY['https://placehold.co/400x300.jpg?text=Ration+Delivery+1',
        'https://placehold.co/400x300.jpg?text=Ration+Delivery+2'],
 31.5204, 74.3587,
 '5 complete ration packs distributed. Beneficiary Usman signed the delivery sheet.',
 5, 'VERIFIED', 720, NOW() - INTERVAL '1 day', NOW() - INTERVAL '2 days'),

-- Delivery for task 57 (PAID — historical)
(52, 57, 730,
 ARRAY['https://placehold.co/400x300.jpg?text=Tent+Distribution'],
 35.9220, 74.3087,
 '10 emergency tents distributed at the Gilgit earthquake camp. Coordinator Zara verified on-site.',
 10, 'VERIFIED', 720, NOW() - INTERVAL '5 days', NOW() - INTERVAL '6 days')

ON CONFLICT (id) DO NOTHING;

-- ── SECTION 8: BENEFICIARY FEEDBACK ─────────────────────────────────────────
-- validate_feedback_ownership trigger: beneficiary_id must match task.beneficiary_id
-- delivery 51 → task 56 → beneficiary_id = 750 (Usman)  ✓
-- delivery 52 → task 57 → beneficiary_id = 750 (Usman)  ✓
INSERT INTO beneficiary_feedback
  (delivery_id, beneficiary_id, confirmation_status, rating, comment)
VALUES
(51, 750, 'RECEIVED', 5, 'Jazak Allah! Nadia arrived on time and the ration packs were complete.'),
(52, 750, 'RECEIVED', 5, 'The tents arrived before sundown. Our whole family is grateful.')
ON CONFLICT (delivery_id) DO NOTHING;

-- ── SECTION 9: CASH DONATIONS ────────────────────────────────────────────────
-- CONFIRMED donations trigger sync_campaign_raised_pkr → auto-updates raised_pkr.
-- Final raised_pkr after all inserts:
--   campaign 50 → 50k + 25k = 75,000
--   campaign 51 → 30,000
--   campaign 52 → 75,000
--   campaign 53 → 0  (DRAFT, no donations yet)
--   campaign 54 → 200k + 250k = 450,000 (COMPLETED)
INSERT INTO donations
  (id, donor_id, campaign_id, amount_pkr, status, gateway_ref,
   payment_method, approved_by, created_at)
VALUES
-- Campaign 50 — 2 confirmed + 1 pending (visible to admin for action)
(50, 740, 50,  50000.00, 'CONFIRMED', 'DEMO-TXN-0001', 'BANK_TRANSFER', 701, NOW() - INTERVAL '5 days'),
(51, 741, 50,  25000.00, 'CONFIRMED', 'DEMO-TXN-0002', 'BANK_TRANSFER', 701, NOW() - INTERVAL '3 days'),
(52, 740, 50, 100000.00, 'PENDING',   'DEMO-TXN-0003', 'BANK_TRANSFER', NULL, NOW() - INTERVAL '1 hour'),

-- Campaign 51 — 1 confirmed + 1 pending
(53, 741, 51,  30000.00, 'CONFIRMED', 'DEMO-TXN-0004', 'BANK_TRANSFER', 701, NOW() - INTERVAL '2 days'),
(54, 740, 51,  50000.00, 'PENDING',   'DEMO-TXN-0005', 'BANK_TRANSFER', NULL, NOW()),

-- Campaign 52 — 1 confirmed
(55, 740, 52,  75000.00, 'CONFIRMED', 'DEMO-TXN-0006', 'BANK_TRANSFER', 701, NOW() - INTERVAL '4 days'),

-- Campaign 54 (COMPLETED) — historical confirmed donations
(56, 741, 54, 200000.00, 'CONFIRMED', 'DEMO-TXN-0007', 'BANK_TRANSFER', 701, NOW() - INTERVAL '30 days'),
(57, 740, 54, 250000.00, 'CONFIRMED', 'DEMO-TXN-0008', 'BANK_TRANSFER', 701, NOW() - INTERVAL '28 days'),

-- Rejected donation — visible in admin donation list
(58, 741, 50,   5000.00, 'REJECTED',  'DEMO-TXN-0009', 'BANK_TRANSFER', NULL, NOW() - INTERVAL '10 days')

ON CONFLICT (id) DO NOTHING;

-- ── SECTION 10: WITHDRAWALS ──────────────────────────────────────────────────
INSERT INTO withdrawals
  (id, ngo_user_id, amount, bank_account, status,
   approved_by, approved_at, created_at)
VALUES
-- Approved (historical)
(50, 710, 100000.00, 'MCB — 1234567890123 — Khidmat Foundation',
 'APPROVED', 701, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 days'),

-- Pending — admin can approve/reject this live in the demo
(51, 710,  50000.00, 'MCB — 1234567890123 — Khidmat Foundation',
 'PENDING', NULL, NULL, NOW() - INTERVAL '1 hour'),

-- Rejected (historical)
(52, 711,  25000.00, 'HBL — 9876543210123 — Aman Relief Trust',
 'REJECTED', NULL, NULL, NOW() - INTERVAL '5 days'),

-- Pending (Aman Trust) — second withdrawal for admin demo
(53, 711,  40000.00, 'HBL — 9876543210123 — Aman Relief Trust',
 'PENDING', NULL, NULL, NOW())

ON CONFLICT (id) DO NOTHING;

-- ── SECTION 11: INKIND DONATIONS ─────────────────────────────────────────────
-- photo_url column name: originally photo_url (009) → storage_key (011) → photo_url (012)
INSERT INTO inkind_donations
  (id, donor_id, title, description, photo_url,
   address_text, latitude, longitude, status)
VALUES
-- AVAILABLE — beneficiaries can request these right now
(50, 740, 'Barely-used Winter Jacket (Men''s XL)',
 'Men''s winter jacket, worn once. Very warm. Size XL. Perfect condition.',
 NULL, 'Clifton Block 5, Karachi', 24.8182, 67.0299, 'AVAILABLE'),

(51, 741, 'Children''s Textbooks — Grade 5 & 6',
 'Full set of Punjab Textbook Board books for Grade 5 and 6. Good condition.',
 NULL, 'DHA Phase 2, Lahore', 31.4849, 74.4022, 'AVAILABLE'),

(52, 740, 'Wheelchair (Foldable, Lightweight)',
 'Excellent condition foldable wheelchair. Please donate to someone who truly needs it.',
 NULL, 'F-7 Sector, Islamabad', 33.7294, 73.0931, 'AVAILABLE'),

-- ACCEPTED — one beneficiary accepted, others were rejected
(53, 741, 'Basmati Rice — 25 kg Bag',
 'Unopened 25 kg bag of premium Basmati rice. Going to a family in need.',
 NULL, 'Gulshan-e-Iqbal, Karachi', 24.9252, 67.1014, 'ACCEPTED'),

-- COMPLETED — already delivered
(54, 740, 'Baby Clothes Bundle (0–12 months)',
 '20+ pieces of washed, good-condition baby clothes for a family with a newborn.',
 NULL, 'Johar Town, Lahore', 31.4540, 74.2791, 'COMPLETED')

ON CONFLICT (id) DO NOTHING;

-- ── SECTION 12: INKIND REQUESTS ──────────────────────────────────────────────
-- Must be inserted BEFORE inkind chat rooms because rooms reference request IDs.
-- inkind_requests_one_per_beneficiary prevents duplicate (donation_id, beneficiary_id).
INSERT INTO inkind_requests
  (id, donation_id, beneficiary_id, message, phone, email,
   status, donor_shared_phone, accepted_at, chat_room_id)
VALUES
-- Request for jacket (item 50) — PENDING
(50, 50, 751,
 'Assalam-o-alaikum, I have 3 school-age children and my son desperately needs a warm jacket.',
 '03001234567', 'beneficiary2@demo.pk',
 'PENDING', NULL, NULL, NULL),

-- Request for rice (item 53) — ACCEPTED (donor shared phone, chat started)
-- chat_room_id will be set after room 50 is created
(51, 53, 750,
 'We are a family of 5. This rice would feed us for an entire month. Jazak Allah Khair.',
 '03007654321', 'beneficiary@demo.pk',
 'ACCEPTED', '03119876543', NOW() - INTERVAL '1 day', NULL),

-- Second request for rice (item 53, same item, different beneficiary) — REJECTED
(52, 53, 751,
 'Please help. I need this rice for my elderly mother who is very ill.',
 '03331234567', 'beneficiary2@demo.pk',
 'REJECTED', NULL, NULL, NULL),

-- Request for textbooks (item 51) — PENDING with chat room
-- chat_room_id will be set after room 51 is created
(53, 51, 750,
 'My son is in Grade 5 and we cannot afford textbooks this year.',
 '03001234567', 'beneficiary@demo.pk',
 'PENDING', NULL, NULL, NULL)

ON CONFLICT (id) DO NOTHING;

-- ── SECTION 13: CHAT ROOMS ───────────────────────────────────────────────────
-- InKind rooms: task_id=NULL, inkind_request_id IS NOT NULL  (constraint from migration 012)
-- Task rooms:   task_id IS NOT NULL, inkind_request_id=NULL
-- Unique index on task_id (migration 003) allows multiple NULLs.

-- InKind rooms — inkind_request_id already set (requests exist from section 12)
INSERT INTO chat_rooms (id, task_id, inkind_request_id, created_by) VALUES
(50, NULL, 51, 750),  -- Room: Usman ↔ Ayesha about the accepted rice donation
(51, NULL, 53, 750)   -- Room: Usman ↔ Ayesha about the textbook request
ON CONFLICT (id) DO NOTHING;

-- Task-based rooms
INSERT INTO chat_rooms (id, task_id, inkind_request_id, created_by) VALUES
(52, 53, NULL, 710),  -- Task 53 (CLAIMED) — volunteer + NGO coordination
(53, 55, NULL, 710),  -- Task 55 (SUBMITTED) — delivery follow-up
(54, 57, NULL, 710)   -- Task 57 (PAID) — historical conversation
ON CONFLICT (id) DO NOTHING;

-- Link requests back to their rooms now that rooms exist
UPDATE inkind_requests SET chat_room_id = 50 WHERE id = 51 AND chat_room_id IS NULL;
UPDATE inkind_requests SET chat_room_id = 51 WHERE id = 53 AND chat_room_id IS NULL;

-- ── SECTION 14: CHAT MESSAGES ────────────────────────────────────────────────
INSERT INTO chat_messages (room_id, sender_id, text, created_at) VALUES
-- Room 52: Task 53 coordination (NGO + Volunteer + Coordinator)
(52, 710, 'Bilal, the 20 water gallons are ready at the NGO office. Please collect before 3 pm.', NOW() - INTERVAL '3 hours'),
(52, 730, 'On my way! Will reach by 2 pm.', NOW() - INTERVAL '2 hours 30 minutes'),
(52, 720, 'Bilal, beneficiary contact: 0300-1234567. Please coordinate directly with them.', NOW() - INTERVAL '2 hours'),

-- Room 53: Task 55 delivery tracking
(53, 710, 'Bilal, all 15 TB kits are packed and labelled. Delivery: Lyari Community Health Center, Ward 3.', NOW() - INTERVAL '5 hours'),
(53, 730, 'Received and delivered! Dr. Farhan signed the receipt. Photos submitted in the app.', NOW() - INTERVAL '2 hours'),
(53, 720, 'Excellent work. Reviewing your delivery evidence now.', NOW() - INTERVAL '1 hour'),

-- Room 54: Task 57 historical (PAID)
(54, 710, 'Tent delivery confirmed and payment processed. Thank you for the incredible response!', NOW() - INTERVAL '5 days'),
(54, 730, 'It was an honour. The families were so relieved. Ready for the next mission.', NOW() - INTERVAL '5 days'),

-- Room 50: InKind — rice request accepted (donor ↔ beneficiary)
(50, 741, 'Your request has been accepted! Please call me at 0311-9876543 to arrange pickup.', NOW() - INTERVAL '22 hours'),
(50, 750, 'Jazak Allah! I will call you this afternoon.', NOW() - INTERVAL '21 hours'),
(50, 741, 'Great! I am home all day. Address: House 12, Gulshan-e-Iqbal, near Nipa Chowrangi.', NOW() - INTERVAL '20 hours');

-- ── SECTION 15: GOODS CAMPAIGNS ──────────────────────────────────────────────
-- goods_campaigns.ngo_id references users(id), NOT ngo_profiles(id)
INSERT INTO goods_campaigns
  (id, ngo_id, title, item_needed, category, target_qty, unit,
   description, location_text, latitude, longitude,
   deadline, status, qty_received)
VALUES
(50, 710, 'Flour Drive — Karachi Flood Relief',
 'Wheat Flour', 'Food', 5000, 'kg',
 'Collecting wheat flour for 500 flood-affected families. Each family needs 10 kg. Donors can drop off any quantity.',
 'Khidmat Foundation Office, Orangi Town, Karachi', 24.8607, 67.0011,
 CURRENT_DATE + 30, 'ACTIVE', 1250.00),

(51, 710, 'Blanket Collection — Winter Emergency',
 'Woolen Blankets', 'Clothing', 1000, 'pieces',
 'Collecting warm blankets for Balochistan families. Standard double-bed size. Good condition only.',
 'Khidmat Foundation HQ, Karachi', 24.8182, 67.0299,
 CURRENT_DATE + 15, 'ACTIVE', 340.00),

(52, 711, 'Medical Supplies Drive',
 'First Aid Kits', 'Medical', 200, 'units',
 'Collecting sealed first aid kits for rural health posts in South Punjab. Must be within expiry date.',
 'Aman Relief Trust HQ, Lahore', 31.5204, 74.3587,
 CURRENT_DATE + 45, 'ACTIVE', 75.00),

(53, 711, 'Back-to-School Stationery Drive',
 'Stationery Sets', 'Education', 500, 'sets',
 'Collecting stationery packs (pencils, pens, eraser, sharpener, ruler, notebook) for underprivileged students.',
 'Aman Trust, Lahore', 31.5204, 74.3587,
 CURRENT_DATE + 60, 'DRAFT', 0.00)

ON CONFLICT (id) DO NOTHING;

-- ── SECTION 16: GOODS DONATIONS ──────────────────────────────────────────────
INSERT INTO goods_donations
  (id, campaign_id, donor_id, item_name, category, description,
   quantity, unit, pickup_address, pickup_lat, pickup_lng,
   contact_number, status, volunteer_id, qty_confirmed, submitted_at)
VALUES
-- Campaign 50 (Flour) — one approved, one delivered (awaiting approval), one assigned, one pending
(50, 50, 740, 'Wheat Flour', 'Food',
 'Chakki atta, 10 bags of 25 kg each. Fresh stock, bought specifically for donation.',
 250, 'kg', 'House 12, Block B, PECHS, Karachi', 24.8706, 67.0634,
 '03001234567', 'APPROVED', 730, 250, NOW() - INTERVAL '5 days'),

(51, 50, 741, 'Wheat Flour', 'Food',
 'Premium quality flour, 10 bags of 10 kg each.',
 100, 'kg', 'Flat 5, Gulshan-e-Iqbal, Karachi', 24.9252, 67.1014,
 '03331234567', 'DELIVERED', 731, 100, NOW() - INTERVAL '2 days'),

(52, 50, 740, 'Wheat Flour', 'Food',
 '5 sacks of 25 kg each. Volunteer assigned for pickup.',
 125, 'kg', 'Plot 7, DHA Phase 5, Karachi', 24.8107, 67.0747,
 '03001234567', 'ASSIGNED', 730, NULL, NOW() - INTERVAL '1 day'),

(53, 50, 741, 'Wheat Flour', 'Food',
 'Just purchased 15 bags for donation. Ready for pickup anytime.',
 150, 'kg', 'Apartment 3B, Clifton Block 4, Karachi', 24.8182, 67.0299,
 '03331234567', 'PENDING', NULL, NULL, NOW()),

-- Campaign 51 (Blankets) — one approved, one pending
(54, 51, 740, 'Woolen Blankets', 'Clothing',
 'Heavy winter blankets, king size. New condition, bought last winter but unused.',
 50, 'pieces', 'House 20, Gulberg III, Lahore', 31.5160, 74.3477,
 '03001234567', 'APPROVED', 731, 50, NOW() - INTERVAL '3 days'),

(55, 51, 741, 'Woolen Blankets', 'Clothing',
 'Good quality blankets, used for only one season. Washed and packed.',
 30, 'pieces', 'DHA Phase 4, Lahore', 31.4849, 74.4022,
 '03331234567', 'PENDING', NULL, NULL, NOW()),

-- Campaign 52 (Medical) — one pending
(56, 52, 740, 'First Aid Kits', 'Medical',
 'Standard WHO first aid kits, sealed, all within expiry (expires 2027). 25 units.',
 25, 'units', 'Office 7, Blue Area, Islamabad', 33.7294, 73.0931,
 '03001234567', 'PENDING', NULL, NULL, NOW())

ON CONFLICT (id) DO NOTHING;

-- Goods status log
INSERT INTO goods_status_log (donation_id, changed_by, old_status, new_status, note) VALUES
(50, 730, 'PENDING',   'ASSIGNED',  'Volunteer Bilal claimed this pickup'),
(50, 730, 'ASSIGNED',  'DELIVERED', '250 kg flour delivered to NGO warehouse'),
(50, 701, 'DELIVERED', 'APPROVED',  'Admin confirmed: 250 kg received. Campaign updated.'),
(51, 731, 'PENDING',   'ASSIGNED',  'Volunteer Nadia assigned'),
(51, 731, 'ASSIGNED',  'DELIVERED', '100 kg flour delivered to distribution point'),
(52, 730, 'PENDING',   'ASSIGNED',  'Bilal assigned for pickup tomorrow'),
(54, 731, 'PENDING',   'ASSIGNED',  'Nadia assigned'),
(54, 731, 'ASSIGNED',  'DELIVERED', '50 blankets delivered to Aman HQ, Lahore'),
(54, 701, 'DELIVERED', 'APPROVED',  'Confirmed: 50 blankets added to campaign tally');

-- ── SECTION 17: AUDIT LOGS ───────────────────────────────────────────────────
INSERT INTO audit_logs
  (admin_id, action_type, target_entity, target_id, metadata)
VALUES
(701, 'APPROVE_DONATION',   'donations',   50, '{"amount":50000,"donor":"Hassan Donor","campaign":"Karachi Flood Emergency 2026"}'),
(701, 'APPROVE_DONATION',   'donations',   51, '{"amount":25000,"donor":"Ayesha Donor","campaign":"Karachi Flood Emergency 2026"}'),
(701, 'APPROVE_DONATION',   'donations',   53, '{"amount":30000,"donor":"Ayesha Donor","campaign":"Winter Blanket Drive"}'),
(701, 'APPROVE_DONATION',   'donations',   55, '{"amount":75000,"donor":"Hassan Donor","campaign":"Orphan Education Fund"}'),
(701, 'APPROVE_DONATION',   'donations',   56, '{"amount":200000,"donor":"Ayesha Donor","campaign":"Earthquake Response 2025"}'),
(701, 'APPROVE_DONATION',   'donations',   57, '{"amount":250000,"donor":"Hassan Donor","campaign":"Earthquake Response 2025"}'),
(701, 'APPROVE_WITHDRAWAL', 'withdrawals', 50, '{"amount":100000,"ngo":"Khidmat Foundation","bank":"MCB Bank"}'),
(701, 'REJECT_WITHDRAWAL',  'withdrawals', 52, '{"amount":25000,"ngo":"Aman Relief Trust","reason":"Insufficient wallet balance at time of request"}'),
(701, 'UPDATE_CAMPAIGN',    'campaigns',   54, '{"old_status":"ACTIVE","new_status":"COMPLETED","reason":"All objectives met — earthquake relief mission concluded"}'),
(701, 'FLAG_TASK',          'tasks',       58, '{"reason":"GPS coordinates in delivery report do not match the expected delivery zone"}');

-- ── SECTION 18: LEDGER ENTRIES ───────────────────────────────────────────────
INSERT INTO ledger_entries
  (type, amount_pkr, from_user_id, to_user_id, ref_table, ref_id)
VALUES
('DONATION',    50000.00, 740, NULL, 'donations',   50),
('DONATION',    25000.00, 741, NULL, 'donations',   51),
('DONATION',    30000.00, 741, NULL, 'donations',   53),
('DONATION',    75000.00, 740, NULL, 'donations',   55),
('DONATION',   200000.00, 741, NULL, 'donations',   56),
('DONATION',   250000.00, 740, NULL, 'donations',   57),
('WITHDRAWAL', 100000.00, 710, NULL, 'withdrawals', 50)
ON CONFLICT (type, ref_table, ref_id) DO NOTHING;

-- ── SECTION 19: SEQUENCE RESETS ──────────────────────────────────────────────
-- Ensures auto-increment counters are beyond the seeded IDs so new records
-- created through the app never clash with demo data.
SELECT setval('users_id_seq',                GREATEST((SELECT MAX(id) FROM users),               800));
SELECT setval('ngo_profiles_id_seq',         GREATEST((SELECT MAX(id) FROM ngo_profiles),         60));
SELECT setval('volunteer_profiles_id_seq',   GREATEST((SELECT MAX(id) FROM volunteer_profiles),    60));
SELECT setval('campaigns_id_seq',            GREATEST((SELECT MAX(id) FROM campaigns),             60));
SELECT setval('tasks_id_seq',                GREATEST((SELECT MAX(id) FROM tasks),                 60));
SELECT setval('task_events_id_seq',          GREATEST((SELECT MAX(id) FROM task_events),          200));
SELECT setval('deliveries_id_seq',           GREATEST((SELECT MAX(id) FROM deliveries),            60));
SELECT setval('beneficiary_feedback_id_seq', GREATEST((SELECT MAX(id) FROM beneficiary_feedback),  60));
SELECT setval('donations_id_seq',            GREATEST((SELECT MAX(id) FROM donations),             60));
SELECT setval('withdrawals_id_seq',          GREATEST((SELECT MAX(id) FROM withdrawals),           60));
SELECT setval('inkind_donations_id_seq',     GREATEST((SELECT MAX(id) FROM inkind_donations),      60));
SELECT setval('inkind_requests_id_seq',      GREATEST((SELECT MAX(id) FROM inkind_requests),       60));
SELECT setval('chat_rooms_id_seq',           GREATEST((SELECT MAX(id) FROM chat_rooms),            60));
SELECT setval('chat_messages_id_seq',        GREATEST((SELECT MAX(id) FROM chat_messages),        200));
SELECT setval('goods_campaigns_id_seq',      GREATEST((SELECT MAX(id) FROM goods_campaigns),       60));
SELECT setval('goods_donations_id_seq',      GREATEST((SELECT MAX(id) FROM goods_donations),       60));
SELECT setval('goods_status_log_id_seq',     GREATEST((SELECT MAX(id) FROM goods_status_log),     200));
SELECT setval('audit_logs_id_seq',           GREATEST((SELECT MAX(id) FROM audit_logs),           200));
SELECT setval('ledger_entries_id_seq',       GREATEST((SELECT MAX(id) FROM ledger_entries),       200));

COMMIT;
