# Bana Land — New Leads Account: Workflows
*Last edited: 2026-04-21 · Last reviewed: 2026-04-21*

All 12 workflows for the New Leads GHL sub-account. Build these in **Automation > Workflows** after completing the account configuration in [data-model.md](data-model.md).

Reference files:

- [data-model.md](data-model.md) — custom fields, tags, pipeline stages, lead entry rules
- [pipeline.md](pipeline.md) — stage definitions
- [sequences.md](sequences.md) — cadence map
- [messaging.md](messaging.md) — message templates
- [rules.md](rules.md) — compliance rules

---

## Workflow Index

| Code       | Name                                        |
| ---------- | ------------------------------------------- |
| **WF-New-Lead-Entry**  | New Lead Entry                              |
| **WF-Day-1-10**  | Day 1-10 Sequence                           |
| **WF-Day-11-30**  | Day 11-30 Sequence                          |
| **WF-Cold-Drip-Monthly**  | Cold Drip — Monthly (Months 1–3)            |
| **WF-Nurture-Monthly**  | Nurture — Monthly (Months 1–3)              |
| **WF-Long-Term-Quarterly** | Long-Term Quarterly Drip (Month 4–28)       |
| **WF-Dispo-Re-Engage**  | Dispo Re-Engage — Long-Term Drip Enrollment |
| **WF-DNC-Handler**  | DNC Handler (+ DNC Sync)                   |
| **WF-Response-Handler**  | Inbound Response Handler (Re-Engagement)    |
| **WF-Missed-Call-Textback**  | Missed Call Text-Back                       |
| **WF-Abandoned-Alert**   | Abandoned Status Alert (safety net)         |
| **WF-Pull-From-PD**     | Pull from Prospect Data                     |

### Workflow Trigger Convention

- **Stage-specific workflows** (WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly) trigger on **stage entry** within a specific pipeline. The preceding workflow moves the contact to the next stage — that stage change fires the next workflow automatically. No explicit "Enroll in…" action needed. Cross-pipeline moves (e.g., Day 11-30 → LT FU: Cold) also fire the target pipeline's stage-entry trigger.
- **Status-triggered workflows** (WF-Dispo-Re-Engage, WF-DNC-Handler, WF-Abandoned-Alert) trigger on **opportunity status change** (Lost, or Abandoned for the alert). WF-Dispo-Re-Engage branches on Lost Reason to determine behavior.
- **Cross-stage workflows** (WF-Long-Term-Quarterly) trigger on **explicit enrollment** from the preceding workflow. These serve multiple stages/statuses (Cold, Nurture, Lost) and cannot rely on a single trigger.
- **WF-Dispo-Re-Engage** triggers on status → Lost, moves the opportunity to LT FU: Lost (cross-pipeline), then enrolls in WF-Nurture-Monthly (softer drip — Lost leads gave a reason, so treated as warm, not cold).
- **Cross-pipeline trigger:** Acquisition pipeline stage "Nurture" has a stage-entry trigger that immediately moves the opportunity to LT FU pipeline stage "Nurture". This is a 1-action automation (no workflow code needed) — Acquisition: Nurture is a trigger stage, not a resting stage.
- **Event-driven workflows** (WF-New-Lead-Entry, WF-Response-Handler, WF-Missed-Call-Textback) trigger on specific events (lead added, inbound reply, missed call).

---

### WF-New-Lead-Entry | New Lead Entry

Diagram: [diagrams/workflow-diagrams.md#wf-new-lead-entry--new-lead-entry](diagrams/workflow-diagrams.md#wf-new-lead-entry--new-lead-entry)

**Trigger:** Contact added to Acquisition pipeline stage "New Leads"
**Actions:**

1. **If contact is tagged `re-submitted` (re-entry from new external campaign):**
   - **[Contact] DNC check:** If Contact tagged `dnc` OR Opportunity Lost Reason = DNC → send internal notification "Re-submission blocked — contact is DNC: {{first_name}}" → End workflow. DNC is permanent.
   - **[Contact]** Remove from all active workflows: WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly, WF-Dispo-Re-Engage
   - **[Opportunity] If Opportunity status is Lost:** Clear lost reason, change Opportunity status to Open
   - **[Contact]** Clear Contact custom field: `Pause WFs Until` (if set from a prior cycle)
   - **[Contact]** Remove tag from Contact: `re-submitted` (cleanup — it has served its purpose as a trigger)
2. **[Opportunity] Branch on Opportunity Latest Source field — assign to LM or AM** (uses GHL "Assign To User" action with "Only Apply to Unassigned Contacts" enabled → sets native Contact Owner; Opportunity owner auto-syncs. Re-submitted leads keep their existing owner):
   - **If Opportunity Latest Source = "Cold SMS" OR "Cold Call":**
     - Assign To User: Lead Manager
   - **If Opportunity Latest Source = "Direct Mail" OR "VAPI" OR "Referral" OR "Website":**
     - Assign To User: Jeremy, [AM2] — Split Traffic: Equally (round-robin)
3. Update **Contact** native Source = current source value (skip if already set — mirrors Opportunity Source for GHL built-in reporting). *Opportunity native Source, Latest Source, and Latest Source Date are set by n8n during lead intake — see [../n8n/intake-workflow.md](../n8n/intake-workflow.md).*
4. **Day 0 — Speed to Lead:**
   - Send internal notification to assigned owner: "New lead — speed-to-lead touches firing now: {{first_name}} ({{opportunity.latest_source}}). Work the lead, then move to Day 1-10 when done."
   - **Push notification** (GHL mobile app) to assigned owner: "NEW LEAD — {{first_name}} — call NOW"
   - **Internal SMS alert** to assigned owner's personal number: "NEW LEAD — {{first_name}} — call now: {{phone}}"
   - **Branch A — Cold outbound (Opportunity Latest Source = "Cold SMS" OR "Cold Call"):**
     - **[Contact]** Send SMS to Contact: CO-SMS-00 (Cold Outbound Speed to Lead) — fires after 120-second wait
     - Wait: 1 hour → If no call logged → **[Contact]** Send SMS to Contact: CO-SMS-00A (Missed Call)
   - **Branch B — Inbound (Opportunity Latest Source = "Website" OR "VAPI" OR "Referral"):**
     - **[Contact]** Send SMS to Contact: IN-SMS-00 (Inbound Speed to Lead) — fires after 120-second wait
     - Wait: 1 hour → If no call logged → **[Contact]** Send SMS to Contact: IN-SMS-00A (Inbound Missed Call)
   - **Branch C — Direct Mail (Opportunity Latest Source = "Direct Mail"):**
     - **[Contact]** Send SMS to Contact: DM-SMS-00 (Direct Mail Speed to Lead) — fires after 120-second wait
     - Wait: 1 hour → If no call logged → **[Contact]** Send SMS to Contact: DM-SMS-00A (Direct Mail Missed Call)

**Note:** Day 0 speed-to-lead touches fire automatically on entry. Owner works the lead on Day 0, then manually moves the contact to Day 1-10 the same day — that stage move triggers WF-Day-1-10. WF-Day-1-10 waits until the next business day to start automated touches.

---

### WF-Day-1-10 | Day 1-10 Sequence

**Trigger:** Contact moved to Acquisition pipeline stage "Day 1-10" (owner manually moves from New Leads after Day 0 speed-to-lead work)
**Enrollment condition:** Lead NOT tagged `dnc`

**Actions:**

*Days 1-2 — 2x per day:*

1. Wait: until next business day, 9:00 AM contact local time *(Day 0 speed-to-lead touches already fired in WF-New-Lead-Entry)*
2. Send SMS: NL-SMS-01 (First Touch)
3. Wait: 4 hours
4. Send SMS: NL-SMS-07 (Missed Call Follow-Up)
5. Wait: until next business day, 9:00 AM contact local time
6. Send Email: NL-EMAIL-01
7. Wait: 4 hours
8. Send SMS: NL-SMS-02

*Days 3-10 — 1x per day, rotating channels:*

9. Wait: until next day, 9:00 AM contact local time
10. Send SMS: NL-SMS-10
11. Wait: 1 day
12. Send Email: NL-EMAIL-05
13. Wait: 1 day
14. Send Email: NL-EMAIL-02
15. Wait: 1 day
16. Send SMS: NL-SMS-03
17. Wait: 1 day
18. Send SMS: NL-SMS-08
19. Wait: until Day 11 begins
20. If no stage change: Move to pipeline stage: Day 11-30 (WF-Day-11-30 fires automatically on Day 11-30 stage entry)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Day-11-30 | Day 11-30 Sequence

**Trigger:** Contact moved to Acquisition pipeline stage "Day 11-30" (auto-advanced from WF-Day-1-10 or manually moved)
**Enrollment condition:** Lead NOT tagged `dnc`

**Important:** All touches in this workflow must respect the 9am–7pm contact local time window.

**Actions:**

1. Send SMS: NL-SMS-04 (Re-engage)
2. Wait: 2 days
3. Send RVM: NL-RVM-01
4. Wait: 1 day
5. Send Email: NL-EMAIL-03
6. Wait: 2 days
7. Send SMS: NL-SMS-09
8. Wait: 3 days
9. Send RVM: NL-RVM-02
10. Wait: 2 days
11. Send SMS: NL-SMS-05
12. Wait: 2 days
13. Send RVM: NL-RVM-03
14. Wait: 3 days
15. Send Email: NL-EMAIL-04 (Long-game)
16. Wait: 1 day
17. Send SMS: NL-SMS-06 (Final touch before cold)
18. If no stage change: Move opportunity to 04 : LT FU pipeline, stage: Cold (cross-pipeline move — WF-Cold-Drip-Monthly fires automatically on LT FU: Cold stage entry)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Cold-Drip-Monthly | Cold Drip — Monthly (Months 1–3)

**Trigger:** Contact moved to LT FU pipeline stage "Cold"
**Applies to:** LT FU: Cold leads (no response after Day 30)
**Enrollment condition:** Lead NOT tagged `dnc`

**Actions:**

1. **Defensive cleanup:** Remove from WF-Nurture-Monthly, WF-Long-Term-Quarterly (prevents dual drip if contact moved from Nurture → Cold)
2. Wait: 30 days
3. Send SMS: COLD-SMS-01
4. Wait: 14 days
5. Send Email: COLD-EMAIL-01
6. Wait: 14 days
7. Send SMS: COLD-SMS-02
8. Wait: 14 days
9. Send Email: COLD-EMAIL-02
10. Wait: 14 days
11. Send SMS: COLD-SMS-03
12. Wait: 14 days
13. Send Email: COLD-EMAIL-03
14. Enroll in WF-Long-Term-Quarterly (Long-Term Quarterly Drip)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Long-Term-Quarterly | Long-Term Quarterly Drip (Month 4–28)

**Trigger:** Enrolled from WF-Cold-Drip-Monthly or WF-Nurture-Monthly (end of monthly phase) OR enrolled directly
**Applies to:** Cold, Nurture, and Lost leads — all share this quarterly drip
**Enrollment condition:** Lead NOT tagged `dnc`

**Actions — Q1–Q4 plays twice (24 months), then stops:**

**Year 1:**
1. Wait: 90 days
2. Send SMS: LTQ-SMS-01
3. Send Email: LTQ-EMAIL-01
4. Wait: 90 days
5. Send SMS: LTQ-SMS-02
6. Send Email: LTQ-EMAIL-02
7. Wait: 90 days
8. Send SMS: LTQ-SMS-03
9. Send Email: LTQ-EMAIL-03
10. Wait: 90 days
11. Send SMS: LTQ-SMS-04
12. Send Email: LTQ-EMAIL-04

**Year 2 (same templates, second pass):**
13. Wait: 90 days
14. Send SMS: LTQ-SMS-01
15. Send Email: LTQ-EMAIL-01
16. Wait: 90 days
17. Send SMS: LTQ-SMS-02
18. Send Email: LTQ-EMAIL-02
19. Wait: 90 days
20. Send SMS: LTQ-SMS-03
21. Send Email: LTQ-EMAIL-03
22. Wait: 90 days
23. Send SMS: LTQ-SMS-04
24. Send Email: LTQ-EMAIL-04

**End of 24-month cycle:**
25. Change opportunity status to: **Lost**, Lost Reason = **Exhausted**
26. Send internal notification to team: "{{first_name}} — 24-month follow-up complete. Status → Lost (Exhausted). No further automated outreach. [Contact Link]"

Workflow ends. No re-enrollment. WF-Dispo-Re-Engage will fire on this status change but exits immediately (Exhausted is a No-Drip reason — no re-enrollment loop). WF-Response-Handler still catches any future inbound reply from Lost (non-DNC) contacts.

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage) OR opportunity status changes (e.g., manually moved to Won or Lost before drip completes).

---

### WF-Nurture-Monthly | Nurture — Monthly (Months 1–3)

**Trigger:** Contact moved to LT FU pipeline stage "Nurture" OR "Lost" OR enrolled directly by WF-Dispo-Re-Engage
**Applies to:** LT FU: Nurture leads (stalled qualified deals) and LT FU: Lost leads (drip-eligible lost reasons, enrolled via WF-Dispo-Re-Engage)
**Enrollment condition:** Lead NOT tagged `dnc`

**Actions:**

1. **Defensive cleanup:** Remove from WF-Cold-Drip-Monthly, WF-Long-Term-Quarterly (prevents dual drip if contact moved from Cold → Nurture)
2. Wait: 30 days
3. Send SMS: NUR-SMS-01
4. Wait: 30 days
5. Send Email: NUR-EMAIL-01
6. Wait: 30 days
7. Send SMS: NUR-SMS-02
8. Enroll in WF-Long-Term-Quarterly (Long-Term Quarterly Drip)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Dispo-Re-Engage | Lost — Long-Term Drip Enrollment

**Trigger:** Opportunity status changed to **Lost** (any lost reason)
**Actions:**

1. **If/Else branch on Lost Reason:**
   - **If Lost Reason IN (No Motivation, Wants Retail, On MLS, Lead Declined) — Drip reasons:**
     1. **Defensive cleanup:** Remove from WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly (prevents dual drip if contact was previously in Cold/Nurture)
     2. Move opportunity to 04 : LT FU pipeline, stage: Lost (cross-pipeline move)
     3. Enroll in WF-Nurture-Monthly (Nurture — Monthly)
   - **If Lost Reason IN (Not a Fit, No Longer Own, Exhausted, DNC) — No-Drip / DNC reasons:**
     - End workflow immediately. No enrollment, no pipeline move.

Drip-eligible Lost leads move to LT FU: Lost and flow into the softer Nurture monthly drip (WF-Nurture-Monthly, then WF-Long-Term-Quarterly) — same sequence as stalled qualified Nurture leads. Lost leads gave a reason, so they're warmer than never-responded Cold leads and receive fewer, less aggressive touches. After 24 months, WF-Long-Term-Quarterly changes status to Lost (Exhausted) — this re-triggers WF-Dispo-Re-Engage, but the If/Else branch catches Exhausted and exits immediately (no loop).

---

### WF-DNC-Handler | DNC Handler (+ DNC Sync to Prospect Data)

**Trigger:** SMS reply contains STOP/QUIT/UNSUBSCRIBE/CANCEL/END OR manually triggered by team (status change to Lost + Lost Reason = DNC)
**Actions:**

1. **Set Contact DND: ALL channels** (SMS, Call, Email) — platform-level hard block
2. Change opportunity status to: **Lost**, Lost Reason = **DNC** (if not already)
3. Add tag: `dnc` (Contact-level marker for DND filtering, enrollment gates, and n8n intake checks)
4. Remove from ALL active workflow enrollments (use "Remove from Workflow" action for each active WF: WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly, WF-Dispo-Re-Engage, WF-Response-Handler, WF-Missed-Call-Textback) — defensive list covers all possible enrollments.
5. Cancel all pending tasks for this contact
6. Send internal notification to team: "{{first_name}} has opted out — DNC applied. Status → Lost (DNC). [Contact Link]"
7. **DNC Sync — Prospect Data:** Fire webhook to automation with contact identifier (email + phone numbers)
   - automation looks up matching Property record in Prospect Data by phone or email
   - If found → set DNC = checked, DNC Date = today, Status = DNC
   - If not found → no action needed
8. End — no further actions ever

---

### WF-Response-Handler | Inbound Response Handler (Re-Engagement)

**Trigger:** Inbound SMS received OR Email reply received
**Filter:** Contact is in Acquisition pipeline stage: Day 1-10 or Day 11-30 — OR LT FU pipeline stage: Cold, Nurture, or Lost (status = Open) — OR opportunity status is Lost AND Lost Reason IN (Not a Fit, No Longer Own, Exhausted)
**Enrollment conditions:**
- Lead NOT tagged `dnc`
- `Pause WFs Until` field is empty OR `Pause WFs Until` ≤ today (prevents re-trigger during an active review window, but allows re-trigger after a prior pause has expired)

**Pause mechanic:** Every drip/automated-send workflow (WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly) has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Actions:**

1. **Check: Is the reply an opt-out keyword?** (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
   - If yes → route to WF-DNC-Handler (DNC Handler). End this workflow.
2. Set custom field: `Pause WFs Until` = today + 3 days — all active automated workflows immediately hold at their next send condition
3. **Branch on Contact Owner — assign review task to lead owner or AM round-robin fallback:**
   - **If/Else branch on Contact Owner field:**
     - **If Contact Owner is set** (routes to the actual assigned owner, not a hardcoded role):
       - Create Task: "REVIEW — {{first_name}} replied. Read their reply and decide next step." — Assigned to: **Contact Owner** — Due: Today — Priority: High
       - Send internal notification to Contact Owner: "{{first_name}} replied. Automation paused for 3 days. Review and either move stage or clear the Pause WFs Until field to resume early. [Contact Link]"
     - **Else (Contact Owner is empty — typical for LT FU: Cold / Nurture / Lost, where contacts are intentionally unassigned):**
       - Create Task: "REVIEW (unassigned lead) — {{first_name}} replied. Read their reply and decide next step. If actionable, move stage and self-assign." — Assigned to: Jeremy, [AM2] via round-robin (Split Traffic: Equally) — Due: Today — Priority: High
       - Send internal notification to the task assignee: "Unassigned lead {{first_name}} replied. Automation paused for 3 days. Review and either move stage (and self-assign) or clear the Pause WFs Until field to resume early. [Contact Link]"
       - **Do NOT set Contact Owner.** The contact stays unassigned unless the AM self-assigns after reviewing.
4. **Branch — drip stages/statuses (Cold / Nurture / Lost) only:** Wait 3 days (auto-resume safety net)
5. **Branch — check resolution:**
   **Branch A — Owner moved contact to a qualified stage (flips to Open if previously Lost):**
   - Workflow exit conditions fire, all active workflows killed automatically
   - Clear field: `Pause WFs Until` (cleanup)
   - End workflow. AM works qualified stages directly (no automated workflow).
   **Branch B — Owner changed status to Lost (with reason):**
   - Clear field: `Pause WFs Until` (cleanup)
   - End workflow. Status-triggered workflows handle it (WF-Dispo-Re-Engage branches on Lost Reason; WF-DNC-Handler for DNC).
   **Branch C — Owner cleared `Pause WFs Until` field early (reply not actionable, lead stays in current stage/status):**
   - Drip resumes from exactly where it stopped. End workflow.
   **Branch D — Owner did nothing, 3 days expired (drip stages and Lost status only):**
   - `Pause WFs Until` date has now passed — drip send conditions evaluate to true and resume automatically
   - Clear field: `Pause WFs Until` (cleanup)
   - Send internal notification to owner: "{{first_name}} — 3-day review window expired with no action. Drip resumed automatically."

**Note for active stages (Day 1-10 / Day 11-30):** There is no 3-day auto-resume for these contacts. The owner is already actively working them. Resolution is: owner moves stage (kills workflow) or clears the `Pause WFs Until` field.

**Note for Lost — No-Drip contacts (Not a Fit, No Longer Own, Exhausted):** There is no drip to resume — all automated outreach is complete. The 3-day window is a review-only period. If owner does nothing after 3 days, `Pause WFs Until` is cleared and the lead stays Lost. Owner can flip to Open + move to a qualified stage, change Lost Reason, or leave as-is.

**Soft opt-outs:** Replies like "not interested" or "leave me alone" without official opt-out keywords (STOP/CANCEL/etc.) still trigger WF-Response-Handler normally. Owner reviews and decides — may change to Lost (DNC) or Lost (with another reason) based on judgment. See rules.md §6A for guidance.

---

### WF-Missed-Call-Textback | Missed Call Text-Back

**Trigger:** Missed inbound call to Bana Land number
**Enrollment condition:** Caller is a known contact AND NOT tagged `dnc`

**Purpose:** Automatically texts a lead back when nobody answers their inbound call. Short delay avoids feeling like a bot. No task — the lead's reply shows up in conversation and triggers a notification.

**Actions:**

1. Wait: 2 minutes
2. Send SMS: MC-SMS-01 (Missed Call Auto-Reply)
3. Send internal notification to assigned owner: "Missed call from {{first_name}} — auto-text sent"

**Note:** If the lead replies to the SMS, WF-Response-Handler (Inbound Response Handler) fires as usual — pauses drips and creates a review window.

---

### WF-Abandoned-Alert | Abandoned Status Alert (Safety Net)

**Trigger:** Opportunity status changed to **Abandoned**
**Purpose:** GHL cannot remove the Abandoned status from the UI. This workflow catches accidental use and alerts the team.

**Actions:**

1. Send internal notification to team: "{{first_name}} was set to Abandoned — we no longer use this status. Please change to Lost + select a Lost Reason. [Contact Link]"

**No auto-correction** — just alerts. Team fixes manually so they learn the process.

---

### WF-Pull-From-PD | Pull from Prospect Data

**Trigger:** Opportunity custom field changed → `Pull from PD` → is checked
**Purpose:** Pulls property and owner data from the matching Property record in Prospect Data and merges it onto the existing Contact + Opportunity. Gap-fill only — existing NL data is never overwritten.

**Prerequisite:** The Opportunity must have a `Reference ID` populated. If empty, the workflow posts an error note and unchecks the box.

**Actions:**

1. **Webhook POST** to n8n `/pull-from-pd` endpoint with `opportunity_id`, `contact_id`, and `reference_id` (from the Opportunity's Reference ID field).

n8n handles all remaining steps — see [n8n/pull-workflow.md](../n8n/pull-workflow.md) for the full spec:

- Searches Prospect Data for the Property by Reference ID
- DNC check (blocks if Property is DNC)
- Fetches existing Contact + Opportunity data from New Leads
- Builds merge payloads (gap-fill: only populates empty fields)
- Updates Contact (mailing address, age, deceased, unconfirmed phones/emails — only if empty)
- Updates Opportunity (property data fields — only if empty)
- Posts PD Snapshot Note on Contact timeline
- Updates PD Property record (Status = Pipeline, CRM Push Date = today)
- Unchecks `Pull from PD` on the Opportunity
- Posts result summary note on Contact timeline

**Merge rule:** Every field is PRESERVE if populated. PD data only fills blanks. NL data (from the lead or the operator) is always authoritative. Source fields (native Source, Latest Source, Latest Source Date) are never touched — this is a data enrichment action, not a lead event.

**Error handling:** All error cases (no Reference ID, no PD match, DNC, API failure) post an error note on the Contact timeline and uncheck the box. Operator can re-check to retry.

---

## Compliance Verification Checklist

Before going live, verify:

- SMS opt-out keywords configured (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
- Auto-reply on opt-out is set: "You've been unsubscribed. Reply START to re-subscribe."
- WF-DNC-Handler (DNC Handler) triggers on opt-out SMS reply
- DNC sync webhook to automation tested and confirmed working (New Leads → Prospect Data)
- All workflows have time-window restrictions (9am–7pm contact local time)
- All SMS messages identify sender: include "Bana Land" or agent name
- Phone number has A2P 10DLC registration completed (required for business SMS in US)
- Unsubscribe footer included in all marketing emails
- AM round-robin assignment verified: Jeremy + [AM2], Split Traffic: Equally
- "Only Apply to Unassigned Contacts" toggle enabled on Assign To User action (owner preserved on re-submission)
- WF-Response-Handler review task assigned to Contact Owner via If/Else branch, with AM round-robin fallback (Jeremy + [AM2]) when Contact Owner is empty — Contact Owner is not set by the fallback; AM self-assigns only if they decide to work the lead (the only task created by workflows)
- All workflow enrollments tested with a test contact before live launch

---

## Go-Live Checklist

- All 5 pipelines created with stages in correct order (Acquisition, Due Diligence, Value Add, Long Term FU, Disposition)
- Acquisition: Nurture stage-entry trigger configured (auto-move to LT FU: Nurture)
- All custom fields created
- All tags created
- All 12 workflows built and tested (WF-New-Lead-Entry, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly, WF-Dispo-Re-Engage, WF-DNC-Handler, WF-Response-Handler, WF-Missed-Call-Textback, WF-Abandoned-Alert, WF-Pull-From-PD)
- Smart lists created
- Team members trained on GHL task queue and stage movement (LM and AM)
- automation routing confirmed: all campaign types → New Leads
- DNC sync tested (New Leads → Prospect Data)
- Prospect Data push automation tested: field mapping correct, Contact + Opportunity created per property
- Prospect Data DNC sync tested: DNC in New Leads → Property record updated (DNC checked, Status = DNC)
- First batch of leads imported and enrolled in WF-New-Lead-Entry
- Monitoring dashboard set up (Reporting > Conversations, Tasks, Pipeline)
