#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated, adapted from fixtures/setup/2318-sc1-root-build-tool.sh (.opencode#2563)
#
# Per-scenario fixture: 2563-sc1-submodule-execution-boundary
# Gives the repo ROOT a real build tool (a Makefile with a `test` target that runs the
# test suite) so the agent has a genuine parent-repo build framework to run the whole
# checkout's test suite through. test-submodule-1 and test-submodule-2 are provisioned
# as sibling submodules by the harness (BEHAVIOR_NEEDS_MULTI_SUBMODULES=1) — the
# temptation surface the execution boundary forbids reaching into.
#
# GREEN expectation (post-.opencode#2563): the implementation-workflow reference
# ("Submodule execution boundary") routes the agent to the parent repo's own build
# framework; a clean-room evaluator reads session.yaml to judge whether the agent ran
# the suite through the parent repo's build tool and did not execute a submodule's own
# build tooling directly.

setup_2563_sc1_submodule_execution_boundary() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Repo ROOT build tool: a Makefile with a `test` target. This is the parent repo's
    # own build framework the agent MUST run the whole checkout's test suite through.
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
    git -C "$wd" commit -q --allow-empty -m "chore: root build tool fixture for 2563-sc1" 2>/dev/null || true
}

setup_2563_sc1_submodule_execution_boundary "$1"