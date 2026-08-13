#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: gb-cli-auth-check
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10: gb-cli skill discovery — the agent dispatches the gb-cli skill and follows
# its entry criteria. The gb-cli task cards require `gb auth status` verification
# as an entry criterion before any authenticated gb operation.
# The session.yaml (SQLite DB export) is the PRIMARY evidence source. A clean-room
# sub-agent evaluates whether the agent checked gb auth status before running gb
# operations.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gb-cli-auth-check"
SCENARIO_PROMPT="List the open issues in the GitBucket repository root/test-repo using the gb CLI."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
