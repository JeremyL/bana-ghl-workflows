# n8n Pull from Prospect Data Workflow
*Last edited: 2026-04-09 · Last reviewed: —*

n8n workflow that pulls property and owner data from a Prospect Data Property record and merges it onto an existing Contact + Opportunity in New Leads. Gap-fill only — existing NL data is never overwritten.

**Trigger:** GHL workflow WF-Pull-From-PD fires when an operator checks the `Pull from PD` checkbox on an Opportunity card in New Leads.

Reference files:

- [prospect-data/data-model.md](../prospect-data/data-model.md) — Property schema + field mapping
- [new-leads/data-model.md](../new-leads/data-model.md) — Contact/Opportunity fields
- [new-leads/workflows.md](../new-leads/workflows.md) — WF-Pull-From-PD definition
- [n8n/intake-workflow.md](intake-workflow.md) — Shared field mapping sub-workflow reference

---

## Overview

```
Operator checks "Pull from PD"     n8n                              Prospect Data
on Opportunity card
       |
       v
WF-Pull-From-PD fires
(checkbox trigger)
       |
       v
Webhook to n8n ──────────► 1. Validate Reference ID
                               (from payload — must be populated,
                                if empty → error note, stop)
                                    |
                                    v
                             2. Search PD Properties ────────► by Reference ID
                                (no match → error note, stop)
                                    |
                                    v
                             3. DNC Check
                                (if DNC → warning note, stop)
                                    |
                                    v
                             4. Fetch existing Contact ──────► GET /contacts/{contact_id}
                                + Opportunity from NL            GET /opportunities/{opportunity_id}
                                    |
                                    v
                             5. Build merge payloads ─────────► Shared sub-workflow
                                (mode = "enrich")                 Map PD to NL Fields
                                    |
                                    v
                             6. Update Contact ──────────────► PUT /contacts/{contact_id}
                                Update Opportunity ──────────► PUT /opportunities/{opportunity_id}
                                    |
                                    v
                             7. Post PD Snapshot Note ───────► POST /contacts/{contact_id}/notes
                                    |
                                    v
                             8. Update PD Property ──────────► PUT /custom-objects/{schemaId}/records/{id}
                                (Status=Pipeline, CRM Push Date=today — if not already Pipeline)
                                    |
                                    v
                             9. Uncheck trigger ─────────────► PUT /opportunities/{opportunity_id}
                                (Pull from PD = unchecked)
                                    |
                                    v
                            10. Post result note ────────────► POST /contacts/{contact_id}/notes
                                ("PD Pull completed" summary)
```

---

## Trigger

### Webhook Endpoint

**Method:** POST
**Path:** `/pull-from-pd`
**Auth:** Webhook-specific token or header key (configured in n8n)

### Payload (from GHL WF-Pull-From-PD)

```json
{
  "opportunity_id": "opp_abc123",
  "contact_id": "con_xyz789",
  "reference_id": "TX-TRAVIS-00123"
}
```

| Field | Required | Type | Notes |
| --- | --- | --- | --- |
| `opportunity_id` | Yes | String | GHL Opportunity ID |
| `contact_id` | Yes | String | GHL Contact ID linked to the Opportunity |
| `reference_id` | Yes | String | The Opportunity's existing Reference ID. Used to search Prospect Data. |

---

## Workflow Steps

### Step 1: Validate Payload

**Check:** All three fields (`opportunity_id`, `contact_id`, `reference_id`) are present and non-empty.

- If `reference_id` is missing or empty → post error note on Contact timeline: "PD Pull failed — Opportunity has no Reference ID. Populate Reference ID before pulling." → uncheck `Pull from PD` → stop.
- If `opportunity_id` or `contact_id` is missing → log error → stop (no contact to post note to).

---

### Step 2: Search Prospect Data

Search the Properties Custom Object in the Prospect Data GHL sub-account by Reference ID.

**GHL API:** `POST /custom-objects/{schemaId}/records/search`
**Auth:** Prospect Data Private Integration Token (`GHL — Prospect Data`)

**Query:** Filter where `Reference ID` = `{reference_id}` (exact match).

- **Match found** → record the Property record. Continue to Step 3.
- **No match** → post error note on Contact timeline: "PD Pull failed — no Property found for Reference ID: {reference_id}" → uncheck `Pull from PD` → stop.

---

### Step 3: DNC Check

**Check:** Is the Property's `DNC` checkbox checked OR `Status` = `DNC`?

- **Yes** → post warning note on Contact timeline: "PD Pull blocked — Property {reference_id} is DNC in Prospect Data." → uncheck `Pull from PD` → stop.
- **No** → continue to Step 4.

---

### Step 4: Fetch Existing Contact + Opportunity

Read the current Contact and Opportunity data from New Leads. This is needed for the merge logic — we need to know which fields are already populated.

**GHL API:**
- `GET /contacts/{contact_id}` — returns all contact fields including custom fields
- `GET /opportunities/{opportunity_id}` — returns all opportunity fields including custom fields

**Auth:** New Leads Private Integration Token (`GHL — New Leads`)

Record both full records for Step 5.

---

### Step 5: Build Merge Payloads

Call the shared **Map PD to NL Fields** sub-workflow (same sub-workflow used by the intake workflow) with:

- `property_data` = the Property record from Step 2
- `matched_owner` = `1` (default to Owner 1 — same as Reference ID search in intake)
- `mode` = `"enrich"`
- `existing_contact` = the Contact record from Step 4
- `existing_opportunity` = the Opportunity record from Step 4

The sub-workflow returns:
- `contact_payload` — only fields that are currently empty on the existing Contact
- `opportunity_payload` — only fields that are currently empty on the existing Opportunity
- `prospect_note` — PD Snapshot Note text (same format as intake workflow)

#### Merge Rules

**Principle: NL data is authoritative. PD only fills gaps.** If a field already has a value in New Leads, it stays. The pull only populates empty fields.

**Contact fields:**

| Field | Rule |
| --- | --- |
| Phone (native) | PRESERVE if populated |
| Email (native) | PRESERVE if populated |
| Phone 2-4 (native) | PRESERVE if populated |
| First Name / Last Name | PRESERVE if populated |
| Address / City / State / Postal Code | PRESERVE if populated |
| Age | PRESERVE if populated |
| Deceased | PRESERVE if populated |
| Unconfirmed Phones | PRESERVE if populated |
| Unconfirmed Emails | PRESERVE if populated |

**Opportunity fields:**

| Field | Rule |
| --- | --- |
| Reference ID | PRESERVE (already set) |
| APN | PRESERVE if populated |
| Property County | PRESERVE if populated |
| Property State | PRESERVE if populated |
| Acres | PRESERVE if populated |
| Legal Description | PRESERVE if populated |
| Tier 1 / Tier 2 Market Price | PRESERVE if populated |
| Blind Offer / Offer Price / Offer Price % | PRESERVE if populated |
| Lat/Long | PRESERVE if populated |
| Map Link | PRESERVE if populated |
| Source (native) | PRESERVE |
| Latest Source / Latest Source Date | PRESERVE |
| Contract Date | PRESERVE |
| Opportunity Name | PRESERVE if populated |

**Key distinction from intake:** This is a data enrichment action, not a lead event. No source fields are touched. No tags are added. No pipeline stage changes.

---

### Step 6: Update Contact + Opportunity

**When:** The merge payloads from Step 5 contain at least one field to update.

**GHL API:**
- `PUT /contacts/{contact_id}` with `contact_payload` from Step 5
- `PUT /opportunities/{opportunity_id}` with `opportunity_payload` from Step 5

**Auth:** New Leads Private Integration Token (`GHL — New Leads`)

If both payloads are empty (all fields already populated), skip the API calls but still post the notes (Steps 7 and 10) — the PD Snapshot Note is useful as a reference even when no fields changed.

---

### Step 7: Post PD Snapshot Note

Post the Prospect Data Snapshot Note to the Contact timeline. Same format as the intake workflow — a snapshot of all raw property and owner data from Prospect Data.

**GHL API:** `POST /contacts/{contact_id}/notes`
**Auth:** New Leads Private Integration Token (`GHL — New Leads`)

**Note format:**

```
=== PROSPECT DATA SNAPSHOT ===
Pulled: {today}
Reference ID: {reference_id}

--- PROPERTY ---
APN: {apn}
County: {county}
State: {state}
Acres: {acres}
Legal: {legal_description}
Tier 1 Market Price: {tier_1}
Tier 2 Market Price: {tier_2}
Blind Offer: {blind_offer}
Offer Price: {offer_price}
Offer Price %: {offer_pct}
Lat/Long: {lat_long}
Map Link: {map_link}

--- OWNER 1 ---
Name: {first_name} {last_name}
Age: {age}
Deceased: {deceased}
Address: {mailing_address}, {city}, {state} {zip}

--- ALL PHONES (OWNER 1) ---
{phone_1} ({type_1})
{phone_2} ({type_2})
...

--- ALL EMAILS (OWNER 1) ---
{email_1}
{email_2}
...
```

Empty fields are omitted from the note. If multiple owners exist, include Owner 2 and Owner 3 sections.

---

### Step 8: Update Prospect Data Property

**When:** The Property's `Status` is not already `Pipeline`.

**GHL API:** `PUT /custom-objects/{schemaId}/records/{propertyId}?locationId={pdLocationId}`
**Auth:** Prospect Data Private Integration Token (`GHL — Prospect Data`)
**Body key:** `properties` (not `fields`)

| Field | Value |
| --- | --- |
| Status | `pipeline` |
| CRM Push Date | Today (`YYYY-MM-DD`) |

If Status is already `Pipeline`, update only `CRM Push Date` (reflects the most recent data pull).

> **Note:** `Push to CRM` checkbox on the PD side cannot be written via API (same limitation as intake workflow — GHL Custom Objects API does not support checkbox writes).

---

### Step 9: Uncheck Trigger Field

Clear the `Pull from PD` checkbox on the Opportunity so the trigger resets for future use.

**GHL API:** `PUT /opportunities/{opportunity_id}`
**Auth:** New Leads Private Integration Token (`GHL — New Leads`)

| Field | Value |
| --- | --- |
| Pull from PD | `false` (unchecked) |

> **Note:** Unlike the Push to CRM checkbox on PD Custom Objects, the Pull from PD checkbox is on a GHL Opportunity (native object). Opportunity custom field updates via API are supported — checkbox values accept `true`/`false`.

---

### Step 10: Post Result Note

Post a summary note to the Contact timeline confirming the pull completed.

**GHL API:** `POST /contacts/{contact_id}/notes`
**Auth:** New Leads Private Integration Token (`GHL — New Leads`)

**Note format:**

```
=== PD PULL COMPLETED ===
Date: {today}
Reference ID: {reference_id}
Property: {county}, {state} — {acres} acres
Fields Updated: {count}
```

`Fields Updated` is the count of fields that were actually populated by this pull (empty before, filled now). If 0, the note reads "Fields Updated: 0 (all fields already populated)".

---

## Shared Sub-Workflow: Map PD to NL Fields

This sub-workflow is shared between the intake workflow and the pull workflow. It contains the full field mapping logic and the Custom Field ID Map (`CF` object).

**Location:** Separate n8n sub-workflow, called via the "Execute Sub-Workflow" node.

### Inputs

| Parameter | Type | Description |
| --- | --- | --- |
| `property_data` | Object | Full Property record from Prospect Data |
| `matched_owner` | Number | Owner number to use (1, 2, or 3) |
| `mode` | String | `"create"` (full payload) or `"enrich"` (gap-fill only) |
| `existing_contact` | Object | Current Contact record from New Leads (required for "enrich" mode) |
| `existing_opportunity` | Object | Current Opportunity record from New Leads (required for "enrich" mode) |

### Outputs

| Parameter | Type | Description |
| --- | --- | --- |
| `contact_payload` | Object | Contact fields to create or update |
| `opportunity_payload` | Object | Opportunity fields to create or update |
| `prospect_note` | String | PD Snapshot Note text |

### Mode Behavior

**"create" mode** (used by intake workflow):
- Builds full Contact and Opportunity payloads with all available fields from the Property record
- No merge logic — all fields are populated
- Current Build Payloads behavior, unchanged

**"enrich" mode** (used by pull workflow):
- Compares each PD field against the corresponding existing NL field
- Only includes a field in the payload if the existing NL field is empty/null/blank
- Source fields (native Source, Latest Source, Latest Source Date) are never included in enrich mode
- Reference ID is never included (already set — it's how we found the PD record)

### Custom Field ID Map

The `CF` object maps human-readable field names to GHL custom field IDs. This is defined once in the sub-workflow and used by both modes. When a new custom field is added to either Contact or Opportunity, update this map in one place.

---

## GHL API Reference

### Endpoints Used

| Operation | Method | Endpoint | Account |
| --- | --- | --- | --- |
| Search Properties (Custom Object) | POST | `/custom-objects/{schemaId}/records/search` | Prospect Data |
| Update Property (Custom Object) | PUT | `/custom-objects/{schemaId}/records/{id}` | Prospect Data |
| Get Contact | GET | `/contacts/{id}` | New Leads |
| Get Opportunity | GET | `/opportunities/{id}` | New Leads |
| Update Contact | PUT | `/contacts/{id}` | New Leads |
| Update Opportunity | PUT | `/opportunities/{id}` | New Leads |
| Create Contact Note (x2) | POST | `/contacts/{id}/notes` | New Leads |

### Authentication

Same two Private Integration Tokens as the intake workflow:

| Account | Token Name in GHL | n8n Credential Name |
| --- | --- | --- |
| Prospect Data | `n8n — Prospect Data` | `GHL — Prospect Data` |
| New Leads | `n8n — New Leads` | `GHL — New Leads` |

API base URL: `https://services.leadconnectorhq.com`

---

## Error Handling

| Failure Point | Action |
| --- | --- |
| Missing `reference_id` in payload | Post error note on Contact timeline. Uncheck `Pull from PD`. Stop. |
| No Property match in Prospect Data | Post error note on Contact timeline. Uncheck `Pull from PD`. Stop. |
| Property is DNC | Post warning note on Contact timeline. Uncheck `Pull from PD`. Stop. |
| Contact/Opportunity GET fails | Log error. Post error note if possible. Uncheck `Pull from PD`. Stop. |
| Contact/Opportunity UPDATE fails | Log error. Post error note. Uncheck `Pull from PD`. Stop. |
| PD Property update fails | Log warning. Continue — the NL side was already updated successfully. |
| Note creation fails | Log warning. Continue — notes are best-effort. |

All errors are logged to n8n's execution log. Critical failures should trigger an n8n error notification.

---

## Pre-Launch Checklist

- [ ] `Pull from PD` checkbox custom field created on Opportunities in New Leads
- [ ] WF-Pull-From-PD workflow created in GHL (trigger: checkbox checked → webhook POST)
- [ ] n8n workflow created and connected to webhook endpoint
- [ ] Shared sub-workflow `Map PD to NL Fields` extracted and working
- [ ] Intake workflow refactored to use shared sub-workflow (no behavior change)
- [ ] Test: check Pull from PD on Opportunity with Reference ID → PD data merges onto Contact + Opportunity
- [ ] Test: verify existing populated fields are NOT overwritten
- [ ] Test: verify empty fields ARE populated from PD
- [ ] Test: Source fields (native + Latest) are not touched
- [ ] Test: PD Snapshot Note appears on Contact timeline
- [ ] Test: Result summary note appears on Contact timeline with correct field count
- [ ] Test: Pull from PD checkbox is unchecked after execution
- [ ] Test: PD Property record updated (Status = Pipeline, CRM Push Date = today)
- [ ] Test: Opportunity with no Reference ID → error note posted, checkbox unchecked
- [ ] Test: Reference ID with no PD match → error note posted, checkbox unchecked
- [ ] Test: DNC Property → warning note posted, checkbox unchecked
- [ ] Verify intake workflow still functions correctly after sub-workflow extraction
