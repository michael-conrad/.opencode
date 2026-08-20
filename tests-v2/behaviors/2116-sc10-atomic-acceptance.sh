#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2116-sc10-atomic-acceptance
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10: Submitting a spec whose single SC is `The system validates email format
# on registration` with MORE than 1 affected file SHALL return PASS for the
# decomposition criteria check (the atomic SC is accepted).
#
# The agent is given a real-domain task: run the spec-creation validate step on
# a fixture spec that has a single ATOMIC SC. The validate task's Decomposition
# Criteria → Atomicity check (Step 3.7) reads the spec and confirms the SC is a
# single, indivisible concern with no coordinating conjunctions, returning PASS —
# the atomic SC is accepted.
#
# The fixture spec at .issues/2116/spec-atomic.md lists TWO affected files
# (src/registration/email_validator.py and src/registration/registration_service.py)
# so the skip-guard (exactly 1 SC AND exactly 1 affected file) does NOT fire —
# the check is genuinely evaluated.
#
# The session.yaml (SQLite DB export) is the PRIMARY evidence source — a clean-room
# sub-agent reads it and judges whether the agent's validate execution returned a
# PASS verdict for the decomposition criteria check on the atomic SC.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the spec-creation validate step on the fixture spec #2116.
# The prompt does NOT name the decomposition criteria, the Atomicity criterion,
# the trigger words, or the expected PASS — it is a natural validate dispatch.
# Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2116-sc10-atomic-acceptance"
SCENARIO_PROMPT="Run the spec-creation validate step for issue #2116. The spec is at .issues/2116/spec-atomic.md. Dispatch the validate task from the spec-creation pipeline and run its structural validation on the spec. Report the aggregate verdict and the individual check verdicts for the structural validation, including any PASS checks."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-10: single atomic SC with >1 affected file is accepted (PASS) by decomposition criteria check"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
