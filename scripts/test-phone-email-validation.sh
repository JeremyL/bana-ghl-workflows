#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# test-phone-email-validation.sh
# Fires the n8n intake webhook with various phone/email
# combinations and verifies normalization + lead creation
# in the GHL Contact record.
#
# Usage:
#   bash scripts/test-phone-email-validation.sh
#   bash scripts/test-phone-email-validation.sh --dry-run
# ─────────────────────────────────────────────────────────────
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# ── Load .env ───────────────────────────────────────────────
ENV_FILE="$PROJECT_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env not found at $ENV_FILE"; exit 1
fi

GHL_NEW_LEADS_TOKEN=$(grep '^GHL_NEW_LEADS_TOKEN=' "$ENV_FILE" | cut -d= -f2-)
NL_LOCATION_ID=$(grep '^NL_LOCATION_ID=' "$ENV_FILE" | cut -d= -f2-)
N8N_WEBHOOK_URL=$(grep '^N8N_WEBHOOK_URL=' "$ENV_FILE" | cut -d= -f2-)

if [[ -z "$N8N_WEBHOOK_URL" ]]; then
  echo "ERROR: N8N_WEBHOOK_URL not set in .env"
  exit 1
fi

# ── Check dependencies ──────────────────────────────────────
export PATH="$HOME/bin:$PATH"
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd is required but not found."; exit 1
  fi
done

# ── Config ──────────────────────────────────────────────────
BASE_URL="https://services.leadconnectorhq.com"
NL_HEADERS=(-H "Authorization: Bearer $GHL_NEW_LEADS_TOKEN" -H "Version: 2021-07-28" -H "Accept: application/json")
WAIT_SECONDS=30

# ── Color helpers ───────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
tput_out() { echo -e "$@"; }

# ── Output setup ────────────────────────────────────────────
RESULTS_DIR="$SCRIPT_DIR/results"
mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
RESULT_FILE="$RESULTS_DIR/test-phone-email-validation-$TIMESTAMP.md"
RUN_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# ── API helpers ─────────────────────────────────────────────
nl_api_get() {
  curl -s -w "\n%{http_code}" "${NL_HEADERS[@]}" "$1" 2>&1
}

parse_response() {
  local response="$1" http_code body
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
  if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
    echo "$body"; return 0
  else
    echo "HTTP $http_code: $body" >&2; return 1
  fi
}

nl_delete_contact() {
  curl -s -w "\n%{http_code}" "${NL_HEADERS[@]}" -X DELETE \
    "$BASE_URL/contacts/$1" 2>&1
}

# ── Counters & report ───────────────────────────────────────
PASS=0; FAIL=0; SKIP=0
MD_ROWS=""

# ════════════════════════════════════════════════════════════
# run_test — single test case
#
# Args:
#   $1  label
#   $2  phone         ("(none)" to omit)
#   $3  email         ("(none)" to omit)
#   $4  first_name
#   $5  last_name
#   $6  expected_phone  ("(empty)" = should be blank)
#   $7  expected_email  ("(empty)" = should be blank, "(any)" = skip check)
#   $8  search_by       ("email", "phone", or "name")
# ════════════════════════════════════════════════════════════
run_test() {
  local label="$1" phone="$2" email="$3" first="$4" last="$5"
  local exp_phone="$6" exp_email="$7" search_by="$8"

  tput_out "${BOLD}── Test: $label ──${NC}"
  tput_out "  Phone:    ${phone}"
  tput_out "  Email:    ${email}"
  tput_out "  Expect:   phone=${exp_phone}  email=${exp_email}"

  # ── Build payload (omit fields set to "(none)") ───────────
  local jq_args=()
  local jq_obj='{source: "Website", first_name: $first, last_name: $last'
  jq_args+=(--arg first "$first" --arg last "$last")

  if [[ "$phone" != "(none)" ]]; then
    jq_obj+=', phone: $phone'
    jq_args+=(--arg phone "$phone")
  fi
  if [[ "$email" != "(none)" ]]; then
    jq_obj+=', email: $email'
    jq_args+=(--arg email "$email")
  fi
  jq_obj+='}'

  local PAYLOAD
  PAYLOAD=$(jq -n "${jq_args[@]}" "$jq_obj")

  if [[ "$DRY_RUN" == true ]]; then
    tput_out "  ${CYAN}Payload:${NC} $PAYLOAD"
    tput_out "  ${YELLOW}SKIPPED (dry run)${NC}"
    MD_ROWS+="| $label | \`$phone\` | \`$email\` | \`$exp_phone\` | \`$exp_email\` | Dry run |\n"
    ((SKIP++))
    tput_out ""
    return
  fi

  # ── Fire webhook ──────────────────────────────────────────
  local WEBHOOK_RESPONSE WH_CODE
  WEBHOOK_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$N8N_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>&1)
  WH_CODE=$(echo "$WEBHOOK_RESPONSE" | tail -1)
  tput_out "  Webhook: HTTP $WH_CODE"

  if [[ "$WH_CODE" -lt 200 || "$WH_CODE" -ge 300 ]]; then
    tput_out "  ${RED}x Webhook failed${NC}"
    MD_ROWS+="| $label | \`$phone\` | \`$email\` | \`$exp_phone\` | \`$exp_email\` | **HTTP $WH_CODE** |\n"
    ((FAIL++))
    tput_out ""
    return
  fi

  # ── Wait ──────────────────────────────────────────────────
  tput_out "  Waiting ${WAIT_SECONDS}s..."
  sleep "$WAIT_SECONDS"

  # ── Search for contact ────────────────────────────────────
  local SEARCH_TERM CONTACT_ID=""
  case "$search_by" in
    email)
      SEARCH_TERM=$(python -c "import urllib.parse; print(urllib.parse.quote('$email'))" 2>/dev/null || echo "$email")
      ;;
    phone)
      SEARCH_TERM=$(python -c "import urllib.parse; print(urllib.parse.quote('$exp_phone'))" 2>/dev/null || echo "$exp_phone")
      ;;
    name)
      SEARCH_TERM=$(python -c "import urllib.parse; print(urllib.parse.quote('$first $last'))" 2>/dev/null || echo "$first $last")
      ;;
  esac

  local SEARCH_RAW SEARCH_BODY
  SEARCH_RAW=$(nl_api_get "$BASE_URL/contacts/?locationId=$NL_LOCATION_ID&query=$SEARCH_TERM&limit=1")
  SEARCH_BODY=$(parse_response "$SEARCH_RAW" 2>/dev/null) || true
  CONTACT_ID=$(echo "$SEARCH_BODY" | jq -r '.contacts[0].id // empty' 2>/dev/null)

  if [[ -z "$CONTACT_ID" ]]; then
    tput_out "  ${RED}x Contact not found${NC}"
    MD_ROWS+="| $label | \`$phone\` | \`$email\` | \`$exp_phone\` | \`$exp_email\` | **Not found** |\n"
    ((FAIL++))
    tput_out ""
    return
  fi

  # ── Get contact details ───────────────────────────────────
  local DETAIL_RAW DETAIL
  DETAIL_RAW=$(nl_api_get "$BASE_URL/contacts/$CONTACT_ID")
  DETAIL=$(parse_response "$DETAIL_RAW" 2>/dev/null) || true
  if echo "$DETAIL" | jq -e '.contact' &>/dev/null 2>&1; then
    DETAIL=$(echo "$DETAIL" | jq '.contact')
  fi

  local ACTUAL_PHONE ACTUAL_EMAIL
  ACTUAL_PHONE=$(echo "$DETAIL" | jq -r '.phone // empty' 2>/dev/null)
  ACTUAL_EMAIL=$(echo "$DETAIL" | jq -r '.email // empty' 2>/dev/null)

  # ── Verify phone ──────────────────────────────────────────
  local phone_ok=false
  if [[ "$exp_phone" == "(empty)" ]]; then
    [[ -z "$ACTUAL_PHONE" ]] && phone_ok=true
  else
    [[ "$ACTUAL_PHONE" == "$exp_phone" ]] && phone_ok=true
  fi

  # ── Verify email ──────────────────────────────────────────
  local email_ok=false
  if [[ "$exp_email" == "(any)" ]]; then
    email_ok=true
  elif [[ "$exp_email" == "(empty)" ]]; then
    [[ -z "$ACTUAL_EMAIL" ]] && email_ok=true
  else
    [[ "$ACTUAL_EMAIL" == "$exp_email" ]] && email_ok=true
  fi

  # ── Result ────────────────────────────────────────────────
  local actual_phone_display="${ACTUAL_PHONE:-(empty)}"
  local actual_email_display="${ACTUAL_EMAIL:-(empty)}"
  tput_out "  Phone:  ${actual_phone_display}  $(if $phone_ok; then echo "${GREEN}ok${NC}"; else echo "${RED}FAIL${NC}"; fi)"
  tput_out "  Email:  ${actual_email_display}  $(if $email_ok; then echo "${GREEN}ok${NC}"; else echo "${RED}FAIL${NC}"; fi)"

  if $phone_ok && $email_ok; then
    tput_out "  ${GREEN}+ PASS${NC}"
    MD_ROWS+="| $label | \`$phone\` | \`$email\` | \`$actual_phone_display\` | \`$actual_email_display\` | Pass |\n"
    ((PASS++))
  else
    local details=""
    if ! $phone_ok; then details+="phone: expected ${exp_phone}, got ${actual_phone_display}. "; fi
    if ! $email_ok; then details+="email: expected ${exp_email}, got ${actual_email_display}. "; fi
    tput_out "  ${RED}x FAIL — ${details}${NC}"
    MD_ROWS+="| $label | \`$phone\` | \`$email\` | \`$actual_phone_display\` | \`$actual_email_display\` | **FAIL** |\n"
    ((FAIL++))
  fi

  # ── Cleanup ───────────────────────────────────────────────
  tput_out "  Cleaning up $CONTACT_ID..."
  local DEL_RAW DEL_CODE
  DEL_RAW=$(nl_delete_contact "$CONTACT_ID")
  DEL_CODE=$(echo "$DEL_RAW" | tail -1)
  if [[ "$DEL_CODE" -ge 200 && "$DEL_CODE" -lt 300 ]]; then
    tput_out "  ${CYAN}Deleted${NC}"
  else
    tput_out "  ${YELLOW}Cleanup failed (HTTP $DEL_CODE)${NC}"
  fi

  tput_out ""
}

# ════════════════════════════════════════════════════════════
# HEADER
# ════════════════════════════════════════════════════════════
tput_out ""
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"
tput_out "${BOLD}  PHONE / EMAIL VALIDATION TEST${NC}"
tput_out "${BOLD}  $RUN_DATE${NC}"
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"
tput_out ""
tput_out "  Webhook: $N8N_WEBHOOK_URL"
tput_out "  Wait per test: ${WAIT_SECONDS}s"
if [[ "$DRY_RUN" == true ]]; then
  tput_out "  ${YELLOW}DRY RUN — payloads shown but not sent${NC}"
fi
tput_out ""

# ════════════════════════════════════════════════════════════
# GROUP 1: Phone Normalization
# ════════════════════════════════════════════════════════════
tput_out "${BOLD}━━━ Group 1: Phone Normalization ━━━${NC}"
tput_out ""

#            label                    phone                email                           first        last                 exp_phone        exp_email                        search_by
run_test    "10-digit bare"          "2025550101"         "test-01@test.banaland.com"      "Test"       "Phone-01"           "+12025550101"   "test-01@test.banaland.com"      "email"
run_test    "11-digit with 1"        "12025550102"        "test-02@test.banaland.com"      "Test"       "Phone-02"           "+12025550102"   "test-02@test.banaland.com"      "email"
run_test    "E.164 with +1"          "+12025550103"       "test-03@test.banaland.com"      "Test"       "Phone-03"           "+12025550103"   "test-03@test.banaland.com"      "email"
run_test    "Dashes"                 "202-555-0104"       "test-04@test.banaland.com"      "Test"       "Phone-04"           "+12025550104"   "test-04@test.banaland.com"      "email"
run_test    "Parens + dash"          "(202) 555-0105"     "test-05@test.banaland.com"      "Test"       "Phone-05"           "+12025550105"   "test-05@test.banaland.com"      "email"
run_test    "Spaces"                 "202 555 0106"       "test-06@test.banaland.com"      "Test"       "Phone-06"           "+12025550106"   "test-06@test.banaland.com"      "email"
run_test    "Dots"                   "202.555.0107"       "test-07@test.banaland.com"      "Test"       "Phone-07"           "+12025550107"   "test-07@test.banaland.com"      "email"
run_test    "Mixed format"           "+1 (202) 555-0108"  "test-08@test.banaland.com"      "Test"       "Phone-08"           "+12025550108"   "test-08@test.banaland.com"      "email"
run_test    "9-digit (invalid)"      "202555019"          "test-09@test.banaland.com"      "Test"       "Phone-09"           "(empty)"        "test-09@test.banaland.com"      "email"

# ════════════════════════════════════════════════════════════
# GROUP 2: Missing Identifier Edge Cases
# ════════════════════════════════════════════════════════════
tput_out "${BOLD}━━━ Group 2: Missing Identifier Edge Cases ━━━${NC}"
tput_out ""

#            label                    phone                email                           first        last                 exp_phone        exp_email                        search_by
run_test    "Email only"             "(none)"             "test-10@test.banaland.com"      "Test"       "Email-Only"         "(empty)"        "test-10@test.banaland.com"      "email"
run_test    "Phone only"             "+12025550111"       "(none)"                         "Test"       "Phone-Only"         "+12025550111"   "(empty)"                        "phone"
run_test    "No identifiers"         "(none)"             "(none)"                         "Test"       "NoID"               "(empty)"        "(empty)"                        "name"
run_test    "Junk phone + email"     "abc123"             "test-13@test.banaland.com"      "Test"       "Junk-Phone"         "(empty)"        "test-13@test.banaland.com"      "email"

# ════════════════════════════════════════════════════════════
# SUMMARY
# ════════════════════════════════════════════════════════════
TOTAL=$((PASS + FAIL + SKIP))

tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"
tput_out "  ${GREEN}Pass: $PASS${NC}  ${RED}Fail: $FAIL${NC}  ${YELLOW}Skip: $SKIP${NC}  Total: $TOTAL"
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"

if [[ $FAIL -eq 0 && $SKIP -eq 0 ]]; then
  tput_out "  ${GREEN}${BOLD}All tests passed!${NC}"
elif [[ $FAIL -eq 0 ]]; then
  tput_out "  ${YELLOW}${BOLD}No failures (dry run — re-run without --dry-run to test live)${NC}"
else
  tput_out "  ${RED}${BOLD}$FAIL test(s) failed${NC}"
fi

# ════════════════════════════════════════════════════════════
# WRITE MARKDOWN REPORT
# ════════════════════════════════════════════════════════════
cat > "$RESULT_FILE" <<MDEOF
# Phone / Email Validation Test
*Run: $RUN_DATE*

## Config
- **Webhook:** \`$N8N_WEBHOOK_URL\`
- **Wait per test:** ${WAIT_SECONDS}s

## Summary
- **Pass:** $PASS
- **Fail:** $FAIL
- **Skip:** $SKIP

## Results

| Test | Phone Input | Email Input | Phone Result | Email Result | Status |
| --- | --- | --- | --- | --- | --- |
$(echo -e "$MD_ROWS")
MDEOF

tput_out ""
tput_out "  Report saved to: $RESULT_FILE"
tput_out ""
