#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Behavioral test: analytical-artifacts-present
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8 (behavioral): Agent completes the full DiMo chain (retroactive backfill
# artifact evaluation → spec-audit dispatch → auditor tasks) when running a
# spec audit on a spec WITH analytical artifacts, proceeding without BLOCKED
# interruptions.
#
# Real-domain task: user asks to audit a spec that already has all 7 analytical
# artifacts in place — agent should proceed through the full audit chain without
# artifact-generation detours.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="analytical-artifacts-present"
SCENARIO_PROMPT="Please audit spec #42 for the auto-complete feature. All 7 analytical artifacts (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) were already generated during spec creation and are stored at .issues/42/artifacts/. Proceed with the full audit."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
