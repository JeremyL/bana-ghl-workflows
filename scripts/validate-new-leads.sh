#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# validate-new-leads.sh
# Pre-launch validation for the New Leads GHL sub-account.
# Sources .env for tokens/IDs, hits GHL API, prints pass/fail.
# Output: terminal (colored) + markdown file in scripts/results/
# ─────────────────────────────────────────────────────────────
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# ── Load .env ───────────────────────────────────────────────
ENV_FILE="$PROJECT_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env not found at $ENV_FILE"
  exit 1
fi
GHL_NEW_LEADS_TOKEN=$(grep '^GHL_NEW_LEADS_TOKEN=' "$ENV_FILE" | cut -d= -f2-)
NL_LOCATION_ID=$(grep '^NL_LOCATION_ID=' "$ENV_FILE" | cut -d= -f2-)
NL_PIPELINE_ID=$(grep '^NL_PIPELINE_ID=' "$ENV_FILE" | cut -d= -f2-)
NL_NEW_LEADS_STAGE_ID=$(grep '^NL_NEW_LEADS_STAGE_ID=' "$ENV_FILE" | cut -d= -f2-)

# ── Check dependencies ──────────────────────────────────────
export PATH="$HOME/bin:$PATH"
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd is required but not found."
    exit 1
  fi
done

# ── Config ──────────────────────────────────────────────────
BASE_URL="https://services.leadconnectorhq.com"
TOKEN="$GHL_NEW_LEADS_TOKEN"
LOC_ID="$NL_LOCATION_ID"
API_HEADERS=(-H "Authorization: Bearer $TOKEN" -H "Version: 2021-07-28" -H "Accept: application/json")

# ── Output setup ────────────────────────────────────────────
RESULTS_DIR="$SCRIPT_DIR/results"
mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
RESULT_FILE="$RESULTS_DIR/validate-new-leads-$TIMESTAMP.md"
RUN_DATE=$(date '+%Y-%m-%d %H:%M:%S')

PASS=0; FAIL=0; WARN=0

# ── Collectors for markdown tables ──────────────────────────
MD_CONTACT_ROWS=""
MD_OPP_ROWS=""
MD_STAGE_ROWS=""
MD_WF_ROWS=""
MD_WF_OTHER_ROWS=""
MD_USER_ROWS=""
MD_CAL_ROWS=""
MD_AUTH_LINE=""
MD_PIPE_INFO=""

# ── Color helpers (terminal only) ───────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

tput_out() { echo -e "$@"; }
pass_t()   { tput_out "  ${GREEN}+${NC} $1"; ((PASS++)); }
fail_t()   { tput_out "  ${RED}x${NC} $1"; ((FAIL++)); }
warn_t()   { tput_out "  ${YELLOW}!${NC} $1"; ((WARN++)); }
info_t()   { tput_out "  ${CYAN}-${NC} $1"; }
section_t(){ tput_out ""; tput_out "${BOLD}── $1 ──${NC}"; }

# ── API helper ──────────────────────────────────────────────
api_get() {
  local url="$1"
  local response http_code body
  response=$(curl -s -w "\n%{http_code}" "${API_HEADERS[@]}" "$url" 2>&1)
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
  if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
    echo "$body"; return 0
  else
    echo "HTTP $http_code: $body" >&2; return 1
  fi
}

# ── Start ───────────────────────────────────────────────────
tput_out ""
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"
tput_out "${BOLD}  NEW LEADS — PRE-LAUNCH VALIDATION${NC}"
tput_out "${BOLD}  $RUN_DATE${NC}"
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"

# ════════════════════════════════════════════════════════════
# 1. AUTH TEST
# ════════════════════════════════════════════════════════════
section_t "AUTH TEST"

AUTH_RESPONSE=$(api_get "$BASE_URL/locations/$LOC_ID" 2>&1) || true
LOC_NAME=""

if echo "$AUTH_RESPONSE" | jq -e '.location.name' &>/dev/null 2>&1; then
  LOC_NAME=$(echo "$AUTH_RESPONSE" | jq -r '.location.name // "Unknown"')
elif echo "$AUTH_RESPONSE" | jq -e '.name' &>/dev/null 2>&1; then
  LOC_NAME=$(echo "$AUTH_RESPONSE" | jq -r '.name // "Unknown"')
fi

if [[ -n "$LOC_NAME" ]]; then
  pass_t "Token valid — Location: $LOC_NAME"
  MD_AUTH_LINE="**Result:** Pass — Location: \`$LOC_NAME\`"
else
  fail_t "Auth failed or unexpected response"
  MD_AUTH_LINE="**Result:** FAIL — could not authenticate"
  tput_out "${RED}Cannot continue without valid auth. Fix token and re-run.${NC}"
  # Write minimal MD and exit
  cat > "$RESULT_FILE" <<MDEOF
# New Leads — Pre-Launch Validation
*Run: $RUN_DATE*

## Auth Test
$MD_AUTH_LINE

> Script stopped — auth must pass before other checks run.
MDEOF
  tput_out "  Result saved to: $RESULT_FILE"
  exit 1
fi

# ════════════════════════════════════════════════════════════
# 2. CONTACT CUSTOM FIELDS
# ════════════════════════════════════════════════════════════
section_t "CONTACT CUSTOM FIELDS"

CONTACT_FIELDS=(
  "Age|NUMERICAL"
  "Deceased|TEXT"
  "Pause WFs Until|DATE"
  "Unconfirmed Phones|LARGE_TEXT"
  "Unconfirmed Emails|LARGE_TEXT"
)

CF_RESPONSE=$(api_get "$BASE_URL/locations/$LOC_ID/customFields?model=contact" 2>&1) || true
CF_DATA=$(echo "$CF_RESPONSE" | jq -r '.customFields // . // []' 2>/dev/null)
CF_TOTAL=0

if [[ -n "$CF_DATA" ]] && echo "$CF_DATA" | jq -e 'type == "array"' &>/dev/null; then
  CF_TOTAL=$(echo "$CF_DATA" | jq 'length')
  info_t "Found $CF_TOTAL total contact custom fields in GHL"
  tput_out ""

  for expected in "${CONTACT_FIELDS[@]}"; do
    IFS='|' read -r exp_name exp_type <<< "$expected"
    match=$(echo "$CF_DATA" | jq -r --arg name "$exp_name" '.[] | select(.name | ascii_downcase == ($name | ascii_downcase))' 2>/dev/null)

    if [[ -n "$match" ]]; then
      actual_type=$(echo "$match" | jq -r '.dataType // .fieldType // .type // "unknown"')
      actual_name=$(echo "$match" | jq -r '.name')
      field_key=$(echo "$match" | jq -r '.fieldKey // .key // "n/a"')
      norm_expected=$(echo "$exp_type" | tr '[:lower:]' '[:upper:]')
      norm_actual=$(echo "$actual_type" | tr '[:lower:]' '[:upper:]')

      if [[ "$norm_actual" == *"$norm_expected"* ]] || [[ "$norm_expected" == *"$norm_actual"* ]]; then
        pass_t "$(printf '%-25s %-15s %s' "$actual_name" "$actual_type" "$field_key")"
        MD_CONTACT_ROWS+="| $actual_name | $actual_type | \`$field_key\` | Pass |"$'\n'
      else
        warn_t "$(printf '%-25s %-15s (expected %s)  %s' "$actual_name" "$actual_type" "$exp_type" "$field_key")"
        MD_CONTACT_ROWS+="| $actual_name | $actual_type | \`$field_key\` | Warn — expected $exp_type |"$'\n'
      fi
    else
      fail_t "$(printf '%-25s %s' "$exp_name" "MISSING")"
      MD_CONTACT_ROWS+="| $exp_name | $exp_type | — | **MISSING** |"$'\n'
    fi
  done
else
  fail_t "Could not retrieve contact custom fields"
  MD_CONTACT_ROWS+="| — | — | — | **API call failed** |"$'\n'
fi

# ════════════════════════════════════════════════════════════
# 3. OPPORTUNITY CUSTOM FIELDS
# ════════════════════════════════════════════════════════════
section_t "OPPORTUNITY CUSTOM FIELDS"

OPP_FIELDS=(
  "Reference ID|TEXT"
  "Property County|TEXT"
  "Property State|TEXT"
  "Acres|NUMERICAL"
  "APN|TEXT"
  "Tier 1 Market Price|MONETORY"
  "Tier 2 Market Price|MONETORY"
  "Blind Offer|MONETORY"
  "Offer Price %|TEXT"
  "Legal Description|LARGE_TEXT"
  "Map Link|TEXT"
  "Lat/Long|TEXT"
  "Offer Price|TEXT"
  "Contract Date|DATE"
  "Latest Source|TEXT"
  "Latest Source Date|DATE"
)


OF_RESPONSE=$(api_get "$BASE_URL/locations/$LOC_ID/customFields?model=opportunity" 2>&1) || true
OF_DATA=$(echo "$OF_RESPONSE" | jq -r '.customFields // . // []' 2>/dev/null)
OF_TOTAL=0

if [[ -n "$OF_DATA" ]] && echo "$OF_DATA" | jq -e 'type == "array"' &>/dev/null; then
  OF_TOTAL=$(echo "$OF_DATA" | jq 'length')
  info_t "Found $OF_TOTAL total opportunity custom fields in GHL"
  tput_out ""

  for expected in "${OPP_FIELDS[@]}"; do
    IFS='|' read -r exp_name exp_type <<< "$expected"
    match=$(echo "$OF_DATA" | jq -r --arg name "$exp_name" '.[] | select(.name | ascii_downcase == ($name | ascii_downcase))' 2>/dev/null)

    if [[ -n "$match" ]]; then
      actual_type=$(echo "$match" | jq -r '.dataType // .fieldType // .type // "unknown"')
      actual_name=$(echo "$match" | jq -r '.name')
      field_key=$(echo "$match" | jq -r '.fieldKey // .key // "n/a"')
      norm_expected=$(echo "$exp_type" | tr '[:lower:]' '[:upper:]')
      norm_actual=$(echo "$actual_type" | tr '[:lower:]' '[:upper:]')

      if [[ "$norm_actual" == *"$norm_expected"* ]] || [[ "$norm_expected" == *"$norm_actual"* ]]; then
        pass_t "$(printf '%-25s %-18s %s' "$actual_name" "$actual_type" "$field_key")"
        MD_OPP_ROWS+="| $actual_name | $actual_type | \`$field_key\` | Pass |"$'\n'
      else
        warn_t "$(printf '%-25s %-18s (expected %s)  %s' "$actual_name" "$actual_type" "$exp_type" "$field_key")"
        MD_OPP_ROWS+="| $actual_name | $actual_type | \`$field_key\` | Warn — expected $exp_type |"$'\n'
      fi

    else
      fail_t "$(printf '%-25s %s' "$exp_name" "MISSING")"
      MD_OPP_ROWS+="| $exp_name | $exp_type | — | **MISSING** |"$'\n'
    fi
  done
else
  fail_t "Could not retrieve opportunity custom fields"
  MD_OPP_ROWS+="| — | — | — | **API call failed** |"$'\n'
fi

# ════════════════════════════════════════════════════════════
# 4. PIPELINES & STAGES (Multi-Pipeline)
# ════════════════════════════════════════════════════════════
section_t "PIPELINES & STAGES"

# Expected pipelines and their stages (pipe-delimited: "search_term|stage1,stage2,...")
# Empty stages = TBD (just check pipeline exists)
EXPECTED_PIPELINES=(
  "leads|New Leads,Day 1-10,Day 11-30"
  "qualified|Comps/Pricing,Make Offer,Negotiations,Additional Info Needed,Contract Sent,Contract Signed,Nurture"
  "due diligence|"
  "value add|"
  "long term fu|Cold,Nurture,Lost"
)
EXPECTED_PIPE_NAMES=("01 : Leads" "02 : Qualified" "03 : Due Diligence" "04 : Value Add" "05 : Long Term FU")

PIPE_RESPONSE=$(api_get "$BASE_URL/opportunities/pipelines?locationId=$LOC_ID" 2>&1) || true
PIPE_DATA=$(echo "$PIPE_RESPONSE" | jq -r '.pipelines // . // []' 2>/dev/null)

if [[ -n "$PIPE_DATA" ]] && echo "$PIPE_DATA" | jq -e 'type == "array"' &>/dev/null; then
  PIPE_COUNT=$(echo "$PIPE_DATA" | jq 'length')
  info_t "Found $PIPE_COUNT pipeline(s) in account"
  MD_PIPE_INFO="**Pipelines found:** $PIPE_COUNT (5 expected)"

  for p_idx in "${!EXPECTED_PIPELINES[@]}"; do
    IFS='|' read -r search_term exp_stages_csv <<< "${EXPECTED_PIPELINES[$p_idx]}"
    pipe_label="${EXPECTED_PIPE_NAMES[$p_idx]}"

    tput_out ""
    info_t "--- $pipe_label ---"

    # Search by name (case-insensitive contains)
    found_pipe=$(echo "$PIPE_DATA" | jq -r --arg s "$search_term" '.[] | select(.name | ascii_downcase | contains($s))' 2>/dev/null | head -100)

    # Fallback: for Leads pipeline, also try .env ID
    if [[ -z "$found_pipe" && "$search_term" == "leads" && -n "$NL_PIPELINE_ID" ]]; then
      found_pipe=$(echo "$PIPE_DATA" | jq -r --arg id "$NL_PIPELINE_ID" '.[] | select(.id == $id)' 2>/dev/null)
    fi

    if [[ -z "$found_pipe" ]]; then
      fail_t "Pipeline NOT FOUND (searched for '$search_term')"
      MD_STAGE_ROWS+="| **$pipe_label** | — | — | **NOT FOUND** |"$'\n'
      continue
    fi

    p_name=$(echo "$found_pipe" | jq -r '.name')
    p_id=$(echo "$found_pipe" | jq -r '.id')
    pass_t "Pipeline: $p_name ($p_id)"
    MD_STAGE_ROWS+="| **$pipe_label** | \`$p_name\` | \`$p_id\` | Pass |"$'\n'

    # For Leads pipeline, check .env match
    if [[ "$search_term" == "leads" ]]; then
      if [[ "$p_id" == "$NL_PIPELINE_ID" ]]; then
        pass_t "  Leads pipeline ID matches .env (NL_PIPELINE_ID)"
      elif [[ -n "$NL_PIPELINE_ID" ]]; then
        fail_t "  Leads pipeline ID mismatch — API: $p_id vs .env: $NL_PIPELINE_ID"
      fi
    fi

    # Check stages (skip if TBD)
    if [[ -z "$exp_stages_csv" ]]; then
      info_t "  Stages TBD — skipping stage check"
      MD_STAGE_ROWS+="| | *(stages TBD)* | — | Skipped |"$'\n'
      continue
    fi

    IFS=',' read -ra exp_stages <<< "$exp_stages_csv"
    stages_json=$(echo "$found_pipe" | jq -r '.stages // []' 2>/dev/null)
    stage_count=$(echo "$stages_json" | jq 'length' 2>/dev/null)
    info_t "  Found $stage_count stages (${#exp_stages[@]} expected)"

    for s_idx in "${!exp_stages[@]}"; do
      exp_stage="${exp_stages[$s_idx]}"
      stage_match=$(echo "$stages_json" | jq -r --arg name "$exp_stage" '.[] | select(.name | ascii_downcase == ($name | ascii_downcase))' 2>/dev/null)

      if [[ -n "$stage_match" ]]; then
        s_id=$(echo "$stage_match" | jq -r '.id')
        pass_t "  $(printf '%d. %-25s %s' "$((s_idx+1))" "$exp_stage" "$s_id")"

        env_note=""
        if [[ "$exp_stage" == "New Leads" && "$search_term" == "leads" ]]; then
          if [[ "$s_id" == "$NL_NEW_LEADS_STAGE_ID" ]]; then
            pass_t "    New Leads stage ID matches .env"
            env_note=" (matches .env)"
          elif [[ -n "$NL_NEW_LEADS_STAGE_ID" ]]; then
            fail_t "    Stage ID mismatch — API: $s_id vs .env: $NL_NEW_LEADS_STAGE_ID"
            env_note=" (**MISMATCH** .env)"
          fi
        fi
        MD_STAGE_ROWS+="| | $((s_idx+1)). $exp_stage | \`$s_id\` | Pass${env_note} |"$'\n'
      else
        fail_t "  $(printf '%d. %-25s %s' "$((s_idx+1))" "$exp_stage" "MISSING")"
        MD_STAGE_ROWS+="| | $((s_idx+1)). $exp_stage | — | **MISSING** |"$'\n'
      fi
    done

    # Check for unexpected extra stages
    expected_json=$(printf '%s\n' "${exp_stages[@]}" | jq -R . | jq -s '[ .[] | ascii_downcase ]')
    extra=$(echo "$stages_json" | jq -r --argjson expected "$expected_json" \
      '[ .[] | select(.name | ascii_downcase | IN($expected[]) | not) ] | .[] | .name' 2>/dev/null)
    if [[ -n "$extra" ]]; then
      echo "$extra" | while read -r s; do
        warn_t "  Extra stage: $s"
        MD_STAGE_ROWS+="| | $s | — | Warn — unexpected |"$'\n'
      done
    fi
  done
else
  fail_t "Could not retrieve pipelines"
  MD_PIPE_INFO="**Pipelines:** API call failed"
fi

# ════════════════════════════════════════════════════════════
# 5. WORKFLOWS
# ════════════════════════════════════════════════════════════
section_t "WORKFLOWS"

EXPECTED_WFS=(
  "WF-New-Lead-Entry"
  "WF-Day-1-10"
  "WF-Day-11-30"
  "WF-Cold-Email-Subflow-P1"
  "WF-Cold-Email-Subflow-P2"
  "WF-Cold-Drip-Monthly"
  "WF-Nurture-Monthly"
  "WF-Long-Term-Quarterly"
  "WF-Dispo-Re-Engage"
  "WF-DNC-Handler"
  "WF-Response-Handler"
  "WF-Missed-Call-Textback"
)

WF_RESPONSE=$(api_get "$BASE_URL/workflows/?locationId=$LOC_ID" 2>&1) || true
WF_DATA=$(echo "$WF_RESPONSE" | jq -r '.workflows // . // []' 2>/dev/null)
WF_TOTAL=0

if [[ -n "$WF_DATA" ]] && echo "$WF_DATA" | jq -e 'type == "array"' &>/dev/null; then
  WF_TOTAL=$(echo "$WF_DATA" | jq 'length')
  info_t "Found $WF_TOTAL total workflow(s) in account"
  tput_out ""

  for exp_wf in "${EXPECTED_WFS[@]}"; do
    wf_match=$(echo "$WF_DATA" | jq -r --arg name "$exp_wf" '.[] | select(.name | ascii_downcase | contains($name | ascii_downcase))' 2>/dev/null | head -20)

    if [[ -n "$wf_match" ]]; then
      wf_name=$(echo "$wf_match" | jq -r '.name' | head -1)
      wf_status=$(echo "$wf_match" | jq -r '.status // "unknown"' | head -1)
      wf_id=$(echo "$wf_match" | jq -r '.id' | head -1)
      status_upper=$(echo "$wf_status" | tr '[:lower:]' '[:upper:]')

      if [[ "$status_upper" == "PUBLISHED" || "$status_upper" == "ACTIVE" ]]; then
        pass_t "$(printf '%-30s %-12s %s' "$exp_wf" "$wf_status" "$wf_id")"
        MD_WF_ROWS+="| $exp_wf | $wf_status | \`$wf_id\` | Pass |"$'\n'
      else
        warn_t "$(printf '%-30s %-12s %s' "$exp_wf" "$wf_status (not active)" "$wf_id")"
        MD_WF_ROWS+="| $exp_wf | $wf_status | \`$wf_id\` | Warn — not active |"$'\n'
      fi
    else
      fail_t "$(printf '%-30s %s' "$exp_wf" "NOT FOUND")"
      MD_WF_ROWS+="| $exp_wf | — | — | **NOT FOUND** |"$'\n'
    fi
  done

  # Other workflows
  tput_out ""
  info_t "Other workflows in account:"
  while IFS='|' read -r name status; do
    [[ -z "$name" ]] && continue
    matched=false
    for exp_wf in "${EXPECTED_WFS[@]}"; do
      if echo "$name" | grep -qi "$exp_wf"; then matched=true; break; fi
    done
    if [[ "$matched" == "false" ]]; then
      info_t "  $(printf '%-40s %s' "$name" "$status")"
      MD_WF_OTHER_ROWS+="| $name | $status |"$'\n'
    fi
  done < <(echo "$WF_DATA" | jq -r '.[] | "\(.name)|\(.status // "unknown")"' 2>/dev/null)
else
  fail_t "Could not retrieve workflows"
  MD_WF_ROWS+="| — | — | — | **API call failed** |"$'\n'
fi

# ════════════════════════════════════════════════════════════
# 6. USERS
# ════════════════════════════════════════════════════════════
section_t "USERS"

USER_RESPONSE=$(api_get "$BASE_URL/users/?locationId=$LOC_ID" 2>&1) || true
USER_DATA=$(echo "$USER_RESPONSE" | jq -r '.users // . // []' 2>/dev/null)

if [[ -n "$USER_DATA" ]] && echo "$USER_DATA" | jq -e 'type == "array"' &>/dev/null; then
  USER_COUNT=$(echo "$USER_DATA" | jq 'length')
  info_t "Found $USER_COUNT user(s)"
  while IFS='|' read -r name role email uid; do
    info_t "$(printf '%-25s %-15s %-30s %s' "$name" "$role" "$email" "$uid")"
    MD_USER_ROWS+="| $name | $role | $email | \`$uid\` |"$'\n'
  done < <(echo "$USER_DATA" | jq -r '.[] | "\(.name // ((.firstName // "") + " " + (.lastName // "")) | gsub("^ +| +$";""))|\(.role // .type // "unknown")|\(.email // "n/a")|\(.id // "n/a")"' 2>/dev/null)

  # Native Assigned User field requires at least 1 GHL user
  if [[ "$USER_COUNT" -gt 0 ]]; then
    pass_t "At least 1 user exists (required for native Assigned User field)"
  else
    fail_t "No users found — native Assigned User field requires at least 1 GHL user"
  fi
else
  warn_t "Could not retrieve users"
  MD_USER_ROWS+="| — | — | — | API call failed |"$'\n'
fi

# ════════════════════════════════════════════════════════════
# 7. CALENDARS
# ════════════════════════════════════════════════════════════
section_t "CALENDARS"

CAL_RESPONSE=$(api_get "$BASE_URL/calendars/?locationId=$LOC_ID" 2>&1) || true
CAL_DATA=$(echo "$CAL_RESPONSE" | jq -r '.calendars // . // []' 2>/dev/null)

EXPECTED_CAL="qualified first call"

if [[ -n "$CAL_DATA" ]] && echo "$CAL_DATA" | jq -e 'type == "array"' &>/dev/null; then
  CAL_COUNT=$(echo "$CAL_DATA" | jq 'length')
  info_t "Found $CAL_COUNT calendar(s)"

  # Check for required calendar
  cal_match=$(echo "$CAL_DATA" | jq -r --arg name "$EXPECTED_CAL" '.[] | select(.name | ascii_downcase | contains($name))' 2>/dev/null | head -20)
  if [[ -n "$cal_match" ]]; then
    cal_name=$(echo "$cal_match" | jq -r '.name' | head -1)
    cal_id=$(echo "$cal_match" | jq -r '.id' | head -1)
    pass_t "$(printf '%-35s %s' "$cal_name" "$cal_id")"
    MD_CAL_ROWS+="| $cal_name | \`$cal_id\` | Pass |"$'\n'
  else
    fail_t "Qualified First Call calendar NOT FOUND (needed for LM->AM round-robin handoff)"
    MD_CAL_ROWS+="| Qualified First Call | — | **NOT FOUND** |"$'\n'
  fi

  # List other calendars (informational)
  while IFS='|' read -r name cid; do
    [[ -z "$name" ]] && continue
    if ! echo "$name" | grep -qi "$EXPECTED_CAL"; then
      info_t "$(printf '%-35s %s' "$name" "$cid")"
      MD_CAL_ROWS+="| $name | \`$cid\` | — |"$'\n'
    fi
  done < <(echo "$CAL_DATA" | jq -r '.[] | "\(.name // "Unnamed")|\(.id // "n/a")"' 2>/dev/null)
else
  warn_t "Could not retrieve calendars"
  MD_CAL_ROWS+="| — | — | API call failed |"$'\n'
fi

# ════════════════════════════════════════════════════════════
# SUMMARY (terminal)
# ════════════════════════════════════════════════════════════
TOTAL=$((PASS + FAIL + WARN))

tput_out ""
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"
tput_out "${BOLD}  SUMMARY${NC}"
tput_out "${BOLD}═══════════════════════════════════════════════════════${NC}"
tput_out ""
tput_out "  ${GREEN}Passed:   $PASS${NC}"
[[ $FAIL -gt 0 ]] && tput_out "  ${RED}Failed:   $FAIL${NC}" || tput_out "  Failed:   0"
[[ $WARN -gt 0 ]] && tput_out "  ${YELLOW}Warnings: $WARN${NC}" || tput_out "  Warnings: 0"
tput_out "  Total:    $TOTAL checks"
tput_out ""
[[ $FAIL -eq 0 ]] && tput_out "  ${GREEN}${BOLD}All critical checks passed!${NC}" || tput_out "  ${RED}${BOLD}$FAIL item(s) need attention (see x above)${NC}"

# ════════════════════════════════════════════════════════════
# WRITE MARKDOWN FILE
# ════════════════════════════════════════════════════════════
cat > "$RESULT_FILE" <<MDEOF
# New Leads — Pre-Launch Validation

*Run: $RUN_DATE*

---

## Summary

| | Count |
|---|---|
| **Passed** | $PASS |
| **Failed** | $FAIL |
| **Warnings** | $WARN |
| **Total** | $TOTAL |

---

## Auth Test

$MD_AUTH_LINE

---

## Contact Custom Fields

*$CF_TOTAL total contact custom fields found in GHL. 5 expected.*

| Field | Type | Key | Status |
|---|---|---|---|
${MD_CONTACT_ROWS}
---

## Opportunity Custom Fields

*$OF_TOTAL total opportunity custom fields found in GHL. 16 expected.*

| Field | Type | Key | Status |
|---|---|---|---|
${MD_OPP_ROWS}
MDEOF


cat >> "$RESULT_FILE" <<MDEOF
---

## Pipelines & Stages

${MD_PIPE_INFO}

*5 pipelines expected: Leads (3), Qualified (7), Due Diligence (TBD), Value Add (TBD), Long Term FU (3).*

| Pipeline | Stage | ID | Status |
|---|---|---|---|
${MD_STAGE_ROWS}
---

## Workflows

*$WF_TOTAL total workflows in account. 12 expected.*

| Expected Workflow | Status | ID | Result |
|---|---|---|---|
${MD_WF_ROWS}
MDEOF

if [[ -n "$MD_WF_OTHER_ROWS" ]]; then
  cat >> "$RESULT_FILE" <<MDEOF

### Other Workflows in Account

| Name | Status |
|---|---|
${MD_WF_OTHER_ROWS}
MDEOF
fi

cat >> "$RESULT_FILE" <<MDEOF
---

## Users

| Name | Role | Email | ID |
|---|---|---|---|
${MD_USER_ROWS}
---

## Calendars

| Name | ID | Status |
|---|---|---|
${MD_CAL_ROWS}
MDEOF

tput_out ""
tput_out "  Result saved to: $RESULT_FILE"
tput_out ""
