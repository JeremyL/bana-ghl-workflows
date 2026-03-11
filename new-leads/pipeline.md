# Bana Land — New Leads Account: Pipeline Stage Definitions

This is the pipeline reference for **New Leads**. This account handles all leads
from New Leads through close, disqualification, or long-term drip.

For the Warm Response account, see [../warm-response/pipeline.md](../warm-response/pipeline.md).

---

## Data Model

- **Contacts** = people (property owners). Personal info, phone, email.
- **Opportunities** = properties/deals. Each property is a separate opportunity in the pipeline. Property data (county, acreage, APN, pricing) and source tracking (Original Source, Latest Source, Latest Source Date) live on the Opportunity.

Pipeline stages track **Opportunities**, not Contacts. Each card in the pipeline IS an opportunity. A Contact will only ever have one active Opportunity at a time. Multiple Contacts can be linked to a single Opportunity (e.g., co-owners on one property).

See [ghl-setup.md](ghl-setup.md) Step 3 for the full custom field definitions.

---

## Team Roles

| Role                    | Responsibility                                                            |
| ----------------------- | ------------------------------------------------------------------------- |
| **Acquisition Manager** | Works all leads from New Leads through close. Owns the full pipeline.     |

---

## Stage Group 1: Not Contacted / Not Qualified

These leads have entered the pipeline and have been assigned to the acquisition manager.
They have not yet been spoken to and qualified. Every lead starts here.

---

### New Leads

| Field          | Detail                                                                                              |
| -------------- | --------------------------------------------------------------------------------------------------- |
| **Definition** | Lead assigned to acquisition manager. Holding stage — no outreach automations fire here.            |
| **Entry**      | Transferred from Warm Response OR direct entry from cold call / direct mail / VAPI callback OR re-submission. |
| **Exit**       | AM reviews lead, makes one manual contact attempt, then manually moves to Day 1-2 → WF-02 kicks off |
| **Owner**      | Acquisition manager (assigned on entry via WF-01)                                                   |
| **Actions**    | WF-01 assigns to AM and creates a review task. AM manually calls. AM manually pushes to Day 1-2.    |

---

### Day 1-2

| Field          | Detail                                                                                                                            |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Definition** | Contact has been attempted but lead has not been reached or qualified.                                                            |
| **Entry**      | First contact attempt logged → Manual assignment by acquisition manager                                                           |
| **Exit**       | Lead responds and qualifies → Due Diligence. No response by Day 3 → Day 3-14. Disqualifying info found → appropriate Dispo stage. |
| **Owner**      | Acquisition manager (manual calls) + GHL automation (SMS, Email)                                                                  |
| **Frequency**  | 2x per day (morning + afternoon)                                                                                                  |
| **Channels**   | Call, SMS, Email                                                                                                                  |
| **Actions**    | Morning call task + automated SMS. Afternoon call task + SMS or Email.                                                            |

---

### Day 3-14

| Field          | Detail                                                                                              |
| -------------- | --------------------------------------------------------------------------------------------------- |
| **Definition** | Contact attempted for 3+ days. Lead has not responded or qualified.                                 |
| **Entry**      | No meaningful response by end of Day 2                                                              |
| **Exit**       | Lead responds and qualifies → Due Diligence. Day 15 passes → Day 15-30. Disqualifying info → Dispo. |
| **Owner**      | Acquisition manager (manual calls) + GHL automation                                                 |
| **Frequency**  | Days 3–10: 1x per day. Days 11–14: every 2–3 days.                                                  |
| **Channels**   | Call, SMS, Email                                                                                    |
| **Actions**    | Daily call task + rotating automated message (SMS or Email).                                        |

---

### Day 15-30

| Field          | Detail                                                                            |
| -------------- | --------------------------------------------------------------------------------- |
| **Definition** | Contact attempted for 15+ days without qualification.                             |
| **Entry**      | No meaningful response by end of Day 14                                           |
| **Exit**       | Lead qualifies → Due Diligence. Day 30 passes → Cold. Disqualifying info → Dispo. |
| **Owner**      | Acquisition manager (manual calls) + GHL automation                               |
| **Frequency**  | Tuesday & Thursdays Only                                                          |
| **Channels**   | Call, SMS, Email                                                                  |
| **Actions**    | Tuesday & Thursdays call task + rotating automated message.                       |

---

### Cold

| Field             | Detail                                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | 30+ days of contact attempts with no response or qualification.                                                       |
| **Entry**         | No meaningful response by end of Day 30                                                                               |
| **Exit**          | Lead responds and qualifies → Due Diligence. Lead opts out → DNC. Otherwise, stays in Cold indefinitely on drip.      |
| **Re-Engagement** | Lead replies to drip → WF-11: pause drip, AM 7-day review. AM acts → qualified/dispo. AM does nothing → drip resumes. |
| **Re-Submission** | Lead enters from new external campaign → WF-01: stop drip, move to New Leads, full restart as new lead.               |
| **Owner**         | GHL automation only (no manual call tasks unless lead re-engages)                                                     |
| **Frequency**     | Days 30–180: Monthly. Day 180+: Quarterly.                                                                            |
| **Channels**      | Days 30–180: SMS, Email (monthly). Day 180+: SMS, Email (quarterly).                                                  |
| **Actions**       | Automated drip only. If lead responds, WF-11 fires (see Re-Engagement above).                                         |

---

## Stage Group 2: Disqualified

Disqualified stages fall into two groups:

- **Dispo — Terminal** *(no future contact):* Not a Fit, No Longer Own, Purchased, DNC
- **Dispo — Re-Engage** *(Long-Term Drip — same as Cold stage, indefinite):* No Motivation, Wants Retail, On MLS, Lead Declined

---

### TERMINAL DISPOSITIONS (No Future Contact)

#### Dispo: Not a Fit

| Field          | Detail                                                           |
| -------------- | ---------------------------------------------------------------- |
| **Definition** | Property or owner characteristics make this a non-starter.       |
| **Entry**      | Team determines property/owner doesn't meet Bana Land's criteria |
| **Follow-Up**  | None                                                             |

#### Dispo: No Longer Own

| Field          | Detail                              |
| -------------- | ----------------------------------- |
| **Definition** | Lead has already sold the property. |
| **Entry**      | Confirmed property transfer         |
| **Follow-Up**  | None                                |

#### Dispo: Purchased

| Field          | Detail                                                      |
| -------------- | ----------------------------------------------------------- |
| **Definition** | Bana Land successfully purchased / closed on this property. |
| **Entry**      | Deal closed and funded                                      |
| **Follow-Up**  | None                                                        |

#### Dispo: DNC

| Field          | Detail                                                                           |
| -------------- | -------------------------------------------------------------------------------- |
| **Definition** | Lead has explicitly requested to not be contacted.                               |
| **Entry**      | Lead says "stop calling," "remove me," "don't contact me," or similar            |
| **Follow-Up**  | **Zero contact.** Immediately stop all workflows. Tag DNC. Log date.             |
| **DNC Sync**   | WF-10 fires DNC sync webhook → automation → Warm Response marks DNC if contact exists there. |
| **Compliance** | TCPA — failure to honor opt-out is a legal liability. Treat as highest priority. |

---

### RE-ENGAGE DISPOSITIONS (Long-Term Drip — Indefinite Until Opt-Out, Re-Engagement, or Re-Submission)

**Re-entry applies to all four stages below:**

- **Re-Engagement** (responds to our drip) → WF-11: pause drip, AM 7-day review. AM acts or drip auto-resumes.
- **Re-Submission** (new external campaign) → WF-01: stop drip, move to New Leads, full restart.

#### Dispo: No Motivation

| Field          | Detail                                                                         |
| -------------- | ------------------------------------------------------------------------------ |
| **Definition** | Owner has no reason or urgency to sell at this time.                           |
| **Entry**      | Conversation confirms owner is not motivated to sell                           |
| **Follow-Up**  | **Yes** — enroll in Long-Term Drip. Indefinite until opt-out or re-engagement. |

#### Dispo: Wants Retail

| Field          | Detail                                                                         |
| -------------- | ------------------------------------------------------------------------------ |
| **Definition** | Owner wants full market value or has unrealistic price expectations.           |
| **Entry**      | Price discussion reveals retail expectations                                   |
| **Follow-Up**  | **Yes** — enroll in Long-Term Drip. Indefinite until opt-out or re-engagement. |

#### Dispo: On MLS

| Field          | Detail                                                                         |
| -------------- | ------------------------------------------------------------------------------ |
| **Definition** | Property is listed with a realtor or on the open market.                       |
| **Entry**      | Confirmed listed status                                                        |
| **Follow-Up**  | **Yes** — enroll in Long-Term Drip. Indefinite until opt-out or re-engagement. |

#### Dispo: Lead Declined

| Field          | Detail                                                                         |
| -------------- | ------------------------------------------------------------------------------ |
| **Definition** | Lead received an offer from Bana Land and declined.                            |
| **Entry**      | Offer rejected without counter / negotiations ended                            |
| **Follow-Up**  | **Yes** — enroll in Long-Term Drip. Indefinite until opt-out or re-engagement. |

---

## Stage Group 3: Qualified Leads

These leads have been spoken to and are actively progressing through the deal cycle.

### Due Diligence

| Field          | Detail                                                           |
| -------------- | ---------------------------------------------------------------- |
| **Definition** | Lead is qualified. Team is researching the property.             |
| **Entry**      | Successful qualifying conversation                               |
| **Exit**       | Research complete → Make Offer.                                  |
| **Owner**      | Acquisition manager (human-led, every 1–2 days)                  |
| **Channels**   | Calls primarily. SMS check-ins.                                  |
| **Actions**    | Internal research tasks + seller relationship maintenance calls. |

### Make Offer

| Field          | Detail                                                                                 |
| -------------- | -------------------------------------------------------------------------------------- |
| **Definition** | Due diligence complete. Team is ready to present an offer to the seller.               |
| **Entry**      | Research finished, offer calculated                                                    |
| **Exit**       | Offer accepted → Contract Sent. Offer countered/rejected → Dispo/Negotiations/Nurture. |
| **Owner**      | Acquisition manager                                                                    |
| **Channels**   | Call (present offer verbally first).                                                   |
| **Actions**    | Call task to present offer. SMS follow-up if no answer.                                |

### Negotiations

| Field          | Detail                                                                             |
| -------------- | ---------------------------------------------------------------------------------- |
| **Definition** | An offer was made but not accepted. Both parties are working toward a number.      |
| **Entry**      | Seller countered or asked for time to think                                        |
| **Exit**       | Agreement reached → Contract Sent. No agreement → Dispo: Lead Declined or Nurture. |
| **Owner**      | Acquisition manager (active back-and-forth)                                        |
| **Channels**   | Calls. SMS for quick follow-ups.                                                   |
| **Frequency**  | Every 1–2 days while negotiating                                                   |
| **Actions**    | Daily call task. Light SMS automation for "checking in" messages.                  |

### Contract Sent

| Field          | Detail                                                                                          |
| -------------- | ----------------------------------------------------------------------------------------------- |
| **Definition** | Seller agreed to the price. A purchase contract has been sent for signature.                    |
| **Entry**      | Verbal agreement reached, contract delivered (email, DocuSign, physical mail)                   |
| **Exit**       | Contract signed → Under Contract. Seller backs out → Dispo: Lead Declined/Nurture/Negotiations. |
| **Owner**      | Acquisition manager                                                                             |
| **Channels**   | Calls + SMS                                                                                     |
| **Frequency**  | Every 1–2 days until signed                                                                     |
| **Actions**    | Follow up on signing status. Address objections. Urgency without pressure.                      |

### Under Contract

| Field          | Detail                                                                            |
| -------------- | --------------------------------------------------------------------------------- |
| **Definition** | Contract is signed. Property is under contract with Bana Land.                    |
| **Entry**      | Executed contract received                                                        |
| **Exit**       | Deal closes → Dispo: Purchased. Deal falls through → appropriate Dispo or Nurture |
| **Owner**      | Acquisition manager + transaction coordinator (if applicable)                     |
| **Channels**   | Calls + SMS (deal management, not follow-up)                                      |
| **Actions**    | Manage transaction timeline. Keep seller informed. Coordinate closing.            |

### Nurture

| Field             | Detail                                                                                                                        |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | Qualified lead that couldn't be closed. Kept alive for a future deal opportunity.                                             |
| **Entry**         | Left any qualified stage without closing (team discretion — not every dead deal lands here)                                   |
| **Exit**          | Lead re-engages → back to appropriate active stage. Lead opts out → DNC.                                                      |
| **Re-Engagement** | Lead replies to nurture drip → WF-11: pause drip, AM 7-day review. AM acts → qualified/dispo. AM does nothing → drip resumes. |
| **Re-Submission** | Lead enters from new external campaign → WF-01: stop drip, move to New Leads, full restart as new lead.                       |
| **Owner**         | GHL automation (full automation — no manual tasks unless response received)                                                   |
| **Frequency**     | Monthly for first 3 months → quarterly thereafter                                                                             |
| **Channels**      | SMS + Email (rotating).                                                                                                       |
| **Actions**       | Automated "checking in" messages. If response received, WF-11 fires (see Re-Engagement above).                                |

---

## Stage Transition Quick Reference

```
[WARM RESPONSE TRANSFER / COLD CALL / DIRECT MAIL / VAPI / RE-SUBMISSION]
  └─► NEW LEADS (Acquisition Manager)
        └─► Day 1-2 (2x daily)
              └─► Qualifies ──────────────────────────────────────► Due Diligence
              └─► No response by Day 3 ───────────────────────────► Day 3-14 (daily)
                    └─► Qualifies ──────────────────────────────► Due Diligence
                    └─► No response by Day 15 ──────────────────► Day 15-30 (Tue & Thu only)
                          └─► Qualifies ──────────────────────► Due Diligence
                          └─► No response by Day 30 ──────────► Cold (monthly → quarterly drip)
                                └─► Qualifies ────────────────► Due Diligence
                                └─► DNC request ──────────────► Dispo: DNC

Due Diligence ──► Make Offer ──► Negotiations ──► Contract Sent ──► Under Contract ──► Dispo: Purchased
                       │               │                │                  │
                       └──► Dispo /    └──► Dispo /     └──► Dispo /       └──► Dispo /
                            Negotiations     Nurture         Nurture /          Nurture
                            / Nurture                        Negotiations

Dispo: No Motivation ───────────────────────────────────────────► Long-Term Drip (indefinite)
Dispo: Wants Retail ────────────────────────────────────────────► Long-Term Drip (indefinite)
Dispo: On MLS ──────────────────────────────────────────────────► Long-Term Drip (indefinite)
Dispo: Lead Declined ───────────────────────────────────────────► Long-Term Drip (indefinite)

Any Qualified Stage (couldn't close) ───────────────────────────► Nurture or appropriate Dispo

--- RE-ENTRY PATHS ---

Cold / Nurture / Dispo Re-Engage (replies to our drip)
  └─► WF-11: Re-Engaged ─► AM 7-day review
        └─► AM moves to qualified stage ────────────────────────► Due Diligence (or appropriate)
        └─► AM moves to dispo ──────────────────────────────────► Appropriate Dispo
        └─► AM does nothing (7 days expire) ────────────────────► Drip resumes from where it stopped

Any stage (new external campaign source detected by automation)
  └─► Re-Submitted ─► Move to NEW LEADS ─► Full restart (Day 1-2 → etc.)
```
