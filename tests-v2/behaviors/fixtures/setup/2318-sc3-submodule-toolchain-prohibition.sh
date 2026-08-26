#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2318-sc3-submodule-toolchain-prohibition
# Gives the repo ROOT a real build tool (a Makefile with a `test` target) so the agent
# has a genuine root build tool in the multi-module checkout. test-submodule-1 and
# test-submodule-2 are provisioned as sibling submodules by the harness
# (BEHAVIOR_NEEDS_MULTI_SUBMODULES=1), each with their own toolchain.
#
# RED expectation: the current `.opencode/AGENTS.md` has no submodule-toolchain
# prohibition rule (only the SC-1 root build-tool rule and SC-2 root project-local-tools
# rule exist). When asked to run the test suite for the whole checkout, an agent may
# invent a competing build tool inside a submodule or modify a submodule's existing
# tooling rather than restricting itself to the repo root's build tool. A clean-room
# evaluator reads session.yaml to judge whether the agent created or modified any
# submodule toolchain in its recorded actions.

setup_sc3_submodule_toolchain_prohibition() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Repo ROOT build tool: a Makefile with a `test` target. This is the canonical root
    # build tool. The SC-3 prohibition is that the agent must NOT create new build
    # tooling inside a submodule or modify a submodule's existing tooling — it stays on
    # the repo root's toolchain.
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
    git -C "$wd" commit -q --allow-empty -m "chore: root build tool fixture for SC-3" 2>/dev/null || true
}

setup_sc3_submodule_toolchain_prohibition "$1"
