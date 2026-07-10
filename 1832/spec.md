---
issue: 1832
repo: .opencode
status: open
phase: spec
labels: [spec, test-infrastructure, consolidated]
---

# [SPEC] Test environment must replicate production — consolidate with-test-home, env-loader, and dead code cleanup

## Summary

The behavioral test harness (`with-test-home`) must replicate the production environment. Currently it does not — it uses different model discovery paths, bypasses plugins, and has incomplete XDG isolation. This spec consolidates three related issues (`.opencode#676`, `.opencode#793`, `.opencode#1653`) into a single implementation plan with sequenced phases.

**Core principle:** If the test environment doesn't replicate the production environment, it is worthless. Every deviation from prod behavior is a source of false negatives (tests that pass but shouldn't) or false positives (tests that fail due to harness issues, not implementation defects).

## Requirements

### Phase 1: `env-loader.ts` plugin fix

The `env-loader.ts` plugin crashes in isolated test environments with `Plugin export is not a function`. The root cause is the combination of `export default` (line 216) and named `export {}` (line 340) — the plugin system cannot handle both. PR #1654 worked around this by adding `--pure` to `behavior_run()`, which is wrong: `--pure` skips all plugins, making the test environment *less* like production.

**Fix:** Remove the named exports block at line 340 (`export { parseEnvFile, isEnvGitignored, writeDiagnostic, DIAGNOSTICS_PATH }` and `export type { PluginDiagnostic }`). These are test-only exports — the plugin itself only needs `export default`. Move the exported functions to a separate test utility file if tests need them.

### Phase 2: `with-test-home` — model discovery unification

`seed_model_config()` currently discovers models via `ollama_models()` → `ollama list`. Production uses `opencode-cli models`. The test config must use the same discovery path.

**Changes:**
1. Replace `ollama_models()` call in `seed_model_config()` with `opencode-cli models` filtered to `ollama/*` entries
2. Add `ollama-cloud` provider block to the seeded config with extended timeouts (30min)
3. Remove the `ollama_models()` function entirely — no callers remain
4. Add `TEST_HOME` to `pass_through_env` array so `env -i` preserves it across sequential dispatches
5. **Keep** `OPENCODE_CONFIG_CONTENT` — it is a valid override mechanism for test-specific needs (e.g., disabling notebook MCP). It does not replace the seeded config; it merges on top.

### Phase 3: `helpers.sh` — dead code removal

The following dead code has already been removed from `main` (regression guards only):
- `behavior_resolve_model()` function — already absent
- `BEHAVIOR_LOCAL_MODEL` / `BEHAVIOR_CLOUD_MODEL` variables — already absent
- `--pure` flag in `behavior_run()` — already absent

Still needed:
- Delete `tools/ollama-model-resolve` script (returns invalid model tags)
- Update `060-tool-usage.md` Tier 3 tool list — remove `ollama-model-resolve`
- Update `test-enforcement.sh` scenario `ollama-tooling-registration` — remove `ollama-model-resolve` assertion
- Update `approval-gate/tasks/verify-authorization.md` Step 0.2 — remove model resolution via `ollama-model-resolve`

### Phase 4: Documentation

1. **`.opencode/tests/AGENTS.md`**: Add §Session Failure Diagnosis section with diagnostic checklist table (6 checks), 5 common root causes, and clarification that `node_modules/` under `~/.config/opencode/` is irrelevant to test isolation.

2. **`.opencode/AGENTS.md`**: Update the "Isolated test environment" paragraph with session failure diagnosis summary and cross-reference to the full checklist.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `env-loader.ts` loads without error in isolated test environment | `behavioral` | Run `with-test-home opencode-cli run "test"` — stderr must not contain "Plugin export is not a function" |
| SC-2 | `seed_model_config()` uses `opencode-cli models` (not `ollama list`) for model discovery | `string` | Grep `with-test-home` for `opencode-cli models` in `seed_model_config`; `ollama_models` must not appear in `seed_model_config` |
| SC-3 | Seeded config includes `ollama-cloud` provider block | `string` | Grep `with-test-home` for `ollama-cloud` in the seeded JSON |
| SC-4 | `with-test-home` passes `TEST_HOME` through `env -i` | `string` | Grep `with-test-home` for `TEST_HOME` in `pass_through_env` loop |
| SC-5 | `OPENCODE_CONFIG_CONTENT` is preserved in `env -i` block | `string` | Grep `with-test-home` for `OPENCODE_CONFIG_CONTENT` — must appear |
| SC-6 | `ollama_models()` function removed from `with-test-home` | `string` | Grep `with-test-home` for `ollama_models` — must not appear |
| SC-7 | `tools/ollama-model-resolve` script deleted | `string` | File existence check — must not exist |
| SC-8 | `060-tool-usage.md` no longer references `ollama-model-resolve` | `string` | Grep `060-tool-usage.md` for `ollama-model-resolve` — must not appear |
| SC-9 | `test-enforcement.sh` no longer references `ollama-model-resolve` | `string` | Grep `test-enforcement.sh` for `ollama-model-resolve` — must not appear |
| SC-10 | `verify-authorization.md` no longer references `ollama-model-resolve` | `string` | Grep `verify-authorization.md` for `ollama-model-resolve` — must not appear |
| SC-11 | `tests/AGENTS.md` contains Session Failure Diagnosis section | `string` | Grep for `Session Failure Diagnosis` heading |
| SC-12 | `.opencode/AGENTS.md` contains session failure diagnosis cross-reference | `string` | Grep for `Session failure diagnosis` in `.opencode/AGENTS.md` |
| SC-13 | `env-loader.ts` has no named `export {}` block | `string` | Grep `env-loader.ts` for `export {` — must not appear (only `export default` is permitted) |

### SC Failure Policy — Zero Tolerance

**Any SC that is skipped, deferred, weakened, blocked, or otherwise bypassed marks ALL SCs as FAIL.** A single bypassed SC renders the entire implementation defective — the PR must be immediately rejected and trashed as unusable. This applies to:

- Removing an SC from the table
- Weakening an SC's evidence type (e.g., `behavioral` → `string`)
- Replacing an SC with a weaker version
- Marking an SC as "blocked" or "deferred" in the spec body
- Adding a `depends-on` or cross-reference solely to push SC verification out of this spec
- Claiming an SC is "not achievable" and modifying the spec rather than implementing it

**All SCs must pass with 100% clean PASS for the implementation to be accepted.**

## Supersedes

| Issue | Reason |
|-------|--------|
| `.opencode#676` | Absorbed — Phase 2 replaces #676's unmerged work (replace `ollama list` with `opencode-cli models` in `seed_model_config()`) |
| `.opencode#793` | Absorbed — Phase 3 covers #793's dead code removal scope |
| `.opencode#1653` | Absorbed — Phases 1, 2, and 4 cover #1653's scope, corrected per discussion (keep `OPENCODE_CONFIG_CONTENT`, fix `env-loader.ts` instead of `--pure`) |

## Interdependencies

| Issue | Relationship | Action Required |
|-------|-------------|-----------------|
| `.opencode#492` | **Depends on this spec** — #492's behavioral test scripts require a working test harness. Must wait for this spec to merge | No action on this spec; #492 must update its dependency after merge |
| `.opencode#294` | **Upstream** — added `seed_model_config()`. Already merged | No action needed |
| `.opencode#706` | **Upstream** — added sourcing guard and cloud model pool. Already merged | No action needed |

## Affected Files

| File | Phase | Change |
|------|-------|--------|
| `.opencode/plugins/env-loader.ts` | 1 | Remove named `export {}` block; keep only `export default` |
| `.opencode/tests/with-test-home` | 2 | Replace `ollama_models()` with `opencode-cli models`; add `ollama-cloud` provider; add `TEST_HOME` passthrough; remove `ollama_models()` function |
| `.opencode/tests/behaviors/helpers.sh` | 3 | No code changes needed (dead code already removed); regression guard SCs only |
| `.opencode/tools/ollama-model-resolve` | 3 | Delete file |
| `.opencode/guidelines/060-tool-usage.md` | 3 | Remove `ollama-model-resolve` from Tier 3 tool list |
| `.opencode/tests/test-enforcement.sh` | 3 | Remove `ollama-model-resolve` assertion from `ollama-tooling-registration` scenario |
| `.opencode/skills/approval-gate/tasks/verify-authorization.md` | 3 | Remove model resolution via `ollama-model-resolve` from Step 0.2 |
| `.opencode/tests/AGENTS.md` | 4 | Add §Session Failure Diagnosis section |
| `.opencode/AGENTS.md` | 4 | Add session failure diagnosis cross-reference |

## Root Cause Analysis

The `env-loader.ts` plugin crash (`Plugin export is not a function`) occurs because the plugin system cannot handle both `export default` and named `export {}` in the same file. In production, this is masked because the desktop app's plugin loader may handle it differently. In the isolated test environment, the crash surfaces immediately.

PR #1654's workaround (`--pure` flag) was incorrect — it skips all plugins, making the test environment diverge from production. The correct fix is to remove the named exports from the plugin file.

The `ollama_models()` → `ollama list` path in `seed_model_config()` is a second divergence: production discovers models via `opencode-cli models`, which is the authoritative source. Using `ollama list` means the test config may not match what the agent actually sees at runtime.

## Implementation Plan

Implement in phase order (each phase depends on the previous):

1. **Phase 1** — Fix `env-loader.ts` (SC-1, SC-13)
2. **Phase 2** — Fix `with-test-home` (SC-2 through SC-6)
3. **Phase 3** — Dead code cleanup (SC-7 through SC-10)
4. **Phase 4** — Documentation (SC-11, SC-12)

All phases on a single feature branch, single PR.

## Compliance Statement

This spec complies with all applicable guidelines: `000-critical-rules.md` (no escape hatches, no lobotomization), `080-code-standards.md` (evidence type taxonomy, SC-to-test traceability), `091-incremental-build.md` (per-item TDD cycle), `010-approval-gate.md` (spec before code).

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
