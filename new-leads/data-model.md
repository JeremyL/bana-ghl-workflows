# Bana Land — New Leads Account: Data Model

*Last edited: 2026-04-07 · Last reviewed: 2026-04-07*

Static configuration for the New Leads GHL sub-account — fields, tags, pipeline stages, smart lists, and lead entry rules. Build everything in this file before creating workflows.

This is the single working account for all lead sources. All leads enter here and are worked through close, disqualification, or long-term drip.

Reference files:

- [workflows.md](workflows.md) — all 10 workflow definitions
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

### Push from Prospect Data

**Who:** All outbound campaign contacts — Cold SMS, Cold Call, Direct Mail.
**How:** Prospect Data automation pushes contacts into this account when a lead comes in that is associated with a property record.

**What automation must send:**


| Field                            | Value                                                                                   |
| -------------------------------- | --------------------------------------------------------------------------------------- |
| First name, last name            | From campaign data / skip trace                                                         |
| Email address                    | From campaign data (may be absent for some sources)                                     |
| All phone numbers (Phone 1–4)    | From skip trace data                                                                    |
| Tag                              | `source: cold sms`, `source: cold call`, or `source: direct mail`                       |
| Native Source (Opportunity)      | Matching source value (set once, never overwritten — first-touch attribution)            |
| Custom field: Latest Source      | Same as native Source on first entry                                                    |
| Custom field: Latest Source Date | Today                                                                                   |
| Pipeline stage                   | New Leads                                                                               |


---

### Inbound (VAPI, Referral, Website)

**Who:** Leads who contacted us directly — phone call-ins, referrals, website inquiries.
**How:** Entered via GHL form/webhook (Website), VAPI call completion webhook, or manual entry (Referral).

**Automation requirements:** The entry automation (GHL workflow or Zapier/Make) must create a Contact + Opportunity in New Leads with the fields below. If the contact already exists, treat as a Re-Submission (see below).

**What must be set on entry:**


| Field                            | Value                                                            |
| -------------------------------- | ---------------------------------------------------------------- |
| Tag                              | `source: vapi`, `source: referral`, or `source: website` |
| Native Source (Opportunity)      | Matching source value (set once, never overwritten — first-touch attribution) |
| Custom field: Latest Source      | Same as native Source on first entry                                         |
| Custom field: Latest Source Date | Today                                                                        |
| Pipeline stage                   | New Leads                                                        |


**VAPI note:** The AI note taker determines the actual marketing source before entry. If the caller responded to a direct mail piece, the lead enters with `source: direct mail` (not `source: vapi`). `source: vapi` is only used when there is no known campaign trigger. No separate channel tracking needed — the source tag reflects the marketing trigger, not the entry channel.

---

### Re-Submission (Contact Already Exists — New Campaign)

**Who:** A contact already in this account (any stage) who responds to a new, separate marketing campaign outside GHL.
**Where they land:** New Leads — full restart as a new lead.

**What automation must do:**

1. Detect the contact already exists in this account (duplicate match)
2. Stack a new source tag on the existing contact (e.g., `source: direct mail` added on top of existing `source: cold call`)
3. Update custom field: Latest Source = new source value
4. Update custom field: Latest Source Date = Today
5. Add tag: `re-submitted`
6. Move Opportunity to New Leads (same property) or create a new Opportunity (new property)

**Rules:**

- Do NOT overwrite native Opportunity Source — first-touch attribution is permanent
- WF-New-Lead-Entry fires automatically on the New Leads stage move → cleans up active drips and creates owner task

---

### Routing Summary

After entry, WF-New-Lead-Entry assigns the owner (if unassigned) and fires the Day 0 speed-to-lead SMS based on source. AM-sourced leads are round-robin assigned between 2 AMs. Re-submitted leads keep their existing owner.


| Source       | Entry Mechanism | Day 1–30 Owner | Day 0 SMS |
| ------------ | --------------- | -------------- | --------- |
| Cold SMS     | Campaign Push   | LM             | CO-SMS-00 |
| Cold Call    | Campaign Push   | LM             | CO-SMS-00 |
| Direct Mail  | Campaign Push   | AM (round-robin) | DM-SMS-00 |
| VAPI | Inbound         | AM (round-robin) | IN-SMS-00 |
| Referral     | Inbound         | AM (round-robin) | IN-SMS-00 |
| Website      | Inbound         | AM (round-robin) | IN-SMS-00 |


After Day 0, all sources follow the same cadence (Day 1–10 → Day 11–30 → LT FU: Cold). The only ongoing difference is the assigned owner (LM vs one of two AMs). All task assignments throughout workflows use If/Else branching on the Contact Owner field to route to the correct person.

---

### Opportunity Creation (Applies to All Leads)

When any new contact enters this account, create an **Opportunity** linked to that contact in the pipeline.

- Populate Opportunity custom fields with available property data (Reference ID, Property County, Property State, Acres, APN, etc.)
- The Opportunity is what moves through pipeline stages — the Contact record stays static
- A Contact will only ever have one active Opportunity at a time

---

## Custom Fields

### Data Model: Contacts vs Opportunities

- **Contacts** = people (property owners). Confirmed phone/email in native fields. Unconfirmed skip trace data in two Large Text fields. Personal info lives here.
- **Opportunities** = properties/deals. Each property is a separate opportunity inside the pipeline. Property data, pricing, and deal-specific fields live here.

Pipeline stages track **Opportunities**, not Contacts. Each pipeline card IS an opportunity.

---

### Confirmed vs. Unconfirmed Contact Data

**Confirmed** = the phone number or email the lead actually used (called from, texted from, replied from, answered on). Goes in GHL's native fields:

- **Phone** (native) — confirmed phone number
- **Phone 2–4** (native) — additional confirmed numbers (verified during follow-up conversations)
- **Email** (native) — confirmed email address

**Unconfirmed** = skip trace data pulled from Prospect Data when the lead enters New Leads. Stored in two Large Text custom fields (one per line):

- **Unconfirmed Phones** — all skip trace phone numbers
- **Unconfirmed Emails** — all skip trace email addresses

If the confirmed phone/email matches one from skip trace, it still goes in the native field. The unconfirmed fields hold everything from skip trace for reference — if a primary bounces or goes dead, the team can manually try an alternate.

---

### Contact Custom Fields

Go to **Settings > Custom Fields > Contacts** and create the following:


| Field Name         | Type       | Purpose                                                                                                                                                                                      |
| ------------------ | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Age                | Number     | Owner's age (from skip trace data)                                                                                                                                                           |
| Deceased           | Text       | Owner is deceased (from skip trace data). Values: Y / N / blank                                                                                                                              |
| Pause WFs Until    | Date       | Pause all automated sends until this date. Workflows check: field is empty OR field ≤ today → proceed to send. Set to today+3 by WF-Response-Handler. Owner clears manually to resume early. |
| Unconfirmed Phones | Large Text | All skip trace phone numbers (one per line). Not verified — for reference and manual use.                                                                                                    |
| Unconfirmed Emails | Large Text | All skip trace email addresses (one per line). Not verified — for reference and manual use.                                                                                                  |

> **Lead assignment** uses GHL's native Assigned User (Contact Owner) field — not a custom field. WF-New-Lead-Entry sets it via the "Assign To User" workflow action with "Only Apply to Unassigned Contacts" enabled. LM-sourced leads assign to the single Lead Manager. AM-sourced leads round-robin between 2 Acquisition Managers (Jeremy + [AM2], Split Traffic: Equally). Re-submitted leads keep their existing owner. The native field appears on contact cards, supports If/Else workflow conditions, Smart List filters, and provides merge fields (`{{user.name}}`, `{{user.first_name}}`, etc.). Contact and Opportunity owners are coupled by default (changing one changes the other). All task assignments in workflows use If/Else branching on Contact Owner to route to the correct person (GHL's Create Task action does not support dynamic "assign to contact owner" natively).

> **Stage date tracking** uses GHL's native `lastStageChangeAt` field on Opportunities — not a custom field. GHL updates this automatically whenever an opportunity moves to a new pipeline stage. No workflow step needed. Used by the Stale New Leads Smart List to detect leads sitting in New Leads > 24 hours. **Edge case:** `lastStageChangeAt` does not update when an opportunity is re-submitted to the same stage it's already in (see for-review.md re-sub test item).

> **DNC enforcement** uses GHL's native DND (Do Not Disturb) in addition to the `dnc` tag. WF-DNC-Handler sets DND for ALL channels (SMS, Call, Email) via the "Set Contact DND" workflow action — this is the platform-level hard block that prevents sends regardless of workflow configuration. The `dnc` tag is kept as the workflow-visible marker for enrollment gates and n8n intake DNC checks.

> **Lead entry tracking** uses GHL's native `dateAdded` field on Contacts — not a custom field. GHL sets this automatically when the contact is created. In this system, contacts are only created on pipeline entry, so `dateAdded` = first entry date. On re-submissions the contact already exists and `dateAdded` does not change — preserving first-touch timing.

> **Source attribution** uses GHL's native Source field on both Contacts and Opportunities for first-touch attribution — not a custom field. WF-New-Lead-Entry sets both once on first entry (skip if already set). Not updated on re-submission — the Latest Source custom field on the Opportunity tracks that. This keeps GHL's built-in reporting populated without a custom field for original source.


---

### Opportunity Custom Fields

Go to **Settings > Custom Fields > Opportunities** and create the following:


| Field Name          | Type       | Purpose                                                                                                                                                                          |
| ------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Reference ID        | Text       | Internal reference/tracking ID for the property                                                                                                                                  |
| Property County     | Text       | County where the property is located                                                                                                                                             |
| Property State      | Text       | State where the property is located                                                                                                                                              |
| Acres               | Number     | Property acreage                                                                                                                                                                 |
| APN                 | Text       | Assessor's Parcel Number                                                                                                                                                         |
| Tier 1 Market Price | Currency   | Market price estimate — Tier 1 valuation                                                                                                                                         |
| Tier 2 Market Price | Currency   | Market price estimate — Tier 2 valuation                                                                                                                                         |
| Blind Offer         | Currency   | Blind offer amount (used in direct mail)                                                                                                                                         |
| Offer Price %       | Text       | Offer as a percentage of market value                                                                                                                                            |
| Legal Description   | Large Text | Full legal description of the property                                                                                                                                           |
| Map Link            | Text       | URL to property map (Google Maps, ParcelFact, etc.)                                                                                                                              |
| Lat/Long            | Text       | Latitude and longitude as a single comma-separated value (e.g., `35.1234, -97.5678`).                                                                                            |
| Offer Price         | Text       | Offer amount or percentage for this property (e.g., "$45,000" or "35%" or "$45k / 32%"). Populated from Prospect Data on push.                                                   |
| Contract Date       | Date       | Date contract was signed for this deal                                                                                                                                           |
| Latest Source       | Text       | Most recent channel that brought this lead in. Updated on re-submission. Values: Cold Call, Cold SMS, Direct Mail, VAPI, Referral, Website.                                      |
| Latest Source Date  | Date       | Date the Latest Source field was last updated                                                                                                                                    |


---

## Tags

**Tag naming convention:** All tags are stored lowercase by GHL. Use `category: value` format. Simple high-priority tags (`dnc`) are kept short.

Go to **Settings > Tags** and create these tags:


| Tag Name               | Use                                                                                                                           |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| dnc                    | Do Not Contact — blocks all outreach. Triggers DNC sync to Prospect Data.                                                     |
| re-submitted           | Lead came back in from a new external campaign (different source). Resets to New Leads.                                       |
| source: cold call      | Lead came from cold calling.                                                                                                  |
| source: cold sms       | Lead came from SMS blast campaign.                                                                                            |
| source: direct mail    | Lead came from direct mail.                                                                                                   |
| source: vapi   | Lead called Bana Land number; AI agent answered.                                                                              |
| source: referral       | Lead came via referral.                                                                                                       |
| source: website        | Lead came via website inquiry.                                                                                                |
| abandoned: dnc         | Abandoned status — lead opted out. Permanent, blocks re-entry.                                                                |
| abandoned: not a fit   | Abandoned status — property/owner doesn't meet Bana Land's criteria.                                                          |
| abandoned: no longer own | Abandoned status — lead already sold the property.                                                                           |
| abandoned: exhausted   | Abandoned status — completed 24-month drip cycle with no conversion.                                                          |
| bounced                | Email address bounced — do not email until corrected.                                                                         |
| caller: [agent name]   | Name of the third-party cold caller who generated the lead (paired with `source: cold call`).                                 |


---

## Pipeline Setup

Go to **CRM > Pipelines** and create the following 5 pipelines with stages in exact order:

### 01 : Acquisition *(LM or AM based on source)*

1. New Leads
2. Day 1-10
3. Day 11-30
4. Comp
5. Make Offer
6. Negotiations
7. Contract Sent
8. Contract Signed
9. Nurture *(trigger stage — auto-moves to LT FU: Nurture)*

### 02 : Due Diligence *(manual, TBD stages)*

Post-contract, pre-close. Stages TBD.

### 03 : Value Add *(manual, TBD stages)*

Pre-close, complex deals with property improvements. Stages TBD.

### 04 : Long Term FU *(automated drip)*

1. Cold
2. Nurture
3. Lost

### 05 : Disposition *(manual, TBD stages)*

Post-acquisition sales — selling properties Bana Land has already purchased. Stages TBD.

All stages use **Open** status. Deal outcomes use native GHL statuses — no dispo stages in the pipeline. See [pipeline.md](pipeline.md) for full stage definitions and cross-pipeline movement rules.

---

## Opportunity Statuses & Lost Reasons

GHL has four fixed statuses: **Open, Won, Lost, Abandoned.** These replace our former dispo stages. See [pipeline.md](pipeline.md) for full definitions and re-entry paths.

**Status → Won:** Deal closed and funded (replaces former "Dispo: Purchased" stage).

**Status → Lost** — configure these custom lost reasons under **Settings > Custom Fields > Lost Reason:**

| Lost Reason      | Former Stage          |
| ---------------- | --------------------- |
| No Motivation    | Dispo: No Motivation  |
| Wants Retail     | Dispo: Wants Retail   |
| On MLS           | Dispo: On MLS         |
| Lead Declined    | Dispo: Lead Declined  |

Lost triggers WF-Dispo-Re-Engage → 24-month long-term drip. After drip completes → Abandoned + `abandoned: exhausted`.

**Status → Abandoned** — reason tracked via `abandoned:` tags (see Tags section above). No further outreach.

| Tag                        | Former Stage           |
| -------------------------- | ---------------------- |
| `abandoned: dnc`           | Dispo: DNC             |
| `abandoned: not a fit`     | Dispo: Not a Fit       |
| `abandoned: no longer own` | Dispo: No Longer Own   |
| `abandoned: exhausted`     | Exhausted              |

---

## Smart Lists

Create these Smart Lists under Contacts for daily team use:


| Smart List Name         | Filter Criteria                                          |
| ----------------------- | -------------------------------------------------------- |
| LM — Today's Tasks     | Open tasks, due today, assigned to LM (manually created tasks only — no automated call tasks) |
| AM — Today's Tasks     | Open tasks, due today, assigned to AM (manually created tasks + WF-Response-Handler review tasks) |
| Cold — No Response 30d  | Pipeline = LT FU, Stage = Cold, GHL native "Last Activity" > 30 days ago |
| Active Qualified Leads  | Pipeline = Acquisition, Stage is one of: Comp, Make Offer, Negotiations |
| Contracts in Progress   | Pipeline = Acquisition, Stage is one of: Contract Sent, Contract Signed |
| DNC Contacts            | Status = Abandoned, Tag = `abandoned: dnc`               |
| Stale New Leads         | Stage = New Leads, native `lastStageChangeAt` > 24 hours ago |


**Stale New Leads — daily notification:** Set up a daily internal notification (9 AM) to the assigned owner for any contacts on the Stale New Leads list. Message: "{{count}} lead(s) still in New Leads for 24+ hours — move to Day 1-10 or take action. [Smart List Link]". This catches leads that didn't get moved to Day 1-10 after Day 0 speed-to-lead.