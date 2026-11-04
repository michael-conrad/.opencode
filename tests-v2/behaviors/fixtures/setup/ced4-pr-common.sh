#!/bin/bash
# Shared fixture logic for the ced4 non-release PR scenarios (cedproject#4):
# builds a small seeded product repo state whose ready change's category and
# base version state are controlled by the case:
#   $1 = workdir
#   $2 = case name: fix-baseline | feature-release | breaking-release
#
# - fix-baseline:      branch fix/unused-import, a `fix:` commit, NO tags
#                      (derivation base = the 0.1.0 baseline)
# - feature-release:   branch feature/audio-lessons, a `feat:` commit, tag
#                      v0.2.0 seeded on main (derivation base = latest release tag)
# - breaking-release:  branch feature/config-schema, a `feat!:` commit, tag
#                      v0.2.0 seeded on main (breaking -> major bump)
#
# The fixture leaves the workdir ON the ready-change branch; behavior_run
# auto-pushes the current branch to the wired GitBucket origin.
#
# The root AGENTS.md declares trivial fast commands so the run agent's PR-prep
# structural checks never stall on discovery (pre-supplied environment
# mandate, tests-v2 AGENTS.md section 3a).

set -euo pipefail

setup_ced4_case() {
    local wd="$1"
    local case_name="$2"

    # Trivial product content on main
    cat > "$wd/ed-imports.py" <<'EOF'
import os  # unused legacy import

# ed-imports: shared import map for the project
IMPORTS = {
    "figures": "fig",
    "verbs": "verb",
}
EOF
    cat > "$wd/config.json" <<'EOF'
{"storage": "vault", "port": 8410}
EOF

    cat > "$wd/AGENTS.md" <<'EOF'
# Product repo — agent notes

## Build / Lint / Test Commands

| Purpose | Command |
|---------|---------|
| Check (canonical) | `python3 -m py_compile ed-imports.py` |
| Validate (canonical) | `python3 -c "import json; json.load(open('config.json'))"` |

The commands above are the repository's canonical check commands.
EOF

    git -C "$wd" add AGENTS.md ed-imports.py config.json
    git -C "$wd" commit -q -m "chore: seed product content"

    case "$case_name" in
        fix-baseline)
            git -C "$wd" checkout -q -b fix/unused-import
            cat > "$wd/ed-imports.py" <<'EOF'
# ed-imports: shared import map for the project
IMPORTS = {
    "figures": "fig",
    "verbs": "verb",
}
EOF
            git -C "$wd" add ed-imports.py
            git -C "$wd" commit -q -m "fix: drop unused os import from ed-imports"
            ;;
        feature-release)
            git -C "$wd" tag -a v0.2.0 -m "release v0.2.0"
            git -C "$wd" checkout -q -b feature/audio-lessons
            mkdir -p "$wd/lessons"
            cat > "$wd/lessons/audio-lessons.py" <<'EOF'
# audio-lessons: challenge/response lesson builder (initial scaffold)

def lesson(title, items):
    return {"title": title, "challenge_response": items}
EOF
            git -C "$wd" add lessons/audio-lessons.py
            git -C "$wd" commit -q -m "feat: scaffold audio-lessons builder module"
            ;;
        breaking-release)
            git -C "$wd" tag -a v0.2.0 -m "release v0.2.0"
            git -C "$wd" checkout -q -b feature/config-schema
            cat > "$wd/config.json" <<'EOF'
{"storage_uri": "vault://", "listen_port": 8410}
EOF
            git -C "$wd" add config.json
            git -C "$wd" commit -q -m "feat!: rename config fields to storage_uri/listen_port"
            ;;
        *)
            echo "HARNESS_FAILURE: unknown ced4 case '$case_name'" >&2
            exit 1
            ;;
    esac
}
