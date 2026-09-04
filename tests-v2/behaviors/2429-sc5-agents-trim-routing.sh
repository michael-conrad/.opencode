#!/bin/bash
# Behavioral test: 2429-sc5-agents-trim-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (#2429): AGENTS.md trim — gb-install / pair-mode routing to canonical homes.
# The scenario asks the agent two real-domain questions:
#   1. How to install the gb CLI on Linux x86_64 and which version to pin.
#   2. What working directory rules apply on a pair-spec/NNN branch.
# The canonical answers live in:
#   - .opencode/skills/gb-cli/reference/install-and-authentication.md (gb install home)
#   - .opencode/guidelines/116-pair-mode.md (pair mode home)
#
# RED condition (pre-GREEN): neither destination exists (gb-cli reference dir absent,
#   AGENTS.md carries the sections inline); the agent answers from the duplicated
#   AGENTS.md copy or cannot reach canonical content.
# GREEN condition: the agent reaches the answers through the Tier-2 routes —
#   following the AGENTS.md Read [Text](path) pointers (or INDEX rows) to the
#   canonical files — and reports the correct install commands/version pin and
#   the pair-mode working-directory rule (main project dir, no worktree).
#
# Evaluation: session.yaml (PRIMARY evidence source) — orchestrator evaluates;
# this script only generates artifacts.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: an install + routing question per plan item 5 RED/verify
# steps ("a gb-install or pair-mode question must route to canonical content")
# — NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2429-sc5-agents-trim-routing"
SCENARIO_PROMPT="I need to set up the GitBucket CLI on this project's CI machine and also understand the collaboration workflow rules. Two questions: (1) How do I install the gb CLI on Linux x86_64, and exactly which version must be pinned — cite the source document you used. (2) If the current branch is pair-spec/2430-review-prep, which working directory must the agent operate in, and are git worktrees allowed — cite the rule document you used. Answer both questions by reading the governing documents in this repo (.opencode/AGENTS.md is a good starting point). Do not install anything or modify any files — just report the answers with their cited sources."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0