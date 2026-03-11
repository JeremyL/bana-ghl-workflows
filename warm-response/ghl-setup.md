# Bana Land — Warm Response Account: GHL Setup Guide

This guide walks through building the Warm Response GHL sub-account from scratch.
Follow the steps in order — each section depends on the previous one being complete.

This account handles cold email and cold SMS responders through either successful
transfer to New Leads or long-term Cold drip.

Reference files:

- [pipeline.md](pipeline.md) — stage definitions
- [sequences.md](sequences.md) — cadence map
- [messaging.md](messaging.md) — message templates
- [rules.md](rules.md) — compliance rules
- For New Leads: [../new-leads/ghl-setup.md](../new-leads/ghl-setup.md)

---

## Step 1 — Sub-Account Setup

1. Log into GHL and create the Warm Response sub-account
2. Set the **business name** to: `Bana Land — Warm Response`
3. Set the **time zone** to: `Eastern Time` (default safe zone for compliance)
   - Note: Workflows should use per-contact local time where possible
4. Configure **company phone number** — this will be used for SMS and caller ID
5. Set **reply-to email address** for all outgoing emails

---

## Step 2 — Integrations to Connect

| Service        | Purpose                | GHL Location                              |
| -------------- | ---------------------- | ----------------------------------------- |
| SMS Provider   | Outbound/inbound texts | Settings > Phone Numbers > LC Phone       |
| Email Provider | Outbound emails        | Settings > Email Services > Mailgun or LC |

---

## Step 2B — Lead Entry Integration (automation / Webhook)

### Entry Path — Warm Response (Cold Email & Cold SMS Responders)

**Who:** Prospects who replied "yes" to an outbound cold email or cold SMS campaign managed outside GHL.
**Where they land:** Warm Response pipeline stage (Lead Manager owns from here).
**How:** automation detects the positive reply and pushes the contact into this account automatically.

**Flow:**

1. Prospect replies "yes" to cold email or cold SMS (managed outside GHL)
2. automation detects the reply and pushes the contact into Warm Response via API/webhook
3. automation sets the source tag and places the contact in the Warm Response stage
4. GHL triggers WF-00A (email track) or WF-00B (SMS track) based on the tag

**What automation must send to GHL:**

| Field                            | Value                                                            |
| -------------------------------- | ---------------------------------------------------------------- |
| First name, last name            | From campaign data                                               |
| Email address                    | Required for email responders; may be absent for SMS             |
| Phone number                     | Required for SMS responders; may be absent for email responders  |
| Tag                              | `Warm: Email` (email responders) or `Warm: SMS` (SMS responders) |
| Tag                              | `Source: Cold Email` or `Source: Cold SMS`                       |
| Custom field: Original Source    | Matching source value (set once, never overwritten)              |
| Custom field: Latest Source      | Same as Original Source on first entry                           |
| Custom field: Latest Source Date | Today                                                            |
| Pipeline stage                   | Warm Response                                                    |

### Opportunity Creation

When any new contact enters this account, create an **Opportunity** linked to that contact in the pipeline.

- Populate Opportunity custom fields with available property data (Reference ID, Property County, Property State, Acres, APN, etc.)
- The Opportunity is what moves through pipeline stages — the Contact record stays static

---

## Step 3 — Custom Fields

### Data Model: Contacts vs Opportunities

- **Contacts** = people (property owners). One person has one email address and up to four phone numbers. Personal info lives here.
- **Opportunities** = properties/deals. Each property is a separate opportunity inside the pipeline. Property data, pricing, and deal-specific fields live here.

Pipeline stages track **Opportunities**, not Contacts.

---

### Multiple Phone Numbers per Contact

GHL contacts support multiple phone numbers. Skip-trace data can return up to 4 phone numbers per person:

- **Phone** (primary) — first/best skip-traced number
- **Phone 2** — second skip-traced number (if available)
- **Phone 3** — third skip-traced number (if available)
- **Phone 4** — fourth skip-traced number (if available)

Used in WF-00A's one-time SMS blast for `Cold: Email Only` contacts.

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
| Deceased          | Checkbox | Owner is deceased (from skip trace data)                                                                       |
| Assigned To       | Text     | Lead Manager name                                                                                              |
| Pause WFs Until   | Date     | Pause all automated sends until this date. Workflows check: field is empty OR field < today → proceed to send. Set to today+7 by WF-11. LM clears manually to resume early. |

---

### Opportunity Custom Fields

Go to **Settings > Custom Fields > Opportunities** and create the following:

| Field Name          | Type       | Purpose                                                                                                                                                                                          |
| ------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Reference ID        | Text       | Internal reference/tracking ID for the property                                                                                                                                                  |
| Property County     | Text       | County where the property is located                                                                                                                                                             |
| Property State      | Dropdown   | State where the property is located (all US states)                                                                                                                                              |
| Acres               | Number     | Property acreage                                                                                                                                                                                 |
| APN                 | Text       | Assessor's Parcel Number                                                                                                                                                                         |
| Tier 1 Market Price | Currency   | Market price estimate — Tier 1 valuation                                                                                                                                                         |
| Tier 2 Market Price | Currency   | Market price estimate — Tier 2 valuation                                                                                                                                                         |
| Blind Offer         | Currency   | Blind offer amount (used in direct mail)                                                                                                                                                         |
| Offer Price %       | Number     | Offer as a percentage of market value                                                                                                                                                            |
| Legal Description   | Large Text | Full legal description of the property                                                                                                                                                           |
| Map Link            | Text       | URL to property map (Google Maps, ParcelFact, etc.)                                                                                                                                              |
| Latitude            | Number     | Property GPS latitude                                                                                                                                                                            |
| Longitude           | Number     | Property GPS longitude                                                                                                                                                                           |
| Offer Price         | Text       | Offer amount or percentage for this property (e.g., "$45,000" or "35%" or "$45k / 32%"). Populated from Prospect Data on push.                                                                   |
| Contract Date       | Date       | Date contract was signed for this deal                                                                                                                                                           |
| Original Source     | Dropdown   | First channel that brought this lead into GHL. Set once on first entry, never overwritten. Values: Cold Call, Cold Email, Cold SMS, Direct Mail, VAPI AI Call, Launch Control, Referral, Website |
| Latest Source       | Dropdown   | Most recent channel that brought this lead in. Same dropdown values as Original Source. On first entry, set to same value as Original Source.                                                    |
| Latest Source Date  | Date       | Date the Latest Source field was last updated                                                                                                                                                     |

---

## Step 4 — Tags to Create

**Tag naming convention:** All tags follow `Category: Value` format with title case. Simple high-priority tags (DNC, Hot) are kept short.

Go to **Settings > Tags** and create these tags:

| Tag Name             | Use                                                                                                                     |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| DNC                  | Do Not Contact — blocks all outreach. Triggers DNC sync to New Leads.                                                  |
| Hot                  | Team-assigned tag for priority leads (manual)                                                                            |
| Re-Engaged           | Lead responded to our Cold drip. Triggers WF-11.                                                                        |
| Warm: Email          | Entered via cold email response — email track in Warm Response                                                           |
| Warm: SMS            | Entered via cold SMS response — SMS track in Warm Response                                                               |
| Cold: Email Only     | Email-to-Cold lead. Email drip only — one-time SMS already sent to skip-traced numbers.                                 |
| Source: Cold Call     | Lead came from cold calling                                                                                              |
| Source: Cold Email    | Lead came from cold email campaign                                                                                       |
| Source: Cold SMS      | Lead came from SMS blast campaign                                                                                        |
| Source: Direct Mail   | Lead came from direct mail                                                                                               |
| Source: VAPI AI Call  | Lead called Bana Land number; AI agent answered                                                                          |
| Source: Launch Control | Lead came from Launch Control platform                                                                                  |
| Source: Referral      | Lead came via referral                                                                                                  |
| Source: Website       | Lead came via website inquiry                                                                                            |
| Bounced              | Email address bounced — do not email until corrected                                                                     |
| Can't Find           | No valid contact info — hold for skip trace                                                                              |
| Cleanup              | Added by WF-CLEANUP during re-submission. Prevents WF-HANDOFF from double-firing.                                       |

---

## Step 5 — Pipeline Setup

Go to **CRM > Pipelines > Add Pipeline** and create: `Bana Land — Warm Response Pipeline`

Add the following stages **in this exact order:**

1. **Warm Response** — active 14-day window (email + SMS tracks)
2. **Cold** — warm leads that timed out, long-term drip
3. **Transferred** — terminal success: lead handed off to New Leads
4. **Dispo: DNC** — terminal: zero contact

---

## Step 6 — Workflows to Build

Build each workflow in **Automation > Workflows**.

### Workflow Index (Quick Reference)

| Code         | Name                                    |
| ------------ | --------------------------------------- |
| **WF-00A**   | Warm Response — Email Track             |
| **WF-00B**   | Warm Response — SMS Track               |
| **WF-05**    | Cold Drip (Monthly → Quarterly)         |
| **WF-10**    | DNC Handler (+ DNC Sync)               |
| **WF-HANDOFF** | Transfer to New Leads                 |
| **WF-11**    | Inbound Response Handler                   |
| **WF-CLEANUP** | Re-Submission Cleanup (automation Triggered)    |

---

### WF-00A | Warm Response — Email Track

**Trigger:** Contact added to pipeline stage "Warm Response" AND tagged `Warm: Email`
**Owner:** Lead Manager
**Enrollment condition:** Lead NOT tagged DNC

**Actions:**

1. Update custom field: Lead Entry Date = Today
2. Update custom field: Stage Entry Date = Today
3. Send Email: WR-EMAIL-01 (ask for phone number)
4. Wait: 1 day
5. If phone number field is still empty:
   - Send Email: WR-EMAIL-02
6. Wait: 2 days
7. If phone number field is still empty:
   - Send Email: WR-EMAIL-03
8. Wait: 3 days
9. If phone number field is still empty:
   - Send Email: WR-EMAIL-04
10. Wait: 3 days
11. If phone number field is still empty:
    - Send Email: WR-EMAIL-05
12. **If phone number received at any point (Lead Manager manually moves contact):**
    - Lead Manager enters phone number into contact record and moves to pipeline stage: Transferred
    - WF-HANDOFF fires: sends webhook to automation → New Leads creates contact in New Leads → WF-01 fires
    - Lead Manager has no further responsibility for this contact
13. If Day 14 reached with no connection:
    - **One-time SMS blast to all skip-traced phone numbers on contact (one SMS per number, send only if field is not empty):**
      - Send SMS to Phone 1: WR-COLD-SMS-01
      - Send SMS to Phone 2: WR-COLD-SMS-01 (if Phone 2 is not empty)
      - Send SMS to Phone 3: WR-COLD-SMS-01 (if Phone 3 is not empty)
      - Send SMS to Phone 4: WR-COLD-SMS-01 (if Phone 4 is not empty)
    - **This is a one-time blast only.** No more SMS will be sent in Cold stage for this contact.
    - Add tag: `Cold: Email Only` — flags contact for email-only Cold drip (WF-05 skips SMS steps)
    - Move to pipeline stage: Cold (WF-05 fires automatically on stage entry)
    - Send internal notification to Lead Manager: "{{first_name}} — warm email responder moved to Cold after 14 days with no phone connection. One-time SMS blast sent to all skip-traced numbers."

**If any skip-traced number responds to the one-time SMS:**

- WF-11 fires (Inbound Response Handler) — drip paused, review task created
- If connection is made, contact moves to Transferred → WF-HANDOFF → New Leads
- `Cold: Email Only` tag can be removed if phone number is now confirmed

**Pause mechanic:** Every email send step has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before it. If the field is set, the contact holds in place — position preserved, no messages sent.

**Exit conditions:** Stage changes (phone number received → moved to Transferred, or Dispo: DNC)

---

### WF-00B | Warm Response — SMS Track

**Trigger:** Contact added to pipeline stage "Warm Response" AND tagged `Warm: SMS`
**Owner:** Lead Manager
**Enrollment condition:** Lead NOT tagged DNC

**Actions:**

1. Update custom field: Lead Entry Date = Today
2. Update custom field: Stage Entry Date = Today
3. Create Task: "Call {{first_name}} — Warm SMS Responder — CALL NOW" — Assigned to: Lead Manager — Due: Today
4. Wait: 1 day
5. Create Task: "Call {{first_name}} — Day 2 Attempt" — Assigned to: Lead Manager — Due: Today
6. Wait: 1 day
7. Send SMS: WR-SMS-01
8. Create Task: "Call {{first_name}} — Day 3 Attempt" — Assigned to: Lead Manager — Due: Today
9. Wait: 2 days
10. Send SMS: WR-SMS-02
11. Wait: 1 day
12. Create Task: "Call {{first_name}} — Day 6 Final Attempt" — Assigned to: Lead Manager — Due: Today
13. Wait: 2 days
14. Send SMS: WR-SMS-03
15. Wait: 6 days
16. Send SMS: WR-SMS-04
17. Move to pipeline stage: Cold (WF-05 fires automatically on stage entry)
18. Send internal notification to Lead Manager: "{{first_name}} — warm SMS responder moved to Cold after 14 days with no phone connection."

**Pause mechanic:** Every SMS send step has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before it. Call task creation is unaffected — tasks may still be created while paused.

**Exit conditions:** Stage changes (phone call completed → moved to Transferred, or Dispo: DNC)

---

### WF-05 | Cold Drip — Monthly → Quarterly

**Trigger:** Contact moved to pipeline stage "Cold"
**Enrollment condition:** Lead NOT tagged DNC

**Note — `Cold: Email Only` contacts:** Skip all SMS steps — send email steps only.

**Phase 1 — Monthly (Day 0–180 in Cold):**

1. Wait: 30 days
2. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-01
3. Wait: 30 days
4. Send Email: COLD-EMAIL-01
5. Wait: 30 days
6. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-04
7. Wait: 30 days
8. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-02
9. Wait: 30 days
10. Send Email: COLD-EMAIL-02
11. Wait: 30 days
12. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-03

**Phase 2 — Quarterly (Day 180+, indefinite):**

13. Wait: 90 days
14. **If NOT tagged `Cold: Email Only`:** Send SMS: COLDQ-SMS-01
15. Wait: 1 day
16. Send Email: COLDQ-EMAIL-01
17. Go to Step 13 (loop)

**Note:** GHL does not natively loop workflows. Build out 2+ years of quarterly steps manually and extend as needed.

**Pause mechanic:** Every send step has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before it. If the field is set, the contact holds in place — position preserved, no messages sent.

---

### WF-10 | DNC Handler (+ DNC Sync to New Leads + Prospect Data)

**Trigger:** Contact moved to Dispo: DNC OR SMS reply contains STOP/QUIT/UNSUBSCRIBE/CANCEL/END
**Actions:**

1. Move to pipeline stage: Dispo: DNC (ensures correct stage regardless of trigger source)
2. Remove from ALL active workflow enrollments (use "Remove from Workflow" action for each active WF)
3. Add tag: DNC
4. Update custom field: DNC Date = Today
5. Cancel all pending tasks for this contact
6. Send internal notification to team: "{{first_name}} has opted out — DNC applied. [Contact Link]"
7. **DNC Sync — New Leads:** Fire webhook to automation with contact identifier (email + phone numbers)
   - automation looks up contact in New Leads
   - If found → triggers DNC in New Leads (moves to DNC stage, kills workflows, tags DNC)
   - If not found → no action needed
8. **DNC Sync — Prospect Data:** Fire webhook to automation with contact identifier (email + phone numbers)
   - automation looks up matching Property record in Prospect Data by phone or email
   - If found → set DNC = checked, DNC Date = today, Status = DNC
   - If not found → no action needed
9. End — no further actions ever

---

### WF-HANDOFF | Transfer to New Leads

**Trigger:** Contact moved to pipeline stage "Transferred"
**Enrollment condition:** Contact NOT tagged `Cleanup` (prevents double-fire when WF-CLEANUP moves re-submitted contacts to Transferred — automation already handled the push to New Leads)
**Actions:**

1. Fire webhook to automation with all contact data:
   - First name, last name
   - Email address
   - All phone numbers (Phone 1–4)
   - All tags (source tags, Warm: Email/SMS, etc.)
   - All custom field values (Original Source, Latest Source, Latest Source Date, property data)
   - Contact notes
2. automation receives webhook → creates contact in New Leads → places in New Leads stage
3. New Leads' WF-01 fires automatically (assigns to AM, creates review task)
4. Send internal notification to Lead Manager: "{{first_name}} transferred to New Leads. Acquisition Manager will take over."
5. End — no further actions in this account

---

### WF-11 | Inbound Response Handler

**Decision: Option A — Lead Manager reviews.** Lead Manager tries to connect. If successful → transfer to New Leads. If not actionable → workflow resumes.

**Trigger:** Inbound SMS received OR Email reply received
**Applies to:** All contacts — active LM stage (Warm Response) AND Cold drip stage
**Enrollment condition:** Lead NOT tagged DNC

**Pause mechanic:** WF-00A, WF-00B, and WF-05 each have a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before each send step. Setting the field holds all active workflows in place — position preserved, no messages sent.

**Actions:**

1. **Check: Is the reply an opt-out keyword?** (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
   - If yes → route to WF-10 (DNC Handler). End this workflow.
2. Set custom field: `Pause WFs Until` = today + 7 days — all active workflows immediately hold at their next send condition
3. Add tag: `Re-Engaged`
4. Create Task: "CALL — {{first_name}} replied. Call them and try to connect." — Assigned to: Lead Manager — Due: Today — Priority: High
5. Send internal notification to Lead Manager: "{{first_name}} replied. Automation paused for 7 days. Call them — if you connect, move to Transferred. To resume early, clear the Pause WFs Until field. [Contact Link]"
6. **Branch — Cold stage only:** Wait 7 days (auto-resume safety net)
7. **Resolution:**
   - **Lead Manager connects → moves to Transferred:** WF-HANDOFF fires, contact goes to New Leads. Clear field: `Pause WFs Until`. Remove tag: `Re-Engaged`.
   - **Lead Manager clears `Pause WFs Until` field early (not actionable):** Drip resumes from where it stopped. Remove tag: `Re-Engaged`.
   - **Cold stage only — No action after 7 days:** `Pause WFs Until` date has now passed — drip send conditions evaluate to true and resume automatically. Clear field: `Pause WFs Until` (cleanup). Remove tag: `Re-Engaged`. Send notification: "{{first_name}} — 7-day review window expired with no action. Drip resumed automatically."

**Note for Warm Response stage contacts:** No 7-day auto-resume. Lead Manager is actively working these leads. Resolution is: LM moves to Transferred (kills workflow) or clears the `Pause WFs Until` field.

---

### WF-CLEANUP | Re-Submission Cleanup (Triggered by automation)

**Trigger:** Webhook received from automation (re-submission cleanup signal)
**Purpose:** When a contact in this account gets re-submitted from a new external campaign and enters New Leads, this workflow cleans up Warm Response.

**Actions:**

1. Remove from all active workflow enrollments (WF-05, WF-00A, WF-00B)
2. Clear field: `Pause WFs Until` (if set). Remove tag: `Re-Engaged` (if present)
3. Cancel all pending tasks for this contact
4. Add tag: `Cleanup` (prevents WF-HANDOFF from firing when stage moves to Transferred — automation already pushed the contact to New Leads)
5. Move to pipeline stage: Transferred (terminal — contact now lives in New Leads)
6. Add note: "Contact re-submitted from new external campaign. Moved to New Leads as new lead. All Warm Response workflows stopped."

---

## Step 7 — GHL Smart List Setup

Create these Smart Lists under Contacts for daily team use:

| Smart List Name        | Filter Criteria                       |
| ---------------------- | ------------------------------------- |
| Warm Response — Active | Stage = Warm Response                 |
| Today's Call Tasks     | Open tasks, type = Call, due today    |
| Cold — Active Drip     | Stage = Cold                          |
| DNC Contacts           | Tag = DNC                             |
| Transferred            | Stage = Transferred                   |

---

## Step 8 — Compliance Verification Checklist

Before going live, verify:

- SMS opt-out keywords configured (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
- Auto-reply on opt-out is set: "You've been unsubscribed. Reply START to re-subscribe."
- WF-10 (DNC Handler) triggers on opt-out SMS reply
- DNC sync webhook to automation tested and confirmed working
- All workflows have time-window restrictions (9am–7pm contact local time)
- All SMS messages identify sender: include "Bana Land" or agent name
- Phone number has A2P 10DLC registration completed (required for business SMS in US)
- Unsubscribe footer included in all marketing emails
- Task assignment mapped to Lead Manager
- All workflow enrollments tested with a test contact before live launch
- WF-HANDOFF webhook tested end-to-end (Warm Response → automation → New Leads)

---

## Step 9 — Go-Live Checklist

- All pipeline stages created and in correct order (Warm Response, Cold, Transferred, DNC)
- All custom fields created (matching New Leads schema)
- All tags created
- All 7 workflows built and tested (WF-00A, WF-00B, WF-05, WF-10, WF-HANDOFF, WF-11, WF-CLEANUP)
- WF-CLEANUP webhook endpoint configured
- Smart lists created
- Lead Manager trained on GHL task queue and stage movement
- automation routing confirmed: warm responses → Warm Response
- DNC sync tested bidirectionally (Warm Response ↔ New Leads ↔ Prospect Data)
- Prospect Data push automation tested: field mapping correct, Contact + Opportunity created per property
- Prospect Data DNC sync tested: DNC in Warm Response → Property record updated (DNC checked, Status = DNC)
- Transfer webhook tested: Warm Response → automation → New Leads
