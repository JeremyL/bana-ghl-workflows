# Bana Land — New Leads Account: Message Templates
*Last edited: 2026-04-02 · Last reviewed: 2026-04-02*

## Voice & Principles

- **Short** — SMS ≤ 2 sentences, Email ≤ 4 sentences
- **Casual and curious** — like a peer asking a question, not a salesperson pitching
- **NEPQ-influenced** — ask questions, don't make statements about their situation
- **Status-maintained** — tone says "I have plenty of deals, this one would be nice"
- **Rural-appropriate** — plain language, no jargon
- **Incomplete loops** — voicemails should leave something unsaid to create a reason to call back
- **Unique angles** — no two messages in the sequence should use the same approach

**Banned Phrases (never use in any template):**

- "just following up" / "following up"
- "checking in" / "check-in"
- "still interested"
- "no pressure" / "no rush" / "no obligation"
- "whenever you're ready"
- "keeping the door open"
- "just wanted to make sure you saw it"
- "we're still here"

Use `{{first_name}}` for GHL merge tag (first name of contact).
Use `{{agent_name}}` for the team member's name.
Use `{{opportunity.property_county}}` for the property's county (Opportunity custom field).
Replace `[CALLBACK NUMBER]` with the agent's dedicated phone line.

---

## Template Naming Convention

All template IDs follow the pattern: `STAGE-CHANNEL-##`


| Prefix | Stage                                       |
| ------ | ------------------------------------------- |
| NL     | New Leads (Day 1-30)                        |
| CO     | Cold Outreach Day 0 (Cold SMS, Cold Call) |
| NL-VM  | Voicemail Scripts (manual, with calls)      |
| NL-RVM | Ringless Voicemail Drops (automated)        |
| COLD   | Cold Monthly Drip (Months 1–3)              |
| NUR    | Nurture Monthly (Months 1–3)                |
| LTQ    | Long-Term Quarterly Drip (Month 4–28)       |
| IN     | Inbound Day 0 (Website, VAPI, Referral) |
| DM     | Direct Mail Day 0                           |
| MC     | Missed Call Text-Back                       |


---

## Quick Reference — All Templates (Account: New Leads)


| ID             | Channel | Stage                       | Timing            | Workflow | Auto/Manual |
| -------------- | ------- | --------------------------- | ----------------- | -------- | ----------- |
| CO-SMS-00      | SMS     | New Leads — Day 0           | 120s wait         | WF-New-Lead-Entry    | Auto        |
| CO-SMS-00A     | SMS     | New Leads — Day 0           | ~1hr post-call    | WF-New-Lead-Entry    | Auto        |
| IN-SMS-00      | SMS     | New Leads — Day 0 (Inbound) | 120s wait         | WF-New-Lead-Entry    | Auto        |
| IN-SMS-00A     | SMS     | New Leads — Day 0 (Inbound) | ~1hr post-call    | WF-New-Lead-Entry    | Auto        |
| DM-SMS-00      | SMS     | New Leads — Day 0 (Direct Mail) | 120s wait     | WF-New-Lead-Entry    | Auto        |
| DM-SMS-00A     | SMS     | New Leads — Day 0 (Direct Mail) | ~1hr post-call | WF-New-Lead-Entry    | Auto        |
| NL-SMS-01      | SMS     | New Leads — Day 1-10        | Day 1, Morning    | WF-Day-1-10    | Auto        |
| NL-SMS-07      | SMS     | New Leads — Day 1-10        | Day 1, Afternoon  | WF-Day-1-10    | Auto        |
| NL-EMAIL-01    | Email   | New Leads — Day 1-10        | Day 2, Morning    | WF-Day-1-10    | Auto        |
| NL-SMS-02      | SMS     | New Leads — Day 1-10        | Day 2             | WF-Day-1-10    | Auto        |
| NL-SMS-10      | SMS     | New Leads — Day 1-10        | Day 4             | WF-Day-1-10    | Auto        |
| NL-EMAIL-05    | Email   | New Leads — Day 1-10        | Day 5             | WF-Day-1-10    | Auto        |
| NL-EMAIL-02    | Email   | New Leads — Day 1-10        | Day 7             | WF-Day-1-10    | Auto        |
| NL-SMS-03      | SMS     | New Leads — Day 1-10        | Day 8             | WF-Day-1-10    | Auto        |
| NL-SMS-08      | SMS     | New Leads — Day 1-10        | Day 10            | WF-Day-1-10    | Auto        |
| NL-SMS-04      | SMS     | New Leads — Day 11-30       | Day 11            | WF-Day-11-30    | Auto        |
| NL-EMAIL-03    | Email   | New Leads — Day 11-30       | Day 15            | WF-Day-11-30    | Auto        |
| NL-SMS-09      | SMS     | New Leads — Day 11-30       | Day 17            | WF-Day-11-30    | Auto        |
| NL-SMS-05      | SMS     | New Leads — Day 11-30       | Day 22            | WF-Day-11-30    | Auto        |
| NL-EMAIL-04    | Email   | New Leads — Day 11-30       | Day 29            | WF-Day-11-30    | Auto        |
| NL-SMS-06      | SMS     | New Leads — Day 11-30       | Day 30            | WF-Day-11-30    | Auto        |
| COLD-SMS-01    | SMS     | Cold Monthly                | Day 30             | WF-Cold-Drip-Monthly    | Auto        |
| COLD-EMAIL-01  | Email   | Cold Monthly                | Day 44             | WF-Cold-Drip-Monthly    | Auto        |
| COLD-SMS-02    | SMS     | Cold Monthly                | Day 58             | WF-Cold-Drip-Monthly    | Auto        |
| COLD-EMAIL-02  | Email   | Cold Monthly                | Day 72             | WF-Cold-Drip-Monthly    | Auto        |
| COLD-SMS-03    | SMS     | Cold Monthly                | Day 86             | WF-Cold-Drip-Monthly    | Auto        |
| COLD-EMAIL-03  | Email   | Cold Monthly                | Day 100            | WF-Cold-Drip-Monthly    | Auto        |
| LTQ-SMS-01     | SMS     | Long-Term Quarterly         | Q1                | WF-Long-Term-Quarterly   | Auto        |
| LTQ-EMAIL-01   | Email   | Long-Term Quarterly         | Q1                | WF-Long-Term-Quarterly   | Auto        |
| LTQ-SMS-02     | SMS     | Long-Term Quarterly         | Q2                | WF-Long-Term-Quarterly   | Auto        |
| LTQ-EMAIL-02   | Email   | Long-Term Quarterly         | Q2                | WF-Long-Term-Quarterly   | Auto        |
| LTQ-SMS-03     | SMS     | Long-Term Quarterly         | Q3                | WF-Long-Term-Quarterly   | Auto        |
| LTQ-EMAIL-03   | Email   | Long-Term Quarterly         | Q3                | WF-Long-Term-Quarterly   | Auto        |
| LTQ-SMS-04     | SMS     | Long-Term Quarterly         | Q4                | WF-Long-Term-Quarterly   | Auto        |
| LTQ-EMAIL-04   | Email   | Long-Term Quarterly         | Q4                | WF-Long-Term-Quarterly   | Auto        |
| NUR-SMS-01     | SMS     | Nurture Monthly             | Month 1           | WF-Nurture-Monthly    | Auto        |
| NUR-EMAIL-01   | Email   | Nurture Monthly             | Month 2           | WF-Nurture-Monthly    | Auto        |
| NUR-SMS-02     | SMS     | Nurture Monthly             | Month 3           | WF-Nurture-Monthly    | Auto        |
| NL-VM-01       | VM      | New Leads — Day 1-10        | With manual calls | WF-Day-1-10    | Manual      |
| NL-VM-02       | VM      | New Leads — Day 11-30       | With manual calls | WF-Day-11-30    | Manual      |
| NL-VMSMS-01    | SMS     | New Leads — Day 1-10 / 11-30| After voicemail   | WF-Day-1-10 / WF-Day-11-30 | Manual      |
| NL-RVM-01      | RVM     | New Leads — Day 11-30       | ~Day 14           | WF-Day-11-30    | Auto        |
| NL-RVM-02      | RVM     | New Leads — Day 11-30       | ~Day 20           | WF-Day-11-30    | Auto        |
| NL-RVM-03      | RVM     | New Leads — Day 11-30       | ~Day 27           | WF-Day-11-30    | Auto        |
| MC-SMS-01      | SMS     | Missed Call Text-Back       | 2 min after miss  | WF-Missed-Call-Textback    | Auto        |


---

## New Leads — Day 0

**Stage:** New Leads | **Cadence:** Immediate (speed to lead) | **Owner:** LM or AM (by source) + GHL auto

Day 0 SMS varies by source: CO-SMS-00/00A (Cold SMS, Cold Call), IN-SMS-00/00A (Website, VAPI, Referral), DM-SMS-00/00A (Direct Mail). Rest of Day 1-30 sequence is identical across all sources.

---

#### CO-SMS-00 | Cold Outbound Speed to Lead (Day 0, 120s wait)

> Hey {{first_name}}, it's {{agent_name}} with Bana Land — had a quick question about your property in {{opportunity.property_county}}. Mind if I give you a call?

---

#### CO-SMS-00A | Missed Call (Day 0, ~1hr after call attempt)

> Hey {{first_name}}, it's {{agent_name}} from Bana Land — just tried you on the phone. Call me back when you get a chance: [CALLBACK NUMBER]

---

#### IN-SMS-00 | Inbound Speed to Lead (Day 0, 120s wait)

> Hey {{first_name}}, just saw your info come through about your property in {{opportunity.property_county}} — I'd love to chat about it. Mind if I give you a call?

---

#### IN-SMS-00A | Inbound Missed Call (Day 0, ~1hr after call attempt)

> Hey {{first_name}}, it's {{agent_name}} with Bana Land — just tried giving you a call about your property. Call me back when you get a chance: [CALLBACK NUMBER]

---

#### DM-SMS-00 | Direct Mail Speed to Lead (Day 0, 120s wait)

> Hey {{first_name}}, it's {{agent_name}} with Bana Land — we sent a letter about your property in {{opportunity.property_county}}. Would it be worth a quick call?

---

#### DM-SMS-00A | Direct Mail Missed Call (Day 0, ~1hr after call attempt)

> Hey {{first_name}}, it's {{agent_name}} from Bana Land — just tried you on the phone about the letter we sent. Call me back when you get a chance: [CALLBACK NUMBER]

---

## New Leads — Day 1-10

**Stage:** Day 1-10 | **Cadence:** Days 1-2: 2x per day, Days 3-10: 1x per day | **Owner:** LM or AM (by source) + GHL auto

---

#### NL-SMS-01 | First Touch (Day 1, Morning)

> {{first_name}}, it's {{agent_name}} from Bana Land — we've been buying some land in {{opportunity.property_county}} and yours came up. Would it be worth a quick conversation?

---

#### NL-SMS-07 | Missed Call Follow-Up (Day 1-10, Afternoon)

> Hey {{first_name}}, tried to reach you just now — this is {{agent_name}} with Bana Land. When you get a sec, here's my direct line: [CALLBACK NUMBER]

---

#### NL-EMAIL-01 | First Email (Day 2, Morning)

**Subject:** Your land in {{opportunity.property_county}}

Hey {{first_name}},

This is {{agent_name}} with Bana Land — we buy rural properties and yours caught my attention. I had a couple of questions about it.

Would you be open to a 5-minute call this week?

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

#### NL-SMS-02 | Follow-Up (Day 2)

> {{first_name}}, wanted to run something by you about your land in {{opportunity.property_county}}. Got a minute to talk? — {{agent_name}}, Bana Land

---

## Day 3-10 Templates (continued — still Day 1-10 stage)

---

#### NL-SMS-10 | Casual Value Hint (Day 4)

> {{first_name}}, something came up when I was looking into your property in {{opportunity.property_county}} — are you around for a quick call? — {{agent_name}}, Bana Land

---

#### NL-EMAIL-05 | Quick Follow-Up (Day 5)

**Subject:** Quick question for you

Hey {{first_name}},

We've been working on a few deals in {{opportunity.property_county}} and your property keeps coming up in our research. Figured I should reach out directly.

Have you given any thought to what you'd want for it?

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

#### NL-EMAIL-02 | Follow-Up (Day 7)

**Subject:** Am I reaching the right person?

Hey {{first_name}},

I've sent a couple messages about your property in {{opportunity.property_county}} — wanted to make sure I'm reaching the right person.

If you're the owner, I'd love to connect for a few minutes. If not, no worries — just let me know.

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

#### NL-SMS-03 | Day 8

> {{first_name}}, curious — is your property in {{opportunity.property_county}} something you'd consider selling this year, or is the timing off? — {{agent_name}}, Bana Land

---

#### NL-SMS-08 | Check-In (Day 10)

> Hey {{first_name}}, I've reached out a few times — not trying to bug you. Would a conversation even make sense, or should I take a step back? — {{agent_name}}, Bana Land

---

## New Leads — Day 11-30

**Stage:** Day 11-30 | **Cadence:** Every 2–3 days | **Owner:** LM or AM (by source) + GHL auto

---

#### NL-SMS-04 | Re-Engage (Day 11)

> {{first_name}}, I've been trying to connect about your property — where should we go from here? — {{agent_name}}, Bana Land

---

#### NL-EMAIL-03 | Mid-Range Follow-Up (Day 15)

**Subject:** Has anything changed?

Hey {{first_name}},

I reached out a couple weeks ago about your land in {{opportunity.property_county}}. Sometimes the timing just isn't right, and that's fine.

I'm curious — has anything changed with your situation since then?

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

#### NL-SMS-09 | Mid-Range Follow-Up (Day 17)

> {{first_name}}, would it help if I just sent you a number on your property? That way you can decide if it's even worth talking. — {{agent_name}}, Bana Land

---

#### NL-SMS-05 | Check-In (Day 22)

> {{first_name}}, out of curiosity — what would need to happen for selling your land to make sense? — {{agent_name}}, Bana Land

---

#### NL-EMAIL-04 | Long-Game Setup (Day 29)

**Subject:** Wrapping up on your property

Hey {{first_name}},

I'm going to move your property to the back of my list — figured I should give you one more heads up before I do.

If you want to have a conversation about what your land is worth, I'm here. Otherwise, no hard feelings.

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

#### NL-SMS-06 | 30-Day Close

> {{first_name}}, closing out my notes on your property. If you ever want to pick this back up, you've got my number. — {{agent_name}}, Bana Land

---

## Cold — Monthly Drip (Months 1–3)

**Stage:** LT FU: Cold / Lost | **Cadence:** 30-day wait on entry, then SMS + Email each month, ~2 weeks apart | **Owner:** GHL auto only
**Applies to:** LT FU: Cold leads (no response) and LT FU: Lost leads (non-terminal Lost status)
**Trigger:** WF-Cold-Drip-Monthly fires on LT FU: Cold/Lost stage entry or enrollment by WF-Dispo-Re-Engage

---

#### COLD-SMS-01 | Day 30

> Hey {{first_name}}, it's {{agent_name}} from Bana Land — just had time to circle back. You ever figure out what you wanted to do with your property?

---

#### COLD-EMAIL-01 | Day 44

**Subject:** We just closed nearby

Hey {{first_name}},

We picked up a property in your area recently and it reminded me of yours. Figured I'd reach out.

Have your plans changed at all since we last talked?

— {{agent_name}} | Bana Land

---

#### COLD-SMS-02 | Day 58

> {{first_name}}, random question — are you paying taxes on that property in {{opportunity.property_county}} and wondering if it's even worth holding onto? — Bana Land

---

#### COLD-EMAIL-02 | Day 72

**Subject:** Something came up

Hey {{first_name}},

I know it's been a while — we've been doing more deals in your area and I wanted to see if your property is something you'd reconsider.

Even if it's a "not right now," that's helpful for me to know. What are you thinking?

— {{agent_name}} | Bana Land

---

#### COLD-SMS-03 | Day 86

> {{first_name}}, it's Bana Land — your property still on your mind at all, or have you moved on from that?

---

#### COLD-EMAIL-03 | Day 100

**Subject:** One more from me

Hey {{first_name}},

I'll space out my messages after this one. Before I do — is selling your land something that's completely off the table, or just not the right time?

Either way is fine. Just want to know where we stand.

— {{agent_name}} | Bana Land

---

## Long-Term Quarterly Drip (Month 4–28)

**Applies to:** Cold / Nurture / Lost | **Cadence:** SMS + Email same day, every 90 days | **Owner:** GHL auto only
**Trigger:** WF-Long-Term-Quarterly fires after Cold Monthly or Nurture Monthly completes (or directly to skip monthly)
**Rotation:** 4 unique quarters (Q1–Q4), plays twice (24 months total), then stops.
**Note:** After Q4 plays the second time, no further automated touches — WF-Response-Handler still catches any future inbound reply.

---

#### LTQ-SMS-01 | Q1 SMS

> {{first_name}}, it's Bana Land — you ever decide what you wanted to do with that property?

---

#### LTQ-EMAIL-01 | Q1 Email

**Subject:** Been a while

Hey {{first_name}},

We're still buying land in your area and yours is still on my list.

Worth a quick conversation, or should I hold off?

— {{agent_name}} | Bana Land | [CALLBACK NUMBER]

---

#### LTQ-SMS-02 | Q2 SMS

> {{first_name}}, we just picked up another property in your county. Yours still available? — {{agent_name}}, Bana Land

---

#### LTQ-EMAIL-02 | Q2 Email

**Subject:** Sellers in your area

Hey {{first_name}},

We've been working with a few landowners in {{opportunity.property_county}} recently. Your property came back up.

Would you want to hear what we'd offer, or is this not the right time?

— {{agent_name}} | Bana Land

---

#### LTQ-SMS-03 | Q3 SMS

> {{first_name}}, figured you'd decided to keep your land — is that right, or is selling still on your radar? — Bana Land

---

#### LTQ-EMAIL-03 | Q3 Email

**Subject:** Closing the loop

Hey {{first_name}},

I've had your property in my notes for a while now. Trying to figure out if I should keep it there or move on.

What would you say — is this worth a conversation?

— Bana Land | [CALLBACK NUMBER]

---

#### LTQ-SMS-04 | Q4 SMS

> {{first_name}}, honest question — what's keeping you from selling that land? Curious if there's something we could help with. — {{agent_name}}, Bana Land

---

#### LTQ-EMAIL-04 | Q4 Email

**Subject:** Quick question

Hey {{first_name}},

I've been reaching out periodically about your land and wanted to ask straight up — should I keep your property on my list, or would you rather I stop reaching out?

Either way is fine.

— {{agent_name}} | Bana Land

---

## Nurture — Monthly (Months 1–3)

**Stage:** LT FU: Nurture | **Cadence:** Every 30 days (30-day wait before first touch) | **Owner:** GHL auto only
**Trigger:** WF-Nurture-Monthly fires on LT FU: Nurture stage entry
**Channels:** SMS + Email only

---

#### NUR-SMS-01 | Month 1

> Hey {{first_name}}, it's {{agent_name}} from Bana Land — been thinking about our conversation. Has anything shifted on your end with the property?

---

#### NUR-EMAIL-01 | Month 2

**Subject:** Thinking about our conversation

Hey {{first_name}},

Last time we spoke, it sounded like the timing wasn't quite right. Totally get that.

I'm curious — has anything changed, or are you still in the same spot?

— {{agent_name}} | Bana Land

---

#### NUR-SMS-02 | Month 3

> {{first_name}}, just circling back — where do things stand with your property these days? Would love to reconnect if it makes sense. — {{agent_name}}, Bana Land

Trigger: WF-Nurture-Monthly enrolls contact in WF-Long-Term-Quarterly at Month 3.

After Nurture Monthly, leads enter the shared **Long-Term Quarterly Drip** (see LTQ templates above). Same templates as Cold leads — both are unresponsive at this point.

---

## Missed Call Text-Back

**Workflow:** WF-Missed-Call-Textback | **Owner:** Auto (SMS) — reply visible in conversation + notification

---

#### MC-SMS-01 | Missed Call Auto-Reply (2 min delay)

**Used by:** WF-Missed-Call-Textback — sent 2 minutes after a missed inbound call from a known contact.

> Hey, this is {{agent_name}} with Bana Land — saw you just called. I'll try you right back, or feel free to text me here.

---

## Voicemail Scripts

**When to use:** When a manual call goes to voicemail, leave the appropriate voicemail script below, then immediately send NL-VMSMS-01 (combo SMS) via GHL conversation. The voicemail + SMS combo dramatically increases callback rate.

**Key principle:** Voicemails should be incomplete — mention that something came up or you have a question, but do NOT say what. This creates an open loop that gives them a reason to call back.

---

#### NL-VM-01 | Day 1-10 Voicemail Script (~15 sec)

**Used by:** LM or AM during manual call tasks in WF-Day-1-10. Leave this voicemail, then send NL-VMSMS-01.

> Hey {{first_name}}, it's {{agent_name}} with Bana Land. I was looking into your property in {{opportunity.property_county}} and something came up I wanted to ask you about. Give me a call when you get this: [CALLBACK NUMBER].

---

#### NL-VM-02 | Day 11-30 Voicemail Script (~15 sec)

**Used by:** LM or AM during manual call tasks in WF-Day-11-30. Leave this voicemail, then send NL-VMSMS-01.

> Hey {{first_name}}, it's {{agent_name}} from Bana Land. I've got a quick update on your property — call me back when you get a chance: [CALLBACK NUMBER].

---

#### NL-VMSMS-01 | Voicemail Combo SMS

**Used by:** LM or AM — sent manually via GHL conversation immediately after leaving a voicemail (NL-VM-01 or NL-VM-02).

> Hey {{first_name}}, just left you a voicemail — call me back when you get a sec: [CALLBACK NUMBER]. — {{agent_name}}, Bana Land

---

## Ringless Voicemail Drops (RVM) — Day 11-30

**Stage:** Day 11-30 | **Cadence:** Automated drops filling gaps between existing touches | **Owner:** GHL auto
**Workflow:** WF-Day-11-30 | **Send window:** 9am–7pm contact local time

These are automated RVM drops delivered directly to voicemail without ringing the phone. They maintain presence during the wind-down phase without adding more SMS or email.

**Key principle:** Each RVM uses a different hook. Sound natural, like you're calling between meetings. ~15 seconds each.

---

#### NL-RVM-01 | ~Day 14

> Hey {{first_name}}, it's {{agent_name}} from Bana Land. Was going through some properties in your area and had a question about yours. Call me when you get a chance: [CALLBACK NUMBER].

---

#### NL-RVM-02 | ~Day 20

> Hey {{first_name}}, it's {{agent_name}} with Bana Land — wanted to touch base on your property, got something I wanted to run by you. Give me a ring: [CALLBACK NUMBER].

---

#### NL-RVM-03 | ~Day 27

> Hey {{first_name}}, it's Bana Land — before I wrap up on your property, wanted to see if we could connect. Call me at [CALLBACK NUMBER].
