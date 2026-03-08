# Bana Land — Open Decisions & To-Do Items

Track outstanding decisions that block or affect the GHL build.
Mark items as **RESOLVED** once the team makes a call, and update the relevant files.

---

## Open Decisions

### DNC at Property & Contact Level

**Status:** OPEN

DNC should be tracked at both property and contact level to ensure coverage.

- If someone says you have the wrong number or email, that is a number/email level issue — those numbers/emails should be deleted from the contact and logged in notes as wrong number/email. These are NOT DNC at the contact or property level. Just removing incorrect contact info.
- Do we need a separate DNC list for emails/phones as a standalone for wrong-number/wrong-email types?

**Affected files:** warm-response/rules.md, new-leads/rules.md, ROLE.md

---

AI said this but it was readlly wrong

Here's how I'll resolve this. The system already has the pieces — just needs explicit documentation of three distinct scenarios:

Contact-level DNC — person says "stop contacting me" → existing DNC protocol (tag + kill all workflows + sync). Permanent. Blocks re-submissions too.
Property-level DNC — person says "not interested in this property" → Dispo: DNC on the opportunity. Contact itself is NOT DNC'd. Re-submissions for new properties are allowed.
Wrong number/email — NOT DNC at all. Data cleanup: delete bad info, add note, tag for tracking (Wrong Number / Wrong Email). No separate list needed.
Updating all affected files now.

Edit c:\Users\J\Projects\Bana Follow Up\warm-response\rules.md
Added 25 lines
Edit c:\Users\J\Projects\Bana Follow Up\new-leads\rules.md
Added 25 lines
