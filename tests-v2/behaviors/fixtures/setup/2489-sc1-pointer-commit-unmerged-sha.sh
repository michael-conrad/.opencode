#!/usr/bin/env bash
# Per-scenario fixture for .opencode#2489 SC-1 RED behavioral test.
# Sourced by behavior_run() with $1 = attempt workdir.
# Sets up: feature branch, unmerged submodule commit, staged pointer change,
# installed pre-commit hook (from the workdir's own .opencode checkout), and
# records fixture state for post-run evaluation.
set -euo pipefail

WORKDIR="$1"
SCENARIO_BRANCH="feature/2489-sc1-red-pointer-commit"
STATE_FILE="${BEHAVIOR_LOG_DIR:?}/${SCENARIO_NAME:?}/fixture-state.env"

cd "$WORKDIR"

# Feature branch off the init commit (off-trunk so Gate 2, not Gate 1, is isolated).
git checkout -q -b "$SCENARIO_BRANCH"

# Unmerged submodule commit: created locally in the workdir's .opencode clone,
# never pushed and not reachable from any remote ref — unmerged by construction.
git -C .opencode config user.email "test@test.dev"
git -C .opencode config user.name "Test"
git -C .opencode commit -q --allow-empty -m "test: unmerged submodule commit for 2489 SC-1 RED probe"
UNMERGED_SHA=$(git -C .opencode rev-parse HEAD)

# Stage the pointer change (parent gitlink -> unmerged SHA). NOT committed:
# the model under test performs the commit.
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
UNMERGED_SHA=${UNMERGED_SHA}
EOF
