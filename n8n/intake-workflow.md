# n8n Intake Workflow (Baseline)
*Last edited: 2026-04-02 · Last reviewed: —*

Baseline n8n workflow that proves the Prospect Data → New Leads pipeline. Receives a new lead via webhook, searches Prospect Data for a matching Property record, enriches the lead if found, and creates a Contact + Opportunity in New Leads.

This is a **skeleton workflow**. Source-specific automations (Cold Call intake, Cold Email intake, VAPI intake, etc.) will be cloned from this baseline and customized per source.

Reference files:

- [prospect-data/data-model.md](../prospect-data/data-model.md) — Property schema + field mapping
- [new-leads/data-model.md](../new-leads/data-model.md) — Contact/Opportunity fields, lead entry rules
- [prospect-data/rules.md](../prospect-data/rules.md) — Push-to-CRM rules, DNC handling
- [new-leads/workflows.md](../new-leads/workflows.md) — WF-New-Lead-Entry (fires after this workflow creates a lead)

---

## Overview

```
Webhook (lead data)
  │
  ▼
Validate (need at least 1 identifier)
  │
  ▼
Search Prospect Data ──► ref ID → phone → email (cascade)
  │                          │
  ├── Match found            ├── Multi-match → flag, use first
  │   ├── DNC? → halt        │
  │   └── Enrich lead        └── No match → skip enrichment
  │
  ▼
Check New Leads for existing Contact
  │
  ├── Exists + DNC → halt
  ├── Exists → re-submission path
  └── New → create path
  │
  ▼
Create/Update Contact + Opportunity in New Leads
  │
  ▼
Update Prospect Data (if match found)
  │
  ▼
Return response
```

---

## Webhook Endpoint

**Method:** POST
**Auth:** Webhook-specific token or header key (configured in n8n)

### Payload

```json
{
  "reference_id": "TX-TRAVIS-00123",
  "phone": "+15125551234",
  "email": "owner@example.com",
  "first_name": "John",
  "last_name": "Smith",
  "source": "Cold Call",
  "caller_name": "Agent Mike"
}
```

### Field Definitions

| Field | Required | Type | Notes |
| --- | --- | --- | --- |
| `reference_id` | Conditional | String | Property Reference ID. At least one of `reference_id`, `phone`, or `email` must be present. |
| `phone` | Conditional | String | The confirmed phone — the number the lead called from, answered on, or texted from. E.164 format preferred. |
| `email` | Conditional | String | The confirmed email — the address the lead replied from. |
| `first_name` | Optional | String | Lead's first name. Enriched from Prospect Data if not provided and match found. |
| `last_name` | Optional | String | Lead's last name. Enriched from Prospect Data if not provided and match found. |
| `source` | Required | String | One of: `Cold Call`, `Cold Email`, `Cold SMS`, `Direct Mail`, `VAPI`, `Referral`, `Website` |
| `caller_name` | Optional | String | Third-party cold caller name (paired with `source: cold call` — applies `caller: [name]` tag) |

---

## Workflow Steps

### Step 1: Validate Webhook

**Check:** At least one of `reference_id`, `phone`, or `email` is present.

- If none → respond `400` with `{ "error": "At least one identifier required (reference_id, phone, or email)" }` and stop.

**Check:** `source` is present and is a valid value.

- Valid values: `Cold Call`, `Cold Email`, `Cold SMS`, `Direct Mail`, `VAPI`, `Referral`, `Website`
- If missing or invalid → respond `400` with `{ "error": "source is required and must be one of: Cold Call, Cold Email, Cold SMS, Direct Mail, VAPI, Referral, Website" }` and stop.

---

### Step 2: Search Prospect Data (Priority Cascade)

Search the Properties Custom Object in the Prospect Data GHL sub-account. Stop at the first match.

**GHL API:** `POST /custom-objects/{schemaId}/records/search`
**Auth:** Prospect Data Private Integration Token (`GHL — Prospect Data`)

#### 2A: Search by Reference ID

**When:** `reference_id` is present in the webhook payload.

**Query:** Filter where `Reference ID` = `{reference_id}` (exact match).

- **Match found** → record the Property record. Set `matched_by` = `reference_id`. Go to Step 2D.
- **No match** → continue to 2B.

#### 2B: Search by Phone

**When:** `phone` is present in the webhook payload AND Step 2A found no match.

**Query:** Same `query` search as 2A, using the phone number as the search term. This matches against the `All Phones` searchable TEXT field on the Property record (a space-separated concatenation of all 18 phone fields across all owners).

- **Match found** → record the Property record. Determine which owner matched by checking the record's individual phone fields. Set `matched_by` = `phone`. Go to Step 2D.
- **Multiple matches** → use the first result. Set `multi_match` = `true`. Go to Step 2D.
- **No match** → continue to 2C.

> **Dependency:** Phone search requires the `All Phones` field to be populated and marked as a searchable property on the Custom Object. See prospect-data/data-model.md → Search Fields.

#### 2C: Search by Email

**When:** `email` is present in the webhook payload AND Steps 2A + 2B found no match.

**Normalize:** Lowercase the `email` value from the webhook before searching. Prospect Data stores emails in original case from skip trace (often uppercase), so case-insensitive matching requires normalizing the search term.

**Query:** Same `query` search as 2A, using the lowercased email as the search term. This matches against the `All Emails` searchable TEXT field on the Property record (a space-separated concatenation of all 12 email fields across all owners).

- **Match found** → record the Property record. Determine which owner matched by checking the record's individual email fields. Set `matched_by` = `email`. Go to Step 2D.
- **Multiple matches** → use the first result. Set `multi_match` = `true`. Go to Step 2D.
- **No match** → set `property_matched` = `false`. Go to Step 3.

#### 2D: DNC Check (Prospect Data)

**When:** A Property match was found.

**Check:** Is the Property's `DNC` checkbox checked OR `Status` = `DNC`?

- **Yes** → respond `200` with `{ "status": "dnc_blocked", "source": "prospect_data", "reference_id": "{ref}" }` and stop. Do not create anything in New Leads.
- **No** → set `property_matched` = `true`. Continue to Step 3.

---

### Step 3: Determine Primary Owner

**When match found:** Identify which owner's data to use for the Contact.

| Match method | Primary owner |
| --- | --- |
| Reference ID | Owner 1 (default) |
| Phone matched Owner N Phone X | Owner N |
| Email matched Owner N Email X | Owner N |

Record the owner number (1, 2, or 3) as `primary_owner` for field mapping in Steps 4 and 5.

**When no match:** Skip this step. Contact data comes entirely from the webhook.

---

### Step 4: Build Contact Payload

#### 4A: Match Found — Merge Webhook + Prospect Data

Map the primary owner's fields from the Property record to Contact fields. Webhook data takes precedence for confirmed phone/email.

**Normalize emails:** Before mapping, lowercase all email values — both the webhook `email` (confirmed) and all Owner N Email 1–4 values from the Property record (unconfirmed). GHL lowercases emails on contact creation, but normalizing here ensures consistency for email comparisons, dedup, and workflow conditions before the data reaches GHL.

| Source | Contact Field | Value |
| --- | --- | --- |
| Webhook | Phone (native) | `phone` from webhook (confirmed) |
| Webhook | Email (native) | `email` from webhook (confirmed, lowercased) |
| Property | First Name | Owner N First Name (use webhook `first_name` if provided, else Property) |
| Property | Last Name | Owner N Last Name (use webhook `last_name` if provided, else Property) |
| Property | Address | Owner N Mailing Address |
| Property | City | Owner N Mailing City |
| Property | State | Owner N Mailing State |
| Property | Postal Code | Owner N Mailing Zip |
| Property | Age | Owner N Age |
| Property | Deceased | Owner N Deceased |
| Property | Unconfirmed Phones | All non-empty Owner N Phone 1–6 values, one per line |
| Property | Unconfirmed Emails | All non-empty Owner N Email 1–4 values, lowercased, one per line |

**Unconfirmed Phones** — concatenate all non-empty phone fields for the primary owner, one per line:
```
5125551111
5125552222
5125553333
```

**Unconfirmed Emails** — same pattern for email fields. Lowercase each value before concatenating.

#### 4B: No Match — Webhook Data Only

**Normalize emails:** Lowercase the webhook `email` before mapping (same reason as 4A).

| Contact Field | Value |
| --- | --- |
| Phone (native) | `phone` from webhook (if present) |
| Email (native) | `email` from webhook (if present, lowercased) |
| First Name | `first_name` from webhook (if present) |
| Last Name | `last_name` from webhook (if present) |
| Unconfirmed Phones | Empty |
| Unconfirmed Emails | Empty |

---

### Step 5: Build Opportunity Payload

#### 5A: Match Found — Prospect Data Fields

| Property Field (Prospect Data) | Opportunity Field (New Leads) |
| --- | --- |
| Reference ID | Reference ID |
| APN | APN |
| Property County | Property County |
| Property State | Property State |
| Acres | Acres |
| Legal Description | Legal Description |
| Tier 1 Market Price | Tier 1 Market Price |
| Tier 2 Market Price | Tier 2 Market Price |
| Blind Offer | Blind Offer |
| Offer Price | Offer Price |
| Offer Price % | Offer Price % |
| Lat/Long | Lat/Long |
| Map Link | Map Link |

Source fields (set regardless of match):

| Field | Value |
| --- | --- |
| Source (native) | `source` from webhook |
| Latest Source | `source` from webhook |
| Latest Source Date | Today |

#### 5B: No Match — Minimal Opportunity

Only source fields are populated. Property data fields are empty (can be filled manually later).

| Field | Value |
| --- | --- |
| Source (native) | `source` from webhook |
| Latest Source | `source` from webhook |
| Latest Source Date | Today |

---

### Step 6: Check for Existing Contact in New Leads

Search the New Leads GHL sub-account for an existing Contact.

**GHL API:** `POST /contacts/search`
**Auth:** New Leads Private Integration Token (`GHL — New Leads`)

**Search order:**

1. By phone (if `phone` is present in webhook) — GHL Contacts API supports native phone search
2. By email (if `email` is present and phone search returned no match) — GHL Contacts API supports native email search

#### 6A: Contact Found — DNC Check

**Check:** Is the existing Contact tagged `dnc` or `abandoned: dnc` (opportunity status = Abandoned)?

- **Yes** → respond `200` with `{ "status": "dnc_blocked", "source": "new_leads", "contact_id": "{id}" }` and stop.
- **No** → this is a re-submission. Continue to Step 6B.

#### 6B: Re-Submission Path

The contact already exists. Follow the re-submission protocol:

1. **Add source tag:** `source: {source}` (stacks on top of existing source tags)
2. **Add tag:** `re-submitted`
3. **Add tag:** `caller: {caller_name}` (only if `caller_name` is present and `source` = `Cold Call`)
4. **Update Opportunity:**
   - Latest Source = `source` from webhook
   - Latest Source Date = Today
   - Do NOT overwrite native Opportunity Source (first-touch attribution)
5. **Move Opportunity** to pipeline stage `New Leads`
   - This triggers WF-New-Lead-Entry in GHL → cleans up active drips + re-routes

**GHL API calls:**
- `PUT /contacts/{id}` — update Contact fields with any new data from Step 4 (merge, don't overwrite existing confirmed data)
- `POST /contacts/{id}/tags` — add source tag + `re-submitted` + optional `caller:` tag
- `PUT /opportunities/{id}` — update Latest Source + Latest Source Date, move to New Leads stage

Go to Step 8.

#### 6C: New Contact — Create Path

No existing Contact found. Continue to Step 7.

---

### Step 7: Create Contact + Opportunity in New Leads

#### 7A: Create Contact

**GHL API:** `POST /contacts/`
**Auth:** New Leads Private Integration Token (`GHL — New Leads`)

**Payload:** All fields from Step 4 (match or no-match variant), plus:

| Field | Value |
| --- | --- |
| Source | `{source}` (native Contact Source field — first-touch attribution for GHL reporting) |
| Tags | `source: {source}` |
| Tags | `caller: {caller_name}` (only if `caller_name` present and `source` = `Cold Call`) |

Record the returned `contact_id`.

#### 7B: Create Opportunity

**GHL API:** `POST /opportunities/`
**Auth:** New Leads Private Integration Token (`GHL — New Leads`)

**Payload:** All fields from Step 5 (match or no-match variant), plus:

| Field | Value |
| --- | --- |
| Pipeline | 01 : Leads |
| Stage | New Leads |
| Contact | `contact_id` from Step 7A |
| Opportunity Name | `{first_name} {last_name} — {Property County}, {Property State}` (or `{first_name} {last_name}` if no county/state) |

Record the returned `opportunity_id`.

**This stage assignment triggers WF-New-Lead-Entry in GHL**, which handles owner assignment (LM vs AM), Day 0 speed-to-lead SMS, and all downstream workflows.

---

### Step 8: Update Prospect Data (Post-Push)

**When:** A Property match was found in Step 2 (`property_matched` = `true`).

**GHL API:** `PUT /custom-objects/{schemaId}/records/{propertyId}`
**Auth:** Prospect Data Private Integration Token (`GHL — Prospect Data`)

| Field | Value |
| --- | --- |
| Status | Pipeline |
| CRM Pushed | Checked |
| CRM Push Date | Today |
| Push to CRM | Unchecked (clear the trigger field, if it was set) |

**When no match:** Skip this step.

---

### Step 9: Return Response

**Success — new Contact created:**

```json
{
  "status": "created",
  "contact_id": "abc123",
  "opportunity_id": "opp456",
  "property_matched": true,
  "matched_by": "reference_id",
  "reference_id": "TX-TRAVIS-00123",
  "multi_match": false
}
```

**Success — re-submission:**

```json
{
  "status": "re_submitted",
  "contact_id": "abc123",
  "opportunity_id": "opp456",
  "property_matched": true,
  "matched_by": "phone",
  "reference_id": "TX-TRAVIS-00123",
  "multi_match": false
}
```

**Success — no Prospect Data match:**

```json
{
  "status": "created_without_match",
  "contact_id": "abc123",
  "opportunity_id": "opp456",
  "property_matched": false,
  "matched_by": null,
  "reference_id": null,
  "multi_match": false
}
```

**Blocked — DNC:**

```json
{
  "status": "dnc_blocked",
  "source": "prospect_data",
  "reference_id": "TX-TRAVIS-00123"
}
```

**Multi-match flagged (still creates the lead, using first match):**

The `multi_match` field is `true` in the response. The lead is created normally using the first matched Property. The calling system or operator should review manually.

---

## GHL API Reference

### Endpoints Used

| Operation | Method | Endpoint | Account |
| --- | --- | --- | --- |
| Search Properties (Custom Object) | POST | `/custom-objects/{schemaId}/records/search` | Prospect Data |
| Update Property (Custom Object) | PUT | `/custom-objects/{schemaId}/records/{id}` | Prospect Data |
| Search Contact | POST | `/contacts/search` | New Leads |
| Create Contact | POST | `/contacts/` | New Leads |
| Update Contact | PUT | `/contacts/{id}` | New Leads |
| Add Tags | POST | `/contacts/{id}/tags` | New Leads |
| Create Opportunity | POST | `/opportunities/` | New Leads |
| Update Opportunity | PUT | `/opportunities/{id}` | New Leads |

### Authentication

Two Private Integration Tokens required — one per GHL sub-account. Generate at **Settings → Private Integrations** in each sub-account (enable in **Settings → Labs** if not visible). Tokens are static Bearer tokens that don't auto-refresh; rotate manually every 90 days.

| Account | Token Name in GHL | n8n Credential Name |
| --- | --- | --- |
| Prospect Data | `n8n — Prospect Data` | `GHL — Prospect Data` |
| New Leads | `n8n — New Leads` | `GHL — New Leads` |

Store as separate HTTP Header Auth credentials in n8n with `Authorization: Bearer <token>`. Each API call must use the correct credential for the target sub-account.

API base URL: `https://services.leadconnectorhq.com`

Docs: https://marketplace.gohighlevel.com/docs/Authorization/PrivateIntegrationsToken

### Rate Limits

GHL API v2 rate limits vary by plan. Typical: 100 requests/minute per sub-account. At per-lead volume, this workflow stays well within limits. The dedup search uses concatenated `All Phones` and `All Emails` fields — 3 queries max per lead (ref → phone → email).

---

## Error Handling

| Failure Point | Action |
| --- | --- |
| Webhook validation fails | Return 400 with error message. Stop. |
| Prospect Data API call fails | Log error. Continue without enrichment (treat as no match). Set `property_matched` = `false` in response. |
| New Leads Contact search fails | Log error. Assume new lead (create path). Flag in response. |
| New Leads Contact/Opportunity create fails | Return 500 with error details. Do not update Prospect Data. |
| Prospect Data post-push update fails | Log error. Return success for the lead (Contact + Opportunity were created). Flag that post-push update failed in response. |

All errors should be logged to n8n's execution log. Critical failures (Contact/Opportunity creation) should trigger an n8n error notification (email or Slack, depending on setup).

---

## Pre-Launch Checklist

- [ ] Prospect Data Private Integration Token generated and stored in n8n (`GHL — Prospect Data`)
- [ ] New Leads Private Integration Token generated and stored in n8n (`GHL — New Leads`)
- [ ] Properties Custom Object `schemaId` recorded and set in workflow
- [ ] Pipeline ID for "01 : Leads" recorded and set in workflow
- [ ] Stage ID for "New Leads" stage recorded and set in workflow
- [ ] Test: webhook with `reference_id` only → finds Property, creates Contact + Opportunity
- [ ] Test: webhook with `phone` only → cascade search finds Property
- [ ] Test: webhook with `email` only → cascade search finds Property
- [ ] Test: webhook with all three → matches on `reference_id` (priority order)
- [ ] Test: webhook with no match → creates Contact + Opportunity without enrichment
- [ ] Test: re-submission (existing Contact) → updates existing, stacks source tag, adds `re-submitted`
- [ ] Test: DNC Property → returns `dnc_blocked`, no Contact created
- [ ] Test: DNC Contact in New Leads → returns `dnc_blocked`, no update
- [ ] Test: multi-match phone → uses first match, returns `multi_match: true`
- [ ] Verify WF-New-Lead-Entry fires in GHL after Contact lands in New Leads stage
- [ ] Verify owner assignment (LM vs AM) works correctly based on Source tag
- [ ] Verify Day 0 speed-to-lead SMS fires

---

## Future Enhancements

- **Multi-owner Contact creation:** Create Contacts for all owners with valid contact info, not just the primary. Link all to the same Opportunity.
- ~~**Concatenated search field:**~~ ✅ Implemented — `All Phones` and `All Emails` fields exist on Properties custom object and are used in Steps 2B/2C.
- **Batch webhook support:** Accept an array of leads in a single webhook call for cold calling session imports.
- **Manual push trigger:** Listen for `Push to CRM` checkbox change on Property records via GHL webhook → fire this same pipeline.
