#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# compare-test-lead.sh
# Pulls the test lead from both GHL sub-accounts via API and
# compares Prospect Data → New Leads field-by-field.
# Output: terminal + markdown file in scripts/results/
# ─────────────────────────────────────────────────────────────
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# ── Load .env ───────────────────────────────────────────────
ENV_FILE="$PROJECT_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env not found at $ENV_FILE"; exit 1
fi

GHL_PROSPECT_DATA_TOKEN=$(grep '^GHL_PROSPECT_DATA_TOKEN=' "$ENV_FILE" | cut -d= -f2-)
GHL_NEW_LEADS_TOKEN=$(grep '^GHL_NEW_LEADS_TOKEN=' "$ENV_FILE" | cut -d= -f2-)
PD_LOCATION_ID=$(grep '^PD_LOCATION_ID=' "$ENV_FILE" | cut -d= -f2-)
NL_LOCATION_ID=$(grep '^NL_LOCATION_ID=' "$ENV_FILE" | cut -d= -f2-)
PD_PROPERTIES_OBJECT_ID=$(grep '^PD_PROPERTIES_OBJECT_ID=' "$ENV_FILE" | cut -d= -f2-)
TEST_REFERENCE_ID=$(grep '^TEST_REFERENCE_ID=' "$ENV_FILE" | cut -d= -f2-)
TEST_PHONE=$(grep '^TEST_PHONE=' "$ENV_FILE" | cut -d= -f2-)

# ── Check dependencies ──────────────────────────────────────
export PATH="$HOME/bin:$PATH"
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd is required but not found."; exit 1
  fi
done

# ── Config ──────────────────────────────────────────────────
BASE_URL="https://services.leadconnectorhq.com"
PD_HEADERS=(-H "Authorization: Bearer $GHL_PROSPECT_DATA_TOKEN" -H "Version: 2021-07-28" -H "Accept: application/json" -H "Content-Type: application/json")
NL_HEADERS=(-H "Authorization: Bearer $GHL_NEW_LEADS_TOKEN" -H "Version: 2021-07-28" -H "Accept: application/json")

# ── Output setup ────────────────────────────────────────────
RESULTS_DIR="$SCRIPT_DIR/results"
mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
RESULT_FILE="$RESULTS_DIR/compare-test-lead-$TIMESTAMP.md"
RUN_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# ── Color helpers ───────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

tput_out() { echo -e "$@"; }
section_t(){ tput_out ""; tput_out "${BOLD}── $1 ──${NC}"; }

# ── API helpers ─────────────────────────────────────────────
pd_api_post() {
  local url="$1" data="$2"
  curl -s -w "\n%{http_code}" "${PD_HEADERS[@]}" -X POST -d "$data" "$url" 2>&1
}

nl_api_get() {
  local url="$1"
  curl -s -w "\n%{http_code}" "${NL_HEADERS[@]}" "$url" 2>&1
}

parse_response() {
  local response="$1"
  local http_code body
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
  if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
    echo "$body"; return 0
  else
    echo "HTTP $http_code: $body" >&2; return 1
  fi
}

# ════════════════════════════════════════════════════════════
tput_out ""
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"
tput_out "${BOLD}  TEST LEAD COMPARISON: $TEST_REFERENCE_ID${NC}"
tput_out "${BOLD}  $RUN_DATE${NC}"
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"

# ════════════════════════════════════════════════════════════
# 1. SEARCH PROSPECT DATA FOR PROPERTY
# ════════════════════════════════════════════════════════════
section_t "PROSPECT DATA — Property Search"

PD_RAW=$(pd_api_post "$BASE_URL/objects/$PD_PROPERTIES_OBJECT_ID/records/search" \
  "{\"locationId\":\"$PD_LOCATION_ID\",\"query\":\"$TEST_REFERENCE_ID\",\"page\":1,\"pageLimit\":10}")
PD_BODY=$(parse_response "$PD_RAW") || { tput_out "${RED}Failed to search Prospect Data${NC}"; exit 1; }

PD_RECORD=$(echo "$PD_BODY" | jq -r '.records[0] // empty')
if [[ -z "$PD_RECORD" ]]; then
  tput_out "${RED}No property found for reference $TEST_REFERENCE_ID${NC}"; exit 1
fi

PD_PROPS=$(echo "$PD_RECORD" | jq '.properties // .')
PD_RECORD_ID=$(echo "$PD_RECORD" | jq -r '.id // "unknown"')
tput_out "  ${GREEN}Found property${NC} — Record ID: $PD_RECORD_ID"

# Extract PD fields
pd_get() { echo "$PD_PROPS" | jq -r ".$1 // empty" 2>/dev/null; }
pd_get_money() {
  local raw=$(echo "$PD_PROPS" | jq ".$1" 2>/dev/null)
  if echo "$raw" | jq -e '.value' &>/dev/null 2>&1; then
    echo "$raw" | jq -r '.value // empty'
  else
    echo "$raw" | jq -r '. // empty' 2>/dev/null
  fi
}

# ════════════════════════════════════════════════════════════
# 2. SEARCH NEW LEADS FOR CONTACT
# ════════════════════════════════════════════════════════════
section_t "NEW LEADS — Contact Search"

# URL-encode the phone
ENCODED_PHONE=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TEST_PHONE'))" 2>/dev/null || echo "$TEST_PHONE")

NL_CONTACT_RAW=$(nl_api_get "$BASE_URL/contacts/?locationId=$NL_LOCATION_ID&query=$ENCODED_PHONE&limit=1")
NL_CONTACT_BODY=$(parse_response "$NL_CONTACT_RAW") || { tput_out "${RED}Failed to search New Leads contacts${NC}"; exit 1; }

CONTACT_ID=$(echo "$NL_CONTACT_BODY" | jq -r '.contacts[0].id // empty')
if [[ -z "$CONTACT_ID" ]]; then
  tput_out "${RED}No contact found for phone $TEST_PHONE${NC}"; exit 1
fi
tput_out "  ${GREEN}Found contact${NC} — ID: $CONTACT_ID"

# Get full contact details
NL_CONTACT_DETAIL_RAW=$(nl_api_get "$BASE_URL/contacts/$CONTACT_ID")
CONTACT=$(parse_response "$NL_CONTACT_DETAIL_RAW") || { tput_out "${RED}Failed to get contact details${NC}"; exit 1; }
# Unwrap if nested under .contact
if echo "$CONTACT" | jq -e '.contact' &>/dev/null 2>&1; then
  CONTACT=$(echo "$CONTACT" | jq '.contact')
fi

nl_contact() { echo "$CONTACT" | jq -r ".$1 // empty" 2>/dev/null; }
nl_contact_cf() {
  local field_id="$1"
  echo "$CONTACT" | jq -r ".customFields[] | select(.id == \"$field_id\") | (.fieldValue // .value // .field_value) // empty" 2>/dev/null
}

# ════════════════════════════════════════════════════════════
# 3. SEARCH NEW LEADS FOR OPPORTUNITY
# ════════════════════════════════════════════════════════════
section_t "NEW LEADS — Opportunity Search"

NL_OPP_RAW=$(nl_api_get "$BASE_URL/opportunities/search?location_id=$NL_LOCATION_ID&contact_id=$CONTACT_ID")
NL_OPP_BODY=$(parse_response "$NL_OPP_RAW") || { tput_out "${RED}Failed to search opportunities${NC}"; exit 1; }

OPP_ID=$(echo "$NL_OPP_BODY" | jq -r '.opportunities[0].id // empty')
if [[ -z "$OPP_ID" ]]; then
  OPP='{}'
  tput_out "${YELLOW}No opportunity found for contact $CONTACT_ID${NC}"
else
  tput_out "  ${GREEN}Found opportunity${NC} — ID: $OPP_ID"
  # Fetch full opportunity record (search endpoint doesn't include customFields)
  NL_OPP_FULL_RAW=$(nl_api_get "$BASE_URL/opportunities/$OPP_ID")
  NL_OPP_FULL=$(parse_response "$NL_OPP_FULL_RAW") || true
  OPP=$(echo "$NL_OPP_FULL" | jq '.opportunity // . // {}')
fi

nl_opp() { echo "$OPP" | jq -r ".$1 // empty" 2>/dev/null; }
nl_opp_cf() {
  local field_id="$1"
  echo "$OPP" | jq -r ".customFields[] | select(.id == \"$field_id\") | (.fieldValue // .value // .field_value) // empty" 2>/dev/null
}

# ════════════════════════════════════════════════════════════
# 4. GET CONTACT NOTES
# ════════════════════════════════════════════════════════════
section_t "NEW LEADS — Contact Notes"

NL_NOTES_RAW=$(nl_api_get "$BASE_URL/contacts/$CONTACT_ID/notes")
NL_NOTES_BODY=$(parse_response "$NL_NOTES_RAW") || true
NOTES_COUNT=$(echo "$NL_NOTES_BODY" | jq '.notes | length // 0' 2>/dev/null || echo "0")
tput_out "  Notes found: $NOTES_COUNT"

FIRST_NOTE=""
if [[ "$NOTES_COUNT" -gt 0 ]]; then
  FIRST_NOTE=$(echo "$NL_NOTES_BODY" | jq -r '.notes[0].body // empty' 2>/dev/null)
  tput_out "  ${GREEN}Latest note preview:${NC} $(echo "$FIRST_NOTE" | head -3)..."
fi

# ════════════════════════════════════════════════════════════
# 5. BUILD COMPARISON
# ════════════════════════════════════════════════════════════
section_t "FIELD COMPARISON"

# Custom field IDs (from Build Payloads node)
CF_AGE="RlOkZEIvtvPCWwW2RMeQ"
CF_DECEASED="23ZikPrAwk0ofq1ry8dp"
CF_UNCONF_PHONES="9PKcT1OoD4DsXQtFQDbt"
CF_UNCONF_EMAILS="OALkm7NtEs07ekhbM7NM"
CF_REFERENCE_ID="4hQRrLmeYjCGwZrQ3H4A"
CF_PROPERTY_COUNTY="SXflz4EWkLmqX7vcGOqj"
CF_PROPERTY_STATE="TNMOvo362nMjuzrJypwX"
CF_ACRES="03OYKG8PqIofM8pc2ov4"
CF_APN="7pPZgfNVh6BCmCBiyAR4"
CF_T1_MARKET="TKJcASAUjBNb7pi8dSZw"
CF_T2_MARKET="D6xAIrlI7Rn9JAsLVQJK"
CF_BLIND_OFFER="NK98NtSL6NrsVEZVni3I"
CF_OFFER_PRICE="poMnC6bF9Lm0xFbseujv"
CF_OFFER_PCT="h1kDi6OkLYh7kwfrtSWU"
CF_LEGAL_DESC="6tIXVdo7xZB8Qs5Xh6Tp"
CF_LATLONG="8CP09XvE7YupgOjdyofd"
CF_MAP_LINK="dTj4K3p3FDofsIW4rC7d"
CF_LATEST_SOURCE="NmjAspnKmNdn258U0FUN"
CF_LATEST_SOURCE_DATE="0AmEgilRa5zAqVSjVKSu"

# Determine which owner matched (default owner 1)
MATCH_OWNER=1

PASS=0; FAIL=0; EMPTY=0

compare() {
  local label="$1" pd_val="$2" nl_val="$3"
  local status icon
  # Normalize for comparison (trim whitespace, lowercase)
  local pd_norm=$(echo "$pd_val" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')
  local nl_norm=$(echo "$nl_val" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')

  if [[ -z "$pd_val" && -z "$nl_val" ]]; then
    status="both empty"; icon="${CYAN}-${NC}"; ((EMPTY++))
  elif [[ -z "$pd_val" ]]; then
    status="no PD source"; icon="${CYAN}-${NC}"; ((EMPTY++))
  elif [[ -z "$nl_val" ]]; then
    status="MISSING in NL"; icon="${RED}x${NC}"; ((FAIL++))
  elif [[ "$pd_norm" == "$nl_norm" ]]; then
    status="match"; icon="${GREEN}+${NC}"; ((PASS++))
  else
    status="MISMATCH"; icon="${RED}x${NC}"; ((FAIL++))
  fi

  tput_out "  $icon $label"
  if [[ "$status" == "MISMATCH" ]]; then
    tput_out "      PD: $pd_val"
    tput_out "      NL: $nl_val"
  fi

  # Build markdown row
  local pd_display="${pd_val:-(empty)}"
  local nl_display="${nl_val:-(empty)}"
  MD_ROWS+="| $label | $pd_display | $nl_display | $status |\n"
}

MD_ROWS=""

# --- Contact fields ---
tput_out ""
tput_out "  ${BOLD}Contact Fields:${NC}"
MD_ROWS+="| **Field** | **Prospect Data** | **New Leads** | **Status** |\n"
MD_ROWS+="| --- | --- | --- | --- |\n"
MD_ROWS+="| **CONTACT** | | | |\n"

compare "First Name"       "$(pd_get owner_${MATCH_OWNER}_first_name)"    "$(nl_contact firstName)"
compare "Last Name"        "$(pd_get owner_${MATCH_OWNER}_last_name)"     "$(nl_contact lastName)"
compare "Phone (confirmed)" "$TEST_PHONE"                                 "$(nl_contact phone)"

TEST_EMAIL_VAL=$(grep '^TEST_EMAIL=' "$ENV_FILE" | cut -d= -f2-)
EMAIL_PD=$(echo "$TEST_EMAIL_VAL" | tr '[:upper:]' '[:lower:]')
EMAIL_NL=$(nl_contact email)
compare "Email (confirmed)" "$EMAIL_PD"                                    "$EMAIL_NL"

compare "Mailing Address"  "$(pd_get owner_${MATCH_OWNER}_mailing_address)" "$(nl_contact address1)"
compare "Mailing City"     "$(pd_get owner_${MATCH_OWNER}_mailing_city)"    "$(nl_contact city)"
compare "Mailing State"    "$(pd_get owner_${MATCH_OWNER}_mailing_state)"   "$(nl_contact state)"
compare "Mailing Zip"      "$(pd_get owner_${MATCH_OWNER}_mailing_zip)"     "$(nl_contact postalCode)"
compare "Age"              "$(pd_get owner_${MATCH_OWNER}_age)"             "$(nl_contact_cf $CF_AGE)"
compare "Deceased"         "$(pd_get owner_${MATCH_OWNER}_deceased)"        "$(nl_contact_cf $CF_DECEASED)"

# Unconfirmed phones — just check if populated
UNCONF_PHONES_NL=$(nl_contact_cf $CF_UNCONF_PHONES)
if [[ -n "$UNCONF_PHONES_NL" ]]; then
  tput_out "  ${GREEN}+${NC} Unconfirmed Phones — populated"; ((PASS++))
  MD_ROWS+="| Unconfirmed Phones | (see PD phones) | $(echo "$UNCONF_PHONES_NL" | tr '\n' ', ') | populated |\n"
else
  tput_out "  ${RED}x${NC} Unconfirmed Phones — EMPTY"; ((FAIL++))
  MD_ROWS+="| Unconfirmed Phones | (see PD phones) | (empty) | MISSING |\n"
fi

UNCONF_EMAILS_NL=$(nl_contact_cf $CF_UNCONF_EMAILS)
if [[ -n "$UNCONF_EMAILS_NL" ]]; then
  tput_out "  ${GREEN}+${NC} Unconfirmed Emails — populated"; ((PASS++))
  MD_ROWS+="| Unconfirmed Emails | (see PD emails) | $(echo "$UNCONF_EMAILS_NL" | tr '\n' ', ') | populated |\n"
else
  tput_out "  ${RED}x${NC} Unconfirmed Emails — EMPTY"; ((FAIL++))
  MD_ROWS+="| Unconfirmed Emails | (see PD emails) | (empty) | MISSING |\n"
fi

# Tags
CONTACT_TAGS=$(echo "$CONTACT" | jq -r '.tags // [] | join(", ")' 2>/dev/null)
tput_out "  ${CYAN}-${NC} Tags: $CONTACT_TAGS"
MD_ROWS+="| Tags | — | $CONTACT_TAGS | info |\n"

# --- Opportunity fields ---
tput_out ""
tput_out "  ${BOLD}Opportunity Fields:${NC}"
MD_ROWS+="| **OPPORTUNITY** | | | |\n"

compare "Reference ID"      "$(pd_get reference_id)"        "$(nl_opp_cf $CF_REFERENCE_ID)"
compare "APN"                "$(pd_get apn)"                 "$(nl_opp_cf $CF_APN)"
compare "Property County"    "$(pd_get property_county)"     "$(nl_opp_cf $CF_PROPERTY_COUNTY)"
compare "Property State"     "$(pd_get property_state)"      "$(nl_opp_cf $CF_PROPERTY_STATE)"
compare "Acres"              "$(pd_get acres)"               "$(nl_opp_cf $CF_ACRES)"
compare "Legal Description"  "$(pd_get legal_description)"   "$(nl_opp_cf $CF_LEGAL_DESC)"
compare "Tier 1 Market Price" "$(pd_get_money tier_1_market_price)" "$(nl_opp_cf $CF_T1_MARKET)"
compare "Tier 2 Market Price" "$(pd_get_money tier_2_market_price)" "$(nl_opp_cf $CF_T2_MARKET)"
compare "Blind Offer"        "$(pd_get_money blind_offer)"   "$(nl_opp_cf $CF_BLIND_OFFER)"
compare "Offer Price"        "$(pd_get offer_price)"         "$(nl_opp_cf $CF_OFFER_PRICE)"
compare "Offer Price %"      "$(pd_get offer_price_pct)"     "$(nl_opp_cf $CF_OFFER_PCT)"
compare "Lat/Long"           "$(pd_get gps)"                 "$(nl_opp_cf $CF_LATLONG)"
compare "Map Link"           "$(pd_get map_link)"            "$(nl_opp_cf $CF_MAP_LINK)"

# Source fields (not from PD — from webhook/sheet)
OPP_SOURCE=$(nl_opp source)
OPP_LATEST_SOURCE=$(nl_opp_cf $CF_LATEST_SOURCE)
OPP_LATEST_DATE=$(nl_opp_cf $CF_LATEST_SOURCE_DATE)
OPP_NAME=$(nl_opp name)
OPP_STATUS=$(nl_opp status)
OPP_PIPELINE=$(nl_opp pipelineId)
OPP_STAGE=$(nl_opp pipelineStageId)

tput_out ""
tput_out "  ${BOLD}Opportunity Metadata:${NC}"
tput_out "  ${CYAN}-${NC} Name: $OPP_NAME"
tput_out "  ${CYAN}-${NC} Status: $OPP_STATUS"
tput_out "  ${CYAN}-${NC} Pipeline ID: $OPP_PIPELINE"
tput_out "  ${CYAN}-${NC} Stage ID: $OPP_STAGE"
tput_out "  ${CYAN}-${NC} Source (native): $OPP_SOURCE"
tput_out "  ${CYAN}-${NC} Latest Source (CF): $OPP_LATEST_SOURCE"
tput_out "  ${CYAN}-${NC} Latest Source Date (CF): $OPP_LATEST_DATE"

MD_ROWS+="| **OPP METADATA** | | | |\n"
MD_ROWS+="| Opp Name | — | $OPP_NAME | info |\n"
MD_ROWS+="| Opp Status | — | $OPP_STATUS | info |\n"
MD_ROWS+="| Pipeline ID | — | $OPP_PIPELINE | info |\n"
MD_ROWS+="| Stage ID | — | $OPP_STAGE | info |\n"
MD_ROWS+="| Source (native) | — | $OPP_SOURCE | info |\n"
MD_ROWS+="| Latest Source (CF) | — | $OPP_LATEST_SOURCE | info |\n"
MD_ROWS+="| Latest Source Date | — | $OPP_LATEST_DATE | info |\n"

# ════════════════════════════════════════════════════════════
# 5B. PROSPECT DATA POST-PUSH VERIFICATION
# ════════════════════════════════════════════════════════════
section_t "PROSPECT DATA — Post-Push Fields"

MD_ROWS+="| **PD POST-PUSH** | | | |\n"

PD_STATUS=$(pd_get status)
PD_CRM_PUSH_DATE=$(pd_get crm_push_date)

compare "PD Status"         "pipeline"   "$PD_STATUS"
TODAY=$(date +%Y-%m-%d)
compare "PD CRM Push Date"  "$TODAY"     "$PD_CRM_PUSH_DATE"

# ════════════════════════════════════════════════════════════
# 6. SUMMARY
# ════════════════════════════════════════════════════════════
tput_out ""
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"
tput_out "  ${GREEN}Match: $PASS${NC}  ${RED}Missing/Mismatch: $FAIL${NC}  ${CYAN}Empty/Info: $EMPTY${NC}"
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"

# ════════════════════════════════════════════════════════════
# 7. WRITE MARKDOWN REPORT
# ════════════════════════════════════════════════════════════

# Escape note for markdown
NOTE_MD=""
if [[ -n "$FIRST_NOTE" ]]; then
  NOTE_MD=$(echo "$FIRST_NOTE" | sed 's/|/\\|/g')
fi

cat > "$RESULT_FILE" <<MDEOF
# Test Lead Comparison: $TEST_REFERENCE_ID
*Run: $RUN_DATE*

## IDs
| Record | ID |
| --- | --- |
| Prospect Data Property | \`$PD_RECORD_ID\` |
| New Leads Contact | \`$CONTACT_ID\` |
| New Leads Opportunity | \`${OPP_ID:-(not found)}\` |

## Summary
- **Match:** $PASS
- **Missing/Mismatch:** $FAIL
- **Empty/Info:** $EMPTY

## Field Comparison

$(echo -e "$MD_ROWS")

## Contact Note
**Notes found:** $NOTES_COUNT

\`\`\`
${FIRST_NOTE:-(no note found)}
\`\`\`

## Raw Prospect Data (Owner $MATCH_OWNER)
\`\`\`json
$(echo "$PD_PROPS" | jq '.' 2>/dev/null || echo "$PD_PROPS")
\`\`\`

## Raw Contact
\`\`\`json
$(echo "$CONTACT" | jq '.' 2>/dev/null || echo "$CONTACT")
\`\`\`

## Raw Opportunity
\`\`\`json
$(echo "$OPP" | jq '.' 2>/dev/null || echo "$OPP")
\`\`\`
MDEOF

tput_out ""
tput_out "  Report saved to: $RESULT_FILE"
