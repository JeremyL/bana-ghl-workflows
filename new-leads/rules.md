# New Leads — Contact Rules & Compliance

*Last edited: 2026-04-07 · Last reviewed: 2026-04-07*

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

1. Change opportunity status to **Abandoned** + add tag `abandoned: dnc` immediately
2. **Set native DND for ALL channels** (SMS, Call, Email) — platform-level hard block that prevents sends regardless of workflow configuration
3. Tag the lead with **"dnc"**
4. GHL workflow auto-pauses / kills all active sequences for this contact
5. Remove from all active workflow enrollments
6. Zero contact from that point forward — calls, texts, email, all stopped
7. **DNC Sync:** WF-DNC-Handler fires on status → Abandoned + `abandoned: dnc` tag → sync webhook via automation:
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
4. Sync this with the property record in Prospect Data account

---

## 3. No Response =/= Opt-Out

Not answering calls, not replying to texts, and not opening emails does NOT constitute an opt-out.

- Continue the cadence as defined in sequences.md
- Only an explicit opt-out request triggers DNC status
- Leads who have never responded receive follow-up through the full 24-month quarterly cycle, then move to Exhausted (no further automated outreach)

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

## 5. Stage & Status Movement Rules

**Who can change a lead's stage or status:**

- **Lead Manager (LM):** Can move LM-sourced leads (Cold SMS/Call) through Acquisition pipeline stages. Can change status to Lost (with reason) or Abandoned (with tag). Can qualify and move to Acquisition: Comp.
- **Acquisition Manager (AM):** Can move AM-sourced leads (Direct Mail/VAPI/Referral/Website) through any stage in any pipeline. Can change status. Owns all deal stages (Comp through Contract Signed) regardless of source.
- **GHL automation:** Can advance leads within Acquisition pipeline (Day 1-10 → Day 11-30). Can auto-move to LT FU: Cold after Day 11-30. Can auto-move Acquisition: Nurture → LT FU: Nurture. Can move Lost status → LT FU: Lost. Can change status to Abandoned (exhausted) after 24-month drip completes.
- **Automation cannot:** Qualify a lead (move to Comp or beyond) — that requires human confirmation


| Trigger                        | Action                                                                                  |
| ------------------------------ | --------------------------------------------------------------------------------------- |
| Lead responds and is qualified | Owner manually moves to Acquisition: Comp. For LM-sourced: LM sets call appointment for AM. |
| X days pass with no response   | GHL auto-advances to next stage (within Acquisition) or cross-pipeline to LT FU: Cold    |
| Lead says stop / opt-out       | Status → Abandoned + tag `abandoned: dnc` immediately                                   |
| Disqualifying info gathered    | Status → Lost (with reason) or Abandoned (with tag) depending on type                   |
| Offer declined, deal dead      | Status → Lost, lost reason = Lead Declined                                               |
| Offer declined, could revisit  | AM moves to Nurture or Negotiations (stays Open)                                        |
| Not a fit / no longer owns     | Status → Abandoned + appropriate tag                                                    |
| Re-submitted from new campaign | WF-New-Lead-Entry fires → clear lost reason / strip abandoned tag → Open → New Leads    |


---

## 6. Positive Response Protocol

There are two distinct re-entry events. Each has its own protocol.

**Pause mechanic:** All drip and automated-send workflows include a **"Wait Until"** condition before each send step that checks: `**Pause WFs Until` is empty OR `Pause WFs Until` ≤ today**. If the field is set to a future date, the contact is held in place — no messages go out, but position in the workflow is preserved. When the date passes naturally (auto-resume) or the field is cleared manually by the owner (early release), the contact continues from exactly where it stopped.

### 6A. Re-Engagement — Lead responds to our existing GHL follow-up

**Definition:** Lead replies to an SMS or email that *we sent* from any GHL workflow.

#### Protocol (WF-Response-Handler):

**WF-Response-Handler only fires for contacts in:** Leads: Day 1-10, Leads: Day 11-30, LT FU: Cold, LT FU: Nurture, LT FU: Lost (status = Open), or Abandoned (non-DNC) — AND `Pause WFs Until` is empty (prevents duplicate triggers during an active review window).

1. Set field: `Pause WFs Until` = today + 3 days — all active workflows hold at the next send condition
2. Create high-priority review task assigned to **Contact Owner** (via If/Else branch on Contact Owner field)
3. Send internal notification & internal SMS to lead owner with contact link
4. **Resolution — one of three outcomes:**
  - **Owner moves to a qualified stage** (flip to Open if currently Lost) → workflow exit triggers fire, active workflows killed. Clear `Pause WFs Until`.
  - **Owner changes status to Lost** (with reason) or **Abandoned** (with tag) → appropriate workflows take over. Clear `Pause WFs Until`.
  - **Owner clears `Pause WFs Until` field early** (reply not actionable, lead stays in current stage/status) → drip resumes from where it stopped.
5. **Auto-resume safety net (drip stages and Lost status only):** If owner does nothing after **3 days**, `Pause WFs Until` date expires → drip resumes automatically. WF-Response-Handler clears the field.
6. **Active stages (Day 1-10 / Day 11-30):** No 3-day auto-resume. Owner is already working this lead — they move the stage or manually clear `Pause WFs Until` when ready.
7. **Soft opt-outs:** Replies like "not interested" or "leave me alone" without official opt-out keywords still trigger WF-Response-Handler normally. Owner reviews and decides case-by-case — may move to Abandoned (DNC) or Lost (with reason) based on judgment.

### 6B. Re-Submission — Lead comes back from a new external campaign

**Definition:** A contact already in GHL is reached by a *new, separate marketing campaign* outside GHL.

**Protocol:**

1. automation detects duplicate contact with a new campaign source
2. automation adds a new Source tag (stacks on existing), updates Latest Source field + Latest Source Date
3. automation adds tag: `re-submitted` and moves contact to **New Leads** stage
4. WF-New-Lead-Entry fires: cleans up all active drips, preserves existing owner (assignment only fires for unassigned contacts), creates task
5. Lead is worked from scratch — full Day 1-10 sequence, identical to a brand-new lead
6. Native Opportunity Source is never overwritten — first-touch attribution preserved

**Key distinction:** Re-engagement = responding to *our* outreach (pause and review). Re-submission = entering from a *new external source* (full reset to New Leads).

---

## 7. Lost Status — Long-Term Drip

*(New Leads account)*

Leads marked **Lost** are NOT completely dead — they had a real conversation but didn't convert. The four lost reasons are:

- No Motivation
- Wants Retail
- On MLS
- Lead Declined

When a lead's status changes to Lost (any reason), WF-Dispo-Re-Engage triggers and enrolls them in **WF-Cold-Drip-Monthly → WF-Long-Term-Quarterly** — the same drip used for LT FU: Cold leads (monthly first, then quarterly with a 24-month cap).

- After 24 months of quarterly drip (Q4×2), WF-Long-Term-Quarterly changes status to **Abandoned** + adds tag `abandoned: exhausted` — all automated outreach is complete
- If a Lost lead responds positively at any point (including from Abandoned), flip to Open + move to the appropriate active stage (human decision)
- If they opt out at any point, status → Abandoned + tag `abandoned: dnc` immediately
- Re-submission via WF-New-Lead-Entry still works from any status — clear lost reason / strip abandoned tag, flip to Open, full restart (except DNC — blocked)

---

## 8. Data Hygiene Rules

- **Phone numbers:** Verify with skip trace or carrier lookup before launching campaigns. Do not blast unverified numbers.
- **Emails:** Verify email addresses from skip trace data using a verification service before sending.
- **Duplicate contacts:** Merge duplicates before enrolling in any sequence. GHL can trigger multiple workflows on dupes.
- **Disconnected numbers:** If a call returns "not in service," tag the lead accordingly. Do not keep sending SMS to dead numbers.
- **Stage date tracking:** GHL's native `lastStageChangeAt` field on Opportunities updates automatically whenever an opportunity moves to any pipeline stage — no manual updates or workflow steps needed. This covers all stages across all pipelines, including cross-pipeline moves. Used by the Stale New Leads Smart List to detect leads sitting in New Leads > 24 hours.

---

## 9. Escalation Protocol

If a lead becomes hostile, threatening, or legally threatening:

1. Immediately change status to Abandoned + tag `abandoned: dnc` (+ DNC sync to Prospect Data)
2. Flag for manager review
3. Document the interaction with full notes in GHL contact record
4. Do not re-engage under any circumstances

---

## 10. Rules Summary Cheat Sheet


| Rule                                 | Detail                                                        |
| ------------------------------------ | ------------------------------------------------------------- |
| Contact hours                        | 9am–7pm local time only                                       |
| DNC opt-out response time            | Immediate — status → Abandoned + `abandoned: dnc`             |
| DNC re-contact                       | Never                                                         |
| DNC sync                             | Bi-directional (NL → PD via WF-DNC-Handler; PD → NL via automation)    |
| No response = opt-out?               | No — keep following up per cadence                            |
| Who can qualify a lead?              | LM or AM (based on source) — no automation                    |
| Who can change status?               | LM or AM — both can mark Lost or Abandoned directly           |
| Auto-resume after re-engagement      | 3 days (drip stages only)                                     |
| SMS opt-out keywords handled by GHL? | Yes — verify configured                                       |
| LM → AM handoff mechanism            | LM sets call appointment for AM at qualification              |
| Speed to lead — new/inbound leads    | Call within 10 minutes (push + SMS alert to owner)            |
| Speed to lead — re-submitted leads   | Call within 30 minutes                                        |
| Wrong number / wrong email           | Not a DNC — delete bad data, add note, sync to Prospect Data  |
| Voicemail protocol                   | Script + SMS combo on manual calls. RVM auto-drops Day 11-30. |

---

## 11. Speed to Lead

**Calling within 10 minutes of a lead entering the system increases contact rate by 10x+ vs. calling within an hour.** These leads just responded or reached out — they're hot right now.

### Time Targets


| Lead Type                                                 | Target                     | Owner                    |
| --------------------------------------------------------- | -------------------------- | ------------------------ |
| Cold SMS, Cold Call, Direct Mail, VAPI, Referral, Website | **Call within 10 minutes** | LM or AM (by source)     |
| Re-submitted leads (any source)                           | **Call within 30 minutes** | Existing Contact Owner   |


### How It Works

WF-New-Lead-Entry fires the following on lead entry (Day 0):

1. **Immediate (120 seconds) SMS** (CO-SMS-00) — warms the number before the call
2. **Push notification** — GHL mobile app alert to assigned owner
3. **SMS alert** — text to owner's personal number: "NEW LEAD — {{first_name}} — call now: {{phone}}"
4. **1-hour check** — if no call logged, missed-call SMS (CO-SMS-00A) fires automatically

### Team Responsibility

- When you receive a speed-to-lead push notification or SMS alert, **drop what you're doing and call**
- If you can't call within 10 minutes, notify your team so someone else can cover
- Log the call in GHL immediately after — the 1-hour missed-call SMS check depends on it

---

## 12. Voicemail Protocol

70-80% of calls go to voicemail. A voicemail followed immediately by an SMS dramatically increases callback rate.

### Manual Voicemail (Day 1-10 and Day 11-30)

- **Script:** Use NL-VM-01 (Day 1-10) or NL-VM-02 (Day 11-30). Keep under 15 seconds. Identify as Bana Land. Leave callback number.
- **Voicemail + SMS combo:** After leaving a voicemail, send NL-VMSMS-01 manually via GHL conversation. This is a manual send — not automated — because it only fires when the caller actually reaches voicemail.

### Ringless Voicemail Drops (Day 11-30)

- **RVM drops** are automated via WF-Day-11-30. No manual action needed.
- Contact hours (9am–7pm local) still apply.
- RVM drops are delivered directly to voicemail without ringing the phone — they fill gaps between existing Day 11-30 touches.

