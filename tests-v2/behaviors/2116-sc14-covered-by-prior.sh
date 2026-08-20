#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2116-sc14-covered-by-prior
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-14: Submitting a spec whose SECOND SC is covered by a prior SC (requirement
# set already entailed) with MORE than 1 affected file SHALL return FAIL with the
# coverage reason `SC is covered by a prior SC` (or an equivalent rejection).
#
# The agent is given a real-domain task: run the spec-creation validate step on
# a fixture spec whose second SC has the same requirement set as its first SC
# (SC-2 is entailed by SC-1). The validate task's Decomposition Criteria →
# Coverage / Covered-by-Prior check (Step 3.7) reads the spec and detects that the
# second SC's requirement set is already entailed by a prior SC, returning FAIL
# with the coverage reason `SC is covered by a prior SC (requirement set already
# entailed)`.
#
# The fixture spec at .issues/2301/spec.md lists TWO affected files
# (src/auth/password_policy.py and src/auth/account_creation.py) so the SC-8
# skip-guard (exactly 1 SC AND exactly 1 affected file) does NOT fire.
#
# The session.yaml (SQLite DB export) is the PRIMARY evidence source — a clean-room
# sub-agent reads it and judges whether the agent's validate execution returned a
# FAIL verdict for the covered-by-prior second SC with the coverage reason
# `SC is covered by a prior SC`.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the spec-creation validate step on the fixture spec #2301.
# The prompt does NOT name the coverage criterion, the Covered-by-Prior check, or
# the expected reason string — it is a natural validate dispatch. Natural behavior,
# NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2116-sc14-covered-by-prior"
SCENARIO_PROMPT="Run the spec-creation validate step for issue #2301. The spec is at .issues/2301/spec.md. Dispatch the validate task from the spec-creation pipeline and run its structural validation on the spec. Report the aggregate verdict and the individual check verdicts for the structural validation, including any FAIL checks and their reasons."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-14: second SC covered by a prior SC with >1 affected file is rejected by decomposition Coverage check"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
