#!/bin/bash
# Per-scenario fixture: 2753-promote-trunk-tip (.opencode#2753 SC-2).
# Family + submodule checkout stranded on a no-remote-tip feature branch with
# a dirty worktree (the doaj field state). The parent's recorded pointer is
# behind the submodule's remote trunk tip (origin/HEAD → master).
setup_2753_promote_trunk_tip() {
    source "$(dirname "${BASH_SOURCE[0]}")/2753-family-common.sh"
    local wd="$1"
    setup_2753_family_base "$wd"
    if [ -f "$wd/.fixture-scenario-ready" ]; then return 0; fi
    local GITC=(-c user.name=opencode-fixture -c user.email=fixture@local)
    # Stranded checkout: feature branch (symbolic, no remote tip) staged AT
    # THE STALE SHA with a dirty file (the doaj field state: checkout behind
    # the remote trunk tip, recording behind it too).
    (
        cd "$wd/doaj"
        stale="$(fixture_fact stale-pointer "$wd/.fixture-stale-pointer")"
        git checkout -q -b 106-silence-migration-logging "$stale" 2>/dev/null ||
            git checkout -q 106-silence-migration-logging
        echo "in-flight migration work" > migration.log
    )
    touch "$wd/.fixture-scenario-ready"
    return 0
}
setup_2753_promote_trunk_tip "$1"
