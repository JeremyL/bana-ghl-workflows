# Bana Land — New Leads Account: Pipeline Definitions

*Last edited: 2026-04-21 · Last reviewed: 2026-04-07*

Pipeline reference for **New Leads** — the single working account for all lead sources. Five pipelines organize the full lifecycle from entry through close or long-term follow-up:

1. **01 : Acquisition** — automated lead follow-up (Day 0–30) + manual deal-making (qualification through close)
2. **02 : Due Diligence** — post-contract, pre-close (TBD stages)
3. **03 : Value Add** — pre-close, complex deals with property improvements (TBD stages)
4. **04 : Long Term FU** — long-term drip for unresponsive, stalled, or lost leads
5. **05 : Disposition** — selling properties Bana Land has already purchased (TBD stages)

Opportunities move between pipelines as they progress. Acquisition stages New Leads through Day 11-30 are mostly automated; Comp through Contract Signed are human-driven. Due Diligence, Value Add, and Disposition are fully manual. Long Term FU is fully automated drip.

---

## Data Model

- **Contacts** = people (property owners). Personal info, phone, email.
- **Opportunities** = properties/deals. Each property is a separate opportunity in the pipeline. Property data (county, acreage, APN, pricing) and source tracking (native Source, Latest Source, Latest Source Date) live on the Opportunity.

Pipeline stages track **Opportunities**, not Contacts. Each card in the pipeline IS an opportunity. A Contact will only ever have one active Opportunity at a time. Multiple Contacts can be linked to a single Opportunity (e.g., co-owners on one property).

See [data-model.md](data-model.md) for the full custom field definitions.

---

## Team Roles

| Role                    | Sources Owned (Day 1–30)                     | Responsibility                                                                                                                                                                                                   |
| ----------------------- | -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Lead Manager**        | Cold SMS, Cold Call                           | Owns the full 30-day pre-qualification follow-up for these two sources. All calling, all SMS/email touches. The LM's first successful phone conversation IS the qualifying call (interest, motivation, asking price). When qualified → LM moves to Acquisition: Comp and sets a call appointment for AM. |
| **Acquisition Manager** | Direct Mail, VAPI, Referral, Website | For these sources: owns full lifecycle from Day 1 through close (fact-finding first call + offer second call). For LM-sourced leads: receives qualified leads via appointment, makes the offer call. If lead misses AM's appointment call, AM owns follow-up from that point. |

---

## How Source Determines Owner (Day 1–30)

Same Acquisition pipeline stages, different owner assignment based on Latest Source field. AM-sourced leads round-robin between 2 AMs. No automated call tasks in Day 1–30 workflows — the only task created is the WF-Response-Handler review task (assigned to Contact Owner via If/Else branch).

| Latest Source          | Day 1–30 Owner             | Qualifying Call By | After Qualification                       |
| ---------------------- | -------------------------- | ------------------ | ----------------------------------------- |
| Cold SMS               | Lead Manager               | LM                 | LM sets appointment → AM makes offer call |
| Cold Call              | Lead Manager               | LM                 | LM sets appointment → AM makes offer call |
| Direct Mail            | Acquisition Manager (RR)   | AM                 | AM continues through close                |
| VAPI                   | Acquisition Manager (RR)   | AM                 | AM continues through close                |
| Referral               | Acquisition Manager (RR)   | AM                 | AM continues through close                |
| Website                | Acquisition Manager (RR)   | AM                 | AM continues through close                |

**(RR)** = Round-robin between Jeremy and [AM2], Split Traffic: Equally. Assignment only fires for unassigned contacts — re-submitted leads keep their existing owner.

**LM → AM Handoff:** When LM qualifies a lead (confirms interest, motivation, asking price), LM moves the opportunity to Acquisition: Comp and sets a call appointment for AM. AM calls the lead for the offer conversation. If the lead misses the appointment, AM owns follow-up from that point forward.

**AM-sourced leads:** Already considered qualified (the person came to us). AM handles fact-finding on the first call and presents an offer on the second call. Full multi-call lifecycle unchanged.

---

## 01 : Acquisition

9 stages. Automated lead follow-up (New Leads through Day 11-30) + manual deal-making (Comp through Contract Signed). Nurture is a trigger stage. LM or AM owns based on Latest Source field.

All leads enter this pipeline at New Leads. If no response by end of Day 11-30, the opportunity auto-moves to 04 : Long Term FU (Cold stage). Qualified leads progress through Comp → Contract Signed within the same pipeline.

---

### New Leads

| Field          | Detail                                                                                           |
| -------------- | ------------------------------------------------------------------------------------------------ |
| **Definition** | Lead assigned to LM or AM (round-robin for AMs) based on Latest Source field. **Day 0 speed-to-lead touches fire here** via WF-New-Lead-Entry. |
| **Entry**      | All sources: Cold SMS, Cold Call, Direct Mail, VAPI, Referral, Website, re-submission. |
| **Exit**       | Owner works Day 0 speed-to-lead (immediate SMS + call + missed-call SMS), then manually moves to Day 1-10 the same day. |
| **Owner**      | LM (Cold SMS/Call) or AM round-robin (Direct Mail/VAPI/Referral/Website) — assigned on entry via WF-New-Lead-Entry. Re-submitted leads keep existing owner. |
| **Actions**    | WF-New-Lead-Entry branches on Latest Source field: assigns to LM or AM (round-robin for AMs, unassigned contacts only), fires Day 0 speed-to-lead (CO-SMS-00 + call task + CO-SMS-00A if no call logged), sends notification to owner. |

---

### Day 1-10

| Field          | Detail                                                                                                                            |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Definition** | Contact has been attempted on Day 0. Active daily pursuit across ten full calendar days.                                          |
| **Entry**      | Owner completes Day 0 speed-to-lead work → manual move by lead owner (LM or AM). WF-Day-1-10 waits until next business day to start.   |
| **Exit**       | Lead responds and qualifies → Acquisition: Comp (intra-pipeline move). No response by Day 11 → Day 11-30. Disqualifying info → Lost (with reason). |
| **Owner**      | Contact Owner (LM or AM assigned at entry) + GHL automation (SMS, Email).                                                         |
| **Frequency**  | Days 1–2: 2x per day (morning + afternoon). Days 3–10: 1x per day. Day 1 = first full calendar day after Day 0.                  |
| **Channels**   | SMS, Email (automated). Calls manual by owner as needed.                                                                          |
| **Actions**    | Rotating automated SMS/Email. No manual call tasks — if lead responds, WF-Response-Handler creates a review task for Contact Owner. |

---

### Day 11-30

| Field          | Detail                                                                                              |
| -------------- | --------------------------------------------------------------------------------------------------- |
| **Definition** | Contact attempted for 10+ days without qualification. Winding down — reduced frequency.             |
| **Entry**      | No meaningful response by end of Day 10. Auto-advanced from Day 1-10.                                |
| **Exit**       | Lead responds and qualifies → Acquisition: Comp (intra-pipeline move). Day 30 passes with no response → 04 : LT FU: Cold (auto-move, cross-pipeline). Disqualifying info → Lost (with reason). |
| **Owner**      | Contact Owner (LM or AM assigned at entry) + GHL automation.                                         |
| **Frequency**  | Every 2–3 days (9 touches across 20-day window).                                                     |
| **Channels**   | SMS, Email, RVM (automated). Calls manual by owner as needed.                                        |
| **Actions**    | Rotating automated messages (SMS, Email, RVM). No manual call tasks — if lead responds, WF-Response-Handler creates a review task for Contact Owner. |

---

### Comp

| Field          | Detail                                                                                         |
| -------------- | ---------------------------------------------------------------------------------------------- |
| **Definition** | Lead is qualified. Team is researching the property and preparing an offer. **AM owns all stages from Comp through Contract Signed.** |
| **Entry**      | **LM-sourced:** LM qualifies lead (interest, motivation, asking price confirmed), moves opportunity to Acquisition: Comp, sets call appointment for AM. **AM-sourced:** AM qualifies lead during fact-finding call, moves within Acquisition. |
| **Exit**       | Research complete → Make Offer.                                                                 |
| **Owner**      | Acquisition Manager (human-led, every 1–2 days).                                               |
| **Channels**   | Calls primarily. SMS check-ins.                                                                 |
| **Actions**    | Internal research tasks + seller relationship maintenance calls. For LM-sourced: AM's first call is the scheduled appointment (offer conversation). |

---

### Make Offer

| Field          | Detail                                                                                 |
| -------------- | -------------------------------------------------------------------------------------- |
| **Definition** | Research and pricing complete. Team is ready to present an offer to the seller.         |
| **Entry**      | Comps/pricing finished, offer calculated.                                               |
| **Exit**       | Offer accepted → Contract Sent. Offer countered → Negotiations. Offer rejected → Lost or Acquisition: Nurture (trigger → LT FU). |
| **Owner**      | Acquisition Manager.                                                                    |
| **Channels**   | Call (present offer verbally first).                                                    |
| **Actions**    | Call task to present offer. SMS follow-up if no answer.                                 |

---

### Negotiations

| Field          | Detail                                                                             |
| -------------- | ---------------------------------------------------------------------------------- |
| **Definition** | An offer was made but not accepted. Both parties are working toward a number.      |
| **Entry**      | Seller countered or asked for time to think.                                        |
| **Exit**       | Agreement reached → Contract Sent. No agreement → Lost (Lead Declined) or Acquisition: Nurture (trigger → LT FU). |
| **Owner**      | Acquisition Manager (active back-and-forth).                                        |
| **Channels**   | Calls. SMS for quick follow-ups.                                                    |
| **Frequency**  | Every 1–2 days while negotiating.                                                   |
| **Actions**    | Call every 1-2 days. SMS for quick follow-ups between calls.                        |

---

### Contract Sent

| Field          | Detail                                                                                          |
| -------------- | ----------------------------------------------------------------------------------------------- |
| **Definition** | Seller agreed to the price. A purchase contract has been sent for signature.                    |
| **Entry**      | Verbal agreement reached, contract delivered (email, DocuSign, physical mail).                   |
| **Exit**       | Contract signed → Contract Signed. Seller backs out → Lost (Lead Declined) or Negotiations. |
| **Owner**      | Acquisition Manager.                                                                             |
| **Channels**   | Calls + SMS.                                                                                     |
| **Frequency**  | Every 1–2 days until signed.                                                                     |
| **Actions**    | Follow up on signing status. Address objections. Urgency without pressure.                       |

---

### Contract Signed

| Field          | Detail                                                                            |
| -------------- | --------------------------------------------------------------------------------- |
| **Definition** | Contract is signed. Property is under contract with Bana Land.                    |
| **Entry**      | Executed contract received.                                                        |
| **Exit**       | Simple deal → Due Diligence (pipeline 02). Complex deal → Value Add (pipeline 03). Deal closes → Won. Deal falls through → Lost (with reason) or Acquisition: Nurture (trigger → LT FU). |
| **Owner**      | Acquisition Manager + transaction coordinator (if applicable).                     |
| **Channels**   | Calls + SMS (deal management, not follow-up).                                      |
| **Actions**    | Manage transaction timeline. Keep seller informed. Coordinate closing.             |

---

### Nurture (trigger stage)

| Field          | Detail                                                                                                            |
| -------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Definition** | Qualified lead that couldn't be closed. AM parks the deal here — **immediately auto-moves to LT FU: Nurture**.    |
| **Entry**      | AM moves deal from any Acquisition stage (Comp through Contract Signed) when it stalls (team discretion — not every dead deal uses this). |
| **Exit**       | Auto-move to 04 : Long Term FU (Nurture stage) on entry. This is a trigger stage, not a resting stage.            |
| **Owner**      | N/A — opportunity passes through immediately.                                                                      |
| **Actions**    | Stage-entry trigger fires automation to move opportunity to LT FU: Nurture (cross-pipeline).                       |

---

## 02 : Due Diligence (TBD)

Post-contract, pre-close pipeline. Standard closing process — title work, surveys, closing coordination.

Stages TBD. Fully manual. Not relevant to automated workflows.

---

## 03 : Value Add (TBD)

Pre-close pipeline for complex deals where Bana does value-add work on the property (not a simple flip). The deal's complexity warrants its own pipeline and tracking.

Stages TBD. Fully manual. Not relevant to automated workflows.

---

## 04 : Long Term FU

3 stages. Automated long-term drip for leads that didn't convert during active follow-up. All drip is automated — no manual tasks unless a lead re-engages.

---

### Cold

| Field             | Detail                                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | 30+ days of contact attempts with no response or qualification. Never had a real conversation.                        |
| **Entry**         | Auto-move from Acquisition: Day 11-30 when sequence completes with no response. |
| **Exit**          | Lead responds → WF-Response-Handler (owner reviews). Lead opts out → Lost (DNC). 24-month quarterly drip completes → Lost (Exhausted). |
| **Re-Engagement** | Lead replies to drip → WF-Response-Handler: pause drip, Contact Owner reviews. 3-day auto-resume if no action. |
| **Re-Submission** | Lead enters from new external campaign → WF-New-Lead-Entry: stop drip, move to Acquisition: New Leads, full restart.       |
| **Owner**         | GHL automation only (no manual call tasks unless lead re-engages).                                                     |
| **Frequency**     | Months 1–3: Monthly (SMS + Email each month). Month 4+: Quarterly.                                                    |
| **Channels**      | SMS + Email (monthly → quarterly).                                                                                      |
| **Actions**       | Automated drip only. If lead responds, WF-Response-Handler fires.                                                      |

---

### Nurture

| Field             | Detail                                                                                                                           |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | Qualified deal that stalled. Had real conversations but couldn't close.                                                          |
| **Entry**         | Auto-move from Acquisition: Nurture (trigger stage).                                                                           |
| **Exit**          | Lead re-engages → WF-Response-Handler (AM reviews). Lead opts out → Lost (DNC). 24-month quarterly drip completes → Lost (Exhausted). |
| **Re-Engagement** | Lead replies to nurture drip → WF-Response-Handler: pause drip, AM 3-day review. AM acts → appropriate Acquisition stage or Lost. AM does nothing → drip resumes. |
| **Re-Submission** | Lead enters from new external campaign → WF-New-Lead-Entry: stop drip, move to Acquisition: New Leads, full restart.                   |
| **Owner**         | GHL automation (full automation — no manual tasks unless response received).                                                      |
| **Frequency**     | Monthly for first 3 months → quarterly thereafter.                                                                                |
| **Channels**      | SMS + Email (rotating).                                                                                                           |
| **Actions**       | Automated "checking in" messages. If response received, WF-Response-Handler fires.                                                |

---

### Lost

| Field             | Detail                                                                                                                           |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | Lead was manually marked Lost with a Drip lost reason. Had a conversation, didn't convert. Re-engageable via 24-month drip.     |
| **Entry**         | Status changed to Lost (any pipeline) → WF-Dispo-Re-Engage fires → moves opportunity to LT FU: Lost.                            |
| **Exit**          | Lead re-engages → WF-Response-Handler (owner reviews). Lead opts out → Lost (DNC). 24-month quarterly drip completes → Lost (Exhausted). |
| **Re-Engagement** | Lead replies to long-term drip → WF-Response-Handler: pause drip, owner 3-day review. Owner flips to Open + moves to appropriate stage, or drip resumes. |
| **Re-Submission** | Lead enters from new external campaign → WF-New-Lead-Entry: clear lost reason, flip status to Open, move to Acquisition: New Leads, full restart. |
| **Owner**         | GHL automation (full automation — no manual tasks unless response received).                                                      |
| **Frequency**     | Monthly for first 3 months → quarterly thereafter.                                                                                |
| **Channels**      | SMS + Email (rotating).                                                                                                           |
| **Actions**       | Automated drip via WF-Dispo-Re-Engage enrollment → WF-Nurture-Monthly (shared with LT FU: Nurture) → WF-Long-Term-Quarterly. Softer cadence than Cold — Lost leads gave a reason, so they're warmer than never-responded Cold. If response received, WF-Response-Handler fires. |

---

## 05 : Disposition (TBD)

Post-acquisition sales pipeline. Selling properties Bana Land has already purchased. This pipeline tracks the sell-side of the business — all prior pipelines track the buy-side (acquiring properties from motivated sellers).

Entry: After Won status / post-close from Due Diligence or Value Add. Stages TBD. Fully manual. Not relevant to automated lead follow-up workflows.

---

## Opportunity Statuses

GHL has four fixed opportunity statuses (Open, Won, Lost, Abandoned) but this system only uses **Open, Won, and Lost.** Abandoned is never used — WF-Abandoned-Alert fires an internal notification if anyone sets it accidentally. We use statuses + lost reasons for deal outcomes instead of cluttering pipelines with disposition stages.

**Who can dispo:** Both LM and AM can change a lead's status to Lost (any reason). LM can dispo leads directly during the Day 1–30 window without passing to AM first.

---

### Open

All pipeline stages across all 5 pipelines use **Open** status. Any opportunity actively being worked — from New Leads through Contract Signed, plus all Long Term FU drip stages — stays Open.

---

### Won

| Field          | Detail                                                      |
| -------------- | ----------------------------------------------------------- |
| **Definition** | Bana Land successfully purchased / closed on this property. |
| **Entry**      | Deal closed and funded. Change status → Won.                |
| **Follow-Up**  | None.                                                        |

---

### Lost (+ Lost Reason)

All deal outcomes that aren't Won use Lost status with a Lost Reason. The **Lost Reason** determines follow-up behavior. WF-Dispo-Re-Engage triggers on any status change to Lost but branches on Lost Reason — only Drip reasons enroll in the long-term drip.

#### Drip Reasons — 24-month long-term drip

| Lost Reason       | Definition                                                     | Entry Criteria                                      |
| ----------------- | -------------------------------------------------------------- | --------------------------------------------------- |
| **No Motivation** | Owner has no reason or urgency to sell at this time.           | Conversation confirms owner is not motivated.        |
| **Wants Retail**  | Owner wants full market value or has unrealistic expectations. | Price discussion reveals retail expectations.        |
| **On MLS**        | Property is listed with a realtor or on the open market.      | Confirmed listed status.                             |
| **Lead Declined** | Lead received an offer from Bana Land and declined.           | Offer rejected / negotiations ended.                 |

**Follow-Up:** Status change to Lost → WF-Dispo-Re-Engage (If/Else: Drip reason) → moves to LT FU: Lost stage → enrolls in Long-Term Drip (monthly → quarterly, 24-month cap). After 24 months → Lost (Exhausted).

**Re-entry paths:**

- **Re-Engagement** (responds to our drip) → WF-Response-Handler: pause drip, owner reviews. Owner acts or drip auto-resumes after 3 days. If owner moves back to active stage, status flips to Open.
- **Re-Submission** (new external campaign) → WF-New-Lead-Entry: clear lost reason, flip status to Open, move to Acquisition: New Leads, full restart.

#### No-Drip Reasons — no further outreach

| Lost Reason       | Definition                                                         | Entry Criteria                                                    |
| ----------------- | ------------------------------------------------------------------ | ----------------------------------------------------------------- |
| **Not a Fit**     | Property or owner characteristics make this a non-starter.         | Team determines property/owner doesn't meet criteria.             |
| **No Longer Own** | Lead has already sold the property.                                | Confirmed property transfer.                                      |
| **Exhausted**     | Completed 24-month drip cycle with no conversion.                  | WF-Long-Term-Quarterly final step fires automatically.            |

**Follow-Up:** None. WF-Dispo-Re-Engage fires but the If/Else branch sees a No-Drip reason and exits immediately.

**Re-entry paths:**

- **Re-Submission** → WF-New-Lead-Entry: clear lost reason, flip status to Open, move to Acquisition: New Leads, full restart.
- **Re-Engagement** (inbound reply) → WF-Response-Handler: owner 3-day review (no drip to resume). Owner flips to Open + moves to appropriate stage, or lead stays Lost.

#### DNC — permanent, zero contact

| Lost Reason | Definition                                  | Entry Criteria                                                    |
| ----------- | ------------------------------------------- | ----------------------------------------------------------------- |
| **DNC**     | Lead explicitly requested no contact.       | Lead says "stop calling," "remove me," or similar. **Permanent.** |

**Follow-Up:** None. WF-DNC-Handler sets Lost + DNC reason, `dnc` Contact tag, DND all channels, and fires sync webhook → Prospect Data marks DNC on Property record. TCPA — highest priority, immediate full stop.

**Re-entry paths:**

- **Re-Submission** → **Blocked.** DNC is permanent. No restart.

---

## Cross-Pipeline Movement Summary

| Trigger | From | To | Mechanism |
|---|---|---|---|
| Lead qualifies | Acquisition: Day 1-10 or Day 11-30 | Acquisition: Comp | Manual move by LM or AM (intra-pipeline) |
| Day 11-30 sequence completes, no response | Acquisition: Day 11-30 | LT FU: Cold | WF-Day-11-30 (auto-move at end of sequence) |
| AM parks stalled deal | Acquisition: Nurture (trigger) | LT FU: Nurture | Auto-move on stage entry |
| Status changed to Lost | Any pipeline | LT FU: Lost | WF-Dispo-Re-Engage |
| Contract signed, simple deal | Acquisition: Contract Signed | Due Diligence (pipeline 02) | Manual move |
| Contract signed, complex deal | Acquisition: Contract Signed | Value Add (pipeline 03) | Manual move |
| Re-engagement from LT FU | LT FU: any stage | Human decides | WF-Response-Handler (pause + review task) |
| Re-submission (new campaign) | Any pipeline/status | Acquisition: New Leads | WF-New-Lead-Entry |
| Deal closes (Won) | Due Diligence / Value Add | Disposition (pipeline 05) | Manual move |
| DNC | Any pipeline | No move — status change to Lost (DNC) | WF-DNC-Handler |

---

## Stage Transition Quick Reference

```
[ALL SOURCES: Cold SMS / Cold Call / Direct Mail / VAPI / Referral / Website / Re-Submission]

=== 01 : ACQUISITION ===

  └─► NEW LEADS (LM for Cold SMS/Call, AM round-robin for Direct Mail/VAPI/Referral/Website)
        │   Day 0: Speed to Lead — immediate SMS + call task + missed-call SMS (WF-New-Lead-Entry)
        └─► Day 1-10 (2x daily Days 1-2, 1x daily Days 3-10)
              └─► Qualifies ──────────────────────────────────► Comp (intra-pipeline)
              └─► No response by Day 11 ──────────────────────► Day 11-30 (every 2–3 days)
                    └─► Qualifies ────────────────────────────► Comp (intra-pipeline)
                    └─► No response by Day 30 ────────────────► [04 : LT FU] Cold (auto-move)

--- QUALIFICATION HANDOFF (within Acquisition) ---

LM qualifies lead (Cold SMS/Call sources)
  └─► LM moves to Comp + sets call appointment for AM
        └─► AM calls lead (offer conversation)
              └─► Lead misses appointment → AM owns follow-up from here

AM qualifies lead (Direct Mail/VAPI/Referral/Website sources)
  └─► AM moves to Comp → continues through close

--- DEAL STAGES (AM owns all — Comp through Contract Signed) ---

Comp ──► Make Offer ──► Negotiations ──► Contract Sent ──► Contract Signed
              │               │                │                  │
              └──► Lost /     └──► Lost /      └──► Lost /        └──► [02 : Due Diligence] or
                   Negotiations     Nurture         Nurture /          [03 : Value Add] or
                   / Nurture                        Negotiations       Won / Lost / Nurture

  Nurture (trigger stage) ──► immediately moves to [04 : LT FU] Nurture

=== 02 : DUE DILIGENCE (manual, TBD stages) ===

  Post-contract, pre-close. Standard closing process. ──► Won or Lost

=== 03 : VALUE ADD (manual, TBD stages) ===

  Pre-close, complex deal with property improvements. ──► Won or Lost

=== 04 : LONG TERM FU (automated drip) ===

  Cold (from Acquisition — never had conversation)    ─┐
  Nurture (from Acquisition — deal stalled)         ├──► Monthly → Quarterly drip (24-month cap)
  Lost (Drip reasons only)                             ─┘

  Re-engages ──► WF-Response-Handler → owner 3-day review → appropriate stage or drip resumes
  24 months complete ──► Lost (Exhausted) — no further outreach

=== 05 : DISPOSITION (manual, TBD stages) ===

  Post-acquisition sales. Selling properties Bana Land has already purchased.

=== LOST — DRIP REASONS (status change from any pipeline) ===

Status → Lost (No Motivation / Wants Retail / On MLS / Lead Declined)
  └─► WF-Dispo-Re-Engage (Drip branch) ──► [04 : LT FU] Lost ──► 24-month drip ──► Lost (Exhausted)

=== LOST — NO-DRIP REASONS ===

Status → Lost (Not a Fit / No Longer Own / Exhausted)
  └─► WF-Dispo-Re-Engage fires but exits immediately (No-Drip branch). No outreach. Re-submission allowed.

=== LOST — DNC ===

Status → Lost (DNC)
  └─► WF-DNC-Handler: DND all channels, `dnc` tag, sync to Prospect Data. Zero contact. Re-submission blocked.

=== RE-ENTRY PATHS ===

LT FU: any stage (replies to drip — status is Open)
  └─► WF-Response-Handler: Pause WFs Until set → owner 3-day review
        └─► Owner moves to active stage ───────────────────────► Appropriate pipeline/stage
        └─► Owner marks Lost (with reason) ────────────────────► Stays in LT FU: Lost
        └─► Owner does nothing (3 days expire) ────────────────► Drip resumes

Lost — Drip reason (replies to long-term drip)
  └─► WF-Response-Handler: Pause WFs Until set → owner 3-day review
        └─► Owner flips to Open + moves to stage ─────────────► Appropriate pipeline/stage
        └─► Owner does nothing (3 days expire) ────────────────► Drip resumes

Lost — No-Drip reason (replies inbound — non-DNC only)
  └─► WF-Response-Handler: owner 3-day review (no drip to resume)
        └─► Owner flips to Open + moves to stage ─────────────► Appropriate pipeline/stage
        └─► Owner does nothing ────────────────────────────────► Stays Lost

Any status (new external campaign source detected by automation)
  └─► Re-submitted → clear lost reason → Status → Open → [01 : Acquisition] New Leads → Full restart
  └─► EXCEPTION: Lost (DNC) → Blocked. DNC is permanent.
```
