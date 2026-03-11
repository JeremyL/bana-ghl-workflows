# Bana Land — Warm Response Account: Pipeline Stage Definitions

This is the pipeline reference for **Warm Response**. This account handles
cold email and cold SMS responders from initial response through either successful handoff
to New Leads or long-term Cold drip.

For the New Leads account, see [../new-leads/pipeline.md](../new-leads/pipeline.md).

---

## Data Model

- **Contacts** = people (property owners). Personal info, phone, email.
- **Opportunities** = properties/deals. Each property is a separate opportunity in the pipeline. Property data (county, acreage, APN, pricing) and source tracking (Original Source, Latest Source, Latest Source Date) live on the Opportunity.

Pipeline stages track **Opportunities**, not Contacts. Each card in the pipeline IS an opportunity. A Contact will only ever have one active Opportunity at a time. Multiple Contacts can be linked to a single Opportunity (e.g., co-owners on one property).

See [ghl-setup.md](ghl-setup.md) Step 3 for the full custom field definitions.

---

## Team Roles

| Role             | Responsibility                                                                                                                                                                                                                         |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Lead Manager** | Works the Warm Response stage. SMS responders: calls to get first conversation, then hands to New Leads (Acquisition Manager). Email responders: emails to obtain phone number — once received, Lead Manager transfers contact to New Leads. |

---

## Stage 1: Warm Response

These are prospects from cold email or cold SMS campaigns who responded "yes" to our initial
outreach but have NOT yet had a phone conversation with anyone on our team.
They are warmer than a cold prospect but are not yet a lead.
**Owner: Lead Manager.**

| Field                          | Detail                                                                                                                                                                                                          |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Definition**                 | Prospect responded "yes" to a cold email or cold SMS. No phone call has occurred yet.                                                                                                                           |
| **Entry**                      | Cold email reply indicating interest OR cold SMS reply indicating interest (via automation webhook)                                                                                                                    |
| **Exit — SMS Success**         | First phone conversation completed → Lead Manager moves contact to **Transferred** → WF-HANDOFF fires webhook to automation → New Leads receives contact as New Lead                                                  |
| **Exit — Email Success**       | Phone number received via email reply → Lead Manager moves contact to **Transferred** → WF-HANDOFF fires webhook to automation → New Leads receives contact as New Lead                                               |
| **Exit — No Connection (SMS)** | 14 days with no phone connection → move to **Cold** stage. Cold drip (SMS + Email, monthly → quarterly) runs within this account.                                                                                |
| **Exit — No Connection (Email)** | 14 days with no phone number received → one-time SMS blast to all skip-traced phones (Phone 1–4, if populated) → move to **Cold** stage with `Cold: Email Only` tag. Email-only Cold drip (no further SMS). |
| **Exit — Opt-Out**             | Any opt-out request → move to **Dispo: DNC** immediately. DNC sync webhook fires to New Leads.                                                                                                                 |
| **Owner**                      | Lead Manager                                                                                                                                                                                                    |
| **Channels**                   | **Email track:** automated email only — when phone number received, contact transfers to New Leads. **SMS track:** immediate lead manager call task + automated SMS follow-up if no answer.                     |
| **Tags**                       | `Warm: Email` for cold email responders. `Warm: SMS` for cold SMS responders.                                                                                                                                   |
| **Actions**                    | See [sequences.md](sequences.md) Sequence — Warm Response for full track details.                                                                                                                               |

**Key distinction:**
These contacts said "yes" — they are warmer than a cold prospect. The lead manager's sole job in this stage is to get them on the phone (SMS track) or get a phone number (Email track). Once that happens, the contact is transferred to New Leads where the Acquisition Manager takes over.

**No Connection After 14 Days:**
- **SMS track:** 14 days with no phone connection → move to Cold stage with standard Cold drip (SMS + Email, monthly → quarterly).
- **Email track:** 14 days with no phone number received → WF-00A sends a one-time SMS blast to all skip-traced phone numbers on file (Phone 1–4, if populated) using template WR-COLD-SMS-01. Contact moves to Cold stage tagged `Cold: Email Only` — Cold drip sends email only (no further SMS). If any skip-traced number responds, WF-11 fires and Lead Manager reviews.

---

## Stage 2: Cold

| Field             | Detail                                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Definition**    | Warm Response lead that went 14 days without phone connection. Long-term automated drip within Warm Response.             |
| **Entry**         | Warm Response lead with no phone connection after 14 days                                                             |
| **Exit**          | Lead responds → WF-11 fires (pause, review). Lead opts out → DNC. Re-submitted from new campaign → cleanup + New Leads. |
| **Re-Engagement** | Lead replies to drip → WF-11: pause drip, Lead Manager reviews. LM tries to connect → if successful, transfer to New Leads. If not actionable, drip resumes. 7-day auto-resume if no action. |
| **Re-Submission** | Lead enters from new external campaign → automation sends to New Leads + fires cleanup webhook to Warm Response (stop drip, move to terminal stage). |
| **Owner**         | GHL automation only (no manual call tasks unless lead re-engages)                                                     |
| **Frequency**     | Days 0–180: Monthly. Day 180+: Quarterly.                                                                             |
| **Channels**      | SMS + Email (monthly → quarterly). `Cold: Email Only` contacts receive email only.                                    |
| **Actions**       | Automated drip only. If lead responds, WF-11 fires.                                                                   |

---

## Stage 3: Transferred

| Field          | Detail                                                                                                        |
| -------------- | ------------------------------------------------------------------------------------------------------------- |
| **Definition** | Lead was successfully connected and transferred to New Leads (New Leads account).                             |
| **Entry**      | (1) Lead Manager moves contact here after successful phone connection (SMS track) or phone number receipt (Email track). (2) Re-submission cleanup automation — contact was in Warm Response Cold drip when a new campaign pushed them directly into New Leads; cleanup stops all Warm Response workflows and moves them here automatically. |
| **Follow-Up**  | None in Warm Response. WF-HANDOFF fires webhook to automation → New Leads creates contact in New Leads.                 |
| **Terminal**   | Yes — no further action in this account.                                                                       |

---

## Stage 4: Dispo: DNC

| Field          | Detail                                                                                                    |
| -------------- | --------------------------------------------------------------------------------------------------------- |
| **Definition** | Lead has explicitly requested to not be contacted.                                                        |
| **Entry**      | Lead says "stop," "remove me," or similar. SMS opt-out keyword (STOP, QUIT, etc.)                         |
| **Follow-Up**  | **Zero contact.** Immediately stop all workflows. Tag DNC. Log date.                                      |
| **DNC Sync**   | WF-10 fires DNC sync webhook → automation → New Leads marks DNC if contact exists there.                        |
| **Compliance** | TCPA — failure to honor opt-out is a legal liability. Treat as highest priority.                           |

---

## Stage Transition Quick Reference

```
[COLD EMAIL / SMS CAMPAIGN — outside GHL]
  └─► Prospect says "yes" ──────────────────────────────► WARM RESPONSE (Lead Manager)

        Email track (tag: Warm: Email)
        └─► # received ─────────────────────────────────► TRANSFERRED → webhook → New Leads
        └─► No # after 14 days → one-time SMS blast ───► COLD (email-only drip in Warm Response)

        SMS track (tag: Warm: SMS)
        └─► First phone call happens ───────────────────► TRANSFERRED → webhook → New Leads
        └─► No phone connection after 14 days ─────────► COLD (standard drip in Warm Response)

        Either track
        └─► Opt-out ────────────────────────────────────► DISPO: DNC (+ DNC sync to New Leads)

COLD (Warm Response drip)
  └─► Lead responds to drip ────────────────────────────► WF-11: pause, Lead Manager reviews
        └─► Connects successfully ──────────────────────► TRANSFERRED → webhook → New Leads
        └─► Not actionable ────────────────────────────► Drip resumes
  └─► Re-submitted (new external campaign) ────────────► automation cleanup → New Leads
  └─► Opt-out ──────────────────────────────────────────► DISPO: DNC (+ DNC sync to New Leads)
```
