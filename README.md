# Bana Land — GHL Follow-Up System
*Last edited: 2026-03-19 · Last reviewed: —*

Documentation for Bana Land's multi-channel motivated seller follow-up system, built in Go High Level (GHL). Covers the full lead lifecycle — from first outreach response through deal close, disqualification, or long-term drip.

**CRM:** Go High Level  |  **Niche:** Rural land, all US states  |  **Lead sources:** Cold call, cold email, cold SMS, direct mail, VAPI AI call, referral, website

---

## Two-Account Architecture


| Account           | Owner                         | Role                                                                                                  |
| ----------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------- |
| **New Leads**     | Lead Manager + Acquisition Manager | Single working account for all leads. LM owns Day 1–30 for Cold Email/SMS/Call. AM owns Day 1–30 for Direct Mail/VAPI/Referral/Website + all qualified stages through close. |
| **Prospect Data** | —                             | Central data warehouse. Raw property + skip trace data. No outreach. Feeds New Leads.                 |


---

## Project Files

### Parent-Level


| File                                 | Purpose                                                                             |
| ------------------------------------ | ----------------------------------------------------------------------------------- |
| [ROLE.md](ROLE.md)                   | AI assistant context file — loaded each session to establish role, business profile |
| [todo.md](todo.md)                   | Cross-account open decisions, unresolved questions, and pending build tasks         |
| [for-review.md](for-review.md)       | Pre-launch verifications, consistency log, improvement ideas, and decision log      |


### Account: New Leads (`new-leads/`)

Single working account for all lead sources. Handles all leads from entry through close, disqualification, or long-term drip. Workflows branch on source tag to assign tasks to Lead Manager or Acquisition Manager.


| File                                   | Purpose                                                                          |
| -------------------------------------- | -------------------------------------------------------------------------------- |
| [pipeline.md](new-leads/pipeline.md)   | Stage definitions: New Leads → Cold, all Dispo stages, Qualified stages, Nurture |
| [sequences.md](new-leads/sequences.md) | Cadence map: Day 1–30 + Cold Email sub-flow + Cold drip + Nurture + Qualified    |
| [messaging.md](new-leads/messaging.md) | Message templates: NL-* + WR-EMAIL-* + COLD-* + COLDQ-* + NUR-* + NURQ-*        |
| [rules.md](new-leads/rules.md)         | Contact rules and compliance: hours, DNC, stage movement, response protocol, data hygiene |
| [ghl-setup.md](new-leads/ghl-setup.md) | GHL build guide: 12 workflows (WF-Cold-Email-Subflow, WF-New-Lead-Entry–WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Cold-Drip-Quarterly, WF-Nurture-Monthly–WF-Missed-Call-Textback, WF-Nurture-Quarterly) |


### Account: Prospect Data (`prospect-data/`)

Stores all raw property and skip trace data in GHL Custom Objects. No contacts, no pipeline, no outreach. Serves as the central data warehouse that feeds New Leads.


| File                                         | Purpose                                                                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| [data-model.md](prospect-data/data-model.md) | Custom Object schemas (Properties + Campaigns), field definitions, associations, field mapping to New Leads                 |
| [rules.md](prospect-data/rules.md)           | Data upload standards, campaign rules, status management, push-to-account rules                                             |
