# Bana Land — New Leads Account: Message Templates

All outreach for Bana Land must follow this voice:

- **Short** — SMS <= 2 sentences, Email <= 4 sentences
- **Casual and curious** — not desperate, not salesy
- **NEPQ-influenced** — ask questions, don't pitch, let them talk
- **Status-maintained** — we're a solution-provider, not a beggar
- **Rural-appropriate** — plain language, no jargon

Use `{{first_name}}` for GHL merge tag (first name of contact).
Use `{{agent_name}}` for the team member's name.
Replace `[CALLBACK NUMBER]` with the agent's dedicated phone line.

For the Warm Response account templates, see [../warm-response/messaging.md](../warm-response/messaging.md).

---

## Template Naming Convention

All template IDs follow the pattern: `STAGE-CHANNEL-##`


| Prefix | Stage                          |
| ------ | ------------------------------ |
| NL     | New Leads (Day 1-30)           |
| COLD   | Cold Monthly Drip (Day 30-180) |
| COLDQ  | Cold Quarterly Drip (Day 180+) |
| NUR    | Nurture Monthly (Months 0-3)   |
| NURQ   | Nurture Quarterly (Month 3+)   |


---

## Quick Reference — All Templates (Account: New Leads)


| ID             | Channel | Stage                       | Timing            | Workflow | Auto/Manual |
| -------------- | ------- | --------------------------- | ----------------- | -------- | ----------- |
| NL-SMS-01      | SMS     | New Leads — Day 1-2         | Day 1, Morning    | WF-02    | Auto        |
| NL-SMS-07      | SMS     | New Leads — Day 1-2         | Day 1, Afternoon  | WF-02    | Auto        |
| NL-EMAIL-01    | Email   | New Leads — Day 1-2         | Day 2, Morning    | WF-02    | Auto        |
| NL-SMS-02      | SMS     | New Leads — Day 1-2 / 3-14  | Day 2, Day 4      | WF-02 / WF-03 | Auto        |
| NL-EMAIL-05    | Email   | New Leads — Day 3-14        | Day 5             | WF-03    | Auto        |
| NL-EMAIL-02    | Email   | New Leads — Day 3-14        | Day 7             | WF-03    | Auto        |
| NL-SMS-03      | SMS     | New Leads — Day 3-14        | Day 8             | WF-03    | Auto        |
| NL-SMS-08      | SMS     | New Leads — Day 3-14        | Day 10            | WF-03    | Auto        |
| NL-SMS-04      | SMS     | New Leads — Day 3-14        | Day 11            | WF-03    | Auto        |
| NL-EMAIL-03    | Email   | New Leads — Day 15-30       | Day 15            | WF-04    | Auto        |
| NL-SMS-09      | SMS     | New Leads — Day 15-30       | Day 17            | WF-04    | Auto        |
| NL-SMS-05      | SMS     | New Leads — Day 15-30       | Day 22            | WF-04    | Auto        |
| NL-EMAIL-04    | Email   | New Leads — Day 15-30       | Day 29            | WF-04    | Auto        |
| NL-SMS-06      | SMS     | New Leads — Day 15-30       | Day 30            | WF-04    | Auto        |
| COLD-SMS-01    | SMS     | Cold Monthly                | Month 1           | WF-05    | Auto        |
| COLD-EMAIL-01  | Email   | Cold Monthly                | Month 2           | WF-05    | Auto        |
| COLD-SMS-04    | SMS     | Cold Monthly                | Month 3           | WF-05    | Auto        |
| COLD-SMS-02    | SMS     | Cold Monthly                | Month 4           | WF-05    | Auto        |
| COLD-EMAIL-02  | Email   | Cold Monthly                | Month 5           | WF-05    | Auto        |
| COLD-SMS-03    | SMS     | Cold Monthly                | Month 6           | WF-05    | Auto        |
| COLDQ-SMS-01   | SMS     | Cold Quarterly              | Every 90 days     | WF-05    | Auto        |
| COLDQ-EMAIL-01 | Email   | Cold Quarterly              | Every 90 days     | WF-05    | Auto        |
| NUR-SMS-01     | SMS     | Nurture Monthly             | Month 0           | WF-08    | Auto        |
| NUR-EMAIL-01   | Email   | Nurture Monthly / Quarterly | Month 1, Month 9  | WF-08    | Auto        |
| NUR-SMS-02     | SMS     | Nurture Monthly / Quarterly | Month 2, Month 15 | WF-08    | Auto        |
| NURQ-EMAIL-01  | Email   | Nurture Quarterly           | Month 3           | WF-08    | Auto        |
| NURQ-SMS-01    | SMS     | Nurture Quarterly           | Month 6           | WF-08    | Auto        |
| NURQ-SMS-02    | SMS     | Nurture Quarterly           | Month 12 (1-Year) | WF-08    | Auto        |


---

## New Leads — Day 1-2

**Stage:** Day 1-2 | **Cadence:** 2x per day | **Owner:** Acquisition Manager + GHL auto

---

### NL-SMS-01 | First Touch (Day 1, Morning)

> Hey {{first_name}}, this is {{agent_name}} with Bana Land — we buy land in your area and thought you might be open to a cash offer. Is that something worth a quick conversation?

---

### NL-SMS-02 | Follow-Up (Day 2 / Day 4)

> Hey {{first_name}}, just following up on my last message. We're still interested in your property — no pressure, just wanted to make sure you saw it.

---

### NL-EMAIL-01 | First Touch (Day 2, Morning)

**Subject:** Quick question about your land in [County Name]

Hey {{first_name}},

My name is {{agent_name}} — I work with Bana Land, a company that buys rural properties directly from owners like yourself.

I came across your property and wanted to reach out. Are you open to hearing a cash offer?

No agents, no fees, no obligations. Just wanted to ask.

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

### NL-SMS-07 | Missed Call Follow-Up (Day 1, Afternoon)

> Hey {{first_name}}, just tried giving you a call — this is {{agent_name}} with Bana Land. Give me a call back when you get a chance: [CALLBACK NUMBER]

---

## New Leads — Day 3-14

**Stage:** Day 3-14 | **Cadence:** Days 3-10 daily, Days 11-14 every 2-3 days | **Owner:** Acquisition Manager + GHL auto

Template NL-SMS-02 is reused from the Day 1-2 section above.

---

### NL-SMS-03 | Day 8

> {{first_name}}, still reaching out about your property. If you've got a few minutes, I'd love to hear what's going on with it. — {{agent_name}}, Bana Land

---

### NL-SMS-04 | Re-Engage (Day 11)

> Hey {{first_name}}, been trying to connect — totally understand if the timing isn't right. Is selling something you're still thinking about at some point? — {{agent_name}}, Bana Land

---

### NL-EMAIL-02 | Follow-Up (Day 7)

**Subject:** Re: Your property in [County Name]

Hey {{first_name}},

Just following up on my note from a few days ago about your land.

If now isn't a good time or you have questions, no worries at all — I just want to make sure you had a chance to see it.

Happy to answer anything you've got.

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

### NL-EMAIL-05 | Quick Follow-Up (Day 5)

**Subject:** Following up — Bana Land

Hey {{first_name}},

Just a quick follow-up from {{agent_name}} at Bana Land. I've been trying to reach you about your property.

If you've got a couple minutes, I'd love to connect — feel free to call or text me at [CALLBACK NUMBER].

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

### NL-SMS-08 | Check-In (Day 10)

> Hey {{first_name}}, still trying to connect about your property. If you have a few minutes, give me a call or shoot me a text. — {{agent_name}}, Bana Land [CALLBACK NUMBER]

---

### NL-SMS-09 | Mid-Range Follow-Up (Day 17)

> {{first_name}}, just circling back one more time. We're still interested in your property — no pressure, just want to make sure you know we're here. — {{agent_name}}, Bana Land

---

## New Leads — Day 15-30

**Stage:** Day 15-30 | **Cadence:** Tuesdays & Thursdays only | **Owner:** Acquisition Manager + GHL auto

---

### NL-SMS-05 | Check-In (Day 22)

> {{first_name}}, just a quick check-in — if you ever want a no-obligation offer on your land, we're still here. No rush. — Bana Land

---

### NL-SMS-06 | 30-Day Close

> Hey {{first_name}}, this'll be my last reach-out for a while. If things change and you want to talk about your land, feel free to text or call anytime — {{agent_name}} with Bana Land. [CALLBACK NUMBER]

---

### NL-EMAIL-03 | Mid-Range Follow-Up (Day 15)

**Subject:** Still interested in your property

Hey {{first_name}},

I know you're probably busy — just wanted to check in one more time.

We work with sellers across the country who want a straightforward, no-hassle sale. If that's something you'd consider, I'd love to get on a quick call.

No pressure at all — just here if you want to talk.

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

### NL-EMAIL-04 | Long-Game Setup (Day 29)

**Subject:** Keeping the door open

Hey {{first_name}},

I won't keep filling up your inbox — just wanted to say we're still here whenever the time is right.

A lot of the sellers we work with weren't ready to sell right away. When the situation changed, they gave us a call — and we made it easy.

If that ever becomes you, feel free to reach out anytime.

— {{agent_name}}
Bana Land | [CALLBACK NUMBER]

---

## Cold — Monthly Drip (Day 30-180)

**Stage:** Cold | **Cadence:** Monthly (every 30 days) | **Owner:** GHL auto only
**Applies to:** Cold stage leads AND all Dispo Re-Engage leads (No Motivation, Wants Retail, On MLS, Lead Declined)
**Trigger:** WF-05 fires on stage entry

---

### COLD-SMS-01 | Month 1

> Hey {{first_name}}, it's {{agent_name}} from Bana Land. Just checking in — has anything changed with your property situation?

---

### COLD-EMAIL-01 | Month 2

**Subject:** Quick check-in on your property

Hey {{first_name}},

Just a brief check-in from Bana Land. We're still active buyers in your county and wanted to see if anything had changed on your end.

If now's not the time, completely fine — just keeping the line open.

— {{agent_name}} | Bana Land

---

### COLD-SMS-04 | Month 3

> Hey {{first_name}}, quick check-in from Bana Land — we're still actively buying in your county. Has anything changed on your end? No rush, just checking in.

---

### COLD-SMS-02 | Month 4

> {{first_name}}, hope all is well — still interested in your land if the timing ever works. Just wanted to stay in touch. — Bana Land

---

### COLD-EMAIL-02 | Month 5

**Subject:** Still here when you're ready

Hey {{first_name}},

Hope things are going well. We're still buying land across the country and have helped a lot of sellers who just needed the right timing.

If that ever lines up for you, we'd love to reconnect.

— Bana Land

---

### COLD-SMS-03 | Month 6

> Hey {{first_name}}, it's been a few months — we're still actively buying land in your county. If you've been thinking about it, now might be a good time to connect. — Bana Land

Trigger: WF-05 transitions to quarterly phase automatically at Month 6.

---

## Cold — Quarterly Drip (Day 180+)

**Stage:** Cold | **Cadence:** Every 90 days (indefinite) | **Owner:** GHL auto only
**Trigger:** WF-05 (Phase 2) continues automatically

---

### COLDQ-SMS-01 | Quarterly SMS

> Hey {{first_name}}, quick check-in from Bana Land — still buying in your area. If your situation's changed, we'd love to talk.

---

### COLDQ-EMAIL-01 | Quarterly Email

**Subject:** Bana Land — still interested in your property

Hey {{first_name}},

Just a periodic check-in from our team. We continue to buy rural land across the US and your property is still of interest to us.

If your situation has changed or you'd like to revisit a conversation, reply to this email or give us a call.

— Bana Land | [CALLBACK NUMBER]

---

## Nurture — Monthly (Months 0-3)

**Stage:** Nurture | **Cadence:** Every 30 days | **Owner:** GHL auto only
**Trigger:** WF-08 fires on stage entry
**Channels:** SMS + Email only

---

### NUR-SMS-01 | Month 0

> Hey {{first_name}}, it's {{agent_name}} with Bana Land. Wanted to circle back — has anything changed with your property since we last talked?

---

### NUR-EMAIL-01 | Month 1 (reused at Month 9)

**Subject:** Following up from Bana Land

Hey {{first_name}},

It's been a little while since we connected. Wanted to touch base and see if anything's changed with your property.

No pressure — just wanted to stay on your radar in case the timing ever works out.

— {{agent_name}} | Bana Land

---

### NUR-SMS-02 | Month 2 (reused at Month 15)

> {{first_name}}, just wanted to stay on your radar. We're still actively buying land — if the timing's ever right, we're here.

Trigger: WF-08 transitions to quarterly phase automatically at Month 3.

---

## Nurture — Quarterly (Month 3+)

**Stage:** Nurture | **Cadence:** Every 90 days (indefinite) | **Owner:** GHL auto only
**Trigger:** WF-08 (Phase 2) continues automatically

Templates NUR-EMAIL-01 and NUR-SMS-02 are reused from the Monthly section above.

---

### NURQ-EMAIL-01 | Month 3

**Subject:** Still buying in your area

Hey {{first_name}},

We've been active buyers in your region this year and wanted to make sure you still have our info.

If you've been thinking about making a move on your land, we'd love to have that conversation.

— Bana Land | [CALLBACK NUMBER]

---

### NURQ-SMS-01 | Month 6

> Hey {{first_name}}, hope things are well — we've helped a lot of sellers in similar situations this year. Whenever you're ready, we'd love to revisit. — Bana Land

---

### NURQ-SMS-02 | 1-Year Touch (Month 12)

> {{first_name}}, it's been about a year — still thinking about your land at all? We're still in the market. — Bana Land

Continue rotating NUR-SMS-02, NUR-EMAIL-01, NURQ-SMS-01, NURQ-SMS-02 every 90 days indefinitely.

---



