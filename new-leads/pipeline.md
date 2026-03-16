# Bana Land — New Leads Account: Pipeline Stage Definitions

This is the pipeline reference for **New Leads** — the single working account for all lead sources.
All leads enter here and are worked through close, disqualification, or long-term drip.

---

## Data Model

- **Contacts** = people (property owners). Personal info, phone, email.
- **Opportunities** = properties/deals. Each property is a separate opportunity in the pipeline. Property data (county, acreage, APN, pricing) and source tracking (Original Source, Latest Source, Latest Source Date) live on the Opportunity.

Pipeline stages track **Opportunities**, not Contacts. Each card in the pipeline IS an opportunity. A Contact will only ever have one active Opportunity at a time. Multiple Contacts can be linked to a single Opportunity (e.g., co-owners on one property).

See [ghl-setup.md](ghl-setup.md) Step 3 for the full custom field definitions.

---

## Team Roles

| Role                    | Sources Owned (Day 1–30)                     | Responsibility                                                                                                                                                                                                   |
| ----------------------- | -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Lead Manager**        | Cold Email, Cold SMS, Cold Call               | Owns the full 30-day pre-qualification follow-up for these three sources. All calling, all SMS/email touches. The LM's first successful phone conversation IS the qualifying call (interest, motivation, asking price). When qualified → LM moves to Due Diligence and sets a call appointment for AM. |
| **Acquisition Manager** | Direct Mail, VAPI AI Call, Referral, Website | For these sources: owns full lifecycle from Day 1 through close (fact-finding first call + offer second call). For LM-sourced leads: receives qualified leads via appointment, makes the offer call. If lead misses AM's appointment call, AM owns follow-up from that point. |

---

## How Source Determines Owner (Day 1–30)

Same pipeline stages, different task assignment based on source tag.

| Source Tag             | Day 1–30 Owner     | Call Tasks Assigned To | Qualifying Call By | After Qualification                       |
| ---------------------- | ------------------- | ---------------------- | ------------------ | ----------------------------------------- |
| `Source: Cold Email`   | Lead Manager        | LM                     | LM                 | LM sets appointment → AM makes offer call |
| `Source: Cold SMS`     | Lead Manager        | LM                     | LM                 | LM sets appointment → AM makes offer call |
| `Source: Cold Call`    | Lead Manager        | LM                     | LM                 | LM sets appointment → AM makes offer call |
| `Source: Direct Mail`  | Acquisition Manager | AM                     | AM                 | AM continues through close                |
| `Source: VAPI AI Call` | Acquisition Manager | AM                     | AM                 | AM continues through close                |
| `Source: Referral`     | Acquisition Manager | AM                     | AM                 | AM continues through close                |
| `Source: Website`      | Acquisition Manager | AM                     | AM                 | AM continues through close                |

**LM → AM Handoff:** When LM qualifies a lead (confirms interest, motivation, asking price), LM moves the opportunity to Due Diligence and sets a call appointment for AM. AM calls the lead for the offer conversation. If the lead misses the appointment, AM owns follow-up from that point forward.

**AM-sourced leads:** Already considered qualified (the person came to us). AM handles fact-finding on the first call and presents an offer on the second call. Full multi-call lifecycle unchanged.

---

## Cold Email Special Handling

Cold Email leads may not have a phone number on entry. They get a special sub-flow that runs concurrently with normal stage progression:

- **Phase 1 (no phone #):** Automated emails asking for phone number (WR-EMAIL templates). Runs alongside normal Day 1–30 stage progression. LM monitors replies.
- **Phase 2 (phone # received):** LM call tasks begin. Normal Day 1–30 cadence applies from this point.
- **Day 30 with no phone # received:** One-time SMS blast to all skip-traced phone numbers on file (Phone 1–4) → move to Cold stage with `Cold: Email Only` tag (email-only drip, no further SMS).

If any skip-traced number responds to the one-time SMS blast, WF-11 fires and the LM reviews.

---

## Stage Group 1: Not Contacted / Not Qualified

These leads have entered the pipeline and been assigned to a team member (LM or AM based on source).
They have not yet been spoken to and qualified. Every lead starts here.

---

### New Leads

| Field          | Detail                                                                                           |
| -------------- | ------------------------------------------------------------------------------------------------ |
| **Definition** | Lead assigned to LM or AM based on source tag. Holding stage — no outreach automations fire here. |
| **Entry**      | All sources: Cold Email, Cold SMS, Cold Call, Direct Mail, VAPI, Referral, Website, re-submission. |
| **Exit**       | Owner reviews lead, makes one manual contact attempt, then manually moves to Day 1-2 → WF-02 kicks off. |
| **Owner**      | LM (Cold Email/SMS/Call) or AM (Direct Mail/VAPI/Referral/Website) — assigned on entry via WF-01. |
| **Actions**    | WF-01 branches on source tag: assigns to LM or AM, creates a review task for the assigned owner. |

---

### Day 1-2

| Field          | Detail                                                                                                                            |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Definition** | Contact has been attempted but lead has not been reached or qualified.                                                            |
| **Entry**      | First contact attempt logged → manual move by lead owner (LM or AM).                                                             |
| **Exit**       | Lead responds and qualifies → Due Diligence. No response by Day 3 → Day 3-14. Disqualifying info found → appropriate Dispo stage. |
| **Owner**      | LM or AM based on source tag + GHL automation (SMS, Email).                                                                       |
| **Frequency**  | 2x per day (morning + afternoon).                                                                                                 |
| **Channels**   | Call, SMS, Email.                                                                                                                 |
| **Actions**    | Morning call task + automated SMS. Afternoon call task + SMS or Email. Tasks assigned to LM or AM per source.                     |

---

### Day 3-14

| Field          | Detail                                                                                              |
| -------------- | --------------------------------------------------------------------------------------------------- |
| **Definition** | Contact attempted for 3+ days. Lead has not responded or qualified.                                 |
| **Entry**      | No meaningful response by end of Day 2.                                                              |
| **Exit**       | Lead responds and qualifies → Due Diligence. Day 15 passes → Day 15-30. Disqualifying info → Dispo. |
| **Owner**      | LM or AM based on source tag + GHL automation.                                                       |
| **Frequency**  | Days 3–10: 1x per day. Days 11–14: every 2–3 days.                                                  |
| **Channels**   | Call, SMS, Email.                                                                                    |
| **Actions**    | Daily call task + rotating automated message (SMS or Email). Tasks assigned to LM or AM per source.  |

---

### Day 15-30

| Field          | Detail                                                                            |
| -------------- | --------------------------------------------------------------------------------- |
| **Definition** | Contact attempted for 15+ days without qualification.                             |
| **Entry**      | No meaningful response by end of Day 14.                                           |
| **Exit**       | Lead qualifies → Due Diligence. Day 30 passes → Cold. Disqualifying info → Dispo. |
| **Owner**      | LM or AM based on source tag + GHL automation.                                     |
| **Frequency**  | Tuesdays & Thursdays only.                                                         |
| **Channels**   | Call, SMS, Email.                                                                  |
| **Actions**    | Tuesday & Thursday call task + rotating automated message. Tasks assigned to LM or AM per source. |

---

### Cold

| Field             | Detail                                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | 30+ days of contact attempts with no response or qualification.                                                       |
| **Entry**         | No meaningful response by end of Day 30. Cold Email leads with no phone # get `Cold: Email Only` tag (email-only drip). |
| **Exit**          | Lead responds and qualifies → Due Diligence. Lead opts out → DNC. Otherwise, stays in Cold indefinitely on drip.      |
| **Re-Engagement** | Lead replies to drip → WF-11: pause drip, owner reviews (LM for LM-sources, AM for AM-sources). 7-day auto-resume if no action. |
| **Re-Submission** | Lead enters from new external campaign → WF-01: stop drip, move to New Leads, full restart as new lead.               |
| **Owner**         | GHL automation only (no manual call tasks unless lead re-engages).                                                     |
| **Frequency**     | Days 30–180: Monthly. Day 180+: Quarterly.                                                                            |
| **Channels**      | SMS + Email (monthly → quarterly). `Cold: Email Only` contacts receive email only.                                     |
| **Actions**       | Automated drip only. If lead responds, WF-11 fires (see Re-Engagement above).                                         |

---

## Stage Group 2: Disqualified

Disqualified stages fall into two groups:

- **Dispo — Terminal** *(no future contact):* Not a Fit, No Longer Own, Purchased, DNC
- **Dispo — Re-Engage** *(Long-Term Drip — same as Cold stage, indefinite):* No Motivation, Wants Retail, On MLS, Lead Declined

**Who can dispo:** Both LM and AM can move leads to any Dispo stage. LM can dispo leads directly during the Day 1–30 window without passing to AM first.

---

### TERMINAL DISPOSITIONS (No Future Contact)

#### Dispo: Not a Fit

| Field          | Detail                                                           |
| -------------- | ---------------------------------------------------------------- |
| **Definition** | Property or owner characteristics make this a non-starter.       |
| **Entry**      | Team determines property/owner doesn't meet Bana Land's criteria. |
| **Follow-Up**  | None.                                                             |

#### Dispo: No Longer Own

| Field          | Detail                              |
| -------------- | ----------------------------------- |
| **Definition** | Lead has already sold the property. |
| **Entry**      | Confirmed property transfer.         |
| **Follow-Up**  | None.                                |

#### Dispo: Purchased

| Field          | Detail                                                      |
| -------------- | ----------------------------------------------------------- |
| **Definition** | Bana Land successfully purchased / closed on this property. |
| **Entry**      | Deal closed and funded.                                      |
| **Follow-Up**  | None.                                                        |

#### Dispo: DNC

| Field          | Detail                                                                           |
| -------------- | -------------------------------------------------------------------------------- |
| **Definition** | Lead has explicitly requested to not be contacted.                               |
| **Entry**      | Lead says "stop calling," "remove me," "don't contact me," or similar.            |
| **Follow-Up**  | **Zero contact.** Immediately stop all workflows. Tag DNC. Log date.             |
| **DNC Sync**   | WF-10 fires DNC sync webhook → automation → Prospect Data marks DNC on Property record. |
| **Compliance** | TCPA — failure to honor opt-out is a legal liability. Treat as highest priority. |

---

### RE-ENGAGE DISPOSITIONS (Long-Term Drip — Indefinite Until Opt-Out, Re-Engagement, or Re-Submission)

**Re-entry applies to all four stages below:**

- **Re-Engagement** (responds to our drip) → WF-11: pause drip, owner reviews. Owner acts or drip auto-resumes after 7 days.
- **Re-Submission** (new external campaign) → WF-01: stop drip, move to New Leads, full restart.

#### Dispo: No Motivation

| Field          | Detail                                                                         |
| -------------- | ------------------------------------------------------------------------------ |
| **Definition** | Owner has no reason or urgency to sell at this time.                           |
| **Entry**      | Conversation confirms owner is not motivated to sell.                           |
| **Follow-Up**  | **Yes** — enroll in Long-Term Drip. Indefinite until opt-out or re-engagement. |

#### Dispo: Wants Retail

| Field          | Detail                                                                         |
| -------------- | ------------------------------------------------------------------------------ |
| **Definition** | Owner wants full market value or has unrealistic price expectations.           |
| **Entry**      | Price discussion reveals retail expectations.                                   |
| **Follow-Up**  | **Yes** — enroll in Long-Term Drip. Indefinite until opt-out or re-engagement. |

#### Dispo: On MLS

| Field          | Detail                                                                         |
| -------------- | ------------------------------------------------------------------------------ |
| **Definition** | Property is listed with a realtor or on the open market.                       |
| **Entry**      | Confirmed listed status.                                                        |
| **Follow-Up**  | **Yes** — enroll in Long-Term Drip. Indefinite until opt-out or re-engagement. |

#### Dispo: Lead Declined

| Field          | Detail                                                                         |
| -------------- | ------------------------------------------------------------------------------ |
| **Definition** | Lead received an offer from Bana Land and declined.                            |
| **Entry**      | Offer rejected without counter / negotiations ended.                            |
| **Follow-Up**  | **Yes** — enroll in Long-Term Drip. Indefinite until opt-out or re-engagement. |

---

## Stage Group 3: Qualified Leads

These leads have been spoken to and are actively progressing through the deal cycle.
**AM owns all qualified stages** — for LM-sourced leads, AM takes over at Due Diligence via call appointment handoff.

### Due Diligence

| Field          | Detail                                                                                         |
| -------------- | ---------------------------------------------------------------------------------------------- |
| **Definition** | Lead is qualified. Team is researching the property and preparing an offer.                     |
| **Entry**      | **LM-sourced:** LM qualifies lead (interest, motivation, asking price confirmed), moves to Due Diligence, sets call appointment for AM. **AM-sourced:** AM qualifies lead during fact-finding call. |
| **Exit**       | Research complete → Make Offer.                                                                 |
| **Owner**      | Acquisition Manager (human-led, every 1–2 days).                                               |
| **Channels**   | Calls primarily. SMS check-ins.                                                                 |
| **Actions**    | Internal research tasks + seller relationship maintenance calls. For LM-sourced: AM's first call is the scheduled appointment (offer conversation). |

### Make Offer

| Field          | Detail                                                                                 |
| -------------- | -------------------------------------------------------------------------------------- |
| **Definition** | Due diligence complete. Team is ready to present an offer to the seller.               |
| **Entry**      | Research finished, offer calculated.                                                    |
| **Exit**       | Offer accepted → Contract Sent. Offer countered/rejected → Dispo/Negotiations/Nurture. |
| **Owner**      | Acquisition Manager.                                                                    |
| **Channels**   | Call (present offer verbally first).                                                    |
| **Actions**    | Call task to present offer. SMS follow-up if no answer.                                 |

### Negotiations

| Field          | Detail                                                                             |
| -------------- | ---------------------------------------------------------------------------------- |
| **Definition** | An offer was made but not accepted. Both parties are working toward a number.      |
| **Entry**      | Seller countered or asked for time to think.                                        |
| **Exit**       | Agreement reached → Contract Sent. No agreement → Dispo: Lead Declined or Nurture. |
| **Owner**      | Acquisition Manager (active back-and-forth).                                        |
| **Channels**   | Calls. SMS for quick follow-ups.                                                    |
| **Frequency**  | Every 1–2 days while negotiating.                                                   |
| **Actions**    | Daily call task. Light SMS automation for "checking in" messages.                   |

### Contract Sent

| Field          | Detail                                                                                          |
| -------------- | ----------------------------------------------------------------------------------------------- |
| **Definition** | Seller agreed to the price. A purchase contract has been sent for signature.                    |
| **Entry**      | Verbal agreement reached, contract delivered (email, DocuSign, physical mail).                   |
| **Exit**       | Contract signed → Under Contract. Seller backs out → Dispo: Lead Declined/Nurture/Negotiations. |
| **Owner**      | Acquisition Manager.                                                                             |
| **Channels**   | Calls + SMS.                                                                                     |
| **Frequency**  | Every 1–2 days until signed.                                                                     |
| **Actions**    | Follow up on signing status. Address objections. Urgency without pressure.                       |

### Under Contract

| Field          | Detail                                                                            |
| -------------- | --------------------------------------------------------------------------------- |
| **Definition** | Contract is signed. Property is under contract with Bana Land.                    |
| **Entry**      | Executed contract received.                                                        |
| **Exit**       | Deal closes → Dispo: Purchased. Deal falls through → appropriate Dispo or Nurture. |
| **Owner**      | Acquisition Manager + transaction coordinator (if applicable).                     |
| **Channels**   | Calls + SMS (deal management, not follow-up).                                      |
| **Actions**    | Manage transaction timeline. Keep seller informed. Coordinate closing.             |

### Nurture

| Field             | Detail                                                                                                                           |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | Qualified lead that couldn't be closed. Kept alive for a future deal opportunity.                                                 |
| **Entry**         | Left any qualified stage without closing (team discretion — not every dead deal lands here).                                      |
| **Exit**          | Lead re-engages → back to appropriate active stage. Lead opts out → DNC.                                                          |
| **Re-Engagement** | Lead replies to nurture drip → WF-11: pause drip, AM 7-day review. AM acts → qualified/dispo. AM does nothing → drip resumes.    |
| **Re-Submission** | Lead enters from new external campaign → WF-01: stop drip, move to New Leads, full restart as new lead.                          |
| **Owner**         | GHL automation (full automation — no manual tasks unless response received).                                                      |
| **Frequency**     | Monthly for first 3 months → quarterly thereafter.                                                                                |
| **Channels**      | SMS + Email (rotating).                                                                                                           |
| **Actions**       | Automated "checking in" messages. If response received, WF-11 fires (see Re-Engagement above).                                   |

---

## Stage Transition Quick Reference

```
[ALL SOURCES: Cold Email / Cold SMS / Cold Call / Direct Mail / VAPI / Referral / Website / Re-Submission]
  └─► NEW LEADS (LM for Cold Email/SMS/Call, AM for Direct Mail/VAPI/Referral/Website)
        └─► Day 1-2 (2x daily)
              └─► Qualifies ──────────────────────────────────────► Due Diligence
              └─► No response by Day 3 ───────────────────────────► Day 3-14 (daily)
                    └─► Qualifies ──────────────────────────────► Due Diligence
                    └─► No response by Day 15 ──────────────────► Day 15-30 (Tue & Thu only)
                          └─► Qualifies ──────────────────────► Due Diligence
                          └─► No response by Day 30 ──────────► Cold (monthly → quarterly drip)
                                └─► Re-engages ──────────────► WF-11 → owner reviews
                                └─► DNC request ──────────────► Dispo: DNC

--- COLD EMAIL SPECIAL HANDLING (runs concurrently with stages above) ---

Cold Email (no phone #) enters New Leads
  └─► Phase 1: Automated emails asking for phone # (Days 1–30)
        └─► Phone # received at any point ────────────────────► Phase 2: LM call tasks begin
        └─► Day 30, no phone # ───────────────────────────────► One-time SMS blast → Cold (email-only drip)

--- QUALIFICATION HANDOFF ---

LM qualifies lead (Cold Email/SMS/Call sources)
  └─► LM moves to Due Diligence + sets call appointment for AM
        └─► AM calls lead (offer conversation)
              └─► Lead misses appointment → AM owns follow-up from here

AM qualifies lead (Direct Mail/VAPI/Referral/Website sources)
  └─► AM moves to Due Diligence → continues through close (unchanged)

--- QUALIFIED PIPELINE (AM owns all) ---

Due Diligence ──► Make Offer ──► Negotiations ──► Contract Sent ──► Under Contract ──► Dispo: Purchased
                       │               │                │                  │
                       └──► Dispo /    └──► Dispo /     └──► Dispo /       └──► Dispo /
                            Negotiations     Nurture         Nurture /          Nurture
                            / Nurture                        Negotiations

--- DISPO RE-ENGAGE (Long-Term Drip) ---

Dispo: No Motivation ───────────────────────────────────────────► Long-Term Drip (indefinite)
Dispo: Wants Retail ────────────────────────────────────────────► Long-Term Drip (indefinite)
Dispo: On MLS ──────────────────────────────────────────────────► Long-Term Drip (indefinite)
Dispo: Lead Declined ───────────────────────────────────────────► Long-Term Drip (indefinite)

Any Qualified Stage (couldn't close) ───────────────────────────► Nurture or appropriate Dispo

--- RE-ENTRY PATHS ---

Cold / Nurture / Dispo Re-Engage (replies to our drip)
  └─► WF-11: Re-Engaged → owner 7-day review
        └─► Owner moves to qualified stage ────────────────────► Due Diligence (or appropriate)
        └─► Owner moves to dispo ──────────────────────────────► Appropriate Dispo
        └─► Owner does nothing (7 days expire) ────────────────► Drip resumes from where it stopped

Any stage (new external campaign source detected by automation)
  └─► Re-Submitted → Move to NEW LEADS → Full restart (Day 1-2 → etc.)
```
