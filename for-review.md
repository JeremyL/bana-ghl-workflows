# Bana Land — For Review

*Last edited: 2026-04-21 · Last reviewed: 2026-04-07*

Catch-all for items that need attention before or after go-live: pre-launch verifications, cross-file consistency checks, improvement ideas, and open decisions.

---

## Pre-Launch Verifications

Items that require hands-on GHL testing before go-live. Cannot be verified from documentation alone.


| Item                                          | Account       | Workflow                                     | What to Verify                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| --------------------------------------------- | ------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DNC sync to Prospect Data                     | New Leads     | WF-DNC-Handler                               | Automation webhook updates Property record in Prospect Data on DNC                                                                                                                                                                                                                                                                                                                                                                                                |
| Prospect Data push automation                 | Prospect Data | Automation                                   | Field mapping from Properties to Contact + Opportunity works correctly                                                                                                                                                                                                                                                                                                                                                                                            |
| Source-based task assignment                  | New Leads     | WF-New-Lead-Entry                            | Workflow correctly branches on Latest Source field to assign leads to LM vs AM                                                                                                                                                                                                                                                                                                                                                                                             |
| Manual stage move workflow exit               | New Leads     | All drip workflows                           | Test manual stage moves between LT FU stages (Cold ↔ Nurture ↔ Lost) and cross-pipeline moves (Acquisition → LT FU, Acquisition: Nurture → LT FU: Nurture) and status changes (Open → Lost → Open). Verify the prior workflow exits cleanly. Defensive removal steps in WF-Cold-Drip-Monthly, WF-Nurture-Monthly, and WF-Dispo-Re-Engage should also fire as belt-and-suspenders.                                                                                 |
| Status change to Lost triggers                | New Leads     | WF-Dispo-Re-Engage                           | Verify "Opportunity Status Changed → Lost" trigger fires WF-Dispo-Re-Engage correctly. Test If/Else branch: Drip reasons (No Motivation, Wants Retail, On MLS, Lead Declined) proceed to enrollment; No-Drip reasons (Not a Fit, No Longer Own, Exhausted, DNC) exit immediately.                                                                                                                                                                                  |
| Lost (DNC) triggers WF-DNC-Handler            | New Leads     | WF-DNC-Handler                               | Verify Lost + DNC reason triggers WF-DNC-Handler correctly. Test that Lost + other reasons do NOT trigger DNC handler (they trigger WF-Dispo-Re-Engage instead, which branches correctly).                                                                                                                                                                                                                                                                        |
| Lost → Open status flip                       | New Leads     | WF-New-Lead-Entry                            | On re-submission of a Lost lead (any non-DNC reason), verify: lost reason clears, status flips to Open, WF-New-Lead-Entry fires normally. DNC leads must be blocked.                                                                                                                                                                                                                                                                                              |
| WF-Abandoned-Alert fires on accidental use    | New Leads     | WF-Abandoned-Alert                           | Set a test contact to Abandoned status. Verify internal notification fires alerting team. Verify no other workflows trigger on Abandoned.                                                                                                                                                                                                                                                                                                                          |
| One-time migration: Abandoned → Lost          | New Leads     | Bulk action / API                            | Before go-live: bulk change all existing Abandoned contacts to Lost + set appropriate Lost Reason based on their `abandoned:` tag. Remove `abandoned:` tags after migration.                                                                                                                                                                                                                                                                                       |
| Pause ≤ today check                           | New Leads     | All drip workflows                           | GHL supports `Pause WFs Until` ≤ today (less than or equal) in Wait Until conditions. If not, fall back to setting pause to today+2 instead of today+3.                                                                                                                                                                                                                                                                                                           |
| Stale New Leads Smart List                    | New Leads     | N/A                                          | Smart List "Stale New Leads" correctly filters contacts in New Leads stage where native `lastStageChangeAt` > 24 hours ago. Verify Smart Lists can filter on this native Opportunity field. Daily notification fires to assigned owner.                                                                                                                                                                                                                           |
| Opportunity name UTF-8 encoding               | New Leads     | n8n intake                                   | Em dash (—) in opportunity name shows as `\u00e2\u20ac\u201d` in API response. Likely renders correctly in GHL UI — verify. If garbled, switch to a plain dash or add UTF-8 charset header to n8n API calls.                                                                                                                                                                                                                                                      |
| Re-sub stage change timestamp                 | New Leads     | n8n intake                                   | On re-submission, `lastStageChangeAt` was NOT updated when opportunity was already in New Leads stage. Test re-sub after manually moving a lead to a later stage (e.g. Day 1-10) to confirm GHL registers the stage reset back to New Leads. Now using native `lastStageChangeAt` as sole stage date source — this edge case matters more. If same-stage re-sub doesn't update the timestamp, Stale New Leads Smart List may immediately flag re-submitted leads. |
| Duplicate phone/email search results          | Prospect Data | n8n intake                                   | Test what happens when multiple Property records share the same phone or email (e.g. two properties with the same owner). Unlikely but possible. Current behavior: uses first result and sets `multi_match=true`. Verify this works correctly and the right record is selected. May need operator review flag or selection logic.                                                                                                                                 |
| Nurture Drip double-trigger on Lost           | New Leads     | WF-Nurture-Monthly / WF-Dispo-Re-Engage      | WF-Nurture-Monthly triggers on LT FU: Lost stage entry, but WF-Dispo-Re-Engage also explicitly enrolls into WF-Nurture-Monthly after moving to that stage (Steps 2 + 3). Verify GHL deduplicates and the contact is not enrolled twice. If not, remove explicit enrollment from WF-Dispo-Re-Engage or remove the Lost stage trigger from WF-Nurture-Monthly.                                                                                                      |
| Pull from PD — checkbox trigger               | New Leads     | WF-Pull-From-PD                              | Verify GHL fires workflow on Opportunity custom field change (checkbox `Pull from PD` checked). If Opportunity-level custom field triggers are not supported, fall back to a Contact-level custom field and map to the Opportunity via the contact-opportunity link.                                                                                                                                                                                                |
| Pull from PD — gap-fill merge                 | New Leads     | n8n pull workflow                            | Check `Pull from PD` on a test Opportunity with Reference ID set + some fields already populated. Verify: populated fields are NOT overwritten, empty fields ARE filled from PD, Source fields untouched, PD Snapshot Note appears on timeline, checkbox unchecked after execution.                                                                                                                                                                                |
| Pull from PD — error cases                    | New Leads     | n8n pull workflow                            | Test: (1) Opportunity with no Reference ID → error note posted, checkbox unchecked. (2) Reference ID with no PD match → error note, unchecked. (3) DNC Property → warning note, unchecked.                                                                                                                                                                                                                                                                        |
| Pull from PD — PD post-pull update            | Prospect Data | n8n pull workflow                            | After successful pull, verify PD Property record has Status = Pipeline and CRM Push Date = today.                                                                                                                                                                                                                                                                                                                                                                  |
| Shared sub-workflow — intake regression       | New Leads     | n8n intake workflow                          | After extracting Build Payloads into shared `Map PD to NL Fields` sub-workflow, verify intake workflow still functions identically: new lead creates Contact + Opportunity with full enrichment, re-submission updates correctly.                                                                                                                                                                                                                                   |


---

## Cross-File Consistency Log

Last full re-run: 2026-04-07 (full file-by-file cross-file audit — all files compared against all other files).

### Open Notes

- **CC13 — Open.** SVG diagram `day_0_to_30_sequence_detail.svg`: Day 11-30 section has 11 visual day-boxes with incorrect day numbers and channel color assignments. Actual sequence has 9 touches. Text label fixed (CC10), but visual nodes need to be reduced from 11 to 9, renumbered to match documented sequence (D11, D13, D14, D16, D19, D21, D23, D26, D27), and recolored to match channel types (SMS=green, Email=amber, RVM=pink). Deferred — diagram is informational, not authoritative.

---

## Improvements — Medium Priority (Implement Early)

---

### 5. Property-Specific Merge Fields in Templates

**Gap:** CO-SMS-00 already uses {{county}}, but most other templates only use {{first_name}} and {{agent_name}}. Cold, Nurture, and Dispo Re-Engage templates do not reference any property details (county, acres).

**Why it matters:** "Checking in about your 40 acres in Garfield County" feels personal. "Checking in about your property" feels generic.

**Blocked until:** GHL sub-account is set up and all custom fields are created. GHL generates its own merge field keys (e.g., `{{opportunity.property_county}}` or `{{opportunity.custom_field_key}}`), and we won't know the exact syntax until the fields exist.

**Post-setup steps:**

1. Create all custom fields in GHL (see data-model.md Custom Fields section)
2. Export / document the actual GHL merge field keys for each Opportunity custom field
3. Add a merge field reference table to data-model.md mapping our field names to GHL's generated keys
4. Update Cold, Nurture, and Dispo Re-Engage templates in messaging.md to use the correct merge fields (county at minimum, acres where it fits)
5. New Leads templates can stay generic — owner is actively personalizing via calls

- **Files affected:** data-model.md (add merge field reference table), messaging.md (update Cold, Nurture, and Quarterly templates with verified merge field syntax)

---

### 14. Email Bounce Handling Process

**Gap:** The `bounced` tag exists in data-model.md but there is no documented process for what happens when an email bounces. Rules.md §8 covers disconnected phone numbers but not bounced emails. Continued sends to bounced addresses damage sender reputation, which affects deliverability for ALL emails across the entire account.

**Why it matters:** Email deliverability is a shared resource. One bad address hurts every email you send.

**Recommended approach:**

1. Add bounce handling to rules.md §8 (Data Hygiene):
  - When email bounces → auto-tag `bounced` → immediately stop email sends to this Contact
  - Attempt Email 2-4 fallback from Prospect Data (see Improvement #15)
  - If no fallback available → convert to SMS/call-only contact
2. Configure GHL bounce webhook or automation to auto-apply `bounced` tag on hard bounce

- **Files affected:** rules.md (§8 expansion), workflows.md (bounce automation configuration)

---

### 15. Email 2-4 Fallback from Prospect Data

**Gap:** Only Email 1 maps from Prospect Data to New Leads (GHL Contacts natively support 1 email). If Email 1 bounces, Emails 2-4 sit unused in Prospect Data.

**Why it matters:** A lead with a bounced Email 1 loses an entire communication channel — but Email 2, 3, or 4 might work. These backup emails exist in Prospect Data and can rescue the lead.

**Recommended approach:**

1. When `bounced` tag is applied → look up the original Property record in Prospect Data (via Reference ID)
2. If Email 2, 3, or 4 exists for that owner → update Contact's email field with the next available email
3. Remove `bounced` tag → add `email fallback attempted` tag to prevent infinite loops
4. If that email also bounces → lead is truly email-dead, follow bounce handling process (Improvement #14)
5. This can be automated via webhook or manual via LM checklist

- **Files affected:** rules.md (fallback protocol), data-model.md (`email fallback attempted` tag), workflows.md (fallback process), prospect-data/rules.md (note Emails 2-4 as fallback source)

---

### 16. Phone Type-Aware Outreach

**Gap:** Prospect Data stores Phone Type for each number (Mobile, Residential, Landline, VoIP) but this data is not used. SMS to a landline fails silently — the lead appears unresponsive but never received the message.

**Why it matters:** Landlines are common among rural landowners (older demographic, rural areas). If Phone 1 is a landline and Phone 2 is a mobile, the system sends SMS to Phone 1 which never arrives. Every SMS in the Day 0-30 cadence is wasted on that lead.

**Recommended approach:**

1. **Pre-push validation in Prospect Data:** When pushing to New Leads, if Phone 1 Type = Landline and a Mobile number exists in Phone 2/3/4, swap so the Mobile number is Phone 1 (primary). This ensures SMS reaches a mobile number.
2. Map Phone Type fields to Contact custom fields in New Leads for visibility (Phone 1 Type, Phone 2 Type, etc.)
3. Add Phone Type awareness to SMS workflow steps — only send to phone fields that are Mobile type

- **Files affected:** prospect-data/data-model.md (add Phone Type to field mapping), prospect-data/rules.md (add phone type validation to pre-push rules), data-model.md (Phone Type custom fields)

---

### 17. Skip Trace Refresh Schedule

**Gap:** Prospect Data rules.md §6 mentions quarterly review of stale properties, but there is no systematic refresh schedule tied to Skip Trace Date age and no defined threshold for when data becomes unreliable.

**Why it matters:** Phone numbers go stale within 6-12 months. People move, change numbers, pass away. Campaigns targeting stale skip trace data waste money on disconnected numbers and lower response rates.

**Recommended approach:**

1. Add a documented refresh policy to prospect-data/rules.md §6:
  - **6 months:** Flag for re-skip-trace if being included in a new campaign
  - **12 months:** Mandatory re-skip-trace before any new campaign inclusion or push to New Leads
  - **Pre-push validation:** If Skip Trace Date > 12 months old, block push and flag for refresh
2. Add a Smart List or filter in Prospect Data: "Stale Skip Trace" = Status: blank + Skip Trace Date older than 12 months
3. Track re-skip-trace results: how many numbers changed, how many new numbers found — helps calibrate the refresh cadence over time

- **Files affected:** prospect-data/rules.md (§6 expansion with refresh schedule + pre-push validation)

---

### 18. Contract Signed Communication Cadence

**Gap:** Pipeline.md says "Keep seller informed" for Contract Signed, but there is no structured communication cadence. Sequences.md says "Regular deal management calls" with no specifics. Land closings take 30-60+ days with often-complicated title work (boundary disputes, easements, mineral rights, unclear chain of title).

**Why it matters:** Silence during the closing period causes sellers to panic, call their attorney, or back out. This is where deals fall apart — not because the terms were wrong, but because the seller felt abandoned. A simple weekly check-in prevents most deal falloff.

**Recommended approach:**

1. Add a Contract Signed communication cadence to sequences.md:
  - **Day 1 post-contract:** Expectations SMS — "Contract received. Here's what happens next: [brief title/closing process overview]. I'll keep you updated every step."
  - **Weekly:** Brief update SMS or call — "Title work is progressing, everything looks good" or "Ran into a small item with [X], working on it — nothing to worry about"
  - **Milestone notifications:** Title clear, closing date set, closing instructions sent
  - **Day before closing:** Confirmation SMS
2. Create 3-4 templates: CS-SMS-01 (contract received / expectations), CS-SMS-02 (weekly check-in), CS-SMS-03 (closing scheduled), CS-SMS-04 (day-before closing)
3. Semi-automated: AM manually triggers milestone messages, or a weekly timer fires CS-SMS-02 while opportunity is in Qualified: Contract Signed stage

- **Files affected:** messaging.md (add CS templates), sequences.md (add Contract Signed cadence), pipeline.md (expand Contract Signed stage notes)

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
- **Files affected:** data-model.md (add Lead Score field, Smart List), rules.md (Lead Score criteria)

---

### 9. Expired MLS Trigger

**Gap:** Lost (On MLS) leads receive generic Long-Term Drip. No awareness of when listing expires.

**Why it matters:** Expired MLS = seller tried retail, failed, now more motivated.

**Recommended approach:**

- Add Opportunity custom field: "MLS Listing Date" (Date)
- When AM marks Lost (On MLS reason), record the listing date
- Set a reminder at 90 and 180 days to verify listing status
- If listing expired: create high-priority task "MLS listing may have expired — contact {{first_name}}"
- Optional messaging angle: "I noticed your property was listed for a while — sometimes the market just isn't right. We're still interested if you'd consider a direct offer."
- **Files affected:** data-model.md (add MLS Listing Date field), pipeline.md (add note to Lost: On MLS reason)

---

### 10. Disposition Review / Quality Check

**Gap:** No process to verify AM disposition decisions. Once a lead is dispo'd, it's final.

**Why it matters:** Wrong dispos lose deals. New AMs especially may dispo too aggressively.

**Recommended approach:**

- Add Opportunity custom field: "Dispo Reason" (Large Text) — AM logs why they dispo'd
- Weekly manager review: spot-check 5-10 recent dispos for accuracy
- Monthly report: count of Lost status changes by reason — helps identify patterns
- If a dispo is overturned: manager moves back to appropriate stage, workflow re-enrolls
- **Files affected:** data-model.md (add Dispo Reason field), rules.md (add dispo review process)

---

### 19. AM Qualified Stage Playbook

**Gap:** The LM side of the system is exhaustively documented (cadence, templates, workflow steps). The AM Qualified stages (Comps/Pricing through Contract Signed) are a black box: "AM handles it, every 1-2 days." No qualification call framework, no offer presentation approach, no stall thresholds, no objection responses.

**Why it matters:** The AM is the revenue-generating role — everything before qualification is just filtering. If you hire a second AM or replace one, there is nothing to train from. The difference between a good and great AM is often a repeatable framework, not just instinct.

**Recommended approach:**

- Create a new file `new-leads/am-playbook.md` covering:
  - **Qualification call framework:** What to confirm (interest level, motivation, timeline, asking price, authority to sell, property condition/access)
  - **Offer presentation:** NEPQ-style approach — "Based on what I'm seeing, the range I'd be looking at is... how does that sit with you?"
  - **Stage advancement criteria:** Specific triggers for Comps/Pricing → Make Offer → Negotiations → Contract Sent → Contract Signed
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
  - **Core KPIs:** Response rate by source, speed-to-lead actual vs. 10-min target, stage conversion rates (Day 1-10 → Day 11-30, Day 11-30 → Cold, any stage → Due Diligence), qualification rate, close rate, time in each stage (average), cost per lead by source, revenue per lead by source
  - **Weekly dashboard:** New leads in, responses received, leads qualified, offers made, contracts sent, deals closed
  - **Monthly review:** Source performance comparison, cadence effectiveness (which templates get replies), stage funnel analysis, dispo breakdown
  - **GHL dashboard setup:** Which Smart Lists to check daily, which reports to run weekly
- Define framework now, implement after 30-60 days of live data
- **Files affected:** New file (reporting.md), README.md (file index), workflows.md (expand go-live dashboard section)

---

### 22. VAPI Integration Details

**Gap:** VAPI is listed as an inbound source with minimal documentation (data-model.md Lead Entry & Routing — Inbound). No script, no data flow, no quality thresholds documented.

**Why it matters:** If the VAPI collects bad data, asks the wrong questions, or fails to set expectations, the leads entering GHL will be low quality or confused by the follow-up. The handoff between AI and human is a critical moment.

**Recommended approach (GHL-side scope only — VAPI config is external):**

- Expand data-model.md Lead Entry & Routing — Inbound section with:
  - Minimum data requirements for a VAPI lead to enter the pipeline (name, county, phone at minimum)
  - What the AM should expect when reviewing a VAPI-sourced lead (transcript location, what to look for)
  - Quality threshold: if VAPI lead is missing key data, flag for manual review before workflow enrollment
- Add a "VAPI Lead Review" note to rules.md
- **Files affected:** data-model.md (Inbound section expansion), rules.md (VAPI review process)

---

### 23. Channel Preference Tracking

**Gap:** *(Note: Last Contact Type custom field was removed in audit fix H5 — GHL native tracking used instead.)* No channel preference tracking. If a lead always responds to SMS but never email, the system sends both on schedule regardless.

**Why it matters:** Rural demographics skew older and may strongly prefer phone/SMS over email, or vice versa. Adapting to preference increases response rate and reduces wasted touches.

**Recommended approach:**

- Add Contact custom field: "Preferred Channel" (Dropdown: SMS / Email / Call / Unknown)
- After 2+ responses from the same channel, LM/AM manually sets Preferred Channel
- In Cold and Nurture drips, add a branch: if Preferred Channel = SMS, double SMS touches and reduce email (and vice versa)
- **Note:** This is a v2 optimization. The workflow branching required is significant. Start with manual tracking, automate later.
- **Files affected:** data-model.md (new field), workflows.md (eventual branching), rules.md (channel preference tracking rule)

---

### 24. Seasonal Messaging Angles

**Gap:** All 45 templates are generic year-round. Land has genuine seasonal patterns — spring buyer demand, tax season selling motivation, year-end "clean slate" decisions.

**Why it matters:** Seasonal angles create natural urgency that generic messages lack. "Buyers are most active right now" in spring feels timely. "Checking in about your property" in January feels identical to the same message in July.

**Recommended approach:**

- Align quarterly drip templates (LTQ) to seasonal themes:
  - Q1 (Jan-Mar): Tax season / new year angle
  - Q2 (Apr-Jun): Spring buyer demand angle
  - Q3 (Jul-Sep): Summer/fall market activity angle
  - Q4 (Oct-Dec): Year-end clean slate angle
- **Challenge:** Quarterly timing follows the lead's enrollment date, not calendar quarters. A lead entering Cold in February hits "Q1 template" in May (90 days later), which is wrong seasonally. Proper implementation requires GHL date-based branching within WF-Long-Term-Quarterly to select templates by current month, not position in sequence. This adds significant workflow complexity.
- **Recommendation:** Implement only after the system is stable and producing data. Strong evergreen messaging first, seasonal layer second.
- **Files affected:** messaging.md (rewrite quarterly templates), workflows.md (date-based branching in WF-Long-Term-Quarterly)

---

### 25. Win-Back for "No Longer Own"

**Gap:** Lost (No Longer Own) has zero future outreach. These sellers sold the specific property we targeted, but may own other parcels.

**Why it matters:** Rural landowners frequently own multiple parcels across counties. "No Longer Own" doesn't mean "no longer a seller" — it means that specific property is gone. An annual check-in costs almost nothing.

**Recommended approach:**

- Add an optional annual SMS for "No Longer Own" contacts only: "Hey {{first_name}}, it's {{agent_name}} with Bana Land — I know you sold your property in {{opportunity.property_county}}. Do you have any other land you'd ever consider parting with?"
- 1 template (NLO-SMS-01), 1 lightweight workflow or manual annual touch
- Other Lost reasons (Not a Fit, DNC) and Won status stay as-is — "Not a Fit" is property-specific and unlikely to change, "Won" is covered by Improvement #20, "DNC" is untouchable
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

**Gap:** Prospect Data rules.md explicitly notes: "Currently manual — NL WF-New-Lead-Entry does not write back to Prospect Data to update campaign tags and CRM Push Date automatically." This means campaign tag stacking and CRM Push Date updates require manual work on every re-submission.

**Why it matters:** Manual steps get skipped, especially under volume. If campaign tags don't stack automatically, Prospect Data loses its history of which properties were sent to which campaigns. Source tracking becomes unreliable over time.

**Recommended approach:**

- Add a webhook or automation from WF-New-Lead-Entry to Prospect Data on re-submission detection:
  - Update the Property record's campaign tag (stack new tag alongside existing)
  - Update CRM Push Date to today
- Update prospect-data/rules.md to reflect automation instead of manual process
- **Files affected:** workflows.md (WF-New-Lead-Entry webhook step), prospect-data/rules.md (update re-submission section)

---

## Decision Log


| #   | Item                          | Decision                                                                                                                                                                                                                                                                                                                                                                                                            | Date       |
| --- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| 9   | Lead Scoring                  | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 10  | Expired MLS Trigger           | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 19  | Email Bounce Handling         | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 20  | Email 2-4 Fallback            | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 21  | Phone Type-Aware Outreach     | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 22  | Skip Trace Refresh            | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 23  | Under Contract Cadence        | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 24  | AM Playbook                   | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 26  | Reporting / KPIs              | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 27  | VAPI Integration Details      | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 28  | Channel Preference            | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 29  | Seasonal Messaging            | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 30  | Win-Back No Longer Own        | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 31  | NL-SMS-07 Wording             | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
| 32  | Re-Submission Write-Back      | Pending                                                                                                                                                                                                                                                                                                                                                                                                             | —          |
