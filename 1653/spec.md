---
issue: 1653
repo: .opencode
status: open
phase: spec
labels: [spec-fix, test-infrastructure]
---

# [SPEC-FIX] with-test-home: fix test environment isolation gaps causing Session not found errors

## Summary

`with-test-home` has multiple test environment isolation gaps that cause `opencode-cli run` to produce `Error: Session not found` or hang indefinitely during behavioral tests. The root cause is always incomplete XDG isolation — the test runner uses the host SQLite database or config instead of the isolated test home.

## Requirements

### `with-test-home` — 4 fixes needed

1. **`TEST_HOME` passthrough**: Add `TEST_HOME` to `pass_through_env` array so `env -i` preserves it across sequential dispatches. Without this, each `behavior_run` call creates a fresh test home with full ~240s bootstrap, exceeding the 600s bash tool timeout.

2. **Cloud model seeding**: `seed_model_config()` must populate cloud models (`ollama/deepseek-v4-flash:cloud` etc.) from `opencode-cli models` in addition to local models from `ollama list`. Without cloud models, model dispatch hangs because no provider can handle the request.

   **Note:** This absorbs the unmerged work from closed issue `.opencode#676` ("Use opencode-cli models for behavioral testing model discovery"). Issue #676 was closed as completed but its changes were never merged to `main`. The current `seed_model_config()` still uses `ollama list` only.

3. **`ollama-cloud` provider block**: The seeded config must include the `ollama-cloud` provider with extended timeouts (30min). Without it, cloud model dispatch hangs indefinitely.

4. **`OPENCODE_CONFIG_CONTENT` removal**: Remove the `OPENCODE_CONFIG_CONTENT` env var from the `env -i` block. It overrides the **entire** seeded config, stripping all provider definitions. The seeded config file at `$TEST_HOME/.config/opencode/opencode.jsonc` already has all providers — the env var is redundant and destructive.

### `helpers.sh` — 1 revert needed (pre-satisfied, regression guard)

5. **Remove `--pure` flag**: `--pure` was added as a workaround for the env-loader plugin crash, but it masks the root cause (incomplete isolation). The correct fix is proper XDG isolation — `--pure` has no place in the test harness.

   **Status:** Already satisfied on `main` — `--pure` is absent from all test files. Retained as a regression guard SC.

### Test scripts — 1 structural fix needed (pre-satisfied, regression guard)

6. **Split multi-scenario scripts**: `492-stale-branch-auto-rebase.sh` has 3 `behavior_run` calls in one script, violating the One Scenario Per Run mandate. Split into 3 single-scenario scripts (stale, clean, conflict).

   **Status:** Already satisfied on `main` — `492-stale-branch-auto-rebase.sh` does not exist. Retained as a regression guard SC.

### Documentation — 2 files to update

7. **`.opencode/tests/AGENTS.md`**: Add a §Session Failure Diagnosis section with diagnostic checklist table (6 checks), 5 common root causes, and clarification that `node_modules/` under `~/.config/opencode/` is irrelevant to test isolation.

8. **`.opencode/AGENTS.md`**: Update the "Isolated test environment" paragraph with session failure diagnosis summary and cross-reference to the full checklist.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `with-test-home` passes `TEST_HOME` through `env -i` | `string` | Grep `with-test-home` for `TEST_HOME` in `pass_through_env` loop |
| SC-2 | `seed_model_config()` includes cloud models from `opencode-cli models` | `string` | Grep `with-test-home` for `opencode-cli models` in `seed_model_config` |
| SC-3 | Seeded config includes `ollama-cloud` provider block | `string` | Grep `with-test-home` for `ollama-cloud` in the seeded JSON |
| SC-4 | `OPENCODE_CONFIG_CONTENT` env var is NOT set in `env -i` block | `string` | Grep `with-test-home` for `OPENCODE_CONFIG_CONTENT` — must not appear |
| SC-5 | `behavior_run()` does NOT use `--pure` flag | `string` | Grep `helpers.sh` for `--pure` — must not appear |
| SC-6 | `492-stale-branch-auto-rebase.sh` does not exist in `tests/behaviors/` | `string` | File existence check — must not exist |
| SC-7 | `tests/AGENTS.md` contains Session Failure Diagnosis section | `string` | Grep for `Session Failure Diagnosis` heading |
| SC-8 | `AGENTS.md` contains session failure diagnosis cross-reference | `string` | Grep for `Session failure diagnosis` in `.opencode/AGENTS.md` |

### SC Failure Policy — Zero Tolerance

**Any SC that is skipped, deferred, weakened, blocked, or otherwise bypassed marks ALL SCs as FAIL.** A single bypassed SC renders the entire implementation defective — the PR must be immediately rejected and trashed as unusable. This applies to:

- Removing an SC from the table
- Weakening an SC's evidence type (e.g., `string` → `structural`)
- Replacing an SC with a weaker version
- Marking an SC as "blocked" or "deferred" in the spec body
- Adding a `depends-on` or cross-reference solely to push SC verification out of this spec
- Claiming an SC is "not achievable" and modifying the spec rather than implementing it

**All SCs must pass with 100% clean PASS for the implementation to be accepted.**

## Interdependencies

| Issue | Relationship | Action Required |
|-------|-------------|-----------------|
| `.opencode#676` | **Absorbed** — closed but never merged. SC-2 replaces #676's unmerged work | Mark #676 as superseded by #1653 after merge |
| `.opencode#793` | **Independent** — touches `helpers.sh` but different lines (removes `behavior_resolve_model()`). No ordering constraint | No action needed |
| `.opencode#492` | **Prerequisite** — SC-6 (split test scripts) is a prerequisite for #492's stale-branch detection tests | #492 must wait for #1653 to merge before its test scripts can be created |
| `.opencode#294` | **Upstream** — added `seed_model_config()`. Already merged | No action needed |
| `.opencode#706` | **Upstream** — added sourcing guard and cloud model pool. Already merged | No action needed |

## Affected Files

- `.opencode/tests/with-test-home`
- `.opencode/tests/behaviors/helpers.sh` (SC-5 only — regression guard, already satisfied)
- `.opencode/tests/AGENTS.md`
- `.opencode/AGENTS.md`

## Root Cause Analysis

The `env-loader.ts` plugin (`Plugin export is not a function`) is a red herring — it only appears because the test environment is not properly isolated. When `with-test-home` is used correctly with complete `env -i` passthrough and a properly seeded config, the plugin loads and runs without error. The `node_modules/` directory under `~/.config/opencode/` is created automatically by opencode's runtime and is irrelevant to test isolation.

## Implementation Plan

The 6 fixes and 2 documentation updates described above have been partially implemented on branch `feature/492-stale-branch-detection` (not yet merged to main). The merge path is:

- **Option A (preferred):** Create a PR from `feature/492-stale-branch-detection` to `main`, verify all SCs pass, and merge
- **Option B (fallback):** If the branch is stale or conflicts, re-implement the 8 requirements on a new feature branch following the same order

## Compliance Statement

This spec complies with all applicable guidelines: `000-critical-rules.md` (no escape hatches, no lobotomization), `080-code-standards.md` (evidence type taxonomy, SC-to-test traceability), `091-incremental-build.md` (per-item TDD cycle), `010-approval-gate.md` (spec before code).

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
