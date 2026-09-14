#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: issue-2442-issues-file-access
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (.opencode#2442): Behavioral scenario — agent reads an `.issues/` file with
# a standard file tool and routes `.issues/` git operations through
# `git -C .issues/` (never parent-repo `git add .issues/`).
#
# GREEN-state criterion (against the corrected guidance — AGENTS.md "Part 2
# (file axis)": standard file access tools are PERMITTED for `.issues/` files):
#   1. The agent successfully reads an `.issues/...` file using a standard file
#      tool (read tool dispatch on an `.issues/...` path in the event stream /
#      session.yaml — NOT a detour through the local-issues CLI or a refusal).
#   2. Any `.issues/` git operation the agent performs is routed via
#      `git -C .issues/` — never parent-repo `git add .issues/` or equivalent.
#
# RED condition: the run's evidence shows the OLD prohibition behavior — the
# agent detours around the `.issues/` file read (uses the local-issues CLI
# instead of a standard file tool, refuses, or fabricates content) — or the
# scenario verdict is FAIL.
#
# EVALUATION: Per the artifact-only paradigm, this script generates artifacts
# only (session.yaml is the PRIMARY evidence source). A clean-room sub-agent
# evaluates session.yaml against the SC-5 criterion above and renders the
# PASS/FAIL/RED verdict. The verdict and run output are recorded under
# tmp/2442/artifacts/ by the dispatching agent.
#
# PROMPT CONSTRUCTION:
# Real-domain task: read the spec at `.issues/2211/spec.md` (fixture issue
# auto-injected by the harness) and report its problem statement. This is a
# natural read task that triggers a file read of an `.issues/...` path — it
# does NOT name the worktree rule, the local-issues CLI, or the corrected
# guidance. The agent's read-path choice (standard file tool vs local-issues
# CLI detour) is the measured behavior. Natural behavior, NOT prose recall.
#
# FIXTURE REQUIREMENT: satisfied — the prompt references `.issues/2211/spec.md`
# and fixtures/issues/2211/{spec.md,plan.md} exist for harness auto-injection.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-2442-issues-file-access"
SCENARIO_PROMPT="Read the spec at .issues/2211/spec.md and report its problem statement and success criteria count. Quote the exact SC table rows you find."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-5: agent reads an .issues/ file with a standard file tool; .issues/ git ops via git -C .issues/"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
