#!/bin/bash
# Behavioral test: release-pr-body-behavioral
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="release-pr-body-behavioral"
SCENARIO_PROMPT="Perform a release promotion to v1.2.3"
BEHAVIOR_PHASE="RED"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0