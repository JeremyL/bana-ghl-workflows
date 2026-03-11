# Bana Land — GHL Follow-Up System

Documentation for Bana Land's multi-channel motivated seller follow-up system, built in Go High Level (GHL). Covers the full lead lifecycle — from first outreach response through deal close, disqualification, or long-term drip — across three GHL sub-accounts.

**CRM:** Go High Level &nbsp;|&nbsp; **Niche:** Rural land, all US states &nbsp;|&nbsp; **Lead sources:** Cold call, cold email, cold SMS, direct mail

---

## Three-Account Architecture

| Account | Owner | Role |
| --- | --- | --- |
| **New Leads** | Acquisition Manager | All leads from entry through close, dispo, or drip |
| **Warm Response** | Lead Manager | Cold email/SMS responders → first call or phone number → transfer to New Leads |
| **Prospect Data** | — | Central data warehouse. Raw property + skip trace data. No outreach. Feeds New Leads & Warm Response. |

---

## Project Files

### Parent-Level

| File                               | Purpose                                                                                |
| ---------------------------------- | -------------------------------------------------------------------------------------- |
| [ROLE.md](ROLE.md)                 | AI assistant context file — loaded each session to establish role, business profile    |
| [rules.md](rules.md)               | Shared contact rules and compliance for New Leads + Warm Response                      |
| [todo.md](todo.md)                 | Cross-account open decisions, unresolved questions, and pending build tasks            |
| [for-review.md](for-review.md)     | Pre-launch verifications, consistency log, improvement ideas, and decision log         |


### Account: New Leads (`new-leads/`)

Handles all leads from New Leads through close, disqualification, or long-term drip. Owned by Acquisition Manager.

| File                                   | Purpose                                                                           |
| -------------------------------------- | --------------------------------------------------------------------------------- |
| [pipeline.md](new-leads/pipeline.md)   | Stage definitions: New Leads → Cold, all Dispo stages, Qualified stages, Nurture  |
| [sequences.md](new-leads/sequences.md) | Cadence map: New Leads + Cold drip + Nurture + Qualified sequences                |
| [messaging.md](new-leads/messaging.md) | Message templates: NL-* + COLD-* + COLDQ-* + NUR-* + NURQ-* + NEPQ question bank |
| [rules.md](new-leads/rules.md)         | Account-specific rules summary — points to shared ../rules.md                     |
| [ghl-setup.md](new-leads/ghl-setup.md) | GHL build guide: 10 workflows (WF-01 through WF-05, WF-07 through WF-11)          |


### Account: Warm Response (`warm-response/`)

Handles cold email and cold SMS responders from initial response through either successful transfer to New Leads or long-term Cold drip. Owned by Lead Manager.

| File                                       | Purpose                                                                                      |
| ------------------------------------------ | -------------------------------------------------------------------------------------------- |
| [pipeline.md](warm-response/pipeline.md)   | Stage definitions: Warm Response, Cold, Transferred, DNC                                     |
| [sequences.md](warm-response/sequences.md) | Cadence map: Warm Response sequence + Cold drip (monthly → quarterly)                        |
| [messaging.md](warm-response/messaging.md) | Message templates: WR-* + COLD-* + COLDQ-*                                                   |
| [rules.md](warm-response/rules.md)         | Account-specific rules summary — points to shared ../rules.md                               |
| [ghl-setup.md](warm-response/ghl-setup.md) | GHL build guide: 7 workflows (WF-00A, WF-00B, WF-05, WF-10, WF-HANDOFF, WF-11, WF-CLEANUP)        |


### Account: Prospect Data (`prospect-data/`)

Stores all raw property and skip trace data in GHL Custom Objects. No contacts, no pipeline, no outreach. Serves as the central data warehouse that feeds New Leads & Warm Response.

| File                                         | Purpose                                                                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| [data-model.md](prospect-data/data-model.md) | Custom Object schemas (Properties + Campaigns), field definitions, associations, field mapping to New Leads & Warm Response |
| [rules.md](prospect-data/rules.md)           | Data upload standards, campaign rules, status management, push-to-account rules                                             |
