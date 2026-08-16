#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 23 — audit SKILL.md dispatch-contract
# and Returns-contract repair (SC-41, SC-42)
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 23 — dispatch-contract repair (SC-41, SC-42), target
#        `.opencode/skills/audit/SKILL.md`.
#
# SC-41: The `Run an audit` Workflows section dispatch contracts in
#   audit/SKILL.md SHALL pass exactly the parameters each role's task card
#   accepts; the 21-parameter union SHALL be reduced to each role's accepted
#   subset, and `pr_number` SHALL be removed from the context passed to any
#   role whose task card does not accept it. (structural)
# SC-42: The `Run an audit` Workflows section Returns fields in audit/SKILL.md
#   SHALL use the same field names as the task cards' Result Contracts —
#   `summary`, not `finding_summary`. (structural)
#
# RED state: the `Run an audit` Workflows section still passes the 21-param
#   dispatch union (which contains orphan params — `pr_number` and
#   `github.repo` — accepted by no task card's `## Dispatch Contract`) and
#   returns `finding_summary` where the task cards' Result Contracts use
#   `summary`. Assertions FAIL on the current code. GREEN reduces the Context
#   passed to each role to its accepted subset (removing orphan params such as
#   `pr_number`) and changes the Returns to `summary`.
#
# Evidence type: structural. This content-verification test compares the
#   on-disk `Run an audit` Workflows dispatch/Returns contracts in SKILL.md
#   against the on-disk `## Dispatch Contract` and Result Contract sections of
#   the audit task cards. It is the RED/GREEN gate for the Phase 23 repair.
#
# Usage: bash .opencode/tests-v2/test-2254-phase23-audit-dispatch-returns-repair.sh
# Exit:  0 if the SKILL.md dispatch contracts and Returns match the task cards (GREEN),
#        1 if any dispatch param is orphan or any Returns field mismatches (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ROLES=(investigator validator evaluator arbiter)

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

# Extract the Returns field names of a given role step directly from the
# `Run an audit` Workflows section of SKILL.md. Returns the field names
# sorted, space-separated.
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

# Extract the accepted Dispatch Contract params of a task card directly from
# its on-disk `## Dispatch Contract` section. Returns the params sorted,
# space-separated. A card with no `## Dispatch Contract` section returns an
# empty string.
on_disk_card_params() {
    local f="$1"
    local result
    result="$(awk '/^## Dispatch Contract/{f=1;next} /^## /{f=0} f' "$f" \
        | grep -oE '^- `[a-z_.]+`' \
        | sed 's/^- `//; s/`$//' \
        | sort | tr '\n' ' ' | sed 's/ $//')" || true
    printf '%s' "$result"
}

# Union of accepted Dispatch Contract params across all task cards for a given
# role (all `*-<role>.md` cards). Returns the params sorted, space-separated.
on_disk_role_params() {
    local role="$1"
    local result=""
    for f in "$AUDIT_DIR"/*"-$role.md"; do
        [ -e "$f" ] || continue
        local params
        params="$(on_disk_card_params "$f")"
        if [ -n "$params" ]; then
            result="$(printf '%s %s' "$result" "$params" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ' | sed 's/ $//')"
        fi
    done
    printf '%s' "$result"
}

# Union of accepted Dispatch Contract params across ALL audit task cards.
# Returns the params sorted, space-separated.
on_disk_all_card_params() {
    local result=""
    for f in "$AUDIT_DIR"/*.md; do
        [ -e "$f" ] || continue
        local params
        params="$(on_disk_card_params "$f")"
        if [ -n "$params" ]; then
            result="$(printf '%s %s' "$result" "$params" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ' | sed 's/ $//')"
        fi
    done
    printf '%s' "$result"
}

# Extract the Result Contract field names of a task card directly from its
# on-disk Result Contract yaml block (the `## Result Contract`, `## Output`,
# or `Return Frugal Result Contract` step). Returns the field names sorted,
# space-separated. A card with no Result Contract block returns an empty string.
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

# Union of Result Contract field names across all task cards for a given role
# (all `*-<role>.md` cards). Returns the field names sorted, space-separated.
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

echo ""
echo "=== Phase 23 — audit SKILL.md dispatch/Returns contract repair (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the dispatch union from the `Run an audit` Workflows
# Context passed, the union of params accepted by ALL task cards, and the
# per-role Returns vs Result Contract field names, all independent of any
# artifact.
# ---------------------------------------------------------------------------
UNION=""
for role in "${ROLES[@]}"; do
    ctx="$(on_disk_role_context "$role")"
    if [ -n "$ctx" ]; then
        UNION="$(printf '%s %s' "$UNION" "$ctx" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ' | sed 's/ $//')"
    fi
done
ALL_CARD_PARAMS="$(on_disk_all_card_params)"

echo "On-disk: ${#ROLES[@]} \`Run an audit\` Workflows roles (investigator/validator/evaluator/arbiter)."
echo "On-disk: dispatch union = {$(printf '%s' "$UNION" | tr ' ' ', ')}"
echo "On-disk: params accepted by ALL task cards = {$(printf '%s' "$ALL_CARD_PARAMS" | tr ' ' ', ')}"
echo ""

# ---------------------------------------------------------------------------
# (a) SC-41 — every parameter in the `Run an audit` Workflows dispatch
#     contract is accepted by at least one audit task card (no orphan params
#     like pr_number).
# ---------------------------------------------------------------------------
echo "--- (a) SC-41: no orphan params in the dispatch union ---"

if [ -z "$UNION" ]; then
    check_fail "SC-41: dispatch union extracted from \`Run an audit\` Workflows" \
        "no Context passed found in the \`Run an audit\` Workflows section of $SKILL_FILE"
else
    check_pass "SC-41: dispatch union extracted from \`Run an audit\` Workflows ($(printf '%s' "$UNION" | tr ' ' '\n' | sed '/^$/d' | wc -l) params)"
fi

for param in $UNION; do
    if printf '%s' "$ALL_CARD_PARAMS" | tr ' ' '\n' | grep -qx "$param"; then
        check_pass "SC-41: dispatch param '$param' accepted by at least one task card"
    else
        check_fail "SC-41: dispatch param '$param' accepted by at least one task card" \
            "'$param' is passed as Context in the \`Run an audit\` Workflows section but accepted by no task card's \`## Dispatch Contract\` (orphan param)"
    fi
done

# SC-41 also requires each role's Context passed to be reduced to that role's
# accepted subset (no over-supplied/unconsumed params per role).
for role in "${ROLES[@]}"; do
    passed="$(on_disk_role_context "$role")"
    accepted="$(on_disk_role_params "$role")"
    for param in $passed; do
        if printf '%s' "$accepted" | tr ' ' '\n' | grep -qx "$param"; then
            check_pass "SC-41: $role Context param '$param' in $role accepted subset"
        else
            check_fail "SC-41: $role Context param '$param' in $role accepted subset" \
                "'$param' is passed to the $role step but not accepted by any $role task card's \`## Dispatch Contract\` (over-supplied/unconsumed)"
        fi
    done
done

# ---------------------------------------------------------------------------
# (b) SC-42 — the `Run an audit` Workflows Returns fields match the task cards'
#     Result Contract field names (`summary`, not `finding_summary`).
# ---------------------------------------------------------------------------
echo "--- (b) SC-42: Workflows Returns fields match the task cards' Result Contracts ---"

for role in "${ROLES[@]}"; do
    returns="$(on_disk_returns_fields "$role")"
    card_fields="$(on_disk_role_card_fields "$role")"

    if [ -z "$returns" ]; then
        check_fail "SC-42: $role Workflows Returns extracted" \
            "no Returns found for the $role step in the \`Run an audit\` Workflows section"
        continue
    fi
    check_pass "SC-42: $role Workflows Returns extracted ({$(printf '%s' "$returns" | tr ' ' ', ')})"

    if [ -z "$card_fields" ]; then
        check_fail "SC-42: $role task cards' Result Contract fields extracted" \
            "no Result Contract found across the $role task cards"
        continue
    fi

    # The Workflows Returns field names must be a subset of the role's task
    # cards' Result Contract field names — every field the Workflows Returns
    # names must be a field the task cards' Result Contracts actually use.
    for field in $returns; do
        if printf '%s' "$card_fields" | tr ' ' '\n' | grep -qx "$field"; then
            check_pass "SC-42: $role Workflows Returns field '$field' is a task card Result Contract field"
        else
            check_fail "SC-42: $role Workflows Returns field '$field' is a task card Result Contract field" \
                "the $role Workflows Returns use '$field' but the $role task cards' Result Contracts do not (they use 'summary')"
        fi
    done

    # Explicit guard: the Returns MUST NOT use `finding_summary` when the task
    # cards' Result Contracts use `summary`.
    if printf '%s' "$returns" | tr ' ' '\n' | grep -qx 'finding_summary'; then
        check_fail "SC-42: $role Workflows Returns do not use 'finding_summary'" \
            "the $role Workflows Returns still use 'finding_summary'; task cards' Result Contracts use 'summary'"
    else
        check_pass "SC-42: $role Workflows Returns do not use 'finding_summary'"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 23 (audit SKILL.md dispatch/Returns contract repair)"
    echo "not yet implemented. The \`Run an audit\` Workflows section still passes the"
    echo "21-param dispatch union containing orphan params (e.g., pr_number) accepted by"
    echo "no task card, and returns \`finding_summary\` where the task cards' Result"
    echo "Contracts use \`summary\`. GREEN reduces the Context passed to each role to its"
    echo "accepted subset (removing orphan params such as pr_number) and changes the"
    echo "Returns to \`summary\`."
    echo ""
    exit 1
fi
echo "Phase 23 is GREEN — the \`Run an audit\` Workflows dispatch contracts pass exactly"
echo "each role's accepted subset (no orphan params) and the Returns fields use \`summary\`"
echo "matching the task cards' Result Contracts."
echo ""
exit 0
