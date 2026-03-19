# Bana Land — New Leads Account: GHL Setup Guide
*Last edited: 2026-03-20 · Last reviewed: —*

This guide walks through building the New Leads GHL sub-account from scratch.
Follow the steps in order — each section depends on the previous one being complete.

This is the single working account for all lead sources. All leads enter here and are worked through close, disqualification, or long-term drip.

Reference files:

- [pipeline.md](pipeline.md) — stage definitions
- [sequences.md](sequences.md) — cadence map
- [messaging.md](messaging.md) — message templates
- [rules.md](rules.md) — compliance rules

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

## Step 2B — Lead Entry Integration (automation / Webhook)

There are three entry paths into this account. Every incoming lead follows exactly one of them.

---

### Entry Path 1 — Direct Entry (All Outbound Campaign Sources)

**Who:** Prospects from any outbound campaign — Cold Email, Cold SMS, Cold Call, Direct Mail.
**Where they land:** New Leads pipeline stage.
**How:** automation pushes the contact into this account when a campaign launches or when a prospect responds to outreach.

**What automation must send to this account:**

| Field                            | Value                                                                 |
| -------------------------------- | --------------------------------------------------------------------- |
| First name, last name            | From campaign data / skip trace                                       |
| Email address                    | From campaign data (required for Cold Email; may be absent for others) |
| All phone numbers (Phone 1–4)    | From skip trace data (may be absent for Cold Email responders)        |
| Tag                              | `Source: Cold Email`, `Source: Cold SMS`, `Source: Cold Call`, or `Source: Direct Mail` |
| Tag (Cold Email/SMS only)        | `Warm: Email` or `Warm: SMS` — historical tracking tag                |
| Custom field: Original Source    | Matching source value (set once, never overwritten)                   |
| Custom field: Latest Source      | Same as Original Source on first entry                                |
| Custom field: Latest Source Date | Today                                                                 |
| Pipeline stage                   | New Leads                                                             |

**Cold Email note:** Cold Email responders may not have a phone number on entry. WF-Cold-Email-Subflow (Cold Email Sub-Flow) runs concurrently to obtain one. See WF-Cold-Email-Subflow below.

---

### Entry Path 2 — Inbound Sources (VAPI, Referral, Website)

**Who:** Leads who came to us — VAPI AI call-ins, referrals, website inquiries.
**Where they land:** New Leads pipeline stage (AM owns from here).
**How:** Entered via automation flow or manual entry. These leads are already considered qualified by virtue of reaching out.

**What must be set on entry:**

| Field                            | Value                                                                 |
| -------------------------------- | --------------------------------------------------------------------- |
| Tag                              | `Source: VAPI AI Call`, `Source: Referral`, or `Source: Website`      |
| Custom field: Original Source    | Matching source value (set once, never overwritten)                   |
| Custom field: Latest Source      | Same as Original Source on first entry                                |
| Custom field: Latest Source Date | Today                                                                 |
| Pipeline stage                   | New Leads                                                             |

**VAPI note:** The `Source: VAPI AI Call` tag is applied automatically by VAPI. The team reviews the call transcript after entry and manually adds any additional context tags. No separate sequence needed — VAPI contacts follow the standard New Leads flow.

---

### Entry Path 3 — Re-Submission (Contact Already Exists — New External Campaign)

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

### Opportunity Creation (Applies to All Entry Paths)

When any new contact enters this account, create an **Opportunity** linked to that contact in the pipeline.

- Populate Opportunity custom fields with available property data (Reference ID, Property County, Property State, Acres, APN, etc.)
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

## Step 4 — Tags to Create

**Tag naming convention:** All tags follow `Category: Value` format with title case. Simple high-priority tags (DNC, Hot) are kept short.

Go to **Settings > Tags** and create these tags:

| Tag Name                | Use                                                                                                                     |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| DNC                     | Do Not Contact — blocks all outreach. Triggers DNC sync to Prospect Data.                                               |
| Hot                     | Team-assigned tag for priority leads (manual).                                                                           |
| Re-Submitted            | Lead came back in from a new external campaign (different source). Resets to New Leads.                                  |
| Warm: Email             | Entered via cold email response — Cold Email sub-flow tracking.                                                          |
| Warm: SMS               | Entered via cold SMS response — historical tracking.                                                                     |
| Cold: Email Only        | Cold Email lead with no confirmed phone number. Email-only Cold drip (WF-Cold-Drip-Monthly/WF-Cold-Drip-Quarterly skip SMS steps).                     |
| Source: Cold Call        | Lead came from cold calling.                                                                                             |
| Source: Cold Email       | Lead came from cold email campaign.                                                                                      |
| Source: Cold SMS         | Lead came from SMS blast campaign.                                                                                       |
| Source: Direct Mail      | Lead came from direct mail.                                                                                              |
| Source: VAPI AI Call     | Lead called Bana Land number; AI agent answered.                                                                         |
| Source: Referral         | Lead came via referral.                                                                                                  |
| Source: Website          | Lead came via website inquiry.                                                                                           |
| Bounced                  | Email address bounced — do not email until corrected.                                                                   |
| Can't Find               | No valid contact info — hold for skip trace.                                                                            |
| Caller: [Agent Name]     | VAPI AI persona that handled the inbound call (auto-applied).                                                           |

---

## Step 5 — Pipeline Setup

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

## Step 6 — Workflows to Build

Build each workflow in **Automation > Workflows**.

### Workflow Index (Quick Reference)

| Code       | Name                                        |
| ---------- | ------------------------------------------- |
| **WF-Cold-Email-Subflow** | Cold Email Sub-Flow (Get Phone Number)      |
| **WF-New-Lead-Entry**  | New Lead Entry                              |
| **WF-Day-1-10**  | Day 1-10 Sequence                           |
| **WF-Day-11-30**  | Day 11-30 Sequence                          |
| **WF-Cold-Drip-Monthly**  | Cold Drip — Monthly (Months 1–3)            |
| **WF-Cold-Drip-Quarterly** | Cold Drip — Quarterly (Month 4+)            |
| **WF-Nurture-Monthly**  | Nurture — Monthly (Months 1–3)              |
| **WF-Nurture-Quarterly** | Nurture — Quarterly (Month 4+)              |
| **WF-Dispo-Re-Engage**  | Dispo Re-Engage — Long-Term Drip Enrollment |
| **WF-DNC-Handler**  | DNC Handler (+ DNC Sync)                   |
| **WF-Response-Handler**  | Inbound Response Handler (Re-Engagement)    |
| **WF-Missed-Call-Textback**  | Missed Call Text-Back                       |

---

### WF-Cold-Email-Subflow | Cold Email Sub-Flow (Get Phone Number)

**Trigger:** Contact moved to pipeline stage "Day 1-10" AND tagged `Source: Cold Email` AND Phone field is empty
**Owner:** Lead Manager (monitors replies)
**Enrollment condition:** Lead NOT tagged DNC

**Purpose:** Runs concurrently with WF-Day-1-10/03. Sends automated emails asking for a phone number. When phone # is received, this workflow exits and the standard Day 1–30 workflows handle everything. While this workflow is active, WF-Day-1-10/03 skip their SMS, call, and email steps for this contact (all three channels suppressed — WF-Cold-Email-Subflow is the sole communicator).

**Actions:**

1. Send Email: WR-EMAIL-01 (ask for phone number)
2. Wait: 2 days
3. **Check: Phone number populated?** If yes → exit workflow (standard WF-Day-1-10/03 steps now fire normally).
4. Send Email: WR-EMAIL-02
5. Wait: 4 days
6. **Check: Phone number populated?** If yes → exit workflow.
7. Send Email: WR-EMAIL-03
8. Wait: 7 days
9. **Check: Phone number populated?** If yes → exit workflow.
10. Send Email: WR-EMAIL-04
11. Wait: 7 days
12. **Check: Phone number populated?** If yes → exit workflow.
13. Send Email: WR-EMAIL-05
14. Wait: 9 days (brings us to approximately Day 30)
15. **Check: Phone number populated?** If yes → exit workflow.

**Day 30 — No Phone Number Received:**

16. **One-time SMS blast to all skip-traced phone numbers on contact (one SMS per number, send only if field is not empty):**
    - Send SMS to Phone 1: WR-COLD-SMS-01
    - Send SMS to Phone 2: WR-COLD-SMS-01 (if Phone 2 is not empty)
    - Send SMS to Phone 3: WR-COLD-SMS-01 (if Phone 3 is not empty)
    - Send SMS to Phone 4: WR-COLD-SMS-01 (if Phone 4 is not empty)
    - **This is a one-time blast only.** No more SMS will be sent in Cold stage for this contact.
17. Add tag: `Cold: Email Only` — flags contact for email-only Cold drip (WF-Cold-Drip-Monthly/WF-Cold-Drip-Quarterly skip SMS steps)
18. Send internal notification to Lead Manager: "{{first_name}} — Cold Email lead moved to Cold after 30 days with no phone number received. One-time SMS blast sent to all skip-traced numbers."

**If any skip-traced number responds to the one-time SMS:**

- WF-Response-Handler fires (Inbound Response Handler) — drip paused, review task created for LM
- If LM connects, LM qualifies and moves to Due Diligence + sets appointment for AM
- `Cold: Email Only` tag can be removed if phone number is now confirmed

**Pause mechanic:** Every email send step has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before it.

**Exit conditions:** Phone number populated (at any check point) OR contact stage changes (moved to any other pipeline stage).

---

### WF-New-Lead-Entry | New Lead Entry

**Trigger:** Contact added to pipeline stage "New Leads"
**Actions:**

1. **If contact is tagged `Re-Submitted` (re-entry from new external campaign):**
   - Remove from all active workflows: WF-Cold-Email-Subflow, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Cold-Drip-Quarterly, WF-Nurture-Monthly, WF-Nurture-Quarterly, WF-Dispo-Re-Engage
   - Clear field: `Pause WFs Until` (if set from a prior cycle)
   - Remove tag: `Re-Submitted` (cleanup — it has served its purpose as a trigger)
2. **Branch on source tag — assign to LM or AM:**
   - **If tagged `Source: Cold Email` OR `Source: Cold SMS` OR `Source: Cold Call`:**
     - Assign contact to Lead Manager (specific team member)
     - Update custom field: Assigned To = Lead Manager name
   - **If tagged `Source: Direct Mail` OR `Source: VAPI AI Call` OR `Source: Referral` OR `Source: Website`:**
     - Assign contact to Acquisition Manager (specific team member)
     - Update custom field: Assigned To = Acquisition Manager name
3. Update custom field: Lead Entry Date = Today (skip if already set — contact may be a re-submission)
4. Update custom field: Original Source (skip if already set — only set on first-ever entry)
5. Update custom field: Latest Source = current source value
6. Update custom field: Latest Source Date = Today
7. Update custom field: Stage Entry Date = Today
8. **Day 0 — Speed to Lead:**
   - **Branch A: If tagged `Source: Cold Email` AND Phone field is empty:**
     - Skip SMS, skip call notifications
     - Send internal notification to Lead Manager: "New Cold Email lead — no phone number on file. WF-Cold-Email-Subflow will run starting at Day 1-10. {{first_name}}"
     - *(WF-Cold-Email-Subflow takes over when owner moves contact to Day 1-10)*
   - **Branch B: Phone present — branch on source for Day 0 SMS:**
     - Send internal notification to assigned owner: "New lead — speed-to-lead touches firing now: {{first_name}} ({{source tag}}). Work the lead, then move to Day 1-10 when done."
     - **Push notification** (GHL mobile app) to assigned owner: "NEW LEAD — {{first_name}} — call NOW"
     - **Internal SMS alert** to assigned owner's personal number: "NEW LEAD — {{first_name}} — call now: {{phone}}"
     - **B1 — Cold outbound (`Source: Cold Email` OR `Source: Cold SMS` OR `Source: Cold Call`):**
       - Send SMS: CO-SMS-00 (Cold Outbound Speed to Lead) — fires after 120-second wait
       - Wait: 1 hour → If no call logged → Send SMS: CO-SMS-00A (Missed Call)
     - **B2 — Inbound (`Source: Website` OR `Source: VAPI AI Call` OR `Source: Referral`):**
       - Send SMS: IN-SMS-00 (Inbound Speed to Lead) — fires after 120-second wait
       - Wait: 1 hour → If no call logged → Send SMS: IN-SMS-00A (Inbound Missed Call)
     - **B3 — Direct Mail (`Source: Direct Mail`):**
       - Send SMS: DM-SMS-00 (Direct Mail Speed to Lead) — fires after 120-second wait
       - Wait: 1 hour → If no call logged → Send SMS: DM-SMS-00A (Direct Mail Missed Call)

**Note:** Day 0 speed-to-lead touches fire automatically on entry. Owner works the lead on Day 0, then manually moves the contact to Day 1-10 the same day — that stage move triggers WF-Day-1-10 (and WF-Cold-Email-Subflow for Cold Email leads with no phone). WF-Day-1-10 waits until the next business day to start automated touches.

---

### WF-Day-1-10 | Day 1-10 Sequence

**Trigger:** Contact moved to pipeline stage "Day 1-10" (owner manually moves from New Leads after Day 0 speed-to-lead work)
**Enrollment condition:** Lead NOT tagged DNC

**Conditional logic:** Each SMS, call, and email step has a condition: **"If contact is enrolled in WF-Cold-Email-Subflow → skip step"**. This ensures Cold Email leads with no phone number only receive WF-Cold-Email-Subflow emails (no double communication). Once WF-Cold-Email-Subflow exits (phone # received), these conditions pass and standard steps fire.

**Actions:**

*Days 1-2 — 2x per day:*

1. Update custom field: Stage Entry Date = Today
2. Wait: until next business day, 9:00 AM contact local time *(Day 0 speed-to-lead touches already fired in WF-New-Lead-Entry)*
3. **[Conditional]** Send SMS: NL-SMS-01 (First Touch)
4. Wait: 4 hours
5. **[Conditional]** Create Task: "Call {{first_name}} — Day 1" — Assigned to: **LM or AM based on source tag** — Due: Today
6. Wait: 4 hours
7. **[Conditional]** Send SMS: NL-SMS-07 (Missed Call Follow-Up)
8. Wait: until next business day, 9:00 AM contact local time
9. **[Conditional]** Send Email: NL-EMAIL-01
10. Wait: 4 hours
11. **[Conditional]** Create Task: "Call {{first_name}} — Day 2" — Assigned to: **LM or AM based on source tag** — Due: Today
12. Wait: 4 hours
13. **[Conditional]** Send SMS: NL-SMS-02

*Days 3-10 — 1x per day, rotating channels:*

14. Wait: until next day, 9:00 AM contact local time
15. **[Conditional]** Create Task: "Call {{first_name}} — Day 3" — Assigned to: **LM or AM** — Due: Today
16. Wait: 1 day
17. **[Conditional]** Send SMS: NL-SMS-02
18. Wait: 1 day
19. **[Conditional]** Send Email: NL-EMAIL-05
20. Wait: 1 day
21. **[Conditional]** Create Task: "Call {{first_name}} — Day 6" — Assigned to: **LM or AM** — Due: Today
22. Wait: 1 day
23. **[Conditional]** Send Email: NL-EMAIL-02
24. Wait: 1 day
25. **[Conditional]** Send SMS: NL-SMS-03
26. Wait: 1 day
27. **[Conditional]** Create Task: "Call {{first_name}} — Day 9" — Assigned to: **LM or AM** — Due: Today
28. Wait: 1 day
29. **[Conditional]** Send SMS: NL-SMS-08
30. Wait: until Day 11 begins
31. If no stage change: Move to Day 11-30 → Enroll in WF-Day-11-30

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Day-11-30 | Day 11-30 Sequence

**Trigger:** Enrolled from WF-Day-1-10 or manually moved to pipeline stage "Day 11-30"
**Enrollment condition:** Lead NOT tagged DNC

**Same conditional logic as WF-Day-1-10:** Steps are skipped while contact is enrolled in WF-Cold-Email-Subflow.

**Important:** All touches in this workflow must respect the 9am–7pm contact local time window.

**Actions:**

1. Update custom field: Stage Entry Date = Today
2. **[Conditional]** Send SMS: NL-SMS-04 (Re-engage)
3. Wait: 2 days
4. **[Conditional]** Create Task: "Call {{first_name}} — Day 13" — Assigned to: **LM or AM** — Due: Today
5. Wait: 1 day
6. **[Conditional]** Send RVM: NL-RVM-01
7. Wait: 1 day
8. **[Conditional]** Send Email: NL-EMAIL-03
9. Wait: 2 days
10. **[Conditional]** Send SMS: NL-SMS-09
11. Wait: 3 days
12. **[Conditional]** Send RVM: NL-RVM-02
13. Wait: 2 days
14. **[Conditional]** Send SMS: NL-SMS-05
15. Wait: 2 days
16. **[Conditional]** Create Task: "Call {{first_name}} — Day 24" — Assigned to: **LM or AM** — Due: Today
17. Wait: 3 days
18. **[Conditional]** Send RVM: NL-RVM-03
19. Wait: 2 days
20. **[Conditional]** Send Email: NL-EMAIL-04 (Long-game)
21. Wait: 1 day
22. **[Conditional]** Send SMS: NL-SMS-06 (Final touch before cold)
23. If no stage change: Move to pipeline stage: Cold (WF-Cold-Drip-Monthly fires automatically on Cold stage entry)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Cold-Drip-Monthly | Cold Drip — Monthly (Months 1–3)

**Trigger:** Contact moved to pipeline stage "Cold" OR enrolled directly by WF-Dispo-Re-Engage (for Dispo Re-Engage leads)
**Applies to:** Cold stage leads (no response after Day 30) AND all Dispo Re-Engage leads
**Enrollment condition:** Lead NOT tagged DNC

**Note — `Cold: Email Only` contacts:** Skip all SMS steps — send email steps only.

**Actions:**

1. **Defensive cleanup:** Remove from WF-Nurture-Monthly, WF-Nurture-Quarterly (prevents dual drip if contact moved from Nurture → Cold)
2. Wait: 30 days
3. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-01
4. Wait: 14 days
5. Send Email: COLD-EMAIL-01
6. Wait: 14 days
7. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-02
8. Wait: 14 days
9. Send Email: COLD-EMAIL-02
10. Wait: 14 days
11. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-03
12. Wait: 14 days
13. Send Email: COLD-EMAIL-03
14. Enroll in WF-Cold-Drip-Quarterly (Cold Drip — Quarterly)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Cold-Drip-Quarterly | Cold Drip — Quarterly (Month 4+)

**Trigger:** Enrolled from WF-Cold-Drip-Monthly (end of monthly phase) OR enrolled directly (to skip monthly phase)
**Applies to:** Same as WF-Cold-Drip-Monthly — Cold stage leads and Dispo Re-Engage leads
**Enrollment condition:** Lead NOT tagged DNC

**Note — `Cold: Email Only` contacts:** Skip all SMS steps — send email steps only.

**Actions — 4 unique quarters, then loops indefinitely:**

1. Wait: 90 days
2. **If NOT tagged `Cold: Email Only`:** Send SMS: COLDQ-SMS-01
3. Send Email: COLDQ-EMAIL-01
4. Wait: 90 days
5. **If NOT tagged `Cold: Email Only`:** Send SMS: COLDQ-SMS-02
6. Send Email: COLDQ-EMAIL-02
7. Wait: 90 days
8. **If NOT tagged `Cold: Email Only`:** Send SMS: COLDQ-SMS-03
9. Send Email: COLDQ-EMAIL-03
10. Wait: 90 days
11. **If NOT tagged `Cold: Email Only`:** Send SMS: COLDQ-SMS-04
12. Send Email: COLDQ-EMAIL-04
13. Enroll in WF-Cold-Drip-Quarterly (re-starts quarterly loop from step 1)

**Note:** Uses native GHL "Add to Workflow" action to re-enroll the contact, creating an indefinite loop. If GHL blocks same-workflow re-enrollment, create WF-Cold-Drip-QuarterlyA (identical steps) and alternate: WF-Cold-Drip-Quarterly ends by enrolling in WF-Cold-Drip-QuarterlyA, WF-Cold-Drip-QuarterlyA ends by enrolling back in WF-Cold-Drip-Quarterly.

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Nurture-Monthly | Nurture — Monthly (Months 1–3)

**Trigger:** Contact moved to Nurture stage
**Enrollment condition:** Lead NOT tagged DNC

**Actions:**

1. **Defensive cleanup:** Remove from WF-Cold-Drip-Monthly, WF-Cold-Drip-Quarterly (prevents dual drip if contact moved from Cold → Nurture)
2. Wait: 30 days
3. Send SMS: NUR-SMS-01
4. Wait: 30 days
5. Send Email: NUR-EMAIL-01
6. Wait: 30 days
7. Send SMS: NUR-SMS-02
8. Enroll in WF-Nurture-Quarterly (Nurture — Quarterly)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Nurture-Quarterly | Nurture — Quarterly (Month 4+)

**Trigger:** Enrolled from WF-Nurture-Monthly (end of monthly phase) OR enrolled directly (to skip monthly phase)
**Enrollment condition:** Lead NOT tagged DNC

**Actions — 4 unique quarters, then loops indefinitely:**

1. Wait: 90 days
2. Send SMS: NURQ-SMS-01
3. Send Email: NURQ-EMAIL-01
4. Wait: 90 days
5. Send SMS: NURQ-SMS-02
6. Send Email: NURQ-EMAIL-02
7. Wait: 90 days
8. Send SMS: NURQ-SMS-03
9. Send Email: NURQ-EMAIL-03
10. Wait: 90 days
11. Send SMS: NURQ-SMS-04
12. Send Email: NURQ-EMAIL-04
13. Enroll in WF-Nurture-Quarterly (re-starts quarterly loop from step 1)

**Note:** Uses native GHL "Add to Workflow" action to re-enroll the contact, creating an indefinite loop. If GHL blocks same-workflow re-enrollment, create WF-Nurture-QuarterlyA (identical steps) and alternate: WF-Nurture-Quarterly ends by enrolling in WF-Nurture-QuarterlyA, WF-Nurture-QuarterlyA ends by enrolling back in WF-Nurture-Quarterly.

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Dispo-Re-Engage | Dispo Re-Engage — Long-Term Drip Enrollment

**Trigger:** Contact moved to any Dispo Re-Engage stage: No Motivation, Wants Retail, On MLS, or Lead Declined
**Actions:**

1. **Defensive cleanup:** Remove from WF-Nurture-Monthly, WF-Nurture-Quarterly (prevents dual drip if contact moved from Nurture → Dispo Re-Engage)
2. Update custom field: Stage Entry Date = Today
3. Enroll in WF-Cold-Drip-Monthly (Cold Drip — Monthly)

That's it. All re-engage dispo leads flow into the same Long-Term Drip as Cold stage leads (WF-Cold-Drip-Monthly monthly, then WF-Cold-Drip-Quarterly quarterly).

---

### WF-DNC-Handler | DNC Handler (+ DNC Sync to Prospect Data)

**Trigger:** Contact moved to Dispo: DNC OR SMS reply contains STOP/QUIT/UNSUBSCRIBE/CANCEL/END
**Actions:**

1. Move to pipeline stage: Dispo: DNC (ensures correct stage regardless of trigger source)
2. Remove from ALL active workflow enrollments (use "Remove from Workflow" action for each active WF: WF-Cold-Email-Subflow, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Cold-Drip-Quarterly, WF-Nurture-Monthly, WF-Nurture-Quarterly, WF-Dispo-Re-Engage)
3. Add tag: DNC
4. Update custom field: DNC Date = Today
5. Cancel all pending tasks for this contact
6. Send internal notification to team: "{{first_name}} has opted out — DNC applied. [Contact Link]"
7. **DNC Sync — Prospect Data:** Fire webhook to automation with contact identifier (email + phone numbers)
   - automation looks up matching Property record in Prospect Data by phone or email
   - If found → set DNC = checked, DNC Date = today, Status = DNC
   - If not found → no action needed
8. End — no further actions ever

---

### WF-Response-Handler | Inbound Response Handler (Re-Engagement)

**Trigger:** Inbound SMS received OR Email reply received
**Stage filter:** Contact is in pipeline stage: Day 1-10, Day 11-30, Cold, Nurture, Dispo: No Motivation, Dispo: Wants Retail, Dispo: On MLS, OR Dispo: Lead Declined
**Enrollment conditions:**
- Lead NOT tagged DNC
- `Pause WFs Until` field is empty OR `Pause WFs Until` < today (prevents re-trigger during an active review window, but allows re-trigger after a prior pause has expired)

**Pause mechanic:** Every drip/automated-send workflow (WF-Cold-Email-Subflow, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Cold-Drip-Quarterly, WF-Nurture-Monthly, WF-Nurture-Quarterly) has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` < today" condition before each send step.

**Actions:**

1. **Check: Is the reply an opt-out keyword?** (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
   - If yes → route to WF-DNC-Handler (DNC Handler). End this workflow.
2. Set custom field: `Pause WFs Until` = today + 7 days — all active automated workflows immediately hold at their next send condition
3. **Branch on source tag — assign review task to original owner:**
   - **If tagged `Source: Cold Email` OR `Source: Cold SMS` OR `Source: Cold Call`:**
     - Create Task: "REVIEW — {{first_name}} replied. Read their reply and decide next step." — Assigned to: Lead Manager — Due: Today — Priority: High
     - Send internal notification to LM: "{{first_name}} replied. Automation paused for 7 days. Review and either move stage or clear the Pause WFs Until field to resume early. [Contact Link]"
   - **If tagged `Source: Direct Mail` OR `Source: VAPI AI Call` OR `Source: Referral` OR `Source: Website`:**
     - Create Task: "REVIEW — {{first_name}} replied. Read their reply and decide next step." — Assigned to: Acquisition Manager — Due: Today — Priority: High
     - Send internal notification to AM: "{{first_name}} replied. Automation paused for 7 days. Review and either move stage or clear the Pause WFs Until field to resume early. [Contact Link]"
4. **Branch — drip stages (Cold / Nurture / Dispo Re-Engage) only:** Wait 7 days (auto-resume safety net)
5. **Branch — check resolution:**
   **Branch A — Owner moved contact to a qualified stage (Due Diligence, Make Offer, etc.):**
   - Workflow exit conditions fire, all active workflows killed automatically
   - Clear field: `Pause WFs Until` (cleanup)
   - End workflow. AM works qualified stages directly (no automated workflow).
   **Branch B — Owner moved contact to any Dispo stage:**
   - Workflow exit conditions fire, all active workflows killed automatically
   - Clear field: `Pause WFs Until` (cleanup)
   - End workflow. Dispo workflows handle it (WF-Dispo-Re-Engage for Re-Engage dispos, WF-DNC-Handler for DNC).
   **Branch C — Owner cleared `Pause WFs Until` field early (reply not actionable, lead stays in stage):**
   - Drip resumes from exactly where it stopped. End workflow.
   **Branch D — Owner did nothing, 7 days expired (drip stages only):**
   - `Pause WFs Until` date has now passed — drip send conditions evaluate to true and resume automatically
   - Clear field: `Pause WFs Until` (cleanup)
   - Send internal notification to owner: "{{first_name}} — 7-day review window expired with no action. Drip resumed automatically."

**Note for active stages (Day 1-10 / Day 11-30):** There is no 7-day auto-resume for these contacts. The owner is already actively working them. Resolution is: owner moves stage (kills workflow) or clears the `Pause WFs Until` field.

**Soft opt-outs:** Replies like "not interested" or "leave me alone" without official opt-out keywords (STOP/CANCEL/etc.) still trigger WF-Response-Handler normally. Owner reviews and decides — may move to DNC or appropriate Dispo based on judgment. See rules.md §6A for guidance.

---

### WF-Missed-Call-Textback | Missed Call Text-Back

**Trigger:** Missed inbound call to Bana Land number
**Enrollment condition:** Caller is a known contact AND NOT tagged DNC

**Purpose:** Automatically texts a lead back when nobody answers their inbound call. Short delay avoids feeling like a bot. No task — the lead's reply shows up in conversation and triggers a notification.

**Actions:**

1. Wait: 2 minutes
2. Send SMS: MC-SMS-01 (Missed Call Auto-Reply)
3. Send internal notification to assigned owner: "Missed call from {{first_name}} — auto-text sent"

**Note:** If the lead replies to the SMS, WF-Response-Handler (Inbound Response Handler) fires as usual — pauses drips and creates a review window.

---

## Step 7 — GHL Smart List Setup

Create these Smart Lists under Contacts for daily team use:

| Smart List Name          | Filter Criteria                                          |
| ------------------------ | -------------------------------------------------------- |
| LM — Today's Call Tasks  | Open tasks, type = Call, due today, assigned to LM       |
| AM — Today's Call Tasks  | Open tasks, type = Call, due today, assigned to AM       |
| Hot Leads                | Tag = Hot                                                |
| Cold — No Response 30d   | Stage = Cold, Last Contact Date > 30 days ago            |
| Cold Email — No Phone    | Tag = Source: Cold Email, Phone field is empty            |
| Active Qualified Leads   | Stage is one of: Due Diligence, Make Offer, Negotiations |
| Contracts in Progress    | Stage is one of: Contract Sent, Under Contract           |
| DNC Contacts             | Tag = DNC                                                |
| Stale New Leads          | Stage = New Leads, Stage Entry Date > 24 hours ago       |

**Stale New Leads — daily notification:** Set up a daily internal notification (9 AM) to the assigned owner for any contacts on the Stale New Leads list. Message: "{{count}} lead(s) still in New Leads for 24+ hours — move to Day 1-10 or take action. [Smart List Link]". This catches leads that didn't get moved to Day 1-10 after Day 0 speed-to-lead.

---

## Step 8 — Compliance Verification Checklist

Before going live, verify:

- SMS opt-out keywords configured (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
- Auto-reply on opt-out is set: "You've been unsubscribed. Reply START to re-subscribe."
- WF-DNC-Handler (DNC Handler) triggers on opt-out SMS reply
- DNC sync webhook to automation tested and confirmed working (New Leads → Prospect Data)
- All workflows have time-window restrictions (9am–7pm contact local time)
- All SMS messages identify sender: include "Bana Land" or agent name
- Phone number has A2P 10DLC registration completed (required for business SMS in US)
- Unsubscribe footer included in all marketing emails
- Task assignment mapped to correct team member(s) — LM for Cold Email/SMS/Call, AM for DM/VAPI/Referral/Website
- WF-Cold-Email-Subflow conditional logic tested: confirms WF-Day-1-10/03 steps are skipped while WF-Cold-Email-Subflow is active
- All workflow enrollments tested with a test contact before live launch

---

## Step 9 — Go-Live Checklist

- All pipeline stages created and in correct order
- All custom fields created
- All tags created
- All 12 workflows built and tested (WF-Cold-Email-Subflow, WF-New-Lead-Entry, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Cold-Drip-Quarterly, WF-Nurture-Monthly, WF-Nurture-Quarterly, WF-Dispo-Re-Engage, WF-DNC-Handler, WF-Response-Handler, WF-Missed-Call-Textback)
- Smart lists created
- Team members trained on GHL task queue and stage movement (LM and AM)
- automation routing confirmed: all campaign types → New Leads
- DNC sync tested (New Leads → Prospect Data)
- Prospect Data push automation tested: field mapping correct, Contact + Opportunity created per property
- Prospect Data DNC sync tested: DNC in New Leads → Property record updated (DNC checked, Status = DNC)
- WF-Cold-Email-Subflow tested end-to-end: email sub-flow, phone # detection, one-time SMS blast, Cold: Email Only tagging
- First batch of leads imported and enrolled in WF-New-Lead-Entry
- Monitoring dashboard set up (Reporting > Conversations, Tasks, Pipeline)
