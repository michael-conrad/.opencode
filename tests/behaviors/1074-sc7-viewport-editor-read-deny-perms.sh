#!/bin/bash
# Behavioral test: 1074-sc7-viewport-editor-read-deny-perms
# Tests that agent uses viewport-editor when built-in read/write/edit are denied via permissions.
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1074-sc7-viewport-editor-read-deny-perms"
SCENARIO_PROMPT="Read tmp/test.txt"

# Override behavior_run behavior: inject deny permissions into test home
# before the model runs. We use --setup to get a test home, patch the
# opencode.jsonc with permissions denying built-in read/write/edit,
# then run opencode-cli directly via with-test-home.

# Get a test home with our custom opencode.jsonc that denies built-in tools
local test_home=""
local setup_output
setup_output=$(bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" --setup "$(pwd)")
test_home=$(echo "$setup_output" | grep '^TEST_HOME=' | cut -d= -f2-)
if [ -z "$test_home" ]; then
    echo "HARNESS_FAILURE: --setup failed to produce TEST_HOME" >&2
    exit 1
fi

# Inject deny permissions for built-in read/write/edit
# This forces the agent to use viewport-editor as the alternative
CONFIG="$test_home/.config/opencode/opencode.jsonc"
# Remove trailing } and inject permissions
sed -i '$d' "$CONFIG"
cat >> "$CONFIG" <<'PERMS'
  },
  "permissions": [
    {"permission": "read", "action": "deny", "pattern": "*"},
    {"permission": "write", "action": "deny", "pattern": "*"},
    {"permission": "edit", "action": "deny", "pattern": "*"}
  ]
}
PERMS

echo "  [harness] injected deny permissions for read/write/edit into test config" >&2

# Now run the model with our patched config  
local log_dir="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
mkdir -p "$log_dir"
local output_file="$log_dir/stdout.log"
local err_file="$log_dir/stderr.log"

TEST_WORKDIR="$PARENT_REPO_DIR" \
bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" opencode-cli run "$SCENARIO_PROMPT" --model "$BEHAVIOR_MODEL" --log-level INFO --print-logs \
    > "$output_file" 2> "$err_file" \
    || true

# Produce artifact directory
local artifact_dir
artifact_dir=$(__artifact_dir "$SCENARIO_NAME" "$BEHAVIOR_MODEL")
mkdir -p "$artifact_dir"
cp "$output_file" "$artifact_dir/stdout.log" 2>/dev/null || true
cp "$err_file" "$artifact_dir/stderr.log" 2>/dev/null || true

local timestamp
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$artifact_dir/manifest.yaml" <<MANIFESTEOF
scenario_name: ${SCENARIO_NAME}
phase: GREEN
model: ${BEHAVIOR_MODEL}
timestamp: ${timestamp}
exit_code: 0
harness_version: ${BEHAVIOR_HARNESS_VERSION}
note: Built-in read/write/edit denied via permissions. Agent must use viewport-editor.
MANIFESTEOF

echo "  [harness] artifacts at $artifact_dir" >&2
exit 0