# Prospect Data — Rules
*Last edited: 2026-03-19 · Last reviewed: —*

Operating rules for the Prospect Data instance. Covers data uploads,
campaign management, status transitions, and push-to-account rules.

---

## 1. Data Upload Rules

### Property Uploads

- Upload via CSV. One row per property.
- `**reference` (Reference ID) is the master unique key.** If a `reference` already exists, update
the existing record rather than creating a duplicate. APN is a data point, not the dedup key.
- Set Status to `Active` on initial upload unless the record is known DNC or Removed.
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
   Examples: `CE-TX-Travis-2026-03`, `DM-FL-Marion-2026-Q1`, `CC-AZ-Mohave-2026-03`
  - CE = Cold Email, CS = Cold SMS, CC = Cold Call, DM = Direct Mail
3. Set the **Campaign Tag** field to the exact tag that will be applied to Properties.
  Format: `Campaign: [Campaign Name]`
   Example: Campaign Name = `CE-TX-Travis-2026-03` → Campaign Tag = `Campaign: CE-TX-Travis-2026-03`
   This is the single source of truth for which tag links Properties to this Campaign.
4. Set Campaign Status to `Planning` until properties are assigned and ready to send.

### Assigning Properties to a Campaign

Properties can be assigned to a campaign in two ways:

**Method 1: Upload with tags (most common)**

- CSV is prepared externally with properties already selected for a specific campaign.
- On upload, include the campaign tag `Campaign: [Campaign Name]` on each record.
- Update Total Records count on the Campaign record after upload.

**Method 2: Tag from within GHL**

- Filter existing Properties by target criteria (state, county, acreage range,
Status = Active, Skip Trace Date is not blank).
- Apply the campaign tag to all matching properties: `Campaign: [Campaign Name]`
- Update Total Records count on the Campaign record.

In either case, set Campaign Status to `Active` when the campaign launches.

### Campaign Completion

- Set Campaign Status to `Completed` and fill in End Date.
- Do not remove campaign tags from properties — they preserve history.

---

## 3. Status Management

### Status Transitions

```
Active ──► Pipeline       (property pushed to New Leads)
Active ──► DNC            (owner requests DNC)
Active ──► Removed        (bad data, duplicate, sold, purchased, disqualified)

Pipeline ──► Active       (deal fell through, removed from New Leads)
Pipeline ──► DNC          (owner requests DNC while in pipeline)
Pipeline ──► Removed      (bad data discovered, property sold/purchased, disqualified)

DNC ──► Removed           (property sold or otherwise permanently off the table)
Removed ──► Active        (if data was corrected or error was reversed)
```

### DNC Handling

- **New Leads → Prospect Data:** When a DNC is triggered in New Leads, the DNC sync (WF-DNC-Handler) updates the Property record in Prospect Data:
  - Set DNC = checked
  - Set DNC Date = today
  - Set Status = DNC
- **Prospect Data → New Leads:** When a property is manually marked DNC in Prospect Data (e.g., external DNC list, prior system data), automation should push DNC status to the corresponding Contact in New Leads if one exists:
  - Tag `DNC` on Contact
  - Move Opportunity to Dispo: DNC
  - Remove from all active workflows
- DNC applies to the entire property record, not individual owners. If any owner on the
property is DNC, the property is DNC.
- DNC properties must not be included in any future campaigns.
- When filtering properties for a new campaign, always exclude Status = DNC.

### Account Push Tracking

- When a property is pushed to New Leads, check `Pushed to New Leads` and set Account Push Date.
- When a property is removed from the pipeline (deal dead, cold drip exhausted),
uncheck `Pushed to New Leads` and set Status back to Active.

### Re-Submission Behavior

When a property is re-submitted to New Leads from a new external campaign (NL WF-New-Lead-Entry fires), update the Property record in Prospect Data as follows:

- **Status:** Stays `Pipeline`. No transition needed — the property is already active in a pipeline.
- **Campaign tag:** Add the new campaign tag (`Campaign: [New Campaign Name]`). Do not remove old campaign tags — they stack as history.
- **Pushed to New Leads:** Should already be checked. If it was previously unchecked (e.g., the lead went cold and was removed), re-check it.
- **Account Push Date:** Update to today's date to reflect the new push.

These updates are currently manual. The re-submission automation (NL WF-New-Lead-Entry) does not write back to Prospect Data. Until automated, whoever manages the re-submission should update the Property record at the same time.

---

## 4. Push-to-Account Rules

### When to Push

Properties are pushed to New Leads when they are assigned to a campaign and that
campaign launches. All campaign types now route to New Leads:


| Campaign Type | Destination |
| ------------- | ----------- |
| Cold Email    | New Leads   |
| Cold SMS      | New Leads   |
| Cold Call     | New Leads   |
| Direct Mail   | New Leads   |


### What Gets Pushed

- Automation reads the Property record and splits it into Contact + Opportunity per the
field mapping in data-model.md.
- One Contact is created per owner that has at least one valid phone number or email.
- One Opportunity is created per property, linked to the primary owner's Contact.
- If multiple owners exist, additional Contacts are created and linked to the same Opportunity.

### Pre-Push Validation

Before pushing, automation should verify:

- Property Status = Active (not DNC, Pipeline, or Removed)
- Skip Trace Date is not blank (owner data exists)
- At least one owner has at least one phone number or email
- Property is not already in the destination account (check `Pushed to New Leads` checkbox)

### Post-Push Updates

After successful push to an account:

- Set Status = Pipeline
- Check `Pushed to New Leads`
- Set Account Push Date

---

## 5. Tag Conventions

All tags follow `Category: Value` format (title case), matching New Leads.

### Campaign Tags

- `Campaign: [Campaign Name]` — one tag per campaign, stacks over time

---

## 6. Data Hygiene

- **Quarterly review:** Properties with Status = Active that have not been included in any
campaign for 6+ months should be flagged for re-skip-tracing or removal.
- **Sold property scrub:** Periodically cross-reference against public records or a sold
property list. Mark confirmed sales as Removed.
- **DNC audit:** DNC records should never appear in campaign filters. Run a monthly check
to verify no DNC-tagged properties leaked into active campaign lists.

