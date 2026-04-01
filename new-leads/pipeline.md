# Bana Land — New Leads Account: Pipeline Definitions

*Last edited: 2026-04-01 · Last reviewed: 2026-04-01*

Pipeline reference for **New Leads** — the single working account for all lead sources. Five pipelines organize the full lifecycle from entry through close or long-term follow-up:

1. **01 : Leads** — automated lead follow-up (Day 0 through Day 30)
2. **02 : Qualified** — manual deal-making (qualification through close)
3. **03 : Due Diligence** — post-contract, pre-close (TBD stages)
4. **04 : Value Add** — pre-close, complex deals with property improvements (TBD stages)
5. **05 : Long Term FU** — long-term drip for unresponsive, stalled, or lost leads

Opportunities move between pipelines as they progress. Leads is mostly automated. Qualified is human-driven. Due Diligence and Value Add are fully manual. Long Term FU is fully automated drip.

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
| **Lead Manager**        | Cold Email, Cold SMS, Cold Call               | Owns the full 30-day pre-qualification follow-up for these three sources. All calling, all SMS/email touches. The LM's first successful phone conversation IS the qualifying call (interest, motivation, asking price). When qualified → LM moves to Qualified: Comps/Pricing and sets a call appointment for AM. |
| **Acquisition Manager** | Direct Mail, VAPI, Referral, Website | For these sources: owns full lifecycle from Day 1 through close (fact-finding first call + offer second call). For LM-sourced leads: receives qualified leads via appointment, makes the offer call. If lead misses AM's appointment call, AM owns follow-up from that point. |

---

## How Source Determines Owner (Day 1–30)

Same Leads pipeline stages, different task assignment based on source tag.

| Source Tag             | Day 1–30 Owner     | Call Tasks Assigned To | Qualifying Call By | After Qualification                       |
| ---------------------- | ------------------- | ---------------------- | ------------------ | ----------------------------------------- |
| `source: cold email`   | Lead Manager        | LM                     | LM                 | LM sets appointment → AM makes offer call |
| `source: cold sms`     | Lead Manager        | LM                     | LM                 | LM sets appointment → AM makes offer call |
| `source: cold call`    | Lead Manager        | LM                     | LM                 | LM sets appointment → AM makes offer call |
| `source: direct mail`  | Acquisition Manager | AM                     | AM                 | AM continues through close                |
| `source: vapi` | Acquisition Manager | AM                     | AM                 | AM continues through close                |
| `source: referral`     | Acquisition Manager | AM                     | AM                 | AM continues through close                |
| `source: website`      | Acquisition Manager | AM                     | AM                 | AM continues through close                |

**LM → AM Handoff:** When LM qualifies a lead (confirms interest, motivation, asking price), LM moves the opportunity from Leads to Qualified: Comps/Pricing and sets a call appointment for AM. AM calls the lead for the offer conversation. If the lead misses the appointment, AM owns follow-up from that point forward.

**AM-sourced leads:** Already considered qualified (the person came to us). AM handles fact-finding on the first call and presents an offer on the second call. Full multi-call lifecycle unchanged.

---

## Cold Email Special Handling

Cold Email leads may not have a phone number on entry. They get a two-phase sub-flow that runs concurrently with the Day 1–30 sequence — one workflow per stage, matching the normal relay pattern:

- **P1 — Day 1-10 (no phone #):** WF-Cold-Email-Subflow-P1 sends automated emails asking for phone number (WR-EMAIL-01 through 03). Standard WF-Day-1-10 steps suppressed. LM monitors replies.
- **P2 — Day 11-30 (no phone #):** WF-Cold-Email-Subflow-P2 continues emails (WR-EMAIL-04, 05). Standard WF-Day-11-30 steps suppressed. Day 30: one-time SMS blast to all skip-traced phone numbers on file (Phone 1–4) → move to LT FU: Cold with `cold: email only` tag (email-only drip, no further SMS).
- **Phone # received (any point):** Active sub-flow phase exits. LM call tasks begin. Normal Day 1–30 cadence applies from that point.

If any skip-traced number responds to the one-time SMS blast, WF-Response-Handler fires and the LM reviews.

---

## 01 : Leads

3 stages. Automated lead follow-up for the first 30 days. LM or AM owns based on source tag.

All leads enter this pipeline. If no response by end of Day 11-30, the opportunity auto-moves to 05 : Long Term FU (Cold stage).

---

### New Leads

| Field          | Detail                                                                                           |
| -------------- | ------------------------------------------------------------------------------------------------ |
| **Definition** | Lead assigned to LM or AM based on source tag. **Day 0 speed-to-lead touches fire here** via WF-New-Lead-Entry. |
| **Entry**      | All sources: Cold Email, Cold SMS, Cold Call, Direct Mail, VAPI, Referral, Website, re-submission. |
| **Exit**       | Owner works Day 0 speed-to-lead (immediate SMS + call + missed-call SMS), then manually moves to Day 1-10 the same day. |
| **Owner**      | LM (Cold Email/SMS/Call) or AM (Direct Mail/VAPI/Referral/Website) — assigned on entry via WF-New-Lead-Entry. |
| **Actions**    | WF-New-Lead-Entry branches on source tag: assigns to LM or AM, fires Day 0 speed-to-lead (CO-SMS-00 + call task + CO-SMS-00A if no call logged), sends notification to owner. |

---

### Day 1-10

| Field          | Detail                                                                                                                            |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Definition** | Contact has been attempted on Day 0. Active daily pursuit across ten full calendar days.                                          |
| **Entry**      | Owner completes Day 0 speed-to-lead work → manual move by lead owner (LM or AM). WF-Day-1-10 waits until next business day to start.   |
| **Exit**       | Lead responds and qualifies → Qualified: Comps/Pricing (cross-pipeline move). No response by Day 11 → Day 11-30. Disqualifying info → Lost or Abandoned (status change). |
| **Owner**      | LM or AM based on source tag + GHL automation (SMS, Email).                                                                       |
| **Frequency**  | Days 1–2: 2x per day (morning + afternoon). Days 3–10: 1x per day. Day 1 = first full calendar day after Day 0.                  |
| **Channels**   | Call, SMS, Email.                                                                                                                 |
| **Actions**    | Call tasks + rotating automated SMS/Email. Tasks assigned to LM or AM per source.                                                 |

---

### Day 11-30

| Field          | Detail                                                                                              |
| -------------- | --------------------------------------------------------------------------------------------------- |
| **Definition** | Contact attempted for 10+ days without qualification. Winding down — reduced frequency.             |
| **Entry**      | No meaningful response by end of Day 10. Auto-advanced from Day 1-10.                                |
| **Exit**       | Lead responds and qualifies → Qualified: Comps/Pricing (cross-pipeline move). Day 30 passes with no response → LT FU: Cold (auto-move, cross-pipeline). Disqualifying info → Lost or Abandoned (status change). |
| **Owner**      | LM or AM based on source tag + GHL automation.                                                       |
| **Frequency**  | Every 2–3 days (11 touches across 20-day window).                                                    |
| **Channels**   | Call, SMS, Email, RVM.                                                                               |
| **Actions**    | Scheduled call task + rotating automated message (SMS, Email, or RVM). Tasks assigned to LM or AM per source. |

---

## 02 : Qualified

7 stages. Manual deal-making from qualification through close. **AM owns all stages.**

For LM-sourced leads, AM takes over at Comps/Pricing via call appointment handoff from LM.

---

### Comps/Pricing

| Field          | Detail                                                                                         |
| -------------- | ---------------------------------------------------------------------------------------------- |
| **Definition** | Lead is qualified. Team is researching the property and preparing an offer.                     |
| **Entry**      | **LM-sourced:** LM qualifies lead (interest, motivation, asking price confirmed), moves opportunity from Leads to Qualified: Comps/Pricing, sets call appointment for AM. **AM-sourced:** AM qualifies lead during fact-finding call, moves from Leads. |
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
| **Exit**       | Offer accepted → Contract Sent. Offer countered → Negotiations. Offer rejected → Lost or Nurture. |
| **Owner**      | Acquisition Manager.                                                                    |
| **Channels**   | Call (present offer verbally first).                                                    |
| **Actions**    | Call task to present offer. SMS follow-up if no answer.                                 |

---

### Negotiations

| Field          | Detail                                                                             |
| -------------- | ---------------------------------------------------------------------------------- |
| **Definition** | An offer was made but not accepted. Both parties are working toward a number.      |
| **Entry**      | Seller countered or asked for time to think.                                        |
| **Exit**       | Agreement reached → Contract Sent. No agreement → Lost (Lead Declined) or Nurture. |
| **Owner**      | Acquisition Manager (active back-and-forth).                                        |
| **Channels**   | Calls. SMS for quick follow-ups.                                                    |
| **Frequency**  | Every 1–2 days while negotiating.                                                   |
| **Actions**    | Call every 1-2 days. SMS for quick follow-ups between calls.                        |

---

### Additional Info Needed

| Field          | Detail                                                                                         |
| -------------- | ---------------------------------------------------------------------------------------------- |
| **Definition** | More information about the property is needed before a contract can be signed or offer made.    |
| **Entry**      | AM determines additional info is required — parking stage.                                      |
| **Exit**       | Info received → return to previous stage (Make Offer, Negotiations, or Contract Sent). Info unavailable → Lost or Nurture. |
| **Owner**      | Acquisition Manager.                                                                            |
| **Channels**   | Calls + SMS.                                                                                     |
| **Actions**    | Follow up on outstanding information. Internal research.                                         |

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
| **Exit**       | Simple deal → Due Diligence (pipeline 03). Complex deal → Value Add (pipeline 04). Deal closes → Won. Deal falls through → Lost (with reason) or Nurture. |
| **Owner**      | Acquisition Manager + transaction coordinator (if applicable).                     |
| **Channels**   | Calls + SMS (deal management, not follow-up).                                      |
| **Actions**    | Manage transaction timeline. Keep seller informed. Coordinate closing.             |

---

### Nurture (trigger stage)

| Field          | Detail                                                                                                            |
| -------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Definition** | Qualified lead that couldn't be closed. AM parks the deal here — **immediately auto-moves to LT FU: Nurture**.    |
| **Entry**      | AM moves deal from any Qualified stage when it stalls (team discretion — not every dead deal uses this).        |
| **Exit**       | Auto-move to 05 : Long Term FU (Nurture stage) on entry. This is a trigger stage, not a resting stage.            |
| **Owner**      | N/A — opportunity passes through immediately.                                                                      |
| **Actions**    | Stage-entry trigger fires automation to move opportunity to LT FU: Nurture.                                        |

---

## 03 : Due Diligence (TBD)

Post-contract, pre-close pipeline. Standard closing process — title work, surveys, closing coordination.

Stages TBD. Fully manual. Not relevant to automated workflows.

---

## 04 : Value Add (TBD)

Pre-close pipeline for complex deals where Bana does value-add work on the property (not a simple flip). The deal's complexity warrants its own pipeline and tracking.

Stages TBD. Fully manual. Not relevant to automated workflows.

---

## 05 : Long Term FU

3 stages. Automated long-term drip for leads that didn't convert during active follow-up. All drip is automated — no manual tasks unless a lead re-engages.

---

### Cold

| Field             | Detail                                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | 30+ days of contact attempts with no response or qualification. Never had a real conversation.                        |
| **Entry**         | Auto-move from Leads: Day 11-30 when sequence completes with no response. Cold Email leads with no phone # get `cold: email only` tag (email-only drip). |
| **Exit**          | Lead responds → WF-Response-Handler (owner reviews). Lead opts out → DNC. 24-month quarterly drip completes → Abandoned + `abandoned: exhausted`. |
| **Re-Engagement** | Lead replies to drip → WF-Response-Handler: pause drip, owner reviews (LM for LM-sources, AM for AM-sources). 3-day auto-resume if no action. |
| **Re-Submission** | Lead enters from new external campaign → WF-New-Lead-Entry: stop drip, move to Leads: New Leads, full restart.       |
| **Owner**         | GHL automation only (no manual call tasks unless lead re-engages).                                                     |
| **Frequency**     | Months 1–3: Monthly (SMS + Email each month). Month 4+: Quarterly.                                                    |
| **Channels**      | SMS + Email (monthly → quarterly). `cold: email only` contacts receive email only.                                     |
| **Actions**       | Automated drip only. If lead responds, WF-Response-Handler fires.                                                      |

---

### Nurture

| Field             | Detail                                                                                                                           |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | Qualified deal that stalled. Had real conversations but couldn't close.                                                          |
| **Entry**         | Auto-move from Qualified: Nurture (trigger stage).                                                                             |
| **Exit**          | Lead re-engages → WF-Response-Handler (AM reviews). Lead opts out → DNC. 24-month quarterly drip completes → Abandoned + `abandoned: exhausted`. |
| **Re-Engagement** | Lead replies to nurture drip → WF-Response-Handler: pause drip, AM 3-day review. AM acts → appropriate Qualified stage or Lost. AM does nothing → drip resumes. |
| **Re-Submission** | Lead enters from new external campaign → WF-New-Lead-Entry: stop drip, move to Leads: New Leads, full restart.                   |
| **Owner**         | GHL automation (full automation — no manual tasks unless response received).                                                      |
| **Frequency**     | Monthly for first 3 months → quarterly thereafter.                                                                                |
| **Channels**      | SMS + Email (rotating).                                                                                                           |
| **Actions**       | Automated "checking in" messages. If response received, WF-Response-Handler fires.                                                |

---

### Lost

| Field             | Detail                                                                                                                           |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | Lead was manually marked Lost with a non-terminal lost reason. Had a conversation, didn't convert. Re-engageable.                |
| **Entry**         | Status changed to Lost (any pipeline) → WF-Dispo-Re-Engage fires → moves opportunity to LT FU: Lost.                            |
| **Exit**          | Lead re-engages → WF-Response-Handler (owner reviews). Lead opts out → DNC. 24-month quarterly drip completes → Abandoned + `abandoned: exhausted`. |
| **Re-Engagement** | Lead replies to long-term drip → WF-Response-Handler: pause drip, owner 3-day review. Owner flips to Open + moves to appropriate stage, or drip resumes. |
| **Re-Submission** | Lead enters from new external campaign → WF-New-Lead-Entry: clear lost reason, flip status to Open, move to Leads: New Leads, full restart. |
| **Owner**         | GHL automation (full automation — no manual tasks unless response received).                                                      |
| **Frequency**     | Monthly for first 3 months → quarterly thereafter.                                                                                |
| **Channels**      | SMS + Email (rotating).                                                                                                           |
| **Actions**       | Automated drip via WF-Dispo-Re-Engage enrollment → WF-Long-Term-Quarterly. If response received, WF-Response-Handler fires.      |

---

## Opportunity Statuses

GHL has four fixed opportunity statuses — **Open, Won, Lost, Abandoned** — separate from pipeline stages. We use statuses for deal outcomes instead of cluttering pipelines with disposition stages.

**Who can dispo:** Both LM and AM can change a lead's status. LM can dispo leads directly during the Day 1–30 window without passing to AM first.

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

Leads that were real but didn't convert — they get a 24-month long-term drip triggered by the status change. The **Lost Reason** field captures why.

| Lost Reason      | Definition                                                     | Entry Criteria                                      |
| ---------------- | -------------------------------------------------------------- | --------------------------------------------------- |
| **No Motivation** | Owner has no reason or urgency to sell at this time.           | Conversation confirms owner is not motivated.        |
| **Wants Retail**  | Owner wants full market value or has unrealistic expectations. | Price discussion reveals retail expectations.        |
| **On MLS**        | Property is listed with a realtor or on the open market.      | Confirmed listed status.                             |
| **Lead Declined** | Lead received an offer from Bana Land and declined.           | Offer rejected / negotiations ended.                 |

**Follow-Up:** Status change to Lost triggers WF-Dispo-Re-Engage → moves to LT FU: Lost stage → enrolls in Long-Term Drip (monthly → quarterly, 24-month cap). After 24 months, status changes to Abandoned + `abandoned: exhausted` tag.

**Re-entry paths:**

- **Re-Engagement** (responds to our drip) → WF-Response-Handler: pause drip, owner reviews. Owner acts or drip auto-resumes after 3 days. If owner moves back to active stage, status flips to Open.
- **Re-Submission** (new external campaign) → WF-New-Lead-Entry: clear lost reason, flip status to Open, move to Leads: New Leads, full restart.

---

### Abandoned (+ Tag)

Truly done — no further outreach, no resources spent. The reason is tracked via tag since GHL doesn't have native "abandoned reasons."

| Tag                        | Definition                                                         | Entry Criteria                                                    |
| -------------------------- | ------------------------------------------------------------------ | ----------------------------------------------------------------- |
| `abandoned: dnc`           | Lead explicitly requested no contact.                              | Lead says "stop calling," "remove me," or similar. **Permanent.** |
| `abandoned: not a fit`     | Property or owner characteristics make this a non-starter.         | Team determines property/owner doesn't meet criteria.             |
| `abandoned: no longer own` | Lead has already sold the property.                                | Confirmed property transfer.                                      |
| `abandoned: exhausted`     | Completed 24-month drip cycle with no conversion.                  | WF-Long-Term-Quarterly final step fires automatically.            |

**Follow-Up:** None for any Abandoned reason.

**DNC specifics:** WF-DNC-Handler fires on Abandoned + `abandoned: dnc` → sync webhook → Prospect Data marks DNC on Property record. TCPA — highest priority, immediate full stop.

**Re-entry paths:**

- **Re-Submission (non-DNC)** → WF-New-Lead-Entry: strip `abandoned:` tag, flip status to Open, move to Leads: New Leads, full restart.
- **Re-Submission (DNC)** → **Blocked.** DNC is permanent. No restart.

---

## Cross-Pipeline Movement Summary

| Trigger | From | To | Mechanism |
|---|---|---|---|
| Lead qualifies | Leads: Day 1-10 or Day 11-30 | Qualified: Comps/Pricing | Manual move by LM or AM |
| Day 11-30 sequence completes, no response | Leads: Day 11-30 | LT FU: Cold | WF-Day-11-30 (auto-move at end of sequence) |
| AM parks stalled deal | Qualified: Nurture (trigger) | LT FU: Nurture | Auto-move on stage entry |
| Status changed to Lost | Any pipeline | LT FU: Lost | WF-Dispo-Re-Engage |
| Contract signed, simple deal | Qualified: Contract Signed | Due Diligence (pipeline 03) | Manual move |
| Contract signed, complex deal | Qualified: Contract Signed | Value Add (pipeline 04) | Manual move |
| Re-engagement from LT FU | LT FU: any stage | Human decides | WF-Response-Handler (pause + review task) |
| Re-submission (new campaign) | Any pipeline/status | Leads: New Leads | WF-New-Lead-Entry |
| DNC / Abandoned | Any pipeline | No move — status change only | WF-DNC-Handler |

---

## Stage Transition Quick Reference

```
[ALL SOURCES: Cold Email / Cold SMS / Cold Call / Direct Mail / VAPI / Referral / Website / Re-Submission]

=== 01 : LEADS ===

  └─► NEW LEADS (LM for Cold Email/SMS/Call, AM for Direct Mail/VAPI/Referral/Website)
        │   Day 0: Speed to Lead — immediate SMS + call task + missed-call SMS (WF-New-Lead-Entry)
        └─► Day 1-10 (2x daily Days 1-2, 1x daily Days 3-10)
              └─► Qualifies ──────────────────────────────────► [02 : Qualified] Comps/Pricing
              └─► No response by Day 11 ──────────────────────► Day 11-30 (every 2–3 days)
                    └─► Qualifies ────────────────────────────► [02 : Qualified] Comps/Pricing
                    └─► No response by Day 30 ────────────────► [05 : LT FU] Cold (auto-move)

--- COLD EMAIL SPECIAL HANDLING (runs concurrently with stages above) ---

Cold Email (no phone #) enters New Leads
  └─► Phase 1: Automated emails asking for phone # (Days 1–10)
        └─► Phone # received at any point ──────────────────► LM call tasks begin (normal cadence)
  └─► Phase 2: Continue emails (Days 11–30)
        └─► Day 30, no phone # ─────────────────────────────► One-time SMS blast → [05 : LT FU] Cold (email-only drip)

--- QUALIFICATION HANDOFF ---

LM qualifies lead (Cold Email/SMS/Call sources)
  └─► LM moves to [02 : Qualified] Comps/Pricing + sets call appointment for AM
        └─► AM calls lead (offer conversation)
              └─► Lead misses appointment → AM owns follow-up from here

AM qualifies lead (Direct Mail/VAPI/Referral/Website sources)
  └─► AM moves to [02 : Qualified] Comps/Pricing → continues through close

=== 02 : QUALIFIED (AM owns all) ===

Comps/Pricing ──► Make Offer ──► Negotiations ──► Contract Sent ──► Contract Signed
                       │               │                │                  │
                       └──► Lost /     └──► Lost /      └──► Lost /        └──► [03 : Due Diligence] or
                            Negotiations     Nurture         Nurture /          [04 : Value Add] or
                            / Nurture                        Negotiations       Won / Lost / Nurture

  Additional Info Needed ◄──► any Qualified stage (parking stage)

  Nurture (trigger stage) ──► immediately moves to [05 : LT FU] Nurture

=== 03 : DUE DILIGENCE (manual, TBD stages) ===

  Post-contract, pre-close. Standard closing process. ──► Won or Lost

=== 04 : VALUE ADD (manual, TBD stages) ===

  Pre-close, complex deal with property improvements. ──► Won or Lost

=== 05 : LONG TERM FU (automated drip) ===

  Cold (from Leads — never had conversation)     ─┐
  Nurture (from Qualified — deal stalled)      ├──► Monthly → Quarterly drip (24-month cap)
  Lost (status → Lost, non-terminal)              ─┘

  Re-engages ──► WF-Response-Handler → owner 3-day review → appropriate stage or drip resumes
  24 months complete ──► Abandoned + `abandoned: exhausted`

=== LOST (status change from any pipeline) ===

Status → Lost (No Motivation / Wants Retail / On MLS / Lead Declined)
  └─► WF-Dispo-Re-Engage ──► [05 : LT FU] Lost ──► 24-month drip ──► Abandoned (exhausted)

=== RE-ENTRY PATHS ===

LT FU: any stage (replies to drip — status is Open)
  └─► WF-Response-Handler: Pause WFs Until set → owner 3-day review
        └─► Owner moves to active stage ───────────────────────► Appropriate pipeline/stage
        └─► Owner marks Lost (with reason) ────────────────────► Stays in LT FU: Lost
        └─► Owner does nothing (3 days expire) ────────────────► Drip resumes

Lost (replies to long-term drip)
  └─► WF-Response-Handler: Pause WFs Until set → owner 3-day review
        └─► Owner flips to Open + moves to stage ─────────────► Appropriate pipeline/stage
        └─► Owner does nothing (3 days expire) ────────────────► Drip resumes

Abandoned (replies inbound — non-DNC only)
  └─► WF-Response-Handler: owner 3-day review (no drip to resume)
        └─► Owner flips to Open + moves to stage ─────────────► Appropriate pipeline/stage
        └─► Owner does nothing ────────────────────────────────► Stays Abandoned

Any status (new external campaign source detected by automation)
  └─► Re-submitted → strip abandoned tag / clear lost reason → Status → Open → [01 : Leads] New Leads → Full restart
  └─► EXCEPTION: Abandoned + `abandoned: dnc` → Blocked. DNC is permanent.
```
