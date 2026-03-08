# Bana Land — Warm Response Account: Contact Rules & Compliance

This file defines the operational rules that govern all outreach in **Warm Response**.
Every GHL workflow, automation, and team member action must respect these rules.

For the New Leads account rules, see [../new-leads/rules.md](../new-leads/rules.md).

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
   - n8n marks DNC in New Leads if contact exists there (moves to DNC stage, kills workflows, tags DNC)
   - n8n updates the Property record in Prospect Data (DNC = checked, DNC Date = today, Status = DNC)

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

### Who can change a lead's stage:

- **Lead Manager:** Can move leads through Warm Response, Cold, Transferred, DNC
- **GHL automation:** Can advance from Warm Response → Cold (14-day timeout)
- **Automation cannot:** Move a lead to Transferred — that requires human confirmation (Lead Manager)

### Stage change triggers:

| Trigger                                 | Action                                                   |
| --------------------------------------- | -------------------------------------------------------- |
| Phone # received (email track)          | Lead Manager moves to Transferred → WF-HANDOFF           |
| Phone call completed (SMS track)        | Lead Manager moves to Transferred → WF-HANDOFF           |
| 14 days pass with no connection         | GHL auto-moves to Cold → Cold drip begins                |
| Lead says stop / opt-out                | GHL or Lead Manager moves to Dispo: DNC → DNC sync       |
| Re-submitted from new external campaign | n8n cleanup webhook → New Leads handles as new lead      |

---

## 6. Positive Response Protocol

### Re-Engagement — Lead responds to our Warm Response Cold drip

**Definition:** Lead replies to an SMS or email sent from a Cold drip workflow in this account.

**Protocol (WF-11):**

1. Add tag: `Paused` — all active workflows immediately hold at their next send gate
2. Add tag: `Re-Engaged`
3. Create call task assigned to Lead Manager: "Call {{first_name}} — re-engaged from Cold drip"
4. Send internal notification with contact link
5. **Resolution:**
   - Lead Manager connects → move to Transferred → WF-HANDOFF → New Leads
   - Not actionable → remove `Paused` tag → drip resumes
   - No action after 7 days → auto-remove `Paused` tag → drip resumes

### Re-Submission — Lead comes back from a new external campaign

**Definition:** A contact already in this account is reached by a new, separate marketing campaign outside GHL.

**Protocol:**

1. n8n sends contact to New Leads as a new lead (always goes to New Leads)
2. n8n fires cleanup webhook to Warm Response: stop all drips, move to terminal stage
3. New Leads' WF-01 fires: assigns to AM, creates task
4. Lead is worked from scratch in New Leads

---

## 7. Data Hygiene Rules

- **Phone numbers:** Verify with skip trace or carrier lookup before launching campaigns. Do not blast unverified numbers.
- **Emails:** Verify email addresses from skip trace data using a service before sending cold emails.
- **Duplicate contacts:** Merge duplicates before enrolling in any sequence.
- **Disconnected numbers:** If a call returns "not in service," tag the lead accordingly.
- **Stage date logging:** When a lead moves to a new stage, log the date (Stage Entry Date field).

---

## 8. Escalation Protocol

If a lead becomes hostile, threatening, or legally threatening:

1. Immediately move to Dispo: DNC (+ DNC sync to New Leads)
2. Flag for manager review
3. Document the interaction with full notes in GHL contact record
4. Do not re-engage under any circumstances

---

## 9. Rules Summary Cheat Sheet

| Rule                                 | Requirement                             |
| ------------------------------------ | --------------------------------------- |
| Contact hours                        | 9am–7pm local time only                 |
| DNC opt-out response time            | Immediate — within the same interaction |
| DNC re-contact                       | Never                                   |
| DNC sync to New Leads               | Always — via n8n webhook                |
| No response = opt-out?               | No — keep following up per cadence      |
| Who can transfer a lead?             | Lead Manager only — no automation       |
| SMS opt-out keywords handled by GHL? | Yes — verify configured                 |
