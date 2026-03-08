# Bana Land — System Improvements & Future Considerations

Strategic review of the follow-up system. All items are planning-only — no changes to existing files until decisions are made.

Generated: 2026-03-08

---

## Priority Tiers


| Tier       | Items                                                                                                          | When            |
| ---------- | -------------------------------------------------------------------------------------------------------------- | --------------- |
| **High**   | #1 Speed to Lead, #2 Multi-Property Overlap, #3 GHL Looping, #4 WF-11 Filter                                   | Before go-live  |
| **Medium** | #5 Missed Call Text-Back, #6 Property Merge Fields, #7 Message Variety, #8 Voicemail Strategy                  | Implement early |
| **Lower**  | #9 Lead Scoring, #10 Expired MLS Trigger, #11 Post-Purchase Referrals, #12 Deceased Protocol, #13 Dispo Review | Add over time   |


---

## HIGH PRIORITY — Address Before Go-Live

---

### 1. Speed to Lead

**Gap:** No speed-to-lead target. WF-00B creates a call task due "Today" — no urgency beyond that.

**Why it matters:** Calling within 5 minutes of a positive SMS response increases contact rate by 10x+ vs. calling within an hour. These leads said "yes" — they're hot right now.

**Recommended changes:**

- Document speed-to-lead targets:
  - SMS responders (Warm: SMS): **Call within 5 minutes**
  - Email responders (Warm: Email): **Reply email within 1 hour**
  - Re-submitted leads: **Call within 30 minutes**
- GHL implementation:
  - WF-00B Step 3: Change task to "CALL NOW" with real-time push notification to Lead Manager's phone
  - Add SMS alert to Lead Manager's personal number: "NEW WARM SMS LEAD — {{first_name}} — call now: {{phone}}"
  - Consider GHL auto-call bridge: system calls Lead Manager first, then auto-dials the lead
- **Files affected:** rules.md (add Section 11: Speed to Lead), ghl-setup.md (WF-00B notification), sequences.md (add timing note)

---

### 2. Multi-Property Cadence Overlap

**Gap:** Flagged in ghl-setup.md Step 3 but no solution. If one owner has multiple properties in the same stage, they receive duplicate automated messages for each opportunity.

**Why it matters:** 3 properties in Day 1-2 = 6 automated SMS in one day + 3 call tasks. Fast track to DNC.

**How common:** Rare but possible. Rural land owners sometimes have multiple parcels.

**Recommended approach (simple):**

- Add a workflow condition at the start of WF-02, WF-03, WF-04, WF-05, WF-06, WF-08:
  - "If this contact has another active opportunity in the same stage group, skip automated messages and create a manual task instead"
  - AM handles multi-property contacts personally
- For Cold/Nurture drips: only send one message per contact regardless of opportunity count
- **Files affected:** ghl-setup.md (add condition to WF-02 through WF-08), pipeline.md (document the edge case and solution)

**Alternative approaches (more complex, for later):**

- Consolidate messages referencing multiple properties in one SMS
- Stagger workflows by a few hours so messages don't stack
- Use n8n pre-check before GHL fires the message

---

### 3. GHL Looping Limitation

**Gap:** WF-06 (Cold Quarterly) and WF-08 Phase 2 (Nurture Quarterly) both say "loop" but GHL does not natively support workflow loops. If built as linear workflows, they end after the last step and leads silently stop receiving messages.

**Why it matters:** Implementation blocker. Without a solution, quarterly drips expire after the last built step.

**Three options:**


| Option                        | How It Works                                                                                                                   | Pros                                          | Cons                                                    |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------- | ------------------------------------------------------- |
| **A. Manual build-out**       | Build 3+ years of quarterly steps (12+ steps per workflow)                                                                     | Simple, no external dependency, easy to audit | Must remember to extend. If forgotten, leads go silent. |
| **B. n8n webhook re-trigger** | At the end of WF-06/WF-08, fire a webhook to n8n. n8n removes the drip tag, waits, then re-adds it — re-triggering enrollment. | Truly indefinite. Set and forget.             | Adds n8n dependency. If n8n fails, drip stops.          |
| **C. Hybrid**                 | Build 2 years manually + n8n webhook at the end as a safety net                                                                | Long runway + failsafe                        | Slightly more complex to set up                         |


**Recommendation:** Start with Option A (manual build-out, 3 years). Add Option B later as a safety net. Revisit annually.

**Decision needed:** Which option to use. Document the decision in ghl-setup.md WF-06 and WF-08 notes.

- **Files affected:** ghl-setup.md (WF-06, WF-08)

---

### 4. WF-11 Enrollment Filter & Edge Cases

**Gap:** WF-11 triggers on "Inbound SMS or Email reply received" but needs precise stage filtering to avoid misfiring on Day 1-2 / Day 3-14 / Day 15-30 contacts (already being worked by AM). Also no guard against re-triggering if lead replies twice during the 7-day review window.

**Why it matters:** Without the filter, every inbound reply from any contact fires WF-11. Day 1-2 leads would get paused and flagged when AM is already actively working them.

**Recommended changes:**

1. **Explicit enrollment filter** — add to WF-11 trigger:
  - Contact is in pipeline stage: Cold, Nurture, Dispo: No Motivation, Dispo: Wants Retail, Dispo: On MLS, OR Dispo: Lead Declined
  - AND contact is NOT tagged `Re-Engaged` (prevents re-trigger during 7-day window)
  - AND contact is NOT tagged `DNC`
2. **Re-trigger guard** — if lead is already tagged `Re-Engaged`, do NOT re-enroll in WF-11. The existing 7-day review is already in progress.
3. **Negative-but-not-opt-out replies** — document handling for replies like "not interested" or "stop bothering me" that don't use official opt-out keywords:
  - WF-11 still fires (it's an inbound reply)
  - AM reviews within 7 days — if clearly negative, AM manually moves to appropriate Dispo
  - Consider adding a note in rules.md about "soft opt-outs" that AM should treat as DNC even if keywords weren't used

- **Files affected:** ghl-setup.md (WF-11 trigger section), rules.md (add soft opt-out guidance)

---

## MEDIUM PRIORITY — Implement Early

---

### 5. Missed Call Text-Back (WF-12)

**Gap:** No automation when a lead calls Bana Land and nobody answers.

**Why it matters:** Inbound calls = highest intent. A missed call with no follow-up loses that momentum.

**Recommended addition:**

**WF-12 | Missed Call Auto-Reply**

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
- Start with Cold/Nurture/Dispo Re-Engage templates (long-term drip). New Leads templates can stay generic since AM is actively personalizing via calls.

**Note:** Verify GHL merge field syntax for Opportunity fields. May need `{{opportunity.custom_field_name}}` format — test before bulk-updating templates.

- **Files affected:** messaging.md (update Cold, Nurture, and Quarterly templates), ghl-setup.md (note merge field syntax)

---

### 7. Message Variety in Quarterly Drips

**Gap:** COLDQ-SMS-01 and COLDQ-EMAIL-01 are the only quarterly templates. Leads see the same message every 90 days indefinitely. Same issue with Nurture Quarterly.

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
- **Files affected:** messaging.md (add COLDQ-SMS-02 through -06, COLDQ-EMAIL-02 through -06, NURQ variants), sequences.md (update rotation schedule), ghl-setup.md (update WF-06, WF-08 to rotate)

---

### 8. Voicemail Strategy

**Gap:** Call tasks exist throughout Day 1-2, Day 3-14, Day 15-30, and Qualified stages. No documented voicemail script, no logging convention, no voicemail + SMS combo.

**Why it matters:** 70-80% of calls go to voicemail. A voicemail followed immediately by an SMS dramatically increases callback rate. Without a script, AM improvises or skips the voicemail entirely.

**Recommended additions:**

1. **Voicemail script (NEPQ style, ~15 seconds):**
  - "Hey {{first_name}}, this is {{agent_name}} with Bana Land. I was calling about your property — had a quick question for you. Give me a call back when you get a chance: [CALLBACK NUMBER]. Thanks."
  - Short, curious, no pitch, creates curiosity gap
2. **Voicemail + SMS combo:** After leaving a voicemail, AM sends a quick SMS:
  - "Hey {{first_name}}, just left you a voicemail — give me a call back when you get a sec. — {{agent_name}}, Bana Land"
3. **Logging convention:** When AM leaves a voicemail, log "Voicemail Left" in contact notes with date. This prevents the automated "missed call" SMS from also firing if WF-12 is implemented.
4. **Ringless Voicemail Drops (RVM):** GHL supports RVM. Consider using automated RVM drops for Day 11-14 and Day 15-30 touches where manual call volume is dropping anyway. Reduces AM workload while maintaining "call" presence.

- **Files affected:** messaging.md (add voicemail scripts), rules.md (add voicemail protocol), ghl-setup.md (add RVM consideration for WF-03, WF-04)

---

## LOWER PRIORITY — Add Over Time

---

### 9. Lead Scoring / Task Prioritization

**Gap:** No lead scoring. All call tasks appear equal in AM's queue.

**Why it matters:** AM time is the #1 bottleneck. Knowing which leads to call first directly impacts deal flow.

**Recommended approach (simple v1):**

- Score based on existing data:
  - Acres (more = higher priority for land wholesaling)
  - Tier 1 Market Price (higher value = higher priority)
  - Source (cold call > cold SMS > cold email for intent level)
  - Age (older owners more likely to sell)
- Implement as a GHL custom field "Lead Score" (Number) calculated by n8n on entry
- Create Smart List: "Priority Calls Today" sorted by Lead Score descending
- Define criteria for "Hot" tag: Lead Score > X, or AM discretion
- **Files affected:** ghl-setup.md (add Lead Score field, Smart List), rules.md (Hot tag criteria)

---

### 10. Expired MLS Trigger

**Gap:** Dispo: On MLS leads receive generic Long-Term Drip. No awareness of when listing expires.

**Why it matters:** Expired MLS = seller tried retail, failed, now more motivated. This is a prime trigger for wholesalers.

**Recommended approach:**

- Add Opportunity custom field: "MLS Listing Date" (Date)
- When AM dispos to On MLS, record the listing date
- Set a reminder (manual task or n8n check) at 90 and 180 days to verify listing status
- If listing expired: create high-priority task "MLS listing may have expired — contact {{first_name}}"
- Optional: different messaging — "I noticed your property was listed for a while — sometimes the market just isn't right. We're still interested if you'd consider a direct offer."
- **Files affected:** ghl-setup.md (add MLS Listing Date field), pipeline.md (add note to Dispo: On MLS)

---

### 11. Post-Purchase Referral Sequence

**Gap:** Dispo: Purchased is terminal with zero follow-up. The seller relationship ends at close.

**Why it matters:** Referral leads close at 3-5x the rate of cold leads. Closed sellers know other landowners. A 2-3 message sequence costs nothing and can generate high-value leads.

**Recommended addition:**

**WF-13 | Post-Purchase Follow-Up**

- **Trigger:** Contact moved to Dispo: Purchased
- **Actions:**
  1. Send SMS (Day 0 — closing day): "Hey {{first_name}}, glad we could get this done for you. If you ever need anything, don't hesitate to reach out. — {{agent_name}}, Bana Land"
  2. Wait: 30 days
  3. Send SMS: "Hey {{first_name}}, hope everything's going well since the sale. Quick question — do you know anyone else with land they might be thinking about selling? We'd love an introduction."
  4. Wait: 30 days
  5. Send Email: "Referral ask — longer form, explains the process, makes it easy to refer"
  6. End
- **Files affected:** ghl-setup.md (add WF-13), messaging.md (add post-purchase templates), pipeline.md (update Dispo: Purchased to note follow-up)

---

### 12. Deceased Owner Protocol

**Gap:** Age and Deceased custom fields exist on Contact but no documented handling when Deceased = true.

**Why it matters:** Automated messages to a deceased person upset the family and damage the brand. But the property still exists — probate/heir deals are a major wholesaling niche.

**Recommended approach:**

- If Deceased = true on any contact:
  - Pause all automated outreach immediately
  - Do NOT send standard templates ("Hey {{first_name}}..." to a deceased person)
  - AM reviews: skip trace for heirs, estate representatives, or probate attorney
  - If heir contact found: create new Contact record for heir, link to existing Opportunity
  - Different messaging tone: "We understand this property may be part of an estate. We work with families in these situations..."
- Add a tag: `Deceased` (stops all workflows via enrollment condition)
- Add a GHL enrollment condition to ALL workflows: "Contact NOT tagged Deceased"
- **Files affected:** rules.md (add Deceased Protocol section), ghl-setup.md (add Deceased tag + enrollment conditions), pipeline.md (add note)

---

### 13. Disposition Review / Quality Check

**Gap:** No process to verify AM disposition decisions. Once a lead is dispo'd, it's final.

**Why it matters:** Wrong dispos lose deals. New AMs especially may dispo too aggressively.

**Recommended approach:**

- Add Opportunity custom field: "Dispo Reason" (Large Text) — AM logs why they dispo'd
- Weekly manager review: spot-check 5-10 recent dispos for accuracy
- Monthly report: count of dispos by stage (how many No Motivation vs. Wants Retail vs. Not a Fit) — helps identify patterns
- If a dispo is overturned: manager moves back to appropriate stage, workflow re-enrolls
- **Files affected:** ghl-setup.md (add Dispo Reason field), rules.md (add dispo review process)

---

## Decision Log

Track decisions as they're made:


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


