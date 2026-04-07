# Prospect Data — Rules
*Last edited: 2026-04-08 · Last reviewed: —*

Operating rules for the Prospect Data instance. Covers data uploads,
campaign management, status transitions, and push-to-CRM rules.

---

## 1. Data Upload Rules

### Property Uploads

- Upload via CSV. One row per property.
- `**reference` (Reference ID) is the master unique key.** If a `reference` already exists, update
the existing record rather than creating a duplicate. APN is a data point, not the dedup key.
- Leave Status blank on initial upload (blank = available for campaigns). Set to DNC or Removed only if the record is known DNC or disqualified.
- Current CSVs include property data + skip trace data in one file. When both are
present, set Skip Trace Date = upload date.
- Leave Owner fields blank if property has not been skip traced yet.
Skip Trace Date = blank.

### Data Cleaning (on upload or via automation pre-processing)

- `0` in phone fields → store as blank (0 = no data from skip trace provider)
- `0` in Age field → store as blank (0 = unknown)
- `#N/A` in Offer Price → store as blank (no offer calculated)
- Phone Type values stored as raw text from skip trace provider (Mobile, Residential, Landline, VoIP, etc.) — no conversion needed
- Deceased: `Y` / `N` / blank → store as-is

### Skip Trace Updates

- Match to existing Property records by `reference`.
- Populate Owner 1/2/3 fields. Fill owners in order — Owner 1 first, then 2, then 3.
- Set Skip Trace Date = today.
- If a phone or email slot is empty from the skip trace provider, leave it blank.
Do not fill in "N/A" or placeholder values.
- Phone Type fields are raw text from the skip trace provider. Store as-is.
These inform which channels are valid for outreach when pushing to New Leads.

### Deduplication

- Before uploading, deduplicate by `reference` within the upload file.
- On upload, check for existing `reference` in GHL. Update existing records; do not create duplicates.
- If the same property appears in multiple upload files over time, the latest skip trace
data overwrites the old data on that record.

---

## 2. Campaign Rules

### Creating a Campaign

1. Create a record in the Campaigns custom object with all metadata filled in
  (name, type, status, dates).
2. Campaign Name must be unique. Use a consistent naming convention:
  `[Type Abbreviation]-[State]-[County]-[Date]`
   Examples: `CS-TX-Travis-2026-03`, `DM-FL-Marion-2026-Q1`, `CC-AZ-Mohave-2026-03`
  - CS = Cold SMS, CC = Cold Call, DM = Direct Mail
3. Set the **Campaign Tag** field to the exact tag that will be applied to Properties.
  Format: `campaign: [campaign name]`
   Example: Campaign Name = `CS-TX-Travis-2026-03` → Campaign Tag = `campaign: cs-tx-travis-2026-03`
   This is the single source of truth for which tag links Properties to this Campaign.
4. Set Campaign Status to `Planning` until properties are assigned and ready to send.

### Assigning Properties to a Campaign

Properties can be assigned to a campaign in two ways:

**Method 1: Upload with tags (most common)**

- CSV is prepared externally with properties already selected for a specific campaign.
- On upload, include the campaign tag `campaign: [campaign name]` on each record.
- Update Total Records count on the Campaign record after upload.

**Method 2: Tag from within GHL**

- Filter existing Properties by target criteria (state, county, acreage range,
Status is blank, Skip Trace Date is not blank).
- Apply the campaign tag to all matching properties: `campaign: [campaign name]`
- Update Total Records count on the Campaign record.

In either case, set Campaign Status to `Active` when the campaign launches.

### Campaign Completion

- Set Campaign Status to `Completed` and fill in End Date.
- Do not remove campaign tags from properties — they preserve history.

---

## 3. Status Management

### Status Transitions

```
(blank) ──► Pipeline      (property pushed to New Leads)
(blank) ──► DNC           (owner requests DNC)
(blank) ──► Removed       (bad data, duplicate, sold, purchased, disqualified)

Pipeline ──► (blank)      (deal fell through, removed from New Leads)
Pipeline ──► DNC          (owner requests DNC while in pipeline)
Pipeline ──► Removed      (bad data discovered, property sold/purchased, disqualified)

DNC ──► Removed           (property sold or otherwise permanently off the table)
Removed ──► (blank)       (if data was corrected or error was reversed)
```

### DNC Handling

- **New Leads → Prospect Data:** When a DNC is triggered in New Leads, the DNC sync (WF-DNC-Handler) updates the Property record in Prospect Data:
  - Set DNC = checked
  - Set DNC Date = today
  - Set Status = DNC
- **Prospect Data → New Leads:** When a property is manually marked DNC in Prospect Data (e.g., external DNC list, prior system data), automation should push DNC status to the corresponding Contact in New Leads if one exists:
  - Tag `dnc` on Contact
  - Change Opportunity status to Lost + Lost Reason = DNC
  - Set Contact DND for ALL channels
  - Remove from all active workflows
- DNC applies to the entire property record, not individual owners. If any owner on the
property is DNC, the property is DNC.
- DNC properties must not be included in any future campaigns.
- When filtering properties for a new campaign, always exclude Status = DNC.

### CRM Push Tracking

- When a property is pushed to New Leads, set `Status = Pipeline` and set `CRM Push Date`.
- `Status = Pipeline` indicates the property is active in New Leads. No separate "pushed" checkbox — the status itself is the record.
- `Push to CRM` is a separate trigger field for manual pushes (see Section 4).

### Re-Submission Behavior

When a property is re-submitted to New Leads from a new external campaign (NL WF-New-Lead-Entry fires), update the Property record in Prospect Data as follows:

- **Status:** Stays `Pipeline`. No transition needed — the property is already active in a pipeline.
- **Campaign tag:** Add the new campaign tag (`campaign: [new campaign name]`). Do not remove old campaign tags — they stack as history.
- **CRM Push Date:** Update to today's date to reflect the new push.

These updates are currently manual. The re-submission automation (NL WF-New-Lead-Entry) does not write back to Prospect Data. Until automated, whoever manages the re-submission should update the Property record at the same time.

---

## 4. Push-to-CRM Rules

### When to Push

Properties are pushed to New Leads when a lead comes in that is associated with the
property record. This is not tied to campaigns — it happens whenever the property data
needs to exist in the CRM for lead follow-up.

### How a Push Happens

There are two paths:

**Automated push (most common):**
A lead comes in → automation searches Prospect Data by reference ID, phone number, etc.
→ match found → automation reads the Property record → creates Contact + Opportunity
in New Leads → sets `Status = Pipeline` + sets `CRM Push Date`.

**Manual push:**
No auto-match found, or the team manually identifies a property in Prospect Data that
needs to be pushed. The user checks `Push to CRM` on the Property record → automation
fires on field change → reads the Property record → creates Contact + Opportunity in
New Leads → sets `Status = Pipeline` + sets `CRM Push Date` → unchecks `Push to CRM`.

Both paths end with the same result in New Leads and the same post-push updates in
Prospect Data. The only difference is how the push is initiated.

### What Gets Pushed

- Automation reads the Property record and splits it into Contact + Opportunity per the
field mapping in data-model.md.
- One Contact is created per owner that has at least one valid phone number or email.
- One Opportunity is created per property, linked to the primary owner's Contact.
- If multiple owners exist, additional Contacts are created and linked to the same Opportunity.

### Post-Push Updates

After successful push to New Leads:

- Set Status = Pipeline
- Set `CRM Push Date`
- If push was triggered via `Push to CRM`, uncheck it

---

## 5. Tag Conventions

All tags are stored lowercase by GHL. Use `category: value` format, matching New Leads.

### Campaign Tags

- `campaign: [campaign name]` — one tag per campaign, stacks over time

---

## 6. Data Hygiene

- **Quarterly review:** Properties with blank Status that have not been included in any
campaign for 6+ months should be flagged for re-skip-tracing or removal.
- **Sold property scrub:** Periodically cross-reference against public records or a sold
property list. Mark confirmed sales as Removed.
- **DNC audit:** DNC records should never appear in campaign filters. Run a monthly check
to verify no DNC-tagged properties leaked into active campaign lists.

