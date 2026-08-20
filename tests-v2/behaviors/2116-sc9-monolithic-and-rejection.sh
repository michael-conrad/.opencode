#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2116-sc9-monolithic-and-rejection
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Submitting a spec whose single SC contains the conjunction `AND` (single
# SC `The system validates email format AND sends confirmation email`, with MORE
# than 1 affected file so the SC-8 skip-guard does not fire) SHALL return FAIL
# with the atomicity reason `SC contains trigger words indicating multiple
# concerns`.
#
# The agent is given a real-domain task: run the spec-creation validate step on
# a fixture spec that has a single monolithic SC. The validate task's
# Decomposition Criteria → Atomicity check (Step 3.7) reads the spec and detects
# the `and` coordinating conjunction joining two requirements, returning FAIL with
# the atomicity reason `SC contains trigger words indicating multiple concerns`.
#
# The fixture spec at .issues/2116/spec-monolithic.md lists TWO affected files
# (src/registration/email_validator.py and src/registration/confirmation_email.py)
# so the SC-8 skip-guard (exactly 1 SC AND exactly 1 affected file) does NOT fire.
#
# The session.yaml (SQLite DB export) is the PRIMARY evidence source — a clean-room
# sub-agent reads it and judges whether the agent's validate execution returned a
# FAIL verdict for the monolithic SC with the atomicity reason `SC contains trigger
# words indicating multiple concerns`.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the spec-creation validate step on the fixture spec #2116.
# The prompt does NOT name the decomposition criteria, the Atomicity criterion, the
# trigger words, or the expected reason string — it is a natural validate dispatch.
# Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2116-sc9-monolithic-and-rejection"
SCENARIO_PROMPT="Run the spec-creation validate step for issue #2116. The spec is at .issues/2116/spec-monolithic.md. Dispatch the validate task from the spec-creation pipeline and run its structural validation on the spec. Report the aggregate verdict and the individual check verdicts for the structural validation, including any FAIL checks and their reasons."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-9: single monolithic (AND) SC with >1 affected file is rejected by decomposition Atomicity check"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
