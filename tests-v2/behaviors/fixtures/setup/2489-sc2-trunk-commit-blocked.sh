#!/usr/bin/env bash
# Per-scenario fixture for .opencode#2489 SC-2 RED behavioral test (plan Item 10).
# Sourced by behavior_run() with $1 = attempt workdir.
# Sets up: stay on the trunk branch (renamed to main — Gate 1 resolves the
# trunk as 'main' when no remote HEAD branch is discoverable), unmerged
# submodule commit, staged pointer change, installed pre-commit hook (from the
# workdir's own .opencode checkout), and records fixture state for post-run
# evaluation. The commit attempt itself is the model's task — the pre-commit
# hook Gate 1 must block it (exit 1) both pre- and post-Gate-2-removal.
set -euo pipefail

WORKDIR="$1"
SCENARIO_BRANCH="main"
STATE_FILE="${BEHAVIOR_LOG_DIR:?}/${SCENARIO_NAME:?}/fixture-state.env"

cd "$WORKDIR"

# Trunk branch: rename the init branch to main so Gate 1's trunk check
# (CURRENT_BRANCH = TRUNK_BRANCH, fallback 'main' with no discoverable remote
# HEAD) fires on this branch.
git branch -M main
git checkout -q main 2>/dev/null || true

# Pre-attempt gitlink value — the assertion gate: the trunk commit must NOT
# land, so this value must be unchanged post-run.
SC2_INIT_PTR=$(git rev-parse HEAD:.opencode)

# Unmerged submodule commit: created locally in the workdir's .opencode clone,
# never pushed and not reachable from any remote ref — unmerged by construction.
git -C .opencode config user.email "test@test.dev"
git -C .opencode config user.name "Test"
git -C .opencode commit -q --allow-empty -m "test: unmerged submodule commit for 2489 SC-2 trunk-block probe"
UNMERGED_SHA=$(git -C .opencode rev-parse HEAD)

# Stage the pointer change (parent gitlink -> unmerged SHA). NOT committed:
# the model under test performs the commit (which Gate 1 must block).
git add .opencode

# Install the pre-commit hook from the workdir's own .opencode checkout
# (same content the session-enforcement installer deploys at this submodule SHA).
mkdir -p .git/hooks
cp .opencode/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Record fixture state for post-run evaluation.
mkdir -p "$(dirname "$STATE_FILE")"
cat > "$STATE_FILE" <<EOF
WORKDIR=${WORKDIR}
SCENARIO_BRANCH=${SCENARIO_BRANCH}
SC2_INIT_PTR=${SC2_INIT_PTR}
UNMERGED_SHA=${UNMERGED_SHA}
EOF
