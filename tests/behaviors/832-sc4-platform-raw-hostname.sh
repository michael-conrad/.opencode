#!/bin/bash
# Behavioral test: 832-sc4-platform-raw-hostname
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# GREEN phase test for .opencode#832 SC-4: Agent reports raw hostname platform
# values (github.com, gitbucket.internal.dev) from multi-platform ## Repo Information.
#
# Behavioral: multi-platform fixture repo, agent asked about SCM platforms.
# Must read from session context and report actual hostnames.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="832-sc4-platform-raw-hostname"
SCENARIO_PROMPT="What are the hostname values in the platform field for each repo entry in the workspace?"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/gitbucket-fake-repo"

WORKDIR=$(mktemp -d "$PROJECT_DIR/tmp/behavior-isolated-XXXXXX")
git init -q "$WORKDIR"
git -C "$WORKDIR" config user.email "test@test.dev"
git -C "$WORKDIR" config user.name "Test"
git -C "$WORKDIR" remote add origin git@github.com:michael-conrad/opencode-config.git

# Inject gitbucket fixture as a subdirectory with its own git repo
cp -r "$FIXTURE_DIR" "$WORKDIR/gitbucket-fake-repo"
git -C "$WORKDIR/gitbucket-fake-repo" init -q
git -C "$WORKDIR/gitbucket-fake-repo" config user.email "test@test.dev"
git -C "$WORKDIR/gitbucket-fake-repo" config user.name "Test"
git -C "$WORKDIR/gitbucket-fake-repo" remote add origin git@gitbucket.internal.dev:my-org/some-repo.git
git -C "$WORKDIR/gitbucket-fake-repo" add -A 2>/dev/null || true
git -C "$WORKDIR/gitbucket-fake-repo" commit -q --allow-empty -m "init"

SESSION_INIT="$PROJECT_DIR/.opencode/tools/session-init"
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
if [ -f "$SESSION_INIT" ]; then
    SESSION_OUTPUT=$(cd "$WORKDIR" && uv run --script "$SESSION_INIT" 2>/dev/null) || true
    echo "$SESSION_OUTPUT" > "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/session-init-raw.txt"
fi

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "$DEFAULT_TEST_MODEL" "$WORKDIR"

chmod -R u+w "$WORKDIR" 2>/dev/null || true
rm -rf "$WORKDIR"
exit 0
