#!/bin/bash
# Per-scenario fixture: the test-submodule-1 and test-submodule-2 siblings are provisioned
# by the harness (helpers.sh BEHAVIOR_NEEDS_MULTI_SUBMODULES block) as REACHABLE remotes
# referencing the real test repos. This fixture runs BEFORE that provisioning block, so it
# performs no wiring itself — the harness handles it. It exists as the per-scenario hook
# point and documents the GREEN state faithfully.
#
# SC-4: the behavioral test framework SHALL provision and reference the real test submodule
# repos (git@github.com:michael-conrad/test-submodule-1.git, default branch `dev`, has
# commits; git@github.com:michael-conrad/test-submodule-2.git, empty) as REACHABLE remotes.
#
# GREEN state: helpers.sh clones test-submodule-1 from the real repo so origin/dev is a
# genuine reachable ref, and initializes test-submodule-2 wired to the real empty remote as
# origin. The agent's reachability check `git merge-base --is-ancestor` resolves against a
# genuine reachable origin/$DEFAULT_BRANCH on each sibling — the test PASSES (GREEN).
#
# NOTE: This fixture deliberately performs NO provisioning beyond the harness default. The
# harness's BEHAVIOR_NEEDS_MULTI_SUBMODULES block (helpers.sh) is the wiring point.

setup_sc4_reachable_submodules() {
    local wd="$1"
    # No-op: the harness provisions test-submodule-1 and test-submodule-2 as reachable
    # remotes referencing the real test repos. Do NOT add remotes here.
    :
}

setup_sc4_reachable_submodules "$1"
