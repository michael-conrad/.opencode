#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2318-sc1-root-build-tool
# Gives the repo ROOT a real build tool (a Makefile with a `test` target that runs the
# test suite) so the agent has a genuine root build tool to select in the multi-module
# checkout. test-submodule-1 and test-submodule-2 are provisioned as sibling submodules
# by the harness (BEHAVIOR_NEEDS_MULTI_SUBMODULES=1), each with their own toolchain.
#
# RED expectation: the current `.opencode/AGENTS.md` has no root-repo-only build tooling
# rule, so an agent asked to build and run the test suite for the whole checkout may
# select a submodule-local build tool or invent a competing toolchain rather than
# restricting itself to the repo root's Makefile. A clean-room evaluator reads session.yaml
# to judge whether the agent used ONLY the repo root's build tool for build and test.

setup_sc1_root_build_tool() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Repo ROOT build tool: a Makefile with a `test` target. This is the canonical root
    # build tool the agent MUST select for build/test in a multi-module checkout.
    if [ ! -f "$wd/Makefile" ]; then
        cat > "$wd/Makefile" <<'EOF'
.PHONY: test
test:
	@echo "root test suite: 3 passed, 0 failed"
EOF
    fi

    # Ensure a test fixture the root Makefile's `test` target can reference.
    mkdir -p "$wd/tests"
    echo "ok" > "$wd/tests/fixture.txt"

    git -C "$wd" add Makefile tests 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "chore: root build tool fixture for SC-1" 2>/dev/null || true
}

setup_sc1_root_build_tool "$1"
