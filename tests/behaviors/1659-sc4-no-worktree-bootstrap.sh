#!/bin/bash
# Behavioral test: 1659-sc4-no-worktree-bootstrap
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: session-init completes without attempting worktree creation.
# Calls session-init directly in an isolated test repo and captures output.
# RED phase: session-init calls bootstrap_worktree_layout (worktree output present)
# GREEN phase: session-init completes without worktree-related output

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1659-sc4-no-worktree-bootstrap"
SCENARIO_PROMPT="Run session-init directly and capture worktree-related output"

# Create isolated test repo
TEST_REPO=$(mktemp -d)
trap "rm -rf $TEST_REPO" EXIT

cd "$TEST_REPO"
git init -b main
git config user.email "test@test.com"
git config user.name "Test"

# Clone .opencode submodule
git clone "$PARENT_REPO_DIR/.opencode" .opencode

# Create a minimal session-init wrapper that sources the real one
# We need to run session-init in a context where it won't fail on missing git state
# session-init's main() calls bootstrap_worktree_layout() in the else branch of is_submodule_context()
# Since this is NOT a submodule context, it WILL call bootstrap_worktree_layout()

# Run session-init and capture stderr
cd "$TEST_REPO"
bash .opencode/tools/session-init 2>"$TEST_REPO/stderr.log" 1>"$TEST_REPO/stdout.log" || true

# Create artifact directory
ARTIFACT_DIR=$(__artifact_dir "$SCENARIO_NAME" "$DEFAULT_TEST_MODEL")
mkdir -p "$ARTIFACT_DIR"

# Copy outputs
cp "$TEST_REPO/stderr.log" "$ARTIFACT_DIR/stderr.log"
cp "$TEST_REPO/stdout.log" "$ARTIFACT_DIR/stdout.log"

# Write manifest
cat > "$ARTIFACT_DIR/manifest.yaml" <<EOF
scenario_name: $SCENARIO_NAME
phase: ${BEHAVIOR_PHASE:-GREEN}
model: direct-invocation
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
exit_code: 0
harness_version: ${BEHAVIOR_HARNESS_VERSION:-1}
EOF

echo "0" > "$ARTIFACT_DIR/exit_code"
echo "source_db: null" > "$ARTIFACT_DIR/session.yaml"

echo "Artifacts at: $ARTIFACT_DIR"
exit 0
