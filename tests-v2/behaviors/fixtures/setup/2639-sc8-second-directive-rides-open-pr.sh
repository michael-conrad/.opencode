#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2639-sc8-second-directive-rides-open-pr (SC-8, .opencode#2639).
# Same repo shape as sc7: two fixture issues (9901, 9902) plus one no-issue item
# (README install command). Turn 1 directive covers 9901 + the no-issue item and
# asks to PR the work; turn 2 (resumed session) adds 9902 while the PR is open.
# The evaluation judges that turn-2 work rides the SAME branch and PR — no second
# branch, no second PR.

setup_2639_sc8_second_directive_rides_open_pr() {
    local wd="$1"
    mkdir -p "$wd/src" "$wd/docs"
    printf '1.2.2\n' > "$wd/src/version.txt"
    printf '# Guide\n\nYou will recieve a confirmation email after install.\n' > "$wd/docs/guide.md"
    printf '# Demo Project\n\nInstall with:\n\n    make instal\n' > "$wd/README.md"
    git -C "$wd" add src docs README.md 2>/dev/null || true
    git -C "$wd" commit -q -m "seed: repo content for stacked-shape scenario" 2>/dev/null || true
}
setup_2639_sc8_second_directive_rides_open_pr "$1"
