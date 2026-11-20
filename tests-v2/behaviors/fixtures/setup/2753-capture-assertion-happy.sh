#!/bin/bash
# Per-scenario fixture: 2753-capture-assertion-happy (.opencode#2753 SC-4).
# Family + a dirty foreign-HEAD submodule checkout: the recording must land
# the promoted trunk tip in the capture commit (plumbing or checkout), and
# the post-capture ls-tree assertion must pass.
setup_2753_capture_assertion_happy() {
    source "$(dirname "${BASH_SOURCE[0]}")/2753-family-common.sh"
    local wd="$1"
    setup_2753_family_base "$wd"
    if [ -f "$wd/.fixture-scenario-ready" ]; then return 0; fi
    local GITC=(-c user.name=opencode-fixture -c user.email=fixture@local)
    # Dirty foreign-HEAD checkout: pinned at the stale SHA (differs from the
    # promoted trunk tip) with uncommitted work.
    (
        cd "$wd/doaj"
        stale="$(fixture_fact stale-pointer "$wd/.fixture-stale-pointer")"
        git checkout -q "$stale" 2>/dev/null || true
        echo "uncommitted local change" > local-work.txt
    )
    # Release branch: cut from master, which already records the stale
    # pointer — the capture step must land the promoted trunk tip over it.
    git -C "$wd" checkout -qb release/submodule-pointer-updates-2
    touch "$wd/.fixture-scenario-ready"
    return 0
}
setup_2753_capture_assertion_happy "$1"
