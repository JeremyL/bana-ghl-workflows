# Prospect Data — Data Model

Prospect Data in the Bana Land GHL system. Stores all raw property and skip trace data in a single flat Custom Object. No contacts, no opportunities, no pipeline.

Automations push data from here into New Leads for campaigns and lead follow-up.

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
| Offer Price %     | Number     | `offer_price_pct`    | Offer as a percentage of market value (e.g., 35 for 35%). Manually entered or calculated from Offer Price / Market Price. |
| Legal Description | Large Text | `legal_description`  | Full legal description                           |
| FUB ID            | Text       | `fub_id`             | Follow Up Boss ID — links back to the FUB record for cross-reference |
| Lat/Long          | Text       | `gps`                | Latitude and longitude as a single comma-separated value (e.g., `35.1234, -97.5678`). |
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
| Owner 1 Email 1         | Email  | `email1`          | Primary email                      |
| Owner 1 Email 2         | Email  | `email2`          | Second email                       |
| Owner 1 Email 3         | Email  | `email3`          | Third email                        |
| Owner 1 Email 4         | Email  | `email4`          | Fourth email                       |
| Owner 1 Age             | Number | `Age`             | Age from skip trace (0 = unknown)  |
| Owner 1 Deceased        | Text   | `Deceased`        | Raw value from skip trace provider |


### Owner 2 Fields

Same 20 fields as Owner 1, prefixed with `Owner 2`. CSV columns for future uploads will follow the pattern: `owner2_first_name`, `owner2_phone1`, etc.

### Owner 3 Fields

Same 20 fields as Owner 1, prefixed with `Owner 3`.

### Status & Tracking Fields


| Field           | Type       | Purpose                                       |
| --------------- | ---------- | --------------------------------------------- |
| Status            | Dropdown     | Active / DNC / Pipeline / Removed                |
| Skip Trace Date   | Date         | Date skip trace was completed                    |
| DNC               | Checkbox     | Any owner on this property requested DNC         |
| DNC Date          | Date         | Date DNC was flagged                             |
| Pushed to New Leads | Checkbox   | Whether this property has been pushed to the New Leads account |
| Account Push Date | Date         | Date property was last pushed to another account |
| Date Added        | Date         | Date this property record was created            |
| Notes             | Large Text   | Free-form notes                                  |


### Status Dropdown Values


| Value       | Meaning                                                           |
| ----------- | ----------------------------------------------------------------- |
| Active      | Available for campaigns. Default status on upload.                          |
| Pipeline    | Currently active in New Leads. Do not re-send.                              |
| DNC         | At least one owner requested Do Not Contact. No further outreach.           |
| Removed     | Off the table — bad data, duplicate, sold, purchased, or disqualified.      |


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
| Campaign Tag  | Text       | Exact tag applied to Properties (e.g. `Campaign: CE-TX-Travis-2026-03`) |
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
   Format: `Campaign: [Campaign Name]`

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


| Properties Field (Prospect Data) | Contact Field (New Leads) |
| ---------------------------- | ------------------------------ |
| Owner N First Name           | First Name                     |
| Owner N Last Name            | Last Name                      |
| Owner N Phone 1              | Phone                          |
| Owner N Phone 2              | Phone 2                        |
| Owner N Phone 3              | Phone 3                        |
| Owner N Phone 4              | Phone 4                        |
| Owner N Email 1              | Email                          |
| Owner N Mailing Address      | Address                        |
| Owner N Mailing City         | City                           |
| Owner N Mailing State        | State                          |
| Owner N Mailing Zip          | Postal Code                    |
| Owner N Age                  | Age                            |
| Owner N Deceased             | Deceased                       |


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
| Campaign Type                | Original Source                    |
| Campaign Type                | Latest Source                      |
| (today's date)               | Latest Source Date                 |


**Note:** GHL Contacts natively support only 1 email field. Only Email 1 maps to the
Contact; Emails 2–4 remain in Prospect Data for reference. All 4 phones map over.