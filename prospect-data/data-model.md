# Prospect Data — Data Model
*Last edited: 2026-04-01 · Last reviewed: —*

Prospect Data in the Bana Land GHL system. Stores all raw property and skip trace data in a single flat Custom Object. No contacts, no opportunities, no pipeline.

Automations push data from here into New Leads for lead follow-up.

---

## Custom Object 1: Properties

One row = one property. All owner/skip trace data lives as columns on the same row.  
`Reference ID` **is the Master Unique ID** (not APN). APN is a data point but not the primary key.

### Property Fields


| Field             | Type       | CSV Column (example) | Purpose                                          |
| ----------------- | ---------- | -------------------- | ------------------------------------------------ |
| Reference ID      | Text       | `reference`          | **Master Unique ID.** Dedup key for all uploads. |
| APN               | Text       | `apn`                | Assessor's Parcel Number                         |
| Property County   | Text       | `county`             | County where the property is located             |
| Property State    | Text       | `state`              | State (all US states)                            |
| Acres             | Number     | `property_acreage`   | Property acreage                                 |
| Offer Price       | Text       | `offer price`        | Offer amount or percentage for this property — Text type to support dollar amounts, percentages, or both (e.g., "$45,000" or "35%" or "$45k / 32%") |
| Offer Price %     | Text       | `offer_price_pct`    | Offer as a percentage of market value (e.g., "35%"). Text type to match GHL field. Manually entered or calculated from Offer Price / Market Price. |
| Legal Description | Large Text | `legal_description`  | Full legal description                           |
| FUB ID            | Text       | `fub_id`             | Follow Up Boss ID — links back to the FUB record for cross-reference |
| Lat/Long          | Text       | `gps`                | Latitude and longitude as a single comma-separated value (e.g., `35.1234, -97.5678`). Label: "Lat/Long", key: `gps`. |
| Map Link          | Text       | `map_link`           | URL to property map (Google Maps, onX, ParcelFact, etc.)             |


**Fields available if data source provides them (not in current CSV):**


| Field               | Type     | Purpose                           |
| ------------------- | -------- | --------------------------------- |
| Property Address    | Text     | Property situs address            |
| Property City       | Text     | Property city                     |
| Property Zip        | Text     | Property ZIP code                 |
| Tier 1 Market Price | Currency | Market price estimate — Tier 1    |
| Tier 2 Market Price | Currency | Market price estimate — Tier 2    |
| Blind Offer         | Currency | An offer amount used in marketing |


### Owner 1 Fields


| Field                   | Type   | CSV Column        | Purpose                            |
| ----------------------- | ------ | ----------------- | ---------------------------------- |
| Owner 1 First Name      | Text   | `first_name`      | First name                         |
| Owner 1 Last Name       | Text   | `last_name`       | Last name                          |
| Owner 1 Mailing Address | Text   | `Mailing address` | Mailing street address             |
| Owner 1 Mailing City    | Text   | `mailing_city`    | Mailing city                       |
| Owner 1 Mailing State   | Text   | `mailing_state`   | Mailing state                      |
| Owner 1 Mailing Zip     | Text   | `zipcode`         | Mailing ZIP                        |
| Owner 1 Phone 1         | Phone  | `phone1`          | Primary phone                      |
| Owner 1 Phone 1 Type    | Text   | `phone1 type`     | Raw value from skip trace provider |
| Owner 1 Phone 2         | Phone  | `phone2`          | Second phone                       |
| Owner 1 Phone 2 Type    | Text   | `phone2 type`     | Raw value from skip trace provider |
| Owner 1 Phone 3         | Phone  | `phone3`          | Third phone                        |
| Owner 1 Phone 3 Type    | Text   | `phone3 type`     | Raw value from skip trace provider |
| Owner 1 Phone 4         | Phone  | `phone4`          | Fourth phone                       |
| Owner 1 Phone 4 Type    | Text   | `phone4 type`     | Raw value from skip trace provider |
| Owner 1 Phone 5         | Phone  | `phone5`          | Fifth phone                        |
| Owner 1 Phone 5 Type    | Text   | `phone5 type`     | Raw value from skip trace provider |
| Owner 1 Phone 6         | Phone  | `phone6`          | Sixth phone                        |
| Owner 1 Phone 6 Type    | Text   | `phone6 type`     | Raw value from skip trace provider |
| Owner 1 Email 1         | Text   | `email1`          | Primary email                      |
| Owner 1 Email 2         | Text   | `email2`          | Second email                       |
| Owner 1 Email 3         | Text   | `email3`          | Third email                        |
| Owner 1 Email 4         | Text   | `email4`          | Fourth email                       |
| Owner 1 Age             | Number | `Age`             | Age from skip trace (0 = unknown)  |
| Owner 1 Deceased        | Text   | `Deceased`        | Raw value from skip trace provider |


### Owner 2 Fields

Same 24 fields as Owner 1, prefixed with `Owner 2`. Created via API 2026-04-01. CSV columns for future uploads will follow the pattern: `owner2_first_name`, `owner2_phone1`, etc.

### Owner 3 Fields

Same 24 fields as Owner 1, prefixed with `Owner 3`. Created via API 2026-04-01.

### Status & Tracking Fields


| Field           | Type       | Purpose                                       |
| --------------- | ---------- | --------------------------------------------- |
| Status            | Dropdown     | Active / DNC / Pipeline / Removed                |
| Skip Trace Date   | Date         | Date skip trace was completed                    |
| DNC               | Checkbox     | Any owner on this property requested DNC         |
| DNC Date          | Date         | Date DNC was flagged                             |
| Push to CRM         | Checkbox     | Trigger to push this property to New Leads. Checked to request push; unchecked by automation after completion. |
| CRM Pushed          | Checkbox     | Whether this property has been pushed to New Leads. Permanent — never unchecked. |
| CRM Push Date       | Date         | Date property was last pushed to New Leads       |
| Date Added        | Date         | Date this property record was created (GHL default field) |
| Notes             | Large Text   | Free-form notes                                  |


### Status Dropdown Values


| Value       | Meaning                                                           |
| ----------- | ----------------------------------------------------------------- |
| Active      | Available for campaigns. Default status on upload.                          |
| Pipeline    | Currently active in New Leads. Do not re-send.                              |
| DNC         | At least one owner requested Do Not Contact. No further outreach.           |
| Removed     | Off the table — bad data, duplicate, sold, purchased, or disqualified.      |


### Search Fields

GHL Custom Objects only support `query` search on fields listed in `searchableProperties` (max 3). Phone and Email fields use PHONE/TEXT types that aren't matched by generic query search. These two concatenated TEXT fields solve that — they combine all owner phone/email data into single searchable strings.

| Field      | Type | Searchable | Purpose                                                        |
| ---------- | ---- | ---------- | -------------------------------------------------------------- |
| All Phones | Text | Yes        | All phones across all owners, space-separated. Populated on import and by automation. Enables phone cascade search from n8n intake workflow. |
| All Emails | Text | Yes        | All emails across all owners, space-separated. Populated on import and by automation. Enables email cascade search from n8n intake workflow. |

**Searchable Properties (3 of 3 slots used):** Reference ID, All Phones, All Emails

**Format:** Space-separated values (e.g., `+16104767077 +16104896566 +16105172894`). Must be populated whenever phone/email data is added or updated — on CSV import and on any automation that writes phone/email fields.

### Data Cleaning Rules (on upload)

- `0` in phone fields = no data → store as blank
- `0` in Age field = unknown → store as blank or 0
- `#N/A` in offer price = no offer calculated → store as blank
- `Deceased` values: `Y` / `N` / blank

---

## Custom Object 2: Campaigns

One row = one marketing campaign. Linked to Properties via campaign tags.

### Campaign Fields


| Field         | Type       | Purpose                                         |
| ------------- | ---------- | ----------------------------------------------- |
| Campaign Name | Text       | Unique name for the campaign                                    |
| Campaign Tag  | Text       | Exact tag applied to Properties (e.g. `campaign: ce-tx-travis-2026-03`) |
| Campaign Type | Dropdown   | Cold Email / Cold SMS / Cold Call / Direct Mail                 |
| Status        | Dropdown   | Planning / Active / Completed / Paused                          |
| Start Date    | Date       | Campaign launch date                                            |
| End Date      | Date       | Campaign end date (if applicable)                               |
| Total Records | Number     | Count of properties/owners included                             |
| Notes         | Large Text | Campaign notes, results, observations                           |


---

## Linking Properties to Campaigns

Properties are linked to Campaigns using tags:

1. **Campaign tags** on the Property record — one tag per campaign the property has been
  included in. Tags stack over time to preserve full campaign history.
   Format: `campaign: [campaign name]`

Native GHL associations between Properties and Campaigns can be created via automation if needed for reporting, but the tag approach is the primary link because it works with bulk CSV uploads.

---

## Data Flow to Other Accounts

```
Prospect Data
  │
  └──► New Leads
         All campaign types (Cold Email, Cold SMS, Cold Call, Direct Mail)
         Automation creates Contact + Opportunity from Property fields
```

### Field Mapping: Properties → Contact + Opportunity

When a property is pushed to New Leads, automation splits the flat row into the Contact/Opportunity model:

**Property → Contact (one per owner with valid contact info):**


| Properties Field (Prospect Data) | Contact Field (New Leads)         | Notes                        |
| -------------------------------- | --------------------------------- | ---------------------------- |
| Owner N First Name               | First Name                        |                              |
| Owner N Last Name                | Last Name                         |                              |
| (confirmed phone from campaign)  | Phone                             | Native — confirmed only      |
| Owner N Phone 1–6                | Unconfirmed Phones (Large Text)   | All skip trace phones, one per line |
| (confirmed email from campaign)  | Email                             | Native — confirmed only      |
| Owner N Email 1–4                | Unconfirmed Emails (Large Text)   | All skip trace emails, one per line |
| Owner N Mailing Address          | Address                           |                              |
| Owner N Mailing City             | City                              |                              |
| Owner N Mailing State            | State                             |                              |
| Owner N Mailing Zip              | Postal Code                       |                              |
| Owner N Age                      | Age                               |                              |
| Owner N Deceased                 | Deceased                          |                              |


**Property → Opportunity:**


| Properties Field (Prospect Data) | Opportunity Field (New Leads) |
| ---------------------------- | ---------------------------------- |
| Reference ID                 | Reference ID                       |
| APN                          | APN                                |
| Property County              | Property County                    |
| Property State               | Property State                     |
| Acres                        | Acres                              |
| Legal Description            | Legal Description                  |
| Tier 1 Market Price          | Tier 1 Market Price                |
| Tier 2 Market Price          | Tier 2 Market Price                |
| Blind Offer                  | Blind Offer                        |
| Offer Price                  | Offer Price                        |
| Offer Price %                | Offer Price %                      |
| Lat/Long                     | Lat/Long                           |
| Map Link                     | Map Link                           |
| Campaign Type                | Source (native Opportunity field)   |
| Campaign Type                | Latest Source                      |
| (today's date)               | Latest Source Date                 |


**Note:** The confirmed phone/email (from the campaign interaction — the number they called from, the email they replied from) goes into the native Phone/Email fields. All skip trace phones and emails from Prospect Data go into two Large Text fields (Unconfirmed Phones, Unconfirmed Emails) as reference data. Native Phone 2–4 are reserved for additional numbers confirmed during follow-up conversations.