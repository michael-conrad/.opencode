#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
#
# Shared per-scenario fixture for the #1364 for_pr behavioral tests (SC-1 and SC-2).
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Both 1364-sc1 and 1364-sc2 run the agent under `for_pr` scope and need the agent to
# reach PLAN EXECUTION (executing-plans dispatch) rather than burning the harness
# window on test-environment noise. The harness noise is common to both scenarios, so
# this file centralizes the remediations. The per-scenario scripts source this file and
# then apply scenario-specific deltas (SC-1 keeps the plan; SC-2 removes it).
#
# The noise sources this fixture eliminates (all observed across the SC-2 -3..-7 runs):
#   1. Legacy .issues/open + .issues/closed dirs -> "remediate manually" warning derails the
#      agent into re-inspecting the .issues/ layout instead of reading spec.md/plan.md.
#   2. Injected .issues/ fixtures left STAGED but uncommitted -> pre-work sub-agent stashes
#      76+ files / pops / reconciles, a 10-minute round-trip before any plan work.
#   3. The editor MCP (viewport-editor) registered in the test project's opencode.jsonc ->
#      qwen3.6 cannot drive the multi-action editor interface (emits action-less editor_file
#      calls, external-directory rejects), stalling the agent.
#   4. Parent repo has NO origin -> session-init reports platform:local / owner:(none), and
#      the agent loops on "no remote, can't create a PR" instead of dispatching the plan.
#   5. The .opencode submodule's origin is the REAL remote that contains the feature branch ->
#      the agent sees feature/1364... and concludes "already implemented/pushed", halting.
#   6. git-workflow / approval-gate mandates branch pre-work before any filesystem change ->
#      establishing the feature branch in the fixture makes pre-work a no-op.
#
# The fixture does NOT weaken any behavioral assertion. It only removes environment noise so
# the model reaches the behavior under test (executing-plans dispatch) within the harness window.

set -euo pipefail

fixture_error() {
    echo "  [fixture] ERROR: $*" >&2
}

# Remove the legacy .issues/open and .issues/closed directories that setup-fixture-issues.sh
# creates. The local-issues tool flags these with a "Legacy issue directory format detected"
# warning on every read; the agent reads that warning as an instruction to stop and remediate
# the layout instead of reading .issues/{N}/spec.md. Keeping only the flat .issues/{N}/ layout
# removes the noise so the agent proceeds to plan work.
remove_legacy_open_closed_dirs() {
    local wd="$1"
    rm -rf "$wd/.issues/open" "$wd/.issues/closed"
    git -C "$wd" add -A .issues/ 2>/dev/null || true
}

# Commit the injected fixture state into the init commit so the working tree is CLEAN.
# Without this, the pre-work sub-agent sees a dirty tree (dozens of staged .issues files)
# and spends the window stashing/reconciling instead of reading the plan. The plan presence
# (SC-1) or absence (SC-2) is unaffected by committing the fixtures.
commit_fixture_state() {
    local wd="$1"
    git -C "$wd" add -A .issues/ tmp/ 2>/dev/null || true
    git -C "$wd" -c user.name="Test" -c user.email="test@test.dev" \
        commit -q -m "chore: commit fixture issue state" 2>/dev/null || true
}

# Disable the editor MCP in the test project's .opencode/opencode.jsonc so the model uses the
# built-in Tier-1 read/glob/bash tools (which it drives correctly and which record to
# session.yaml) instead of stalling on the editor MCP's multi-action interface.
disable_editor_mcp() {
    local wd="$1"
    local cfg="$wd/.opencode/opencode.jsonc"
    if [ -f "$cfg" ]; then
        python3 - "$cfg" << 'PY'
import sys
import re

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    text = f.read()

# Remove the "editor": { ... } entry from the "mcp" block. Match the leading comma plus the
# "editor" key through its closing brace, then fall back to a leading "editor": {...}, form.
pattern = re.compile(r',\s*"editor"\s*:\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', re.DOTALL)
new_text, n = pattern.subn("", text)
if n == 0:
    pattern2 = re.compile(r'"editor"\s*:\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', re.DOTALL)
    new_text, n = pattern2.subn("", text)
if n:
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_text)
    print("editor MCP disabled in " + path)
else:
    print("WARNING: editor MCP block not found in " + path + " — no edit applied")
PY
    fi
}

# Commit the editor-MCP disable inside the .opencode submodule and update the parent gitlink
# so `git status` and `git submodule status` are CLEAN. Without this the submodule reads dirty
# for the whole run and the agent spends the window reconciling submodule state.
commit_editor_disable_in_submodule() {
    local wd="$1"
    local sub="$wd/.opencode"
    if [ ! -d "$sub/.git" ]; then
        return 0
    fi
    if [ -z "$(git -C "$sub" status --porcelain 2>/dev/null)" ]; then
        return 0
    fi
    git -C "$sub" -c user.name="Test" -c user.email="test@test.dev" add -A 2>/dev/null || true
    git -C "$sub" -c user.name="Test" -c user.email="test@test.dev" \
        commit -q -m "chore: disable editor MCP for behavioral test" 2>/dev/null || true
    git -C "$wd" add .opencode 2>/dev/null || true
    git -C "$wd" -c user.name="Test" -c user.email="test@test.dev" \
        commit -q --allow-empty -m "chore: update submodule gitlink" 2>/dev/null || true
    echo "  [fixture] editor-MCP disable committed inside submodule; submodule is clean" >&2
}

# Seed a local bare repository as the parent project's origin with a `main` branch so
# `git remote -v` / `git remote show origin` report a concrete single remote. Without this
# the parent is local-only (platform:local) and the agent loops on "no remote => can't PR".
seed_parent_origin() {
    local wd="$1"
    local parent_bare="$wd/../for-pr-parent-origin.git"
    rm -rf "$parent_bare"
    git init --bare -q "$parent_bare"
    if git -C "$wd" rev-parse --verify HEAD >/dev/null 2>&1; then
        git -C "$wd" push -q "$parent_bare" "HEAD:refs/heads/main" 2>/dev/null || {
            echo "  [fixture] WARNING: could not seed parent origin main — continuing without parent remote" >&2
            return 0
        }
    fi
    git -C "$wd" remote add origin "$parent_bare" 2>/dev/null || true
    git -C "$wd" fetch -q origin 2>/dev/null || true
    echo "  [fixture] parent origin seeded to local bare repo (main only)" >&2
}

# Repoint the .opencode submodule origin to a LOCAL bare repository containing only `main`,
# then prune stale refs. The harness clones the REAL remote, so `git remote show origin`
# lists the real feature branch; the agent sees it and concludes the work is already done.
# The working tree stays at the feature commit (executing-plans skill + routing rule present)
# but the agent can no longer see the feature branch.
isolate_submodule_from_feature_branch() {
    local wd="$1"
    local sub="$wd/.opencode"
    if [ ! -d "$sub/.git" ]; then
        echo "  [fixture] WARNING: .opencode submodule not present at $sub — skipping isolation" >&2
        return 0
    fi
    local base_commit
    base_commit=$(git -C "$sub" rev-parse origin/main 2>/dev/null || true)
    if [ -z "$base_commit" ]; then
        echo "  [fixture] WARNING: no origin/main in .opencode submodule — skipping isolation" >&2
        return 0
    fi
    local bare_repo="$wd/../_opencode-isolated-origin.git"
    rm -rf "$bare_repo"
    git init --bare -q "$bare_repo"
    git -C "$sub" push -q "$bare_repo" "origin/main:refs/heads/main" 2>/dev/null || {
        echo "  [fixture] WARNING: could not seed isolated origin with main — skipping isolation" >&2
        return 0
    }
    git -C "$sub" remote set-url origin "$bare_repo"
    git -C "$sub" remote prune origin 2>/dev/null || true
    echo "  [fixture] .opencode submodule origin isolated to local bare repo (only main visible)" >&2
}

# Establish a feature branch and push it to the seeded parent origin so branch pre-work is a
# no-op. The pipeline MANDATES branch pre-work before any filesystem change; a prompt cannot
# override that, and a dirty pre-work state wastes the window. Pre-creating the branch makes
# pre-work pass in seconds. The branch name avoids the word "plan" so the agent does not
# hallucinate that a plan already exists on the branch (observed in SC-2 run -5).
establish_feature_branch() {
    local wd="$1"
    local branch="feature/1364-work"
    if ! git -C "$wd" show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        git -C "$wd" checkout -q -b "$branch" 2>/dev/null || true
    else
        git -C "$wd" checkout -q "$branch" 2>/dev/null || true
    fi
    git -C "$wd" push -q -u origin "$branch" 2>/dev/null || {
        echo "  [fixture] WARNING: could not push feature branch to parent origin" >&2
    }
    echo "  [fixture] feature branch $branch established and pushed to parent origin" >&2
}

# Apply the full set of harness-noise remediations shared by both 1364 for_pr scenarios.
for_pr_apply_common_remediations() {
    local wd="$1"
    remove_legacy_open_closed_dirs "$wd"
    commit_fixture_state "$wd"
    disable_editor_mcp "$wd"
    commit_editor_disable_in_submodule "$wd"
    seed_parent_origin "$wd"
    isolate_submodule_from_feature_branch "$wd"
    establish_feature_branch "$wd"
}
