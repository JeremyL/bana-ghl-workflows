# Bana Land — New Leads Account: Contact Rules & Compliance

This file defines the operational rules that govern all outreach in **New Leads**.
Every GHL workflow, automation, and team member action must respect these rules.

For the Warm Response account rules, see [../warm-response/rules.md](../warm-response/rules.md).

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
6. **DNC Sync:** WF-10 fires two sync webhooks via n8n:
   - n8n marks DNC in Warm Response if contact exists there (moves to DNC stage, kills workflows, tags DNC)
   - n8n updates the Property record in Prospect Data (DNC = checked, DNC Date = today, Status = DNC)

### Team responsibility:

- Any team member who receives a verbal opt-out during a call must update the CRM **during or immediately after** that call
- Do not "finish the sequence" first — DNC is immediate

### Re-contact after DNC:

- **Never.** Do not re-add a DNC contact to any list or campaign.
- If a DNC contact re-engages with us voluntarily (they call us), document it and proceed cautiously

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

### Who can change a lead's stage:

- **Acquisition manager:** Can move leads through any stage manually
- **GHL automation:** Can advance uncontacted leads based on time elapsed (Day 1-2 → Day 3-14 → etc.)
- **Automation cannot:** Qualify a lead (move to Due Diligence or beyond) — that requires human confirmation

### Stage change triggers:

| Trigger                        | Action                                       |
| ------------------------------ | -------------------------------------------- |
| Lead responds and is qualified | Human manually moves to Due Diligence        |
| X days pass with no response   | GHL auto-advances to next time bucket        |
| Lead says stop / opt-out       | GHL or human moves to Dispo: DNC immediately |
| Disqualifying info gathered    | Human moves to appropriate Dispo stage       |
| Offer declined, deal dead      | Human moves to Dispo: Lead Declined          |
| Offer declined, could revisit  | Human moves to Nurture or Negotiations       |

---

## 6. Positive Response Protocol

There are two distinct re-entry events. Each has its own protocol.

**Pause mechanic:** All drip and automated-send workflows (WF-02 through WF-06, WF-08) include a **"Wait Until"** condition before each send step that checks for the `Paused` tag. If present, the contact is held in place — no messages go out, but the contact's position in the workflow is preserved. When the `Paused` tag is removed, the contact continues from exactly where it stopped.

### 6A. Re-Engagement — Lead responds to our existing GHL follow-up

**Definition:** Lead replies to an SMS or email that *we sent* from any GHL workflow — drip stages (Cold, Nurture, Dispo Re-Engage) or active AM stages (Day 1-2, Day 3-14, Day 15-30).

**Protocol (WF-11 — Inbound Response Handler):**

1. Add tag: `Paused` — all active workflows immediately hold at the next send step (no messages sent, position preserved)
2. Add tag: `Re-Engaged`
3. Create high-priority task for Acquisition Manager: review the reply
4. Send internal notification to AM with contact link
5. **Resolution — one of three outcomes:**
   - **AM moves to a qualified stage** (Due Diligence, etc.) → workflow exit triggers fire, active workflows are killed. `Paused` and `Re-Engaged` tags cleaned up
   - **AM moves to a Dispo stage** → workflow exit triggers fire, dispo workflows take over. `Paused` and `Re-Engaged` tags cleaned up
   - **AM clears the `Paused` tag** (reply was not actionable, lead stays in current stage) → drip resumes from exactly where it stopped. `Re-Engaged` tag cleaned up
6. **Auto-resume safety net (drip stages only):** If AM does nothing after **7 days**, WF-11 automatically removes the `Paused` tag → drip resumes from where it stopped. No leads fall through the cracks
7. **Active stages (Day 1-2 / Day 3-14 / Day 15-30):** There is no 7-day auto-resume. The AM is already working this lead — they either move the stage (kills workflow) or manually remove the `Paused` tag when ready

**Ghost scenario:** Lead responds, AM reviews, decides it's not actionable — AM either removes the `Paused` tag immediately, or does nothing and the 7-day timer handles it (drip stages). Either way, the drip picks up exactly where it left off.

### 6B. Re-Submission — Lead comes back from a new external campaign

**Definition:** A contact already in GHL (any stage) is reached by a *new, separate marketing campaign* outside GHL (e.g., cold call lead later responds to a cold SMS blast, or cold drip lead calls back from a direct mailer).

**Protocol:**

1. n8n detects duplicate contact with a new campaign source
2. n8n adds a new Source tag (stacks on existing), updates Latest Source field + Latest Source Date
3. n8n adds tag: `Re-Submitted` and moves contact to New Leads
4. WF-01 fires: cleans up all active drips, assigns to AM, creates task
5. Lead is worked from scratch — full Day 1-2 sequence, identical to a brand-new lead
6. Original Source field is never overwritten — first-touch attribution preserved
7. **If contact also exists in Warm Response:** n8n fires cleanup webhook to Warm Response (stop drip, move to Transferred)

**Key distinction:** Re-engagement = responding to *our* outreach. Re-submission = entering from a *new external source*. The first pauses and reviews; the second fully resets.

---

## 7. Dispo Re-Engage — Long-Term Drip

The four **Dispo — Re-Engage** stages are NOT completely dead leads:

- No Motivation
- Wants Retail
- On MLS
- Lead Declined

When a lead enters any of these stages, WF-09 automatically adds tag `Drip: Cold Monthly` and enrolls them in the **Long-Term Drip** (WF-05 → WF-06) — the same indefinite drip used for Cold stage leads.

- Drip continues indefinitely until opt-out — there is no automatic end date
- If a Re-Engage lead responds positively at any point, move to the appropriate active stage (human decision)
- If they opt out at any point, move to Dispo: DNC immediately

---

## 8. Data Hygiene Rules

- **Phone numbers:** Verify with skip trace or carrier lookup before launching campaigns. Do not blast unverified numbers.
- **Emails:** Verify email addresses from skip trace data using a service before sending cold emails.
- **Duplicate contacts:** Merge duplicates before enrolling in any sequence. GHL can trigger multiple workflows on dupes.
- **Disconnected numbers:** If a call returns "not in service," tag the lead accordingly. Do not keep sending SMS to dead numbers.
- **Stage date logging:** When a lead moves to a new stage, log the date. This is how GHL workflows know when to advance (Day 1-2 → Day 3-14 uses the "Date Entered Stage" field).

---

## 9. Escalation Protocol

If a lead becomes hostile, threatening, or legally threatening:

1. Immediately move to Dispo: DNC (+ DNC sync to Warm Response)
2. Flag for manager review
3. Document the interaction with full notes in GHL contact record
4. Do not re-engage under any circumstances

---

## 10. Rules Summary Cheat Sheet

| Rule                                 | Requirement                             |
| ------------------------------------ | --------------------------------------- |
| Contact hours                        | 9am–7pm local time only                 |
| DNC opt-out response time            | Immediate — within the same interaction |
| DNC re-contact                       | Never                                   |
| DNC sync to Warm Response               | Always — via n8n webhook                |
| No response = opt-out?               | No — keep following up per cadence      |
| Who can qualify a lead?              | Human only — no automation              |
| SMS opt-out keywords handled by GHL? | Yes — verify configured                 |
