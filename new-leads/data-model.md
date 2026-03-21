# Bana Land — New Leads Account: Data Model
*Last edited: 2026-03-21 · Last reviewed: —*

Static configuration for the New Leads GHL sub-account — fields, tags, pipeline stages, smart lists, and lead entry rules. Build everything in this file before creating workflows.

This is the single working account for all lead sources. All leads enter here and are worked through close, disqualification, or long-term drip.

Reference files:

- [workflows.md](workflows.md) — all 11 workflow definitions
- [pipeline.md](pipeline.md) — stage definitions
- [sequences.md](sequences.md) — cadence map
- [messaging.md](messaging.md) — message templates
- [rules.md](rules.md) — compliance rules

---

## Sub-Account Setup

1. Log into GHL and create the New Leads sub-account
2. Set the **business name** to: `Bana Land — New Leads`
3. Set the **time zone** to: `Eastern Time` (default safe zone for compliance)
   - Note: Workflows should use per-contact local time where possible
4. Configure **company phone number** — this will be used for SMS and caller ID
5. Set **reply-to email address** for all outgoing emails

---

## Integrations

| Service        | Purpose                            | GHL Location                              |
| -------------- | ---------------------------------- | ----------------------------------------- |
| SMS Provider   | Outbound/inbound texts             | Settings > Phone Numbers > LC Phone       |
| Email Provider | Outbound emails                    | Settings > Email Services > Mailgun or LC |
| Calendar       | Optional — for appointment setting | Settings > Calendars                      |

---

## Lead Entry & Routing

Leads enter this account through one of three mechanisms. Once inside, WF-New-Lead-Entry routes them to the correct owner and fires the Day 0 speed-to-lead sequence based on source.

---

### Campaign Push (from Prospect Data)

**Who:** All outbound campaign contacts — Cold Email, Cold SMS, Cold Call, Direct Mail.
**How:** Prospect Data automation pushes contacts into this account when a campaign launches.

**What automation must send:**

| Field                            | Value                                                                 |
| -------------------------------- | --------------------------------------------------------------------- |
| First name, last name            | From campaign data / skip trace                                       |
| Email address                    | From campaign data (required for Cold Email; may be absent for others) |
| All phone numbers (Phone 1–4)    | From skip trace data (may be absent for Cold Email responders)        |
| Tag                              | `Source: Cold Email`, `Source: Cold SMS`, `Source: Cold Call`, or `Source: Direct Mail` |
| Custom field: Original Source    | Matching source value (set once, never overwritten)                   |
| Custom field: Latest Source      | Same as Original Source on first entry                                |
| Custom field: Latest Source Date | Today                                                                 |
| Pipeline stage                   | New Leads                                                             |

**Cold Email note:** Cold Email responders may not have a phone number on entry. WF-Cold-Email-Subflow (Cold Email Sub-Flow) runs concurrently to obtain one. See WF-Cold-Email-Subflow below.

---

### Inbound (VAPI AI Call, Referral, Website)

**Who:** Leads who contacted us directly — phone call-ins, referrals, website inquiries.
**How:** Entered via automation flow or manual entry.

**What must be set on entry:**

| Field                            | Value                                                                 |
| -------------------------------- | --------------------------------------------------------------------- |
| Tag                              | `Source: VAPI AI Call`, `Source: Referral`, or `Source: Website`      |
| Custom field: Original Source    | Matching source value (set once, never overwritten)                   |
| Custom field: Latest Source      | Same as Original Source on first entry                                |
| Custom field: Latest Source Date | Today                                                                 |
| Pipeline stage                   | New Leads                                                             |

**VAPI note:** The AI note taker determines the actual marketing source before entry. If the caller responded to a direct mail piece, the lead enters with `Source: Direct Mail` (not `Source: VAPI AI Call`). `Source: VAPI AI Call` is only used when there is no known campaign trigger. No separate channel tracking needed — the source tag reflects the marketing trigger, not the entry channel.

---

### Re-Submission (Contact Already Exists — New Campaign)

**Who:** A contact already in this account (any stage) who responds to a new, separate marketing campaign outside GHL.
**Where they land:** New Leads — full restart as a new lead.

**What automation must do:**

1. Detect the contact already exists in this account (duplicate match)
2. Stack a new Source tag on the existing contact (e.g., `Source: Direct Mail` added on top of existing `Source: Cold Call`)
3. Update custom field: Latest Source = new source value
4. Update custom field: Latest Source Date = Today
5. Add tag: `Re-Submitted`
6. Move Opportunity to New Leads (same property) or create a new Opportunity (new property)

**Rules:**

- Do NOT overwrite Original Source — first-touch attribution is permanent
- WF-New-Lead-Entry fires automatically on the New Leads stage move → cleans up active drips and creates owner task

---

### Routing Summary

After entry, WF-New-Lead-Entry assigns the owner and fires the Day 0 speed-to-lead SMS based on source:

| Source           | Entry Mechanism | Day 1–30 Owner | Day 0 SMS |
| ---------------- | --------------- | -------------- | --------- |
| Cold Email       | Campaign Push   | LM             | CO-SMS-00 |
| Cold SMS         | Campaign Push   | LM             | CO-SMS-00 |
| Cold Call        | Campaign Push   | LM             | CO-SMS-00 |
| Direct Mail      | Campaign Push   | AM             | DM-SMS-00 |
| VAPI AI Call     | Inbound         | AM             | IN-SMS-00 |
| Referral         | Inbound         | AM             | IN-SMS-00 |
| Website          | Inbound         | AM             | IN-SMS-00 |

After Day 0, all sources follow the same cadence (Day 1–10 → Day 11–30 → Cold). The only ongoing difference is owner assignment (LM vs AM).

---

### Opportunity Creation (Applies to All Leads)

When any new contact enters this account, create an **Opportunity** linked to that contact in the pipeline.

- Populate Opportunity custom fields with available property data (Reference ID, Property County, Property State, Acres, APN, etc.)
- The Opportunity is what moves through pipeline stages — the Contact record stays static
- A Contact will only ever have one active Opportunity at a time

---

## Custom Fields

### Data Model: Contacts vs Opportunities

- **Contacts** = people (property owners). One person has one email address and up to four phone numbers. Personal info lives here.
- **Opportunities** = properties/deals. Each property is a separate opportunity inside the pipeline. Property data, pricing, and deal-specific fields live here.

Pipeline stages track **Opportunities**, not Contacts. Each pipeline card IS an opportunity.

---

### Multiple Phone Numbers per Contact

GHL contacts support multiple phone numbers natively:

- **Phone** (primary) — first/best skip-traced number
- **Phone 2** — second skip-traced number (if available)
- **Phone 3** — third skip-traced number (if available)
- **Phone 4** — fourth skip-traced number (if available)

Used in WF-Cold-Email-Subflow's one-time SMS blast for `Cold: Email Only` contacts.

---

### Contact Custom Fields

Go to **Settings > Custom Fields > Contacts** and create the following:

| Field Name        | Type     | Purpose                                                                                                        |
| ----------------- | -------- | -------------------------------------------------------------------------------------------------------------- |
| Lead Entry Date   | Date     | Date lead was first added to the pipeline                                                                      |
| Stage Entry Date  | Date     | Date lead entered their CURRENT stage                                                                          |
| Days in Pipeline  | Number   | Calculated from Lead Entry Date (for reporting)                                                                |
| DNC Date          | Date     | Date lead was added to DNC                                                                                     |
| Last Contact Date | Date     | Date of last successful outreach attempt                                                                       |
| Last Contact Type | Text     | Call / SMS / Email                                                                                             |
| Age               | Number   | Owner's age (from skip trace data)                                                                             |
| Deceased          | Text     | Owner is deceased (from skip trace data). Values: Y / N / blank                                                |
| Assigned To       | Text     | Lead Manager or Acquisition Manager name (set by WF-New-Lead-Entry based on source tag)                                    |
| Pause WFs Until   | Date     | Pause all automated sends until this date. Workflows check: field is empty OR field < today → proceed to send. Set to today+7 by WF-Response-Handler. Owner clears manually to resume early. |

---

### Opportunity Custom Fields

Go to **Settings > Custom Fields > Opportunities** and create the following:

| Field Name          | Type       | Purpose                                                                                                                                                                                          |
| ------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Reference ID        | Text       | Internal reference/tracking ID for the property                                                                                                                                                  |
| Property County     | Text       | County where the property is located                                                                                                                                                             |
| Property State      | Text       | State where the property is located                                                                                                                                                              |
| Acres               | Number     | Property acreage                                                                                                                                                                                 |
| APN                 | Text       | Assessor's Parcel Number                                                                                                                                                                         |
| Tier 1 Market Price | Currency   | Market price estimate — Tier 1 valuation                                                                                                                                                         |
| Tier 2 Market Price | Currency   | Market price estimate — Tier 2 valuation                                                                                                                                                         |
| Blind Offer         | Currency   | Blind offer amount (used in direct mail)                                                                                                                                                         |
| Offer Price %       | Number     | Offer as a percentage of market value                                                                                                                                                            |
| Legal Description   | Large Text | Full legal description of the property                                                                                                                                                           |
| Map Link            | Text       | URL to property map (Google Maps, ParcelFact, etc.)                                                                                                                                              |
| Lat/Long            | Text       | Latitude and longitude as a single comma-separated value (e.g., `35.1234, -97.5678`).                                                                                                           |
| Offer Price         | Text       | Offer amount or percentage for this property (e.g., "$45,000" or "35%" or "$45k / 32%"). Populated from Prospect Data on push.                                                                   |
| Contract Date       | Date       | Date contract was signed for this deal                                                                                                                                                           |
| Original Source     | Dropdown   | First channel that brought this lead into GHL. Set once on first entry, never overwritten. Values: Cold Call, Cold Email, Cold SMS, Direct Mail, VAPI AI Call, Referral, Website |
| Latest Source       | Dropdown   | Most recent channel that brought this lead in. Same dropdown values as Original Source.                                                                                                          |
| Latest Source Date  | Date       | Date the Latest Source field was last updated                                                                                                                                                     |

---

## Tags

**Tag naming convention:** All tags follow `Category: Value` format with title case. Simple high-priority tags (DNC) are kept short.

Go to **Settings > Tags** and create these tags:

| Tag Name                | Use                                                                                                                     |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| DNC                     | Do Not Contact — blocks all outreach. Triggers DNC sync to Prospect Data.                                               |
| Re-Submitted            | Lead came back in from a new external campaign (different source). Resets to New Leads.                                  |
| Cold: Email Only        | Cold Email lead with no confirmed phone number. Email-only drip (WF-Cold-Drip-Monthly/WF-Long-Term-Quarterly skip SMS steps).                     |
| Source: Cold Call        | Lead came from cold calling.                                                                                             |
| Source: Cold Email       | Lead came from cold email campaign.                                                                                      |
| Source: Cold SMS         | Lead came from SMS blast campaign.                                                                                       |
| Source: Direct Mail      | Lead came from direct mail.                                                                                              |
| Source: VAPI AI Call     | Lead called Bana Land number; AI agent answered.                                                                         |
| Source: Referral         | Lead came via referral.                                                                                                  |
| Source: Website          | Lead came via website inquiry.                                                                                           |
| Bounced                  | Email address bounced — do not email until corrected.                                                                   |
| Caller: [Agent Name]     | Name of the third-party cold caller who generated the lead (paired with Source: Cold Call).                             |

---

## Pipeline Setup

Go to **CRM > Pipelines > Add Pipeline** and create: `Bana Land — Seller Pipeline`

Add the following stages **in this exact order:**

**Group: Not Contacted / Not Qualified** *(LM or AM based on source)*

1. New Leads
2. Day 1-10
3. Day 11-30
4. Cold

**Group: Dispo — Terminal** *(no future contact)*

5. Dispo: Not a Fit
6. Dispo: No Longer Own
7. Dispo: Purchased
8. Dispo: DNC

**Group: Dispo — Re-Engage** *(light long-term drip)*

9. Dispo: No Motivation
10. Dispo: Wants Retail
11. Dispo: On MLS
12. Dispo: Lead Declined

**Group: Qualified** *(AM owns all)*

13. Due Diligence
14. Make Offer
15. Negotiations
16. Contract Sent
17. Under Contract
18. Nurture

---

## Smart Lists

Create these Smart Lists under Contacts for daily team use:

| Smart List Name          | Filter Criteria                                          |
| ------------------------ | -------------------------------------------------------- |
| LM — Today's Call Tasks  | Open tasks, type = Call, due today, assigned to LM       |
| AM — Today's Call Tasks  | Open tasks, type = Call, due today, assigned to AM       |
| Cold — No Response 30d   | Stage = Cold, Last Contact Date > 30 days ago            |
| Cold Email — No Phone    | Tag = Source: Cold Email, Phone field is empty            |
| Active Qualified Leads   | Stage is one of: Due Diligence, Make Offer, Negotiations |
| Contracts in Progress    | Stage is one of: Contract Sent, Under Contract           |
| DNC Contacts             | Tag = DNC                                                |
| Stale New Leads          | Stage = New Leads, Stage Entry Date > 24 hours ago       |

**Stale New Leads — daily notification:** Set up a daily internal notification (9 AM) to the assigned owner for any contacts on the Stale New Leads list. Message: "{{count}} lead(s) still in New Leads for 24+ hours — move to Day 1-10 or take action. [Smart List Link]". This catches leads that didn't get moved to Day 1-10 after Day 0 speed-to-lead.
