# Bana Land — Project File Index

All files for the Bana Land GHL follow-up system, split across three GHL accounts.

---

## Parent-Level Files


| File                               | Purpose                                                                                |
| ---------------------------------- | -------------------------------------------------------------------------------------- |
| [ROLE.md](ROLE.md)                 | AI assistant context file — loaded each session to establish role, business profile    |
| [todo.md](todo.md)                 | Cross-account open decisions, unresolved questions, and pending build tasks            |
| [lead-flow.md](lead-flow.md)       | Original pipeline stage reference — early-stage definitions used to seed system design |
| [conflicts.md](conflicts.md)       | Tracked conflicts or discrepancies between documents                                   |
| [improvements.md](improvements.md) | Improvement ideas and enhancement notes                                                |


---


## Account: New Leads (`new-leads/`)

Handles all leads from New Leads through close, disqualification, or long-term drip.
Owned by Acquisition Manager.


| File                                   | Purpose                                                                          |
| -------------------------------------- | -------------------------------------------------------------------------------- |
| [pipeline.md](new-leads/pipeline.md)   | Stage definitions: New Leads → Cold, all Dispo stages, Qualified stages, Nurture |
| [sequences.md](new-leads/sequences.md) | Cadence map: New Leads + Cold drip + Nurture + Qualified sequences               |
| [messaging.md](new-leads/messaging.md) | Message templates: NL-* + COLD-* + COLDQ-* + NUR-* + NURQ-* + NEPQ question bank |
| [rules.md](new-leads/rules.md)         | Contact rules, compliance, DNC handling + DNC sync to Warm Response                  |
| [ghl-setup.md](new-leads/ghl-setup.md) | GHL build guide: 11 workflows (WF-01 through WF-11)                              |


---
 

## Account: Warm Response (`warm-response/`)

Handles cold email and cold SMS responders from initial response through either successful
transfer to New Leads or long-term Cold drip. Owned by Lead Manager.


| File                                       | Purpose                                                                               |
| ------------------------------------------ | ------------------------------------------------------------------------------------- |
| [pipeline.md](warm-response/pipeline.md)   | Stage definitions: Warm Response, Cold, Transferred, DNC                              |
| [sequences.md](warm-response/sequences.md) | Cadence map: Warm Response sequence + Cold drip (monthly → quarterly)                 |
| [messaging.md](warm-response/messaging.md) | Message templates: WR-* + COLD-* + COLDQ-*                                            |
| [rules.md](warm-response/rules.md)         | Contact rules, compliance, DNC handling + DNC sync to New Leads                       |
| [ghl-setup.md](warm-response/ghl-setup.md) | GHL build guide: 8 workflows (WF-00A, WF-00B, WF-05, WF-06, WF-10, WF-HANDOFF, WF-11, WF-CLEANUP) |


---



## Account: Prospect Data (`prospect-data/`)

Stores all raw property and skip trace data in GHL Custom Objects. No contacts,
no pipeline, no outreach. Serves as the central data warehouse that feeds New Leads & Warm Response.


| File                                         | Purpose                                                                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| [data-model.md](prospect-data/data-model.md) | Custom Object schemas (Properties + Campaigns), field definitions, associations, field mapping to New Leads & Warm Response |
| [rules.md](prospect-data/rules.md)           | Data upload standards, campaign rules, status management, push-to-account rules                                             |


---

