#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
#
# Behavioral test: tool-injection-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (issue #1015): Behavioral test that sends a prompt triggering sub-agent
# dispatch and generates artifacts for evaluation. The test uses the artifact-only
# generator paradigm — no assertions, just artifact generation.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="tool-injection-red"
SCENARIO_PROMPT="what tools are preferred to grep, cat, find, sed"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0