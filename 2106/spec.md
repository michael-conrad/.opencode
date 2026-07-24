> **Migrated from michael-conrad/opencode-config#309** — this issue concerns `.opencode/` submodule content and was refiled to the correct repository.

## Intent and Executive Summary

This spec fixes three independent isolation failures in the opencode test framework that cause all test runs to write to the production SQLite database instead of an isolated test home. The fix ensures `with-test-home` actually uses `env -i`, moves the `opencode models` call in `helpers.sh` from source-time to lazy-init, and rewrites two bypass scripts to use the isolation wrapper. Cost is measured in defect-discovery-latency: each isolation failure that ships undetected creates a death spiral of contaminated test data, false CI results, and manual DB cleanup that costs 1000× more than the bounded minutes of running the fix.

## Requirements

| ID | Requirement |
|----|-------------|
| R-1 | `with-test-home` execution block uses `env -i` with explicit allowlist |
| R-2 | `with-test-home` sets `HOME` to test home in execution block |
| R-3 | `with-test-home` copies `.tools/opencode/opencode` to `$TEST_HOME/bin/opencode` |
| R-4 | `with-test-home` prepends `$TEST_HOME/bin` to PATH |
| R-5 | `helpers.sh` does NOT run `opencode models` at source time |
| R-6 | `with-test-home` and `helpers.sh` use bare `"opencode"` not absolute path |
| R-7 | `secret-redaction/SC-2.sh` uses `behavior_run()` from helpers.sh |
| R-8 | `test-verb-variant.sh` does NOT use `snap run` |
| R-9 | `test-verb-variant.sh` uses `with-test-home` wrapper |
| R-10 | `opencode db path` under `with-test-home` contains `$TEST_HOME`, not `~/.local/share` |
| R-11 | Production DB session count is unchanged after a `with-test-home` test run |
| R-12 | `with-test-home` prints diagnostic `[test-env]` lines before running command |

## Problem

The test framework is supposed to isolate opencode's SQLite database into a temporary test home. It does not. Three independent isolation failures cause all test runs to write to the production DB at `~/.local/share/opencode/opencode.db` (9.4 GB, 14,668 sessions, 8 test-contaminated projects).

## Root Causes

### 1. `with-test-home` doesn't use `env -i` — the comment is a lie

Line 25 claims `"uses env -i with ONLY these vars"` but the execution block (lines 319-331) just exports variables in a subshell. No `env -i` anywhere in the execution path. The parent environment leaks through, and `HOME` is never set to the test home in the execution block.

*Provenance: Verified by reading `.opencode/tests-v2/with-test-home` lines 25 and 319-331.*

### 2. `helpers.sh` runs `opencode models` against production DB at source time

Line 397 executes `opencode models` unconditionally at source time — no isolation, no `with-test-home`, no XDG redirect. Every test script that sources `helpers.sh` (16 scripts) triggers this against the production DB.

*Provenance: Verified by reading `.opencode/tests-v2/behaviors/helpers.sh` line 397.*

### 3. The standalone binary is never copied to `$TEST_HOME/bin`

The AGENTS.md mandates:
1. Cache at `.tools/opencode/opencode` ✅ (exists, 178 MB)
2. Copy to `$TEST_HOME/bin/opencode` ❌ **never happens**
3. Prepend `$TEST_HOME/bin` to PATH ❌ **never happens**

`with-test-home` uses `command -v opencode` which resolves to `/snap/bin/opencode` — the snap binary that the framework explicitly forbids.

*Provenance: Verified by reading `.opencode/tests-v2/with-test-home` — no `cp` to `$TEST_HOME/bin` found. Verified `.tools/opencode/opencode` exists via `ls`.*

### 4. Both `with-test-home` and `helpers.sh` resolve opencode to an absolute path

Even when the standalone binary was available, both scripts stored `OPENCODE_CMD` as an absolute path (e.g., `/snap/bin/opencode` or `.tools/opencode/opencode`). The `env -i` block then ran that absolute path directly — PATH was never consulted, so `$TEST_HOME/bin/opencode` was dead code.

*Provenance: Verified by grep for `OPENCODE_CMD=` in both scripts.*

### 5. Two scripts bypass `with-test-home` entirely

- `.opencode/tests-v2/behaviors/secret-redaction/SC-2.sh` — direct `opencode run` with no isolation
- `.opencode/tests-v2/behaviors/test-verb-variant.sh` — uses `snap run opencode`

*Provenance: Verified by reading both scripts — no `with-test-home` wrapper found.*

## Edge Cases and Error Recovery

### Standalone binary missing at `.tools/opencode/opencode`
- **Failure mode:** `cp` fails silently or `with-test-home` falls back to snap binary
- **Recovery:** `with-test-home` MUST check binary existence before copy and emit a `[test-env]` warning if the standalone binary is absent. If absent, the test MUST fail with a clear error message rather than silently using the snap binary.

### `env -i` execution failure
- **Failure mode:** `env -i` itself fails (e.g., `-C` flag unsupported on older systems)
- **Recovery:** The execution block MUST check the exit code of `env -i` and emit a diagnostic. A non-zero exit from `env -i` MUST halt the test with a clear error.

### Permission denied on `$TEST_HOME` directory
- **Failure mode:** `mkdir -p $TEST_HOME/bin` fails due to permissions
- **Recovery:** `with-test-home` MUST check `mkdir` exit code and halt with a diagnostic.

### Existing test scripts that may break
- **Failure mode:** A test script that depends on the snap binary's behavior (e.g., different `opencode db path` output format) breaks after switching to the standalone binary
- **Recovery:** All 4 affected files are explicitly listed in ## Affected Files. Each change is independently verifiable via its SC. If a behavioral test fails after the change, the fix is rolled back per the remediation-first protocol.

## Alternatives Considered

### A. Patch `with-test-home` only (leave `helpers.sh` and bypass scripts)
- **Rejected because:** Root cause 2 (`helpers.sh` source-time `opencode models`) and root cause 5 (bypass scripts) would remain unfixed. The production DB would still be contaminated by 16 sourcing scripts and 2 direct runners. Partial fix leaves the death spiral in place.

### B. Use Docker containers for test isolation
- **Rejected because:** Docker adds a heavyweight dependency (daemon, image management, volume mounts) that conflicts with the lightweight test framework design. The `env -i` approach is simpler, faster, and sufficient when combined with the standalone binary copy.

### C. Rewrite `with-test-home` in Python
- **Rejected because:** The test framework is bash-based. A Python rewrite would require a separate Python dependency and break the existing bash test scripts that source `helpers.sh`. The bash fix is minimal and targeted.

### D. Set `SNAP_USER_DATA` to redirect the snap binary
- **Rejected because:** The snap binary hardcodes `SNAP_USER_DATA=~/snap/opencode/` and cannot be redirected. The AGENTS.md explicitly forbids the snap binary. The standalone binary is the correct approach.

## Recency Check

Git log review for the 4 affected files:

- `.opencode/tests-v2/with-test-home` — Last substantive change: 2026-07-17 (test framework v2 migration). The `env -i` comment on line 25 was added during initial v2 creation and has never been corrected.
- `.opencode/tests-v2/behaviors/helpers.sh` — Last substantive change: 2026-07-17. The `opencode models` call on line 397 was added during initial v2 creation.
- `.opencode/tests-v2/behaviors/secret-redaction/SC-2.sh` — Created 2026-07-17. No isolation wrapper was ever added.
- `.opencode/tests-v2/behaviors/test-verb-variant.sh` — Created 2026-07-17. Uses `snap run opencode` from creation.

All three isolation bugs were introduced during the initial test framework v2 migration (2026-07-17). No recent changes affect the fix approach — the bugs have been latent since creation.

## Documentation Sources

| Claim | Source | Verification Method |
|-------|--------|-------------------|
| `with-test-home` line 25 claims `env -i` | `.opencode/tests-v2/with-test-home` line 25 | `read` tool |
| Execution block lines 319-331 use subshell, not `env -i` | `.opencode/tests-v2/with-test-home` lines 319-331 | `read` tool |
| `helpers.sh` line 397 runs `opencode models` at source time | `.opencode/tests-v2/behaviors/helpers.sh` line 397 | `read` tool |
| `secret-redaction/SC-2.sh` uses direct `opencode run` | `.opencode/tests-v2/behaviors/secret-redaction/SC-2.sh` | `read` tool |
| `test-verb-variant.sh` uses `snap run opencode` | `.opencode/tests-v2/behaviors/test-verb-variant.sh` | `read` tool |
| Standalone binary exists at `.tools/opencode/opencode` | `.tools/opencode/opencode` | `ls` tool |
| AGENTS.md mandates standalone binary copy to `$TEST_HOME/bin` | `.opencode/AGENTS.md` | `read` tool |

## Changes

### `with-test-home`

- Resolves opencode as bare `"opencode"` (not absolute path) so `env -i` PATH resolution finds `$TEST_HOME/bin/opencode`
- Copies `.tools/opencode/opencode` to `$TEST_HOME/bin/opencode` before execution
- Execution block now uses `env -i -C "$TEST_PROJECT"` with explicit allowlist of 16 variables
- Sets `HOME="$TEST_HOME"` and prepends `$TEST_HOME/bin` to PATH
- Prints diagnostic `[test-env]` lines before running the command (HOME, PATH, USER, XDG_*, SNAP_USER_DATA, opencode binary path)

### `helpers.sh`

- `opencode models` call moved from source-time (line 397) into lazy-init function `__init_model_pool()`, called only on first `behavior_run_pool()` invocation
- Resolves opencode as bare `"opencode"` (not absolute path) so `with-test-home`'s `env -i` PATH resolution finds `$TEST_HOME/bin/opencode`

### `secret-redaction/SC-2.sh`

- Rewritten to use `behavior_run()` from helpers.sh (which uses `with-test-home`), instead of direct `opencode run`

### `test-verb-variant.sh`

- Rewritten to use `with-test-home` wrapper instead of `snap run opencode`

## Verification

```
[test-env] HOME=/home/.../tmp/test-home-20260717-220027
[test-env] PATH=/home/.../tmp/test-home-20260717-220027/bin:...
[test-env] USER=opencode-test-user
[test-env] XDG_DATA_HOME=/home/.../tmp/test-home-20260717-220027/.local/share
[test-env] XDG_CONFIG_HOME=/home/.../tmp/test-home-20260717-220027/.config
[test-env] XDG_STATE_HOME=/home/.../tmp/test-home-20260717-220027/.local/state
[test-env] XDG_CACHE_HOME=/home/.../tmp/test-home-20260717-220027/.cache
[test-env] SNAP_USER_DATA=/home/.../tmp/test-home-20260717-220027/snap/opencode
[test-env] opencode=/home/.../tmp/test-home-20260717-220027/bin/opencode
```

| Check | Result |
|-------|--------|
| `opencode` resolves to `$TEST_HOME/bin/opencode` | ✅ |
| Production DB session count unchanged | ✅ |
| Test DB has session with correct project worktree | ✅ |
| Test session ID not found in production DB | ✅ |
| All XDG vars point to test home | ✅ |
| `USER` is `opencode-test-user` | ✅ |

## Phases

### Phase 1: Implement all fixes

All changes are independent and can be done in parallel. This single phase covers all 12 requirements.

| Step | Action | Requirements |
|------|--------|-------------|
| 1.1 | Fix `with-test-home` execution block to use `env -i` with explicit allowlist, set `HOME`, copy standalone binary, prepend `$TEST_HOME/bin` to PATH, and print `[test-env]` diagnostics | R-1, R-2, R-3, R-4, R-6, R-12 |
| 1.2 | Fix `helpers.sh` to move `opencode models` from source-time to lazy-init and use bare `"opencode"` | R-5, R-6 |
| 1.3 | Rewrite `secret-redaction/SC-2.sh` to use `behavior_run()` | R-7 |
| 1.4 | Rewrite `test-verb-variant.sh` to use `with-test-home` wrapper instead of `snap run` | R-8, R-9 |
| 1.5 | Verify behavioral SCs (SC-10, SC-11) pass | R-10, R-11 |

## SC Enforcement Gate

All SCs below must PASS before implementation is considered complete. Any FAIL blocks the pipeline — no partial delivery, no caveats, no "PASS with concerns." Cost is measured in defect-discovery-latency: a structural PASS that misses a behavioral defect creates a death spiral of contaminated test data, false CI results, and manual DB cleanup costing 1000× more than the bounded minutes of running the correct verification.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `with-test-home` execution block uses `env -i` with explicit allowlist | `string` | grep for `env -i` in execution path. Cost: seconds of grep time vs. weeks of contaminated test data if missed. |
| SC-2 | `with-test-home` sets `HOME` to test home in execution block | `string` | grep for `HOME=.*TEST_HOME` in execution block. Cost: seconds vs. death spiral of production DB contamination. |
| SC-3 | `with-test-home` copies `.tools/opencode/opencode` to `$TEST_HOME/bin/opencode` | `string` | grep for `cp.*STANDALONE` in with-test-home. Cost: seconds vs. snap binary contamination of test results. |
| SC-4 | `with-test-home` prepends `$TEST_HOME/bin` to PATH | `string` | grep for `PATH=.*TEST_HOME/bin` in with-test-home. Cost: seconds vs. dead-code PATH that never resolves. |
| SC-5 | `helpers.sh` does NOT run `opencode models` at source time | `string` | grep for `opencode models` outside function body in helpers.sh. Cost: seconds vs. 16 scripts contaminating production DB on every source. |
| SC-6 | `with-test-home` and `helpers.sh` use bare `"opencode"` not absolute path | `string` | grep for `OPENCODE_CMD=.*opencode"` (bare, no path). Cost: seconds vs. `$TEST_HOME/bin/opencode` being dead code. |
| SC-7 | `secret-redaction/SC-2.sh` uses `behavior_run()` from helpers.sh | `string` | grep for `behavior_run` in SC-2.sh. Cost: seconds vs. unisolated test contaminating production DB. |
| SC-8 | `test-verb-variant.sh` does NOT use `snap run` | `string` | grep for `snap run` returns 0 matches. Cost: seconds vs. snap binary bypassing all isolation. |
| SC-9 | `test-verb-variant.sh` uses `with-test-home` wrapper | `string` | grep for `with-test-home` in test-verb-variant.sh. Cost: seconds vs. unisolated test contaminating production DB. |
| SC-10 | `opencode db path` under `with-test-home` contains `$TEST_HOME`, not `~/.local/share` | `behavioral` | Run `bash .opencode/tests-v2/with-test-home opencode db path`. Assert output contains `TEST_HOME` and does NOT contain `.local/share/opencode/opencode.db` (production path). Precondition: standalone binary at `.tools/opencode/opencode`. Cost: minutes of test execution vs. weeks of undetected production DB contamination. |
| SC-11 | Production DB session count is unchanged after a `with-test-home` test run | `behavioral` | Run `sqlite3 ~/.local/share/opencode/opencode.db 'SELECT COUNT(*) FROM sessions'` before and after a `with-test-home` test run. Assert counts are equal. Precondition: production DB exists at `~/.local/share/opencode/opencode.db`. Cost: minutes of test execution vs. death spiral of contaminated session data. |
| SC-12 | `with-test-home` prints diagnostic `[test-env]` lines before running command | `string` | grep for `[test-env]` in with-test-home. Cost: seconds vs. silent isolation failures. |

## Traceability

| SC ID | Requirement | Evidence Type | Verification Method | Phase |
|-------|-------------|---------------|---------------------|-------|
| SC-1 | R-1 | `string` | grep for `env -i` in execution path | 1 |
| SC-2 | R-2 | `string` | grep for `HOME=.*TEST_HOME` in execution block | 1 |
| SC-3 | R-3 | `string` | grep for `cp.*STANDALONE` in with-test-home | 1 |
| SC-4 | R-4 | `string` | grep for `PATH=.*TEST_HOME/bin` in with-test-home | 1 |
| SC-5 | R-5 | `string` | grep for `opencode models` outside function body in helpers.sh | 1 |
| SC-6 | R-6 | `string` | grep for `OPENCODE_CMD=.*opencode"` (bare, no path) | 1 |
| SC-7 | R-7 | `string` | grep for `behavior_run` in SC-2.sh | 1 |
| SC-8 | R-8 | `string` | grep for `snap run` returns 0 matches | 1 |
| SC-9 | R-9 | `string` | grep for `with-test-home` in test-verb-variant.sh | 1 |
| SC-10 | R-10 | `behavioral` | Run `bash .opencode/tests-v2/with-test-home opencode db path`. Assert output contains `TEST_HOME` and does NOT contain `.local/share/opencode/opencode.db`. | 1 |
| SC-11 | R-11 | `behavioral` | Run `sqlite3 ~/.local/share/opencode/opencode.db 'SELECT COUNT(*) FROM sessions'` before and after a `with-test-home` test run. Assert counts are equal. | 1 |
| SC-12 | R-12 | `string` | grep for `[test-env]` in with-test-home | 1 |

## Dependencies

All changes in this spec are independent — no change depends on another. The four affected files (`with-test-home`, `helpers.sh`, `SC-2.sh`, `test-verb-variant.sh`) can be modified in any order. The two behavioral SCs (SC-10, SC-11) require the `with-test-home` changes to be in place first, but since all changes are in Phase 1, this is a natural ordering within the phase rather than a cross-phase dependency.

## Affected Files

- `.opencode/tests-v2/with-test-home`
- `.opencode/tests-v2/behaviors/helpers.sh`
- `.opencode/tests-v2/behaviors/secret-redaction/SC-2.sh`
- `.opencode/tests-v2/behaviors/test-verb-variant.sh`

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-24 | Added preamble section (Intent and Executive Summary) | Spec audit SC-12 FAIL — missing preamble | Spec audit remediation |
| 2026-07-24 | Added Edge Cases and Error Recovery section | Spec audit SC-8 FAIL — no edge cases defined | Spec audit remediation |
| 2026-07-24 | Added Alternatives Considered section | Spec audit research_adequacy.investigation_breadth FAIL | Spec audit remediation |
| 2026-07-24 | Added Recency Check section | Spec audit research_adequacy.recency_check FAIL | Spec audit remediation |
| 2026-07-24 | Added Documentation Sources section with provenance citations | Spec audit SC-11 FAIL — no documentation sources | Spec audit remediation |
| 2026-07-24 | Added provenance citations to each root cause | Spec audit research_adequacy.evidence_provenance FAIL | Spec audit remediation |
| 2026-07-24 | Rewrote SC-10 and SC-11 with executable verification commands and preconditions | Spec audit SC-9/SC-DET FAIL — implicit_behavior patterns | Spec audit remediation |
| 2026-07-24 | Added cost-frame language to all SCs | Spec audit SC-13 FAIL — no cost-frame language | Spec audit remediation |
| 2026-07-24 | Added SC Enforcement Gate statement | Spec audit SC-14 FAIL — missing enforcement gate | Spec audit remediation |
| 2026-07-24 | Added Requirements section (R-1 through R-12 mapping SCs to requirements) | Validation FAIL: completeness — missing Requirements section | Spec-creation revision pipeline |
| 2026-07-24 | Added Phases section (Phase 1: Implement all fixes) | Validation FAIL: phase_coverage — missing Phases section | Spec-creation revision pipeline |
| 2026-07-24 | Added Traceability table mapping each SC to requirement, evidence type, verification method, and phase | Validation FAIL: traceability — missing Traceability table | Spec-creation revision pipeline |
| 2026-07-24 | Added Dependencies section noting all changes are independent | Validation FAIL: completeness — missing Dependencies section | Spec-creation revision pipeline |

