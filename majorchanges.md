# Major Changes — Lead Manager Expansion

Working document for planning the Lead Manager role expansion. **Architecture decision made — implementing.**

---

## What's Changing

### 1. Lead Manager becomes a real hire
Previously "Lead Manager" was a label. Now it's a dedicated person with a defined role across multiple lead sources.

### 2. Lead Manager owns the full first 30 days for three sources
LM handles the **entire pre-qualification follow-up** for:
- **Cold SMS** — previously in Warm Response
- **Cold Email** — previously in Warm Response
- **Cold Call** — previously went straight to AM in New Leads

This is the full 30-day follow-up window. All the calling, all the SMS/email touches, everything until either they qualify or hit Day 30 and go to Cold drip. The LM's first successful phone conversation IS the qualifying call (interest, motivation, price).

### 3. Acquisition Manager's role splits by source

**LM-sourced leads (Cold Email, Cold SMS, Cold Call):**
- LM handles Days 1–30 in New Leads: all follow-up, all calling, qualifying call
- AM gets the lead **only after LM qualifies** — AM makes the offer call (one call)

**AM-sourced leads (VAPI, Direct Mail, Referral, Website):**
- Already considered qualified (the person came to us)
- AM handles from Day 1: fact-finding first call + offer second call
- AM keeps the full multi-call lifecycle (unchanged)

### 4. Lead source routing (all sources → New Leads)

| Source | Before | After |
|---|---|---|
| Cold Email | → WR (14d LM) → NL (30d AM) | → NL (30d LM) → AM (offer only) |
| Cold SMS | → WR (14d LM) → NL (30d AM) | → NL (30d LM) → AM (offer only) |
| Cold Call | → NL (30d AM) | → NL (30d LM) → AM (offer only) |
| Direct Mail | → NL (AM from day 1) | No change |
| VAPI | → NL (AM from day 1) | No change |
| Referral | → NL (AM from day 1) | No change |
| Website | → NL (AM from day 1) | No change |

---

## Architecture Decision: Merge WR → NL (Option B)

**Decision:** Merge all Warm Response functionality into New Leads. One working account for all leads.

**Warm Response account:** Kept as an empty placeholder for potential future use (backup phone numbers, sender reputation protection if needed). No active workflows, no pipeline, no contacts.

**Why merge:** The LM now owns 30 days of follow-up for three sources — the same cadence that NL already has. Having two accounts doing the same thing with cross-account webhooks adds complexity for no benefit. Everything in one pipeline is cleaner.

**Sender reputation note:** Accepted risk. If cold outreach spam rates cause deliverability issues, we can revisit and use WR as a dedicated outreach account. For now, consolidating.

---

## Proposed New Leads Pipeline (Merged)

The pipeline stages stay the same — they represent time buckets, not owners. The workflows branch on source tag to assign tasks to LM or AM.

### Pipeline Stages

**Pre-Qualification (Day 1–30):**
1. **New Lead** — entry point for ALL sources
2. **Day 1-2** — aggressive follow-up (2x daily)
3. **Day 3-14** — daily follow-up
4. **Day 15-30** — tapering (Tue/Thu only)

**Long-Term Drip:**
5. **Cold** — monthly → quarterly automated drip (same as today)

**Qualified (AM owns from here):**
6. **Due Diligence** — AM reviews, runs comps, prepares offer
7. **Offer Made** — offer delivered, waiting for response
8. **Negotiations** — back and forth on price/terms
9. **Under Contract** — signed, headed to close

**Disposition:**
10. **Nurture** — deal fell through but relationship intact
11. **Dispo: No Motivation** — re-engage drip
12. **Dispo: Wants Retail** — re-engage drip
13. **Dispo: On MLS** — re-engage drip
14. **Dispo: Lead Declined** — re-engage drip
15. **Dispo: DNC** — terminal, zero contact

### How Source Determines Owner (Day 1–30)

The key: same pipeline stages, different task assignment based on source.

| Source Tag | Day 1–30 Owner | Call Tasks Assigned To | Qualifying Call By | After Qualification |
|---|---|---|---|---|
| `Source: Cold Email` | Lead Manager | LM | LM | → Due Diligence (AM makes offer) |
| `Source: Cold SMS` | Lead Manager | LM | LM | → Due Diligence (AM makes offer) |
| `Source: Cold Call` | Lead Manager | LM | LM | → Due Diligence (AM makes offer) |
| `Source: Direct Mail` | Acquisition Manager | AM | AM | → Due Diligence (AM continues) |
| `Source: VAPI AI Call` | Acquisition Manager | AM | AM | → Due Diligence (AM continues) |
| `Source: Referral` | Acquisition Manager | AM | AM | → Due Diligence (AM continues) |
| `Source: Website` | Acquisition Manager | AM | AM | → Due Diligence (AM continues) |

### Cold Email Special Handling

Cold Email leads may not have a phone number on entry. They get a special sub-flow within the Day 1–30 stages:

- **Phase 1 (no phone #):** Automated emails asking for phone number (same WR-EMAIL templates, rebranded). Runs concurrently with normal stage progression.
- **Phase 2 (phone # received):** LM call tasks begin. Normal Day 1–30 cadence applies from this point.
- **Day 30 with no phone # received:** One-time SMS blast to skip-traced numbers → Cold stage with `Cold: Email Only` tag (email-only drip).

### What Gets Eliminated

- **WF-HANDOFF** — no cross-account transfer needed (same account)
- **WF-CLEANUP** — no cross-account cleanup needed
- **Cross-account DNC sync (WR ↔ NL)** — single account, one DNC workflow handles it
- **Duplicate custom fields/tags** — one set of everything
- **WR-specific Cold drip** — one Cold drip workflow (WF-05) for all leads

### What Gets Added/Changed

- **WF-01 (New Lead Entry)** — branches on source tag: LM sources → assign to LM, AM sources → assign to AM
- **WF-02, WF-03, WF-04 (Day 1-2, Day 3-14, Day 15-30)** — branch on source tag for task assignment (LM or AM)
- **Cold Email sub-flow** — WF-00A equivalent moves into NL (email phase before call phase)
- **Cold Call track tag** — `Source: Cold Call` (already exists, just needs workflow routing)
- **DNC sync** — simplified to NL ↔ Prospect Data (bi-directional, not tri-directional)

---

## Open Questions (answer as we implement)

### Q5: LM dispo outcomes ✅
When LM connects and the lead doesn't qualify, what happens?

**Answer:** LM can dispo to any Dispo stage (same as AM). No LM-specific dispo stages. If LM qualifies → Due Diligence. If not → appropriate Dispo stage or keep working within 30 days.

### Q6: AM data needs from qualifying call ✅
With everything in one account, AM just reads the contact notes and custom fields in GHL. No webhook needed.

**Answer:** LM logs qualifying call notes (interest, motivation, asking price) on the contact record. AM sees everything — same account, full visibility. **Handoff mechanism:** LM sets a call appointment for AM to call the qualified lead. If the lead misses the AM appointment call, AM owns follow-up from that point forward.

---

## Decisions Made

| # | Question | Decision | Date |
|---|----------|----------|------|
| 1 | Architecture (A or B)? | **B — Merge WR into NL.** WR stays as empty placeholder. | 2026-03-13 |
| 2 | LM 30-day follow-up | Same Day 1-30 cadence as current NL, but LM-owned for Cold Email/SMS/Call | 2026-03-13 |
| 3 | NL pipeline structure | Same stages, workflows branch on source tag for LM vs AM task assignment | 2026-03-13 |
| 4 | Cold drip | One WF-05 in NL for all leads. `Cold: Email Only` tag still applies. | 2026-03-13 |
| 5 | LM dispo stages | **LM uses same dispo stages as AM.** No LM-specific stages. | 2026-03-13 |
| 6 | AM data from qualifying call | **LM logs notes + sets call appointment for AM.** AM owns follow-up if lead misses. | 2026-03-13 |

---

## Implementation Plan

### Phase 1 — Update majorchanges.md (this file) ✅
### Phase 2 — Update New Leads files (merge WR content in) ✅
- pipeline.md — add LM ownership, Cold Email track, Cold Call track
- sequences.md — add LM 30-day cadence, email track, cold call track
- messaging.md — merge WR templates in
- ghl-setup.md — merge WR workflows, remove WF-HANDOFF/CLEANUP, update WF-01/02/03/04 for dual-owner

### Phase 3 — Strip Warm Response files to placeholder ✅
- All WR files → minimal placeholder content

### Phase 4 — Update root files ✅
- ROLE.md, README.md, rules.md, for-review.md — reflect merged architecture
- prospect-data/rules.md — all sources route to NL

### Phase 5 — Update MEMORY.md ✅
