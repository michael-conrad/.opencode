#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2639-sc7-one-branch-one-pr (SC-7, .opencode#2639).
# Sourced by behavior_run() with $1 = attempt workdir. See tests-v2 AGENTS.md §3 Step 0b.
#
# Scenario state: a small repo with three defects — two covered by fixture
# issues (9901: version string; 9902: docs typo) and one no-issue item
# (README install command). The run agent receives ONE directive covering all
# three and "PR everything". The evaluation (separate clean-room dispatch)
# judges that exactly ONE feature branch and ONE stacked PR result, with one
# squashed commit per issue — never a branch/PR per item.
#
# Issue fixtures 9901/9902 are injected by setup_fixture_issues() (BEHAVIOR_FIXTURE_ISSUES=1).

setup_2639_sc7_one_branch_one_pr() {
    local wd="$1"
    mkdir -p "$wd/src" "$wd/docs"
    printf '1.2.2\n' > "$wd/src/version.txt"
    printf '# Guide\n\nYou will recieve a confirmation email after install.\n' > "$wd/docs/guide.md"
    printf '# Demo Project\n\nInstall with:\n\n    make instal\n' > "$wd/README.md"
    git -C "$wd" add src docs README.md 2>/dev/null || true
    git -C "$wd" commit -q -m "seed: repo content for stacked-shape scenario" 2>/dev/null || true
}
setup_2639_sc7_one_branch_one_pr "$1"
