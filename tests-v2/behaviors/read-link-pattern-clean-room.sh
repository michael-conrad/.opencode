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

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="read-link-pattern-clean-room"
LOG_DIR="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
mkdir -p "$LOG_DIR"

# ── Step 1: Create test home (modeled after with-test-home) ────────────────
echo "=== Creating test home ===" >&2
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEST_HOME="$PARENT_REPO_DIR/tmp/test-home-$TIMESTAMP"
TEST_PROJECT="$TEST_HOME/project"
mkdir -p "$TEST_HOME" "$TEST_PROJECT"

git init -q "$TEST_PROJECT"
git -C "$TEST_PROJECT" config user.email "test@test.dev"
git -C "$TEST_PROJECT" config user.name "Test"

# Clone .opencode submodule
SUBMODULE_URL="https://github.com/michael-conrad/.opencode.git"
git clone -q "$SUBMODULE_URL" "$TEST_PROJECT/.opencode" 2>/dev/null || {
    echo "HARNESS_FAILURE: git clone failed for .opencode" >&2
    exit 1
}

# Checkout the current submodule commit for reproducibility
SUBMODULE_COMMIT=$(git -C "$PARENT_REPO_DIR/.opencode" rev-parse HEAD 2>/dev/null || true)
if [ -n "$SUBMODULE_COMMIT" ]; then
    git -C "$TEST_PROJECT/.opencode" checkout -q "$SUBMODULE_COMMIT" 2>/dev/null || true
fi

git -C "$TEST_PROJECT" add -A 2>/dev/null || true
git -C "$TEST_PROJECT" commit -q --allow-empty -m "init" 2>/dev/null || true

# Seed model config
mkdir -p "$TEST_HOME/.config/opencode"
MODELS=$("${OPENCODE_CMD[@]}" models 2>/dev/null | grep '^ollama/' | sed 's/ .*//' || true)
if [ -z "$MODELS" ]; then
    echo "HARNESS_FAILURE: no models available" >&2
    exit 1
fi

MODEL_ENTRIES=""
FIRST=true
while IFS= read -r model; do
    [ -z "$model" ] && continue
    [ "$FIRST" != "true" ] && MODEL_ENTRIES+=",
        "
    FIRST=false
    BARE="${model#ollama/}"
    MODEL_ENTRIES+="\"$BARE\": {}"
done <<< "$MODELS"

cat > "$TEST_HOME/.config/opencode/opencode.jsonc" << JSONC
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        $MODEL_ENTRIES
      }
    }
  }
}
JSONC

echo "TEST_HOME=$TEST_HOME" >&2
echo "TEST_PROJECT=$TEST_PROJECT" >&2

# ── Step 2: Inject test guideline (Tier 2) ────────────────────────────────
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

# Append to INDEX.md
cat >> "$TEST_PROJECT/.opencode/guidelines/INDEX.md" << 'INDEX'

| `999-read-link-experiment.md` | 2 | token-verification, authorization-token, read-link-test | Token verification experiment |
INDEX

# ── Step 3: Create target files with non-inferrable tokens ─────────────────
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

# ── Step 4: Run opencode with natural task prompt ──────────────────────────
SCENARIO_PROMPT="I need token-verification for an implementation task. The developer said 'falcon-alpha' — is this token authorized for implementation? Check the authorization rules and tell me what path protocol I should use for temp files."

echo "=== Running opencode ===" >&2
echo "Prompt: $SCENARIO_PROMPT" >&2

STDOUT_FILE="$LOG_DIR/stdout.log"
STDERR_FILE="$LOG_DIR/stderr.log"

cd "$TEST_PROJECT"
XDG_CONFIG_HOME="$TEST_HOME/.config" \
XDG_CACHE_HOME="$TEST_HOME/.cache" \
XDG_RUNTIME_DIR="$TEST_HOME/.runtime" \
XDG_DATA_HOME="$TEST_HOME/.local/share" \
XDG_STATE_HOME="$TEST_HOME/.local/state" \
GIT_CONFIG_NOSYSTEM=1 \
"${OPENCODE_CMD[@]}" run "$SCENARIO_PROMPT" --model "$DEFAULT_TEST_MODEL" \
    > "$STDOUT_FILE" 2> "$STDERR_FILE" || true

echo "=== Run complete ===" >&2
echo "stdout: $STDOUT_FILE ($(wc -l < "$STDOUT_FILE" 2>/dev/null || echo 0) lines)" >&2
echo "stderr: $STDERR_FILE ($(wc -l < "$STDERR_FILE" 2>/dev/null || echo 0) lines)" >&2

# ── Step 5: Quick diagnostic grep (not evaluation — just for debugging) ───
echo "=== Diagnostic: read calls in stderr ===" >&2
grep -i 'read.*target-a\|read.*target-b\|read.*read-link-test\|read.*tmp/read-link' "$STDERR_FILE" || echo "  (no read calls to target files found)" >&2

echo "=== Diagnostic: token mentions in stdout ===" >&2
grep -i 'xenon-7\|falcon-alpha\|zephyr-42\|zephyr://' "$STDOUT_FILE" || echo "  (no non-inferrable tokens found in stdout)" >&2

# ── Step 6: Copy artifacts to evidence directory ───────────────────────────
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
