#!/bin/bash
# Phase 3 — GREEN/structural verification for Gate 4.
#
# Verifies that the implementation is structurally correct.
# Must PASS in GREEN phase (post-implementation).
#
# SC-3: Gate 4 error message lists the actual changed submodule paths
#       from git diff --cached --name-only (dynamic, not hardcoded).
# SC-4: Gate 4 reads submodule paths from git submodule status,
#       not hardcoded values.
#
# Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gate4-green-verification"
OVERALL_RESULT=0

echo "=== GREEN/Structural Verification: Gate 4 (SC-3, SC-4) ==="

HOOK_FILE="$(realpath "$SCRIPT_DIR/../../hooks/pre-commit")"

# ============================================================
# SC-4: No hardcoded submodule paths in Gate 4
# ============================================================
echo ""
echo "--- SC-4: Gate 4 uses dynamic submodule path detection ---"

# Extract Gate 4 section from the hook file (lines 84-135)
GATE4_TEXT=$(sed -n '84,135p' "$HOOK_FILE")

# Check for common hardcoded path patterns
HARDCODED_ISSUES=0

# Check for literal submodule paths like "libs/lib-b" or ".opencode"
if echo "$GATE4_TEXT" | grep -qE '(\.opencode|libs/|vendor/|modules/)'; then
    echo "FAIL: SC-4 — Gate 4 contains hardcoded submodule path"
    HARDCODED_ISSUES=1
fi

# Verify the dynamic detection pattern: git submodule status | awk '{print $2}'
if echo "$GATE4_TEXT" | grep -q "git submodule status.*awk.*print.*\\\$2"; then
    echo "PASS: SC-4 — Gate 4 reads submodule paths dynamically from git submodule status"
else
    echo "FAIL: SC-4 — Gate 4 does not use git submodule status for path detection"
    HARDCODED_ISSUES=1
fi

# Verify exact path match: staged file == submodule path (no prefix matching)
if echo "$GATE4_TEXT" | grep -qE 'if \[ "\$f" = "\$sp" \]'; then
    echo "PASS: SC-4 — Gate 4 uses exact path match (== not =~)"
else
    echo "FAIL: SC-4 — Gate 4 does not use exact path match"
    HARDCODED_ISSUES=1
fi

if [ "$HARDCODED_ISSUES" -ne 0 ]; then
    OVERALL_RESULT=1
fi

# ============================================================
# SC-3: Error message lists changed submodule paths
# ============================================================
echo ""
echo "--- SC-3: Gate 4 error message shows changed paths ---"

# Check that error message iterates over $STAGED_FILES_G4
if echo "$GATE4_TEXT" | grep -q "for f in \$STAGED_FILES_G4"; then
    echo "PASS: SC-3 — Gate 4 iterates staged files in error output"
else
    echo "FAIL: SC-3 — Gate 4 does not list staged files in error output"
    OVERALL_RESULT=1
fi

# Verify the message contains "Submodule-pointer-only commit blocked"
if echo "$GATE4_TEXT" | grep -q "Submodule-pointer-only commit blocked"; then
    echo "PASS: SC-3 — Error message correctly identifies Gate 4"
else
    echo "FAIL: SC-3 — Error message missing Gate 4 identifier"
    OVERALL_RESULT=1
fi

# ============================================================
# Behavioral verification: error message lists actual submodule path
# ============================================================
echo ""
echo "--- SC-3 (behavioral): Gate 4 error message shows real submodule path ---"

TEST_DIR=$(mktemp -d "$PROJECT_DIR/tmp/gate4-green-test-XXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/repo-b"
(cd "$TEST_DIR/repo-b" && git init -q && git config user.email "test@test.dev" && git config user.name "Test")
echo "sub-content" > "$TEST_DIR/repo-b/README.md"
(cd "$TEST_DIR/repo-b" && git add -A && git commit -q -m "init sub")

mkdir -p "$TEST_DIR/repo-a"
(cd "$TEST_DIR/repo-a" && git init -q && git config user.email "test@test.dev" && git config user.name "Test")
echo "parent" > "$TEST_DIR/repo-a/README.md"
(cd "$TEST_DIR/repo-a" && git add README.md && git commit -q -m "init parent")
(cd "$TEST_DIR/repo-a" && git submodule add -q "$TEST_DIR/repo-b" libs/lib-b)
(cd "$TEST_DIR/repo-a" && git add -A && git commit -q -m "add submodule")

# Create feature branch
(cd "$TEST_DIR/repo-a" && git checkout -q -b "feature/sc3-test")

# Install hook
HOOK_SOURCE="$(realpath "$SCRIPT_DIR/../../hooks/pre-commit")"
mkdir -p "$TEST_DIR/repo-a/.git/hooks"
ln -sf "$HOOK_SOURCE" "$TEST_DIR/repo-a/.git/hooks/pre-commit"

# Make submodule change
echo "sc3-update" >> "$TEST_DIR/repo-b/README.md"
(cd "$TEST_DIR/repo-b" && git add -A && git commit -q -m "sc3 update")

# Update submodule pointer
(cd "$TEST_DIR/repo-a" && git submodule update --remote libs/lib-b 2>/dev/null)

# Stage ONLY submodule pointer
(cd "$TEST_DIR/repo-a" && git add libs/lib-b)

# Attempt commit and capture error
COMMIT_OUTPUT=$(cd "$TEST_DIR/repo-a" && git commit -m "test: sc3" 2>&1 || true)

if echo "$COMMIT_OUTPUT" | grep -q "libs/lib-b"; then
    echo "PASS: SC-3 — Gate 4 error message includes actual submodule path 'libs/lib-b'"
else
    echo "FAIL: SC-3 — Gate 4 error message does NOT include the actual submodule path"
    echo "  Output: $(echo "$COMMIT_OUTPUT" | head -5)"
    OVERALL_RESULT=1
fi

# ============================================================
# Additional structural checks
# ============================================================
echo ""
echo "--- Structural: Gate 4 GATE_NAMES entry ---"

if grep -q "Gate 4 (submodule pointer)" "$HOOK_FILE"; then
    echo "PASS: GATE_NAMES includes Gate 4 entry"
else
    echo "FAIL: GATE_NAMES missing Gate 4 entry"
    OVERALL_RESULT=1
fi

echo ""
echo "--- Structural: Gate 4 uses .gitmodules guard ---"
if echo "$GATE4_TEXT" | grep -q "if \[ ! -f \"\$CURRENT_DIR/.gitmodules\" \]"; then
    echo "PASS: Gate 4 has .gitmodules guard"
elif echo "$GATE4_TEXT" | grep -q "if \[ ! -f \".gitmodules\" \]"; then
    echo "PASS: Gate 4 has .gitmodules guard"
else
    echo "FAIL: Gate 4 missing .gitmodules guard"
    OVERALL_RESULT=1
fi

# ============================================================
# Report
# ============================================================
echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (SC-3, SC-4 structural)"
else
    echo "FAIL: $SCENARIO_NAME (SC-3, SC-4 structural)"
fi

exit $OVERALL_RESULT
