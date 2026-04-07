# Quick Reference — New Leads Outreach

*Last edited: 2026-04-07 · Last reviewed: 2026-04-07*

Every outreach touch across the New Leads pipeline — stage by stage, with template IDs and message counts.
Templates follow `PREFIX-CHANNEL-##` format. Owner = LM (Cold SMS/Call) or AM (Direct Mail/VAPI/Referral/Website).

```
[ALL SOURCES: Cold SMS / Cold Call / Direct Mail / VAPI / Referral / Website / Re-Submission]
  └─► NEW LEADS — Day 0: Speed to Lead (immediate on entry)
        │   SMS varies by source (120s wait):
        │     Cold SMS / Cold Call ────────────────► CO-SMS-00
        │     Website / VAPI / Referral ───────────► IN-SMS-00
        │     Direct Mail ─────────────────────────► DM-SMS-00
        │   After SMS ──► Call (manual)
        │   ~1hr later ──► Missed-call SMS if no call logged:
        │     Cold SMS / Cold Call ────────────────► CO-SMS-00A
        │     Website / VAPI / Referral ───────────► IN-SMS-00A
        │     Direct Mail ─────────────────────────► DM-SMS-00A
        │   Totals: 2 SMS, 1 Call (per lead — template varies by source)
        │
        └─► DAY 1-10 — Active Daily Pursuit (10 calendar days)
              │
              │   Days 1-2 (2x per day):
              │     Day 1:  SMS (NL-SMS-01) ──► SMS (NL-SMS-07)
              │     Day 2:  Email (NL-EMAIL-01) ──► SMS (NL-SMS-02)
              │
              │   Days 3-10 (1x per day, rotating):
              │     Day 3:  SMS (NL-SMS-10)
              │     Day 4:  Email (NL-EMAIL-05)
              │     Day 5:  Email (NL-EMAIL-02)
              │     Day 6:  SMS (NL-SMS-03)
              │     Day 7:  SMS (NL-SMS-08)
              │
              │   No automated call tasks — owner calls manually as needed
              │   Totals: 6 SMS, 3 Emails
              │
              └─► Qualifies ────────────────────────────────────────► COMP (within Acquisition) (AM takes over)
              └─► No response by Day 11 ────────────────────────────► DAY 11-30
                    │
                    │   Day 11-30 — Winding Down (every 2-3 days, 9 touches over 20 days)
                    │     Day 11: SMS (NL-SMS-04)
                    │     Day 13: RVM (NL-RVM-01)
                    │     Day 14: Email (NL-EMAIL-03)
                    │     Day 16: SMS (NL-SMS-09)
                    │     Day 19: RVM (NL-RVM-02)
                    │     Day 21: SMS (NL-SMS-05)
                    │     Day 23: RVM (NL-RVM-03)
                    │     Day 26: Email (NL-EMAIL-04)
                    │     Day 27: SMS (NL-SMS-06)
                    │
                    │   No automated call tasks — owner calls manually as needed
                    │   Totals: 4 SMS, 2 Emails, 3 RVM
                    │
                    └─► Qualifies ──────────────────────────────────► COMP (within Acquisition) (AM takes over)
                    └─► No response by Day 30 ──────────────────────► [04 : LT FU] Cold → COLD MONTHLY
                    └─► DNC request ────────────────────────────────► Lost (DNC) — zero contact, permanent

--- COLD MONTHLY (Months 1-3 — fully automated) ---

COLD MONTHLY (SMS + Email alternating every ~14 days)
  │     Day 30:  SMS (COLD-SMS-01)
  │     Day 44:  Email (COLD-EMAIL-01)
  │     Day 58:  SMS (COLD-SMS-02)
  │     Day 72:  Email (COLD-EMAIL-02)
  │     Day 86:  SMS (COLD-SMS-03)
  │     Day 100: Email (COLD-EMAIL-03)
  │
  │   Totals: 3 SMS, 3 Emails
  │
  └─► After Month 3 ──────────────────────────────────────────────► Long-Term Quarterly

--- NURTURE MONTHLY (Months 1-3 — fully automated) ---

NURTURE MONTHLY (alternating SMS + Email)
  │     Month 1: SMS (NUR-SMS-01)
  │     Month 2: Email (NUR-EMAIL-01)
  │     Month 3: SMS (NUR-SMS-02)
  │   Totals: 2 SMS, 1 Email
  │
  └─► After Month 3 ──────────────────────────────────────────────► Long-Term Quarterly

--- LONG-TERM QUARTERLY (Month 4-28 — shared, fully automated) ---

Fed by: Cold Monthly, Nurture Monthly, and Lost (via WF-Dispo-Re-Engage)
SMS + Email same day, every 90 days — Q1-Q4 plays twice (24 months), then stops

  │     Q1: SMS (LTQ-SMS-01) + Email (LTQ-EMAIL-01)
  │     Q2: SMS (LTQ-SMS-02) + Email (LTQ-EMAIL-02)
  │     Q3: SMS (LTQ-SMS-03) + Email (LTQ-EMAIL-03)
  │     Q4: SMS (LTQ-SMS-04) + Email (LTQ-EMAIL-04)
  │     ↻ plays Q1-Q4 twice (24 months), then stops
  │
  │   Totals: 4 SMS, 4 Emails (x2 = 8 SMS, 8 Emails over 24 months)
  │
  └─► Re-engages (replies to drip) ───────────────────────────────► Owner reviews (3-day window)
  └─► DNC request ─────────────────────────────────────────────────► Lost (DNC) — zero contact, permanent

--- LOST — DRIP REASONS (Status + Lost Reason → Long-Term Drip) ---

Lost (No Motivation) ─────────────────────────────────────────────► Cold Monthly → Long-Term Quarterly (same drip)
Lost (Wants Retail) ──────────────────────────────────────────────► Cold Monthly → Long-Term Quarterly (same drip)
Lost (On MLS) ────────────────────────────────────────────────────► Cold Monthly → Long-Term Quarterly (same drip)
Lost (Lead Declined) ─────────────────────────────────────────────► Cold Monthly → Long-Term Quarterly (same drip)

--- LOST — NO-DRIP REASONS (no further outreach) ---

Lost (Not a Fit) ─────────────────────────────────────────────────► No outreach. Re-submission allowed.
Lost (No Longer Own) ─────────────────────────────────────────────► No outreach. Re-submission allowed.
Lost (Exhausted) ─────────────────────────────────────────────────► No outreach. Re-submission allowed.
Lost (DNC) ───────────────────────────────────────────────────────► Zero contact. Re-submission BLOCKED.

--- MISSED CALL TEXT-BACK (any stage) ---

Missed inbound call ──► 2 min wait ──► SMS (MC-SMS-01)

═══════════════════════════════════════════════════════════════════

TEMPLATE TOTALS (45 unique templates)

  SMS ········ 27   NL-SMS (10) · CO-SMS (2) · IN-SMS (2) · DM-SMS (2) · COLD-SMS (3) · LTQ-SMS (4) · NUR-SMS (2)
                    NL-VMSMS (1) · MC-SMS (1)
  Email ······ 13   NL-EMAIL (5) · COLD-EMAIL (3) · LTQ-EMAIL (4) · NUR-EMAIL (1)
  RVM ········  3   NL-RVM-01, 02, 03
  VM Script ··  2   NL-VM-01, NL-VM-02
```

