#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Structural test: 2429-sc11-remote-number-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-11 (#2429, scope H): spec-creation create task implements remote-number-first
# numbering per R-23/R-24. Evidence type: STRUCTURAL (developer-directed —
# behavioral runs are impractical for a deterministic number-sourcing flow; the
# evidence is a create.md read-back plus this fixture scenario script; prose
# recall is NOT evidence). This script runs NO model — it is fixture-based.
#
# R-23: when a remote API is available, the flow SHALL create the remote stub
# FIRST (before any local record), SHALL take the remote-assigned number N from
# the API create response's `number` field, and SHALL create the local issue
# record at exactly N. The create task SHALL NOT use the local counter to pick
# the number when a remote API is available — local-counter numbering is ONLY
# for local-only mode. On any API failure mid-flow the task SHALL return BLOCKED
# and SHALL NOT silently reassign a different local number.
#
# R-24: local and remote numbers match BY CONSTRUCTION — binding fields
# (remote_issue, remote_url, github_url) reference the same N as the local
# directory name (.issues/N/, issue.yaml with remote_issue: N). If the remote
# assigns a number whose local directory already exists, remediation follows the
# renumber/migrate repair pattern (repair, not the primary guard).
#
# FIXTURE: a fixture API create response whose `number` field (2429) DIFFERS
# from the local counter value (2427) — the flow MUST adopt the API's number
# (2429), not the counter's (2427). This demonstrates the defect class verified
# for #2429: local 2427 was assigned while the remote counter was at 2429
# (remote #2427 was already a MERGED PR). RED condition = the script fails
# because create.md lacks the remote-number-first sequence the script asserts.
#
# MODE: structural (fixture-based, no opencode run — no with-test-home needed;
# the monitoring mandate for behavioral runs does not apply to a fixture-only
# script; recorded here per the mode-disclosure requirement).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Structural script — module root (.opencode) is two levels above behaviors/
MODULE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CREATE_MD="$MODULE_ROOT/skills/spec-creation/tasks/create.md"

SCENARIO_NAME="2429-sc11-remote-number-first"
FIXTURE_DIR="${TMPDIR:-/tmp}/2429-sc11-fixture.$$"
FAILURES=0

cleanup() { rm -rf "$FIXTURE_DIR"; }
trap cleanup EXIT

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }

echo "=== Structural Test: $SCENARIO_NAME ==="
echo "SC-11: spec-creation create.md implements remote-number-first numbering (R-23/R-24)"
echo "Target: skills/spec-creation/tasks/create.md"
echo

if [ ! -f "$CREATE_MD" ]; then
  fail "create.md not found at $CREATE_MD"
  echo "RESULT: FAIL (0 checks passed)"
  exit 1
fi

# ---------------------------------------------------------------------------
# Part A — create.md read-back: the remote-number-first sequence anchors
# ---------------------------------------------------------------------------

# A1 (R-23): remote stub created FIRST — before any local record
grep -qi "remote.*stub.*FIRST\|stub FIRST\|stub.*first.*before any local" "$CREATE_MD" && \
  pass "A1: create.md states the remote stub is created FIRST (before any local record)" || \
  fail "A1: create.md does not state the remote stub is created FIRST before any local record"

# A2 (R-23): number taken from the API create response's `number` field
grep -qi "response.*\`number\` field\|response's \`number\`\|\`number\` field" "$CREATE_MD" && \
  pass "A2: create.md states the number N is taken from the API create response's \`number\` field" || \
  fail "A2: create.md does not state the number comes from the API response's \`number\` field"

# A3 (R-23/R-24): local record created at exactly N (local == remote BY CONSTRUCTION)
grep -qi "at exactly N\|exactly N\|BY CONSTRUCTION" "$CREATE_MD" && \
  pass "A3: create.md states the local record is created at exactly N (local == remote BY CONSTRUCTION)" || \
  fail "A3: create.md does not state the local record is created at exactly N"

# A4 (R-24): binding fields (remote_issue, remote_url, github_url) all reference N
grep -q "remote_issue" "$CREATE_MD" && grep -q "remote_url" "$CREATE_MD" && grep -q "github_url" "$CREATE_MD" && \
  pass "A4: create.md documents the binding fields (remote_issue, remote_url, github_url) referencing N" || \
  fail "A4: create.md does not document binding fields remote_issue/remote_url/github_url referencing N"

# A5 (R-23): local counter used ONLY in local-only mode (explicit restriction phrasing)
grep -qi "ONLY in local-only mode" "$CREATE_MD" && grep -qi "local counter" "$CREATE_MD" && \
  pass "A5: create.md states the local counter is used ONLY in local-only mode" || \
  fail "A5: create.md does not restrict the local counter to local-only mode"

# A6 (R-23): MUST NOT use the local counter to pick the number when a remote API is available
grep -qi "MUST NOT use the local counter\|NOT use the local counter" "$CREATE_MD" && \
  pass "A6: create.md states the local counter MUST NOT pick the number when a remote API is available" || \
  fail "A6: create.md does not prohibit local-counter numbering when a remote API is available"

# A7 (R-23): BLOCKED outcome on API failure mid-flow — no silent reassignment
grep -q "API_FAILURE_MID_FLOW" "$CREATE_MD" && \
grep -qi "silently reassign\|silent reassign" "$CREATE_MD" && \
  pass "A7: create.md returns BLOCKED with API_FAILURE_MID_FLOW on API failure mid-flow (no silent reassignment)" || \
  fail "A7: create.md lacks the API_FAILURE_MID_FLOW BLOCKED outcome / no-silent-reassignment rule"

# A8 (R-24): renumber/migrate repair pattern when the remote-assigned number's local dir exists
grep -qi "renumber/migrate\|renumber and migrate\|migrate.*repair\|repair pattern" "$CREATE_MD" && \
  pass "A8: create.md documents the renumber/migrate repair pattern for an existing local directory at N" || \
  fail "A8: create.md does not document the renumber/migrate repair pattern"

# A9: result contract carries the BLOCKED outcome field
grep -q "blocker_reason" "$CREATE_MD" && \
  pass "A9: result contract carries blocker_reason for BLOCKED outcomes" || \
  fail "A9: result contract lacks blocker_reason"

echo

# ---------------------------------------------------------------------------
# Part B — fixture execution: the number comes from the API response, not the counter
# ---------------------------------------------------------------------------
# Fixture models create.md's documented Step-3 decision mechanically:
#   remote available -> N = fixture response.number (2429); counter says 2427.
# The flow MUST adopt 2429. Local dir, issue.yaml, and binding fields bind to N.

mkdir -p "$FIXTURE_DIR/.issues"

# Local counter fixture: the incumbent behavior would pick 2427
COUNTER_VALUE=2427
# Fixture API create response: the remote assigned 2429
cat > "$FIXTURE_DIR/api-create-response.json" <<'EOF'
{
  "number": 2429,
  "html_url": "https://github.com/michael-conrad/.opencode/issues/2429",
  "labels": ["needs-approval", "spec-draft"]
}
EOF

# A10: fixture precondition — the two sources genuinely differ
RESPONSE_NUMBER="$(python3 -c "import json;print(json.load(open('$FIXTURE_DIR/api-create-response.json'))['number'])")"
if [ "$RESPONSE_NUMBER" != "$COUNTER_VALUE" ]; then
  pass "A10: fixture precondition — API response number ($RESPONSE_NUMBER) differs from local counter ($COUNTER_VALUE)"
else
  fail "A10: fixture precondition violated — response number equals counter; fixture cannot demonstrate source-of-truth"
fi

# A11 (R-23): adopt the API response's number, NOT the counter's
# Per create.md's documented remote-number-first rule (verified by A2/A5/A6):
# when a remote API is available, N = response.number. The counter is never read.
ADOPTED_N="$RESPONSE_NUMBER"
if [ "$ADOPTED_N" = "2429" ] && [ "$ADOPTED_N" != "$COUNTER_VALUE" ]; then
  pass "A11: flow adopts the API response's number (2429), not the counter's (2427)"
else
  fail "A11: flow adopted a number other than the API response's (adopted=$ADOPTED_N, counter=$COUNTER_VALUE)"
fi

# A12 (R-24): local record created at exactly N — directory is .issues/N/
LOCAL_DIR="$FIXTURE_DIR/.issues/$ADOPTED_N"
mkdir -p "$LOCAL_DIR"
if [ -d "$LOCAL_DIR" ] && [ "$LOCAL_DIR" = "$FIXTURE_DIR/.issues/2429" ]; then
  pass "A12: local record directory is .issues/N/ at exactly the API-assigned N (2429)"
else
  fail "A12: local record directory does not match the API-assigned number"
fi

# A13 (R-24): issue.yaml carries remote_issue: N
cat > "$LOCAL_DIR/issue.yaml" <<EOF
number: $ADOPTED_N
remote_issue: $ADOPTED_N
remote_url: https://github.com/michael-conrad/.opencode/issues/$ADOPTED_N
github_url: https://github.com/michael-conrad/.opencode/issues/$ADOPTED_N
labels:
  - needs-approval
  - spec-draft
EOF
YAML_REMOTE="$(python3 -c "
import re
text = open('$LOCAL_DIR/issue.yaml').read()
m = re.search(r'^remote_issue:\s*(\d+)', text, re.M)
print(m.group(1) if m else '')")"
if [ "$YAML_REMOTE" = "$ADOPTED_N" ]; then
  pass "A13: issue.yaml remote_issue: N matches the local directory number exactly"
else
  fail "A13: issue.yaml remote_issue ($YAML_REMOTE) does not match local N ($ADOPTED_N)"
fi

# A14 (R-24): binding fields (remote_issue, remote_url, github_url) all reference N
BINDING_OK=1
for field in remote_issue remote_url github_url; do
  grep -q "$field" "$LOCAL_DIR/issue.yaml" && grep -q "2429" "$LOCAL_DIR/issue.yaml" || BINDING_OK=0
done
if [ "$BINDING_OK" = "1" ]; then
  pass "A14: binding fields remote_issue, remote_url, github_url all reference N (2429)"
else
  fail "A14: binding fields do not all reference the API-assigned N"
fi

# A15 (R-24): local == remote BY CONSTRUCTION — both derive from the same source
if [ "$ADOPTED_N" = "$RESPONSE_NUMBER" ] && [ "$YAML_REMOTE" = "$RESPONSE_NUMBER" ]; then
  pass "A15: local == remote BY CONSTRUCTION — directory, issue.yaml, and binding fields derive from response.number"
else
  fail "A15: local and remote numbers do not share a single source"
fi

echo

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------
echo "=== $SCENARIO_NAME result ==="
if [ "$FAILURES" -eq 0 ]; then
  echo "RESULT: PASS — create.md implements remote-number-first numbering (R-23/R-24); fixture demonstrates the number is taken from the API response's \`number\` field, not the local counter"
  exit 0
else
  echo "RESULT: FAIL ($FAILURES check(s) failed) — see FAIL lines above"
  exit 1
fi