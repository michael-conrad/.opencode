#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2314-sc2-plan-absent-dispatch-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-2 (.opencode#2314): plan-absent implementation dispatch. The fixture injects
# ONLY spec.md for issue #2314 (no plan.md) so NO implementation plan exists when the
# agent starts. This setup defensively removes any plan.md from the injected issue
# paths, then applies the shared harness-noise remediations (legacy dirs, dirty tree,
# editor MCP, no-remote, submodule feature-branch contamination, branch pre-work)
# centralized in 1364-for-pr-common.sh.
#
# RED STATE (historical): The PLAN_MISSING dispatch gate did not exist, so an agent
# directed to implement the spec proceeded with the implementation dispatch WITHOUT
# blocking on the missing plan. A clean-room sub-agent evaluating session.yaml
# observed the implementation dispatch proceeding (no PLAN_MISSING block). SC-2 was RED.
#
# GREEN STATE (current — plan step 9, after the SC-1 gate change in 694f60c9): the
# gate routing entries make a plan-less implementation dispatch BLOCK with
# PLAN_MISSING. The scenario assertion requires the blocked outcome: no
# implementation dispatch proceeds, and the agent surfaces the PLAN_MISSING reason
# code instead.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=1364-for-pr-common.sh
source "$SCRIPT_DIR/1364-for-pr-common.sh"

# SC-2-specific: ensure NO plan exists at any injected issue path. The fixture issues
# directory for 2314 contains only spec.md, but remove defensively in case a plan.md
# is ever added to the fixture or injected by a shared mechanism.
remove_plan_for_sc2() {
    local wd="$1"
    rm -f "$wd/.issues/2314/plan.md"
    rm -f "$wd/.issues/open/2314/plan.md"
    rm -f "$wd/.issues/closed/2314/plan.md"
    git -C "$wd" add -A .issues/ 2>/dev/null || true
}

wd="$1"
remove_plan_for_sc2 "$wd"
for_pr_apply_common_remediations "$wd"
