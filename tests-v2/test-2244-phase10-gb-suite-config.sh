#!/bin/bash
# Content-Verification Enforcement Test: Phase 10 — Executor GB_* Suite + gb config.toml Seeding (Concern C10)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase10-gb-suite-config — Concern C10, `.opencode/tests-v2/with-test-home`
#        (GB_ENV_ARGS, env -i invocation, do_setup/test-home provisioning) and
#        `.opencode/tests-v2/behaviors/helpers.sh` (__ensure_gitbucket GB_REPO/GB_PROTOCOL
#        export + token scoping).
#
# SCs covered: SC19, SC20.
#
# This is a RED-phase test. The GREEN implementation has NOT been applied yet, so the
# assertions below are expected to FAIL (non-zero exit). The GREEN phase will:
#   1. Extend GB_ENV_ARGS in with-test-home to carry the full GB_* suite
#      (GB_TOKEN, GB_HOST, GITBUCKET_PORT, GB_REPO, GB_PROTOCOL) into the isolated
#      env -i subshell when BEHAVIOR_NEEDS_REMOTE=1; the test-env constants
#      (GB_HOST, GB_REPO, GB_PROTOCOL, GITBUCKET_PORT) always set to the harness's
#      constants, GB_TOKEN scoped to the provisioned test instance only
#                                                                       -> SC19
#   2. Add a do_setup/test-home provisioning block in with-test-home that seeds
#      $TEST_HOME/.config/gb/config.toml with the harness's default_host constant
#      and the host token (token present only when GitBucket is provisioned),
#      mirroring the fixture in `.opencode/.issues/2059/spec.md`          -> SC20
#   3. Extend __ensure_gitbucket() in helpers.sh to export GB_REPO and GB_PROTOCOL
#      for the provisioned test instance and scope GB_TOKEN to it          -> SC19
#
# Evidence types: SC19/SC20 are structural — content-verification assertions on
# `.opencode/tests-v2/with-test-home` and `.opencode/tests-v2/behaviors/helpers.sh`.
#
# RED state: Currently GB_ENV_ARGS in with-test-home carries only GB_TOKEN, GB_HOST,
# GITBUCKET_PORT (missing GB_REPO, GB_PROTOCOL), and do_setup/test-home provisioning
# has NO gb config.toml seeding. __ensure_gitbucket() in helpers.sh exports only
# GB_TOKEN, GB_HOST, GITBUCKET_PORT (not GB_REPO, GB_PROTOCOL). Hence RED.
#
# Usage: bash .opencode/tests-v2/test-2244-phase10-gb-suite-config.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

WITH_TEST_HOME="$PROJECT_DIR/.opencode/tests-v2/with-test-home"
HELPERS_SH="$PROJECT_DIR/.opencode/tests-v2/behaviors/helpers.sh"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# grep_assert_present: pattern must appear at least once in the file.
grep_assert_present() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -qF "$pattern" "$file" 2>/dev/null; then
        check_pass "$label"
    else
        check_fail "$label" "pattern '$pattern' not found in $file"
    fi
}

# grep_assert_absent: pattern must NOT appear in the file.
grep_assert_absent() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -qE "$pattern" "$file" 2>/dev/null; then
        check_fail "$label" "forbidden pattern '$pattern' found in $file"
    else
        check_pass "$label"
    fi
}

echo ""
echo "=== Phase 10 — Executor GB_* Suite + gb config.toml Seeding (Spec #2244, Concern C10) ==="
echo ""
echo "Target files: $WITH_TEST_HOME"
echo "              $HELPERS_SH"
echo ""

# ---------------------------------------------------------------------------
# SC19 (structural): Full GB_* env suite propagation.
#
# When BEHAVIOR_NEEDS_REMOTE=1 provisions a test GitBucket, with-test-home SHALL
# propagate the full GB_* env suite — GB_TOKEN, GB_HOST, GITBUCKET_PORT, GB_REPO,
# GB_PROTOCOL — into the isolated test environment via GB_ENV_ARGS. The test-env
# constants (GB_HOST, GB_REPO, GB_PROTOCOL, GITBUCKET_PORT) SHALL be set to the
# harness's test-env constant values always (whether or not GitBucket is
# provisioned); GB_TOKEN SHALL be set to the provisioned test instance's value only
# when BEHAVIOR_NEEDS_REMOTE=1, and SHALL be absent/empty otherwise. No value is
# ever sourced from the parent env.
#
# RED-now: GB_ENV_ARGS carries only GB_TOKEN, GB_HOST, GITBUCKET_PORT — missing
# GB_REPO and GB_PROTOCOL. The test-env constants are not all present in the
# GB_ENV_ARGS array. __ensure_gitbucket() does not export GB_REPO/GB_PROTOCOL.
# ---------------------------------------------------------------------------
echo "--- SC19: full GB_* env suite propagated via GB_ENV_ARGS ---"

# RED-now: GB_ENV_ARGS must carry all five variables. GB_REPO and GB_PROTOCOL are
# currently absent from the GB_ENV_ARGS array in with-test-home.
grep_assert_present \
    "SC19: GB_ENV_ARGS carries GB_TOKEN" \
    "$WITH_TEST_HOME" \
    "GB_TOKEN"
grep_assert_present \
    "SC19: GB_ENV_ARGS carries GB_HOST" \
    "$WITH_TEST_HOME" \
    "GB_HOST"
grep_assert_present \
    "SC19: GB_ENV_ARGS carries GITBUCKET_PORT" \
    "$WITH_TEST_HOME" \
    "GITBUCKET_PORT"
grep_assert_present \
    "SC19: GB_ENV_ARGS carries GB_REPO" \
    "$WITH_TEST_HOME" \
    "GB_REPO"
grep_assert_present \
    "SC19: GB_ENV_ARGS carries GB_PROTOCOL" \
    "$WITH_TEST_HOME" \
    "GB_PROTOCOL"

# RED-now: the GB_ENV_ARGS array must be populated with the full suite only when
# BEHAVIOR_NEEDS_REMOTE=1 (GB_TOKEN scoped to the provisioned test instance).
grep_assert_present \
    "SC19: GB_ENV_ARGS populated under BEHAVIOR_NEEDS_REMOTE=1 guard" \
    "$WITH_TEST_HOME" \
    'BEHAVIOR_NEEDS_REMOTE:-0}" = "1"'

# RED-now: the test-env constants (GB_HOST, GB_REPO, GB_PROTOCOL, GITBUCKET_PORT)
# must be set to the harness's constant values always. GB_REPO and GB_PROTOCOL are
# currently absent from the env -i invocation.
grep_assert_present \
    "SC19: env -i invocation carries GB_REPO" \
    "$WITH_TEST_HOME" \
    "GB_REPO"
grep_assert_present \
    "SC19: env -i invocation carries GB_PROTOCOL" \
    "$WITH_TEST_HOME" \
    "GB_PROTOCOL"

# SC19 helpers-side: __ensure_gitbucket() MUST export GB_REPO and GB_PROTOCOL for
# the provisioned test instance. RED-now: only GB_TOKEN, GB_HOST, GITBUCKET_PORT
# are exported.
grep_assert_present \
    "SC19: __ensure_gitbucket exports GB_REPO for the test instance" \
    "$HELPERS_SH" \
    "GB_REPO"
grep_assert_present \
    "SC19: __ensure_gitbucket exports GB_PROTOCOL for the test instance" \
    "$HELPERS_SH" \
    "GB_PROTOCOL"

# SC19 invariant: no parent-sourced GB_* value ever leaks into the isolated env.
# This is GREEN-now (Phase 1/2): the env -i allowlist and set-env.sh have no
# parent-sourced GB_* passthrough. These PASS now and MUST stay absent.
grep_assert_absent \
    "SC19: allowlist has no parent-sourced GB_REPO passthrough" \
    "$WITH_TEST_HOME" \
    'GB_REPO=\${GB_REPO'
grep_assert_absent \
    "SC19: allowlist has no parent-sourced GB_PROTOCOL passthrough" \
    "$WITH_TEST_HOME" \
    'GB_PROTOCOL=\${GB_PROTOCOL'

# ---------------------------------------------------------------------------
# SC20 (structural): Pre-fabricated gb config.toml seeding.
#
# When BEHAVIOR_NEEDS_REMOTE=1 provisions a test GitBucket, the test home SHALL seed
# a pre-fabricated gb config.toml at $TEST_HOME/.config/gb/config.toml with
# default_host and host token matching the provisioned test GitBucket instance, so
# gb authenticates deterministically without gb auth login. The config SHALL seed
# the harness's test-env default_host constant; the host token SHALL be present only
# when a test GitBucket was provisioned (BEHAVIOR_NEEDS_REMOTE=1).
#
# RED-now: do_setup/test-home provisioning in with-test-home has NO gb config.toml
# seeding block. There is no reference to $TEST_HOME/.config/gb/config.toml, no
# default_host constant, and no host-token seeding.
# ---------------------------------------------------------------------------
echo "--- SC20: test home seeds pre-fabricated gb config.toml ---"

# RED-now: the test-home provisioning must write $TEST_HOME/.config/gb/config.toml.
grep_assert_present \
    "SC20: test-home provisioning seeds gb config.toml path" \
    "$WITH_TEST_HOME" \
    ".config/gb/config.toml"

# RED-now: the seeded config must carry the harness's default_host constant.
grep_assert_present \
    "SC20: seeded config carries default_host constant" \
    "$WITH_TEST_HOME" \
    "default_host"

# RED-now: the host token must be seeded only when GitBucket is provisioned
# (BEHAVIOR_NEEDS_REMOTE=1 guard around the token seeding).
grep_assert_present \
    "SC20: host token seeded under BEHAVIOR_NEEDS_REMOTE=1 guard" \
    "$WITH_TEST_HOME" \
    'BEHAVIOR_NEEDS_REMOTE:-0}" = "1"'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 10 (executor GB_* suite + gb config.toml seeding) not yet implemented."
    echo "GB_ENV_ARGS in with-test-home carries only GB_TOKEN, GB_HOST, GITBUCKET_PORT —"
    echo "missing GB_REPO and GB_PROTOCOL — and __ensure_gitbucket() in helpers.sh does not"
    echo "export GB_REPO/GB_PROTOCOL. do_setup/test-home provisioning has no gb config.toml"
    echo 'seeding block, so $TEST_HOME/.config/gb/config.toml is never written.'
    echo ""
    exit 1
fi
exit 0
