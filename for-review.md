# Bana Land — For Review

Catch-all for items that need attention before or after go-live: pre-launch verifications, cross-file consistency checks, improvement ideas, and open decisions.

Last updated: 2026-03-13

---

## Pre-Launch Verifications

Items that require hands-on GHL testing before go-live. Cannot be verified from documentation alone.

| Item                             | Account    | Workflow       | What to Verify                                                                             |
| -------------------------------- | ---------- | -------------- | ------------------------------------------------------------------------------------------ |
| Conditional SMS by phone field   | New Leads  | WF-00A Step 16 | GHL can send SMS to Phone 1–4 individually, skipping empty fields                          |
| Conditional SMS skip by tag      | New Leads  | WF-05          | GHL can branch on `Cold: Email Only` tag to skip SMS steps                                 |
| WF-00A conditional suppression   | New Leads  | WF-02/03/04    | Standard workflow steps are correctly skipped while contact is enrolled in WF-00A           |
| Workflow looping                 | New Leads  | WF-05, WF-08   | GHL does not natively loop workflows — plan for manual re-enrollment or extended build-out |
| DNC sync to Prospect Data        | New Leads  | WF-10          | Automation webhook updates Property record in Prospect Data on DNC                         |
| Prospect Data push automation    | Prospect Data | Automation  | Field mapping from Properties to Contact + Opportunity works correctly                     |
| Source-based task assignment      | New Leads  | WF-01/02/03/04 | Workflows correctly branch on source tag to assign tasks to LM vs AM                      |

---

## Cross-File Consistency Log

Last full re-run: 2026-03-13 (post-merge architecture — WR merged into NL, dual-owner model).

### Issues Found & Fixed (2026-03-13 Re-Run)

**I-01: sequences.md conflicted with ghl-setup.md on WF-00A suppression scope** — FIXED

sequences.md said standard emails still fire alongside WF-00A. ghl-setup.md said all three channels suppressed (correct per decision). Updated sequences.md to match: WF-00A is the sole communicator while active.

**I-02: new-leads/rules.md had stale pre-merge content** — FIXED

Referenced AM-only ownership and WR DNC sync. Updated to LM/AM dual-owner model and NL → Prospect Data sync only.

**I-03: prospect-data/data-model.md still referenced Warm Response as active destination** — FIXED

Data flow diagram, field mapping headers, and status description all referenced WR. Updated throughout to reflect NL-only routing. WR noted as empty placeholder.

**I-04: Source: Launch Control was a duplicate of Cold SMS** — FIXED

Launch Control is a platform for sending cold SMS, not a separate lead source. Removed `Source: Launch Control` tag and dropdown value entirely. Launch Control leads use `Source: Cold SMS`. Removed from all routing tables, tags, dropdown values, and lead source lists across all files.

### Notes — Not Conflicts, But Worth Documenting

**N-01: Offer Price % field — undocumented origin**

NL Opportunity custom fields include "Offer Price %" (Number), but this field doesn't exist in Prospect Data's Properties schema and isn't in the data-model.md field mapping table. It's unclear whether automation calculates it from Offer Price / Market Price on push, or whether it's manually entered. Should be documented in data-model.md field mapping section or noted as a manually-entered field.

**N-02: Latitude/Longitude/Map Link fields — not in current field mapping**

NL Opportunity custom fields include Latitude, Longitude, and Map Link. Prospect Data's Properties schema lists GPS and Map Link under "fields available if data source provides them (not in current CSV)." The data-model.md field mapping table doesn't include any of these three. Not an error today (data source doesn't provide them yet), but the mapping will need updating when the data source starts including them.

**N-03: Property State type mismatch between Prospect Data and NL**

Prospect Data stores Property State as Text. NL stores it as Dropdown (all US states). Automation must ensure the text value from Prospect Data matches a valid dropdown option when pushing to NL. Not currently documented as a mapping consideration in data-model.md.

**N-04: WF-07 looping limitation not flagged in for-review.md item #3**

WF-07 (Qualified Lead Check-In) says "Repeat / loop every 1-2 days until stage changes" — same GHL looping limitation as WF-05/WF-08. for-review.md item #3 only flags WF-05/WF-08. Lower severity since WF-07 loops are short-duration (active deals, days/weeks not years), but still worth noting.

**N-05: Owner mailing city/state/zip lost on push from Prospect Data**

Prospect Data Properties store full mailing address (street, city, state, zip) for each owner. The data-model.md field mapping only maps "Owner N Mailing Address → Address" (street). Mailing city, state, and zip don't map to any NL Contact field. GHL Contacts have native City, State, and Postal Code fields — the mapping table should include them.

**N-06: Phone Type data from skip trace doesn't map to NL**

Prospect Data Properties store Phone Type (Mobile, Residential, Landline, VoIP, etc.) for each of the 4 phones per owner. This data doesn't map to any NL Contact field. Relevant for WF-00A's one-time SMS blast to Phone 1–4 — sending SMS to a landline will fail silently. Phone Type could inform which numbers to SMS vs. call.

**N-07: for-review.md Decision Log items #11 and #12 have no improvement writeups**

Decision Log lists item #11 (Post-Purchase Referrals) and #12 (Deceased Protocol) as Pending, but neither has a corresponding improvement section with details, recommendations, or files affected. The writeups were either never created or were removed. Consider adding them or removing from the decision log.

---

### Verified — No Issues (2026-03-13, Post-Merge)

- **Nurture sequence** — internally consistent across pipeline.md, sequences.md, messaging.md, and ghl-setup.md (WF-08). Phase 1 monthly (3 months) → Phase 2 quarterly (indefinite). Both phases handled internally by WF-08. Template references match.
- **New Leads 30-day Cold entry** — consistent across NL pipeline.md, sequences.md, and ghl-setup.md (WF-04 → Cold → WF-05)
- **Cold drip sequence (WF-05)** — template references, timing, and `Cold: Email Only` SMS skip logic consistent across sequences.md, messaging.md, and ghl-setup.md
- **WF-00A Cold Email Sub-Flow** — email timing (Days 1, 3, 7, 14, 21), Day 30 SMS blast, suppression of WF-02/03/04 all consistent across pipeline.md, sequences.md, messaging.md, and ghl-setup.md
- **Day 1–30 sequence timing** — template references and day assignments in sequences.md match ghl-setup.md WF-02/03/04 step order and wait durations
- **Source tracking** — Original Source (immutable, set once) + Latest Source (updated on re-submission) + Latest Source Date. 7 dropdown values: Cold Call, Cold Email, Cold SMS, Direct Mail, VAPI AI Call, Referral, Website. Source tags match dropdown values. All 7 sources routed in WF-01/WF-11. (Launch Control removed — it's a platform for Cold SMS, not a separate source.)
- **Source → owner routing** — LM owns Cold Email/SMS/Call; AM owns Direct Mail/VAPI/Referral/Website. Consistent across pipeline.md, sequences.md, ghl-setup.md (WF-01, WF-11), and ROLE.md.
- **Campaign Type → destination routing** — all campaign types route to New Leads. Consistent between prospect-data/rules.md and data-model.md.
- **Prospect Data Campaign rules** — internally consistent between data-model.md and rules.md (naming convention, tag format, status values, campaign types)
- **Prospect Data field mapping** — complete and accurate for all fields that currently flow from Properties to Contact + Opportunity. Email 2–4 limitation explicitly noted. Offer Price mapping correct. Headers updated to NL-only. (Gaps in future/unmapped fields noted in N-01 through N-06)
- **Contact hours** — "9 AM – 7 PM local time" consistent across ROLE.md, rules.md §1, and ghl-setup.md compliance checklist
- **Template voice compliance** — spot-checked all SMS (≤ 2 sentences) and email (≤ 4 sentences) templates. All within limits. All identify sender as Bana Land or agent name.
- **Prospect Data DNC handling** — "DNC applies to the entire property record, not individual owners" consistent between PD data-model.md (DNC checkbox on Property) and PD rules.md §3
- **DNC protocol** — bi-directional (New Leads ↔ Prospect Data). WF-10 syncs to PD. Same trigger keywords (STOP/QUIT/UNSUBSCRIBE/CANCEL/END). No stale WR references.
- **LM/AM dual-owner model** — consistent across all files: both can dispo, LM sets appointment for AM at qualification, AM owns all qualified stages regardless of source.

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

**Why it matters:** 3 properties in Day 1-2 = 6 automated SMS in one day + 3 call tasks. Fast track to DNC.

**How common:** Rare but possible. Rural land owners sometimes have multiple parcels.

**Recommended approach (simple):**

- Add a workflow condition at the start of WF-02, WF-03, WF-04, WF-05, WF-08:
  - "If this contact has another active opportunity in the same stage group, skip automated messages and create a manual task instead"
  - AM handles multi-property contacts personally
- For Cold/Nurture drips: only send one message per contact regardless of opportunity count
- **Files affected:** ghl-setup.md (add condition to WF-02 through WF-08), pipeline.md (document the edge case and solution)

**Alternative approaches (more complex, for later):**

- Consolidate messages referencing multiple properties in one SMS
- Stagger workflows by a few hours so messages don't stack
- Use automation pre-check before GHL fires the message

---

### 3. GHL Looping Limitation

**Gap:** WF-05 Phase 2 (Cold Quarterly) and WF-08 Phase 2 (Nurture Quarterly) both say "loop" but GHL does not natively support workflow loops. If built as linear workflows, they end after the last step and leads silently stop receiving messages.

**Why it matters:** Implementation blocker. Without a solution, quarterly drips expire after the last built step.

**Three options:**

| Option                        | How It Works                                                                                                                   | Pros                                          | Cons                                                    |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------- | ------------------------------------------------------- |
| **A. Manual build-out**       | Build 3+ years of quarterly steps (12+ steps per workflow)                                                                     | Simple, no external dependency, easy to audit | Must remember to extend. If forgotten, leads go silent. |
| **B. automation webhook re-trigger** | At the end of WF-05/WF-08, fire a webhook to automation. automation removes the drip tag, waits, then re-adds it — re-triggering enrollment. | Truly indefinite. Set and forget.             | Adds automation dependency. If automation fails, drip stops.          |
| **C. Hybrid**                 | Build 2 years manually + automation webhook at the end as a safety net                                                                | Long runway + failsafe                        | Slightly more complex to set up                         |

**Recommendation:** Start with Option A (manual build-out, 3 years). Add Option B later as a safety net. Revisit annually.

**Decision needed:** Which option to use. Document in ghl-setup.md WF-05 and WF-08 notes.

- **Files affected:** ghl-setup.md (WF-05, WF-08)

---

### 4. WF-11 Enrollment Filter & Edge Cases

**Gap:** WF-11 triggers on "Inbound SMS or Email reply received" but needs precise stage filtering to avoid misfiring on contacts in terminal stages (DNC, Purchased, etc.). Also no guard against re-triggering if lead replies twice during the 7-day review window.

**Why it matters:** Without the filter, every inbound reply from any contact fires WF-11, potentially creating duplicate work.

**Recommended changes:**

1. **Explicit enrollment filter** — add to WF-11 trigger:
   - Contact is in pipeline stage: Day 1-2, Day 3-14, Day 15-30, Cold, Nurture, Dispo: No Motivation, Dispo: Wants Retail, Dispo: On MLS, OR Dispo: Lead Declined
   - AND contact is NOT tagged `Re-Engaged` (prevents re-trigger during 7-day window)
   - AND contact is NOT tagged `DNC`
2. **Auto-resume distinction in workflow logic (not enrollment filter):**
   - Active stages (Day 1-2, Day 3-14, Day 15-30): No 7-day auto-resume. Owner manually clears `Pause WFs Until` field when ready.
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

**Gap:** Templates only use {{first_name}} and {{agent_name}}. No messages reference the actual property (county, acres).

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

**Gap:** Call tasks exist throughout Day 1-2, Day 3-14, Day 15-30, and Qualified stages. No documented voicemail script, no logging convention, no voicemail + SMS combo.

**Why it matters:** 70-80% of calls go to voicemail. A voicemail followed immediately by an SMS dramatically increases callback rate.

**Recommended additions:**

1. **Voicemail script (NEPQ style, ~15 seconds):**
   - "Hey {{first_name}}, this is {{agent_name}} with Bana Land. I was calling about your property — had a quick question for you. Give me a call back when you get a chance: [CALLBACK NUMBER]. Thanks."
2. **Voicemail + SMS combo:** After leaving a voicemail, AM sends a quick SMS:
   - "Hey {{first_name}}, just left you a voicemail — give me a call back when you get a sec. — {{agent_name}}, Bana Land"
3. **Logging convention:** When AM leaves a voicemail, log "Voicemail Left" in contact notes with date.
4. **Ringless Voicemail Drops (RVM):** GHL supports RVM. Consider automated RVM drops for Day 11-14 and Day 15-30 touches to reduce AM workload.

- **Files affected:** messaging.md (add voicemail scripts), rules.md (add voicemail protocol), ghl-setup.md (add RVM consideration for WF-03, WF-04)

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

### 13. Disposition Review / Quality Check

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

| #   | Item                    | Decision                                          | Date |
| --- | ----------------------- | ------------------------------------------------- | ---- |
| 1   | Speed to Lead           | Pending                                           | —    |
| 2   | Multi-Property Overlap  | Simple workaround (skip auto, create manual task) | —    |
| 3   | GHL Looping             | Pending (3 options documented)                    | —    |
| 4   | WF-11 Filter            | Pending                                           | —    |
| 5   | Missed Call Text-Back   | Pending                                           | —    |
| 6   | Property Merge Fields   | Pending                                           | —    |
| 7   | Message Variety         | Pending                                           | —    |
| 8   | Voicemail Strategy      | Pending                                           | —    |
| 9   | Lead Scoring            | Pending                                           | —    |
| 10  | Expired MLS Trigger     | Pending                                           | —    |
| 11  | Post-Purchase Referrals | Pending                                           | —    |
| 12  | Deceased Protocol       | Pending                                           | —    |
| 13  | Dispo Review            | Pending                                           | —    |
