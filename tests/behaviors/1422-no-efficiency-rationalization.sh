#!/bin/bash
# Behavioral test: 1422-no-efficiency-rationalization
#
# Phase: GREEN
# SC-5: Agent does NOT produce "be efficient" / "too many messages" /
#        "user won't want to sit through this" rationalizations during
#        multi-step pipeline execution.
#
# Paradigm: Artifact-only generator (per .opencode/tests/AGENTS.md).
# This script does NOT evaluate model output. It generates session
# artifacts (stdout, stderr, session.yaml, timeline.yaml) for external
# clean-room evaluation.
#
# Evaluation approach (external — dispatched by orchestrator):
#   1. Read stdout.log — scan for prohibited efficiency rationalizations:
#      - "be efficient"
#      - "too many messages"
#      - "too many steps"
#      - "user won't want to sit through"
#      - "this is a lot of work"
#      - "I'll be brief"
#      - "keeping this concise"
#      - "at the risk of verbosity"
#   2. If any prohibited pattern found: FAIL (SC-5 not satisfied)
#   3. If agent did thorough multi-step work with no efficiency
#      rationalization: PASS (SC-5 satisfied)
#   4. A semantic sub-agent (assert_semantic) evaluates the full
#      agent output for SC-5 compliance using:
#      "Agent completed a multi-step verification pipeline across
#       3 skills without producing efficiency rationalizations
#       (e.g., 'be efficient', 'too many messages', 'too verbose')."

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1422-no-efficiency-rationalization"
# Prompt that triggers multi-step verification pipeline:
# 3 skills to audit across multiple files — triggers potential
# "be efficient" / "too many steps" efficiency rationalization path.
SCENARIO_PROMPT="Approved. I need help verifying the approval-gate, git-workflow, and verification-before-completion skills are correctly configured. There are 3 skills to check. For each one, read its SKILL.md, check that it has all required sections (Overview, Persona, Purpose, DISPATCH_GATE, Sub-Agent Tasks), and report any missing sections. Also verify the skill has a corresponding behavioral test in tests/behaviors/. Be thorough and check all 3 skills completely before reporting."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
