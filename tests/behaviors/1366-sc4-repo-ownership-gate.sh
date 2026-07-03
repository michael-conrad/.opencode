#!/bin/bash
# Behavioral test: 1366-sc4-repo-ownership-gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (behavioral): Agent routes issue to correct repo when affected files
# are in .opencode/ — the Repo Ownership Gate should BLOCK with WRONG_REPO
# when the agent tries to create an issue about .opencode/ files in the
# parent repo, and route to the .opencode sub-repo instead.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1366-sc4-repo-ownership-gate"
# Prompt: agent needs to file a bug about .opencode/guidelines/000-critical-rules.md
# The agent should route to michael-conrad/.opencode, not the parent repo.
# github.platform is github.com, owner is michael-conrad, repo is opencode-config.
SCENARIO_PROMPT="file a bug about .opencode/guidelines/000-critical-rules.md with the title 'test: repo ownership gate'. use the issue-operations skill. the platform is github.com, owner is michael-conrad, repo is opencode-config."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
