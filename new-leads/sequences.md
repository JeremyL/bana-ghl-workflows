# Bana Land — New Leads Account: Follow-Up Sequences

*Last edited: 2026-04-07 · Last reviewed: 2026-04-07*

This is the cadence document for **New Leads**. It defines exactly when to touch a lead,
with which channel, and whether that touch is human-driven or automated.

All rules (time windows, DNC handling, etc.) are governed by [rules.md](rules.md).
All message content lives in [messaging.md](messaging.md).  


### Diagrams

- [Lead Lifecycle Overview](diagrams/bana_land_lead_lifecycle_overview.svg)
- [Day 0–30 Sequence Detail](diagrams/day_0_to_30_sequence_detail.svg)
- [Cold, Nurture & Re-Entry Flows](diagrams/cold_nurture_reentry_flows.svg)

---

## Owner Assignment by Source

All sources follow the same Day 1–30 cadence (same timing, same channels). The only difference is who owns the lead:

| Source Tag             | Owner Assigned At Entry     |
| ---------------------- | --------------------------- |
| `source: cold sms`     | Lead Manager                |
| `source: cold call`    | Lead Manager                |
| `source: direct mail`  | Acquisition Manager (RR)    |
| `source: vapi`         | Acquisition Manager (RR)    |
| `source: referral`     | Acquisition Manager (RR)    |
| `source: website`      | Acquisition Manager (RR)    |

**(RR)** = Round-robin between Jeremy and [AM2], Split Traffic: Equally.

Day 1–30 workflows are fully automated (SMS, Email, RVM) — no manual call tasks. The only task created during this phase is the **WF-Response-Handler review task** when a lead replies, assigned to the Contact Owner via If/Else branch. Automated sends fire identically regardless of source or owner.

---

## Sequence — New Leads (New → LT FU: Cold)

This sequence runs from the moment a lead enters the pipeline until they either qualify,
disqualify themselves, or land in the long-term drip (LT FU: Cold).

### Day 0 — Speed to Lead (New Leads Stage)

**Goal:** Maximize speed to lead. Get a message and call attempt out immediately — before anything else.
**Cadence:** Immediate on entry
**Stage:** New Leads (fires via WF-New-Lead-Entry)


| Touch # | Timing         | Channel | Type   | Message Ref                                      |
| ------- | -------------- | ------- | ------ | ------------------------------------------------ |
| 1       | 120s wait      | SMS     | Auto   | CO-SMS-00 / IN-SMS-00 / DM-SMS-00 (by source)    |
| 2       | After SMS      | Call    | Manual | Call                                             |
| 3       | ~1hr post-call | SMS     | Auto   | CO-SMS-00A / IN-SMS-00A / DM-SMS-00A (by source) |


**Notes:**

- Fires automatically via WF-New-Lead-Entry the moment a lead enters the New Leads stage
- **Day 0 SMS varies by source:** CO-SMS-00/00A for Cold SMS, Cold Call (cold outbound opener). IN-SMS-00/00A for Website, VAPI, Referral (inbound acknowledgment). DM-SMS-00/00A for Direct Mail (letter reference). Rest of Day 1-30 sequence is identical across all sources.
- Speed-to-lead SMS sends immediately — warms the number and signals we're reaching out
- Missed-call SMS fires ~1 hour later only if no call was logged
- Owner works the lead on Day 0 (calls, reviews any reply), then moves stage to Day 1-10 the same day
- After moving to Day 1-10, WF-Day-1-10 fires but waits until the next business day to start automated touches
- If lead responds to any Day 0 touch, the owner sees the reply in GHL conversation (the owner is already working this lead via speed-to-lead). WF-Response-Handler does not fire for New Leads stage — there is no automated drip to pause.
- **Speed-to-lead target: call within 10 minutes.** GHL sends push notification + SMS alert to owner's phone on entry. See rules.md Section 11.

---

### Phase 1 — Day 1-10 Stage (Active Daily Pursuit)

**Goal:** Aggressive, structured daily follow-up for 10 calendar days after Day 0.
**Stage:** Day 1-10
**Workflow:** WF-Day-1-10
**Note:** WF-Day-1-10 waits until the next business day 9:00 AM (contact local time) to start. Day 0 speed-to-lead actions have already fired in the New Leads stage.

#### Days 1-2 (2x per day)


| Touch # | Timing           | Channel | Type   | Message Ref             |
| ------- | ---------------- | ------- | ------ | ----------------------- |
| 1       | Day 1, Morning   | SMS     | Auto   | NL-SMS-01 (First Touch) |
| 2       | Day 1, Afternoon | SMS     | Auto   | NL-SMS-07 (Missed Call) |
| 3       | Day 2, Morning   | Email   | Auto   | NL-EMAIL-01             |
| 4       | Day 2, Afternoon | SMS     | Auto   | NL-SMS-02 (Follow-Up)   |


#### Days 3-10 (1x per day, rotating channels)


| Day | Channel | Type   | Message Ref |
| --- | ------- | ------ | ----------- |
| 3   | SMS     | Auto   | NL-SMS-10   |
| 4   | Email   | Auto   | NL-EMAIL-05 |
| 5   | Email   | Auto   | NL-EMAIL-02 |
| 6   | SMS     | Auto   | NL-SMS-03   |
| 7   | SMS     | Auto   | NL-SMS-08   |


**Notes:**

- Day 1 = first full calendar day after Day 0. Day 2 = second full calendar day.
- NL-SMS-01 fires first on Day 1 morning to continue the outreach rhythm from Day 0
- Days 3-10 rotate channels so the lead isn't getting the same medium daily
- No automated call tasks — owner calls manually as needed based on conversation context
- If lead responds to any touch, WF-Response-Handler fires (pause + owner review)
- After Day 10 with no response: auto-advance to Day 11-30 (within Acquisition pipeline), enroll in WF-Day-11-30

---

### Phase 2 — Day 11-30 Stage (Winding Down)

**Goal:** Maintain presence without overwhelming. Accept lower response rate. Keep the door open.
**Stage:** Day 11-30
**Workflow:** WF-Day-11-30
**Cadence:** Every 2–3 days — 11 touches spread across the 20-day window.


| Touch # | Day (approx) | Channel | Type   | Message Ref             |
| ------- | ------------ | ------- | ------ | ----------------------- |
| 1       | 11           | SMS     | Auto   | NL-SMS-04 (Re-engage)   |
| 2       | 13           | RVM     | Auto   | NL-RVM-01               |
| 3       | 14           | Email   | Auto   | NL-EMAIL-03             |
| 4       | 16           | SMS     | Auto   | NL-SMS-09               |
| 5       | 19           | RVM     | Auto   | NL-RVM-02               |
| 6       | 21           | SMS     | Auto   | NL-SMS-05               |
| 7       | 23           | RVM     | Auto   | NL-RVM-03               |
| 8       | 26           | Email   | Auto   | NL-EMAIL-04 (Long-game) |
| 9       | 27           | SMS     | Auto   | NL-SMS-06 (30-day)      |


**Notes:**

- Touches are spaced via wait steps in WF-Day-11-30 — day numbers are approximate from stage entry
- No automated call tasks — owner calls manually as needed based on conversation context
- **RVM drops** are automated via GHL's ringless voicemail feature — delivered directly to voicemail without ringing. They fill gaps between existing touches to maintain presence without adding more SMS/email
- If lead calls back after an RVM, WF-Response-Handler fires as usual (pause + owner review)
- After Day 30 with no response, lead auto-moves to LT FU: Cold (cross-pipeline) → enters Sequence — Cold
- GHL automation handles cross-pipeline move via WF-Day-11-30 final step

---

## Qualified Leads (01 : Acquisition — Comp through Contract Signed)

These are active deals in the Acquisition pipeline (Comp through Contract Signed). **Fully human-led — no automated workflows.**
AM monitors qualified leads via GHL smart lists. No automated SMS or task generation.

**Cadence:** Every 1-2 days
**Owner:** Acquisition Manager — AM owns all deal stages (Comp through Contract Signed) regardless of original source.


| Stage               | Action                                                                     |
| ------------------- | -------------------------------------------------------------------------- |
| Comp                | Call every 1-2 days to maintain relationship. SMS check-ins. No hard sell. |
| Make Offer          | Call to present offer. Follow up with SMS same day if no answer.           |
| Negotiations        | Call every 1-2 days. SMS "just checking in" between calls.                 |
| Contract Sent       | Call to check on signing. SMS gentle reminders every 1-2 days.             |
| Contract Signed     | Regular deal management calls. SMS for quick updates.                      |


**For LM-sourced leads:** AM's first call on Comp entry is the scheduled appointment set by LM. This is the offer conversation. If the lead misses the appointment, AM owns follow-up from that point.

---

## Sequence — Nurture (LT FU: Nurture — Stalled Qualified Leads)

Qualified leads that didn't close. AM parks the deal in Acquisition: Nurture (trigger stage) → auto-moves to LT FU: Nurture. Fully automated from there. Long game.

**Owner:** GHL automation — no manual call tasks unless lead responds
**Channels:** SMS + Email (rotating).
**Trigger:** WF-Nurture-Monthly fires on LT FU: Nurture stage entry. WF-Long-Term-Quarterly fires after monthly phase completes.

### Nurture Monthly (Months 1–3)

**Cadence:** 30-day wait on entry, then every 30 days
**Workflow:** WF-Nurture-Monthly


| Touch # | Month | Channel | Type | Message Ref  |
| ------- | ----- | ------- | ---- | ------------ |
| 1       | 1     | SMS     | Auto | NUR-SMS-01   |
| 2       | 2     | Email   | Auto | NUR-EMAIL-01 |
| 3       | 3     | SMS     | Auto | NUR-SMS-02   |


At Month 3 → WF-Nurture-Monthly enrolls contact in WF-Long-Term-Quarterly (see **Sequence — Long-Term Quarterly Drip** below). After 24 months of quarterly drip → status changes to Abandoned (`abandoned: exhausted`).

**If lead responds at any point (monthly or quarterly):**

- Immediately pause Nurture automation
- Create manual call task for acquisition manager — high priority
- Move lead to Acquisition: Comp if they want to revisit

---

## Sequence — Cold (LT FU: Cold / Nurture / Lost — Long-Term Drip)

**Applies to:** LT FU: Cold leads (no response after Day 30), LT FU: Nurture leads (stalled deals), and LT FU: Lost leads (non-terminal Lost status)
**Owner:** GHL automation only — no manual call tasks unless lead responds

### Cold Monthly (Months 1–3)

**Goal:** Stay alive in their mind. Rural sellers often take months or years to decide to sell.
**Cadence:** 30-day wait on entry, then SMS + Email each month, spaced ~2 weeks apart
**Workflow:** WF-Cold-Drip-Monthly — fires automatically when contact enters LT FU: Cold, LT FU: Lost, or is enrolled by WF-Dispo-Re-Engage.


| Month | Timing  | Channel | Type | Message Ref   |
| ----- | ------- | ------- | ---- | ------------- |
| 1     | Day 30  | SMS     | Auto | COLD-SMS-01   |
| 1–2   | Day 44  | Email   | Auto | COLD-EMAIL-01 |
| 2     | Day 58  | SMS     | Auto | COLD-SMS-02   |
| 2–3   | Day 72  | Email   | Auto | COLD-EMAIL-02 |
| 3     | Day 86  | SMS     | Auto | COLD-SMS-03   |
| 3–4   | Day 100 | Email   | Auto | COLD-EMAIL-03 |


At ~3.5 months (Day 100) → WF-Cold-Drip-Monthly enrolls contact in WF-Long-Term-Quarterly (shared quarterly phase). After 24 months of quarterly drip → status changes to Abandoned (`abandoned: exhausted`).

---

## Sequence — Long-Term Quarterly Drip (Month 4–28)

**Applies to:** Cold, Nurture, and Lost leads — all feed into this shared quarterly drip after their monthly phase
**Goal:** Extremely light touch. Keep the lead warm with almost zero cost or effort. Cap at 24 months.
**Cadence:** SMS + Email same day, every 90 days
**Workflow:** WF-Long-Term-Quarterly — enrolled from WF-Cold-Drip-Monthly, WF-Nurture-Monthly, or directly
**Owner:** GHL automation only — Q1–Q4 plays twice (24 months), then stops


| Quarter | Channel | Type | Message Ref  |
| ------- | ------- | ---- | ------------ |
| Q1      | SMS     | Auto | LTQ-SMS-01   |
| Q1      | Email   | Auto | LTQ-EMAIL-01 |
| Q2      | SMS     | Auto | LTQ-SMS-02   |
| Q2      | Email   | Auto | LTQ-EMAIL-02 |
| Q3      | SMS     | Auto | LTQ-SMS-03   |
| Q3      | Email   | Auto | LTQ-EMAIL-03 |
| Q4      | SMS     | Auto | LTQ-SMS-04   |
| Q4      | Email   | Auto | LTQ-EMAIL-04 |


4 unique quarters (Q1–Q4), plays twice (Year 1 + Year 2 = 24 months), then workflow ends.

**Notes:**

- After Q4 plays the second time, WF-Long-Term-Quarterly changes the opportunity status to **Abandoned** + adds tag `abandoned: exhausted` — a clear signal that all automated follow-up is complete.
- WF-Response-Handler still catches any future inbound reply from Abandoned (non-DNC) contacts — lead is never truly lost
- If a lead responds at any point (including after moving to Abandoned), standard re-engagement protocol applies — WF-Response-Handler pauses workflows, owner reviews the response and decides next step
- Re-submission via WF-New-Lead-Entry still works from Abandoned (non-DNC) — flip to Open, full restart as a new lead

---

## Lost Status — All Lost Reasons

No Motivation, Wants Retail, On MLS, and Lead Declined all move to **LT FU: Lost** stage and enroll in the same long-term drip as Cold and Nurture leads.

WF-Dispo-Re-Engage fires on status change to Lost (any lost reason), moves the opportunity to LT FU: Lost (cross-pipeline), and enrolls in WF-Cold-Drip-Monthly (monthly first, then WF-Long-Term-Quarterly).

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
| RVM     | GHL automation                 | RVM Action in Workflow   |
| Call    | Manual by owner                | No automated task — owner calls as needed |


---

## Sequence Pause / Stop Triggers


| Event                                   | Action                                                                                                                       |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Lead re-engages (replies to drip)       | WF-Response-Handler: Set `Pause WFs Until` → owner review task → 3-day window. Owner acts or drip auto-resumes.              |
| Lead re-submitted (new external source) | WF-New-Lead-Entry: Stop all drips → tag `re-submitted` → move to New Leads → full restart.                                   |
| Lead says stop / opt-out                | Kill all workflows → status → Abandoned + `abandoned: dnc` → DNC sync to Prospect Data.                                      |
| Lead moves to Comp or later stage    | Stop automated sequence → AM works lead directly (no automated workflow).                                                    |
| AM moves to Acquisition: Nurture     | Trigger stage → auto-move to LT FU: Nurture → start Sequence — Nurture.                                                     |
| Status changed to Abandoned             | Stop all sequences permanently. Tag with `abandoned:` reason.                                                                |
| Status changed to Lost                  | Stop active sequence → WF-Dispo-Re-Engage fires → move to LT FU: Lost → enroll in Sequence — Cold (WF-Cold-Drip-Monthly → WF-Long-Term-Quarterly). |
| 24-month quarterly drip completes        | WF-Long-Term-Quarterly changes status to Abandoned (`abandoned: exhausted`). All automated outreach finished.                 |


---

## Re-Entry Paths

### Re-Engagement (responds to our GHL drip)

A lead in LT FU: Cold, LT FU: Nurture, LT FU: Lost (status = Open), or Abandoned (non-DNC) replies to an automated message we sent (or contacts us inbound). Also applies to leads in Acquisition: Day 1-10 or Day 11-30.

- **What happens:** WF-Response-Handler fires. `Pause WFs Until` field set to today+3 — active workflows hold in place at their next send step (position preserved). Owner gets a 3-day review window.
- **If owner moves to qualified stage** (flips to Open if previously Lost): Workflow exit triggers fire, drip killed. AM works lead directly (no automated workflow).
- **If owner clears `Pause WFs Until` field manually:** Drip resumes from exactly where it stopped.
- **If owner does nothing after 3 days:** `Pause WFs Until` date expires — drip resumes from where it stopped (drip stages and Lost only). For Abandoned contacts, lead simply stays Abandoned.
- **Stage/status does NOT change** during re-engagement review — the lead stays in their current stage/status unless owner explicitly changes it.
- **Active stages (Day 1-10 / Day 11-30):** Same pause mechanic applies — automated sends hold. No 3-day auto-resume for these stages; owner manually clears `Pause WFs Until` field or moves stage.
- **Owner assignment for re-engagement review:** WF-Response-Handler assigns the review task to the Contact Owner via If/Else branch on the Contact Owner field.

### Re-Submission (new external campaign source)

A contact already in GHL is reached by a separate marketing campaign outside GHL and responds.

- **What happens:** automation detects duplicate, updates Latest Source + adds new Source tag + tags `re-submitted` + moves to New Leads.
- **WF-New-Lead-Entry fires:** Cleans up all active drips, preserves existing owner (assignment only fires for unassigned contacts), creates task.
- **Lead is worked from scratch:** Full Day 1-10 → Day 11-30 → Cold sequence, identical to a brand-new lead.
- **Native Opportunity Source preserved:** First-touch attribution never overwritten. Tags stack all sources.

