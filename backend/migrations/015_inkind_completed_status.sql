-- Allow beneficiaries to mark an inkind donation as COMPLETED after receipt.
-- The service calls completeDonation() which sets status='COMPLETED', but the
-- original CHECK constraint in 009_inkind_donations.sql only allows
-- ('AVAILABLE','ACCEPTED','CANCELLED'). This migration widens it.

ALTER TABLE inkind_donations DROP CONSTRAINT IF EXISTS inkind_donations_status_check;

ALTER TABLE inkind_donations
  ADD CONSTRAINT inkind_donations_status_check
  CHECK (status IN ('AVAILABLE', 'ACCEPTED', 'CANCELLED', 'COMPLETED'));
