#  file.Bana Land — For Review
*Last edited: 2026-03-20 · Last reviewed: 2026-03-20*

Catch-all for items that need attention before or after go-live: pre-launch verifications, cross-file consistency checks, improvement ideas, and open decisions.

---

## Pre-Launch Verifications

Items that require hands-on GHL testing before go-live. Cannot be verified from documentation alone.


| Item                           | Account       | Workflow            | What to Verify                                                                                                                                                                |
| ------------------------------ | ------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conditional SMS by phone field | New Leads     | WF-Cold-Email-Subflow Step 16      | GHL can send SMS to Phone 1–4 individually, skipping empty fields                                                                                                             |
| Conditional SMS skip by tag    | New Leads     | WF-Cold-Drip-Monthly, WF-Cold-Drip-Quarterly       | GHL can branch on `Cold: Email Only` tag to skip SMS steps                                                                                                                    |
| WF-Cold-Email-Subflow conditional suppression | New Leads     | WF-Day-1-10/03            | Standard workflow steps are correctly skipped while contact is enrolled in WF-Cold-Email-Subflow                                                                                             |
| Workflow looping               | New Leads     | WF-Cold-Drip-Quarterly, WF-Nurture-Quarterly      | Verify GHL "Add to Workflow" action can re-enroll a contact into the same workflow (enabling native loop). If blocked, implement twin-workflow fallback (see Improvement #2). |
| DNC sync to Prospect Data      | New Leads     | WF-DNC-Handler               | Automation webhook updates Property record in Prospect Data on DNC                                                                                                            |
| Prospect Data push automation  | Prospect Data | Automation          | Field mapping from Properties to Contact + Opportunity works correctly                                                                                                        |
| Source-based task assignment   | New Leads     | WF-New-Lead-Entry/02/03         | Workflows correctly branch on source tag to assign tasks to LM vs AM                                                                                                          |
| Manual stage move workflow exit | New Leads     | All drip workflows | Test manual stage moves between all drip stages (Cold ↔ Nurture ↔ Dispo Re-Engage ↔ Qualified) and verify the prior workflow exits cleanly. Defensive removal steps in WF-Cold-Drip-Monthly, WF-Nurture-Monthly, and WF-Dispo-Re-Engage should also fire as belt-and-suspenders. |
| Stale New Leads Smart List     | New Leads     | N/A                 | Smart List "Stale New Leads" correctly filters contacts in New Leads stage where Stage Entry Date > 24 hours ago. Daily notification fires to assigned owner. |


---

## Cross-File Consistency Log

Last full re-run: 2026-03-19 (full file-by-file cross-file audit).

### Open Notes

No open notes.

---

---

### Resolved Notes (2026-03-19)

- **N-28:** Changed `NL-SMS-07` → `NL-SMS-00A` for Day 0 missed-call SMS in pipeline.md line 76 and rules.md line 240. NL-SMS-07 is a Day 1-10 template; NL-SMS-00A is the correct Day 0 missed-call template.
- **N-29:** Changed messaging.md Nurture Monthly header from "first touch immediate on entry" → "30-day wait before first touch." Matches sequences.md and ghl-setup.md WF-Nurture-Monthly Step 1 (Wait: 30 days).
- **N-30:** Rewrote NURQ-EMAIL-03 in messaging.md to replace banned phrase "Just doing a check-in" → "Wanted to see if anything's changed on your end."
- **N-31:** Changed pipeline.md Negotiations Actions from "Daily call task. Light SMS automation for 'checking in' messages" → "Call every 1-2 days. SMS for quick follow-ups between calls." Removed false automation claim (qualified stages are human-only per sequences.md) and banned phrase.
- **N-32:** Changed Decision Log #1 speed-to-lead target from "5-min" → "10-min" to match rules.md §11 and sequences.md.
- **N-33:** Updated template count from 53 → 54 across for-review.md (verified section, N-23, Improvement #24) and MEMORY.md workflow index (was 43).
- **N-34:** Replaced garbled "through" workflow groupings in ghl-setup.md go-live checklist and README.md with explicit comma-separated list of all 12 workflows matching Step 6 index order.
- **N-35:** Expanded ROLE.md pipeline stage summary from `Cold → Qualified → Dispo → Nurture` → `Cold → Dispo (Terminal + Re-Engage) → Due Diligence → Make Offer → Negotiations → Contract Sent → Under Contract → Nurture`. Now matches actual pipeline order and names all qualified stages.
- **N-36:** Documented PD→NL DNC sync direction in prospect-data/rules.md (automation pushes DNC status to Contact in New Leads if one exists). Updated NL rules.md cheat sheet from "New Leads → Prospect Data" → "Bi-directional." DNC sync is confirmed bi-directional per user.
- **N-37:** Added 4 missing banned phrases to ROLE.md line 126 ("whenever you're ready," "keeping the door open," "just wanted to make sure you saw it," "we're still here"). List now matches messaging.md exactly (10 phrases). Removed "see messaging.md for full list" since the list is now complete.
- **N-38:** Changed pipeline.md Cold Email sub-flow from "runs concurrently with normal stage progression" → "runs concurrently with the Day 1–30 sequence (triggers on Day 1-10 entry)." Removes Day 0 ambiguity, matches ghl-setup.md trigger condition.

### Resolved Notes (2026-03-18)

- **N-12:** Standardized all county references to `{{opportunity.property_county}}` merge field syntax across all templates in messaging.md. Verify correct GHL Opportunity custom field syntax at build time.

- **N-13:** Removed "+ NEPQ" from README.md messaging.md description.
- **N-14:** Split WF-Cold-Drip-Monthly/WF-Nurture-Monthly into monthly + quarterly workflows (WF-Cold-Drip-Quarterly, WF-Nurture-Quarterly). See Decision Log #13.
- **N-15:** Removed Improvement #2 (Multi-Property Cadence Overlap) entirely. See Decision Log #2.
- **N-16:** Renamed COLD-SMS templates to sequential order (01/02/03) across messaging.md, sequences.md, ghl-setup.md.
- **N-17:** Changed "Bana Land Company" → "Bana Land" in ROLE.md.
- **N-18:** Added RVM to pipeline.md Day 11-30 Channels and Actions fields.
- **N-19:** Added "+ RVM (Day 11-30 only)" to ROLE.md Channel Strategy table.
- **N-20:** Changed WF-Cold-Drip-Monthly initial wait from 14d → 30d, added 30d initial wait to WF-Nurture-Monthly. Updated timing labels across sequences.md, messaging.md, and ghl-setup.md. Both Cold and Nurture now have a 30-day breather before first touch.
- **N-21:** Decision Log #4 updated from "Pending" to resolved (WF-Response-Handler Filter — stage filter, `Pause WFs Until`, soft opt-out guidance).
- **N-22:** Workflow count verified note updated from "11" to "12" (WF-Missed-Call-Textback was added after prior verification).
- **N-23:** Template count verified notes updated from "34" to "54" (quarterly, voicemail, and MC-SMS-01 templates added after prior verification).
- **N-24:** Changed NL prefix from "New Leads (Day 1-30)" to "New Leads (Day 0-30)" in messaging.md.
- **N-25:** Updated NL-SMS-07 stage to "New Leads / Day 1-10" and timing to "Day 0-1, Afternoon" in messaging.md.
- **N-26:** Clarified pipeline.md Cold Email sub-flow — standard steps suppressed while WF-Cold-Email-Subflow is active.
- **N-27:** Aligned Nurture quarterly transition to match Cold — removed trailing 30-day wait from WF-Nurture-Monthly, added leading 90-day wait to WF-Nurture-Quarterly. Both now: last monthly touch → enroll quarterly → 90-day wait → first quarterly touch.

---

### Verified — No Issues (2026-03-18)

- **Nurture sequence** — internally consistent across pipeline.md, sequences.md, messaging.md, and ghl-setup.md. Phase 1 monthly (WF-Nurture-Monthly: 30-day initial wait + 3 monthly sends) → Phase 2 quarterly (WF-Nurture-Quarterly: 90-day leading wait, indefinite self-loop). Template references match.
- **New Leads 30-day Cold entry** — consistent across NL pipeline.md, sequences.md, and ghl-setup.md (WF-Day-11-30 → Cold → WF-Cold-Drip-Monthly)
- **Cold drip sequence (WF-Cold-Drip-Monthly monthly + WF-Cold-Drip-Quarterly quarterly)** — template references, timing (30-day initial wait + 14-day spacing), and `Cold: Email Only` SMS skip logic consistent across sequences.md, messaging.md, and ghl-setup.md
- **WF-Cold-Email-Subflow Cold Email Sub-Flow** — email timing (Days 1, 3, 7, 14, 21), Day 30 SMS blast, suppression of WF-Day-1-10/03 all consistent across pipeline.md, sequences.md, messaging.md, and ghl-setup.md
- **Day 1–30 sequence timing** — template references and day assignments in sequences.md match ghl-setup.md WF-Day-1-10/03 step order and wait durations
- **Source tracking** — Original Source (immutable, set once) + Latest Source (updated on re-submission) + Latest Source Date. 7 dropdown values: Cold Call, Cold Email, Cold SMS, Direct Mail, VAPI AI Call, Referral, Website. Source tags match dropdown values. All 7 sources routed in WF-New-Lead-Entry/WF-Response-Handler.
- **Source → owner routing** — LM owns Cold Email/SMS/Call; AM owns Direct Mail/VAPI/Referral/Website. Consistent across pipeline.md, sequences.md, ghl-setup.md (WF-New-Lead-Entry, WF-Response-Handler), and ROLE.md.
- **Campaign Type → destination routing** — all campaign types route to New Leads. Consistent between prospect-data/rules.md and data-model.md.
- **Prospect Data Campaign rules** — internally consistent between data-model.md and rules.md (naming convention, tag format, status values, campaign types)
- **Prospect Data field mapping** — complete and accurate for all fields that currently flow from Properties to Contact + Opportunity. Email 2–4 limitation explicitly noted.
- **Contact hours** — "9 AM – 7 PM local time" consistent across ROLE.md, rules.md §1, and ghl-setup.md compliance checklist
- **Template voice compliance** — spot-checked all SMS (≤ 2 sentences) and email (≤ 4 sentences) templates. All within limits. All identify sender as Bana Land or agent name.
- **Prospect Data DNC handling** — "DNC applies to the entire property record, not individual owners" consistent between PD data-model.md (DNC checkbox on Property) and PD rules.md §3
- **DNC protocol** — bi-directional (New Leads ↔ Prospect Data). WF-DNC-Handler syncs to PD. Same trigger keywords (STOP/QUIT/UNSUBSCRIBE/CANCEL/END). No stale WR references.
- **LM/AM dual-owner model** — consistent across all files: both can dispo, LM sets appointment for AM at qualification, AM owns all qualified stages regardless of source.
- **Quick reference template-to-workflow mapping** — all 58 template IDs in messaging.md quick reference match their workflow assignments in ghl-setup.md.
- **WF-Dispo-Re-Engage Dispo Re-Engage stage list** — "No Motivation, Wants Retail, On MLS, Lead Declined" consistent across ghl-setup.md (WF-Dispo-Re-Engage), sequences.md, messaging.md Cold drip header, and pipeline.md Dispo Re-Engage definitions.
- **Nurture Phase 1/2 timing accuracy** — Phase 1 "Months 1–3" has 30-day initial wait + 3 monthly sends, Phase 2 starts with 90-day wait. Consistent across sequences.md, messaging.md, and ghl-setup.md (WF-Nurture-Monthly + WF-Nurture-Quarterly). Both Cold and Nurture use same transition pattern: last monthly touch → enroll quarterly → 90-day wait → first quarterly touch.
- **Age and Deceased fields** — present in both accounts. Age is Number type, Deceased is Text type. Consistent values for Deceased (Y / N / blank).
- **Stage consolidation (Day 1-10 / Day 11-30)** — stage names, definitions, and cadence descriptions consistent across all 5 New Leads files (pipeline.md, sequences.md, messaging.md, ghl-setup.md, rules.md) + ROLE.md + MEMORY.md. Zero references to old stage names (Day 1-2, Day 3-14, Day 15-30) in active files.
- **WF-04 elimination** — zero active-file references except Decision Log entry #12. Archive files retain old references (expected).
- **Workflow count** — 12 workflows confirmed across ghl-setup.md, MEMORY.md, and README.md (was 10 before monthly+quarterly split → 12 → 11 after WF-07 removal → 12 after WF-Missed-Call-Textback addition).
- **Template-to-workflow mapping post-consolidation** — all 58 template IDs in messaging.md quick reference re-verified against WF-Day-1-10 (Day 1-10) and WF-Day-11-30 (Day 11-30) assignments in ghl-setup.md. All match.
- **Day 11-30 cadence uniformity** — "Every 2–3 days (11 touches)" consistently described in pipeline.md, sequences.md, and ghl-setup.md WF-Day-11-30. Wait-step spacing, no day-of-week restriction.
- **Voicemail strategy** — 6 new template IDs (NL-VM-01, NL-VM-02, NL-VMSMS-01, NL-RVM-01/02/03) consistent across messaging.md quick reference, sequences.md Day 11-30 table, ghl-setup.md WF-Day-11-30 steps, and rules.md §12. Voicemail scripts comply with voice guidelines (short, casual, identifies Bana Land). RVM drops respect 9am–7pm send window and WF-Cold-Email-Subflow conditional logic.

---

## Improvements — Medium Priority (Implement Early)

---

### 5. Property-Specific Merge Fields in Templates

**Gap:** CO-SMS-00 already uses {{county}}, but most other templates only use {{first_name}} and {{agent_name}}. Cold, Nurture, and Dispo Re-Engage templates do not reference any property details (county, acres).

**Why it matters:** "Checking in about your 40 acres in Garfield County" feels personal. "Checking in about your property" feels generic.

**Blocked until:** GHL sub-account is set up and all custom fields are created. GHL generates its own merge field keys (e.g., `{{opportunity.property_county}}` or `{{opportunity.custom_field_key}}`), and we won't know the exact syntax until the fields exist.

**Post-setup steps:**

1. Create all custom fields in GHL (Step 3 of ghl-setup.md)
2. Export / document the actual GHL merge field keys for each Opportunity custom field
3. Add a merge field reference table to ghl-setup.md mapping our field names to GHL's generated keys
4. Update Cold, Nurture, and Dispo Re-Engage templates in messaging.md to use the correct merge fields (county at minimum, acres where it fits)
5. New Leads templates can stay generic — owner is actively personalizing via calls

- **Files affected:** ghl-setup.md (add merge field reference table), messaging.md (update Cold, Nurture, and Quarterly templates with verified merge field syntax)

---

### 14. Email Bounce Handling Process

**Gap:** The `Bounced` tag exists in ghl-setup.md but there is no documented process for what happens when an email bounces. Rules.md §8 covers disconnected phone numbers but not bounced emails. Continued sends to bounced addresses damage sender reputation, which affects deliverability for ALL emails across the entire account.

**Why it matters:** Email deliverability is a shared resource. One bad address hurts every email you send. For Cold Email leads especially, email is the primary (sometimes only) channel — a bounce with no fallback means that lead is dead.

**Recommended approach:**

1. Add bounce handling to rules.md §8 (Data Hygiene):
   - When email bounces → auto-tag `Bounced` → immediately stop email sends to this Contact
   - Attempt Email 2-4 fallback from Prospect Data (see Improvement #15)
   - If no fallback available → convert to SMS/call-only contact
   - For Cold Email leads with no phone + bounced email → dead lead → apply `Can't Find` tag or move to appropriate Dispo
2. Configure GHL bounce webhook or automation to auto-apply `Bounced` tag on hard bounce

- **Files affected:** rules.md (§8 expansion), ghl-setup.md (bounce automation configuration)

---

### 15. Email 2-4 Fallback from Prospect Data

**Gap:** Only Email 1 maps from Prospect Data to New Leads (GHL Contacts natively support 1 email). If Email 1 bounces, Emails 2-4 sit unused in Prospect Data. This is critical for Cold Email source leads where email is the only channel until a phone number is obtained via WF-Cold-Email-Subflow.

**Why it matters:** A Cold Email lead with a bounced Email 1 is completely unreachable — but Email 2, 3, or 4 might work. These backup emails exist in Prospect Data and can rescue the lead.

**Recommended approach:**

1. When `Bounced` tag is applied → look up the original Property record in Prospect Data (via Reference ID)
2. If Email 2, 3, or 4 exists for that owner → update Contact's email field with the next available email
3. Remove `Bounced` tag → add `Email Fallback Attempted` tag to prevent infinite loops
4. If that email also bounces → lead is truly email-dead, follow bounce handling process (Improvement #14)
5. This can be automated via webhook or manual via LM checklist

- **Files affected:** rules.md (fallback protocol), ghl-setup.md (`Email Fallback Attempted` tag + process), prospect-data/rules.md (note Emails 2-4 as fallback source)

---

### 16. Phone Type-Aware Outreach

**Gap:** Prospect Data stores Phone Type for each number (Mobile, Residential, Landline, VoIP) but this data is not used. SMS to a landline fails silently — the lead appears unresponsive but never received the message.

**Why it matters:** Landlines are common among rural landowners (older demographic, rural areas). If Phone 1 is a landline and Phone 2 is a mobile, the system sends SMS to Phone 1 which never arrives. Every SMS in the Day 0-30 cadence is wasted on that lead.

**Recommended approach:**

1. **Pre-push validation in Prospect Data:** When pushing to New Leads, if Phone 1 Type = Landline and a Mobile number exists in Phone 2/3/4, swap so the Mobile number is Phone 1 (primary). This ensures SMS reaches a mobile number.
2. Map Phone Type fields to Contact custom fields in New Leads for visibility (Phone 1 Type, Phone 2 Type, etc.)
3. Add Phone Type awareness to WF-Cold-Email-Subflow's Day 30 SMS blast (Step 16) — only send to phone fields that are Mobile type

- **Files affected:** prospect-data/data-model.md (add Phone Type to field mapping), prospect-data/rules.md (add phone type validation to pre-push rules), ghl-setup.md (Phone Type custom fields)

---

### 17. Skip Trace Refresh Schedule

**Gap:** Prospect Data rules.md §6 mentions quarterly review of stale properties, but there is no systematic refresh schedule tied to Skip Trace Date age and no defined threshold for when data becomes unreliable.

**Why it matters:** Phone numbers go stale within 6-12 months. People move, change numbers, pass away. Campaigns targeting stale skip trace data waste money on disconnected numbers and lower response rates.

**Recommended approach:**

1. Add a documented refresh policy to prospect-data/rules.md §6:
   - **6 months:** Flag for re-skip-trace if being included in a new campaign
   - **12 months:** Mandatory re-skip-trace before any new campaign inclusion or push to New Leads
   - **Pre-push validation:** If Skip Trace Date > 12 months old, block push and flag for refresh
2. Add a Smart List or filter in Prospect Data: "Stale Skip Trace" = Status: Active + Skip Trace Date older than 12 months
3. Track re-skip-trace results: how many numbers changed, how many new numbers found — helps calibrate the refresh cadence over time

- **Files affected:** prospect-data/rules.md (§6 expansion with refresh schedule + pre-push validation)

---

### 18. Under Contract Communication Cadence

**Gap:** Pipeline.md says "Keep seller informed" for Under Contract, but there is no structured communication cadence. Sequences.md says "Regular deal management calls" with no specifics. Land closings take 30-60+ days with often-complicated title work (boundary disputes, easements, mineral rights, unclear chain of title).

**Why it matters:** Silence during the closing period causes sellers to panic, call their attorney, or back out. This is where deals fall apart — not because the terms were wrong, but because the seller felt abandoned. A simple weekly check-in prevents most deal falloff.

**Recommended approach:**

1. Add an Under Contract communication cadence to sequences.md:
   - **Day 1 post-contract:** Expectations SMS — "Contract received. Here's what happens next: [brief title/closing process overview]. I'll keep you updated every step."
   - **Weekly:** Brief update SMS or call — "Title work is progressing, everything looks good" or "Ran into a small item with [X], working on it — nothing to worry about"
   - **Milestone notifications:** Title clear, closing date set, closing instructions sent
   - **Day before closing:** Confirmation SMS
2. Create 3-4 templates: UC-SMS-01 (contract received / expectations), UC-SMS-02 (weekly check-in), UC-SMS-03 (closing scheduled), UC-SMS-04 (day-before closing)
3. Semi-automated: AM manually triggers milestone messages, or a weekly timer fires UC-SMS-02 while opportunity is in Under Contract stage

- **Files affected:** messaging.md (add UC templates), sequences.md (add Under Contract cadence), pipeline.md (expand Under Contract stage notes)

---

## Improvements — Lower Priority (Add Over Time)

---

### 8. Lead Scoring / Task Prioritization

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

### 9. Expired MLS Trigger

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

### 10. Disposition Review / Quality Check

**Gap:** No process to verify AM disposition decisions. Once a lead is dispo'd, it's final.

**Why it matters:** Wrong dispos lose deals. New AMs especially may dispo too aggressively.

**Recommended approach:**

- Add Opportunity custom field: "Dispo Reason" (Large Text) — AM logs why they dispo'd
- Weekly manager review: spot-check 5-10 recent dispos for accuracy
- Monthly report: count of dispos by stage — helps identify patterns
- If a dispo is overturned: manager moves back to appropriate stage, workflow re-enrolls
- **Files affected:** ghl-setup.md (add Dispo Reason field), rules.md (add dispo review process)

---

### 19. AM Qualified Stage Playbook

**Gap:** The LM side of the system is exhaustively documented (cadence, templates, workflow steps). The AM qualified stages (Due Diligence through Under Contract) are a black box: "AM handles it, every 1-2 days." No qualification call framework, no offer presentation approach, no stall thresholds, no objection responses.

**Why it matters:** The AM is the revenue-generating role — everything before qualification is just filtering. If you hire a second AM or replace one, there is nothing to train from. The difference between a good and great AM is often a repeatable framework, not just instinct.

**Recommended approach:**

- Create a new file `new-leads/am-playbook.md` covering:
  - **Qualification call framework:** What to confirm (interest level, motivation, timeline, asking price, authority to sell, property condition/access)
  - **Offer presentation:** NEPQ-style approach — "Based on what I'm seeing, the range I'd be looking at is... how does that sit with you?"
  - **Stage advancement criteria:** Specific triggers for Due Diligence → Make Offer → Negotiations → Contract Sent → Under Contract
  - **Stall thresholds:** If no progress in X days in a stage, consider next action (escalate, Nurture, Dispo)
  - **Common objection responses:** Price too low, need to think about it, talking to other buyers, spouse needs to agree
- Link from sequences.md qualified section and pipeline.md qualified stage definitions

- **Files affected:** New file (am-playbook.md), pipeline.md (add advancement criteria), sequences.md (link to playbook), README.md (add to file index)

---

### 21. Reporting / KPI Framework

**Gap:** Zero documented KPIs, dashboards, or reporting cadence anywhere in the project. The go-live checklist mentions a monitoring dashboard but doesn't define what to monitor or what success looks like.

**Why it matters:** Can't improve what you don't measure. Land wholesaling has long sales cycles (often months). Without tracking response rates by source, stage conversion rates, and time-in-stage, you cannot tell which campaigns are working, whether the cadence is too aggressive or too passive, or where leads are getting stuck.

**Recommended approach:**

- Create a new file `new-leads/reporting.md` covering:
  - **Core KPIs:** Response rate by source, speed-to-lead actual vs. 5-min target, stage conversion rates (Day 1-10 → Day 11-30, Day 11-30 → Cold, any stage → Due Diligence), qualification rate, close rate, time in each stage (average), cost per lead by source, revenue per lead by source
  - **Weekly dashboard:** New leads in, responses received, leads qualified, offers made, contracts sent, deals closed
  - **Monthly review:** Source performance comparison, cadence effectiveness (which templates get replies), stage funnel analysis, dispo breakdown
  - **GHL dashboard setup:** Which Smart Lists to check daily, which reports to run weekly
- Define framework now, implement after 30-60 days of live data

- **Files affected:** New file (reporting.md), README.md (file index), ghl-setup.md (expand go-live dashboard section)

---

### 22. VAPI AI Call Integration Details

**Gap:** VAPI is listed as an inbound source with one paragraph of documentation (ghl-setup.md Entry Path 2). No script, no data flow, no quality thresholds documented.

**Why it matters:** If the VAPI AI call collects bad data, asks the wrong questions, or fails to set expectations, the leads entering GHL will be low quality or confused by the follow-up. The handoff between AI and human is a critical moment.

**Recommended approach (GHL-side scope only — VAPI config is external):**

- Expand ghl-setup.md Entry Path 2 with:
  - Minimum data requirements for a VAPI lead to enter the pipeline (name, county, phone at minimum)
  - What the AM should expect when reviewing a VAPI-sourced lead (transcript location, what to look for)
  - Quality threshold: if VAPI lead is missing key data, flag for manual review before workflow enrollment
- Add a "VAPI Lead Review" note to rules.md

- **Files affected:** ghl-setup.md (Entry Path 2 expansion), rules.md (VAPI review process)

---

### 23. Channel Preference Tracking

**Gap:** Last Contact Type is tracked on Contacts but never used for routing decisions. If a lead always responds to SMS but never email, the system sends both on schedule regardless.

**Why it matters:** Rural demographics skew older and may strongly prefer phone/SMS over email, or vice versa. Adapting to preference increases response rate and reduces wasted touches.

**Recommended approach:**

- Add Contact custom field: "Preferred Channel" (Dropdown: SMS / Email / Call / Unknown)
- After 2+ responses from the same channel, LM/AM manually sets Preferred Channel
- In Cold and Nurture drips, add a branch: if Preferred Channel = SMS, double SMS touches and reduce email (and vice versa)
- **Note:** This is a v2 optimization. The workflow branching required is significant. Start with manual tracking, automate later.

- **Files affected:** ghl-setup.md (new field + eventual branching), rules.md (channel preference tracking rule)

---

### 24. Seasonal Messaging Angles

**Gap:** All 58 templates are generic year-round. Land has genuine seasonal patterns — spring buyer demand, tax season selling motivation, year-end "clean slate" decisions.

**Why it matters:** Seasonal angles create natural urgency that generic messages lack. "Buyers are most active right now" in spring feels timely. "Checking in about your property" in January feels identical to the same message in July.

**Recommended approach:**

- Align quarterly drip templates (COLDQ, NURQ) to seasonal themes:
  - Q1 (Jan-Mar): Tax season / new year angle
  - Q2 (Apr-Jun): Spring buyer demand angle
  - Q3 (Jul-Sep): Summer/fall market activity angle
  - Q4 (Oct-Dec): Year-end clean slate angle
- **Challenge:** Quarterly timing follows the lead's enrollment date, not calendar quarters. A lead entering Cold in February hits "Q1 template" in May (90 days later), which is wrong seasonally. Proper implementation requires GHL date-based branching within WF-Cold-Drip-Quarterly/WF-Nurture-Quarterly to select templates by current month, not position in loop. This adds significant workflow complexity.
- **Recommendation:** Implement only after the system is stable and producing data. Strong evergreen messaging first, seasonal layer second.

- **Files affected:** messaging.md (rewrite quarterly templates), ghl-setup.md (date-based branching in WF-Cold-Drip-Quarterly/WF-Nurture-Quarterly)

---

### 25. Win-Back for "No Longer Own" Dispo

**Gap:** Terminal dispo "No Longer Own" has zero future outreach. These sellers sold the specific property we targeted, but may own other parcels.

**Why it matters:** Rural landowners frequently own multiple parcels across counties. "No Longer Own" doesn't mean "no longer a seller" — it means that specific property is gone. An annual check-in costs almost nothing.

**Recommended approach:**

- Add an optional annual SMS for "No Longer Own" contacts only: "Hey {{first_name}}, it's {{agent_name}} with Bana Land — I know you sold your property in {{opportunity.property_county}}. Do you have any other land you'd ever consider parting with?"
- 1 template (NLO-SMS-01), 1 lightweight workflow or manual annual touch
- Other terminal dispos (Not a Fit, Purchased, DNC) stay as-is — "Not a Fit" is property-specific and unlikely to change, "Purchased" is covered by Improvement #20, "DNC" is untouchable

- **Files affected:** pipeline.md (update No Longer Own notes), messaging.md (1 new template)

---

### 26. NL-SMS-07 Message-Truth Gap

**Gap:** NL-SMS-07 ("tried to reach you just now") fires automatically 4 hours after the Day 1 call task is created (WF-Day-1-10 Step 7), regardless of whether the LM/AM actually made the call. If the call task is still sitting in the queue, the SMS is inaccurate.

**Why it matters:** Minor but relevant — if the lead does pick up later and says "you said you tried to call, I didn't see a missed call," it erodes trust. The NEPQ approach emphasizes authenticity.

**Recommended approach:**

- Reword NL-SMS-07 to not imply a call was just made. Current: "tried to reach you just now." Suggested: "Hey {{first_name}}, this is {{agent_name}} with Bana Land — trying to connect with you about your property in {{opportunity.property_county}}. Here's my direct line: [CALLBACK NUMBER]"
- Alternatively, make NL-SMS-07 conditional on call task completion (if GHL supports this trigger)

- **Files affected:** messaging.md (revise NL-SMS-07 wording)

---

### 27. Re-Submission Write-Back Automation

**Gap:** Prospect Data rules.md explicitly notes: "Currently manual — NL WF-New-Lead-Entry does not write back to Prospect Data to update campaign tags and Account Push Date automatically." This means campaign tag stacking and Account Push Date updates require manual work on every re-submission.

**Why it matters:** Manual steps get skipped, especially under volume. If campaign tags don't stack automatically, Prospect Data loses its history of which properties were sent to which campaigns. Source tracking becomes unreliable over time.

**Recommended approach:**

- Add a webhook or automation from WF-New-Lead-Entry to Prospect Data on re-submission detection:
  - Update the Property record's campaign tag (stack new tag alongside existing)
  - Update Account Push Date to today
  - Re-check `Pushed to New Leads` checkbox
- Update prospect-data/rules.md to reflect automation instead of manual process

- **Files affected:** ghl-setup.md (WF-New-Lead-Entry webhook step), prospect-data/rules.md (update re-submission section)

---

## Decision Log


| #   | Item                   | Decision                                                        | Date       |
| --- | ---------------------- | --------------------------------------------------------------- | ---------- |
| 1   | Speed to Lead          | Push notification + SMS alert to owner. 10-min call target. No auto-call bridge. | 2026-03-18 |
| 2   | Multi-Property Overlap | Removed — not a real concern for this business.                 | 2026-03-18 |
| 3   | GHL Looping            | Native re-enrollment (Enroll in same WF at last step)           | 2026-03-17 |
| 4   | WF-Response-Handler Filter           | Stage filter added (Day 1-10, Day 11-30, Cold, Nurture, Dispo Re-Engage). `Re-Engaged` tag eliminated. `Pause WFs Until` prevents duplicate triggers. Soft opt-out guidance added. | 2026-03-18 |
| 5   | Missed Call Text-Back  | WF-Missed-Call-Textback built. 2-min delay, MC-SMS-01 template, no task. 11 → 12 workflows. | 2026-03-18 |
| 6   | Property Merge Fields  | Blocked until GHL setup. Export actual merge field keys after custom fields are created, then update templates. | 2026-03-18 |
| 7   | Message Variety        | 4 quarterly variants per channel (1-year cycle). Covers both Cold and Nurture. No additional variants needed. | 2026-03-18 |
| 8   | Voicemail Strategy     | VM scripts (NL-VM-01/02) + combo SMS (NL-VMSMS-01) for manual calls. 3 automated RVM drops in Day 11-30 (NL-RVM-01/02/03). Protocol in rules.md §12. | 2026-03-18 |
| 9   | Lead Scoring           | Pending                                                         | —          |
| 10  | Expired MLS Trigger    | Pending                                                         | —          |
| 11  | Dispo Review           | Pending                                                         | —          |
| 12  | Stage Consolidation    | 3 stages → 2: Day 1-10 + Day 11-30. WF-04 eliminated. | 2026-03-18 |
| 13  | Monthly/Quarterly Split | WF-Cold-Drip-Monthly → WF-Cold-Drip-Monthly + WF-Cold-Drip-Quarterly. WF-Nurture-Monthly → WF-Nurture-Monthly + WF-Nurture-Quarterly. Quarterly self-loops. 10 → 12 workflows. | 2026-03-18 |
| 14  | WF-07 Removed          | Qualified stages (Due Diligence → Under Contract) are human-led by AM. No automated workflow — smart lists are the safety net. 12 → 11 workflows. | 2026-03-18 |
| 15  | Re-Engaged Tag Removed | `Re-Engaged` tag eliminated. `Pause WFs Until` date field handles pausing + duplicate-trigger prevention. WF-Response-Handler stage filter + soft opt-out guidance added. | 2026-03-18 |
| 16  | Source-Specific Day 0  | 3-way source branch in WF-New-Lead-Entry Day 0: CO-SMS-00/00A (cold outbound), IN-SMS-00/00A (inbound), DM-SMS-00/00A (direct mail). 4 new templates, 54 → 58 total. | 2026-03-20 |
| 17  | Deceased Owner Protocol | No special handling. Known deceased owners — already talking to someone. Standard outreach applies. | 2026-03-18 |
| 18  | Multi-Owner Coordination | Not a GHL concern. Handled outside the system. Standard outreach for all owners. | 2026-03-18 |
| 19  | Email Bounce Handling  | Pending                                                         | —          |
| 20  | Email 2-4 Fallback     | Pending                                                         | —          |
| 21  | Phone Type-Aware Outreach | Pending                                                      | —          |
| 22  | Skip Trace Refresh     | Pending                                                         | —          |
| 23  | Under Contract Cadence | Pending                                                         | —          |
| 24  | AM Playbook            | Pending                                                         | —          |
| 25  | Post-Close & Referral  | Not implementing. Lifecycle ends at closing. | 2026-03-18 |
| 26  | Reporting / KPIs       | Pending                                                         | —          |
| 27  | VAPI Integration Details | Pending                                                       | —          |
| 28  | Channel Preference     | Pending                                                         | —          |
| 29  | Seasonal Messaging     | Pending                                                         | —          |
| 30  | Win-Back No Longer Own | Pending                                                         | —          |
| 31  | NL-SMS-07 Wording      | Pending                                                         | —          |
| 32  | Re-Submission Write-Back | Pending                                                       | —          |


