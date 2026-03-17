#  file.Bana Land — For Review

Catch-all for items that need attention before or after go-live: pre-launch verifications, cross-file consistency checks, improvement ideas, and open decisions.

Last updated: 2026-03-18

---

## Pre-Launch Verifications

Items that require hands-on GHL testing before go-live. Cannot be verified from documentation alone.


| Item                           | Account       | Workflow            | What to Verify                                                                                                                                                                |
| ------------------------------ | ------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conditional SMS by phone field | New Leads     | WF-00A Step 16      | GHL can send SMS to Phone 1–4 individually, skipping empty fields                                                                                                             |
| Conditional SMS skip by tag    | New Leads     | WF-05               | GHL can branch on `Cold: Email Only` tag to skip SMS steps                                                                                                                    |
| WF-00A conditional suppression | New Leads     | WF-02/03            | Standard workflow steps are correctly skipped while contact is enrolled in WF-00A                                                                                             |
| Workflow looping               | New Leads     | WF-05, WF-07, WF-08 | Verify GHL "Add to Workflow" action can re-enroll a contact into the same workflow (enabling native loop). If blocked, implement twin-workflow fallback (see Improvement #3). |
| DNC sync to Prospect Data      | New Leads     | WF-10               | Automation webhook updates Property record in Prospect Data on DNC                                                                                                            |
| Prospect Data push automation  | Prospect Data | Automation          | Field mapping from Properties to Contact + Opportunity works correctly                                                                                                        |
| Source-based task assignment   | New Leads     | WF-01/02/03         | Workflows correctly branch on source tag to assign tasks to LM vs AM                                                                                                          |


---

## Cross-File Consistency Log

Last full re-run: 2026-03-18 (post-stage consolidation — Day 1-10 / Day 11-30, WF-04 eliminated).

### Open Notes

**N-12: County reference style inconsistent across templates**

NL-SMS-00 uses `{{county}}` (GHL merge field syntax) while NL-EMAIL-01 and NL-EMAIL-02 use `[County Name]` (manual placeholder). Should be standardized. If using merge fields, verify correct GHL syntax for Opportunity custom fields (may need `{{opportunity.property_county}}` rather than `{{county}}`).

---

### Verified — No Issues (2026-03-18)

- **Nurture sequence** — internally consistent across pipeline.md, sequences.md, messaging.md, and ghl-setup.md (WF-08). Phase 1 monthly (3 months) → Phase 2 quarterly (indefinite). Both phases handled internally by WF-08. Template references match.
- **New Leads 30-day Cold entry** — consistent across NL pipeline.md, sequences.md, and ghl-setup.md (WF-03 → Cold → WF-05)
- **Cold drip sequence (WF-05)** — template references, timing, and `Cold: Email Only` SMS skip logic consistent across sequences.md, messaging.md, and ghl-setup.md
- **WF-00A Cold Email Sub-Flow** — email timing (Days 1, 3, 7, 14, 21), Day 30 SMS blast, suppression of WF-02/03 all consistent across pipeline.md, sequences.md, messaging.md, and ghl-setup.md
- **Day 1–30 sequence timing** — template references and day assignments in sequences.md match ghl-setup.md WF-02/03 step order and wait durations
- **Source tracking** — Original Source (immutable, set once) + Latest Source (updated on re-submission) + Latest Source Date. 7 dropdown values: Cold Call, Cold Email, Cold SMS, Direct Mail, VAPI AI Call, Referral, Website. Source tags match dropdown values. All 7 sources routed in WF-01/WF-11.
- **Source → owner routing** — LM owns Cold Email/SMS/Call; AM owns Direct Mail/VAPI/Referral/Website. Consistent across pipeline.md, sequences.md, ghl-setup.md (WF-01, WF-11), and ROLE.md.
- **Campaign Type → destination routing** — all campaign types route to New Leads. Consistent between prospect-data/rules.md and data-model.md.
- **Prospect Data Campaign rules** — internally consistent between data-model.md and rules.md (naming convention, tag format, status values, campaign types)
- **Prospect Data field mapping** — complete and accurate for all fields that currently flow from Properties to Contact + Opportunity. Email 2–4 limitation explicitly noted.
- **Contact hours** — "9 AM – 7 PM local time" consistent across ROLE.md, rules.md §1, and ghl-setup.md compliance checklist
- **Template voice compliance** — spot-checked all SMS (≤ 2 sentences) and email (≤ 4 sentences) templates. All within limits. All identify sender as Bana Land or agent name.
- **Prospect Data DNC handling** — "DNC applies to the entire property record, not individual owners" consistent between PD data-model.md (DNC checkbox on Property) and PD rules.md §3
- **DNC protocol** — bi-directional (New Leads ↔ Prospect Data). WF-10 syncs to PD. Same trigger keywords (STOP/QUIT/UNSUBSCRIBE/CANCEL/END). No stale WR references.
- **LM/AM dual-owner model** — consistent across all files: both can dispo, LM sets appointment for AM at qualification, AM owns all qualified stages regardless of source.
- **Quick reference template-to-workflow mapping** — all 34 template IDs in messaging.md quick reference match their workflow assignments in ghl-setup.md.
- **WF-09 Dispo Re-Engage stage list** — "No Motivation, Wants Retail, On MLS, Lead Declined" consistent across ghl-setup.md (WF-09), sequences.md, messaging.md Cold drip header, and pipeline.md Dispo Re-Engage definitions.
- **Nurture Phase 1/2 timing accuracy** — unlike Cold (see N-08), Nurture phase labels are accurate: Phase 1 "Months 0–3" has 3 monthly sends (Month 0, 1, 2), Phase 2 starts at Month 3. Consistent across sequences.md, messaging.md, and ghl-setup.md (WF-08).
- **Age and Deceased fields** — present in both accounts. Both Text type, consistent values (Y / N / blank for Deceased).
- **Stage consolidation (Day 1-10 / Day 11-30)** — stage names, definitions, and cadence descriptions consistent across all 5 New Leads files (pipeline.md, sequences.md, messaging.md, ghl-setup.md, rules.md) + ROLE.md + MEMORY.md. Zero references to old stage names (Day 1-2, Day 3-14, Day 15-30) in active files.
- **WF-04 elimination** — zero active-file references except Decision Log entry #12. Archive files retain old references (expected).
- **Workflow count post-consolidation** — 10 workflows confirmed across ghl-setup.md, MEMORY.md, and README.md (README.md fixed from 11 → 10 during this audit).
- **Template-to-workflow mapping post-consolidation** — all 34 template IDs in messaging.md quick reference re-verified against new WF-02 (Day 1-10) and WF-03 (Day 11-30) assignments in ghl-setup.md. All match.
- **Day 11-30 Tue/Thu uniformity** — "Tuesdays & Thursdays only (entire stage)" consistently described in pipeline.md, sequences.md, and ghl-setup.md WF-03. No split timing within the stage.

---

## Improvements — High Priority (Before Go-Live)

---

### 1. Speed to Lead

**Gap:** No speed-to-lead target. WF-01 creates a call task due "Today" — no urgency beyond that.

**Why it matters:** Calling within 5 minutes of a positive response increases contact rate by 10x+ vs. calling within an hour. These leads said "yes" — they're hot right now.

**Recommended changes:**

- Document speed-to-lead targets:
  - Cold SMS responders: **Call within 5 minutes** (LM)
  - Cold Email responders (phone # received): **Call within 5 minutes** (LM)
  - Cold Call leads: **Call within 5 minutes** (LM)
  - Re-submitted leads: **Call within 30 minutes**
- GHL implementation:
  - WF-01: Change LM task to "CALL NOW" with real-time push notification to Lead Manager's phone
  - Add SMS alert to Lead Manager's personal number: "NEW LEAD — {{first_name}} — call now: {{phone}}"
  - Consider GHL auto-call bridge: system calls Lead Manager first, then auto-dials the lead
- **Files affected:** rules.md (add Section 11: Speed to Lead), ghl-setup.md (WF-01 notification), sequences.md (add timing note)

---

### 2. Multi-Property Cadence Overlap

**Gap:** Flagged in ghl-setup.md Step 3 but no solution. If one owner has multiple properties in the same stage, they receive duplicate automated messages for each opportunity.

**Why it matters:** 3 properties entering on the same day = Day 0 speed-to-lead fires 3× (up to 6 SMS + 3 call tasks), then Day 1-10 adds more. Fast track to DNC.

**How common:** Rare but possible. Rural land owners sometimes have multiple parcels.

**Recommended approach (simple):**

- Add a workflow condition at the start of WF-02, WF-03, WF-05, WF-08:
  - "If this contact has another active opportunity in the same stage group, skip automated messages and create a manual task instead"
  - AM handles multi-property contacts personally
- For Cold/Nurture drips: only send one message per contact regardless of opportunity count
- **Files affected:** ghl-setup.md (add condition to WF-02, WF-03, WF-05 through WF-08), pipeline.md (document the edge case and solution)

**Alternative approaches (more complex, for later):**

- Consolidate messages referencing multiple properties in one SMS
- Stagger workflows by a few hours so messages don't stack
- Use automation pre-check before GHL fires the message

---

### 3. GHL Looping Limitation

**Gap:** WF-05 Phase 2 (Cold Quarterly), WF-07 (Qualified Check-In), and WF-08 Phase 2 (Nurture Quarterly) all require looping behavior. GHL does not support native "go to step" loops, so without a solution these workflows end silently after the last built step.

**Why it matters:** Implementation blocker. Leads silently stop receiving messages when the workflow ends.

**Recommended approach — native re-enrollment:**

At the last step of each looping workflow, add an "Enroll in [this workflow]" action. The contact re-starts from step 1 indefinitely — no external tools needed.

**Fallback (if GHL blocks same-workflow re-enrollment):** Create a twin workflow (e.g. WF-07A with identical steps). WF-07 ends by enrolling in WF-07A; WF-07A ends by enrolling back in WF-07. Alternating between two identical workflows sidesteps any duplicate enrollment guard.

**Applies to:** WF-05 (Phase 2 last step), WF-07 (last step), WF-08 (Phase 2 last step)

- **Files affected:** ghl-setup.md (WF-05, WF-07, WF-08)

---

### 4. WF-11 Enrollment Filter & Edge Cases

**Gap:** WF-11 triggers on "Inbound SMS or Email reply received" but needs precise stage filtering to avoid misfiring on contacts in terminal stages (DNC, Purchased, etc.). Also no guard against re-triggering if lead replies twice during the 7-day review window.

**Why it matters:** Without the filter, every inbound reply from any contact fires WF-11, potentially creating duplicate work.

**Recommended changes:**

1. **Explicit enrollment filter** — add to WF-11 trigger:
  - Contact is in pipeline stage: Day 1-10, Day 11-30, Cold, Nurture, Dispo: No Motivation, Dispo: Wants Retail, Dispo: On MLS, OR Dispo: Lead Declined
  - AND contact is NOT tagged `Re-Engaged` (prevents re-trigger during 7-day window)
  - AND contact is NOT tagged `DNC`
2. **Auto-resume distinction in workflow logic (not enrollment filter):**
  - Active stages (Day 1-10, Day 11-30): No 7-day auto-resume. Owner manually clears `Pause WFs Until` field when ready.
  - Drip/dispo stages (Cold, Nurture, Dispo Re-Engage): 7-day auto-resume. `Pause WFs Until` date expires after 7 days and workflows resume automatically.
3. **Re-trigger guard** — if lead is already tagged `Re-Engaged`, do NOT re-enroll in WF-11.
4. **Negative-but-not-opt-out replies** — document handling for replies like "not interested" that don't use official opt-out keywords:
  - WF-11 still fires (it's an inbound reply)
  - Owner (LM or AM based on source) reviews within 7 days — if clearly negative, moves to appropriate Dispo
  - Consider adding a note in rules.md about "soft opt-outs" that should be treated as DNC even if keywords weren't used

- **Files affected:** ghl-setup.md (WF-11 trigger section), rules.md (add soft opt-out guidance)

---

## Improvements — Medium Priority (Implement Early)

---

### 5. Missed Call Text-Back (WF-12)

**Gap:** No automation when a lead calls Bana Land and nobody answers.

**Why it matters:** Inbound calls = highest intent. A missed call with no follow-up loses that momentum.

**Recommended addition — WF-12 | Missed Call Auto-Reply:**

- **Trigger:** Missed inbound call to Bana Land number
- **Enrollment condition:** Caller is a known contact AND NOT tagged DNC
- **Actions:**
  1. Send SMS (immediately): "Hey, sorry I missed your call — this is {{agent_name}} with Bana Land. I'll call you right back, or feel free to text me here."
  2. Create Task: "CALLBACK — {{first_name}} called and we missed it" — Assigned to: AM or Lead Manager (based on stage) — Due: Today — Priority: High
  3. Send internal notification: "Missed call from {{first_name}} — auto-text sent, callback task created"
- **Files affected:** ghl-setup.md (add WF-12), messaging.md (add missed call SMS template)

---

### 6. Property-Specific Merge Fields in Templates

**Gap:** NL-SMS-00 already uses {{county}}, but most other templates only use {{first_name}} and {{agent_name}}. Cold, Nurture, and Dispo Re-Engage templates do not reference any property details (county, acres).

**Why it matters:** "Checking in about your 40 acres in Garfield County" feels personal. "Checking in about your property" feels generic.

**Recommended changes:**

- Add GHL merge fields from Opportunity custom fields: {{opp.prop_county}}, {{opp.acres}}
- Update Cold and Nurture templates to reference county at minimum:
  - COLD-SMS-01: "...has anything changed with your land in {{opp.prop_county}}?"
  - COLDQ-EMAIL-01 subject: "Your property in {{opp.prop_county}} — Bana Land"
- Start with Cold/Nurture/Dispo Re-Engage templates. New Leads templates can stay generic since AM is actively personalizing via calls.

**Note:** Verify GHL merge field syntax for Opportunity fields. May need `{{opportunity.custom_field_name}}` format — test before bulk-updating templates.

- **Files affected:** messaging.md (update Cold, Nurture, and Quarterly templates), ghl-setup.md (note merge field syntax)

---

### 7. Message Variety in Quarterly Drips

**Gap:** COLDQ-SMS-01 and COLDQ-EMAIL-01 are the only quarterly templates. Leads see the same message every 90 days indefinitely.

**Why it matters:** Repetition = ignored. After 4 identical messages, leads stop reading. It also signals "this is obviously automated."

**Recommended changes:**

- Write 4-6 quarterly SMS variants and 4-6 quarterly email variants for Cold
- Write 3-4 quarterly SMS and email variants for Nurture
- Rotate through them so a lead doesn't see the same message for 1-2 years minimum
- Add seasonal/contextual angles:
  - Tax season: "Property taxes coming up — thinking about offloading any land?"
  - Year-end: "Any plans for your property heading into the new year?"
  - Market update: "We've been active buyers in {{opp.prop_county}} lately..."
  - Neighbor sold: "A property near yours sold recently — curious if you've thought about yours?"
- **Files affected:** messaging.md (add COLDQ-SMS-02 through -06, COLDQ-EMAIL-02 through -06, NURQ variants), sequences.md (update rotation schedule), ghl-setup.md (update WF-05, WF-08 to rotate)

---

### 8. Voicemail Strategy

**Gap:** Call tasks exist throughout Day 1-10, Day 11-30, and Qualified stages. No documented voicemail script, no logging convention, no voicemail + SMS combo.

**Why it matters:** 70-80% of calls go to voicemail. A voicemail followed immediately by an SMS dramatically increases callback rate.

**Recommended additions:**

1. **Voicemail script (NEPQ style, ~15 seconds):**
  - "Hey {{first_name}}, this is {{agent_name}} with Bana Land. I was calling about your property — had a quick question for you. Give me a call back when you get a chance: [CALLBACK NUMBER]. Thanks."
2. **Voicemail + SMS combo:** After leaving a voicemail, AM sends a quick SMS:
  - "Hey {{first_name}}, just left you a voicemail — give me a call back when you get a sec. — {{agent_name}}, Bana Land"
3. **Logging convention:** When AM leaves a voicemail, log "Voicemail Left" in contact notes with date.
4. **Ringless Voicemail Drops (RVM):** GHL supports RVM. Consider automated RVM drops for Day 11-30 touches to reduce team workload.

- **Files affected:** messaging.md (add voicemail scripts), rules.md (add voicemail protocol), ghl-setup.md (add RVM consideration for WF-03)

---

## Improvements — Lower Priority (Add Over Time)

---

### 9. Lead Scoring / Task Prioritization

**Gap:** No lead scoring. All call tasks appear equal in AM's queue.

**Why it matters:** AM time is the #1 bottleneck. Knowing which leads to call first directly impacts deal flow.

**Recommended approach (simple v1):**

- Score based on existing data: Acres, Tier 1 Market Price, Source, Age
- **Prospect Data note:** Acres, Market Price, and Age are all on the Property record. automation can calculate Lead Score before creating the Contact/Opportunity in New Leads — no manual entry needed.
- Implement as a GHL custom field "Lead Score" (Number) calculated by automation on entry
- Create Smart List: "Priority Calls Today" sorted by Lead Score descending
- Define criteria for "Hot" tag: Lead Score > X, or AM discretion
- **Files affected:** ghl-setup.md (add Lead Score field, Smart List), rules.md (Hot tag criteria)

---

### 10. Expired MLS Trigger

**Gap:** Dispo: On MLS leads receive generic Long-Term Drip. No awareness of when listing expires.

**Why it matters:** Expired MLS = seller tried retail, failed, now more motivated.

**Recommended approach:**

- Add Opportunity custom field: "MLS Listing Date" (Date)
- When AM dispos to On MLS, record the listing date
- Set a reminder at 90 and 180 days to verify listing status
- If listing expired: create high-priority task "MLS listing may have expired — contact {{first_name}}"
- Optional messaging angle: "I noticed your property was listed for a while — sometimes the market just isn't right. We're still interested if you'd consider a direct offer."
- **Files affected:** ghl-setup.md (add MLS Listing Date field), pipeline.md (add note to Dispo: On MLS)

---

### 11. Disposition Review / Quality Check

**Gap:** No process to verify AM disposition decisions. Once a lead is dispo'd, it's final.

**Why it matters:** Wrong dispos lose deals. New AMs especially may dispo too aggressively.

**Recommended approach:**

- Add Opportunity custom field: "Dispo Reason" (Large Text) — AM logs why they dispo'd
- Weekly manager review: spot-check 5-10 recent dispos for accuracy
- Monthly report: count of dispos by stage — helps identify patterns
- If a dispo is overturned: manager moves back to appropriate stage, workflow re-enrolls
- **Files affected:** ghl-setup.md (add Dispo Reason field), rules.md (add dispo review process)

---

## Decision Log


| #   | Item                   | Decision                                                        | Date       |
| --- | ---------------------- | --------------------------------------------------------------- | ---------- |
| 1   | Speed to Lead          | Pending                                                         | —          |
| 2   | Multi-Property Overlap | Simple workaround (skip auto, create manual task)               | —          |
| 3   | GHL Looping            | Native re-enrollment (Enroll in same WF at last step)           | 2026-03-17 |
| 4   | WF-11 Filter           | Pending                                                         | —          |
| 5   | Missed Call Text-Back  | Pending                                                         | —          |
| 6   | Property Merge Fields  | Pending                                                         | —          |
| 7   | Message Variety        | Pending                                                         | —          |
| 8   | Voicemail Strategy     | Pending                                                         | —          |
| 9   | Lead Scoring           | Pending                                                         | —          |
| 10  | Expired MLS Trigger    | Pending                                                         | —          |
| 11  | Dispo Review           | Pending                                                         | —          |
| 12  | Stage Consolidation    | 3 stages → 2: Day 1-10 + Day 11-30 (Tue/Thu). WF-04 eliminated. | 2026-03-18 |


