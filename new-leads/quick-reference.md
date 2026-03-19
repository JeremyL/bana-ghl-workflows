# Quick Reference — New Leads Outreach

*Last edited: 2026-03-20 · Last reviewed: —*

Every outreach touch across the New Leads pipeline — stage by stage, with template IDs and message counts.
Templates follow `PREFIX-CHANNEL-##` format. Owner = LM (Cold Email/SMS/Call) or AM (Direct Mail/VAPI/Referral/Website).

```
[ALL SOURCES: Cold Email / Cold SMS / Cold Call / Direct Mail / VAPI / Referral / Website / Re-Submission]
  └─► NEW LEADS — Day 0: Speed to Lead (immediate on entry)
        │   SMS varies by source (120s wait):
        │     Cold Email / Cold SMS / Cold Call ──► CO-SMS-00
        │     Website / VAPI / Referral ───────────► IN-SMS-00
        │     Direct Mail ─────────────────────────► DM-SMS-00
        │   After SMS ──► Call (manual)
        │   ~1hr later ──► Missed-call SMS if no call logged:
        │     Cold Email / Cold SMS / Cold Call ──► CO-SMS-00A
        │     Website / VAPI / Referral ───────────► IN-SMS-00A
        │     Direct Mail ─────────────────────────► DM-SMS-00A
        │   Totals: 2 SMS, 1 Call (per lead — template varies by source)
        │
        └─► DAY 1-10 — Active Daily Pursuit (10 calendar days)
              │
              │   Days 1-2 (2x per day):
              │     Day 1:  SMS (NL-SMS-01) ──► Call ──► SMS (NL-SMS-07)
              │     Day 2:  Email (NL-EMAIL-01) ──► Call ──► SMS (NL-SMS-02)
              │
              │   Days 3-10 (1x per day, rotating):
              │     Day 3:  Call
              │     Day 4:  SMS (NL-SMS-10)
              │     Day 5:  Email (NL-EMAIL-05)
              │     Day 6:  Call
              │     Day 7:  Email (NL-EMAIL-02)
              │     Day 8:  SMS (NL-SMS-03)
              │     Day 9:  Call
              │     Day 10: SMS (NL-SMS-08)
              │
              │   Voicemail: leave NL-VM-01 script, then send NL-VMSMS-01 combo SMS
              │   Totals: 6 SMS, 3 Emails, 5 Calls, 1 VM script, 1 VM combo SMS
              │
              └─► Qualifies ────────────────────────────────────────► Due Diligence (AM takes over)
              └─► No response by Day 11 ────────────────────────────► DAY 11-30
                    │
                    │   Day 11-30 — Winding Down (every 2-3 days, 11 touches over 20 days)
                    │     Day 11: SMS (NL-SMS-04)
                    │     Day 13: Call
                    │     Day 14: RVM (NL-RVM-01)
                    │     Day 15: Email (NL-EMAIL-03)
                    │     Day 17: SMS (NL-SMS-09)
                    │     Day 20: RVM (NL-RVM-02)
                    │     Day 22: SMS (NL-SMS-05)
                    │     Day 24: Call
                    │     Day 27: RVM (NL-RVM-03)
                    │     Day 29: Email (NL-EMAIL-04)
                    │     Day 30: SMS (NL-SMS-06)
                    │
                    │   Voicemail: leave NL-VM-02 script, then send NL-VMSMS-01 combo SMS
                    │   Totals: 4 SMS, 2 Emails, 2 Calls, 3 RVM, 1 VM script, 1 VM combo SMS
                    │
                    └─► Qualifies ──────────────────────────────────► Due Diligence (AM takes over)
                    └─► No response by Day 30 ──────────────────────► COLD MONTHLY
                    └─► DNC request ────────────────────────────────► Dispo: DNC (zero contact)

--- COLD EMAIL SPECIAL HANDLING (runs concurrently with Day 1-30) ---

Cold Email (no confirmed phone #) enters New Leads → all standard SMS/call/email suppressed
  └─► Phase 1: Automated emails asking for phone # (sole communicator)
        │     Day 1:  Email (WR-EMAIL-01)
        │     Day 3:  Email (WR-EMAIL-02)
        │     Day 7:  Email (WR-EMAIL-03)
        │     Day 14: Email (WR-EMAIL-04)
        │     Day 21: Email (WR-EMAIL-05)
        │
        └─► Phone # received at any point ──────────────────────────► Sub-flow stops, standard Day 1-30 resumes
        └─► Day 30, no phone # ─────────────────────────────────────► One-time SMS blast (WR-COLD-SMS-01)
              └─► Tag: Cold: Email Only → Cold (email-only drip)
  Totals: 5 Emails, 1 SMS

--- COLD MONTHLY (Months 1-3 — fully automated) ---

COLD MONTHLY (SMS + Email alternating every ~14 days)
  │     Day 30:  SMS (COLD-SMS-01)
  │     Day 44:  Email (COLD-EMAIL-01)
  │     Day 58:  SMS (COLD-SMS-02)
  │     Day 72:  Email (COLD-EMAIL-02)
  │     Day 86:  SMS (COLD-SMS-03)
  │     Day 100: Email (COLD-EMAIL-03)
  │
  │   Cold: Email Only contacts skip all SMS steps
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

Fed by: Cold Monthly, Nurture Monthly, and Dispo Re-Engage
SMS + Email same day, every 90 days — Q1-Q4 plays twice (24 months), then stops

  │     Q1: SMS (LTQ-SMS-01) + Email (LTQ-EMAIL-01)
  │     Q2: SMS (LTQ-SMS-02) + Email (LTQ-EMAIL-02)
  │     Q3: SMS (LTQ-SMS-03) + Email (LTQ-EMAIL-03)
  │     Q4: SMS (LTQ-SMS-04) + Email (LTQ-EMAIL-04)
  │     ↻ plays Q1-Q4 twice (24 months), then stops
  │
  │   Cold: Email Only contacts skip all SMS steps
  │   Totals: 4 SMS, 4 Emails (x2 = 8 SMS, 8 Emails over 24 months)
  │
  └─► Re-engages (replies to drip) ───────────────────────────────► Owner reviews (7-day window)
  └─► DNC request ─────────────────────────────────────────────────► Dispo: DNC (zero contact)

--- DISPO RE-ENGAGE ---

Dispo: No Motivation ──────────────────────────────────────────────► Cold Monthly → Long-Term Quarterly (same drip)
Dispo: Wants Retail ───────────────────────────────────────────────► Cold Monthly → Long-Term Quarterly (same drip)
Dispo: On MLS ─────────────────────────────────────────────────────► Cold Monthly → Long-Term Quarterly (same drip)
Dispo: Lead Declined ──────────────────────────────────────────────► Cold Monthly → Long-Term Quarterly (same drip)

--- MISSED CALL TEXT-BACK (any stage) ---

Missed inbound call ──► 2 min wait ──► SMS (MC-SMS-01)

═══════════════════════════════════════════════════════════════════

TEMPLATE TOTALS (50 unique templates)

  SMS ········ 27   NL-SMS (9) · CO-SMS (2) · IN-SMS (2) · DM-SMS (2) · COLD-SMS (3) · LTQ-SMS (4) · NUR-SMS (2)
                    WR-COLD-SMS (1) · NL-VMSMS (1) · MC-SMS (1)
  Email ······ 18   NL-EMAIL (5) · COLD-EMAIL (3) · LTQ-EMAIL (4) · NUR-EMAIL (1)
                    WR-EMAIL (5)
  RVM ········  3   NL-RVM-01, 02, 03
  VM Script ··  2   NL-VM-01, NL-VM-02
```

