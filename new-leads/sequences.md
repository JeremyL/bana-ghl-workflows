# Bana Land — New Leads Account: Follow-Up Sequences
*Last edited: 2026-03-18 · Last reviewed: —*

This is the cadence document for **New Leads**. It defines exactly when to touch a lead,
with which channel, and whether that touch is human-driven or automated.

All rules (time windows, DNC handling, etc.) are governed by [rules.md](rules.md).
All message content lives in [messaging.md](messaging.md).

### Diagrams

- [Lead Lifecycle Overview](diagrams/bana_land_lead_lifecycle_overview.svg)
- [Day 0–30 Sequence Detail](diagrams/day_0_to_30_sequence_detail.svg)
- [Cold, Nurture & Re-Entry Flows](diagrams/cold_nurture_reentry_flows.svg)

---

## Task Assignment by Source

All sources follow the same Day 1–30 cadence (same timing, same channels). The only difference is who call tasks are assigned to:


| Source Tag             | Call Tasks Assigned To |
| ---------------------- | ---------------------- |
| `Source: Cold Email`   | Lead Manager           |
| `Source: Cold SMS`     | Lead Manager           |
| `Source: Cold Call`    | Lead Manager           |
| `Source: Direct Mail`  | Acquisition Manager    |
| `Source: VAPI AI Call` | Acquisition Manager    |
| `Source: Referral`     | Acquisition Manager    |
| `Source: Website`      | Acquisition Manager    |


GHL workflows branch on source tag at each call task creation step to assign to the correct team member. Automated SMS and email steps fire identically regardless of source.

---

## Sequence — New Leads (New → Cold)

This sequence runs from the moment a lead enters the pipeline until they either qualify,
disqualify themselves, or land in the long-term Cold drip.

**Exception — Cold Email leads with no phone number:** SMS and call steps are skipped until a phone number is received. The Cold Email Sub-Flow (below) runs concurrently to obtain the phone number. Once received, the full cadence applies from the lead's current stage position.

### Day 0 — Speed to Lead (New Leads Stage)

**Goal:** Maximize speed to lead. Get a message and call attempt out immediately — before anything else.
**Cadence:** Immediate on entry
**Stage:** New Leads (fires via WF-01)


| Touch # | Timing         | Channel | Type   | Message Ref               |
| ------- | -------------- | ------- | ------ | ------------------------- |
| 1       | Immediate      | SMS     | Auto   | NL-SMS-00 (Speed to Lead) |
| 2       | Immediate      | Call    | Manual | Call                      |
| 3       | ~1hr post-call | SMS     | Auto   | NL-SMS-00A (Missed Call)  |


**Notes:**

- Fires automatically via WF-01 the moment a lead enters the New Leads stage
- NL-SMS-00 sends before the call task — warms the number and signals we're reaching out
- Missed-call SMS (NL-SMS-00A) fires ~1 hour later only if no call was logged
- Owner works the lead on Day 0 (calls, reviews any reply), then moves stage to Day 1-10 the same day
- After moving to Day 1-10, WF-02 fires but waits until the next business day to start automated touches
- If lead responds to any Day 0 touch, WF-11 fires (pause + owner review)
- **Speed-to-lead target: call within 5 minutes.** GHL sends push notification + SMS alert to owner's phone on entry. See rules.md Section 11.

---

### Phase 1 — Day 1-10 Stage (Active Daily Pursuit)

**Goal:** Aggressive, structured daily follow-up for 10 calendar days after Day 0.
**Stage:** Day 1-10
**Workflow:** WF-02
**Note:** WF-02 waits until the next business day 9:00 AM (contact local time) to start. Day 0 speed-to-lead actions have already fired in the New Leads stage.

#### Days 1-2 (2x per day)


| Touch # | Timing           | Channel | Type   | Message Ref             |
| ------- | ---------------- | ------- | ------ | ----------------------- |
| 1       | Day 1, Morning   | SMS     | Auto   | NL-SMS-01 (First Touch) |
| 2       | Day 1, Afternoon | Call    | Manual | Call                    |
| 3       | Day 1, Afternoon | SMS     | Auto   | NL-SMS-07 (Missed Call) |
| 4       | Day 2, Morning   | Email   | Auto   | NL-EMAIL-01             |
| 5       | Day 2, Afternoon | Call    | Manual | Call                    |
| 6       | Day 2, Afternoon | SMS     | Auto   | NL-SMS-02 (Follow-Up)   |


#### Days 3-10 (1x per day, rotating channels)


| Day | Channel | Type   | Message Ref |
| --- | ------- | ------ | ----------- |
| 3   | Call    | Manual | Call        |
| 4   | SMS     | Auto   | NL-SMS-02   |
| 5   | Email   | Auto   | NL-EMAIL-05 |
| 6   | Call    | Manual | Call        |
| 7   | Email   | Auto   | NL-EMAIL-02 |
| 8   | SMS     | Auto   | NL-SMS-03   |
| 9   | Call    | Manual | Call        |
| 10  | SMS     | Auto   | NL-SMS-08   |


**Notes:**

- Day 1 = first full calendar day after Day 0. Day 2 = second full calendar day.
- NL-SMS-01 fires first on Day 1 morning — before any call — to continue the outreach rhythm from Day 0
- Days 3-10 rotate channels so the lead isn't getting the same medium daily
- **Voicemail combo:** When a manual call goes to voicemail, leave script NL-VM-01 then immediately send NL-VMSMS-01 (combo SMS) via GHL conversation
- If lead responds to any touch, WF-11 fires (pause + owner review)
- Manual call tasks appear in LM or AM's GHL task queue based on source tag
- After Day 10 with no response: auto-advance to Day 11-30, enroll in WF-03

---

### Phase 2 — Day 11-30 Stage (Winding Down)

**Goal:** Maintain presence without overwhelming. Accept lower response rate. Keep the door open.
**Stage:** Day 11-30
**Workflow:** WF-03
**Cadence:** Every 2–3 days — 11 touches spread across the 20-day window.


| Touch # | Day (approx) | Channel | Type   | Message Ref             |
| ------- | ------------ | ------- | ------ | ----------------------- |
| 1       | 11           | SMS     | Auto   | NL-SMS-04 (Re-engage)   |
| 2       | 13           | Call    | Manual | Call                    |
| 3       | 14           | RVM     | Auto   | NL-RVM-01               |
| 4       | 15           | Email   | Auto   | NL-EMAIL-03             |
| 5       | 17           | SMS     | Auto   | NL-SMS-09               |
| 6       | 20           | RVM     | Auto   | NL-RVM-02               |
| 7       | 22           | SMS     | Auto   | NL-SMS-05               |
| 8       | 24           | Call    | Manual | Call                    |
| 9       | 27           | RVM     | Auto   | NL-RVM-03               |
| 10      | 29           | Email   | Auto   | NL-EMAIL-04 (Long-game) |
| 11      | 30           | SMS     | Auto   | NL-SMS-06 (30-day)      |


**Notes:**

- Touches are spaced via wait steps in WF-03 — day numbers are approximate from stage entry
- **Voicemail combo:** When a manual call goes to voicemail, leave script NL-VM-02 then immediately send NL-VMSMS-01 (combo SMS) via GHL conversation
- **RVM drops** are automated via GHL's ringless voicemail feature — delivered directly to voicemail without ringing. They fill gaps between existing touches to maintain presence without adding more SMS/email
- If lead calls back after an RVM, WF-11 fires as usual (pause + owner review)
- After Day 30 with no response, lead moves to Cold stage → enters Sequence — Cold
- GHL automation handles stage advancement via WF-03 final step

---

## Cold Email Sub-Flow (Concurrent with Day 1–30)

Cold Email leads may not have a phone number on entry. This sub-flow runs in parallel with the standard Day 1–30 sequence to obtain one. Managed by WF-00A.

**When this sub-flow is active (no phone #):** The standard Day 1–30 sequence skips ALL steps for this contact — SMS, call, and email are all suppressed. WF-00A is the sole communicator until a phone number is received or Day 30 is reached. This avoids sending conflicting messages from two workflows simultaneously.

**When phone # is received:** Sub-flow stops. Standard Day 1–30 sequence resumes fully (calls, SMS, and emails all fire from the lead's current stage position). LM call tasks begin.

### Phase 1 — Get Phone Number (automated emails)


| Touch # | Timing | Channel | Type | Message Ref              |
| ------- | ------ | ------- | ---- | ------------------------ |
| 1       | Day 1  | Email   | Auto | WR-EMAIL-01 (ask for #)  |
| 2       | Day 3  | Email   | Auto | WR-EMAIL-02 (follow-up)  |
| 3       | Day 7  | Email   | Auto | WR-EMAIL-03 (check-in)   |
| 4       | Day 14 | Email   | Auto | WR-EMAIL-04 (mid-window) |
| 5       | Day 21 | Email   | Auto | WR-EMAIL-05 (soft close) |


**Notes:**

- These emails specifically ask for a phone number — they are different from the standard NL-EMAIL templates
- LM monitors replies for phone numbers
- If phone # received at any point → sub-flow exits, standard cadence resumes in full

### Phase 2 — Day 30, No Phone Number Received

If no phone number is received by Day 30:

1. **One-time SMS blast** to all skip-traced phone numbers on file (Phone 1–4, if populated) using template WR-COLD-SMS-01
2. Add tag: `Cold: Email Only` — flags contact for email-only Cold drip (WF-05/WF-05Q skip SMS steps)
3. Move to Cold stage (WF-05 fires automatically on Cold stage entry)

If any skip-traced number responds to the one-time SMS blast, WF-11 fires and LM reviews.

---

## Qualified Leads (Due Diligence → Under Contract)

These are active deals. **Fully human-led — no automated workflows.**
AM monitors qualified leads via GHL smart lists. No automated SMS or task generation.

**Cadence:** Every 1-2 days
**Owner:** Acquisition Manager — AM owns all qualified stages regardless of original source.

| Stage          | Action                                                                     |
| -------------- | -------------------------------------------------------------------------- |
| Due Diligence  | Call every 1-2 days to maintain relationship. SMS check-ins. No hard sell. |
| Make Offer     | Call to present offer. Follow up with SMS same day if no answer.           |
| Negotiations   | Call every 1-2 days. SMS "just checking in" between calls.                 |
| Contract Sent  | Call to check on signing. SMS gentle reminders every 1-2 days.             |
| Under Contract | Regular deal management calls. SMS for quick updates.                      |

**For LM-sourced leads:** AM's first call on Due Diligence entry is the scheduled appointment set by LM. This is the offer conversation. If the lead misses the appointment, AM owns follow-up from that point.

---

## Sequence — Nurture (Stalled Qualified Leads)

Qualified leads that didn't close. Fully automated. Long game.

**Owner:** GHL automation — no manual call tasks unless lead responds
**Channels:** SMS + Email (rotating).
**Trigger:** WF-08 fires on Nurture stage entry. WF-08Q fires after monthly phase completes (or directly to skip monthly).

### Phase 1 — Months 1–3 (Monthly)

**Cadence:** 30-day wait on entry, then every 30 days
**Workflow:** WF-08


| Touch # | Month | Channel | Type | Message Ref  |
| ------- | ----- | ------- | ---- | ------------ |
| 1       | 1     | SMS     | Auto | NUR-SMS-01   |
| 2       | 2     | Email   | Auto | NUR-EMAIL-01 |
| 3       | 3     | SMS     | Auto | NUR-SMS-02   |


At Month 3 → WF-08 enrolls contact in WF-08Q (quarterly phase)

### Phase 2 — Month 4+ (Quarterly, indefinite)

**Cadence:** SMS + Email same day, every 90 days — continues indefinitely until response or opt-out
**Workflow:** WF-08Q


| Quarter | Channel | Type | Message Ref    |
| ------- | ------- | ---- | -------------- |
| Q1      | SMS     | Auto | NURQ-SMS-01    |
| Q1      | Email   | Auto | NURQ-EMAIL-01  |
| Q2      | SMS     | Auto | NURQ-SMS-02    |
| Q2      | Email   | Auto | NURQ-EMAIL-02  |
| Q3      | SMS     | Auto | NURQ-SMS-03    |
| Q3      | Email   | Auto | NURQ-EMAIL-03  |
| Q4      | SMS     | Auto | NURQ-SMS-04    |
| Q4      | Email   | Auto | NURQ-EMAIL-04  |


4 unique quarters (Q1–Q4), then WF-08Q loops indefinitely.

**If lead responds at any point:**

- Immediately pause Nurture automation
- Create manual call task for acquisition manager — high priority
- Move lead to Due Diligence if they want to revisit

---

## Sequence — Cold (Long-Term Drip)

**Applies to:** Cold stage leads AND all Dispo Re-Engage leads (No Motivation, Wants Retail, On MLS, Lead Declined)
**Owner:** GHL automation only — no manual call tasks unless lead responds

### Phase 1 — Monthly (Months 1–3)

**Goal:** Stay alive in their mind. Rural sellers often take months or years to decide to sell.
**Cadence:** 30-day wait on entry, then SMS + Email each month, spaced ~2 weeks apart
**Workflow:** WF-05 — fires automatically when contact enters Cold stage (or any Dispo Re-Engage stage via WF-09).


| Month   | Timing         | Channel | Type | Message Ref   |
| ------- | -------------- | ------- | ---- | ------------- |
| 1       | Day 30         | SMS     | Auto | COLD-SMS-01   |
| 1–2     | Day 44         | Email   | Auto | COLD-EMAIL-01 |
| 2       | Day 58         | SMS     | Auto | COLD-SMS-02   |
| 2–3     | Day 72         | Email   | Auto | COLD-EMAIL-02 |
| 3       | Day 86         | SMS     | Auto | COLD-SMS-03   |
| 3–4     | Day 100        | Email   | Auto | COLD-EMAIL-03 |


At ~3.5 months (Day 100) → WF-05 enrolls contact in WF-05Q (quarterly phase)

**Note:** `Cold: Email Only` contacts (Cold Email leads with no confirmed phone number) receive email steps only — all SMS steps are skipped (in both WF-05 and WF-05Q).

---

### Phase 2 — Quarterly (Month 4+)

**Goal:** Extremely light touch. Keep the lead warm with almost zero cost or effort.
**Cadence:** SMS + Email same day, every 90 days
**Workflow:** WF-05Q — enrolled from WF-05 after monthly phase, or directly to skip monthly
**Owner:** GHL automation only — indefinite until response or opt-out


| Quarter | Channel | Type | Message Ref    |
| ------- | ------- | ---- | -------------- |
| Q1      | SMS     | Auto | COLDQ-SMS-01   |
| Q1      | Email   | Auto | COLDQ-EMAIL-01 |
| Q2      | SMS     | Auto | COLDQ-SMS-02   |
| Q2      | Email   | Auto | COLDQ-EMAIL-02 |
| Q3      | SMS     | Auto | COLDQ-SMS-03   |
| Q3      | Email   | Auto | COLDQ-EMAIL-03 |
| Q4      | SMS     | Auto | COLDQ-SMS-04   |
| Q4      | Email   | Auto | COLDQ-EMAIL-04 |


4 unique quarters (Q1–Q4), then WF-05Q loops indefinitely.

**Notes:**

- This sequence runs indefinitely until the lead responds, opts out, or is manually removed
- If a lead responds at any point (including after 1+ year), standard re-engagement protocol applies — WF-11 pauses workflows, owner reviews the response and decides next step

---

## Dispo Re-Engage — All Stages

No Motivation, Wants Retail, On MLS, and Lead Declined all enroll in **Sequence — Cold** (same long-term drip as Cold stage leads).

No separate sequence. WF-09 fires on Dispo Re-Engage stage entry and enrolls the contact in WF-05 (monthly first, then WF-05Q quarterly).

---

## Channel Order Logic

When hitting a lead on the same day with multiple channels (Days 1-2 of Day 1-10 stage), use this order:

1. **SMS first** — lowest friction, seen quickly, doesn't require them to answer
2. **Call second** — personal touch while SMS is fresh in their mind
3. **Email** — supporting channel, good for those who prefer written communication

---

## Automation vs. Manual Summary


| Channel | Who Handles                    | GHL Node Type            |
| ------- | ------------------------------ | ------------------------ |
| SMS     | GHL automation                 | SMS Action in Workflow   |
| Email   | GHL automation                 | Email Action in Workflow |
| Call    | LM or AM (based on source tag) | Task Action in Workflow  |
| RVM     | GHL automation                 | RVM Action in Workflow   |


---

## Sequence Pause / Stop Triggers


| Event                                   | Action                                                                                                   |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| Lead re-engages (replies to drip)       | WF-11: Set `Pause WFs Until` → owner review task → 7-day window. Owner acts or drip auto-resumes. |
| Lead re-submitted (new external source) | WF-01: Stop all drips → tag `Re-Submitted` → move to New Leads → full restart.                           |
| Lead says stop / opt-out                | Kill all workflows → move to Dispo: DNC immediately → DNC sync to Prospect Data.                         |
| Lead moves to qualified stage           | Stop uncontacted sequence → AM works lead directly (no automated workflow).                               |
| Lead moves to Nurture                   | Stop active sequence → start Sequence — Nurture.                                                         |
| Lead moves to Dispo — Terminal          | Stop all sequences permanently.                                                                          |
| Lead moves to Dispo — Re-Engage         | Stop active sequence → WF-09 fires → enroll in Sequence — Cold (WF-05 → WF-05Q).                         |


---

## Re-Entry Paths

### Re-Engagement (responds to our GHL drip)

A lead in Cold, Nurture, or Dispo Re-Engage replies to an automated message we sent.

- **What happens:** WF-11 fires. `Pause WFs Until` field set to today+7 — active workflows hold in place at their next send step (position preserved). Owner gets a 7-day review window.
- **If owner moves to qualified stage:** Workflow exit triggers fire, drip killed. AM works lead directly (no automated workflow).
- **If owner clears `Pause WFs Until` field manually:** Drip resumes from exactly where it stopped.
- **If owner does nothing after 7 days:** `Pause WFs Until` date expires — drip resumes from where it stopped. No restart.
- **Pipeline stage does NOT change** during re-engagement review — the lead stays in Cold / Nurture / Dispo Re-Engage unless owner explicitly moves them.
- **Active stages (Day 1-10 / Day 11-30):** Same pause mechanic applies — automated sends hold. No 7-day auto-resume for these stages; owner manually clears `Pause WFs Until` field or moves stage.
- **Owner assignment for re-engagement review:** WF-11 assigns the review task to the original owner based on source tag (LM for Cold Email/SMS/Call sources, AM for Direct Mail/VAPI/Referral/Website sources).

### Re-Submission (new external campaign source)

A contact already in GHL is reached by a separate marketing campaign outside GHL and responds.

- **What happens:** automation detects duplicate, updates Latest Source + adds new Source tag + tags `Re-Submitted` + moves to New Leads.
- **WF-01 fires:** Cleans up all active drips, assigns to owner based on new source tag, creates task.
- **Lead is worked from scratch:** Full Day 1-10 → Day 11-30 → Cold sequence, identical to a brand-new lead.
- **Original Source field preserved:** First-touch attribution never overwritten. Tags stack all sources.

