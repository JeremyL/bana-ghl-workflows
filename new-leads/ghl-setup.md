# Bana Land — New Leads Account (Account 2): GHL Setup Guide

This guide walks through building the New Leads GHL sub-account from scratch.
Follow the steps in order — each section depends on the previous one being complete.

This account handles all leads from New Leads through close, disqualification, or long-term drip.

Reference files:

- [pipeline.md](pipeline.md) — stage definitions
- [sequences.md](sequences.md) — cadence map
- [messaging.md](messaging.md) — message templates
- [rules.md](rules.md) — compliance rules
- For Account 1: [../warm-response/ghl-setup.md](../warm-response/ghl-setup.md)

---

## Step 1 — Sub-Account Setup

1. Log into GHL and create the New Leads sub-account
2. Set the **business name** to: `Bana Land — New Leads`
3. Set the **time zone** to: `Eastern Time` (default safe zone for compliance)
   - Note: Workflows should use per-contact local time where possible
4. Configure **company phone number** — this will be used for SMS and caller ID
5. Set **reply-to email address** for all outgoing emails

---

## Step 2 — Integrations to Connect

| Service        | Purpose                            | GHL Location                              |
| -------------- | ---------------------------------- | ----------------------------------------- |
| SMS Provider   | Outbound/inbound texts             | Settings > Phone Numbers > LC Phone       |
| Email Provider | Outbound emails                    | Settings > Email Services > Mailgun or LC |
| Calendar       | Optional — for appointment setting | Settings > Calendars                      |

---

## Step 2B — Lead Entry Integration (n8n / Webhook)

There are three entry paths into this account. Every incoming lead follows exactly one of them.

---

### Entry Path 1 — Transfer from Account 1 (Warm Response)

**Who:** Warm Response leads that successfully connected — Lead Manager transferred them.
**Where they land:** New Leads pipeline stage (Acquisition Manager owns from here).
**How:** Account 1's WF-HANDOFF fires a webhook to n8n → n8n creates contact in this account.

**What n8n must send to this account:**

| Field                            | Value                                                                 |
| -------------------------------- | --------------------------------------------------------------------- |
| First name, last name            | From Account 1 contact record                                        |
| Email address                    | From Account 1                                                        |
| All phone numbers (Phone 1–4)    | From Account 1                                                        |
| All tags                         | Carry over from Account 1 (Source tags, Warm: Email/SMS, etc.)        |
| Custom field: Original Source    | From Account 1 (never overwritten)                                    |
| Custom field: Latest Source      | From Account 1                                                        |
| Custom field: Latest Source Date | From Account 1                                                        |
| Contact notes                    | From Account 1                                                        |
| Pipeline stage                   | New Leads                                                             |

---

### Entry Path 2 — Direct to New Leads (Cold Call, Direct Mail, VAPI)

**Who:** Prospects from cold calling, direct mail, or inbound VAPI calls — anyone who did NOT come through the cold email/SMS Warm Response path.
**Where they land:** New Leads pipeline stage (Acquisition Manager owns from here).
**How:** Entered via n8n flow. These leads skip Account 1 entirely.

**What must be set on entry:**

| Field                            | Value                                                                 |
| -------------------------------- | --------------------------------------------------------------------- |
| Tag                              | `Source: Cold Call`, `Source: Direct Mail`, or `Source: VAPI AI Call` |
| Custom field: Original Source    | Matching source value (set once, never overwritten)                   |
| Custom field: Latest Source      | Same as Original Source on first entry                                |
| Custom field: Latest Source Date | Today                                                                 |
| Pipeline stage                   | New Leads                                                             |

**VAPI note:** The `Source: VAPI AI Call` tag is applied automatically by VAPI. The team reviews the call transcript after entry and manually adds any additional context tags. No separate sequence needed — VAPI contacts follow the standard New Leads flow.

---

### Entry Path 3 — Re-Submission (Contact Already Exists — New External Campaign)

**Who:** A contact already in this account (any stage) who responds to a new, separate marketing campaign outside GHL.
**Where they land:** New Leads — full restart as a new lead.

**What n8n must do:**

1. Detect the contact already exists in this account (duplicate match)
2. Stack a new Source tag on the existing contact (e.g., `Source: Direct Mail` added on top of existing `Source: Cold Call`)
3. Update custom field: Latest Source = new source value
4. Update custom field: Latest Source Date = Today
5. Add tag: `Re-Submitted`
6. Move Opportunity to New Leads (same property) or create a new Opportunity (new property)
7. **If contact also exists in Account 1:** Fire cleanup webhook to Account 1 (stop drip, move to Transferred)

**Rules:**

- Do NOT overwrite Original Source — first-touch attribution is permanent
- WF-01 fires automatically on the New Leads stage move → cleans up active drips and creates AM task

---

### Opportunity Creation (Applies to All Entry Paths)

When any new contact enters this account, create an **Opportunity** linked to that contact in the pipeline.

- Populate Opportunity custom fields with available property data (Reference ID, Prop County, Prop State, Acres, APN, etc.)
- The Opportunity is what moves through pipeline stages — the Contact record stays static
- A Contact will only ever have one active Opportunity at a time

---

## Step 3 — Custom Fields

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

---

### Contact Custom Fields

Go to **Settings > Custom Fields > Contacts** and create the following:

| Field Name        | Type     | Purpose                                         |
| ----------------- | -------- | ----------------------------------------------- |
| Lead Entry Date   | Date     | Date lead was first added to the pipeline       |
| Stage Entry Date  | Date     | Date lead entered their CURRENT stage           |
| Days in Pipeline  | Number   | Calculated from Lead Entry Date (for reporting) |
| DNC Date          | Date     | Date lead was added to DNC                      |
| Last Contact Date | Date     | Date of last successful outreach attempt        |
| Last Contact Type | Text     | Call / SMS / Email                              |
| Age               | Number   | Owner's age (from skip trace data)              |
| Deceased          | Checkbox | Owner is deceased (from skip trace data)        |
| Assigned To       | Text     | Acquisition manager name                        |

---

### Opportunity Custom Fields

Go to **Settings > Custom Fields > Opportunities** and create the following:

| Field Name          | Type       | Purpose                                                                                                                                                                                          |
| ------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Reference ID        | Text       | Internal reference/tracking ID for the property                                                                                                                                                  |
| Prop County         | Text       | County where the property is located                                                                                                                                                             |
| Prop State          | Dropdown   | State where the property is located (all US states)                                                                                                                                              |
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
| Latest Source       | Dropdown   | Most recent channel that brought this lead in. Same dropdown values as Original Source.                                                                                                          |
| Latest Source Date  | Date       | Date the Latest Source field was last updated                                                                                                                                                     |

---

## Step 4 — Tags to Create

**Tag naming convention:** All tags follow `Category: Value` format with title case. Simple high-priority tags (DNC, Hot) are kept short.

Go to **Settings > Tags** and create these tags:

| Tag Name                | Use                                                                                                                     |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| DNC                     | Do Not Contact — blocks all outreach. Triggers DNC sync to Account 1.                                                  |
| Hot                     | Team-assigned tag for priority leads (manual)                                                                            |
| Re-Engaged              | Lead responded to our existing GHL follow-up/drip. Triggers WF-11 (pause + AM review).                                  |
| Re-Submitted            | Lead came back in from a new external campaign (different source). Resets to New Leads.                                  |
| Paused                  | Holds all automated workflows at their next send gate. Added by WF-11 on inbound response.                             |
| Warm: Email             | Carried over from Account 1 — entered via cold email response (historical tracking)                                     |
| Warm: SMS               | Carried over from Account 1 — entered via cold SMS response (historical tracking)                                       |
| Drip: Cold Monthly      | Cold stage monthly cadence (WF-05). Added when contact enters Cold stage or Dispo Re-Engage.                             |
| Drip: Cold Quarterly    | Cold stage quarterly cadence (WF-06). Swapped in from Cold Monthly at 6-month mark.                                     |
| Drip: Nurture Monthly   | Nurture monthly cadence (WF-08 Phase 1). Added when contact enters Nurture stage.                                        |
| Drip: Nurture Quarterly | Nurture quarterly cadence (WF-08 Phase 2). Swapped in from Nurture Monthly at Month 3.                                  |
| Source: Cold Call        | Lead came from cold calling                                                                                              |
| Source: Cold Email       | Lead came from cold email campaign                                                                                       |
| Source: Cold SMS         | Lead came from SMS blast campaign                                                                                        |
| Source: Direct Mail      | Lead came from direct mail                                                                                               |
| Source: VAPI AI Call     | Lead called Bana Land number; AI agent answered                                                                          |
| Source: Launch Control   | Lead came from Launch Control platform                                                                                   |
| Source: Referral         | Lead came via referral                                                                                                   |
| Source: Website          | Lead came via website inquiry                                                                                            |
| Medium: Phone            | Lead responded or came in via phone                                                                                     |
| Medium: Form Email       | Lead responded via email form                                                                                           |
| Medium: Google Form      | Lead responded via Google Form                                                                                          |
| Medium: Raw Email        | Lead responded via direct email reply                                                                                   |
| Bounced                  | Email address bounced — do not email until corrected                                                                    |
| Can't Find               | No valid contact info — hold for skip trace                                                                             |
| Caller: [Agent Name]     | VAPI AI persona that handled the inbound call (auto-applied)                                                            |

---

## Step 5 — Pipeline Setup

Go to **CRM > Pipelines > Add Pipeline** and create: `Bana Land — Seller Pipeline`

Add the following stages **in this exact order:**

**Group: Not Contacted / Not Qualified** *(Acquisition Manager)*

1. New Leads
2. Day 1-2
3. Day 3-14
4. Day 15-30
5. Cold

**Group: Dispo — Terminal** *(no future contact)*

6. Dispo: Not a Fit
7. Dispo: No Longer Own
8. Dispo: Purchased
9. Dispo: DNC

**Group: Dispo — Re-Engage** *(light long-term drip)*

10. Dispo: No Motivation
11. Dispo: Wants Retail
12. Dispo: On MLS
13. Dispo: Lead Declined

**Group: Qualified**

14. Due Diligence
15. Make Offer
16. Negotiations
17. Contract Sent
18. Under Contract
19. Nurture

---

## Step 6 — Workflows to Build

Build each workflow in **Automation > Workflows**.

### Workflow Index (Quick Reference)

| Code       | Name                                        |
| ---------- | ------------------------------------------- |
| **WF-01**  | New Lead Entry                              |
| **WF-02**  | Day 1-2 Sequence                            |
| **WF-03**  | Day 3-14 Sequence                           |
| **WF-04**  | Day 15-30 Sequence                          |
| **WF-05**  | Cold Monthly Drip                           |
| **WF-06**  | Cold Quarterly Drip                         |
| **WF-07**  | Qualified Lead Check-In                     |
| **WF-08**  | Nurture                                     |
| **WF-09**  | Dispo Re-Engage — Long-Term Drip Enrollment |
| **WF-10**  | DNC Handler (+ DNC Sync)                   |
| **WF-11**  | Inbound Response Handler (Re-Engagement)    |

---

### WF-01 | New Lead Entry

**Trigger:** Contact added to pipeline stage "New Leads"
**Actions:**

1. **If contact is tagged `Re-Submitted` (re-entry from new external campaign):**
   - Remove all drip tags: `Drip: Cold Monthly`, `Drip: Cold Quarterly`, `Drip: Nurture Monthly`, `Drip: Nurture Quarterly`
   - Remove from all active drip workflows (WF-05, WF-06, WF-08, WF-09)
   - Remove tag: `Re-Engaged` (if present from a prior cycle)
   - Remove tag: `Re-Submitted` (cleanup — it has served its purpose as a trigger)
2. Assign contact to acquisition manager (specific team member)
3. Update custom field: Lead Entry Date = Today (skip if already set — contact may be coming from Account 1 or re-submission)
4. Update custom field: Original Source (skip if already set — only set on first-ever entry)
5. Update custom field: Latest Source = current source value
6. Update custom field: Latest Source Date = Today
7. Update custom field: Stage Entry Date = Today
8. Create Task: "Review new lead — call {{first_name}}" — Assigned to: Acquisition Manager — Due: Today
9. Send internal notification to Acquisition Manager: "New lead ready for review: {{first_name}}. Move to Day 1-2 after initial contact attempt."

**Note:** No outreach automations fire at New Leads. AM reviews the lead, makes one manual contact attempt, then manually moves the contact to Day 1-2 — that stage move triggers WF-02.

---

### WF-02 | Day 1-2 Sequence

**Trigger:** Contact moved to pipeline stage "Day 1-2" (AM manually moves from New Leads after initial review and contact attempt)
**Enrollment condition:** Lead NOT tagged DNC

**Actions:**

1. Update custom field: Stage Entry Date = Today
2. Send SMS: NL-SMS-01 (First Touch)
3. Wait: 4 hours
4. Create Task: "Call {{first_name}} — First Attempt" — Assigned to: Acquisition Manager — Due: Today
5. Wait: 4 hours
6. Send SMS: NL-SMS-07 (Missed Call Follow-Up)
7. Wait: until next business day, 9:00 AM contact local time
8. Send Email: NL-EMAIL-01
9. Wait: 4 hours
10. Create Task: "Call {{first_name}} — Day 2 Attempt" — Assigned to: Acquisition Manager — Due: Today
11. Wait: 4 hours
12. Send SMS: NL-SMS-02
13. Wait: until Day 3 begins
14. If no stage change: Move to Day 3-14 → Enroll in WF-03

**Pause mechanic:** "Wait Until `Paused` tag is NOT present" gate before each send step.

**Exit conditions:** Contact stage changes (moved to qualified or disqualified stage)

---

### WF-03 | Day 3-14 Sequence

**Trigger:** Enrolled from WF-02 or manually
**Enrollment condition:** Lead NOT tagged DNC

**Actions:**

1. Update custom field: Stage Entry Date = Today
2. Create Task: "Call {{first_name}} — Day 3" — Assigned to: Acquisition Manager — Due: Today
3. Wait: 1 day
4. Send SMS: NL-SMS-02
5. Wait: 1 day
6. Send Email: NL-EMAIL-05
7. Wait: 1 day
8. Create Task: "Call {{first_name}} — Day 6" — Assigned to: Acquisition Manager — Due: Today
9. Wait: 1 day
10. Send Email: NL-EMAIL-02
11. Wait: 1 day
12. Send SMS: NL-SMS-03
13. Wait: 1 day
14. Create Task: "Call {{first_name}} — Day 9" — Assigned to: Acquisition Manager — Due: Today
15. Wait: 1 day
16. Send SMS: NL-SMS-08
17. Wait: 1 day
18. Send SMS: NL-SMS-04 (Re-engage)
19. Wait: 2 days
20. Create Task: "Call {{first_name}} — Day 13 Final Attempt (this stage)" — Assigned to: Acquisition Manager — Due: Today
21. Wait: 1 day
22. If no stage change: Move to pipeline stage: Day 15-30 → Enroll in WF-04

**Pause mechanic:** "Wait Until `Paused` tag is NOT present" gate before each send step.

**Exit conditions:** Contact stage changes (moved to qualified or disqualified stage)

---

### WF-04 | Day 15-30 Sequence

**Trigger:** Enrolled from WF-03 or manually
**Enrollment condition:** Lead NOT tagged DNC

**Important:** All touches in this workflow must be restricted to **Tuesdays and Thursdays only**, within the 9am–7pm contact local time window.

**Actions:**

1. Update custom field: Stage Entry Date = Today
2. Send Email: NL-EMAIL-03 (Day 15)
3. Wait: 2 days
4. Send SMS: NL-SMS-09 (Day 17)
5. Wait: 5 days
6. Send SMS: NL-SMS-05 (Day 22)
7. Wait: 2 days
8. Create Task: "Call {{first_name}} — Day 24" — Assigned to: Acquisition Manager — Due: Today
9. Wait: 5 days
10. Send Email: NL-EMAIL-04 (Day 29 — Long-game)
11. Wait: 1 day
12. Send SMS: NL-SMS-06 (Day 30 — Final touch before cold)
13. If no stage change: Move to pipeline stage: Cold → Add tag: `Drip: Cold Monthly` → Enroll in WF-05

**Pause mechanic:** "Wait Until `Paused` tag is NOT present" gate before each send step.

**Exit conditions:** Contact stage changes (moved to qualified or disqualified stage)

---

### WF-05 | Long-Term Drip — Monthly Phase (Day 30–180)

**Trigger:** Tag added: `Drip: Cold Monthly`
**Applies to:** Cold stage leads (no response after Day 30) AND all Dispo Re-Engage leads
**Enrollment condition:** Lead NOT tagged DNC

**Actions:**

1. Wait: 30 days
2. Send SMS: COLD-SMS-01
3. Wait: 30 days
4. Send Email: COLD-EMAIL-01
5. Wait: 30 days
6. Send SMS: COLD-SMS-04
7. Wait: 30 days
8. Send SMS: COLD-SMS-02
9. Wait: 30 days
10. Send Email: COLD-EMAIL-02
11. Wait: 30 days
12. Send SMS: COLD-SMS-03
13. Remove tag: `Drip: Cold Monthly` → Add tag: `Drip: Cold Quarterly` → Enroll WF-06

**Pause mechanic:** "Wait Until `Paused` tag is NOT present" gate before each send step.

---

### WF-06 | Long-Term Drip — Quarterly Phase (Day 180+)

**Trigger:** Tag added: `Drip: Cold Quarterly`
**Enrollment condition:** Lead NOT tagged DNC

**Actions (repeat indefinitely):**

1. Wait: 90 days
2. Send SMS: COLDQ-SMS-01
3. Wait: 1 day
4. Send Email: COLDQ-EMAIL-01
5. Go to Step 1 (loop)

**Note:** GHL does not natively loop workflows. Use a recurring enrollment trigger or build out 2+ years of touches manually.

**Pause mechanic:** "Wait Until `Paused` tag is NOT present" gate before each send step.

---

### WF-07 | Qualified Lead Check-In (Due Diligence → Under Contract)

**Trigger:** Contact moved to Due Diligence stage
**Actions:**

1. Create Task: "Call {{first_name}} — Due Diligence Check-In" — Due: Today
2. Wait: 2 days
3. If still in same stage: Send SMS — check-in (use NL-SMS-02 or custom message)
4. Wait: 1 day
5. Create Task: "Follow up call — {{first_name}}" — Due: Today
6. Repeat / loop every 1-2 days until stage changes

Apply similar logic for Make Offer, Negotiations, Contract Sent stages.

---

### WF-08 | Nurture Sequence (Tiered)

**Trigger:** Contact moved to Nurture stage
**Enrollment condition:** Lead NOT tagged DNC

**Phase 1 — Monthly (Months 0–3):**

1. Add tag: `Drip: Nurture Monthly`
2. Send SMS: NUR-SMS-01
3. Wait: 30 days
4. Send Email: NUR-EMAIL-01
5. Wait: 30 days
6. Send SMS: NUR-SMS-02
7. Wait: 30 days
8. Remove tag: `Drip: Nurture Monthly` → Add tag: `Drip: Nurture Quarterly`

**Phase 2 — Quarterly (Month 3+, indefinite):**

9. Send Email: NURQ-EMAIL-01
10. Wait: 90 days
11. Send SMS: NURQ-SMS-01
12. Wait: 90 days
13. Send Email: NUR-EMAIL-01
14. Wait: 90 days
15. Send SMS: NURQ-SMS-02 (1-year touch)
16. Wait: 90 days
17. Send SMS: NUR-SMS-02
18. Wait: 90 days
19. Go to Step 9 (loop indefinitely at quarterly cadence)

**Pause mechanic:** "Wait Until `Paused` tag is NOT present" gate before each send step.

---

### WF-09 | Dispo Re-Engage — Long-Term Drip Enrollment

**Trigger:** Contact moved to any Dispo Re-Engage stage: No Motivation, Wants Retail, On MLS, or Lead Declined
**Actions:**

1. Update custom field: Stage Entry Date = Today
2. Add tag: `Drip: Cold Monthly`
3. Enroll in WF-05 (Long-Term Drip — Monthly Phase)

That's it. All re-engage dispo leads flow into the same Long-Term Drip as Cold stage leads.

---

### WF-10 | DNC Handler (+ DNC Sync to Warm Response + Prospect Data)

**Trigger:** Contact moved to Dispo: DNC OR SMS reply contains STOP/QUIT/UNSUBSCRIBE/CANCEL/END
**Actions:**

1. Move to pipeline stage: Dispo: DNC (ensures correct stage regardless of trigger source)
2. Remove from ALL active workflow enrollments (use "Remove from Workflow" action for each active WF)
3. Add tag: DNC
4. Update custom field: DNC Date = Today
5. Cancel all pending tasks for this contact
6. Send internal notification to team: "{{first_name}} has opted out — DNC applied. [Contact Link]"
7. **DNC Sync — Warm Response:** Fire webhook to n8n with contact identifier (email + phone numbers)
   - n8n looks up contact in Warm Response
   - If found → triggers DNC in Warm Response (moves to DNC stage, kills workflows, tags DNC)
   - If not found → no action needed
8. **DNC Sync — Prospect Data:** Fire webhook to n8n with contact identifier (email + phone numbers)
   - n8n looks up matching Property record in Prospect Data by phone or email
   - If found → set DNC = checked, DNC Date = today, Status = DNC
   - If not found → no action needed
9. End — no further actions ever

---

### WF-11 | Inbound Response Handler (Re-Engagement)

**Trigger:** Inbound SMS received OR Email reply received
**Applies to:** All contacts — drip stages (Cold, Nurture, Dispo Re-Engage) AND active AM stages (Day 1-2, Day 3-14, Day 15-30)
**Enrollment condition:** Lead NOT tagged DNC

**Pause mechanic:** Every drip/automated-send workflow (WF-02 through WF-06, WF-08) has a "Wait Until `Paused` tag is NOT present" gate before each send step.

**Actions:**

1. **Check: Is the reply an opt-out keyword?** (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
   - If yes → route to WF-10 (DNC Handler). End this workflow.
2. Add tag: `Paused` — all active automated workflows immediately hold at their next send gate
3. Add tag: `Re-Engaged`
4. Create Task: "REVIEW — {{first_name}} re-engaged (replied). Read their reply and decide next step." — Assigned to: Acquisition Manager — Due: Today — Priority: High
5. Send internal notification to AM: "{{first_name}} replied. Automation paused. Review and either move stage or remove the Paused tag. [Contact Link]"
6. **Branch — drip stages (Cold / Nurture / Dispo Re-Engage) only:** Wait 7 days (auto-resume safety net)
7. **Branch — check resolution:**
   **Branch A — AM moved contact to a qualified stage (Due Diligence, Make Offer, etc.):**
   - Workflow exit conditions fire, all active workflows killed automatically
   - Remove tags: `Paused`, `Re-Engaged` (cleanup)
   - End workflow. Qualified stage workflows (WF-07) take over.
   **Branch B — AM moved contact to any Dispo stage:**
   - Workflow exit conditions fire, all active workflows killed automatically
   - Remove tags: `Paused`, `Re-Engaged` (cleanup)
   - End workflow. Dispo workflows handle it (WF-09 for Re-Engage dispos, WF-10 for DNC).
   **Branch C — AM manually removed `Paused` tag (reply not actionable, lead stays in stage):**
   - Remove tag: `Re-Engaged` (cleanup)
   - Drip resumes from exactly where it stopped. End workflow.
   **Branch D — AM did nothing, 7 days expired (drip stages only):**
   - Remove tag: `Paused` — drip resumes from exactly where it stopped
   - Remove tag: `Re-Engaged` (cleanup)
   - Send internal notification to AM: "{{first_name}} — 7-day review window expired with no action. Drip resumed automatically."

**Note for active AM stages (Day 1-2 / Day 3-14 / Day 15-30):** There is no 7-day auto-resume for these contacts. The AM is already actively working them. Resolution is: AM moves stage (kills workflow) or manually removes the `Paused` tag.

---

## Step 7 — GHL Smart List Setup

Create these Smart Lists under Contacts for daily team use:

| Smart List Name        | Filter Criteria                                          |
| ---------------------- | -------------------------------------------------------- |
| Today's Call Tasks     | Open tasks, type = Call, due today                       |
| Hot Leads              | Tag = Hot                                                |
| Cold — No Response 30d | Stage = Cold, Last Contact Date > 30 days ago            |
| Active Qualified Leads | Stage is one of: Due Diligence, Make Offer, Negotiations |
| Contracts in Progress  | Stage is one of: Contract Sent, Under Contract           |
| DNC Contacts           | Tag = DNC                                                |

---

## Step 8 — Compliance Verification Checklist

Before going live, verify:

- SMS opt-out keywords configured (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
- Auto-reply on opt-out is set: "You've been unsubscribed. Reply START to re-subscribe."
- WF-10 (DNC Handler) triggers on opt-out SMS reply
- DNC sync webhook to n8n tested and confirmed working (both directions)
- All workflows have time-window restrictions (9am–7pm contact local time)
- All SMS messages identify sender: include "Bana Land" or agent name
- Phone number has A2P 10DLC registration completed (required for business SMS in US)
- Unsubscribe footer included in all marketing emails
- Task assignment mapped to correct team member(s)
- All workflow enrollments tested with a test contact before live launch

---

## Step 9 — Go-Live Checklist

- All pipeline stages created and in correct order
- All custom fields created (matching Account 1 schema)
- All tags created
- All 11 workflows built and tested (WF-01 through WF-11)
- Smart lists created
- Team members trained on GHL task queue and stage movement
- n8n routing confirmed: direct leads → Account 2, Account 1 transfers → Account 2
- DNC sync tested bidirectionally
- First batch of leads imported and enrolled in WF-01
- Monitoring dashboard set up (Reporting > Conversations, Tasks, Pipeline)
