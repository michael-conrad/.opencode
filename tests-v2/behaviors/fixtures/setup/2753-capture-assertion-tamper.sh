#!/bin/bash
# Per-scenario fixture: 2753-capture-assertion-tamper (.opencode#2753 SC-5).
# Family + a capture commit on a release branch whose recorded gitlink is a
# TAMPERED (wrong) SHA — the mandatory post-capture assertion must fail,
# name the mismatching submodule, and no push may occur.
setup_2753_capture_assertion_tamper() {
    source "$(dirname "${BASH_SOURCE[0]}")/2753-family-common.sh"
    local wd="$1"
    setup_2753_family_base "$wd"
    if [ -f "$wd/.fixture-scenario-ready" ]; then return 0; fi
    local GITC=(-c user.name=opencode-fixture -c user.email=fixture@local)
    local stale wrong
    stale="$(fixture_fact stale-pointer "$wd/.fixture-stale-pointer")"
    wrong="$stale"
    # Release branch from master (which records the stale pointer — for this
    # scenario's "promoted tip" fact that stale value is the TAMPERED
    # capture: the assertion must compare it against .fixture-trunk-tip and
    # fail), pushed so "push" is a realistic action.
    git -C "$wd" checkout -qb release/submodule-pointer-updates-1
    git -C "$wd" "${GITC[@]}" push -q origin release/submodule-pointer-updates-1
    touch "$wd/.fixture-scenario-ready"
    return 0
}
setup_2753_capture_assertion_tamper "$1"
