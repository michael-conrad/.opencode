#!/bin/bash
# Per-scenario fixture for 2781-sc6-shadowing-index-repair (.opencode#2781 SC-6).
# Accepts $1 = the test workdir.
#
# Re-scope (attempt-4 fold-in, R-18): attempt 3's fixture bootstrapped the store
# and thereby polluted the workspace with legacy store content the run agent
# spent ~1h20m forensically cataloguing before the target repair. This fixture
# now injects ONLY the criterion's defect class — store content re-tracked in
# the holding repo's index (staged `.issues/` entries whose worktree files do
# not exist) plus an unmerged `.gitignore` — with no store bootstrap and no
# side-state. The store does not exist yet; the prompt's session-start sequence
# provisions it.

set -euo pipefail

setup_2781_shadowing_index() {
    local wd="$1"

    # Ensure .gitignore is tracked in HEAD so the repair can resolve it.
    if [ ! -f "$wd/.gitignore" ]; then
        echo "tmp/" > "$wd/.gitignore"
    fi
    if ! git -C "$wd" cat-file -e HEAD:.gitignore 2>/dev/null; then
        git -C "$wd" add .gitignore
        git -C "$wd" commit -q -m "chore: track gitignore" --allow-empty 2>/dev/null || true
    fi

    # Inject the shadowing index:
    #  (a) a store path re-tracked in the parent index (staged add; blob only
    #      exists in the object DB — worktree file absent, the AD state);
    #  (b) a second store path staged the same way;
    #  (c) an unmerged .gitignore (stage entries conflict with HEAD).
    printf '# store guide (old-model content)\n' > "$wd/.tmp-blob"
    local b1; b1="$(git -C "$wd" hash-object -w "$wd/.tmp-blob")"
    printf '# stale store draft (old-model content)\n' > "$wd/.tmp-blob"
    local b2; b2="$(git -C "$wd" hash-object -w "$wd/.tmp-blob")"
    rm -f "$wd/.tmp-blob"
    git -C "$wd" update-index --add --cacheinfo "100644,$b1,.issues/AGENTS.md"
    git -C "$wd" update-index --add --cacheinfo "100644,$b2,.issues/stale-draft.md"

    local ours theirs
    ours="$(git -C "$wd" hash-object -w "$wd/.gitignore")"
    echo "scratch/" >> "$wd/.gitignore"
    theirs="$(git -C "$wd" hash-object -w "$wd/.gitignore")"
    git -C "$wd" checkout -q HEAD -- .gitignore 2>/dev/null || true
    git -C "$wd" update-index --index-info <<EOF
100644 $ours 1	.gitignore
100644 $ours 2	.gitignore
100644 $theirs 3	.gitignore
EOF

    printf 'fixture: conflicted index injected\n' >> "$wd/fixture-note.txt"
}

setup_2781_shadowing_index "$1"
