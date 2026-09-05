#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# RED-phase enforcement test: SC-2a — with-test-home clone+checkout site 2 hard-FAIL gate
#
# Issue: .opencode#2434 — test-framework commit/push/fetch/checkout cycle.
# Spec:   .opencode/.issues/2434/spec.md (SC-2a, evidence type: behavioral)
# Plan:   .opencode/.issues/2434/plan.md — Item 2a, step 12 (RED)
#
# SC-2a: when the local submodule HEAD cannot be checked out (unpushed/uncheckoutable
# SHA), the with-test-home site-2 invocation (main-body clone+checkout path, reached by
# running a command without --setup and without TEST_WORKDIR) must exit non-zero with a
# failure message naming the commit+push+fetch remediation, and no test home may be
# produced from the wrong ref. When the HEAD is pushed to remote, the main-body path
# proceeds normally (no false positive).
#
# Site map (post SC-1 GREEN, commit c84a3d81):
#   site 1 = do_setup() (--setup path)           — HARD FAIL landed (SC-1)
#   site 2 = main body (lines ~395..423, the
#            else branch of the TEST_WORKDIR
#            guard, reached by `with-test-home
#            <command>`)                         — WARNING fallback survives (SC-2a scope)
#
# RED state (today): site 2 carries a WARNING fallback that emits
#   "WARNING: could not checkout local submodule commit <sha> — using remote default branch"
# and lets the command run with exit 0 on the unpushed-HEAD probe — a degraded run on
# the wrong ref. The assertions below target the DESIRED hard-FAIL behavior, so they
# FAIL today. That non-zero exit IS the RED verdict (RED != FALSE: the probes execute
# the real harness path and observe the failing behavior).
#
# Test structure reused from test-2434-sc1-site1-hardfail-red.sh (Item 1, SC-1) with
# the invocation path retargeted: probes invoke the harness as a real command run
# (`--keep <cmd>`), NOT `--setup`, so the main-body clone+checkout site executes.
#
# Fixture: a scratch git repo with one local commit that exists nowhere on the remote
# (unpushable by construction). The probe script is a byte-faithful copy of
# with-test-home with exactly two surgical patches: (a) the PROJECT_DIR walk-up block
# replaced by literal paths so the copy runs from tmp/2434, and (b) the
# LOCAL_SUBMODULE_COMMIT source redirected to the fixture repo. The site-2 guard
# block under test remains byte-identical to the shipped script — the fixture
# substitutes the submodule STATE, not the code under test. The real .opencode
# submodule is never modified.
#
# Control probe: the REAL with-test-home main-body path with the current pushed HEAD
# must complete normally (exit 0, no checkout-failure message) — proving the harness
# is healthy and the defect is specific to unpushed HEAD. Control probe is skipped
# when the local submodule HEAD is not confirmed on any remote ref (precondition
# invalid).
#
# Artifacts: tmp/2434/artifacts/pipeline-red-sc2a-*
# Usage:   bash .opencode/tests-v2/test-2434-sc2a-site2-hardfail-red.sh
# Exit:    0 = all assertions pass (GREEN state reached)
#          1 = RED state confirmed (expected today)

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WITH_TEST_HOME="$PROJECT_ROOT/.opencode/tests-v2/with-test-home"
SUBMODULE_DIR="$PROJECT_ROOT/.opencode"
WORK_DIR="$PROJECT_ROOT/tmp/2434"
ART_DIR="$WORK_DIR/artifacts"
FIXTURE_DIR="$WORK_DIR/fixture-unpushed-submodule-sc2a"
PROBE_SCRIPT="$WORK_DIR/with-test-home-site2-probe"
mkdir -p "$ART_DIR"

exec > >(tee "$ART_DIR/pipeline-red-sc2a-test-output.log") 2> >(tee "$ART_DIR/pipeline-red-sc2a-test-output.err" >&2)

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

echo "== SC-2a RED probe: with-test-home site-2 hard-FAIL checkout gate (.opencode#2434) =="

# ---------------------------------------------------------------------------
# Structural assertion: the WARNING fallback must not survive at site 2.
# (SC-1/SC-4b language: no "using remote default branch" degradation.)
#
# Scoping: the grep is confined to the site-2 main-body clone+checkout block —
# the else branch of the TEST_WORKDIR guard in the main body (the invocation
# path under test). Site 1 (do_setup, --setup path) was Item 1's scope and is
# already fixed; it must not contribute to this count. Site-1 = do_setup()
# spans its own lines; the site-2 guard block is located dynamically: the LAST
# occurrence of the TEST_WORKDIR guard (main body follows do_setup in source
# order), then the column-0 else/fi pair enclosing the clone+checkout block.
# ---------------------------------------------------------------------------
GUARD_LINE=$(grep -n 'if \[ -n "${TEST_WORKDIR:-}" \] && \[ -d "$TEST_WORKDIR" \]; then' "$WITH_TEST_HOME" | tail -1 | cut -d: -f1)
SITE2_START=$(awk -v g="$GUARD_LINE" 'NR>g && /^else$/{print NR; exit}' "$WITH_TEST_HOME")
SITE2_END=$(awk -v s="$SITE2_START" 'NR>s && /^fi$/{print NR; exit}' "$WITH_TEST_HOME")
if [ -z "$GUARD_LINE" ] || [ -z "$SITE2_START" ] || [ -z "$SITE2_END" ]; then
    echo "HARNESS_FAILURE: could not locate site-2 main-body clone+checkout block in with-test-home" >&2
    exit 1
fi
warn_count=$(sed -n "${SITE2_START},${SITE2_END}p" "$WITH_TEST_HOME" \
    | grep -c "WARNING: could not checkout local submodule commit" || true)
warn_sites_total=$(grep -c "WARNING: could not checkout local submodule commit" "$WITH_TEST_HOME" || true)
echo "  [structural] site-2 block lines: $SITE2_START..$SITE2_END"
echo "  [structural] WARNING-fallback sites in site-2 main-body block: $warn_count"
echo "  [structural] WARNING-fallback sites in with-test-home (all): $warn_sites_total"
echo "structural_warning_fallback_sites_site2: ${warn_count}" > "$ART_DIR/pipeline-red-sc2a-structural.txt"
echo "structural_warning_fallback_sites_all: ${warn_sites_total}" >> "$ART_DIR/pipeline-red-sc2a-structural.txt"
echo "structural_site2_block_lines: ${SITE2_START}..${SITE2_END}" >> "$ART_DIR/pipeline-red-sc2a-structural.txt"
if [ "$warn_count" -eq 0 ]; then
    check_pass "structural: no WARNING fallback text in site-2 main-body block"
else
    check_fail "structural: no WARNING fallback text in site-2 main-body block" \
        "$warn_count WARNING-fallback site(s) present in site-2 block (must be 0 after Item 2a GREEN); $warn_sites_total in whole file (site 1 already fixed at Item 1)"
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
git -C "$FIXTURE_DIR" commit -q -m "fixture: local commit left unpushed (SC-2a RED probe)"
FIXTURE_SHA="$(git -C "$FIXTURE_DIR" rev-parse HEAD)"
echo "  [fixture] unpushed SHA: $FIXTURE_SHA ($FIXTURE_DIR)"

# ---------------------------------------------------------------------------
# Build the probe copy of with-test-home — byte-faithful except:
#   1. SCRIPT_DIR/PROJECT_DIR walk-up block → literal paths (copy runs from tmp/)
#   2. LOCAL_SUBMODULE_COMMIT source → fixture repo (both clone+checkout sites)
# The site-2 guard block under test is untouched.
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
# Probe A (RED target): unpushed fixture HEAD through the site-2 main-body
# clone+checkout path — a real command invocation (--keep /bin/true, no
# --setup, no TEST_WORKDIR) so the site-2 block executes.
# ---------------------------------------------------------------------------
echo "== Probe A: unpushed fixture HEAD through site-2 main-body clone+checkout path =="
env -u TEST_WORKDIR -u BEHAVIOR_SHARED_HOME bash "$PROBE_SCRIPT" --keep /bin/true \
    > "$ART_DIR/pipeline-red-sc2a-probe-unpushed.stdout" \
    2> "$ART_DIR/pipeline-red-sc2a-probe-unpushed.stderr"
probe_a_rc=$?
echo "$probe_a_rc" > "$ART_DIR/pipeline-red-sc2a-probe-unpushed.exit"
echo "  [probe A] exit: $probe_a_rc (assertion target: 1)"

if [ "$probe_a_rc" -eq 1 ]; then
    check_pass "probe A: exit 1 on uncheckoutable submodule HEAD (site-2 path)"
else
    check_fail "probe A: exit 1 on uncheckoutable HEAD (site-2 path)" \
        "observed exit $probe_a_rc — site-2 WARNING fallback degrades the run instead of failing"
fi

if grep -qi "commit" "$ART_DIR/pipeline-red-sc2a-probe-unpushed.stderr" \
    && grep -qi "push" "$ART_DIR/pipeline-red-sc2a-probe-unpushed.stderr" \
    && grep -qi "fetch" "$ART_DIR/pipeline-red-sc2a-probe-unpushed.stderr"; then
    check_pass "probe A: failure message names commit+push+fetch remediation"
else
    check_fail "probe A: failure message names commit+push+fetch remediation" \
        "stderr lacks the commit+push+fetch remediation (today: WARNING with no remediation)"
fi

if grep -q "^TEST_HOME=" "$ART_DIR/pipeline-red-sc2a-probe-unpushed.stderr"; then
    check_fail "probe A: no test home produced from the wrong ref" \
        "stderr carries TEST_HOME= — the main-body path completed on the remote default branch"
else
    check_pass "probe A: no test home produced from the wrong ref"
fi

# Wrong-ref proof: when the main-body path completed despite the unpushed HEAD, record
# which ref the produced test home actually checked out (defect evidence for the auditor).
probe_a_test_home="$(sed -n 's/^TEST_HOME=//p' "$ART_DIR/pipeline-red-sc2a-probe-unpushed.stderr" | tail -1)"
if [ -n "$probe_a_test_home" ] && [ -d "$probe_a_test_home/project/.opencode/.git" ]; then
    wrong_ref_sha="$(git -C "$probe_a_test_home/project/.opencode" rev-parse HEAD)"
    {
        echo "fixture_sha: $FIXTURE_SHA"
        echo "produced_home: $probe_a_test_home"
        echo "checked_out_sha: $wrong_ref_sha"
        if [ "$wrong_ref_sha" != "$FIXTURE_SHA" ]; then
            echo "verdict: WRONG-REF RUN CONFIRMED — main-body path ran on $wrong_ref_sha, not the fixture commit under test"
        else
            echo "verdict: fixture SHA was checked out (unexpected — probe precondition changed)"
        fi
    } > "$ART_DIR/pipeline-red-sc2a-probe-unpushed.wrong-ref-proof"
    echo "  [evidence] wrong-ref proof: $ART_DIR/pipeline-red-sc2a-probe-unpushed.wrong-ref-proof"
fi

# ---------------------------------------------------------------------------
# Probe B (control): pushed HEAD through the REAL main-body path must complete
# normally. Precondition: local submodule HEAD confirmed on some remote ref.
# ---------------------------------------------------------------------------
local_head="$(git -C "$SUBMODULE_DIR" rev-parse HEAD)"
submodule_url="$(git -C "$PROJECT_ROOT" config --get submodule..opencode.url 2>/dev/null || true)"
[ -n "$submodule_url" ] || submodule_url="https://github.com/michael-conrad/.opencode.git"
submodule_url="$(echo "$submodule_url" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')"
remote_has_head="$(git ls-remote "$submodule_url" 2>/dev/null | grep -ci "$local_head" || true)"

if [ -n "$remote_has_head" ] && [ "$remote_has_head" -ge 1 ]; then
    echo "== Probe B (control): pushed HEAD $local_head through real site-2 main-body path =="
    env -u TEST_WORKDIR -u BEHAVIOR_SHARED_HOME bash "$WITH_TEST_HOME" --keep /bin/true \
        > "$ART_DIR/pipeline-red-sc2a-probe-control.stdout" \
        2> "$ART_DIR/pipeline-red-sc2a-probe-control.stderr"
    probe_b_rc=$?
    echo "$probe_b_rc" > "$ART_DIR/pipeline-red-sc2a-probe-control.exit"
    echo "  [probe B] exit: $probe_b_rc (assertion target: 0)"
    if [ "$probe_b_rc" -eq 0 ]; then
        check_pass "control: pushed HEAD completes main-body path normally (exit 0, no false positive)"
    else
        check_fail "control: pushed HEAD completes main-body path normally" \
            "observed exit $probe_b_rc — see pipeline-red-sc2a-probe-control.stderr"
    fi
    if grep -q "could not checkout local submodule commit" "$ART_DIR/pipeline-red-sc2a-probe-control.stderr"; then
        check_fail "control: no checkout-failure message on pushed HEAD" \
            "checkout-failure message present on the pushed-HEAD run"
    else
        check_pass "control: no checkout-failure message on pushed HEAD"
    fi
else
    probe_b_rc="skipped"
    {
        echo "reason: local submodule HEAD $local_head not confirmed on any remote ref at ${submodule_url}"
        echo "note: control probe requires a pushed HEAD; skipped to avoid a false control failure"
    } > "$ART_DIR/pipeline-red-sc2a-probe-control.skipped"
    echo "== Probe B SKIPPED: submodule HEAD not confirmed on remote (see pipeline-red-sc2a-probe-control.skipped) =="
fi

# ---------------------------------------------------------------------------
# Cleanup: remove the two disposable test homes created by the probes (recorded
# from stderr). Throwaway tmp state — precise removal only, no --clean-all.
# ---------------------------------------------------------------------------
for home in \
    "$(sed -n 's/^TEST_HOME=//p' "$ART_DIR/pipeline-red-sc2a-probe-unpushed.stderr" | tail -1)" \
    "$(sed -n 's/^TEST_HOME=//p' "$ART_DIR/pipeline-red-sc2a-probe-control.stderr" | tail -1)"; do
    if [ -n "$home" ] && [ -d "$home" ] && case "$home" in "$PROJECT_ROOT"/tmp/test-home-*) true ;; *) false ;; esac; then
        rm -rf "$home"
        echo "  [cleanup] removed probe test home: $home"
    fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "== Results =="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "RED state confirmed: SC-2a hard-FAIL gate not implemented — the site-2"
    echo "main-body WARNING fallback degrades uncheckoutable-HEAD runs to exit 0"
    echo "instead of failing with the commit+push+fetch remediation."
    verdict="RED"
    final_rc=1
else
    echo ""
    echo "GREEN: all SC-2a assertions pass."
    verdict="GREEN"
    final_rc=0
fi

{
    echo "test: SC-2a with-test-home site-2 hard-FAIL checkout gate (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-2a, behavioral)"
    echo "plan_item: Item 2a step 12 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "submodule_head: ${local_head:-unknown}"
    echo "submodule_head_on_remote: $([ "${remote_has_head:-0}" -ge 1 ] 2>/dev/null && echo yes || echo no)"
    echo "fixture_sha: ${FIXTURE_SHA:-n/a}"
    echo "structural_warning_fallback_sites_site2: ${warn_count}"
    echo "structural_warning_fallback_sites_all: ${warn_sites_total}"
    echo "probe_unpushed_exit: ${probe_a_rc}"
    echo "probe_control_exit: ${probe_b_rc}"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
    echo "verdict: $verdict"
    echo "evidence:"
    echo "  - tmp/2434/artifacts/pipeline-red-sc2a-test-output.log"
    echo "  - tmp/2434/artifacts/pipeline-red-sc2a-test-output.err"
    echo "  - tmp/2434/artifacts/pipeline-red-sc2a-structural.txt"
    echo "  - tmp/2434/artifacts/pipeline-red-sc2a-probe-unpushed.stderr"
    echo "  - tmp/2434/artifacts/pipeline-red-sc2a-probe-unpushed.wrong-ref-proof (when main-body path completed)"
    echo "  - tmp/2434/artifacts/pipeline-red-sc2a-probe-control.stderr"
    echo "  - tmp/2434/artifacts/pipeline-red-sc2a-exit-code"
} > "$ART_DIR/pipeline-red-sc2a-summary.yaml"

echo "$final_rc" > "$ART_DIR/pipeline-red-sc2a-exit-code"
exit "$final_rc"