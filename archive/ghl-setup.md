# Bana Land — Go High Level (GHL) Setup Guide

This guide walks through building the entire Bana Land follow-up system inside GHL from scratch.
Follow the steps in order — each section depends on the previous one being complete.

Reference files:

- [pipeline.md](pipeline.md) — stage definitions
- [sequences.md](sequences.md) — cadence map
- [messaging.md](messaging.md) — message templates
- [rules.md](rules.md) — compliance rules

---

## Step 1 — Sub-Account Setup

1. Log into GHL and create or access the Bana Land sub-account
2. Set the **business name** to: `Bana Land`
3. Set the **time zone** to: `Eastern Time` (default safe zone for compliance)
  - Note: Workflows should use per-contact local time where possible
4. Configure **company phone number** — this will be used for SMS and caller ID
5. Set **reply-to email address** for all outgoing emails

---

## Step 2 — Integrations to Connect

Before building any workflows, connect these services:


| Service        | Purpose                            | GHL Location                              |
| -------------- | ---------------------------------- | ----------------------------------------- |
| SMS Provider   | Outbound/inbound texts             | Settings > Phone Numbers > LC Phone       |
| Email Provider | Outbound emails                    | Settings > Email Services > Mailgun or LC |
| Calendar       | Optional — for appointment setting | Settings > Calendars                      |


---

## Step 2B — Lead Entry Integration (n8n / Webhook)

There are two distinct entry paths into GHL. Every incoming lead follows exactly one of them.

---

### Entry Path 1 — Warm Response (Cold Email & Cold SMS Responders)

**Who:** Prospects who replied "yes" to an outbound cold email or cold SMS campaign managed outside GHL.
**Where they land:** Warm Response pipeline stage (Lead Manager owns from here).
**How:** n8n detects the positive reply and pushes the contact into GHL automatically.

**Flow:**

1. Prospect replies "yes" to cold email or cold SMS (managed outside GHL)
2. n8n detects the reply and pushes the contact into GHL via API/webhook
3. n8n sets the source tag and places the contact in the Warm Response stage
4. GHL triggers WF-00A (email track) or WF-00B (SMS track) based on the tag

**What n8n must send to GHL:**


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


---

### Entry Path 2 — Direct to New Leads (Cold Call, Direct Mail, VAPI)

**Who:** Prospects from cold calling, direct mail, or inbound VAPI calls — anyone who did NOT come through the cold email/SMS Warm Response path.
**Where they land:** New Leads pipeline stage (Acquisition Manager owns from here).
**How:** Entered via a separate n8n flow. These leads skip Warm Response entirely.

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

### Opportunity Creation (Applies to Both Entry Paths)

When any new contact enters GHL, create an **Opportunity** linked to that contact in the pipeline.

- Populate Opportunity custom fields with available property data (Reference ID, Prop County, Prop State, Acres, APN, etc.)
- The Opportunity is what moves through pipeline stages — the Contact record stays static
- A Contact will only ever have one active Opportunity at a time. If an existing contact owns a NEW property (different APN/address), resolve or close the existing Opportunity first, then create a new Opportunity linked to the same Contact

---

### Re-Submission (Contact Already Exists in GHL — New External Campaign)

**Who:** A contact already in GHL (any stage) who responds to a new, separate marketing campaign outside GHL.
**Where they land:** New Leads — full restart as a new lead.

**What n8n must do:**

1. Detect the contact already exists in GHL (duplicate match)
2. Stack a new Source tag on the existing contact (e.g., `Source: Direct Mail` added on top of existing `Source: Cold Call`)
3. Update custom field: Latest Source = new source value
4. Update custom field: Latest Source Date = Today
5. Add tag: `Re-Submitted`
6. Move Opportunity to New Leads (same property) or create a new Opportunity (new property)

**Rules:**

- Do NOT overwrite Original Source — first-touch attribution is permanent
- WF-01 fires automatically on the New Leads stage move → cleans up active drips and creates AM task

---

## Step 3 — Custom Fields

### Data Model: Contacts vs Opportunities

GHL uses two linked record types:

- **Contacts** = people (property owners). One person has one email, one phone number. Personal info lives here.
- **Opportunities** = properties/deals. Each property is a separate opportunity inside the pipeline. Property data, pricing, and deal-specific fields live here.

A Contact will only ever have one active Opportunity at a time. A second could theoretically exist if we purchased a property and later pursued another from the same owner, but this has never happened. Multiple Contacts can be linked to a single Opportunity (e.g., co-owners on one property).

Pipeline stages (New Leads → Day 1-2 → Cold → Due Diligence → etc.) track **Opportunities**, not Contacts. Each pipeline card IS an opportunity.

---

### Multiple Phone Numbers per Contact

GHL contacts support multiple phone numbers natively (added under the contact record as additional phone fields). Skip-trace data can return up to 4 phone numbers per person. Load all available numbers into the contact:

- **Phone** (primary) — first/best skip-traced number
- **Phone 2** — second skip-traced number (if available)
- **Phone 3** — third skip-traced number (if available)
- **Phone 4** — fourth skip-traced number (if available)

GHL workflows can send SMS to each phone field individually using conditional branches (send if field is not empty). This is used in WF-00A's one-time SMS blast for `Cold: Email Only` contacts.

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
| Offer Amount        | Currency   | Amount offered to seller for this property                                                                                                                                                       |
| Contract Date       | Date       | Date contract was signed for this deal                                                                                                                                                           |
| Original Source     | Dropdown   | First channel that brought this lead into GHL. Set once on first entry, never overwritten. Values: Cold Call, Cold Email, Cold SMS, Direct Mail, VAPI AI Call, Launch Control, Referral, Website |
| Latest Source       | Dropdown   | Most recent channel that brought this lead in. Same dropdown values as Original Source. On first entry, set to same value as Original Source. On re-submission, updated to the new source.       |
| Latest Source Date  | Date       | Date the Latest Source field was last updated (first entry or most recent re-submission)                                                                                                         |


---

## Step 4 — Tags to Create

**Tag naming convention:** All tags follow `Category: Value` format with title case (e.g., `Source: Cold Call`, `Drip: Cold Monthly`). Simple high-priority tags (DNC, Hot) are kept short.

---

### Existing Tags from Previous CRM (Reference)

These tags were in the prior CRM. Some carry directly into the new build; others are deprecated or removed.


| Tag Name               | Category     | Count   | Status in New Build                                                                                 |
| ---------------------- | ------------ | ------- | --------------------------------------------------------------------------------------------------- |
| Hot                    | Status       | 5       | **Keep** — same name, same use                                                                      |
| Unsubscribed           | Status       | 6       | **Replace with DNC** — map to Dispo: DNC and DNC tag                                                |
| Bounced                | Data Hygiene | —       | **Keep** — email bounce flag; do not email until corrected                                          |
| Can't Find             | Data Hygiene | —       | **Keep** — no valid contact info; holds for skip trace                                              |
| Import                 | Data Hygiene | 307,385 | **Deprecate** — one-time import tracking; not needed ongoing                                        |
| CorrectingState        | Data Hygiene | 10      | **Deprecate** — data cleanup operation; not ongoing                                                 |
| CorrectingState2       | Data Hygiene | 58,786  | **Deprecate** — data cleanup operation; not ongoing                                                 |
| Double Dial 1-2        | Workflow     | 1       | **Deprecate** — Day 1-2 stage handles this in pipeline                                              |
| Make Offer             | Workflow     | 27      | **Evaluate** — mirrors pipeline stage; may be redundant in new build                                |
| Source: Cold Call      | Source       | 823     | **Keep** — already follows convention                                                               |
| Source: Cold Email     | Source       | 137     | **Keep** — already follows convention                                                               |
| Source: Cold SMS       | Source       | 122     | **Rename to Source: Cold SMS** — aligns with naming convention (all other source tags use "Cold X") |
| Source: Mail           | Source       | 2       | **Rename to Source: Direct Mail** — clarifies channel                                               |
| Source: VAPI AI Call   | Source       | 788     | **Keep** — inbound call to Bana Land number; treated same as Direct Mail                            |
| Source: Launch Control | Source       | 6       | **Keep** — Launch Control platform leads                                                            |
| Source: Referral       | Source       | 1       | **Keep** — already follows convention                                                               |
| Source: Website        | Source       | 3       | **Keep** — already follows convention                                                               |
| Source: Santi          | Source       | 1       | **Evaluate** — referral from specific person; consider merging into Source: Referral                |
| Medium: Phone          | Medium       | 60      | **Keep** — lead responded / came in via phone                                                       |
| Medium: Form Email     | Medium       | 2       | **Keep** — lead came in via email form                                                              |
| Medium: Google Form    | Medium       | 613     | **Keep** — lead came in via Google Form                                                             |
| Medium: Raw Email      | Medium       | 1       | **Keep** — lead replied via direct email                                                            |
| Caller: Chloe          | VAPI Caller  | —       | **Keep if VAPI continues** — AI agent persona that handled the call                                 |
| Caller: Hazel          | VAPI Caller  | —       | **Keep if VAPI continues**                                                                          |
| Caller: Jenny          | VAPI Caller  | —       | **Keep if VAPI continues**                                                                          |
| Caller: John           | VAPI Caller  | —       | **Keep if VAPI continues**                                                                          |
| Caller: Kevin          | VAPI Caller  | —       | **Keep if VAPI continues**                                                                          |
| Caller: Phil           | VAPI Caller  | —       | **Keep if VAPI continues**                                                                          |
| Caller: Sarah          | VAPI Caller  | —       | **Keep if VAPI continues**                                                                          |
| Caller: Sophia         | VAPI Caller  | —       | **Keep if VAPI continues**                                                                          |
| Caller: Taylor         | VAPI Caller  | —       | **Keep if VAPI continues**                                                                          |
| Caller: Unknown        | VAPI Caller  | —       | **Keep if VAPI continues** — call received but persona not identified                               |
| AllValleyFarms         | Brand/Entity | —       | **Deprecate** — owner's separate venture; not part of Bana Land build                               |
| Bana Land Company      | Brand/Entity | —       | **Deprecate** — owner's separate venture; not part of Bana Land build                               |
| BanaLandCompany.com    | Brand/Entity | —       | **Deprecate** — owner's separate venture; not part of Bana Land build                               |


**Notes:**

- **Source: VAPI AI Call** — When a person calls the main Bana Land phone number (from website, direct mail, etc.), a VAPI AI agent answers as an interactive voicemail. The VAPI tag stays on the contact permanently. Team reviews the call transcript and manually adds additional source/context tags as needed. For workflow purposes, treat the same as Direct Mail — contact enters New Leads directly, not Warm Response.
- **Caller: [Name]** — VAPI AI agents operate under named personas (Chloe, Hazel, etc.). These tags are applied automatically by VAPI and track which persona handled each inbound call. Caller: Unknown = persona not identified.
- **Bounced / Can't Find** — Data hygiene tags. Bounced = email address failed delivery. Can't Find = no valid contact info found for the lead.
- **AllValleyFarms / Bana Land Company / BanaLandCompany.com** — Owner's separate ventures. Not part of the Bana Land follow-up system. Do not carry these tags into the new GHL build.

---

### Bana Land Tags — New GHL Build

Go to **Settings > Tags** and create these tags:


| Tag Name                | Use                                                                                                                                                              |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DNC                     | Do Not Contact — blocks all outreach                                                                                                                             |
| Hot                     | Team-assigned tag for priority leads (manual)                                                                                                                    |
| Re-Engaged              | Lead responded to our existing GHL follow-up/drip. Triggers WF-11 (pause + AM review).                                                                           |
| Re-Submitted            | Lead came back in from a new external campaign (different source). Resets to New Leads.                                                                          |
| Warm: Email             | Entered via cold email response — email track in Warm Response                                                                                                   |
| Warm: SMS               | Entered via cold SMS response — SMS track in Warm Response                                                                                                       |
| Drip: Cold Monthly      | Cold stage monthly cadence (WF-05). Added when contact enters Cold stage or Dispo Re-Engage.                                                                     |
| Drip: Cold Quarterly    | Cold stage quarterly cadence (WF-06). Swapped in from `Drip: Cold Monthly` at the 6-month mark.                                                                  |
| Drip: Nurture Monthly   | Nurture monthly cadence (WF-08 Phase 1). Added when contact enters Nurture stage.                                                                                |
| Drip: Nurture Quarterly | Nurture quarterly cadence (WF-08 Phase 2). Swapped in from `Drip: Nurture Monthly` at Month 3.                                                                   |
| Cold: Email Only        | Warm Response email lead moved to Cold with no confirmed phone. Email drip only — one-time SMS already sent to skip-traced numbers. No further SMS in Cold drip. |
| Source: Cold Call       | Lead came from cold calling                                                                                                                                      |
| Source: Cold Email      | Lead came from cold email campaign                                                                                                                               |
| Source: Cold SMS        | Lead came from SMS blast campaign                                                                                                                                |
| Source: Direct Mail     | Lead came from direct mail                                                                                                                                       |
| Source: VAPI AI Call    | Lead called Bana Land number; AI agent answered — treated same as Direct Mail                                                                                    |
| Source: Launch Control  | Lead came from Launch Control platform                                                                                                                           |
| Source: Referral        | Lead came via referral                                                                                                                                           |
| Source: Website         | Lead came via website inquiry                                                                                                                                    |
| Medium: Phone           | Lead responded or came in via phone                                                                                                                              |
| Medium: Form Email      | Lead responded via email form                                                                                                                                    |
| Medium: Google Form     | Lead responded via Google Form                                                                                                                                   |
| Medium: Raw Email       | Lead responded via direct email reply                                                                                                                            |
| Bounced                 | Email address bounced — do not email until corrected                                                                                                             |
| Can't Find              | No valid contact info — hold for skip trace                                                                                                                      |
| Caller: [Agent Name]    | VAPI AI persona that handled the inbound call (auto-applied)                                                                                                     |


---

## Step 5 — Pipeline Setup

Go to **CRM > Pipelines > Add Pipeline** and create: `Bana Land — Seller Pipeline`

Each stage in this pipeline tracks **Opportunities** (properties/deals), not Contacts directly. One Contact (owner) can have multiple Opportunities at different stages. See Step 3 for the full data model explanation.

Add the following stages **in this exact order:**

**Group: Warm Response** *(Lead Manager — cold email/SMS responders, not yet spoken by phone)*

1. Warm Response

**Group: Not Contacted / Not Qualified** *(Acquisition Manager)*

1. New Leads
2. Day 1-2
3. Day 3-14
4. Day 15-30
5. Cold

**Group: Dispo — Terminal** *(no future contact)*
7. Dispo: Not a Fit
8. Dispo: No Longer Own
9. Dispo: Purchased
10. Dispo: DNC

**Group: Dispo — Re-Engage** *(light long-term drip)*
11. Dispo: No Motivation
12. Dispo: Wants Retail
13. Dispo: On MLS
14. Dispo: Lead Declined

**Group: Qualified**
15. Due Diligence
16. Make Offer
17. Negotiations
18. Contract Sent
19. Under Contract
20. Nurture

---

## Step 6 — Workflows to Build

Build each workflow in **Automation > Workflows**. Use the naming convention below.

### Workflow Index (Quick Reference)


| Code       | Name                                        |
| ---------- | ------------------------------------------- |
| **WF-00A** | Warm Response — Email Track                 |
| **WF-00B** | Warm Response — SMS Track                   |
| **WF-01**  | New Lead Entry                              |
| **WF-02**  | Day 1-2 Sequence                            |
| **WF-03**  | Day 3-14 Sequence                           |
| **WF-04**  | Day 15-30 Sequence                          |
| **WF-05**  | Cold Monthly Drip                           |
| **WF-06**  | Cold Quarterly Drip                         |
| **WF-07**  | Qualified Lead Check-In                     |
| **WF-08**  | Nurture                                     |
| **WF-09**  | Dispo Re-Engage — Long-Term Drip Enrollment |
| **WF-10**  | DNC Handler                                 |
| **WF-11**  | Inbound Response Handler (Re-Engagement)    |


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
  - Lead Manager enters phone number into contact record and moves to pipeline stage: New Leads
    - WF-01 fires automatically: assigns to Acquisition Manager, creates review task — no outreach automations fire
    - Lead Manager has no further responsibility for this contact
    - AM reviews, makes one manual contact attempt, then manually moves to Day 1-2 to start WF-02
13. If Day 14 reached with no connection:
  - **One-time SMS blast to all skip-traced phone numbers on contact (one SMS per number, send only if field is not empty):**
    - Send SMS to Phone 1: WR-COLD-SMS-01
    - Send SMS to Phone 2: WR-COLD-SMS-01 (if Phone 2 is not empty)
    - Send SMS to Phone 3: WR-COLD-SMS-01 (if Phone 3 is not empty)
    - Send SMS to Phone 4: WR-COLD-SMS-01 (if Phone 4 is not empty)
  - **This is a one-time blast only.** No more SMS will be sent in Cold stage for this contact.
  - Add tag: `Cold: Email Only` — flags contact for email-only Cold drip (WF-05/WF-06 skip SMS steps)
  - Move to pipeline stage: Cold
  - Add tag: `Drip: Cold Monthly`
  - Enroll in WF-05 (Cold Monthly Drip — email steps only due to `Cold: Email Only` tag)
  - Send internal notification to Lead Manager: "{{first_name}} — warm email responder moved to Cold after 14 days with no phone connection. One-time SMS blast sent to all skip-traced numbers."

**If any skip-traced number responds to the one-time SMS:**

- WF-11 fires (Inbound Response Handler) — drip paused, AM review task created
- If AM confirms number is valid, moves contact to New Leads → full Day 1-2 sequence begins
- `Cold: Email Only` tag can be removed if phone number is now confirmed

**Exit conditions:** Stage changes (phone call completed → moved to New Leads or Dispo)

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
17. Move to pipeline stage: Cold
18. Add tag: `Drip: Cold Monthly` → Enroll in WF-05 (Cold Monthly Drip) — use standard cold messages until warm-specific variants are written
19. Send internal notification to Lead Manager: "{{first_name}} — warm SMS responder moved to Cold after 14 days with no phone connection."

**Exit conditions:** Stage changes (phone call completed → moved to New Leads or Dispo)

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
3. Update custom field: Lead Entry Date = Today (skip if already set — contact may be coming from Warm Response or re-submission)
4. Update custom field: Original Source (skip if already set — only set on first-ever entry)
5. Update custom field: Latest Source = current source value
6. Update custom field: Latest Source Date = Today
7. Update custom field: Stage Entry Date = Today
8. Create Task: "Review new lead — call {{first_name}}" — Assigned to: Acquisition Manager — Due: Today
9. Send internal notification to Acquisition Manager: "New lead ready for review: {{first_name}}. Move to Day 1-2 after initial contact attempt."

**Note:** No outreach automations fire at New Leads. AM reviews the lead, makes one manual contact attempt, then manually moves the contact to Day 1-2 — that stage move triggers WF-02. For re-submitted leads, the process is identical to a brand-new lead — full Day 1-2 sequence from scratch.

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

**Exit conditions:** Contact stage changes (moved to qualified or disqualified stage)

---

### WF-04 | Day 15-30 Sequence

**Trigger:** Enrolled from WF-03 or manually
**Enrollment condition:** Lead NOT tagged DNC

**Important:** All touches in this workflow must be restricted to **Tuesdays and Thursdays only**, within the 9am–7pm contact local time window. Configure GHL send windows accordingly.

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

**Exit conditions:** Contact stage changes (moved to qualified or disqualified stage)

---

### WF-05 | Long-Term Drip — Monthly Phase (Day 30–180)

**Trigger:** Tag added: `Drip: Cold Monthly`
**Applies to:** Cold stage leads (no response after Day 30) AND all Dispo Re-Engage leads (No Motivation, Wants Retail, On MLS, Lead Declined)
**Enrollment condition:** Lead NOT tagged DNC

**Note — `Cold: Email Only` contacts:** Warm Response email-only leads that moved to Cold get this tag. For these contacts, skip all SMS steps below — send email steps only. The one-time SMS blast was already handled by WF-00A.

**Actions:**

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
13. Remove tag: `Drip: Cold Monthly` → Add tag: `Drip: Cold Quarterly` → Enroll WF-06

---

### WF-06 | Long-Term Drip — Quarterly Phase (Day 180+)

**Trigger:** Tag added: `Drip: Cold Quarterly`
**Enrollment condition:** Lead NOT tagged DNC

**Note — `Cold: Email Only` contacts:** Skip SMS steps. Send email only.

**Actions (repeat indefinitely):**

1. Wait: 90 days
2. **If NOT tagged `Cold: Email Only`:** Send SMS: COLDQ-SMS-01
3. Wait: 1 day
4. Send Email: COLDQ-EMAIL-01
5. Go to Step 1 (loop)

**Note:** GHL does not natively loop workflows. Use a recurring enrollment trigger or build out 2+ years of touches manually. Review and re-enroll quarterly if needed.

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

1. Send Email: NURQ-EMAIL-01
2. Wait: 90 days
3. Send SMS: NURQ-SMS-01
4. Wait: 90 days
5. Send Email: NUR-EMAIL-01
6. Wait: 90 days
7. Send SMS: NURQ-SMS-02 (1-year touch)
8. Wait: 90 days
9. Send SMS: NUR-SMS-02
10. Wait: 90 days
11. Go to Step 13 (loop indefinitely at quarterly cadence)

---

### WF-09 | Dispo Re-Engage — Long-Term Drip Enrollment

**Trigger:** Contact moved to any Dispo Re-Engage stage: No Motivation, Wants Retail, On MLS, or Lead Declined
**Actions:**

1. Update custom field: Stage Entry Date = Today
2. Add tag: `Drip: Cold Monthly`
3. Enroll in WF-05 (Long-Term Drip — Monthly Phase)

That's it. All re-engage dispo leads flow into the same Long-Term Drip as Cold stage leads.

---

### WF-10 | DNC Handler

**Trigger:** Contact moved to Dispo: DNC OR SMS reply contains STOP/QUIT/UNSUBSCRIBE/CANCEL/END
**Actions:**

1. Move to pipeline stage: Dispo: DNC (ensures correct stage regardless of trigger source)
2. Remove from ALL active workflow enrollments (use "Remove from Workflow" action for each active WF)
3. Add tag: DNC
4. Update custom field: DNC Date = Today
5. Cancel all pending tasks for this contact
6. Send internal notification to team: "{{first_name}} has opted out — DNC applied. [Contact Link]"
7. End — no further actions ever

---

### WF-11 | Inbound Response Handler (Re-Engagement)

**Trigger:** Inbound SMS received OR Email reply received
**Applies to:** All contacts — drip stages (Cold, Nurture, Dispo Re-Engage) AND active AM stages (Day 1-2, Day 3-14, Day 15-30)
**Enrollment condition:** Lead NOT tagged DNC

**Pause mechanic:** Every drip/automated-send workflow (WF-02 through WF-06, WF-08) has a "Wait Until `Paused` tag is NOT present" gate before each send step. Adding the `Paused` tag holds the contact in place at the next gate — position preserved, no messages sent. Removing the tag lets them continue from exactly where they stopped.

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

**Note for active AM stages (Day 1-2 / Day 3-14 / Day 15-30):** There is no 7-day auto-resume for these contacts. The AM is already actively working them. Resolution is: AM moves stage (kills workflow) or manually removes the `Paused` tag. WF-11 ends after step 5 for these contacts — no wait timer.

---

## Step 7 — GHL Smart List Setup

Create these Smart Lists under Contacts for daily team use:


| Smart List Name        | Filter Criteria                                          |
| ---------------------- | -------------------------------------------------------- |
| Warm Response — Active | Stage = Warm Response                                    |
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
- All workflows have time-window restrictions (9am–7pm contact local time)
- All SMS messages identify sender: include "Bana Land" or agent name
- Phone number has A2P 10DLC registration completed (required for business SMS in US)
- Unsubscribe footer included in all marketing emails
- Task assignment mapped to correct team member(s)
- All workflow enrollments tested with a test contact before live launch

---

## Step 9 — Go-Live Checklist

- All pipeline stages created and in correct order
- All custom fields created
- All tags created
- All 13 workflows built and tested (WF-00A, WF-00B, WF-01 through WF-11)
- Smart lists created
- Team members trained on GHL task queue and stage movement
- First batch of leads imported and enrolled in WF-01
- Monitoring dashboard set up (Reporting > Conversations, Tasks, Pipeline)

