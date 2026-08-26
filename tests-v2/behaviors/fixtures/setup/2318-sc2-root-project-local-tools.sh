#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2318-sc2-root-project-local-tools
# Gives the repo ROOT a real project-local tool (a tool installed under `.tools/` that
# runs the test suite) so the agent has a genuine root project-local tool to select in
# the multi-module checkout. test-submodule-1 and test-submodule-2 are provisioned as
# sibling submodules by the harness (BEHAVIOR_NEEDS_MULTI_SUBMODULES=1), each with their
# own project-local tooling.
#
# RED expectation: the current `.opencode/AGENTS.md` has no root-repo-only project-local
# tools rule (only the SC-1 root build-tool rule exists), so an agent asked to build and
# run the test suite for the whole checkout may select a submodule-local project-local
# tool or invent a competing toolchain rather than restricting itself to the repo root's
# project-local tools. A clean-room evaluator reads session.yaml to judge whether the
# agent used ONLY the repo root's project-local tools for build and test.

setup_sc2_root_project_local_tools() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Repo ROOT project-local tool: a tool installed under `.tools/` that runs the test
    # suite. This is the canonical root project-local tool the agent MUST select for
    # build/test in a multi-module checkout. Per 085-project-local-tools.md, `.tools/`
    # is gitignored and never tracked.
    if [ ! -f "$wd/.tools/run-tests" ]; then
        mkdir -p "$wd/.tools"
        cat > "$wd/.tools/run-tests" <<'EOF'
#!/bin/bash
echo "root project-local test suite: 3 passed, 0 failed"
EOF
        chmod +x "$wd/.tools/run-tests"
    fi

    # `.tools/` MUST be gitignored per 085-project-local-tools.md (never tracked).
    if [ ! -f "$wd/.gitignore" ]; then
        echo ".tools/" > "$wd/.gitignore"
    elif ! grep -q '^\.tools/$' "$wd/.gitignore" 2>/dev/null; then
        echo ".tools/" >> "$wd/.gitignore"
    fi

    # Ensure a test fixture the root project-local tool can reference.
    mkdir -p "$wd/tests"
    echo "ok" > "$wd/tests/fixture.txt"

    git -C "$wd" add .gitignore tests 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "chore: root project-local tool fixture for SC-2" 2>/dev/null || true
}

setup_sc2_root_project_local_tools "$1"
