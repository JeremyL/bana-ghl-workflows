# Bana Land — New Leads Account: Workflows
*Last edited: 2026-03-22 · Last reviewed: —*

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
| **WF-Cold-Email-Subflow-P1** | Cold Email Sub-Flow — Phase 1 (Day 1-10)   |
| **WF-Cold-Email-Subflow-P2** | Cold Email Sub-Flow — Phase 2 (Day 11-30)  |
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

### Workflow Trigger Convention

- **Stage-specific workflows** (WF-Cold-Email-Subflow-P1/P2, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Dispo-Re-Engage) trigger on **stage entry**. The preceding workflow moves the contact to the next stage — that stage change fires the next workflow automatically. No explicit "Enroll in…" action needed.
- **Cross-stage workflows** (WF-Long-Term-Quarterly) trigger on **explicit enrollment** from the preceding workflow. These serve multiple stages (Cold, Nurture, Dispo Re-Engage) and cannot rely on a single stage-entry trigger.
- **WF-Dispo-Re-Engage → WF-Cold-Drip-Monthly** uses explicit enrollment because Dispo Re-Engage contacts stay in their dispo stage — no stage change to Cold occurs.
- **Event-driven workflows** (WF-New-Lead-Entry, WF-DNC-Handler, WF-Response-Handler, WF-Missed-Call-Textback) trigger on specific events (lead added, DNC keyword, inbound reply, missed call).

---

### WF-Cold-Email-Subflow-P1 | Cold Email Sub-Flow — Phase 1 (Day 1-10)

**Trigger:** Contact moved to pipeline stage "Day 1-10" AND tagged `Source: Cold Email` AND Phone field is empty
**Owner:** Lead Manager (monitors replies)
**Enrollment condition:** Lead NOT tagged DNC

**Purpose:** Phase 1 of the Cold Email sub-flow. Runs concurrently with WF-Day-1-10. Sends automated emails asking for a phone number during the Day 1-10 window. When phone # is received, this workflow exits and WF-Day-1-10 standard steps fire normally. While this workflow is active, WF-Day-1-10 skips its SMS, call, and email steps for this contact (all three channels suppressed — P1 is the sole communicator). When WF-Day-1-10 auto-advances the contact to Day 11-30, this workflow exits via its stage-change exit condition, and WF-Cold-Email-Subflow-P2 picks up automatically on Day 11-30 entry.

**Actions:**

1. Send Email: WR-EMAIL-01 (ask for phone number)
2. Wait: 2 days
3. **Check: Phone number populated?** If yes → exit workflow (WF-Day-1-10 standard steps now fire normally).
4. Send Email: WR-EMAIL-02
5. Wait: 4 days
6. **Check: Phone number populated?** If yes → exit workflow.
7. Send Email: WR-EMAIL-03

Workflow waits for remaining Day 1-10 time. WF-Day-1-10 auto-advances contact to Day 11-30 at ~Day 11 → stage change fires exit condition → P1 ends. WF-Cold-Email-Subflow-P2 triggers on Day 11-30 entry.

**Pause mechanic:** Every email send step has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before it.

**Exit conditions:** Phone number populated (at any check point) OR contact stage changes (moved to any other pipeline stage).

---

### WF-Cold-Email-Subflow-P2 | Cold Email Sub-Flow — Phase 2 (Day 11-30)

**Trigger:** Contact moved to pipeline stage "Day 11-30" AND tagged `Source: Cold Email` AND Phone field is empty
**Owner:** Lead Manager (monitors replies)
**Enrollment condition:** Lead NOT tagged DNC

**Purpose:** Phase 2 of the Cold Email sub-flow. Picks up where P1 left off when the contact advances to Day 11-30. Sends remaining emails, then applies the Day 30 SMS blast and `Cold: Email Only` tag if no phone number is received. Runs concurrently with WF-Day-11-30 — while active, WF-Day-11-30 skips its SMS, call, and email steps for this contact.

**Actions:**

1. Wait: 3 days (spacing from WR-EMAIL-03 sent in P1)
2. **Check: Phone number populated?** If yes → exit workflow (WF-Day-11-30 standard steps now fire normally).
3. Send Email: WR-EMAIL-04
4. Wait: 3 days
5. **Check: Phone number populated?** If yes → exit workflow.
6. Send Email: WR-EMAIL-05
7. Wait: 9 days (brings us to approximately Day 30)
8. **Check: Phone number populated?** If yes → exit workflow.

**Day 30 — No Phone Number Received:**

9. **One-time SMS blast to all skip-traced phone numbers on contact (one SMS per number, send only if field is not empty):**
    - Send SMS to Phone 1: WR-COLD-SMS-01
    - Send SMS to Phone 2: WR-COLD-SMS-01 (if Phone 2 is not empty)
    - Send SMS to Phone 3: WR-COLD-SMS-01 (if Phone 3 is not empty)
    - Send SMS to Phone 4: WR-COLD-SMS-01 (if Phone 4 is not empty)
    - **This is a one-time blast only.** No more SMS will be sent in Cold stage for this contact.
10. Add tag: `Cold: Email Only` — flags contact for email-only drip (WF-Cold-Drip-Monthly/WF-Long-Term-Quarterly skip SMS steps)
11. Send internal notification to Lead Manager: "{{first_name}} — Cold Email lead moved to Cold after 30 days with no phone number received. One-time SMS blast sent to all skip-traced numbers."

**If any skip-traced number responds to the one-time SMS:**

- WF-Response-Handler fires (Inbound Response Handler) — drip paused, review task created for LM
- If LM connects, LM qualifies and moves to Due Diligence + sets appointment for AM
- `Cold: Email Only` tag can be removed if phone number is now confirmed

**Pause mechanic:** Every email send step has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before it.

**Exit conditions:** Phone number populated (at any check point) OR contact stage changes (moved to any other pipeline stage).

---

### WF-New-Lead-Entry | New Lead Entry

**Trigger:** Contact added to pipeline stage "New Leads"
**Actions:**

1. **If contact is tagged `Re-Submitted` (re-entry from new external campaign):**
   - Remove from all active workflows: WF-Cold-Email-Subflow-P1, WF-Cold-Email-Subflow-P2, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly, WF-Dispo-Re-Engage
   - Clear field: `Pause WFs Until` (if set from a prior cycle)
   - Remove tag: `Re-Submitted` (cleanup — it has served its purpose as a trigger)
   - Remove tag: `Cold: Email Only` (if present — re-submitted lead may now have a phone number)
2. **Branch on source tag — assign to LM or AM:**
   - **If tagged `Source: Cold Email` OR `Source: Cold SMS` OR `Source: Cold Call`:**
     - Assign contact to Lead Manager (specific team member)
     - Update custom field: Assigned To = Lead Manager name
   - **If tagged `Source: Direct Mail` OR `Source: VAPI AI Call` OR `Source: Referral` OR `Source: Website`:**
     - Assign contact to Acquisition Manager (specific team member)
     - Update custom field: Assigned To = Acquisition Manager name
3. Update custom field: Lead Entry Date = Today (skip if already set — contact may be a re-submission)
4. Update **Opportunity** custom field: Original Source (skip if already set — only set on first-ever entry)
5. Update **Opportunity** custom field: Latest Source = current source value
6. Update **Opportunity** custom field: Latest Source Date = Today
7. Update custom field: Stage Entry Date = Today
8. **Day 0 — Speed to Lead:**
   - **Branch A: If tagged `Source: Cold Email` AND Phone field is empty:**
     - Skip SMS, skip call notifications
     - Send internal notification to Lead Manager: "New Cold Email lead — no phone number on file. Move to Day 1-10 within 1 hour to start WF-Cold-Email-Subflow-P1. {{first_name}}"
     - *(WF-Cold-Email-Subflow-P1 takes over when owner moves contact to Day 1-10. LM should move within 1 hour — Stale New Leads Smart List catches any missed at 24hr.)*
   - **Branch B: Phone present — branch on source for Day 0 SMS:**
     - Send internal notification to assigned owner: "New lead — speed-to-lead touches firing now: {{first_name}} ({{source tag}}). Work the lead, then move to Day 1-10 when done."
     - **Push notification** (GHL mobile app) to assigned owner: "NEW LEAD — {{first_name}} — call NOW"
     - **Internal SMS alert** to assigned owner's personal number: "NEW LEAD — {{first_name}} — call now: {{phone}}"
     - **B1 — Cold outbound (`Source: Cold Email` OR `Source: Cold SMS` OR `Source: Cold Call`):**
       - Send SMS: CO-SMS-00 (Cold Outbound Speed to Lead) — fires after 120-second wait
       - Wait: 1 hour → If no call logged → Send SMS: CO-SMS-00A (Missed Call)
     - **B2 — Inbound (`Source: Website` OR `Source: VAPI AI Call` OR `Source: Referral`):**
       - Send SMS: IN-SMS-00 (Inbound Speed to Lead) — fires after 120-second wait
       - Wait: 1 hour → If no call logged → Send SMS: IN-SMS-00A (Inbound Missed Call)
     - **B3 — Direct Mail (`Source: Direct Mail`):**
       - Send SMS: DM-SMS-00 (Direct Mail Speed to Lead) — fires after 120-second wait
       - Wait: 1 hour → If no call logged → Send SMS: DM-SMS-00A (Direct Mail Missed Call)

**Note:** Day 0 speed-to-lead touches fire automatically on entry. Owner works the lead on Day 0, then manually moves the contact to Day 1-10 the same day — that stage move triggers WF-Day-1-10 (and WF-Cold-Email-Subflow-P1 for Cold Email leads with no phone). WF-Day-1-10 waits until the next business day to start automated touches.

---

### WF-Day-1-10 | Day 1-10 Sequence

**Trigger:** Contact moved to pipeline stage "Day 1-10" (owner manually moves from New Leads after Day 0 speed-to-lead work)
**Enrollment condition:** Lead NOT tagged DNC

**Conditional logic:** Each SMS, call, and email step has a condition: **"If contact is enrolled in WF-Cold-Email-Subflow-P1 → skip step"**. This ensures Cold Email leads with no phone number only receive WF-Cold-Email-Subflow-P1 emails (no double communication). Once P1 exits (phone # received), these conditions pass and standard steps fire.

**Actions:**

*Days 1-2 — 2x per day:*

1. Update custom field: Stage Entry Date = Today
2. Wait: until next business day, 9:00 AM contact local time *(Day 0 speed-to-lead touches already fired in WF-New-Lead-Entry)*
3. **[Conditional]** Send SMS: NL-SMS-01 (First Touch)
4. Wait: 4 hours
5. **[Conditional]** Create Task: "Call {{first_name}} — Day 1" — Assigned to: **LM or AM based on source tag** — Due: Today
6. Wait: 4 hours
7. **[Conditional]** Send SMS: NL-SMS-07 (Missed Call Follow-Up)
8. Wait: until next business day, 9:00 AM contact local time
9. **[Conditional]** Send Email: NL-EMAIL-01
10. Wait: 4 hours
11. **[Conditional]** Create Task: "Call {{first_name}} — Day 2" — Assigned to: **LM or AM based on source tag** — Due: Today
12. Wait: 4 hours
13. **[Conditional]** Send SMS: NL-SMS-02

*Days 3-10 — 1x per day, rotating channels:*

14. Wait: until next day, 9:00 AM contact local time
15. **[Conditional]** Create Task: "Call {{first_name}} — Day 3" — Assigned to: **LM or AM** — Due: Today
16. Wait: 1 day
17. **[Conditional]** Send SMS: NL-SMS-10
18. Wait: 1 day
19. **[Conditional]** Send Email: NL-EMAIL-05
20. Wait: 1 day
21. **[Conditional]** Create Task: "Call {{first_name}} — Day 6" — Assigned to: **LM or AM** — Due: Today
22. Wait: 1 day
23. **[Conditional]** Send Email: NL-EMAIL-02
24. Wait: 1 day
25. **[Conditional]** Send SMS: NL-SMS-03
26. Wait: 1 day
27. **[Conditional]** Create Task: "Call {{first_name}} — Day 9" — Assigned to: **LM or AM** — Due: Today
28. Wait: 1 day
29. **[Conditional]** Send SMS: NL-SMS-08
30. Wait: until Day 11 begins
31. If no stage change: Move to pipeline stage: Day 11-30 (WF-Day-11-30 fires automatically on Day 11-30 stage entry)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Day-11-30 | Day 11-30 Sequence

**Trigger:** Contact moved to pipeline stage "Day 11-30" (auto-advanced from WF-Day-1-10 or manually moved)
**Enrollment condition:** Lead NOT tagged DNC

**Same conditional logic as WF-Day-1-10:** Steps are skipped while contact is enrolled in WF-Cold-Email-Subflow-P2.

**Important:** All touches in this workflow must respect the 9am–7pm contact local time window.

**Actions:**

1. Update custom field: Stage Entry Date = Today
2. **[Conditional]** Send SMS: NL-SMS-04 (Re-engage)
3. Wait: 2 days
4. **[Conditional]** Create Task: "Call {{first_name}} — Day 13" — Assigned to: **LM or AM** — Due: Today
5. Wait: 1 day
6. **[Conditional]** Send RVM: NL-RVM-01
7. Wait: 1 day
8. **[Conditional]** Send Email: NL-EMAIL-03
9. Wait: 2 days
10. **[Conditional]** Send SMS: NL-SMS-09
11. Wait: 3 days
12. **[Conditional]** Send RVM: NL-RVM-02
13. Wait: 2 days
14. **[Conditional]** Send SMS: NL-SMS-05
15. Wait: 2 days
16. **[Conditional]** Create Task: "Call {{first_name}} — Day 24" — Assigned to: **LM or AM** — Due: Today
17. Wait: 3 days
18. **[Conditional]** Send RVM: NL-RVM-03
19. Wait: 2 days
20. **[Conditional]** Send Email: NL-EMAIL-04 (Long-game)
21. Wait: 1 day
22. **[Conditional]** Send SMS: NL-SMS-06 (Final touch before cold)
23. If no stage change: Move to pipeline stage: Cold (WF-Cold-Drip-Monthly fires automatically on Cold stage entry)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Cold-Drip-Monthly | Cold Drip — Monthly (Months 1–3)

**Trigger:** Contact moved to pipeline stage "Cold" OR enrolled directly by WF-Dispo-Re-Engage (for Dispo Re-Engage leads)
**Applies to:** Cold stage leads (no response after Day 30) AND all Dispo Re-Engage leads
**Enrollment condition:** Lead NOT tagged DNC

**Note — `Cold: Email Only` contacts:** Skip all SMS steps — send email steps only.

**Actions:**

1. **Defensive cleanup:** Remove from WF-Nurture-Monthly, WF-Long-Term-Quarterly (prevents dual drip if contact moved from Nurture → Cold)
2. Update custom field: Stage Entry Date = Today
3. Wait: 30 days
4. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-01
5. Wait: 14 days
6. Send Email: COLD-EMAIL-01
7. Wait: 14 days
8. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-02
9. Wait: 14 days
10. Send Email: COLD-EMAIL-02
11. Wait: 14 days
12. **If NOT tagged `Cold: Email Only`:** Send SMS: COLD-SMS-03
13. Wait: 14 days
14. Send Email: COLD-EMAIL-03
15. Enroll in WF-Long-Term-Quarterly (Long-Term Quarterly Drip)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Long-Term-Quarterly | Long-Term Quarterly Drip (Month 4–28)

**Trigger:** Enrolled from WF-Cold-Drip-Monthly or WF-Nurture-Monthly (end of monthly phase) OR enrolled directly
**Applies to:** Cold, Nurture, and Dispo Re-Engage leads — all share this quarterly drip
**Enrollment condition:** Lead NOT tagged DNC

**Note — `Cold: Email Only` contacts:** Skip all SMS steps — send email steps only.

**Actions — Q1–Q4 plays twice (24 months), then stops:**

**Year 1:**
1. Wait: 90 days
2. **If NOT tagged `Cold: Email Only`:** Send SMS: LTQ-SMS-01
3. Send Email: LTQ-EMAIL-01
4. Wait: 90 days
5. **If NOT tagged `Cold: Email Only`:** Send SMS: LTQ-SMS-02
6. Send Email: LTQ-EMAIL-02
7. Wait: 90 days
8. **If NOT tagged `Cold: Email Only`:** Send SMS: LTQ-SMS-03
9. Send Email: LTQ-EMAIL-03
10. Wait: 90 days
11. **If NOT tagged `Cold: Email Only`:** Send SMS: LTQ-SMS-04
12. Send Email: LTQ-EMAIL-04

**Year 2 (same templates, second pass):**
13. Wait: 90 days
14. **If NOT tagged `Cold: Email Only`:** Send SMS: LTQ-SMS-01
15. Send Email: LTQ-EMAIL-01
16. Wait: 90 days
17. **If NOT tagged `Cold: Email Only`:** Send SMS: LTQ-SMS-02
18. Send Email: LTQ-EMAIL-02
19. Wait: 90 days
20. **If NOT tagged `Cold: Email Only`:** Send SMS: LTQ-SMS-03
21. Send Email: LTQ-EMAIL-03
22. Wait: 90 days
23. **If NOT tagged `Cold: Email Only`:** Send SMS: LTQ-SMS-04
24. Send Email: LTQ-EMAIL-04

Workflow ends. No re-enrollment. Lead stays in their current stage. WF-Response-Handler still catches any future inbound reply.

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Nurture-Monthly | Nurture — Monthly (Months 1–3)

**Trigger:** Contact moved to Nurture stage
**Enrollment condition:** Lead NOT tagged DNC

**Actions:**

1. **Defensive cleanup:** Remove from WF-Cold-Drip-Monthly, WF-Long-Term-Quarterly (prevents dual drip if contact moved from Cold → Nurture)
2. Update custom field: Stage Entry Date = Today
3. Wait: 30 days
4. Send SMS: NUR-SMS-01
5. Wait: 30 days
6. Send Email: NUR-EMAIL-01
7. Wait: 30 days
8. Send SMS: NUR-SMS-02
9. Enroll in WF-Long-Term-Quarterly (Long-Term Quarterly Drip)

**Pause mechanic:** "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Exit conditions:** Contact stage changes (moved to any other pipeline stage).

---

### WF-Dispo-Re-Engage | Dispo Re-Engage — Long-Term Drip Enrollment

**Trigger:** Contact moved to any Dispo Re-Engage stage: No Motivation, Wants Retail, On MLS, or Lead Declined
**Actions:**

1. **Defensive cleanup:** Remove from WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly (prevents dual drip if contact moved from Cold/Nurture → Dispo Re-Engage)
2. Update custom field: Stage Entry Date = Today
3. Enroll in WF-Cold-Drip-Monthly (Cold Drip — Monthly)

That's it. All re-engage dispo leads flow into the same Long-Term Drip as Cold stage leads (WF-Cold-Drip-Monthly monthly, then WF-Long-Term-Quarterly).

---

### WF-DNC-Handler | DNC Handler (+ DNC Sync to Prospect Data)

**Trigger:** Contact moved to Dispo: DNC OR SMS reply contains STOP/QUIT/UNSUBSCRIBE/CANCEL/END
**Actions:**

1. Move to pipeline stage: Dispo: DNC (ensures correct stage regardless of trigger source)
2. Update custom field: Stage Entry Date = Today
3. Remove from ALL active workflow enrollments (use "Remove from Workflow" action for each active WF: WF-Cold-Email-Subflow-P1, WF-Cold-Email-Subflow-P2, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly, WF-Dispo-Re-Engage, WF-Response-Handler, WF-Missed-Call-Textback)
4. Add tag: DNC
5. Update custom field: DNC Date = Today
6. Cancel all pending tasks for this contact
7. Send internal notification to team: "{{first_name}} has opted out — DNC applied. [Contact Link]"
8. **DNC Sync — Prospect Data:** Fire webhook to automation with contact identifier (email + phone numbers)
   - automation looks up matching Property record in Prospect Data by phone or email
   - If found → set DNC = checked, DNC Date = today, Status = DNC
   - If not found → no action needed
9. End — no further actions ever

---

### WF-Response-Handler | Inbound Response Handler (Re-Engagement)

**Trigger:** Inbound SMS received OR Email reply received
**Stage filter:** Contact is in pipeline stage: Day 1-10, Day 11-30, Cold, Nurture, Dispo: No Motivation, Dispo: Wants Retail, Dispo: On MLS, OR Dispo: Lead Declined
**Enrollment conditions:**
- Lead NOT tagged DNC
- `Pause WFs Until` field is empty OR `Pause WFs Until` ≤ today (prevents re-trigger during an active review window, but allows re-trigger after a prior pause has expired)

**Pause mechanic:** Every drip/automated-send workflow (WF-Cold-Email-Subflow-P1, WF-Cold-Email-Subflow-P2, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly) has a "Wait Until `Pause WFs Until` is empty OR `Pause WFs Until` ≤ today" condition before each send step.

**Actions:**

1. **Check: Is the reply an opt-out keyword?** (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
   - If yes → route to WF-DNC-Handler (DNC Handler). End this workflow.
2. Set custom field: `Pause WFs Until` = today + 3 days — all active automated workflows immediately hold at their next send condition
3. **Branch on source tag — assign review task to original owner:**
   - **If tagged `Source: Cold Email` OR `Source: Cold SMS` OR `Source: Cold Call`:**
     - Create Task: "REVIEW — {{first_name}} replied. Read their reply and decide next step." — Assigned to: Lead Manager — Due: Today — Priority: High
     - Send internal notification to LM: "{{first_name}} replied. Automation paused for 3 days. Review and either move stage or clear the Pause WFs Until field to resume early. [Contact Link]"
   - **If tagged `Source: Direct Mail` OR `Source: VAPI AI Call` OR `Source: Referral` OR `Source: Website`:**
     - Create Task: "REVIEW — {{first_name}} replied. Read their reply and decide next step." — Assigned to: Acquisition Manager — Due: Today — Priority: High
     - Send internal notification to AM: "{{first_name}} replied. Automation paused for 3 days. Review and either move stage or clear the Pause WFs Until field to resume early. [Contact Link]"
4. **Branch — drip stages (Cold / Nurture / Dispo Re-Engage) only:** Wait 3 days (auto-resume safety net)
5. **Branch — check resolution:**
   **Branch A — Owner moved contact to a qualified stage (Due Diligence, Make Offer, etc.):**
   - Workflow exit conditions fire, all active workflows killed automatically
   - Clear field: `Pause WFs Until` (cleanup)
   - End workflow. AM works qualified stages directly (no automated workflow).
   **Branch B — Owner moved contact to any Dispo stage:**
   - Workflow exit conditions fire, all active workflows killed automatically
   - Clear field: `Pause WFs Until` (cleanup)
   - End workflow. Dispo workflows handle it (WF-Dispo-Re-Engage for Re-Engage dispos, WF-DNC-Handler for DNC).
   **Branch C — Owner cleared `Pause WFs Until` field early (reply not actionable, lead stays in stage):**
   - Drip resumes from exactly where it stopped. End workflow.
   **Branch D — Owner did nothing, 3 days expired (drip stages only):**
   - `Pause WFs Until` date has now passed — drip send conditions evaluate to true and resume automatically
   - Clear field: `Pause WFs Until` (cleanup)
   - Send internal notification to owner: "{{first_name}} — 3-day review window expired with no action. Drip resumed automatically."

**Note for active stages (Day 1-10 / Day 11-30):** There is no 3-day auto-resume for these contacts. The owner is already actively working them. Resolution is: owner moves stage (kills workflow) or clears the `Pause WFs Until` field.

**Soft opt-outs:** Replies like "not interested" or "leave me alone" without official opt-out keywords (STOP/CANCEL/etc.) still trigger WF-Response-Handler normally. Owner reviews and decides — may move to DNC or appropriate Dispo based on judgment. See rules.md §6A for guidance.

---

### WF-Missed-Call-Textback | Missed Call Text-Back

**Trigger:** Missed inbound call to Bana Land number
**Enrollment condition:** Caller is a known contact AND NOT tagged DNC

**Purpose:** Automatically texts a lead back when nobody answers their inbound call. Short delay avoids feeling like a bot. No task — the lead's reply shows up in conversation and triggers a notification.

**Actions:**

1. Wait: 2 minutes
2. Send SMS: MC-SMS-01 (Missed Call Auto-Reply)
3. Send internal notification to assigned owner: "Missed call from {{first_name}} — auto-text sent"

**Note:** If the lead replies to the SMS, WF-Response-Handler (Inbound Response Handler) fires as usual — pauses drips and creates a review window.

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
- Task assignment mapped to correct team member(s) — LM for Cold Email/SMS/Call, AM for DM/VAPI/Referral/Website
- WF-Cold-Email-Subflow-P1/P2 conditional logic tested: confirms WF-Day-1-10 steps are skipped while P1 is active, and WF-Day-11-30 steps are skipped while P2 is active
- All workflow enrollments tested with a test contact before live launch

---

## Go-Live Checklist

- All pipeline stages created and in correct order
- All custom fields created
- All tags created
- All 12 workflows built and tested (WF-Cold-Email-Subflow-P1, WF-Cold-Email-Subflow-P2, WF-New-Lead-Entry, WF-Day-1-10, WF-Day-11-30, WF-Cold-Drip-Monthly, WF-Nurture-Monthly, WF-Long-Term-Quarterly, WF-Dispo-Re-Engage, WF-DNC-Handler, WF-Response-Handler, WF-Missed-Call-Textback)
- Smart lists created
- Team members trained on GHL task queue and stage movement (LM and AM)
- automation routing confirmed: all campaign types → New Leads
- DNC sync tested (New Leads → Prospect Data)
- Prospect Data push automation tested: field mapping correct, Contact + Opportunity created per property
- Prospect Data DNC sync tested: DNC in New Leads → Property record updated (DNC checked, Status = DNC)
- WF-Cold-Email-Subflow-P1 → P2 tested end-to-end: P1 email sub-flow, stage transition to P2, phone # detection at each check, Day 30 one-time SMS blast, Cold: Email Only tagging
- First batch of leads imported and enrolled in WF-New-Lead-Entry
- Monitoring dashboard set up (Reporting > Conversations, Tasks, Pipeline)
