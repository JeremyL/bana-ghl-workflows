# Bana Land — Warm Response Account: Follow-Up Sequences

This is the cadence document for **Account 1 (Warm Response)**. It defines exactly when to touch a lead,
with which channel, and whether that touch is human-driven or automated.

All rules (time windows, DNC handling, etc.) are governed by [rules.md](rules.md).
All message content lives in [messaging.md](messaging.md).
For the New Leads account (Account 2), see [../new-leads/sequences.md](../new-leads/sequences.md).

---

## Sequence — Warm Response (Cold Email & Cold SMS Responders)

**Owner:** Lead Manager (not acquisition manager)
**Goal:** Varies by track. SMS responders: get them on the phone (number already known). Email responders: obtain their phone number — once received, Lead Manager transfers contact to Account 2 for the Acquisition Manager to call.
**Entry:** Prospect replied "yes" to cold email or cold SMS outreach (via n8n webhook into this account).
**Duration:** Up to 14 days. If no phone connection by Day 14 → move to **Cold** stage (within this account).

Two tracks run in parallel based on the source channel, identified by tag.

---

### Track 1 — Email Responder (`tag: Warm: Email`)

The prospect replied "yes" to a cold email. We have their email address but may not have a verified phone number.

**Entry tag:** `Warm: Email` (set by n8n on contact creation)
**Goal:** Collect their phone number via email. Once received, transfer contact to Account 2 — Acquisition Manager makes the call.

| Touch # | Timing            | Channel    | Type   | Message Ref                                          |
| ------- | ----------------- | ---------- | ------ | ---------------------------------------------------- |
| 1       | Immediately       | Email      | Auto   | WR-EMAIL-01 (ask for #)                              |
| 2       | Day 2 (no # yet)  | Email      | Auto   | WR-EMAIL-02 (follow-up)                              |
| 3       | Day 4 (no # yet)  | Email      | Auto   | WR-EMAIL-03 (check-in)                               |
| 4       | Day 7 (no # yet)  | Email      | Auto   | WR-EMAIL-04 (mid-window)                             |
| 5       | Day 10 (no # yet) | Email      | Auto   | WR-EMAIL-05 (soft close)                             |
| —       | When # received   | Stage Move | Manual | → Move to Transferred → WF-HANDOFF → Account 2      |

**Logic:**

- The moment a phone number is received (via email reply), Lead Manager enters the phone number, moves contact to Transferred stage. WF-HANDOFF fires webhook to n8n → Account 2 creates contact in New Leads → WF-01 fires automatically.
- The Lead Manager has no call responsibility for email responders — Acquisition Manager owns the contact from Account 2 onward.
- If no phone number is received by Day 14, move to Cold stage (same exit as no-connection limit reached).

---

### Track 2 — SMS Responder (`tag: Warm: SMS`)

The prospect replied "yes" to a cold SMS. We have their mobile number.

**Entry tag:** `Warm: SMS` (set by n8n on contact creation)
**Goal:** Call the number that texted back. Have a qualifying conversation.

| Touch # | Timing      | Channel | Type   | Message Ref              |
| ------- | ----------- | ------- | ------ | ------------------------ |
| 1       | Immediately | Call    | Manual | Call (Manual — Lead Mgr) |
| 2       | Day 2       | Call    | Manual | Call (Manual — Lead Mgr) |
| 3       | Day 3       | SMS     | Auto   | WR-SMS-01                |
| 4       | Day 3       | Call    | Manual | Call (Manual — Lead Mgr) |
| 5       | Day 5       | SMS     | Auto   | WR-SMS-02                |
| 6       | Day 6       | Call    | Manual | Call (Manual — Lead Mgr) |
| 7       | Day 8       | SMS     | Auto   | WR-SMS-03                |
| 8       | Day 14      | SMS     | Auto   | WR-SMS-04                |

**At Day 14 with no phone connection:**

- Move to **Cold** stage (within this account) → add tag `Drip: Cold Monthly` → enroll in WF-05 (Cold Monthly Drip)
- Tags `Warm: SMS` / `Warm: Email` remain on contact permanently (not removed)

---

### Warm Response — Exit Conditions

| Event                                             | Track      | Action                                                                                      |
| ------------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------- |
| Phone number received via email reply             | Email only | Move to Transferred → WF-HANDOFF → Account 2 New Leads                                     |
| First phone call completes                        | SMS only   | Move to Transferred → WF-HANDOFF → Account 2 New Leads                                     |
| First call — disqualifying info found             | SMS only   | Lead Manager moves to Dispo: DNC (if opt-out) or notes it and transfers to Account 2 anyway |
| No # received / no phone connection after 14 days | Both       | Move to **Cold** stage → add tag `Drip: Cold Monthly` → enroll in Cold cadence              |
| Any opt-out request (email or SMS)                | Both       | Move to Dispo: DNC immediately → DNC sync to Account 2                                      |

---

## Sequence — Cold (Long-Term Drip — Account 1)

**Applies to:** Warm Response leads that timed out after 14 days with no phone connection
**Owner:** GHL automation only — no manual call tasks unless lead re-engages
**Templates:** Same COLD-* templates as Account 2 (can be customized later if warm-specific messaging is desired)

**Two tracks run in parallel based on tag:**

| Track        | Tag                         | SMS                                        | Email                              |
| ------------ | --------------------------- | ------------------------------------------ | ---------------------------------- |
| Standard     | *(no `Cold: Email Only`)*   | Monthly/Quarterly per cadence              | Monthly/Quarterly per cadence      |
| Email Only   | `Cold: Email Only`          | **None** — one-time blast already sent     | Monthly/Quarterly per cadence      |

`Cold: Email Only` contacts are Warm Response email-only leads that hit Day 14 with no confirmed phone connection. WF-00A sends a one-time SMS to all skip-traced numbers at Cold entry. WF-05/WF-06 then skip all SMS steps for these contacts and send email only.

### Phase 1 — Monthly (Day 0–180 in Cold)

**Goal:** Stay alive in their mind. Rural sellers often take months or years to decide to sell.
**Cadence:** Monthly (roughly every 30 days)
**Entry tag:** `Drip: Cold Monthly` — added when contact enters Cold stage. This tag triggers WF-05 enrollment.

| Month | Channel | Type | Message Ref           |
| ----- | ------- | ---- | --------------------- |
| 1     | SMS     | Auto | COLD-SMS-01           |
| 2     | Email   | Auto | COLD-EMAIL-01         |
| 3     | SMS     | Auto | COLD-SMS-04           |
| 4     | SMS     | Auto | COLD-SMS-02           |
| 5     | Email   | Auto | COLD-EMAIL-02         |
| 6     | SMS     | Auto | COLD-SMS-03 (6-month) |

At 6 months → Remove tag `Drip: Cold Monthly` → Add tag `Drip: Cold Quarterly` → transition to Phase 2 (WF-06)

---

### Phase 2 — Quarterly (Day 180+)

**Goal:** Extremely light touch. Keep the lead warm with almost zero cost or effort.
**Cadence:** Quarterly (every 90 days)
**Owner:** GHL automation only — indefinite until response or opt-out
**Tag:** `Drip: Cold Quarterly` — swapped in from `Drip: Cold Monthly` at the 6-month mark. Triggers WF-06 enrollment.

| Quarter | Channel | Type | Message Ref    |
| ------- | ------- | ---- | -------------- |
| Q1      | SMS     | Auto | COLDQ-SMS-01   |
| Q1      | Email   | Auto | COLDQ-EMAIL-01 |
| Q2      | SMS     | Auto | COLDQ-SMS-01   |
| Q2      | Email   | Auto | COLDQ-EMAIL-01 |

Continue rotating SMS/Email every 90 days indefinitely.

---

## Sequence Pause / Stop Triggers

| Event                                   | Action                                                                                   |
| --------------------------------------- | ---------------------------------------------------------------------------------------- |
| Lead re-engages (replies to drip)       | WF-11: pause drip → Lead Manager reviews, tries to connect → transfer or resume          |
| Lead re-submitted (new external source) | n8n cleanup webhook: stop drip, move to terminal stage. n8n sends contact to Account 2.  |
| Lead says stop / opt-out                | Kill all workflows → move to Dispo: DNC → DNC sync to Account 2                         |

---

## Re-Entry Paths

### Re-Engagement (responds to our Account 1 drip)

A lead in Cold responds to an automated message we sent from this account.

- **What happens:** WF-11 fires. `Paused` tag added — active workflows hold in place at their next send step (position preserved). Call task created for Lead Manager.
- **Lead Manager tries to connect.** If successful → move to Transferred → WF-HANDOFF → Account 2 New Leads.
- **If not actionable:** Lead Manager removes `Paused` tag → drip resumes from exactly where it stopped.
- **If no action after 7 days:** Auto-remove `Paused` tag → drip resumes automatically.

### Re-Submission (new external campaign source)

A contact already in this account is reached by a separate marketing campaign outside GHL and responds.

- **What happens:** n8n sends contact to Account 2 as a new lead (always). n8n also fires cleanup webhook to Account 1: stop all drips, move contact to a terminal stage.
- **Account 2's WF-01 fires:** Assigns to AM, creates task. Lead is worked from scratch.

---

## Automation vs. Manual Summary

| Channel | Who Handles    | GHL Node Type            |
| ------- | -------------- | ------------------------ |
| SMS     | GHL automation | SMS Action in Workflow   |
| Email   | GHL automation | Email Action in Workflow |
| Call    | Lead Manager   | Task Action in Workflow  |
