#!/bin/bash
# Per-scenario fixture: 2753-unresolvable-tip-halt (.opencode#2753 SC-3).
# Family + a registered submodule whose remote trunk tip cannot be resolved:
# the bare submodule origin's HEAD points at a nonexistent ref (no default
# branch advertised), .gitmodules carries no branch field, and the checkout
# sits on a local-only feature branch. Composition must abort with the named
# halt outcome; no release branch, no PR.
setup_2753_unresolvable_tip_halt() {
    source "$(dirname "${BASH_SOURCE[0]}")/2753-family-common.sh"
    local wd="$1"
    setup_2753_family_base "$wd"
    if [ -f "$wd/.fixture-scenario-ready" ]; then return 0; fi
    local home rem
    home="$(dirname "$wd")"
    rem="$home/remote-family"
    local GITC=(-c user.name=opencode-fixture -c user.email=fixture@local)
    # Unresolvable trunk tip, GENUINELY: the bare origin carries NO
    # advertised refs at all — its HEAD symref points at a nonexistent
    # branch AND refs/heads/master is deleted (leaving the branch advertised
    # let fetch recreate origin/HEAD + origin/master and made the tip
    # resolvable — run-2 GREEN composed instead of halting). No .gitmodules
    # branch field (base). The checkout's origin/HEAD tracking ref is
    # deleted, its origin/master too, and the .fixture-trunk-tip fact file
    # is removed — the whole point is that the tip is not knowable.
    git -C "$rem/doaj.git" symbolic-ref HEAD refs/heads/nonexistent-trunk
    git -C "$rem/doaj.git" update-ref -d refs/heads/master 2>/dev/null || true
    git -C "$wd/doaj" update-ref -d refs/remotes/origin/HEAD 2>/dev/null || true
    git -C "$wd/doaj" update-ref -d refs/remotes/origin/master 2>/dev/null || true
    rm -f "$wd/.fixture-trunk-tip"
    # Stranded checkout on a local-only feature branch with a dirty file.
    (
        cd "$wd/doaj"
        git checkout -q -b migration-logging 2>/dev/null || true
        echo "wip" > wip.txt
        git "${GITC[@]}" add wip.txt 2>/dev/null || true
    )
    touch "$wd/.fixture-scenario-ready"
    return 0
}
setup_2753_unresolvable_tip_halt "$1"
