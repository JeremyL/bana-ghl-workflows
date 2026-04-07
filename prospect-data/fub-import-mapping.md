# FUB → GHL Import Mapping
*Last edited: 2026-04-08 · Last reviewed: —*

Column mapping for the Follow Up Boss (FUB) export CSV (`all-people-2026-03-21 --- IMPORT TEST.csv`) to the GHL Prospect Data Properties custom object.

**Source:** 134 columns, 43,553 rows
**Target:** Properties custom object in Prospect Data GHL sub-account

---

## Mapped Columns

FUB CSV columns that import into GHL Properties fields.

| FUB Column | GHL Field | GHL Type | % Filled | Notes |
|---|---|---|---|---|
| Reference | Reference ID | Text | 100% | Master unique ID / dedup key |
| APN | APN | Text | 100% | Assessor's Parcel Number |
| Prop County | Property County | Text | 100% | |
| Prop State | Property State | Text | 100% | |
| Acres | Acres | Number | 100% | |
| Tier 1 Market Price | Tier 1 Market Price | Currency | 100% | |
| Tier 2 Market Price | Tier 2 Market Price | Currency | 0% | No data in current export |
| Blind Offer | Blind Offer | Currency | 21.8% | |
| Offer price % | Offer Price % | Text | 17.9% | |
| Legal Description | Legal Description | Large Text | 89.8% | |
| ID | FUB ID | Text | 100% | FUB record ID for cross-reference |
| First Name | Owner 1 First Name | Text | 100% | |
| Last Name | Owner 1 Last Name | Text | 98.4% | |
| Mailing Address | Owner 1 Mailing Address | Text | 99.9% | |
| Mailing City | Owner 1 Mailing City | Text | 100% | |
| Mailing State | Owner 1 Mailing State | Text | 100% | |
| Address 1 - Zip | Owner 1 Mailing Zip | Text | 96.6% | FUB stores ZIP in Address 1, not Mailing fields |
| Phone 1 | Owner 1 Phone 1 | Phone | 95.8% | |
| Phone 1 - Type | Owner 1 Phone 1 Type | Text | 95.8% | |
| Phone 2 | Owner 1 Phone 2 | Phone | 88.0% | |
| Phone 2 - Type | Owner 1 Phone 2 Type | Text | 88.0% | |
| Phone 3 | Owner 1 Phone 3 | Phone | 71.3% | |
| Phone 3 - Type | Owner 1 Phone 3 Type | Text | 71.3% | |
| Phone 4 | Owner 1 Phone 4 | Phone | 7.6% | |
| Phone 4 - Type | Owner 1 Phone 4 Type | Text | 7.6% | |
| Phone 5 | Owner 1 Phone 5 | Phone | 3.3% | |
| Phone 5 - Type | Owner 1 Phone 5 Type | Text | 3.3% | |
| Phone 6 | Owner 1 Phone 6 | Phone | 1.3% | |
| Phone 6 - Type | Owner 1 Phone 6 Type | Text | 1.3% | |
| Email 1 | Owner 1 Email 1 | Text | 80.1% | |
| Email 1 - Type | *(skip)* | — | 80.1% | GHL has no email type field |
| Email 2 | Owner 1 Email 2 | Text | 4.7% | |
| Email 2 - Type | *(skip)* | — | 4.7% | |
| Email 3 | Owner 1 Email 3 | Text | 0.4% | |
| Email 3 - Type | *(skip)* | — | 0.4% | |
| Email 4 | Owner 1 Email 4 | Text | 0.0% | |
| Email 4 - Type | *(skip)* | — | 0.0% | |
| Owner Age | Owner 1 Age | Number | 96.9% | |
| Deceased | Owner 1 Deceased | Text | 97.5% | |
| Notes | Notes | Large Text | 1.2% | |
| Bana Ref # | *(no field)* | — | 0.9% | Internal reference. Low fill rate. Create field if needed. |

## Do Not Import

FUB columns with data that should NOT be imported into GHL.

| FUB Column | % Filled | Reason |
|---|---|---|
| Listing Price | 11.1% | Accidental data in FUB native MLS field. Not real listing prices. |
| Date Added | 100% | FUB metadata — not relevant to property record |
| Name | 100% | Concatenation of First + Last — redundant |
| Stage | 100% | FUB pipeline stage — does not map to GHL stages |
| Lead Source | 100% | FUB source — GHL uses its own source tracking |
| Assigned To | 100% | FUB assignment — GHL uses its own assignment |
| Last Assigned | 100% | FUB metadata |
| Is Contacted | 100% | FUB metadata |
| Tags | 100% | FUB tags — GHL uses its own tag system |
| Owner Address | 11.2% | Duplicate of Mailing Address (different data source) |
| Owner City | 11.3% | Duplicate of Mailing City |
| Owner State | 11.3% | Duplicate of Mailing State |
| Owner Zip | 11.2% | Duplicate of Address 1 - Zip |
| Address 1 - Street | 2.6% | FUB native address — overlaps with Mailing Address |
| Address 1 - City | 2.6% | FUB native address — overlaps with Mailing City |
| Address 1 - State | 6.7% | FUB native address — overlaps with Mailing State |
| Address 1 - Type | 100% | FUB address type label |
| Calls | 0.0% | FUB activity count |
| Texts | 0.1% | FUB activity count |

## Empty Columns (skip)

FUB columns that are 100% empty in this export. Not mapped.

**FUB native fields (empty):** Timeframe, Address 1 - Country, Address 2 through 4 (Street/City/Country), Property Address, Property City, Property State, Property Postal Code, Property MLS Number, Property Price, Property Beds, Property Baths, Property Area, Property Lot, Message, Description, Background, Campaign Source/Medium/Term/Content/Name, Deal Stage, Deal Close Date, Deal Price

**Custom fields (empty):** Access?, Assessed Value, Bana Ref Folder, Cash Sell Price, City sewer?, Company Name, DNC, Estimated Tillable Acreage, Financed Sell Price, Gas Notes, Gas?, In Floodzone?, Last Sale Date, Last Sale Price, Latitude, Longitude, Map link, NCCPI Score, OnX (5 rows), Owner Asking Price, Power notes, Power?, Property Type, Range Offer High, Range Offer Low, Sewer notes, Slope percentage, Soil Map Link, SubDivision, Water Hookup, Water Notes, Water?, Zoning

**Partially filled Address 2-4 fields (very low fill, FUB native):** Address 2 - Street (0.0%), Address 2 - State (3.5%), Address 2 - Zip (6.2%), Address 2 - Type (6.2%), Address 3 - State (0.7%), Address 3 - Zip (1.0%), Address 3 - Type (1.0%), Address 4 - State (0.0%), Address 4 - Zip (0.0%), Address 4 - Type (0.0%)

## GHL-Only Fields (no CSV source)

Properties fields that exist in GHL but are not populated from the FUB CSV. These are set by automation or manual entry.

| GHL Field | Purpose |
|---|---|
| All Phones | Concatenated search field — populated on import/automation |
| All Emails | Concatenated search field — populated on import/automation |
| Property Address | Not in FUB export — add from data source if available |
| Property City | Not in FUB export — add from data source if available |
| Property Zip | Not in FUB export — add from data source if available |
| Offer Price | Manual entry or calculated |
| Lat/Long | From data source if available |
| Map Link | Manual entry |
| Skip Trace Date | Set on skip trace refresh |
| Status | Custom object status — set by automation |
| Push to CRM | Transient trigger checkbox |
| CRM Push Date | Set by automation after push |
| DNC | Set by automation (WF-DNC-Handler sync) |
| DNC Date | Set by automation |
| Owner 2 / Owner 3 fields | Multi-owner properties — populated from future data sources |
