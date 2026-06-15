-- 014: Add bank details to ngo_profiles for manual donation transfers
ALTER TABLE ngo_profiles
  ADD COLUMN IF NOT EXISTS bank_name VARCHAR(100),
  ADD COLUMN IF NOT EXISTS account_title VARCHAR(100),
  ADD COLUMN IF NOT EXISTS account_number VARCHAR(100);
