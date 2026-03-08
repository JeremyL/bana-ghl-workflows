# Bana Land — New Leads Account: Follow-Up Sequences

This is the cadence document for **New Leads**. It defines exactly when to touch a lead,
with which channel, and whether that touch is human-driven or automated.

All rules (time windows, DNC handling, etc.) are governed by [rules.md](rules.md).
All message content lives in [messaging.md](messaging.md).
For the Warm Response account, see [../warm-response/sequences.md](../warm-response/sequences.md).

---

## Sequence — New Leads (New → Cold)

This sequence runs from the moment a lead enters the pipeline until they either qualify,
disqualify themselves, or land in the long-term Cold drip.

### Phase 1 — Day 1-2 Stage (Aggressive Early)

**Goal:** Make first contact as fast as possible while the lead is freshest.
**Cadence:** 2x per day

| Touch # | Timing           | Channel | Type   | Message Ref             |
| ------- | ---------------- | ------- | ------ | ----------------------- |
| 1       | Day 1, Morning   | SMS     | Auto   | NL-SMS-01 (First Touch) |
| 2       | Day 1, Afternoon | Call    | Manual | Call (NEPQ)             |
| 3       | Day 1, Afternoon | SMS     | Auto   | NL-SMS-07 (Missed Call) |
| 4       | Day 2, Morning   | Email   | Auto   | NL-EMAIL-01             |
| 5       | Day 2, Afternoon | Call    | Manual | Call (NEPQ)             |
| 6       | Day 2, Afternoon | SMS     | Auto   | NL-SMS-02 (Follow-Up)   |

**Notes:**

- NL-SMS-01 fires first — before any call — to warm the number and signal we're reaching out
- If lead responds to any touch before the next one, pause the sequence and notify team
- Manual call tasks appear in acquisition manager's GHL task queue

---

### Phase 2 — Day 3-10 (Steady Daily)

**Goal:** Stay top of mind. Rotate channels to avoid fatigue. Don't blow up one channel.
**Cadence:** 1x per day, rotating channels

| Day | Channel | Type   | Message Ref |
| --- | ------- | ------ | ----------- |
| 3   | Call    | Manual | Call (NEPQ) |
| 4   | SMS     | Auto   | NL-SMS-02   |
| 5   | Email   | Auto   | NL-EMAIL-05 |
| 6   | Call    | Manual | Call (NEPQ) |
| 7   | Email   | Auto   | NL-EMAIL-02 |
| 8   | SMS     | Auto   | NL-SMS-03   |
| 9   | Call    | Manual | Call (NEPQ) |
| 10  | SMS     | Auto   | NL-SMS-08   |

**Notes:**

- Rotate channels so the lead isn't getting the same medium daily
- Call tasks always go to acquisition manager
- Email and SMS are fully automated in GHL

---

### Phase 3 — Day 11-30 (Tapering Off)

**Goal:** Maintain presence without overwhelming. Accept lower response rate. Keep the door open.

**Days 11-14 (still in Day 3-14 stage): Every 2-3 days**

| Touch # | Day | Channel | Type   | Message Ref           |
| ------- | --- | ------- | ------ | --------------------- |
| 1       | 11  | SMS     | Auto   | NL-SMS-04 (Re-engage) |
| 2       | 13  | Call    | Manual | Call (NEPQ)           |

**Days 15-30 (Day 15-30 stage): Tuesdays & Thursdays only**

| Touch # | Day    | Channel | Type   | Message Ref             |
| ------- | ------ | ------- | ------ | ----------------------- |
| 3       | 15     | Email   | Auto   | NL-EMAIL-03             |
| 4       | 17     | SMS     | Auto   | NL-SMS-09               |
| 5       | 22     | SMS     | Auto   | NL-SMS-05               |
| 6       | 24     | Call    | Manual | Call (NEPQ)             |
| 7       | 29     | Email   | Auto   | NL-EMAIL-04 (Long-game) |
| 8       | Day 30 | SMS     | Auto   | NL-SMS-06 (30-day)      |

**Notes:**

- Day 15-30 touches fire on Tuesdays and Thursdays only — GHL send windows should enforce this
- After Day 30 with no response, lead moves to Cold stage → enters Sequence — Cold
- GHL automation handles stage advancement via date-elapsed trigger

---

## Sequence — Qualified Leads (Due Diligence → Under Contract)

These are active deals. Outreach is human-led with light automation support.
No heavy automation here — these sellers need to feel cared for, not processed.

**Cadence:** Every 1-2 days
**Owner:** Acquisition manager (manual calls primary)

| Stage          | Action                                                                     |
| -------------- | -------------------------------------------------------------------------- |
| Due Diligence  | Call every 1-2 days to maintain relationship. SMS check-ins. No hard sell. |
| Make Offer     | Call to present offer. Follow up with SMS same day if no answer.           |
| Negotiations   | Call every 1-2 days. SMS "just checking in" between calls.                 |
| Contract Sent  | Call to check on signing. SMS gentle reminders every 1-2 days.             |
| Under Contract | Regular deal management calls. SMS for quick updates.                      |

**GHL Task Setup for Qualified Stages:**

- GHL creates a recurring call task every 1-2 days, assigned to acquisition manager
- Light SMS automation sends a check-in SMS if no call was logged within 48 hours
- All outreach is logged manually in GHL contact notes

---

## Sequence — Nurture (Stalled Qualified Leads)

Qualified leads that didn't close. Fully automated. Long game.

**Owner:** GHL automation — no manual call tasks unless lead responds
**Channels:** SMS + Email (rotating).
**Tags:** `Drip: Nurture Monthly` added on Nurture stage entry (Phase 1). At Month 3, swap to `Drip: Nurture Quarterly` (Phase 2). Tags trigger the workflow — stages add the tags, tags trigger the sequences.

### Phase 1 — Months 0–3 (Monthly)

**Cadence:** Every 30 days

| Touch # | Month | Channel | Type | Message Ref  |
| ------- | ----- | ------- | ---- | ------------ |
| 1       | 0     | SMS     | Auto | NUR-SMS-01   |
| 2       | 1     | Email   | Auto | NUR-EMAIL-01 |
| 3       | 2     | SMS     | Auto | NUR-SMS-02   |

At Month 3 → Remove tag `Drip: Nurture Monthly` → Add tag `Drip: Nurture Quarterly` → transition to Phase 2

### Phase 2 — Month 3+ (Quarterly, indefinite)

**Cadence:** Every 90 days — continues indefinitely until response or opt-out

| Touch # | Month | Channel | Type | Message Ref   |
| ------- | ----- | ------- | ---- | ------------- |
| 4       | 3     | Email   | Auto | NURQ-EMAIL-01 |
| 5       | 6     | SMS     | Auto | NURQ-SMS-01   |
| 6       | 9     | Email   | Auto | NUR-EMAIL-01  |
| 7       | 12    | SMS     | Auto | NURQ-SMS-02   |
| 8       | 15    | SMS     | Auto | NUR-SMS-02    |

Continue rotating SMS/Email every 90 days indefinitely.

**If lead responds at any point:**

- Immediately pause Nurture automation
- Create manual call task for acquisition manager — high priority
- Move lead to Due Diligence if they want to revisit

---

## Sequence — Cold (Long-Term Drip)

**Applies to:** Cold stage leads AND all Dispo Re-Engage leads (No Motivation, Wants Retail, On MLS, Lead Declined)
**Owner:** GHL automation only — no manual call tasks unless lead responds

### Phase 1 — Monthly (Day 30–180)

**Goal:** Stay alive in their mind. Rural sellers often take months or years to decide to sell.
**Cadence:** Monthly (roughly every 30 days)
**Entry tag:** `Drip: Cold Monthly` — added when contact enters Cold stage (or any Dispo Re-Engage stage via WF-09). This tag triggers WF-05 enrollment.

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

**Notes:**

- This sequence runs indefinitely until the lead responds, opts out, or is manually removed
- If a lead responds after 1+ year, treat them as a fresh lead — move to New Leads

---

## Dispo Re-Engage — All Stages

No Motivation, Wants Retail, On MLS, and Lead Declined all enroll in **Sequence — Cold** (same long-term drip as Cold stage leads).

No separate sequence. Enroll by adding tag `Drip: Cold Monthly` when contact is moved to any of these Dispo Re-Engage stages.

---

## Channel Order Logic

When hitting a lead on the same day with multiple channels (Day 1-2 phase), use this order:

1. **SMS first** — lowest friction, seen quickly, doesn't require them to answer
2. **Call second** — personal touch while SMS is fresh in their mind
3. **Email** — supporting channel, good for those who prefer written communication

---

## Automation vs. Manual Summary

| Channel | Who Handles         | GHL Node Type            |
| ------- | ------------------- | ------------------------ |
| SMS     | GHL automation      | SMS Action in Workflow   |
| Email   | GHL automation      | Email Action in Workflow |
| Call    | Acquisition manager | Task Action in Workflow  |

---

## Sequence Pause / Stop Triggers

| Event                                   | Action                                                                         |
| --------------------------------------- | ------------------------------------------------------------------------------ |
| Lead re-engages (replies to drip)       | WF-11: Stop drip → tag `Re-Engaged` → AM review task → 7-day window. AM acts or drip auto-resumes. |
| Lead re-submitted (new external source) | WF-01: Stop all drips → tag `Re-Submitted` → move to New Leads → full restart. |
| Lead says stop / opt-out                | Kill all workflows → move to Dispo: DNC immediately → DNC sync to Warm Response   |
| Lead moves to qualified stage           | Stop uncontacted sequence → start Sequence — Qualified Leads                   |
| Lead moves to Nurture                   | Stop active sequence → start Sequence — Nurture                                |
| Lead moves to Dispo — Terminal          | Stop all sequences permanently                                                 |
| Lead moves to Dispo — Re-Engage         | Stop active sequence → add tag `Drip: Cold Monthly` → enroll in Sequence — Cold |

---

## Re-Entry Paths

### Re-Engagement (responds to our GHL drip)

A lead in Cold, Nurture, or Dispo Re-Engage replies to an automated message we sent.

- **What happens:** WF-11 fires. `Paused` tag added — active workflows hold in place at their next send step (position preserved). AM gets a 7-day review window.
- **If AM moves to qualified stage:** Workflow exit triggers fire, drip killed. Lead enters Sequence — Qualified Leads.
- **If AM clears `Paused` tag manually:** Drip resumes from exactly where it stopped.
- **If AM does nothing after 7 days:** WF-11 auto-removes `Paused` tag — drip resumes from where it stopped. No restart.
- **Pipeline stage does NOT change** during re-engagement review — the lead stays in Cold / Nurture / Dispo Re-Engage unless AM explicitly moves them.
- **Active AM stages (Day 1-2 / Day 3-14 / Day 15-30):** Same pause mechanic applies — automated sends hold. No 7-day auto-resume for these stages; AM manually removes `Paused` tag or moves stage.

### Re-Submission (new external campaign source)

A contact already in GHL is reached by a separate marketing campaign outside GHL and responds.

- **What happens:** n8n detects duplicate, updates Latest Source + adds new Source tag + tags `Re-Submitted` + moves to New Leads.
- **WF-01 fires:** Cleans up all active drips, assigns to AM, creates task.
- **Lead is worked from scratch:** Full Day 1-2 → Day 3-14 → Day 15-30 → Cold sequence, identical to a brand-new lead.
- **Original Source field preserved:** First-touch attribution never overwritten. Tags stack all sources.
- **If contact also exists in Warm Response:** n8n fires cleanup webhook to Warm Response (stop drip, move to Transferred).
