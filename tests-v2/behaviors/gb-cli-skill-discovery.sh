#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: gb-cli-skill-discovery
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10: A gb-cli entry appears in <available_skills> after deployment.
# The agent must have the gb-cli skill available when processing a gb CLI request.
# The session.yaml (SQLite DB export) is the PRIMARY evidence source. A clean-room
# sub-agent evaluates whether the gb-cli entry appears in available_skills.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gb-cli-skill-discovery"
SCENARIO_PROMPT="Create a pull request for the current branch in the GitBucket repository root/test-repo with title 'Fix login bug' using the gb CLI."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
