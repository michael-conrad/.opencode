#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Behavioral test: analytical-artifacts-missing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (behavioral): Agent dispatches retroactive artifact generation when
# running a spec audit on a spec WITHOUT analytical artifacts, rather than
# halting with a BLOCKED/MISSING_SPEC_ARTIFACT error.
#
# Real-domain task: user asks to audit a spec for a feature that has been
# brainstormed but not yet decomposed into analytical artifacts — agent should
# trigger backfill/retroactive generation, not halt.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="analytical-artifacts-missing"
SCENARIO_PROMPT="I need to audit spec #42 for the new dry-run flag feature. The spec was approved last week but we never generated the analytical artifacts (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment). Please run the audit — backfill any missing artifacts first."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
