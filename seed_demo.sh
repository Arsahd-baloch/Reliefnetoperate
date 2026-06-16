#!/usr/bin/env bash
# DisasterAid Demo Seed Script — populates all features via API
# Run: bash seed_demo.sh

BASE="https://finalreliefnet-production.up.railway.app/api"

# ─── Helpers ──────────────────────────────────────────────────────────────────
post()  { curl -s -X POST  "$BASE$1" -H "Content-Type: application/json" -H "Authorization: Bearer $2" -d "$3"; }
patch() { curl -s -X PATCH "$BASE$1" -H "Content-Type: application/json" -H "Authorization: Bearer $2" -d "$3"; }
del()   { curl -s -X DELETE "$BASE$1" -H "Authorization: Bearer $2"; }
login() { curl -s -X POST "$BASE/auth/login" -H "Content-Type: application/json" -d "{\"email\":\"$1\",\"password\":\"password123\"}" | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])"; }
jid()   { echo "$1" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id','ERR'))"; }
ok()  { echo "  ✓ $1"; }
err() { echo "  ✗ $1: $2"; }
section() { echo; echo "══ $1 ══"; }

# ─── Login all accounts ───────────────────────────────────────────────────────
section "Logging in"
ADMIN=$(login "super@disasteraid.pk");  ok "Admin"
NGO1=$(login "contact@redcross.pk");    ok "NGO1 Red Cross"
NGO2=$(login "info@edhi.org");          ok "NGO2 Edhi"
NGO3=$(login "saylani@trust.pk");       ok "NGO3 Saylani"
VOL1=$(login "ahmed@volunteer.pk");     ok "Volunteer1 Ahmed"
VOL2=$(login "sara@volunteer.pk");      ok "Volunteer2 Sara"
VOL3=$(login "john@volunteer.pk");      ok "Volunteer3 John"
DONOR1=$(login "rich@donor.pk");        ok "Donor1 Whale"
DONOR2=$(login "m1@donor.pk");          ok "Donor2 Micro1"
DONOR3=$(login "m2@donor.pk");          ok "Donor3 Micro2"
DONOR4=$(login "d3@donor.pk");          ok "Donor4 D3"
BEN1=$(login "zia@needs.pk");           ok "Beneficiary1 Zia"
BEN2=$(login "fatima@needs.pk");        ok "Beneficiary2 Fatima"
BEN3=$(login "b3@needs.pk");            ok "Beneficiary3 B3"
COORD=$(login "c1@field.pk");           ok "Coordinator"

# ─── 1. NGO bank details ──────────────────────────────────────────────────────
section "NGO Bank Details"
patch "/ngo/profile" "$NGO1" '{"bank_name":"HBL Bank","account_title":"Red Cross PK","account_number":"PK36HABB0000000012345678"}' > /dev/null
ok "Red Cross — HBL PK36HABB0000000012345678"
patch "/ngo/profile" "$NGO2" '{"bank_name":"MCB Bank","account_title":"Edhi Foundation","account_number":"PK70MCBL0000001234567890"}' > /dev/null
ok "Edhi — MCB PK70MCBL0000001234567890"
patch "/ngo/profile" "$NGO3" '{"bank_name":"UBL Bank","account_title":"Saylani Welfare Trust","account_number":"PK24UNIL0000000012345678"}' > /dev/null
ok "Saylani — UBL PK24UNIL0000000012345678"

# ─── 2. Confirm pending money donations ───────────────────────────────────────
section "Confirm Pending Donations"
R=$(post "/donations/3/approve" "$ADMIN" '{}')
echo "$R" | grep -q "error" && err "Donation #3" "$R" || ok "Donation #3 PKR 250,000 → CONFIRMED"
R=$(post "/donations/6/approve" "$ADMIN" '{}')
echo "$R" | grep -q "error" && err "Donation #6" "$R" || ok "Donation #6 PKR 50 → CONFIRMED"

# ─── 3. Goods campaigns (NGO creates + activates) ─────────────────────────────
section "Goods Campaigns"

R=$(post "/goods-campaigns" "$NGO1" '{
  "title": "Flood Survivors Food Drive",
  "item_needed": "Rice Bags (10kg)",
  "category": "Food",
  "target_qty": 500,
  "unit": "bags",
  "description": "We need 10kg rice bags to feed 500 flood-displaced families in Sukkur. Each bag feeds a family of 5 for one week.",
  "location_text": "Sukkur Relief Camp, Sindh",
  "latitude": 27.7052,
  "longitude": 68.8574,
  "deadline": "2026-08-31"
}')
GC1_ID=$(jid "$R")
patch "/goods-campaigns/$GC1_ID" "$NGO1" '{"status":"ACTIVE"}' > /dev/null
ok "Goods Campaign 1: Food Drive (id=$GC1_ID) — ACTIVE"

R=$(post "/goods-campaigns" "$NGO2" '{
  "title": "Winter Clothing for Balochistan",
  "item_needed": "Winter Jackets",
  "category": "Clothing",
  "target_qty": 300,
  "unit": "jackets",
  "description": "Collecting winter jackets for displaced families in Quetta. Temperature drops to -5°C. All sizes welcome.",
  "location_text": "Edhi Centre, Quetta, Balochistan",
  "latitude": 30.1798,
  "longitude": 66.9750,
  "deadline": "2026-09-15"
}')
GC2_ID=$(jid "$R")
patch "/goods-campaigns/$GC2_ID" "$NGO2" '{"status":"ACTIVE"}' > /dev/null
ok "Goods Campaign 2: Winter Clothing (id=$GC2_ID) — ACTIVE"

R=$(post "/goods-campaigns" "$NGO3" '{
  "title": "Medical Supplies for Field Clinic",
  "item_needed": "First Aid Kits",
  "category": "Medical",
  "target_qty": 200,
  "unit": "kits",
  "description": "Saylani Trust field clinic in Larkana needs standard first aid kits, bandages, antiseptics and ORS sachets.",
  "location_text": "Saylani Field Clinic, Larkana, Sindh",
  "latitude": 27.5590,
  "longitude": 68.2108,
  "deadline": "2026-07-30"
}')
GC3_ID=$(jid "$R")
patch "/goods-campaigns/$GC3_ID" "$NGO3" '{"status":"ACTIVE"}' > /dev/null
ok "Goods Campaign 3: Medical Supplies (id=$GC3_ID) — ACTIVE"

# ─── 4. Goods donations (donors submit items) ─────────────────────────────────
section "Goods Donations"

R=$(post "/goods-donations" "$DONOR1" "{
  \"campaign_id\": $GC1_ID,
  \"item_name\": \"Rice Bags 10kg\",
  \"category\": \"Food\",
  \"description\": \"Brand new sealed rice bags from Al-Baraka Mills, Lahore. Ready for pickup anytime.\",
  \"photo_url\": \"https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg\",
  \"quantity\": 50,
  \"unit\": \"bags\",
  \"pickup_address\": \"Plot 45 DHA Phase 6, Lahore\",
  \"pickup_lat\": 31.4504,
  \"pickup_lng\": 74.3587,
  \"contact_number\": \"+92-300-1234567\"
}")
GD1_ID=$(jid "$R")
ok "Goods Donation 1: 50 rice bags by Whale Donor (id=$GD1_ID)"

R=$(post "/goods-donations" "$DONOR2" "{
  \"campaign_id\": $GC1_ID,
  \"item_name\": \"Rice Bags 10kg\",
  \"category\": \"Food\",
  \"description\": \"Basmati rice bags collected from family. Good quality, sealed, ready for pickup.\",
  \"quantity\": 20,
  \"unit\": \"bags\",
  \"pickup_address\": \"House 12 Block B, Gulberg III, Lahore\",
  \"pickup_lat\": 31.5204,
  \"pickup_lng\": 74.3587,
  \"contact_number\": \"+92-321-9876543\"
}")
GD2_ID=$(jid "$R")
ok "Goods Donation 2: 20 rice bags by Donor2 (id=$GD2_ID)"

R=$(post "/goods-donations" "$DONOR3" "{
  \"campaign_id\": $GC2_ID,
  \"item_name\": \"Winter Jackets Mixed Sizes\",
  \"category\": \"Clothing\",
  \"description\": \"Mixed sizes (M/L/XL) winter jackets, gently used but in excellent condition. All dry-cleaned.\",
  \"photo_url\": \"https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg\",
  \"quantity\": 30,
  \"unit\": \"jackets\",
  \"pickup_address\": \"Apartment 3C, Clifton Block 5, Karachi\",
  \"pickup_lat\": 24.8142,
  \"pickup_lng\": 67.0222,
  \"contact_number\": \"+92-333-5556667\"
}")
GD3_ID=$(jid "$R")
ok "Goods Donation 3: 30 jackets by Donor3 (id=$GD3_ID)"

R=$(post "/goods-donations" "$DONOR4" "{
  \"campaign_id\": $GC3_ID,
  \"item_name\": \"First Aid Kits\",
  \"category\": \"Medical\",
  \"description\": \"Standard first aid kits, factory sealed, expiry 2028. Purchased from Fazal Din medical store, Islamabad.\",
  \"photo_url\": \"https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg\",
  \"quantity\": 40,
  \"unit\": \"kits\",
  \"pickup_address\": \"38 Faisal Town, Islamabad\",
  \"pickup_lat\": 33.6844,
  \"pickup_lng\": 73.0479,
  \"contact_number\": \"+92-345-1112223\"
}")
GD4_ID=$(jid "$R")
ok "Goods Donation 4: 40 first aid kits by Donor4 (id=$GD4_ID)"

# ─── 5. Volunteers claim goods donations ─────────────────────────────────────
section "Volunteer Claims (Goods)"
R=$(patch "/goods-donations/$GD1_ID/claim" "$VOL1" '{}')
echo "$R" | grep -q "error" && err "GD1 claim" "$R" || ok "Ahmed claimed GD1 (50 rice bags, Lahore)"
R=$(patch "/goods-donations/$GD3_ID/claim" "$VOL2" '{}')
echo "$R" | grep -q "error" && err "GD3 claim" "$R" || ok "Sara claimed GD3 (30 jackets, Karachi)"
R=$(patch "/goods-donations/$GD4_ID/claim" "$VOL3" '{}')
echo "$R" | grep -q "error" && err "GD4 claim" "$R" || ok "John claimed GD4 (40 kits, Islamabad)"

# ─── 6. Volunteer marks delivered ────────────────────────────────────────────
section "Volunteer Deliveries"
R=$(patch "/goods-donations/$GD1_ID/deliver" "$VOL1" '{
  "proof_photo_url": "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
  "qty_confirmed": 50,
  "volunteer_note": "All 50 bags delivered to Sukkur camp. Signed receipt from camp in-charge Muhammad Tahir."
}')
echo "$R" | grep -q "error" && err "GD1 deliver" "$R" || ok "Ahmed delivered GD1 — 50 rice bags with proof"

R=$(patch "/goods-donations/$GD3_ID/deliver" "$VOL2" '{
  "proof_photo_url": "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
  "qty_confirmed": 28,
  "volunteer_note": "28 of 30 jackets delivered. 2 were damaged during transport and left behind."
}')
echo "$R" | grep -q "error" && err "GD3 deliver" "$R" || ok "Sara delivered GD3 — 28 jackets with proof"

# ─── 7. Coordinator approves / rejects deliveries ─────────────────────────────
section "Coordinator Review (Goods)"
R=$(patch "/goods-donations/$GD1_ID/approve" "$COORD" '{}')
echo "$R" | grep -q "error" && err "GD1 approve" "$R" || ok "GD1 APPROVED — rice bags confirmed by coordinator"

R=$(patch "/goods-donations/$GD3_ID/approve" "$COORD" '{}')
echo "$R" | grep -q "error" && err "GD3 approve" "$R" || ok "GD3 APPROVED — jackets confirmed by coordinator"

R=$(patch "/goods-donations/$GD4_ID/reject" "$COORD" '{"rejection_reason":"Volunteer did not pick up within 48 hours. Item re-listed for another volunteer."}')
echo "$R" | grep -q "error" && err "GD4 reject" "$R" || ok "GD4 REJECTED — first aid kits (shows reject flow for demo)"

# ─── 8. InKind donations (donors list physical items) ─────────────────────────
section "InKind Donations"

R=$(post "/inkind" "$DONOR1" '{
  "title": "Sewing Machine — Singer Model 2020",
  "description": "Working Singer sewing machine, 5 years old, fully serviced last month. Ideal for a woman who wants to earn income through tailoring. Comes with extra needles and thread.",
  "photo_url": "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
  "address_text": "Plot 45 DHA Phase 6, Lahore",
  "latitude": 31.4504,
  "longitude": 74.3587
}')
IK1_ID=$(jid "$R")
ok "InKind 1: Sewing Machine (id=$IK1_ID)"

R=$(post "/inkind" "$DONOR2" '{
  "title": "School Bags + Stationery — 10 complete sets",
  "description": "10 complete school bag sets with notebooks, pens, pencils, rulers and geometry boxes. Suitable for grades 3-7. Brand new, purchased from Packages Mall.",
  "photo_url": "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
  "address_text": "House 12 Block B, Gulberg III, Lahore",
  "latitude": 31.5204,
  "longitude": 74.3587
}')
IK2_ID=$(jid "$R")
ok "InKind 2: School Bags (id=$IK2_ID)"

R=$(post "/inkind" "$DONOR3" '{
  "title": "Wheelchair — Lightweight Foldable",
  "description": "Lightly used foldable wheelchair in excellent condition. Purchased 6 months ago. Suitable for elderly or injured person. Includes padded seat and armrests.",
  "photo_url": "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
  "address_text": "Apartment 3C, Clifton Block 5, Karachi",
  "latitude": 24.8142,
  "longitude": 67.0222
}')
IK3_ID=$(jid "$R")
ok "InKind 3: Wheelchair (id=$IK3_ID)"

R=$(post "/inkind" "$DONOR4" '{
  "title": "Household Kitchen Essentials Box",
  "description": "Large box with 12 plates, 8 cups, 2 cooking pots, 1 pressure cooker, and basic cutlery set. All clean and functional. For a displaced family starting fresh.",
  "address_text": "38 Faisal Town, Islamabad",
  "latitude": 33.6844,
  "longitude": 73.0479
}')
IK4_ID=$(jid "$R")
ok "InKind 4: Kitchen Essentials (id=$IK4_ID)"

# ─── 9. Beneficiaries request inkind donations ────────────────────────────────
section "InKind Requests"
R=$(post "/inkind/$IK1_ID/request" "$BEN1" '{
  "message": "I am a flood victim from Sukkur. My wife knows tailoring and this machine will help us rebuild our income. We lost everything in the flood.",
  "phone": "+92-311-2223334",
  "email": "zia@needs.pk"
}')
IKR1_ID=$(jid "$R")
ok "Zia requested sewing machine (req id=$IKR1_ID)"

R=$(post "/inkind/$IK2_ID/request" "$BEN2" '{
  "message": "My 3 children need school supplies. We cannot afford books this year due to medical expenses from flood injuries.",
  "phone": "+92-322-4445556"
}')
IKR2_ID=$(jid "$R")
ok "Fatima requested school bags (req id=$IKR2_ID)"

R=$(post "/inkind/$IK1_ID/request" "$BEN3" '{
  "message": "I am a widow with 4 children. A sewing machine would allow me to take tailoring orders and earn income for my family.",
  "phone": "+92-333-6667778"
}')
IKR3_ID=$(jid "$R")
ok "B3 also requested sewing machine (competing req id=$IKR3_ID)"

R=$(post "/inkind/$IK3_ID/request" "$BEN2" '{
  "message": "My mother was injured in the earthquake and needs a wheelchair to move around. She is 70 years old.",
  "phone": "+92-322-4445556"
}')
IKR4_ID=$(jid "$R")
ok "Fatima requested wheelchair (req id=$IKR4_ID)"

R=$(post "/inkind/$IK4_ID/request" "$BEN1" '{
  "message": "We lost all kitchen items in the flood. A family of 6 needs basic cooking equipment to survive.",
  "phone": "+92-311-2223334"
}')
IKR5_ID=$(jid "$R")
ok "Zia requested kitchen essentials (req id=$IKR5_ID)"

# ─── 10. Donors accept requests ───────────────────────────────────────────────
section "InKind Acceptances"
# Accept Zia for sewing machine (reject B3's competing request)
R=$(post "/inkind/requests/$IKR1_ID/accept" "$DONOR1" '{"donor_shared_phone":"+92-300-1234567"}')
echo "$R" | grep -q "error" && err "IKR1 accept" "$R" || ok "Sewing machine → Zia's request ACCEPTED"

R=$(post "/inkind/requests/$IKR2_ID/accept" "$DONOR2" '{"donor_shared_phone":"+92-321-9876543"}')
echo "$R" | grep -q "error" && err "IKR2 accept" "$R" || ok "School bags → Fatima's request ACCEPTED"

R=$(post "/inkind/requests/$IKR4_ID/accept" "$DONOR3" '{"donor_shared_phone":"+92-333-5556667"}')
echo "$R" | grep -q "error" && err "IKR4 accept" "$R" || ok "Wheelchair → Fatima's request ACCEPTED"

R=$(post "/inkind/requests/$IKR5_ID/accept" "$DONOR4" '{"donor_shared_phone":"+92-345-1112223"}')
echo "$R" | grep -q "error" && err "IKR5 accept" "$R" || ok "Kitchen essentials → Zia's request ACCEPTED"

# ─── 11. Extra withdrawal request for NGO demo ────────────────────────────────
section "Withdrawal Requests"
R=$(post "/withdrawals" "$NGO2" '{"amount":150000,"bank_account":"PK70MCBL0000001234567890"}')
echo "$R" | grep -q "error" && err "Edhi withdrawal" "$R" || ok "Edhi requested PKR 150,000 withdrawal (PENDING)"
R=$(post "/withdrawals" "$NGO1" '{"amount":75000,"bank_account":"PK36HABB0000000012345678"}')
echo "$R" | grep -q "error" && err "RedCross withdrawal" "$R" || ok "Red Cross requested PKR 75,000 withdrawal (PENDING)"

# ─── Done ─────────────────────────────────────────────────────────────────────
echo
echo "══════════════════════════════════════════════════════"
echo "  Demo seed complete — all features populated!"
echo "══════════════════════════════════════════════════════"
echo
echo "Credentials (all use password: password123)"
echo "  ADMIN:       super@disasteraid.pk  /  finance@disasteraid.pk"
echo "  NGO:         contact@redcross.pk  /  info@edhi.org  /  saylani@trust.pk"
echo "  VOLUNTEER:   ahmed@volunteer.pk  /  sara@volunteer.pk  /  john@volunteer.pk"
echo "  DONOR:       rich@donor.pk  /  m1@donor.pk  /  m2@donor.pk  /  d3@donor.pk"
echo "  BENEFICIARY: zia@needs.pk  /  fatima@needs.pk  /  b3@needs.pk"
echo "  COORDINATOR: c1@field.pk"
