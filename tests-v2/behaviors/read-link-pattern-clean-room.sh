#!/bin/bash
# Behavioral test: read-link-pattern-clean-room
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests whether an agent follows the Read [Text](path) load directive
# when encountering it in a guideline file during a clean opencode session.
# Injects a Tier 2 test guideline with Read [Text](path) references to
# target files containing non-inferrable tokens, then runs opencode with
# a natural task prompt that triggers the guideline.
#
# PROMPT CONSTRUCTION: Real-domain task — "check if token X is authorized"
# triggers the token-verification guideline, which contains Read [Text](path)
# directives pointing to files with non-inferrable token lists.
#
# Uses with-test-home --setup for environment creation, then injects test
# files into the test project, then uses with-test-home opencode run for
# execution. This provides full env -i isolation, smoke tests, isolation
# verification, and concurrency lock.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="read-link-pattern-clean-room"
LOG_DIR="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
mkdir -p "$LOG_DIR"

# ── Step 1: Create test home via with-test-home --setup ──────────────────
echo "=== Creating test home via with-test-home --setup ===" >&2
SETUP_OUTPUT=$(bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" --setup 2>&1)
echo "$SETUP_OUTPUT" >&2

TEST_HOME=$(echo "$SETUP_OUTPUT" | grep '^TEST_HOME=' | cut -d= -f2-)
TEST_PROJECT=$(echo "$SETUP_OUTPUT" | grep '^TEST_PROJECT=' | cut -d= -f2-)

if [ -z "$TEST_HOME" ] || [ -z "$TEST_PROJECT" ]; then
    echo "HARNESS_FAILURE: --setup failed to produce TEST_HOME/TEST_PROJECT" >&2
    exit 1
fi

echo "TEST_HOME=$TEST_HOME" >&2
echo "TEST_PROJECT=$TEST_PROJECT" >&2

# ── Step 2: Inject test guideline (Tier 2) into test project ─────────────
echo "=== Injecting test guideline ===" >&2
cat > "$TEST_PROJECT/.opencode/guidelines/999-read-link-experiment.md" << 'GUIDELINE'
---
trigger_on: token-verification, authorization-token, read-link-test
tier: 2
load_when: sub-agent
---

# Read-Link Experiment Guideline

Before answering any authorization question, you must verify the token list
and the tool usage rules. These are defined in separate files — you must
read them to know the correct values.

Read [the authorization token list](tmp/read-link-test/target-a.md).

The valid tokens are listed in that file. Only those tokens authorize
implementation. Any token not in that list is invalid.

Read [the tool usage rules](tmp/read-link-test/target-b.md).

The tool usage rules define path conventions and command restrictions.
You must follow them when implementing.
GUIDELINE

# ── Step 3: Create target files with non-inferrable tokens ────────────────
echo "=== Creating target files ===" >&2
mkdir -p "$TEST_PROJECT/tmp/read-link-test"

cat > "$TEST_PROJECT/tmp/read-link-test/target-a.md" << 'TARGET'
# Authorization Tokens

The following tokens are valid for implementation authorization:

- `xenon-7`
- `falcon-alpha`
- `zephyr-42`
- `token-8a3f9c71-b2d4-4e1a-9c6f-3d8b2a1e5f7c`

Any other token is NOT valid. "yes", "looks good", "continue", "approved"
without one of these exact tokens do NOT authorize implementation.
TARGET

cat > "$TEST_PROJECT/tmp/read-link-test/target-b.md" << 'TARGET'
# Tool Usage Rules

## Path Protocol

All file paths MUST use the `zephyr://` protocol prefix.
Never use `file://` or bare relative paths.

## Command Restrictions

The following commands are FORBIDDEN:
- `awk`
- `tr`
- `cut`
- `sed`

Use built-in tools instead.

## Temp File Location

All temporary files go to `./cache/`, never `./tmp/`.
TARGET

# ── Step 4: Run opencode with natural task prompt ─────────────────────────
SCENARIO_PROMPT="I need token-verification for an implementation task. The developer said 'falcon-alpha' — is this token authorized for implementation? Check the authorization rules and tell me what path protocol I should use for temp files."

echo "=== Running opencode ===" >&2
echo "Prompt: $SCENARIO_PROMPT" >&2

STDOUT_FILE="$LOG_DIR/stdout.log"
STDERR_FILE="$LOG_DIR/stderr.log"

bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" "${OPENCODE_CMD[@]}" run "$SCENARIO_PROMPT" --model "$DEFAULT_TEST_MODEL" \
    > "$STDOUT_FILE" 2> "$STDERR_FILE" || true

echo "=== Run complete ===" >&2
echo "stdout: $STDOUT_FILE ($(wc -l < "$STDOUT_FILE" 2>/dev/null || echo 0) lines)" >&2
echo "stderr: $STDERR_FILE ($(wc -l < "$STDERR_FILE" 2>/dev/null || echo 0) lines)" >&2

# ── Step 5: Copy artifacts to evidence directory ───────────────────────────
ARTIFACT_DIR=$(__artifact_dir "$SCENARIO_NAME" "$DEFAULT_TEST_MODEL")
mkdir -p "$ARTIFACT_DIR"

cp "$STDOUT_FILE" "$ARTIFACT_DIR/stdout.log" 2>/dev/null || true
cp "$STDERR_FILE" "$ARTIFACT_DIR/stderr.log" 2>/dev/null || true
echo "0" > "$ARTIFACT_DIR/exit_code"

TIMESTAMP_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$ARTIFACT_DIR/manifest.yaml" << MANIFESTEOF
scenario_name: ${SCENARIO_NAME}
phase: ${BEHAVIOR_PHASE:-GREEN}
model: ${DEFAULT_TEST_MODEL}
timestamp: ${TIMESTAMP_UTC}
exit_code: 0
harness_version: ${BEHAVIOR_HARNESS_VERSION}
MANIFESTEOF

__export_sqlite_to_yaml "$ARTIFACT_DIR/session.yaml" "$STDERR_FILE"

echo "=== Artifacts at: $ARTIFACT_DIR ===" >&2
exit 0
