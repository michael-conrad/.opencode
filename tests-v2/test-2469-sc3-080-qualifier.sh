#!/usr/bin/env bash
# RED test for SC-3 (issue 2469).
# GREEN condition: the repo-scope qualifier + Read-link exist in the
# critical-rules-060 "Functional/Behavioral Test Substitution Prohibition"
# block of .opencode/guidelines/080-code-standards.md.
# RED: qualifier not yet present -> this test FAILS (exit 1).
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FILE="$REPO_ROOT/guidelines/080-code-standards.md"
LOG_DIR="$REPO_ROOT/../tmp/2469/artifacts"
mkdir -p "$LOG_DIR"

# Extract the critical-rules-060 block.
rule=$(grep -n "Functional/Behavioral Test Substitution Prohibition" "$FILE" || true)
if [ -z "$rule" ]; then
    echo "FAIL: critical-rules-060 rule heading not found at all" | tee "$LOG_DIR/red-2469-sc3.log"
    exit 1
fi

# GREEN requires BOTH: the repo-scope qualifier AND a Read-link to the SC-1
# anchor ("## Scope Anchor" in .opencode/tests-v2/AGENTS.md) within the
# critical-rules-060 block.
if ! grep -q "## Scope Anchor" "$REPO_ROOT/tests-v2/AGENTS.md"; then
    echo "FAIL: SC-1 '## Scope Anchor' missing from tests-v2/AGENTS.md" | tee "$LOG_DIR/red-2469-sc3.log"
    exit 1
fi

# Check the rule block (from the heading through the Required Actions bullets)
# for the scope qualifier + Read-link.
start=$(grep -n "Functional/Behavioral Test Substitution Prohibition" "$FILE" | head -1 | cut -d: -f1)
block=$(sed -n "${start},$((start+26))p" "$FILE")

if ! printf '%s\n' "$block" | grep -qi "scope qualifier\|repo-scope\|\.opencode-targeted work only"; then
    echo "FAIL RED: repo-scope qualifier absent from critical-rules-060 block (SC-3 not yet implemented)" | tee "$LOG_DIR/red-2469-sc3.log"
    exit 1
fi

if ! printf '%s\n' "$block" | grep -q "Read \[.*\](.*tests-v2/AGENTS.md.*#.*scope-anchor\|Read \[.*\](.*## Scope Anchor"; then
    echo "FAIL RED: Read-link to SC-1 Scope Anchor absent from critical-rules-060 block (SC-3 not yet implemented)" | tee "$LOG_DIR/red-2469-sc3.log"
    exit 1
fi

echo "PASS: SC-3 qualifier + Read-link present" | tee "$LOG_DIR/red-2469-sc3.log"
exit 0