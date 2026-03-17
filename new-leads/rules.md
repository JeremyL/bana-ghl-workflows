# New Leads — Contact Rules & Compliance

Operational rules that govern all outreach in **New Leads** (the single working account).
Every GHL workflow, automation, and team member action must respect these rules.

---

## 1. Contact Hours

**All outreach — calls, SMS, and email — must only be sent between:**

> **9:00 AM – 7:00 PM in the lead's LOCAL time zone**

- GHL workflows must use the lead's state/area code to determine time zone before sending
- For unknown time zones, default to 11:00 AM – 7:00 PM Eastern to stay safe
- Calls made outside these hours can be a violation and legal liability

---

## 2. DNC (Do Not Contact) Protocol

**This is the highest-priority rule in the entire system. No exceptions.**

### What triggers a DNC disposition:

- Lead verbally says "stop calling," "don't call me," "remove me from your list," "take me off," or any similar request
- Lead sends an opt-out reply via SMS (e.g., STOP, UNSUBSCRIBE, QUIT, CANCEL, END)
- Lead sends any written request to stop contact (email, letter)

### Immediate actions when DNC is triggered:

1. Change lead stage to **Dispo: DNC** immediately
2. GHL workflow auto-pauses / kills all active sequences for this contact
3. Tag the lead with **"DNC"** and log the date opted out
4. Remove from all active workflow enrollments
5. Zero contact from that point forward — calls, texts, email, all stopped
6. **DNC Sync:** WF-10 fires a sync webhook via automation:
   - automation updates the Property record in Prospect Data (DNC = checked, DNC Date = today, Status = DNC)

### Team responsibility:

- Any team member who receives a verbal opt-out during a call must update the CRM **during or immediately after** that call
- Do not "finish the sequence" first — DNC is immediate

### Re-contact after DNC:

- **Never.** Do not re-add a DNC contact to any list or campaign.
- If a DNC contact re-engages with us voluntarily (they call us), document it and proceed cautiously

### DNC vs. Wrong Number / Wrong Email:

These are two different things. Do not confuse them.

**DNC** — Any time a person says "don't contact me," "remove me," "stop calling," or anything to that effect: it's a DNC. Full stop. Do not try to interpret whether they mean this property, this phone number, or this campaign. DNC the contact entirely.

**Wrong number / wrong email** — The person says "you have the wrong number" or "I don't know what this is about" without requesting to stop contact, OR the number/email bounces or is confirmed bad. This is a data problem, not a DNC:
1. Delete the bad phone number or email from the contact record
2. Add a contact note: what was removed, why, and the date (e.g., "Phone 2 deleted — wrong number per owner, 2026-03-09")
3. Continue outreach on any remaining valid numbers/emails

---

## 3. No Response =/= Opt-Out

Not answering calls, not replying to texts, and not opening emails does NOT constitute an opt-out.

- Continue the cadence as defined in sequences.md
- Only an explicit opt-out request triggers DNC status
- Leads who have never responded can still receive follow-up indefinitely (Cold stage drip)

---

## 4. Compliance Notes

### Key rules:

- **Opt-out honoring:** SMS opt-outs (STOP replies) must be honored within 30 seconds of receipt. GHL handles this automatically — verify this is configured.

### GHL settings to verify:

- Opt-out keywords configured (STOP, QUIT, UNSUBSCRIBE, CANCEL, END)
- Info keyword configured (HELP) — replies with company info, does NOT trigger opt-out
- Auto-reply on opt-out: "You've been unsubscribed. Reply START to re-subscribe."
- Time-zone send windows enforced on all workflows

---

## 5. Stage Movement Rules

**Who can change a lead's stage:**
- **Lead Manager (LM):** Can move LM-sourced leads (Cold Email/SMS/Call) through any stage, including dispo stages. Can also qualify and move to Due Diligence.
- **Acquisition Manager (AM):** Can move AM-sourced leads (Direct Mail/VAPI/Referral/Website) through any stage. Owns all qualified stages regardless of source.
- **GHL automation:** Can advance uncontacted leads based on time elapsed (Day 1-10 → Day 11-30 → Cold)
- **Automation cannot:** Qualify a lead (move to Due Diligence or beyond) — that requires human confirmation

| Trigger                        | Action                                       |
| ------------------------------ | -------------------------------------------- |
| Lead responds and is qualified | Owner manually moves to Due Diligence. For LM-sourced: LM sets call appointment for AM. |
| X days pass with no response   | GHL auto-advances to next time bucket        |
| Lead says stop / opt-out       | GHL or human moves to Dispo: DNC immediately |
| Disqualifying info gathered    | Owner moves to appropriate Dispo stage       |
| Offer declined, deal dead      | AM moves to Dispo: Lead Declined             |
| Offer declined, could revisit  | AM moves to Nurture or Negotiations          |
| Re-submitted from new campaign | WF-01 fires → full restart in New Leads      |

---

## 6. Positive Response Protocol

There are two distinct re-entry events. Each has its own protocol.

**Pause mechanic:** All drip and automated-send workflows include a **"Wait Until"** condition before each send step that checks: **`Pause WFs Until` is empty OR `Pause WFs Until` < today**. If the field is set to a future date, the contact is held in place — no messages go out, but position in the workflow is preserved. When the date passes naturally (auto-resume) or the field is cleared manually by the owner (early release), the contact continues from exactly where it stopped.

### 6A. Re-Engagement — Lead responds to our existing GHL follow-up

**Definition:** Lead replies to an SMS or email that *we sent* from any GHL workflow.

#### Protocol (WF-11):

1. Set field: `Pause WFs Until` = today + 7 days — all active workflows hold at the next send condition
2. Add tag: `Re-Engaged`
3. Create high-priority review task assigned to **lead owner** (LM for Cold Email/SMS/Call sources, AM for Direct Mail/VAPI/Referral/Website sources)
4. Send internal notification to owner with contact link
5. **Resolution — one of three outcomes:**
   - **Owner moves to a qualified stage** → workflow exit triggers fire, active workflows killed. Clear `Pause WFs Until`. Remove tag `Re-Engaged`.
   - **Owner moves to a Dispo stage** → dispo workflows take over. Clear `Pause WFs Until`. Remove tag `Re-Engaged`.
   - **Owner clears `Pause WFs Until` field early** (reply not actionable, lead stays in current stage) → drip resumes from where it stopped. Remove tag `Re-Engaged`.
6. **Auto-resume safety net (drip stages only):** If owner does nothing after **7 days**, `Pause WFs Until` date expires → drip resumes automatically. WF-11 clears the field and removes `Re-Engaged`.
7. **Active stages (Day 1-10 / Day 11-30):** No 7-day auto-resume. Owner is already working this lead — they move the stage or manually clear `Pause WFs Until` when ready.

### 6B. Re-Submission — Lead comes back from a new external campaign

**Definition:** A contact already in GHL is reached by a *new, separate marketing campaign* outside GHL.

**Protocol:**

1. automation detects duplicate contact with a new campaign source
2. automation adds a new Source tag (stacks on existing), updates Latest Source field + Latest Source Date
3. automation adds tag: `Re-Submitted` and moves contact to **New Leads** stage
4. WF-01 fires: cleans up all active drips, assigns to owner based on new source tag, creates task
5. Lead is worked from scratch — full Day 1-10 sequence, identical to a brand-new lead
6. Original Source field is never overwritten — first-touch attribution preserved

**Key distinction:** Re-engagement = responding to *our* outreach (pause and review). Re-submission = entering from a *new external source* (full reset to New Leads).

---

## 7. Dispo Re-Engage — Long-Term Drip

*(New Leads account)*

The four **Dispo — Re-Engage** stages are NOT completely dead leads:

- No Motivation
- Wants Retail
- On MLS
- Lead Declined

When a lead enters any of these stages, WF-09 automatically enrolls them in **WF-05 (Long-Term Drip)** — the same indefinite drip used for Cold stage leads.

- Drip continues indefinitely until opt-out — there is no automatic end date
- If a Re-Engage lead responds positively at any point, move to the appropriate active stage (human decision)
- If they opt out at any point, move to Dispo: DNC immediately

---

## 8. Data Hygiene Rules

- **Phone numbers:** Verify with skip trace or carrier lookup before launching campaigns. Do not blast unverified numbers.
- **Emails:** Verify email addresses from skip trace data using a service before sending cold emails.
- **Duplicate contacts:** Merge duplicates before enrolling in any sequence. GHL can trigger multiple workflows on dupes.
- **Disconnected numbers:** If a call returns "not in service," tag the lead accordingly. Do not keep sending SMS to dead numbers.
- **Stage date logging:** When a lead moves to a new stage, log the date. This is how GHL workflows know when to advance (Day 1-10 → Day 11-30 uses the "Date Entered Stage" field). *(Applies primarily to New Leads' time-bucket system.)*

---

## 9. Escalation Protocol

If a lead becomes hostile, threatening, or legally threatening:

1. Immediately move to Dispo: DNC (+ DNC sync to Prospect Data)
2. Flag for manager review
3. Document the interaction with full notes in GHL contact record
4. Do not re-engage under any circumstances

---

## 10. Rules Summary Cheat Sheet

| Rule                                 | Detail                                              |
| ------------------------------------ | --------------------------------------------------- |
| Contact hours                        | 9am–7pm local time only                              |
| DNC opt-out response time            | Immediate                                            |
| DNC re-contact                       | Never                                                |
| DNC sync                             | New Leads → Prospect Data (WF-10)                    |
| No response = opt-out?               | No — keep following up per cadence                   |
| Who can qualify a lead?              | LM or AM (based on source) — no automation           |
| Who can dispo a lead?                | LM or AM — both can dispo directly                   |
| Auto-resume after re-engagement      | 7 days (drip stages only)                            |
| SMS opt-out keywords handled by GHL? | Yes — verify configured                              |
| LM → AM handoff mechanism            | LM sets call appointment for AM at qualification     |
