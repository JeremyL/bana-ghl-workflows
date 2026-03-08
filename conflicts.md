# Bana Land — Conflicts Report

Last updated: 2026-03-09 (full re-run, all active files)

Analysis method: every active file compared against every other active file, file by file. Archive and ignore folders excluded.

---

## Summary





---

## GHL Config Verifications (Pre-Launch)

These items require hands-on GHL testing before go-live. They cannot be verified from documentation alone.


| Item                           | Account       | Workflow       | What to Verify                                                                             |
| ------------------------------ | ------------- | -------------- | ------------------------------------------------------------------------------------------ |
| Conditional SMS by phone field | Warm Response | WF-00A Step 13 | GHL can send SMS to Phone 1–4 individually, skipping empty fields                          |
| Conditional SMS skip by tag    | Warm Response | WF-05, WF-06   | GHL can branch on `Cold: Email Only` tag to skip SMS steps                                 |
| Workflow looping               | Both          | WF-06, WF-08   | GHL does not natively loop workflows — plan for manual re-enrollment or extended build-out |
| DNC sync to Prospect Data      | Both          | WF-10          | Automation webhook updates Property record in Prospect Data on DNC                         |
| Prospect Data push automation  | Prospect Data | Automation     | Field mapping from Properties to Contact + Opportunity works correctly                     |
| WF-HANDOFF end-to-end          | Warm Response | WF-HANDOFF     | Webhook → n8n → New Leads contact creation + WF-01 fires                                   |
| WF-CLEANUP guard (C-02)        | Warm Response | WF-CLEANUP     | Re-submission cleanup does NOT double-trigger WF-HANDOFF (see C-02)                        |


**Removed from previous report:** "Conditional SMS skip by tag — New Leads WF-05, WF-06" — `Cold: Email Only` is a Warm Response–only concept. NL contacts in Cold all have verified phone numbers from the Day 1–30 sequence. This verification does not apply to New Leads.

---

## Cross-File Consistency (Verified — No Issues Found)

Every item below was re-checked against all current file versions as of 2026-03-09.

- **Contact custom field schemas** — identical between New Leads and Warm Response (9 fields each, matching names/types; only "Assigned To" value differs: AM vs LM)
- **Opportunity custom field schemas** — identical between New Leads and Warm Response (17 fields each, matching names/types/dropdown values)
- **Tag lists** — matching between NL and WR, with appropriate account-specific differences:
  - NL-only: `Re-Submitted`, `Drip: Nurture Monthly`, `Drip: Nurture Quarterly`, `Caller: [Agent Name]`
  - WR-only: `Cold: Email Only`
  - All shared tags use identical names
- **COLD- and COLDQ- template content** — word-for-word identical between NL and WR messaging.md files (COLD-SMS-01 through COLD-SMS-04, COLD-EMAIL-01/02, COLDQ-SMS-01, COLDQ-EMAIL-01)
- **Cold drip cadence** — 6-month monthly then quarterly, same in both accounts' sequences.md and ghl-setup.md (WF-05/WF-06)
- **Nurture sequence** — NL-only, internally consistent across pipeline.md, sequences.md, messaging.md, and ghl-setup.md (WF-08). Phase 1 monthly (3 months) → Phase 2 quarterly (indefinite). Tag swap documented consistently.
- **Warm Response 14-day exit** — consistent across WR pipeline.md, sequences.md, and ghl-setup.md (WF-00A, WF-00B). Both tracks end at Day 14 → Cold.
- **New Leads 30-day Cold entry** — consistent across NL pipeline.md, sequences.md, and ghl-setup.md (WF-04 → Cold → WF-05)
- **Day-by-day sequence alignment** — NL sequences.md touch schedule matches NL ghl-setup.md WF-02/WF-03/WF-04 step-by-step (message refs, channel, timing all verified). WR sequences.md matches WF-00A/WF-00B.
- **Messaging quick reference tables** — NL and WR messaging.md quick reference tables correctly list workflow assignments, timing, and auto/manual designations for every template
- **Re-engagement protocol (WF-11)** — Paused tag mechanic, Re-Engaged tag, 7-day auto-resume for drip stages, no auto-resume for active stages — consistent within each account and between accounts (role-appropriate: AM in NL, LM in WR)
- **Re-submission protocol** — consistent between NL and WR: always goes to New Leads (WF-01), cleanup webhook to WR (WF-CLEANUP), Original Source preserved, tags stack, `Re-Submitted` tag applied in NL only
- **DNC protocol** — tri-directional, consistent across all three accounts: NL WF-10 syncs to WR + PD, WR WF-10 syncs to NL + PD, PD rules.md documents DNC receipt. Same trigger keywords (STOP/QUIT/UNSUBSCRIBE/CANCEL/END) in both accounts.
- **Source tracking** — Original Source (immutable, set once) + Latest Source (updated on re-submission) + Latest Source Date. Same dropdown values in NL and WR (8 values: Cold Call, Cold Email, Cold SMS, Direct Mail, VAPI AI Call, Launch Control, Referral, Website). Source tags match dropdown values.
- **Pipeline stages** — lead-flow.md original definitions align with current NL pipeline.md and WR pipeline.md
- **Campaign Type → destination routing** — consistent between prospect-data/rules.md §4, ROLE.md Cross-Account Integration, and NL/WR entry path documentation (Cold Email/SMS → WR, Cold Call/DM → NL)
- **Prospect Data Campaign rules** — internally consistent between data-model.md and rules.md (naming convention, tag format, status values, campaign types)
- **Prospect Data field mapping** — complete and accurate for all fields that flow from Properties to Contact + Opportunity (except the naming issue in C-01). Email 2–4 limitation explicitly noted. Offer Price mapping correct.
- **ROLE.md alignment** — business profile, team roles, contact cadence summary, channel strategy, tone/voice, key rules, and three-account architecture all match the detailed account files. No drift detected.
- **Contact hours** — "9 AM – 7 PM local time" consistent across ROLE.md, NL rules.md, WR rules.md, and both ghl-setup.md compliance checklists
- **table-of-contents.md** — file descriptions and workflow counts accurate (NL: 11 workflows, WR: 8 workflows including WF-CLEANUP)

---

## Next Conflict Review

All conflicts resolved. Run next review before GHL build begins or after any significant file changes.