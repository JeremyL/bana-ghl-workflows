# Bana Land — Warm Response Account: Message Templates

All outreach for Bana Land must follow this voice:

- **Short** — SMS <= 2 sentences, Email <= 4 sentences
- **Casual and curious** — not desperate, not salesy
- **NEPQ-influenced** — ask questions, don't pitch, let them talk
- **Status-maintained** — we're a solution-provider, not a beggar
- **Rural-appropriate** — plain language, no jargon

Use `{{first_name}}` for GHL merge tag (first name of contact).
Use `{{agent_name}}` for the team member's name.
Replace `[CALLBACK NUMBER]` with the agent's dedicated phone line.

For the New Leads account templates, see [../new-leads/messaging.md](../new-leads/messaging.md).

---

## Template Naming Convention

All template IDs follow the pattern: `STAGE-CHANNEL-##`

| Prefix | Stage                                |
| ------ | ------------------------------------ |
| WR     | Warm Response (Lead Manager)         |
| COLD   | Cold Monthly Drip (Day 0-180)        |
| COLDQ  | Cold Quarterly Drip (Day 180+)       |

---

## Quick Reference — All Templates

| ID             | Channel | Stage                 | Timing            | Workflow | Auto/Manual |
| -------------- | ------- | --------------------- | ----------------- | -------- | ----------- |
| WR-EMAIL-01    | Email   | Warm Response         | Immediate         | WF-00A   | Auto        |
| WR-EMAIL-02    | Email   | Warm Response         | Day 2             | WF-00A   | Auto        |
| WR-SMS-01      | SMS     | Warm Response         | Day 3             | WF-00B   | Auto        |
| WR-EMAIL-03    | Email   | Warm Response         | Day 4             | WF-00A   | Auto        |
| WR-SMS-02      | SMS     | Warm Response         | Day 5             | WF-00B   | Auto        |
| WR-EMAIL-04    | Email   | Warm Response         | Day 7             | WF-00A   | Auto        |
| WR-SMS-03      | SMS     | Warm Response         | Day 8             | WF-00B   | Auto        |
| WR-EMAIL-05    | Email   | Warm Response         | Day 10            | WF-00A   | Auto        |
| WR-SMS-04      | SMS     | Warm Response         | Day 14            | WF-00B   | Auto        |
| WR-COLD-SMS-01 | SMS     | Warm Response → Cold  | Day 14 (one-time) | WF-00A   | Auto        |
| COLD-SMS-01    | SMS     | Cold Monthly          | Month 1           | WF-05    | Auto        |
| COLD-EMAIL-01  | Email   | Cold Monthly          | Month 2           | WF-05    | Auto        |
| COLD-SMS-04    | SMS     | Cold Monthly          | Month 3           | WF-05    | Auto        |
| COLD-SMS-02    | SMS     | Cold Monthly          | Month 4           | WF-05    | Auto        |
| COLD-EMAIL-02  | Email   | Cold Monthly          | Month 5           | WF-05    | Auto        |
| COLD-SMS-03    | SMS     | Cold Monthly          | Month 6           | WF-05    | Auto        |
| COLDQ-SMS-01   | SMS     | Cold Quarterly        | Every 90 days     | WF-06    | Auto        |
| COLDQ-EMAIL-01 | Email   | Cold Quarterly        | Every 90 days     | WF-06    | Auto        |

---

## Warm Response (Lead Manager)

These messages are used exclusively in the Warm Response stage.
The prospect has already said "yes" — tone should acknowledge that and feel like a natural next step,
not a cold outreach. Lead manager name is used, not a generic agent tag.

---

### WR-EMAIL-01 | Ask for Phone Number (Immediate)

**Subject:** Re: Your property

Hey {{first_name}},

Thanks for getting back to me — glad to hear you're open to a conversation.

What's the best number to reach you at? I'd love to connect for just a few minutes.

— {{agent_name}} | Bana Land

---

### WR-EMAIL-02 | Follow-Up (Day 2, no number received)

**Subject:** Re: Your property

Hey {{first_name}}, just following up — did you get my last message?

If you're still open to a quick chat, just reply with your number and I'll give you a call.

— {{agent_name}} | Bana Land

---

### WR-EMAIL-03 | Check-In (Day 4, no number received)

**Subject:** Re: Your property

Hey {{first_name}}, one more check-in. Happy to work around your schedule — just need a good number to reach you.

Or if it's easier, feel free to call or text me directly: [CALLBACK NUMBER]

— {{agent_name}} | Bana Land

---

### WR-EMAIL-04 | Mid-Window (Day 7, no number received)

**Subject:** Re: Your property

Hey {{first_name}}, still thinking about connecting on your property.

If a quick call works better than email, just reply with your number and I'll reach out at a time that works for you.

— {{agent_name}} | Bana Land

---

### WR-EMAIL-05 | Soft Close (Day 10, no number received)

**Subject:** Re: Your property

Hey {{first_name}}, I know life gets busy — no rush on my end.

When you're ready, just reply with a good number or call me directly: [CALLBACK NUMBER]

— {{agent_name}} | Bana Land

---

### WR-SMS-01 | Day 3 Follow-Up

> Hey {{first_name}}, still trying to connect about your land. Would love to chat for a few minutes when you have a chance. — {{agent_name}}, Bana Land

---

### WR-SMS-02 | Day 5 Check-In

> {{first_name}}, just checking in — you mentioned being open to a conversation. Still the case? — Bana Land

---

### WR-SMS-03 | Day 8 Check-In

> Hey {{first_name}}, still reaching out about your land. Just want to make sure you saw my messages — feel free to call or text back when you have a minute. — {{agent_name}}, Bana Land

---

### WR-SMS-04 | Day 14 Final Touch

> Hey {{first_name}}, we've been trying to connect for a couple weeks. We'll keep you in our system and check back in — but if you ever want to chat about your property, feel free to reach out anytime. — {{agent_name}}, Bana Land

---

### WR-COLD-SMS-01 | Email-to-Cold One-Time SMS (Day 14)

**Used by:** WF-00A Step 13 — sent once to each skip-traced phone number when a Warm Response email lead moves to Cold with no confirmed phone.
**Goal:** Bridge the email conversation to a phone connection. Sent once per number. No further SMS in Cold drip for these contacts.

> Hey {{first_name}}, we've been trying to connect over email about your land — this is {{agent_name}} with Bana Land. Is this a good number to reach you?

---

## Cold — Monthly Drip (Day 0-180 in Cold)

**Stage:** Cold | **Cadence:** Monthly (every 30 days) | **Owner:** GHL auto only
**Applies to:** Warm Response leads that timed out after 14 days
**Entry tag:** `Drip: Cold Monthly`
**Note:** Same templates as New Leads' Cold drip.

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

At Month 6 → Remove tag `Drip: Cold Monthly` → Add tag `Drip: Cold Quarterly` → transition to quarterly phase.

---

## Cold — Quarterly Drip (Day 180+)

**Stage:** Cold | **Cadence:** Every 90 days (indefinite) | **Owner:** GHL auto only
**Entry tag:** `Drip: Cold Quarterly` (swapped in from `Drip: Cold Monthly` at Month 6)

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
