#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2116-sc13-ceremony-rejection
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13: Submitting a spec whose SECOND SC is ceremony (identical deliverable and
# verification method to the first SC, no new requirement) with MORE than 1 affected
# file SHALL return FAIL with the ceremony reason `SC is ceremony` (or an equivalent
# rejection).
#
# The agent is given a real-domain task: run the spec-creation validate step on a
# fixture spec whose SECOND SC is a ceremony duplicate. The validate task's
# Decomposition Criteria → Ceremony check (set-entailment over prior SCs only)
# reads the spec, compares SC-2 against SC-1, finds identical deliverable + identical
# verification method with no new requirement, and returns FAIL with the ceremony
# reason.
#
# The fixture spec at .issues/2116/spec.md lists TWO affected files
# (src/registration/email_validator.py and src/registration/confirmation_email.py)
# so the SC-8 skip-guard (exactly 1 SC AND exactly 1 affected file) does NOT fire.
#
# The session.yaml (SQLite DB export) is the PRIMARY evidence source — a clean-room
# sub-agent reads it and judges whether the agent's validate execution returned a
# FAIL verdict for the second ceremony SC with the ceremony reason `SC is ceremony`
# (or an equivalent rejection).
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the spec-creation validate step on the fixture spec #2116.
# The prompt does NOT name the decomposition criteria, the Ceremony criterion, or the
# expected reason string — it is a natural validate dispatch. Natural behavior, NOT a
# prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2116-sc13-ceremony-rejection"
SCENARIO_PROMPT="Run the spec-creation validate step for issue #2116. The spec is at .issues/2116/spec.md. Dispatch the validate task from the spec-creation pipeline and run its decomposition criteria on the spec. Report the aggregate verdict and the individual check verdicts for the decomposition validation, including any FAIL checks and their reasons."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-13: second ceremony SC (identical deliverable + verification method to SC-1) with >1 affected file is rejected by the Decomposition Ceremony check"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
