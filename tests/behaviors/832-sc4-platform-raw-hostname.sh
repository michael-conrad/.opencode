#!/bin/bash
# Behavioral test: 832-sc4-platform-raw-hostname
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# GREEN phase test for .opencode#832 SC-4: Agent reports raw hostname platform
# values (github.com, gitbucket.internal.dev) from multi-platform ## Repo Information.
#
# Behavioral: multi-platform fixture repo, agent asked about SCM platforms.
# Must read from session context and report actual hostnames.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="832-sc4-platform-raw-hostname"
SCENARIO_PROMPT="What SCM platforms are in use in this workspace?"

# The isolated test repo needs a second fake gitbucket repo alongside .opencode.
# The test harness's behavior_run creates the workdir. We need to inject the
# fixture into it. We set BEHAVIOR_FIXTURE_GITBUCKET to signal the test
# to copy the gitbucket fixture.

FIXTURE_DIR="$SCRIPT_DIR/fixtures/gitbucket-fake-repo"

# The behavior_run creates an isolated test repo. We need to inject the
# gitbucket fixture into that workdir after behavior_run creates it.
# We'll override the workdir by passing it explicitly.
# First create the isolated repo ourselves with the fixture injected.

WORKDIR=$(mktemp -d "$PROJECT_DIR/tmp/behavior-isolated-XXXXXX")
git init -q "$WORKDIR"
git -C "$WORKDIR" config user.email "test@test.dev"
git -C "$WORKDIR" config user.name "Test"
git -C "$WORKDIR" remote add origin git@github.com:michael-conrad/opencode-config.git

# Inject gitbucket fixture as a subdirectory with its own git repo
cp -r "$FIXTURE_DIR" "$WORKDIR/gitbucket-fake-repo"
git -C "$WORKDIR/gitbucket-fake-repo" init -q
git -C "$WORKDIR/gitbucket-fake-repo" config user.email "test@test.dev"
git -C "$WORKDIR/gitbucket-fake-repo" config user.name "Test"
git -C "$WORKDIR/gitbucket-fake-repo" remote add origin git@gitbucket.internal.dev:my-org/some-repo.git
git -C "$WORKDIR/gitbucket-fake-repo" add -A 2>/dev/null || true
git -C "$WORKDIR/gitbucket-fake-repo" commit -q --allow-empty -m "init"

# Let behavior_run use this workdir (pass as 4th arg)
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "$BEHAVIOR_MODEL" "$WORKDIR"

# Clean up
rm -rf "$WORKDIR"

exit 0
