# Bana Land — GHL Follow-Up System
*Last edited: 2026-04-07 · Last reviewed: 2026-04-07*

Documentation for Bana Land's multi-channel motivated seller follow-up system, built in Go High Level (GHL). Covers the full lead lifecycle — from first outreach response through deal close, disqualification, or long-term drip.

**CRM:** Go High Level  |  **Niche:** Rural land, all US states  |  **Lead sources:** Cold call, cold SMS, direct mail, VAPI, referral, website

---

## Two-Account Architecture


| Account           | Owner                         | Role                                                                                                  |
| ----------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------- |
| **New Leads**     | Lead Manager + Acquisition Manager | Single working account for all leads. LM owns Day 1–30 for Cold SMS/Call. AM owns Day 1–30 for Direct Mail/VAPI/Referral/Website + all qualified stages through close. |
| **Prospect Data** | —                             | Central data warehouse. Raw property + skip trace data. No outreach. Feeds New Leads.                 |


---

## Project Files

### Parent-Level


| File                                 | Purpose                                                                             |
| ------------------------------------ | ----------------------------------------------------------------------------------- |
| [ROLE.md](ROLE.md)                   | AI assistant context file — loaded each session to establish role, business profile |
| [for-review.md](for-review.md)       | Pre-launch verifications, consistency log, improvement ideas, and decision log      |


### Account: New Leads (`new-leads/`)

Single working account for all lead sources. Handles all leads from entry through close, disqualification, or long-term drip. Workflows branch on the Latest Source field to assign leads to Lead Manager or Acquisition Manager.


| File                                   | Purpose                                                                          |
| -------------------------------------- | -------------------------------------------------------------------------------- |
| [quick-reference.md](new-leads/quick-reference.md) | Copywriter-friendly quick reference: every outreach touch by stage with template IDs and counts |
| [pipeline.md](new-leads/pipeline.md)   | 5 pipelines (Acquisition, Due Diligence, Value Add, Long Term FU, Disposition) + stage definitions + Opportunity Statuses |
| [sequences.md](new-leads/sequences.md) | Cadence map: Day 1–30 + Cold drip + Nurture + Qualified                          |
| [messaging.md](new-leads/messaging.md) | Message templates: NL-* + COLD-* + NUR-* + LTQ-*                                |
| [rules.md](new-leads/rules.md)         | Contact rules and compliance: hours, DNC, stage movement, response protocol, data hygiene |
| [data-model.md](new-leads/data-model.md) | Account configuration: custom fields, tags, pipeline stages, lead entry rules, smart lists |
| [workflows.md](new-leads/workflows.md) | 11 workflow definitions (WF-New-Lead-Entry, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly, WF-Dispo-Re-Engage, WF-DNC-Handler, WF-Response-Handler, WF-Missed-Call-Textback, WF-Abandoned-Alert) + checklists |


### Account: Prospect Data (`prospect-data/`)

Stores all raw property and skip trace data in GHL Custom Objects. No contacts, no pipeline, no outreach. Serves as the central data warehouse that feeds New Leads.


| File                                         | Purpose                                                                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| [data-model.md](prospect-data/data-model.md) | Custom Object schemas (Properties + Campaigns), field definitions, associations, field mapping to New Leads                 |
| [rules.md](prospect-data/rules.md)           | Data upload standards, campaign rules, status management, push-to-account rules                                             |


### Automation: n8n (`n8n/`)

n8n workflows that connect the two GHL sub-accounts. Handles lead intake, data enrichment from Prospect Data, and Contact + Opportunity creation in New Leads.


| File                                           | Purpose                                                                                     |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------- |
| [intake-workflow.md](n8n/intake-workflow.md)   | Baseline intake workflow: webhook → Prospect Data lookup → Contact + Opportunity in New Leads |
