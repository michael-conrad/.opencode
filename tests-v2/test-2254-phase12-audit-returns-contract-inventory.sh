#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 12 — audit SKILL.md Returns contract inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 12 — audit SKILL.md Returns contract inventory (prep
#        for SC-42), target `.opencode/skills/audit/SKILL.md`.
#
# Phase 12 (preparation, no SC): Produce the Returns-contract inventory
#   artifact enumerating the `Run an audit` Workflows Returns fields
#   (summary matching the task-card Result Contracts after SC-42) (prep for
#   SC-42). Depends on Phase 6 (the audit role-card result-contract inventory
#   artifact enumerating each role card's Result Contract field names) and
#   Phase 10 (the audit workflow inventory artifact enumerating the `Run an
#   audit` Workflows steps and their Returns).
#
# The Returns-contract inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-returns-contract-inventory.yaml`;
#   (b) declare the workflow name (`workflow_name: Run an audit`) and enumerate
#       each `Run an audit` Workflows step's Returns field names
#       (`workflow_returns`), matching the on-disk Returns fields of the
#       corresponding role step in the `Run an audit` Workflows section;
#   (c) cross-reference each role's Returns field names against the role
#       cards' Result Contract field names (`task_card_result_contract_fields`),
#       matching the on-disk Result Contract yaml blocks of the role's task
#       cards, and record the match (`mismatch: none`) — the Workflows Returns
#       use `summary`, which is a task card Result Contract field (SC-42);
#   (d) record the overall match finding (`returns_mismatch: none`).
#
# RED state: the Returns-contract inventory artifact does not exist yet.
#   Assertions (a), (b), (c), and (d) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating the `Run an
#   audit` Workflows Returns fields and cross-referencing them against the
#   role cards' Result Contract field names, recording that the Returns use
#   `summary` with no mismatch.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the Returns-contract inventory
#   artifact. It is the RED/GREEN gate for the Phase 12 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase12-audit-returns-contract-inventory.sh
# Exit:  0 if the Returns-contract inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-returns-contract-inventory.yaml"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# Extract the Returns field names of a given role step directly from the
# `Run an audit` Workflows section of SKILL.md, independent of the artifact.
# Returns the field names sorted, space-separated.
on_disk_returns_fields() {
    local role="$1"
    awk -v r="$role" '
        /^### Run an audit/{ f=1 }
        f {
            cap = toupper(substr(r,1,1)) tolower(substr(r,2))
            if ($0 ~ "^- \\[ \\] [0-9]+\\. \\*\\*" cap "\\*\\*") in_step=1
        }
        in_step && /Returns:/ {
            match($0, /\{[^}]*\}/)
            s=substr($0, RSTART+1, RLENGTH-2)
            gsub(/,/, " ", s)
            print s
            exit
        }
    ' "$SKILL_FILE" | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'
}

# Extract the Result Contract field names of a role card directly from its
# on-disk Result Contract yaml block (the `## Result Contract`, `## Output`,
# or `Return Frugal Result Contract` step), independent of the artifact.
# Returns the field names sorted, space-separated. A card with no Result
# Contract block returns an empty string.
on_disk_card_fields() {
    local f="$1"
    local result
    result="$(awk '
        /Return Frugal Result Contract|^## Result Contract|^## Output/ { in_rc=1 }
        in_rc && /```/ {
            if (in_yaml) { exit }
            in_yaml=1
            next
        }
        in_rc && in_yaml {
            line=$0
            sub(/^[[:space:]]+/, "", line)
            if (line ~ /^[a-z_]+:/) { sub(/:.*$/, "", line); print line }
        }
    ' "$f" | sort -u | tr '\n' ' ' | sed 's/ $//')" || true
    printf '%s' "$result"
}

# Extract the union of Result Contract field names across all task cards for a
# given role (all `*-<role>.md` cards), independent of the artifact. Returns
# the field names sorted, space-separated.
on_disk_role_card_fields() {
    local role="$1"
    local result=""
    for f in "$AUDIT_DIR"/*"-$role.md"; do
        [ -e "$f" ] || continue
        local fields
        fields="$(on_disk_card_fields "$f")"
        if [ -n "$fields" ]; then
            result="$(printf '%s %s' "$result" "$fields" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ' | sed 's/ $//')"
        fi
    done
    printf '%s' "$result"
}

# Extract the workflow_returns list for a given role from the artifact.
# Returns the field names sorted, space-separated.
artifact_workflow_returns() {
    local role="$1"
    awk -v r="$role" '
        $0 ~ "^  - role: " r "$" { in_role=1; next }
        in_role && /^    workflow_returns:/ {
            line=$0
            sub(/^    workflow_returns:[[:space:]]*\[/, "", line)
            sub(/\].*$/, "", line)
            gsub(/,/, " ", line)
            gsub(/[[:space:]]+/, " ", line)
            print line
            in_role=0
        }
    ' "$ARTIFACT" | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'
}

# Extract the task_card_result_contract_fields list for a given role from the
# artifact. Returns the field names sorted, space-separated.
artifact_task_card_fields() {
    local role="$1"
    awk -v r="$role" '
        $0 ~ "^  - role: " r "$" { in_role=1; next }
        in_role && /^    task_card_result_contract_fields:/ {
            line=$0
            sub(/^    task_card_result_contract_fields:[[:space:]]*\[/, "", line)
            sub(/\].*$/, "", line)
            gsub(/,/, " ", line)
            gsub(/[[:space:]]+/, " ", line)
            print line
            in_role=0
        }
    ' "$ARTIFACT" | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'
}

echo ""
echo "=== Phase 12 — audit SKILL.md Returns contract inventory (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo "Artifact:    $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the 4 `Run an audit` Workflows Returns field sets and the
# role cards' Result Contract field names, independent of the artifact.
# ---------------------------------------------------------------------------
ROLES=(investigator validator evaluator arbiter)

echo "On-disk: ${#ROLES[@]} \`Run an audit\` Workflows roles (investigator/validator/evaluator/arbiter)."
for role in "${ROLES[@]}"; do
    echo "On-disk: $role Workflows Returns = {$(on_disk_returns_fields "$role" | tr ' ' ', ')}"
done
echo ""

# ---------------------------------------------------------------------------
# (a) The Returns-contract inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): Returns-contract inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 12: Returns-contract inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 12: Returns-contract inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit Returns-contract inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact declares the workflow name and enumerates each `Run an
#     audit` Workflows step's Returns field names, matching the on-disk
#     Returns fields.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates the \`Run an audit\` Workflows Returns fields ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "workflow_name: Run an audit" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 12: artifact declares workflow_name 'Run an audit'"
    else
        check_fail "Phase 12: artifact declares workflow_name 'Run an audit'" \
            "no 'workflow_name: Run an audit' key in $ARTIFACT"
    fi

    if grep -q "returns_contracts:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 12: artifact declares a returns_contracts list"
    else
        check_fail "Phase 12: artifact declares a returns_contracts list" \
            "no 'returns_contracts:' key in $ARTIFACT"
    fi

    for role in "${ROLES[@]}"; do
        if grep -q "^  - role: $role$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 12: artifact enumerates workflow Returns for role $role"
        else
            check_fail "Phase 12: artifact enumerates workflow Returns for role $role" \
                "no '  - role: $role' entry in returns_contracts in $ARTIFACT"
            continue
        fi

        expected="$(on_disk_returns_fields "$role")"
        actual="$(artifact_workflow_returns "$role")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 12: $role workflow_returns match on-disk ($expected)"
        else
            check_fail "Phase 12: $role workflow_returns match on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi
    done
else
    check_fail "Phase 12: artifact enumerates the \`Run an audit\` Workflows Returns fields" \
        "artifact missing — cannot verify the ${#ROLES[@]} roles' Returns fields"
fi

# ---------------------------------------------------------------------------
# (c) The artifact cross-references each role's Returns field names against the
#     role cards' Result Contract field names, matching the on-disk Result
#     Contract yaml blocks, and records the finding_summary vs summary
#     mismatch.
# ---------------------------------------------------------------------------
echo "--- (c): artifact cross-references each role's Returns against the role cards' Result Contracts ---"

if [ -f "$ARTIFACT" ]; then
    for role in "${ROLES[@]}"; do
        if grep -q "^  - role: $role$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 12: artifact cross-references role $role"
        else
            check_fail "Phase 12: artifact cross-references role $role" \
                "no '  - role: $role' entry in returns_contracts in $ARTIFACT"
            continue
        fi

        expected="$(on_disk_role_card_fields "$role")"
        actual="$(artifact_task_card_fields "$role")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 12: $role task_card_result_contract_fields match on-disk ($expected)"
        else
            check_fail "Phase 12: $role task_card_result_contract_fields match on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi

        # The match finding: the Workflows Returns use `summary`, which IS a
        # role card Result Contract field (SC-42). The artifact must record
        # `mismatch: none` for the role (no mismatch between the Workflows
        # Returns and the task cards' Result Contract field names).
        if grep -q "^    mismatch: none$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 12: $role records mismatch: none (Returns use summary)"
        else
            check_fail "Phase 12: $role records mismatch: none (Returns use summary)" \
                "no '    mismatch: none' entry under the $role step in $ARTIFACT"
        fi
    done
else
    check_fail "Phase 12: artifact cross-references each role's Returns against the role cards' Result Contracts" \
        "artifact missing — cannot verify the ${#ROLES[@]} roles' Result Contract cross-references"
fi

# ---------------------------------------------------------------------------
# (d) The artifact records the overall match finding.
# ---------------------------------------------------------------------------
echo "--- (d): artifact records the overall match finding ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "returns_mismatch: none" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 12: artifact records returns_mismatch: none (Returns use summary)"
    else
        check_fail "Phase 12: artifact records returns_mismatch: none (Returns use summary)" \
            "no 'returns_mismatch: none' key in $ARTIFACT"
    fi
else
    check_fail "Phase 12: artifact records the overall match finding" \
        "artifact missing — cannot verify the returns_mismatch finding"
fi

# ---------------------------------------------------------------------------
# (e) The artifact parses as valid YAML. Defect guard: returns_contracts must
#     be well-formed YAML mappings (each item a {role, workflow_returns,
#     task_card_result_contract_fields, mismatch} mapping), not scalar items
#     mixed with mapping keys at the same indentation.
# ---------------------------------------------------------------------------
echo "--- (e): artifact parses as valid YAML ---"

if [ -f "$ARTIFACT" ]; then
    if python3 -c "
import sys, yaml
try:
    with open('$ARTIFACT') as f:
        data = yaml.safe_load(f)
except Exception as e:
    print('YAML parse error: %s' % e, file=sys.stderr)
    sys.exit(1)
if not isinstance(data, dict):
    print('YAML root is not a mapping', file=sys.stderr)
    sys.exit(1)
rc = data.get('returns_contracts')
if not isinstance(rc, list):
    print('returns_contracts is not a list', file=sys.stderr)
    sys.exit(1)
for item in rc:
    if not isinstance(item, dict):
        print('returns_contracts item is not a mapping: %r' % (item,), file=sys.stderr)
        sys.exit(1)
    for field in ('role', 'workflow_returns', 'task_card_result_contract_fields', 'mismatch'):
        if field not in item:
            print('returns_contracts item missing field %r: %r' % (field, item), file=sys.stderr)
            sys.exit(1)
    if not isinstance(item['workflow_returns'], list):
        print('returns_contracts item workflow_returns is not a list: %r' % (item,), file=sys.stderr)
        sys.exit(1)
    if not isinstance(item['task_card_result_contract_fields'], list):
        print('returns_contracts item task_card_result_contract_fields is not a list: %r' % (item,), file=sys.stderr)
        sys.exit(1)
sys.exit(0)
"; then
        check_pass "Phase 12: artifact parses as valid YAML (returns_contracts is well-formed {role, workflow_returns, task_card_result_contract_fields, mismatch} mappings)"
    else
        check_fail "Phase 12: artifact parses as valid YAML" \
            "artifact is not valid YAML — returns_contracts must be well-formed {role, workflow_returns, task_card_result_contract_fields, mismatch} mappings (see stderr)"
    fi
else
    check_fail "Phase 12: artifact parses as valid YAML" \
        "artifact missing — cannot validate YAML"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 12 (audit SKILL.md Returns contract inventory) not yet"
    echo "implemented. The Returns-contract inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating the ${#ROLES[@]} \`Run an"
    echo "audit\` Workflows Returns fields and cross-referencing them against the role"
    echo "cards' Result Contract field names, recording that the Returns use \`summary\`"
    echo "with no mismatch (investigator/validator/evaluator/arbiter)."
    echo ""
    exit 1
fi
echo "Phase 12 is GREEN — the audit Returns-contract inventory artifact enumerates"
echo "the ${#ROLES[@]} \`Run an audit\` Workflows Returns fields and cross-references"
echo "them against the role cards' Result Contract field names, recording that the"
echo "Returns use \`summary\` with no mismatch (investigator/validator/evaluator/arbiter)."
echo ""
exit 0
