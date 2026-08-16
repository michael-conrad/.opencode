#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 11 — audit SKILL.md dispatch contract inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 11 — audit SKILL.md dispatch contract inventory (prep
#        for SC-41), target `.opencode/skills/audit/SKILL.md`.
#
# Phase 11 (preparation, no SC): Produce the dispatch-contract inventory
#   artifact enumerating the `Run an audit` Workflows dispatch contracts
#   (the 21-param dispatch union; no orphan params after SC-41) (prep for
#   SC-41). Depends on Phase 5 (the audit role-card dispatch-contract
#   inventory artifact enumerating each role card's accepted params) and
#   Phase 10 (the audit workflow inventory artifact enumerating the `Run an
#   audit` Workflows steps and their Context passed).
#
# The dispatch-contract inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-dispatch-contract-inventory.yaml`;
#   (b) declare the 21-param dispatch union (`dispatch_union`) matching the
#       on-disk union of the Context params passed to each role in the `Run an
#       audit` Workflows section, and record the union size
#       (`dispatch_union_size: 21`);
#   (c) cross-reference each role's accepted subset against the union
#       (`role_contracts`), where each entry records the role
#       (`investigator`/`validator`/`evaluator`/`arbiter`) and the subset of
#       the union that the role's task cards accept (`accepted_params`),
#       matching the on-disk `## Dispatch Contract` sections of the role cards;
#   (d) record that the dispatch union has no orphan params — i.e., every
#       param in the union is accepted by at least one task card, and
#       `pr_number` (removed from the Context passed by SC-41) is absent from
#       the union and from every role's `accepted_params` subset
#       (`orphan_params: []`).
#
# RED state: the dispatch-contract inventory artifact does not exist yet.
#   Assertions (a), (b), (c), and (d) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating the 21-param
#   dispatch union and cross-referencing each role's accepted subset.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the dispatch-contract inventory
#   artifact. It is the RED/GREEN gate for the Phase 11 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase11-audit-dispatch-contract-inventory.sh
# Exit:  0 if the dispatch-contract inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-dispatch-contract-inventory.yaml"

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

# Extract the Context params passed to a given role step directly from the
# `Run an audit` Workflows section of SKILL.md, independent of any artifact.
# Returns the params sorted, space-separated.
on_disk_role_context() {
    local role="$1"
    awk -v r="$role" '
        /^### Run an audit/{ f=1 }
        f {
            cap = toupper(substr(r,1,1)) tolower(substr(r,2))
            if ($0 ~ "^- \\[ \\] [0-9]+\\. \\*\\*" cap "\\*\\*") in_step=1
        }
        in_step && /Context passed:/ {
            match($0, /\{[^}]*\}/)
            s=substr($0, RSTART+1, RLENGTH-2)
            gsub(/,/, " ", s)
            print s
            exit
        }
    ' "$SKILL_FILE" | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'
}

# Extract the on-disk union of the Context params passed to each role in the
# `Run an audit` Workflows section of SKILL.md. After SC-41 each role passes
# its accepted subset; this unions the per-role Contexts and returns the
# sorted unique union, space-separated.
on_disk_union() {
    local result=""
    for role in investigator validator evaluator arbiter; do
        local ctx
        ctx="$(on_disk_role_context "$role")"
        if [ -n "$ctx" ]; then
            result="$(printf '%s %s' "$result" "$ctx" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ' | sed 's/ $//')"
        fi
    done
    printf '%s' "$result"
}

# Extract the accepted Dispatch Contract params of a role card directly from
# its on-disk `## Dispatch Contract` section (live, independent of the
# artifact). Returns the params sorted, space-separated. A card with no
# `## Dispatch Contract` section returns an empty string.
on_disk_role_params() {
    local f="$1"
    local result
    result="$(awk '/^## Dispatch Contract/{f=1;next} /^## /{f=0} f' "$f" \
        | grep -oE '^- `[a-z_.]+`' \
        | sed 's/^- `//; s/`$//' \
        | sort | tr '\n' ' ' | sed 's/ $//')" || true
    printf '%s' "$result"
}

# Extract the dispatch_union list from the artifact, sorted, space-separated.
artifact_union() {
    awk '
        /^dispatch_union:/ { in_union=1; next }
        in_union && /^  - / {
            line=$0
            sub(/^[[:space:]]*-[[:space:]]*/, "", line)
            print line
            next
        }
        in_union && /^[a-zA-Z_]+:/ && !/^  - / { in_union=0 }
    ' "$ARTIFACT" | sort | tr '\n' ' ' | sed 's/ $//'
}

# Extract the accepted_params list for a given role from the artifact's
# role_contracts. Returns the params sorted, space-separated.
artifact_role_params() {
    local role="$1"
    awk -v r="$role" '
        $0 ~ "^  - role: " r "$" { in_role=1; next }
        in_role && /^    accepted_params:/ {
            line=$0
            sub(/^    accepted_params:[[:space:]]*\[/, "", line)
            sub(/\].*$/, "", line)
            gsub(/,/, " ", line)
            gsub(/[[:space:]]+/, " ", line)
            print line
            in_role=0
        }
    ' "$ARTIFACT" | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'
}

# Determine whether pr_number is accepted by ANY audit role card on disk.
# Returns 0 (true) if found, 1 (false) if absent from all cards.
pr_number_accepted_by_card() {
    for f in "$PROJECT_DIR/.opencode/skills/audit/tasks/"*.md; do
        if awk '/^## Dispatch Contract/{f=1;next} /^## /{f=0} f' "$f" | grep -q 'pr_number'; then
            return 0
        fi
    done
    return 1
}

echo ""
echo "=== Phase 11 — audit SKILL.md dispatch contract inventory (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo "Artifact:    $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the 21-param dispatch union from the `Run an audit`
# Workflows section, and the 4 roles' accepted subsets from the role cards,
# independent of the artifact.
# ---------------------------------------------------------------------------
UNION="$(on_disk_union)"
UNION_COUNT="$(printf '%s\n' "$UNION" | tr ' ' '\n' | sed '/^$/d' | wc -l)"
ROLES=(investigator validator evaluator arbiter)

echo "On-disk: $UNION_COUNT-param dispatch union from the \`Run an audit\` Workflows Context passed."
echo "On-disk: ${#ROLES[@]} roles (investigator/validator/evaluator/arbiter)."
echo ""

# ---------------------------------------------------------------------------
# (a) The dispatch-contract inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): dispatch-contract inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 11: dispatch-contract inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 11: dispatch-contract inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit dispatch-contract inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact declares the 21-param dispatch union matching the on-disk
#     union, and records the union size.
# ---------------------------------------------------------------------------
echo "--- (b): artifact declares the 21-param dispatch union ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "dispatch_union:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 11: artifact declares a dispatch_union list"
    else
        check_fail "Phase 11: artifact declares a dispatch_union list" \
            "no 'dispatch_union:' key in $ARTIFACT"
    fi

    actual_union="$(artifact_union)"
    if [ "$actual_union" = "$UNION" ]; then
        check_pass "Phase 11: artifact dispatch_union matches on-disk union ($UNION_COUNT params)"
    else
        check_fail "Phase 11: artifact dispatch_union matches on-disk union" \
            "expected '$UNION', artifact has '$actual_union'"
    fi

    if grep -q "dispatch_union_size: $UNION_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 11: artifact records dispatch_union_size $UNION_COUNT"
    else
        check_fail "Phase 11: artifact records dispatch_union_size $UNION_COUNT" \
            "expected 'dispatch_union_size: $UNION_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 11: artifact declares the 21-param dispatch union" \
        "artifact missing — cannot verify the $UNION_COUNT-param dispatch union"
fi

# ---------------------------------------------------------------------------
# (c) The artifact cross-references each role's accepted subset against the
#     union, matching the on-disk `## Dispatch Contract` sections.
# ---------------------------------------------------------------------------
echo "--- (c): artifact cross-references each role's accepted subset ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "role_contracts:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 11: artifact declares a role_contracts list"
    else
        check_fail "Phase 11: artifact declares a role_contracts list" \
            "no 'role_contracts:' key in $ARTIFACT"
    fi

    for role in "${ROLES[@]}"; do
        if grep -q "^  - role: $role$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 11: artifact cross-references role $role"
        else
            check_fail "Phase 11: artifact cross-references role $role" \
                "no '  - role: $role' entry in role_contracts in $ARTIFACT"
            continue
        fi

        # The role's accepted subset is the union of the Dispatch Contract
        # params accepted by that role's task cards on disk.
        expected=""
        for f in "$PROJECT_DIR/.opencode/skills/audit/tasks/"*"-$role.md"; do
            [ -e "$f" ] || continue
            card_params="$(on_disk_role_params "$f")"
            if [ -n "$card_params" ]; then
                expected="$(printf '%s %s' "$expected" "$card_params" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ' | sed 's/ $//')"
            fi
        done

        actual="$(artifact_role_params "$role")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 11: $role accepted_params match on-disk ($expected)"
        else
            check_fail "Phase 11: $role accepted_params match on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi
    done
else
    check_fail "Phase 11: artifact cross-references each role's accepted subset" \
        "artifact missing — cannot verify the ${#ROLES[@]} roles' accepted subsets"
fi

# ---------------------------------------------------------------------------
# (d) The artifact records that the dispatch union has no orphan params:
#     every param in the union is accepted by at least one task card, and
#     `pr_number` (removed from the Context passed by SC-41) is absent from
#     the union and from every role's accepted_params subset.
# ---------------------------------------------------------------------------
echo "--- (d): artifact records no orphan params (pr_number removed from dispatch union) ---"

if [ -f "$ARTIFACT" ]; then
    # Live cross-check: pr_number must NOT be in the on-disk union (SC-41
    # removed it from the Context passed to every role).
    if printf '%s' "$UNION" | tr ' ' '\n' | grep -qx 'pr_number'; then
        check_fail "Phase 11: on-disk dispatch union excludes pr_number" \
            "pr_number IS still in the on-disk dispatch union"
    else
        check_pass "Phase 11: on-disk dispatch union excludes pr_number (SC-41 removed it from Context)"
    fi

    # ...and pr_number must be accepted by no task card on disk.
    if pr_number_accepted_by_card; then
        check_fail "Phase 11: on-disk pr_number accepted by no task card" \
            "pr_number IS accepted by at least one audit role card on disk"
    else
        check_pass "Phase 11: on-disk pr_number accepted by no task card"
    fi

    # The artifact must declare the no-orphan-params finding.
    if grep -q "orphan_params: \[\]" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 11: artifact records orphan_params: [] (no orphan params)"
    else
        check_fail "Phase 11: artifact records orphan_params: [] (no orphan params)" \
            "no 'orphan_params: []' key in $ARTIFACT"
    fi

    # pr_number must be absent from every role's accepted_params in the artifact.
    for role in "${ROLES[@]}"; do
        actual="$(artifact_role_params "$role")"
        if printf '%s' "$actual" | tr ' ' '\n' | grep -qx 'pr_number'; then
            check_fail "Phase 11: $role accepted_params exclude pr_number" \
                "pr_number IS in the $role accepted_params subset in $ARTIFACT"
        else
            check_pass "Phase 11: $role accepted_params exclude pr_number"
        fi
    done
else
    check_fail "Phase 11: artifact records no orphan params" \
        "artifact missing — cannot verify the no-orphan-params finding"
fi

# ---------------------------------------------------------------------------
# (e) The artifact parses as valid YAML. Defect guard: dispatch_union and
#     role_contracts must be well-formed YAML structures, not scalar items
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
union = data.get('dispatch_union')
if not isinstance(union, list) or not all(isinstance(p, str) for p in union):
    print('dispatch_union is not a list of strings', file=sys.stderr)
    sys.exit(1)
if data.get('dispatch_union_size') != len(union):
    print('dispatch_union_size does not match dispatch_union length', file=sys.stderr)
    sys.exit(1)
rc = data.get('role_contracts')
if not isinstance(rc, list):
    print('role_contracts is not a list', file=sys.stderr)
    sys.exit(1)
for item in rc:
    if not isinstance(item, dict):
        print('role_contracts item is not a mapping: %r' % (item,), file=sys.stderr)
        sys.exit(1)
    for field in ('role', 'accepted_params'):
        if field not in item:
            print('role_contracts item missing field %r: %r' % (field, item), file=sys.stderr)
            sys.exit(1)
    if not isinstance(item['accepted_params'], list):
        print('role_contracts item accepted_params is not a list: %r' % (item,), file=sys.stderr)
        sys.exit(1)
sys.exit(0)
"; then
        check_pass "Phase 11: artifact parses as valid YAML (dispatch_union + role_contracts well-formed)"
    else
        check_fail "Phase 11: artifact parses as valid YAML" \
            "artifact is not valid YAML — dispatch_union and role_contracts must be well-formed (see stderr)"
    fi
else
    check_fail "Phase 11: artifact parses as valid YAML" \
        "artifact missing — cannot validate YAML"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 11 (audit SKILL.md dispatch contract inventory) not yet"
    echo "implemented. The dispatch-contract inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating the $UNION_COUNT-param"
    echo "dispatch union and cross-referencing each role's accepted subset"
    echo "(investigator/validator/evaluator/arbiter), recording that the dispatch union"
    echo "has no orphan params (pr_number removed from the Context passed by SC-41)."
    echo ""
    exit 1
fi
echo "Phase 11 is GREEN — the audit dispatch-contract inventory artifact enumerates"
echo "the $UNION_COUNT-param dispatch union and cross-references each role's accepted"
echo "subset (investigator/validator/evaluator/arbiter), recording that the dispatch"
echo "union has no orphan params (pr_number removed from the Context passed by SC-41)."
echo ""
exit 0
