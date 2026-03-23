"""
FUB → GHL CSV Cleanup Script
=============================
Cleans a Follow Up Boss (FUB) CSV export so it's ready to import into the
GHL Prospect Data account (Properties custom object).

WHY NOT EXCEL?
    Excel silently mangles APN values — strips leading zeros, converts long
    alphanumeric strings to scientific notation, etc. This script reads
    everything as plain text so APNs (and all other fields) stay intact.

WHAT IT DOES:
    1. Adds a GPS column — combines separate Latitude and Longitude columns
       into one "lat, long" value (GHL stores this as a single text field).
       Original Latitude/Longitude columns are kept as-is.

    2. Cleans phone numbers (Phone 1 through Phone 6):
       - Value of '0' means no data → becomes blank.
       - Strips all non-digit characters (parentheses, dashes, spaces).
       - Removes leading country code '1' from 11-digit numbers.
       - Result should be a raw 10-digit US number.
       - If it's NOT 10 digits after cleaning, the value is kept but a
         WARNING is printed to the console (row number, column, value)
         so you can review bad data.

    3. Cleans Owner Age:
       - '0' means unknown → becomes blank.

    4. Cleans Offer price %:
       - '#N/A' means no offer was calculated → becomes blank.

    5. Normalizes Deceased:
       - Standardizes to Y / N / blank (strips whitespace, handles
         YES/NO variants).

    6. Preserves all data as text — no type conversion, no column renaming,
       no columns dropped. The only addition is the GPS column at the end.

HOW TO RUN:
    python clean-fub-export.py "path/to/fub-export.csv"

    Example:
    python prospect-data/clean-fub-export.py "prospect-data/all-people-2026-03-21 --- IMPORT TEST.csv"

OUTPUT:
    Creates a new file with '-cleaned' appended to the name in the same folder.
    Example: "all-people-2026-03-21 --- IMPORT TEST-cleaned.csv"

    The original file is never modified.

AFTER RUNNING:
    - Review any WARNING lines in the console output — these are phone
      numbers that aren't 10 digits (bad skip trace data, missing digits, etc.).
    - Spot-check a few APN values in the cleaned file to confirm formatting.
    - The cleaned CSV is ready to map and import into GHL.
"""

import csv
import sys
import os
import re

# --------------------------------------------------------------------------
# Column names must match the FUB export headers exactly.
# If FUB changes their export format, update these.
# --------------------------------------------------------------------------
PHONE_COLUMNS = [
    "Phone 1", "Phone 2", "Phone 3", "Phone 4", "Phone 5", "Phone 6",
]


def clean_phone(value, row_num, col_name):
    """Clean a single phone value. Returns cleaned string."""
    stripped = value.strip()

    # '0' or blank = no data
    if not stripped or stripped == "0":
        return ""

    # Strip everything except digits
    digits = re.sub(r"\D", "", stripped)

    # US numbers sometimes have a leading '1' country code — remove it
    if len(digits) == 11 and digits.startswith("1"):
        digits = digits[1:]

    # Warn on anything that isn't a clean 10-digit US number
    if len(digits) != 10:
        print(f"  WARNING row {row_num}: {col_name} = '{value}' ({len(digits)} digits)")
        return digits  # keep the value so it can be reviewed, don't discard

    return digits


def clean_row(row, row_num):
    """Apply all cleaning rules to one row. Modifies and returns the row dict."""

    # --- Phone cleanup ---
    for col in PHONE_COLUMNS:
        if col in row:
            row[col] = clean_phone(row[col], row_num, col)

    # --- Age: '0' = unknown → blank ---
    if "Owner Age" in row:
        if row["Owner Age"].strip() == "0":
            row["Owner Age"] = ""

    # --- Offer price %: '#N/A' = no offer → blank ---
    if "Offer price %" in row:
        if row["Offer price %"].strip().upper() == "#N/A":
            row["Offer price %"] = ""

    # --- Deceased: normalize to Y / N / blank ---
    if "Deceased" in row:
        val = row["Deceased"].strip().upper()
        if val in ("Y", "YES"):
            row["Deceased"] = "Y"
        elif val in ("N", "NO"):
            row["Deceased"] = "N"
        else:
            row["Deceased"] = ""

    # --- GPS: concatenate Latitude + Longitude into one field ---
    lat = row.get("Latitude", "").strip()
    lon = row.get("Longitude", "").strip()
    row["GPS"] = f"{lat}, {lon}" if lat and lon else ""

    return row


def main():
    if len(sys.argv) < 2:
        print("Usage: python clean-fub-export.py <csv-file>")
        sys.exit(1)

    input_path = sys.argv[1]
    if not os.path.isfile(input_path):
        print(f"File not found: {input_path}")
        sys.exit(1)

    # Output file = same name with '-cleaned' before the extension
    base, ext = os.path.splitext(input_path)
    output_path = f"{base}-cleaned{ext}"

    print(f"Reading:  {input_path}")
    print(f"Writing:  {output_path}")
    print()

    # Read with utf-8-sig to handle the BOM that Excel/FUB sometimes adds.
    # All values are read as strings — no type inference.
    with open(input_path, "r", newline="", encoding="utf-8-sig") as infile:
        reader = csv.DictReader(infile)
        fieldnames = list(reader.fieldnames) + ["GPS"]  # append GPS at the end

        # Write with QUOTE_ALL to protect any values that contain commas
        with open(output_path, "w", newline="", encoding="utf-8") as outfile:
            writer = csv.DictWriter(
                outfile, fieldnames=fieldnames, quoting=csv.QUOTE_ALL
            )
            writer.writeheader()

            for i, row in enumerate(reader, start=2):  # row 2 = first data row
                row = clean_row(row, i)
                writer.writerow(row)

    print()
    print("Done.")


if __name__ == "__main__":
    main()
