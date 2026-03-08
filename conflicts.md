# Bana Land — Conflicts Report

Last updated: 2026-03-09 (post three-account structure)

---

## Summary

**15 findings** across all project files. Organized by severity:

- **4 Conflicts** — direct contradictions between files that must be resolved
- **7 Inconsistencies** — gaps, missing documentation, or outdated info
- **4 Style / Minor** — naming conventions, cleanup items, and nuances

Analysis method: every active file compared against every other active file, file by file. Archive and ignore folders excluded.

---

## Conflicts (Direct Contradictions)

### ~~C-01~~ | RESOLVED — ROLE.md updated to three-account architecture

ROLE.md now reflects three sub-accounts, includes a full Prospect Data description, updated cross-account integration, and a complete Project Files table. Resolved 2026-03-09.

---

### ~~C-02~~ | RESOLVED — DNC sync updated to tri-directional

WF-10 in both New Leads and Warm Response now fires two sync webhooks: one to the other contact account, one to Prospect Data (sets DNC = checked, DNC Date, Status = DNC). Both rules.md files updated to match. I-01 is also closed by this fix. Resolved 2026-03-09.

---

### ~~C-03~~ | RESOLVED — Offer Price changed to Text type in Prospect Data

Prospect Data's Offer Price field changed from Currency to Text — supports dollar amounts, percentages, or both in free-form. Field mapping table updated: maps to NL/WR's Offer Amount field with a note that it's manual-entry at the deal stage. Resolved 2026-03-09.

---

### ~~C-04~~ | RESOLVED — Contact description updated in both ghl-setup files

"One phone number" corrected to "up to four phone numbers" in both new-leads and warm-response ghl-setup.md. Resolved 2026-03-09.

---

## Inconsistencies (Gaps & Missing Documentation)

### ~~I-01~~ | RESOLVED — closed by C-02 fix. Resolved 2026-03-09.

---

### I-02 | Re-submission cleanup doesn't update Prospect Data

**Files:** new-leads/rules.md (§6B), new-leads/ghl-setup.md (WF-01), warm-response/ghl-setup.md (WF-CLEANUP), prospect-data/rules.md (§3)

When a contact is re-submitted to New Leads from a new external campaign, NL WF-01 fires and WR WF-CLEANUP handles Warm Response cleanup. But nobody documents updating the Property record in Prospect Data. The Property's Status might still show "Pipeline" from the original push, and Account Push tracking doesn't get refreshed.

**Fix:** Document in prospect-data/rules.md how re-submissions affect the Property record (new campaign tag added, Account Push updated, Status stays Pipeline or transitions).

---

### I-03 | table-of-contents.md says 7 Warm Response workflows — actually 8

**Files:** table-of-contents.md (line 52), warm-response/ghl-setup.md

table-of-contents.md lists: "7 workflows (WF-00A, WF-00B, WF-05, WF-06, WF-10, WF-HANDOFF, WF-11)." The actual ghl-setup.md also includes **WF-CLEANUP** (Re-Submission Cleanup), making it 8 workflows.

**Fix:** Update table-of-contents.md to "8 workflows" and add WF-CLEANUP to the list.

---

### I-04 | ROLE.md Project Files table is incomplete

**Files:** ROLE.md (lines 146-153)

The Project Files table lists only: table-of-contents.md, todo.md, lead-flow.md, warm-response/, new-leads/. Missing:
- `prospect-data/` subfolder (the entire third account)
- `conflicts.md`
- `improvements.md`

**Fix:** Add all three missing entries to the ROLE.md Project Files table.

---

### I-05 | WR WF-11 doesn't fire for Warm Response stage — NL WF-11 does fire for active stages

**Files:** warm-response/ghl-setup.md (WF-11), new-leads/ghl-setup.md (WF-11)

- **New Leads WF-11** fires for ALL contacts including active AM stages (Day 1-2, Day 3-14, Day 15-30). When a lead replies during an active stage, automation pauses and AM gets a review task.
- **Warm Response WF-11** enrollment condition is "Lead is in Cold stage" only. Inbound replies from contacts in the Warm Response stage (both Email and SMS tracks) are NOT caught by WF-11.

During Warm Response, WF-00A/WF-00B are actively running and Lead Manager is working the lead, so this may be intentional. But it means there's no automated pause-and-review mechanic if a Warm Response lead sends an unexpected reply (e.g., an opt-out phrase that doesn't match keywords, a negative reply, or a reply that comes between scheduled touches).

**Impact:** Potentially a design gap. If intentional, it should be documented as a deliberate choice.

**Decision needed:** Should WR WF-11 also cover the Warm Response stage? Or is Lead Manager's active involvement sufficient coverage? Document the decision.

---

### I-06 | WR pipeline.md Transferred stage doesn't mention re-submission cleanup entry

**Files:** warm-response/pipeline.md (Transferred stage), warm-response/ghl-setup.md (WF-CLEANUP)

The Transferred stage definition says entry is only from "Lead Manager moves contact here after successful phone connection (SMS track) or phone number receipt (Email track)." But WF-CLEANUP also moves contacts to Transferred when a re-submission cleanup fires. This entry path isn't captured in the pipeline stage definition.

**Fix:** Add a second entry path to the Transferred stage: "Re-submission cleanup (WF-CLEANUP) — contact re-entered from a new external campaign and now lives in New Leads."

---

### I-07 | Go-live checklists don't reference Prospect Data

**Files:** new-leads/ghl-setup.md (Step 9), warm-response/ghl-setup.md (Step 9)

Neither account's go-live checklist mentions verifying the data flow from Prospect Data: field mapping accuracy, push automation testing, DNC sync to/from Prospect Data, or campaign tag propagation.

**Fix:** Add Prospect Data verification items to both go-live checklists: "Prospect Data push automation tested (field mapping, Contact + Opportunity creation)" and "DNC sync to Prospect Data tested."

---

## Style / Minor Issues

### S-01 | Account numbering (1/2) used throughout — MEMORY.md says use names

**Files:** Nearly all files, MEMORY.md

MEMORY.md convention says "Use names, not numbers" for accounts. Many files still reference "Account 1" and "Account 2" instead of "Warm Response" and "New Leads." Examples:
- ROLE.md: "Account 1" / "Account 2" throughout
- NL pipeline.md line 148: "DNC sync webhook → n8n → Account 1"
- NL rules.md line 39: "Account 1"
- WR rules.md line 39: "Account 2"
- improvements.md: "Account 1" / "Account 2" throughout

**Fix:** Low priority but should be cleaned up for clarity, especially in ROLE.md. Use "Warm Response" and "New Leads" consistently.

---

### S-02 | todo.md has raw AI output and stale status

**Files:** todo.md (lines 23-35)

The DNC at Property & Contact Level decision (line 10) still shows "Status: OPEN" but lines 23-35 contain raw AI output describing a resolution and edit actions that were apparently taken. The section reads like an unfinished conversation transcript, not a clean decision doc.

**Fix:** Clean up todo.md. If the DNC decision was resolved, mark it RESOLVED and document the outcome cleanly. Remove the raw AI output.

---

### S-03 | improvements.md doesn't mention Prospect Data

**Files:** improvements.md

Generated pre-Prospect-Data. All improvement items reference "Account 1" / "Account 2" only. No considerations for how improvements interact with Prospect Data (e.g., Lead Scoring #9 could incorporate Prospect Data property fields, Deceased Protocol #12 could trigger from Prospect Data's Deceased field on push).

**Fix:** Low priority. When improvement items are implemented, consider Prospect Data implications.

---

### S-04 | ROLE.md Channel Strategy table doesn't capture Cold: Email Only nuance

**Files:** ROLE.md (line 80-81), warm-response/pipeline.md, warm-response/ghl-setup.md

ROLE.md says "Cold (Day 30-180): SMS + Email (monthly)" without noting that Warm Response `Cold: Email Only` contacts receive email only, no SMS. This is a minor nuance — the detail is correctly documented in the WR files — but the parent-level summary is slightly misleading.

**Fix:** Add a footnote or note that WR Cold: Email Only contacts are email-only in the Cold drip.

---

## GHL Config Verifications (Pre-Launch)

Carried forward from previous report, updated for three-account structure:


| Item                           | Account       | Workflow       | What to Verify                                                                             |
| ------------------------------ | ------------- | -------------- | ------------------------------------------------------------------------------------------ |
| Conditional SMS by phone field | Warm Response | WF-00A Step 13 | GHL can send SMS to Phone 1-4 individually, skipping empty fields                          |
| Conditional SMS skip by tag    | Warm Response | WF-05, WF-06   | GHL can branch on `Cold: Email Only` tag to skip SMS steps                                 |
| Conditional SMS skip by tag    | New Leads     | WF-05, WF-06   | Same — verify in New Leads' Cold drip workflows                                            |
| Workflow looping               | Both          | WF-06, WF-08   | GHL does not natively loop workflows — plan for manual re-enrollment or extended build-out |
| DNC sync to Prospect Data      | Both          | WF-10          | n8n webhook updates Property record in Prospect Data on DNC (NEW — from C-02)              |
| Prospect Data push automation  | Prospect Data | n8n            | Field mapping from Properties to Contact + Opportunity works correctly (NEW — from C-03)   |


---

## Cross-File Consistency (Verified — No Issues Found)

These areas were checked and found consistent across all files:

- **Contact and Opportunity custom field schemas** — identical between New Leads and Warm Response
- **Tag lists** — matching between NL and WR (with appropriate account-specific additions like `Cold: Email Only` in WR)
- **COLD-* and COLDQ-* template content** — identical between both accounts' messaging.md files
- **Cold drip cadence** — 6-month monthly then quarterly, same in both accounts' sequences.md and ghl-setup.md
- **Nurture sequence** — NL-only, internally consistent across pipeline.md, sequences.md, messaging.md, and ghl-setup.md
- **Warm Response 14-day exit** — consistent across WR pipeline.md, sequences.md, and ghl-setup.md
- **New Leads 30-day Cold entry** — consistent across NL pipeline.md, sequences.md, and ghl-setup.md
- **Re-engagement protocol (WF-11)** — Paused tag mechanic, 7-day auto-resume, consistent within each account
- **Re-submission protocol** — consistent between NL and WR (always to New Leads, cleanup in WR)
- **DNC protocol between NL and WR** — bidirectionally consistent (gap is only with Prospect Data)
- **Source tracking** — Original Source (immutable) + Latest Source + Latest Source Date, consistent across all files
- **Pipeline stages** — lead-flow.md original definitions align with current NL and WR pipeline.md files
- **Prospect Data field mapping to Contact/Opportunity** — complete and accurate (except Offer Price per C-03)
- **Campaign Type → destination account routing** — consistent between prospect-data/rules.md and NL/WR entry paths
- **Prospect Data Campaign rules** — internally consistent between data-model.md and rules.md

---

## Next Conflict Review

Run after all findings above are resolved and before GHL build begins. Should be lighter since the three-account structure will be fully documented.
