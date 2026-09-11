#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# RED-phase enforcement test: SC-1 — with-test-home clone+checkout site 1 hard-FAIL gate
#
# Issue: .opencode#2434 — test-framework commit/push/fetch/checkout cycle.
# Spec:   .opencode/.issues/2434/spec.md (SC-1, evidence type: behavioral)
# Plan:   .opencode/.issues/2434/plan.md — Item 1, step 6 (RED)
#
# SC-1: when the local submodule HEAD cannot be checked out (unpushed/uncheckoutable
# SHA), the with-test-home site-1 invocation (--setup clone+checkout path) must exit
# non-zero with a failure message naming the commit+push+fetch remediation, and no
# test home may be produced from the wrong ref. When the HEAD is pushed to remote,
# setup proceeds normally (no false positive).
#
# RED state (today): site 1 carries a WARNING fallback that emits
#   "WARNING: could not checkout local submodule commit <sha> — using remote default branch"
# and lets setup complete with exit 0 on the unpushed-HEAD probe — a degraded run on
# the wrong ref. The assertions below target the DESIRED hard-FAIL behavior, so they
# FAIL today. That non-zero exit IS the RED verdict (RED != FALSE: the probes execute
# the real harness path and observe the failing behavior).
#
# Revision (2026-09-04, BAD_TEST_NEEDS_REVISION): the structural assertion was
# re-scoped from a whole-file grep to the site-1 do_setup() guard block only.
# with-test-home carries a second, identical WARNING fallback at its site-2
# (main-body) invocation path — that site is Item 2a's scope and must remain
# untouched at Item 1 GREEN. A whole-file count would still report 1 after a
# valid Item 1 GREEN, making this test impossible to satisfy without Item 2a.
#
# Fixture: a scratch git repo with one local commit that exists nowhere on the remote
# (unpushable by construction). The probe script is a byte-faithful copy of
# with-test-home with exactly two surgical patches: (a) the PROJECT_DIR walk-up block
# replaced by literal paths so the copy runs from tmp/2434, and (b) the
# LOCAL_SUBMODULE_COMMIT source redirected to the fixture repo. The site-1 guard
# block under test remains byte-identical to the shipped script — the fixture
# substitutes the submodule STATE, not the code under test. The real .opencode
# submodule is never modified.
#
# Control probe: the REAL with-test-home --setup with the current pushed HEAD must
# complete normally (exit 0, no checkout-failure message) — proving the harness is
# healthy and the defect is specific to unpushed HEAD. Control probe is skipped when
# the local submodule HEAD is not confirmed on the remote (precondition invalid).
#
# Artifacts: tmp/2434/artifacts/pipeline-red-revised-*
# Usage:   bash .opencode/tests-v2/test-2434-sc1-site1-hardfail-red.sh
# Exit:    0 = all assertions pass (GREEN state reached)
#          1 = RED state confirmed (expected today)

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WITH_TEST_HOME="$PROJECT_ROOT/.opencode/tests-v2/with-test-home"
SUBMODULE_DIR="$PROJECT_ROOT/.opencode"
WORK_DIR="$PROJECT_ROOT/tmp/2434"
ART_DIR="$WORK_DIR/artifacts"
FIXTURE_DIR="$WORK_DIR/fixture-unpushed-submodule"
PROBE_SCRIPT="$WORK_DIR/with-test-home-site1-probe"
mkdir -p "$ART_DIR"

exec > >(tee "$ART_DIR/pipeline-red-revised-test-output.log") 2> >(tee "$ART_DIR/pipeline-red-revised-test-output.err" >&2)

PASS_COUNT=0
FAIL_COUNT=0
check_pass() {
    echo "  PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}
check_fail() {
    echo "  FAIL: $1 — $2" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo "== SC-1 RED probe: with-test-home site-1 hard-FAIL checkout gate (.opencode#2434) =="

# ---------------------------------------------------------------------------
# Structural assertion: the WARNING fallback must not survive at site 1.
# (SC-1/SC-4b language: no "using remote default branch" degradation.)
#
# Scoping (BAD_TEST_NEEDS_REVISION revision): the grep is confined to the
# do_setup() function body — the site-1 guard block under test. Site 2 (the
# main-body clone+checkout path, Item 2a scope) must not contribute to this
# count; it gets its own assertion at Item 2a. Site 1 = do_setup() spans
# lines 181..330 in the shipped script; a byte-faithful copy keeps that
# span stable, and out-of-range extraction would yield nothing to grep.
# ---------------------------------------------------------------------------
DO_SETUP_START=$(awk '/^do_setup\(\) \{/{print NR; exit}' "$WITH_TEST_HOME")
DO_SETUP_END=$(awk -v s="$DO_SETUP_START" 'NR>s && /^\}$/{print NR; exit}' "$WITH_TEST_HOME")
if [ -z "$DO_SETUP_START" ] || [ -z "$DO_SETUP_END" ]; then
    echo "HARNESS_FAILURE: could not locate do_setup() block in with-test-home" >&2
    exit 1
fi
warn_count=$(sed -n "${DO_SETUP_START},${DO_SETUP_END}p" "$WITH_TEST_HOME" \
    | grep -c "WARNING: could not checkout local submodule commit" || true)
warn_sites_total=$(grep -c "WARNING: could not checkout local submodule commit" "$WITH_TEST_HOME" || true)
echo "  [structural] WARNING-fallback sites in do_setup() (site 1): $warn_count"
echo "  [structural] WARNING-fallback sites in with-test-home (all): $warn_sites_total"
echo "structural_warning_fallback_sites: ${warn_count}" > "$ART_DIR/pipeline-red-revised-structural.txt"
echo "structural_warning_fallback_sites_all: ${warn_sites_total}" >> "$ART_DIR/pipeline-red-revised-structural.txt"
if [ "$warn_count" -eq 0 ]; then
    check_pass "structural: no WARNING fallback text in do_setup() site-1 block"
else
    check_fail "structural: no WARNING fallback text in do_setup() site-1 block" \
        "$warn_count WARNING-fallback site(s) present in do_setup() (must be 0 after Item 1 GREEN); $warn_sites_total in whole file (site 2 belongs to Item 2a)"
fi

# ---------------------------------------------------------------------------
# Fixture repo: one local commit, unpushable by construction (timestamped content
# makes the SHA unique; it exists on no remote).
# ---------------------------------------------------------------------------
rm -rf "$FIXTURE_DIR" "$PROBE_SCRIPT"
mkdir -p "$FIXTURE_DIR"
git init -q "$FIXTURE_DIR"
git -C "$FIXTURE_DIR" config user.email "red-fixture@test.dev"
git -C "$FIXTURE_DIR" config user.name "RED Fixture"
echo "fixture $(date -u +%Y%m%dT%H%M%SZ)" > "$FIXTURE_DIR/fixture.txt"
git -C "$FIXTURE_DIR" add -A
git -C "$FIXTURE_DIR" commit -q -m "fixture: local commit left unpushed (SC-1 RED probe)"
FIXTURE_SHA="$(git -C "$FIXTURE_DIR" rev-parse HEAD)"
echo "  [fixture] unpushed SHA: $FIXTURE_SHA ($FIXTURE_DIR)"

# ---------------------------------------------------------------------------
# Build the probe copy of with-test-home — byte-faithful except:
#   1. SCRIPT_DIR/PROJECT_DIR walk-up block → literal paths (copy runs from tmp/)
#   2. LOCAL_SUBMODULE_COMMIT source → fixture repo (both clone+checkout sites)
# The site-1 guard block under test is untouched.
# ---------------------------------------------------------------------------
python3 - "$WITH_TEST_HOME" "$PROBE_SCRIPT" "$PROJECT_ROOT" "$FIXTURE_DIR" <<'PYEOF'
import sys
src, dst, root, fixture = sys.argv[1:5]
text = open(src).read()
old_block = '''SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"'''
new_block = 'SCRIPT_DIR="%s/.opencode/tests-v2"\nPROJECT_DIR="%s"' % (root, root)
assert old_block in text, "PROJECT_DIR walk-up block not found — with-test-home layout changed"
text = text.replace(old_block, new_block)
old_rev = 'git -C "$PROJECT_DIR/.opencode" rev-parse HEAD'
count = text.count(old_rev)
assert count == 2, "expected exactly 2 submodule rev-parse sites, found %d" % count
text = text.replace(old_rev, 'git -C "%s" rev-parse HEAD' % fixture)
open(dst, "w").write(text)
PYEOF
chmod +x "$PROBE_SCRIPT"

# ---------------------------------------------------------------------------
# Probe A (RED target): unpushed fixture HEAD through the site-1 clone+checkout
# path (--setup mode, no TEST_WORKDIR so the site-1 block executes).
# ---------------------------------------------------------------------------
echo "== Probe A: unpushed fixture HEAD through site-1 clone+checkout path =="
env -u TEST_WORKDIR -u BEHAVIOR_SHARED_HOME bash "$PROBE_SCRIPT" --setup \
    > "$ART_DIR/pipeline-red-revised-probe-unpushed.stdout" \
    2> "$ART_DIR/pipeline-red-revised-probe-unpushed.stderr"
probe_a_rc=$?
echo "$probe_a_rc" > "$ART_DIR/pipeline-red-revised-probe-unpushed.exit"
echo "  [probe A] exit: $probe_a_rc (assertion target: 1)"

if [ "$probe_a_rc" -eq 1 ]; then
    check_pass "probe A: exit 1 on uncheckoutable submodule HEAD"
else
    check_fail "probe A: exit 1 on uncheckoutable HEAD" \
        "observed exit $probe_a_rc — WARNING fallback degrades the run instead of failing"
fi

if grep -qi "commit" "$ART_DIR/pipeline-red-revised-probe-unpushed.stderr" \
    && grep -qi "push" "$ART_DIR/pipeline-red-revised-probe-unpushed.stderr" \
    && grep -qi "fetch" "$ART_DIR/pipeline-red-revised-probe-unpushed.stderr"; then
    check_pass "probe A: failure message names commit+push+fetch remediation"
else
    check_fail "probe A: failure message names commit+push+fetch remediation" \
        "stderr lacks the commit+push+fetch remediation (today: WARNING with no remediation)"
fi

if grep -q "^TEST_HOME=" "$ART_DIR/pipeline-red-revised-probe-unpushed.stderr"; then
    check_fail "probe A: no test home produced from the wrong ref" \
        "stderr carries TEST_HOME= — setup completed on the remote default branch"
else
    check_pass "probe A: no test home produced from the wrong ref"
fi

# Wrong-ref proof: when setup completed despite the unpushed HEAD, record which ref
# the produced test home actually checked out (defect evidence for the auditor).
probe_a_test_home="$(sed -n 's/^TEST_HOME=//p' "$ART_DIR/pipeline-red-revised-probe-unpushed.stderr" | tail -1)"
if [ -n "$probe_a_test_home" ] && [ -d "$probe_a_test_home/project/.opencode/.git" ]; then
    wrong_ref_sha="$(git -C "$probe_a_test_home/project/.opencode" rev-parse HEAD)"
    {
        echo "fixture_sha: $FIXTURE_SHA"
        echo "produced_home: $probe_a_test_home"
        echo "checked_out_sha: $wrong_ref_sha"
        if [ "$wrong_ref_sha" != "$FIXTURE_SHA" ]; then
            echo "verdict: WRONG-REF RUN CONFIRMED — setup ran on $wrong_ref_sha, not the fixture commit under test"
        else
            echo "verdict: fixture SHA was checked out (unexpected — probe precondition changed)"
        fi
    } > "$ART_DIR/pipeline-red-revised-probe-unpushed.wrong-ref-proof"
    echo "  [evidence] wrong-ref proof: $ART_DIR/pipeline-red-revised-probe-unpushed.wrong-ref-proof"
fi

# ---------------------------------------------------------------------------
# Probe B (control): pushed HEAD through the REAL --setup path must complete
# normally. Precondition: local submodule HEAD confirmed on the remote.
# ---------------------------------------------------------------------------
local_head="$(git -C "$SUBMODULE_DIR" rev-parse HEAD)"
submodule_url="$(git -C "$PROJECT_ROOT" config --get submodule..opencode.url 2>/dev/null || true)"
[ -n "$submodule_url" ] || submodule_url="https://github.com/michael-conrad/.opencode.git"
submodule_url="$(echo "$submodule_url" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')"
remote_head="$(git ls-remote "$submodule_url" HEAD 2>/dev/null | cut -f1 | head -1)"

if [ -n "$remote_head" ] && [ "$remote_head" = "$local_head" ]; then
    echo "== Probe B (control): pushed HEAD $local_head through real site-1 path =="
    env -u TEST_WORKDIR -u BEHAVIOR_SHARED_HOME bash "$WITH_TEST_HOME" --setup \
        > "$ART_DIR/pipeline-red-revised-probe-control.stdout" \
        2> "$ART_DIR/pipeline-red-revised-probe-control.stderr"
    probe_b_rc=$?
    echo "$probe_b_rc" > "$ART_DIR/pipeline-red-revised-probe-control.exit"
    echo "  [probe B] exit: $probe_b_rc (assertion target: 0)"
    if [ "$probe_b_rc" -eq 0 ]; then
        check_pass "control: pushed HEAD completes setup normally (exit 0, no false positive)"
    else
        check_fail "control: pushed HEAD completes setup normally" \
            "observed exit $probe_b_rc — see pipeline-red-revised-probe-control.stderr"
    fi
    if grep -q "could not checkout local submodule commit" "$ART_DIR/pipeline-red-revised-probe-control.stderr"; then
        check_fail "control: no checkout-failure message on pushed HEAD" \
            "checkout-failure message present on the pushed-HEAD run"
    else
        check_pass "control: no checkout-failure message on pushed HEAD"
    fi
else
    probe_b_rc="skipped"
    {
        echo "reason: local submodule HEAD $local_head not confirmed on remote ${remote_head:-<unreachable>}"
        echo "note: control probe requires a pushed HEAD; skipped to avoid a false control failure"
    } > "$ART_DIR/pipeline-red-revised-probe-control.skipped"
    echo "== Probe B SKIPPED: submodule HEAD not confirmed on remote (see pipeline-red-revised-probe-control.skipped) =="
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "== Results =="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "RED state confirmed: SC-1 hard-FAIL gate not implemented — the site-1"
    echo "WARNING fallback degrades uncheckoutable-HEAD runs to exit 0 instead of"
    echo "failing with the commit+push+fetch remediation."
    verdict="RED"
    final_rc=1
else
    echo ""
    echo "GREEN: all SC-1 assertions pass."
    verdict="GREEN"
    final_rc=0
fi

{
    echo "test: SC-1 with-test-home site-1 hard-FAIL checkout gate (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-1, behavioral)"
    echo "plan_item: Item 1 step 6 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "submodule_head: ${local_head:-unknown}"
    echo "submodule_head_on_remote: $([ "${remote_head:-}" = "${local_head:-x}" ] && echo yes || echo no)"
    echo "fixture_sha: ${FIXTURE_SHA:-n/a}"
    echo "structural_warning_fallback_sites: ${warn_count}"
    echo "structural_warning_fallback_sites_all: ${warn_sites_total}"
    echo "probe_unpushed_exit: ${probe_a_rc}"
    echo "probe_control_exit: ${probe_b_rc}"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
    echo "verdict: $verdict"
    echo "evidence:"
    echo "  - tmp/2434/artifacts/pipeline-red-revised-test-output.log"
    echo "  - tmp/2434/artifacts/pipeline-red-revised-test-output.err"
    echo "  - tmp/2434/artifacts/pipeline-red-revised-structural.txt"
    echo "  - tmp/2434/artifacts/pipeline-red-revised-probe-unpushed.stderr"
    echo "  - tmp/2434/artifacts/pipeline-red-revised-probe-unpushed.wrong-ref-proof (when setup completed)"
    echo "  - tmp/2434/artifacts/pipeline-red-revised-probe-control.stderr"
    echo "  - tmp/2434/artifacts/pipeline-red-revised-exit-code"
} > "$ART_DIR/pipeline-red-revised-summary.yaml"

echo "$final_rc" > "$ART_DIR/pipeline-red-revised-exit-code"
exit "$final_rc"