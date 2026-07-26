#!/bin/bash
# Behavioral test: source-db-missing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13: Verifies that __export_sqlite_to_yaml writes source_db: MISSING
# (not null, not a fallback path) when the SQLite DB is not found in the test home.
#
# This test directly invokes __export_sqlite_to_yaml with a test home that has
# NO SQLite database. The function under test is in helpers.sh.
#
# RED phase: Current __export_sqlite_to_yaml writes source_db: null when DB
# is absent (helpers.sh:131). This test confirms RED by producing a session.yaml
# with source_db: null instead of source_db: MISSING.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="source-db-missing"
LOG_DIR="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
mkdir -p "$LOG_DIR"

# ── Step 1: Create a test home with NO SQLite database ────────────────────────
echo "=== Creating test home (no SQLite DB) ===" >&2
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEST_HOME="$PARENT_REPO_DIR/tmp/test-home-$TIMESTAMP"
mkdir -p "$TEST_HOME/.local/share/opencode"

# Verify NO SQLite DB exists in test home
if [ -f "$TEST_HOME/.local/share/opencode/opencode.db" ]; then
    echo "HARNESS_FAILURE: SQLite DB already exists in test home" >&2
    exit 1
fi
echo "  [OK] No SQLite DB in test home (as expected)" >&2

# ── Step 2: Create a fake stderr file with test home path ──────────────────
STDERR_FILE="$LOG_DIR/stderr.log"
cat > "$STDERR_FILE" << STDERR
Test home: $TEST_HOME
[opencode] Starting session...
STDERR

# ── Step 3: Call __export_sqlite_to_yaml with HOME set to test home ─────────
# Setting HOME=$TEST_HOME ensures the fallback paths (helpers.sh:115-120)
# resolve to $TEST_HOME/.local/share/opencode/opencode.db which does NOT exist.
# This cleanly demonstrates RED: the function writes source_db: null instead of
# source_db: MISSING.
ARTIFACT_DIR=$(__artifact_dir "$SCENARIO_NAME" "direct-test")
mkdir -p "$ARTIFACT_DIR"

SESSION_YAML="$ARTIFACT_DIR/session.yaml"
HOME="$TEST_HOME" __export_sqlite_to_yaml "$SESSION_YAML" "$STDERR_FILE"

echo "=== session.yaml content ===" >&2
cat "$SESSION_YAML" 2>/dev/null || echo "(empty)" >&2

# ── Step 4: Write manifest ────────────────────────────────────────────────────
TIMESTAMP_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$ARTIFACT_DIR/manifest.yaml" << MANIFESTEOF
scenario_name: ${SCENARIO_NAME}
phase: ${BEHAVIOR_PHASE:-RED}
model: direct-test
timestamp: ${TIMESTAMP_UTC}
exit_code: 0
harness_version: ${BEHAVIOR_HARNESS_VERSION}
MANIFESTEOF

cp "$STDERR_FILE" "$ARTIFACT_DIR/stderr.log" 2>/dev/null || true
echo "0" > "$ARTIFACT_DIR/exit_code"

echo "=== Artifacts at: $ARTIFACT_DIR ===" >&2
echo "=== session.yaml content ===" >&2
cat "$SESSION_YAML" 2>/dev/null || echo "(empty)" >&2

exit 0
