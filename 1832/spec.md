## Summary

The behavioral test harness (`with-test-home`) must replicate the production environment. Currently it does not — it uses different model discovery paths, has a broken plugin, and has incomplete XDG isolation. This spec consolidates four related issues (`.opencode#676`, `.opencode#793`, `.opencode#1370`, `.opencode#1653`) into a single implementation plan with sequenced phases.

**Core principle:** If the test environment doesn't replicate the production environment, it is worthless. Every deviation from prod behavior is a source of false negatives (tests that pass but shouldn't) or false positives (tests that fail due to harness issues, not implementation defects).

## References

- [OpenCode Plugin API docs](https://opencode.ai/docs/plugins/) — plugins require named exports, not `export default`
- [OpenCode CLI docs](https://opencode.ai/docs/cli/) — `--pure` flag documented as "Run without external plugins"; `OPENCODE_CONFIG_CONTENT` documented as "Inline json config content"
- [OpenCode Models docs](https://opencode.ai/docs/models/) — `opencode-cli models` is the authoritative model discovery command

## Requirements

### Phase 1: `env-loader.ts` plugin fix

`env-loader.ts` fails to load with `Plugin export is not a function`. Per the [official plugin docs](https://opencode.ai/docs/plugins/), the plugin system requires a **named export**:

```typescript
export const MyPlugin = async ({ project, client, $, directory, worktree }) => {
```

Current code uses `export default async function envLoaderPlugin(input: PluginInput)` — the plugin system iterates over module exports looking for named function exports; `export default` is a `default` key on the module, not a named export, so the loader doesn't find it.

**Fix:**
1. Change `export default async function envLoaderPlugin(input: PluginInput)` to `export const EnvLoaderPlugin: Plugin = async ({ project, client, $, directory, worktree }) => { ... }`
2. Update import: `import type { Hooks, PluginInput } from "@opencode-ai/plugin";` → `import type { Plugin } from "@opencode-ai/plugin";`
3. Map context: `input?.directory` → `directory`, `input?.worktree` → `worktree`, `input.$.nothrow` → `$.nothrow`
4. Preserve named exports at bottom (`parseEnvFile`, `isEnvGitignored`, `writeDiagnostic`, `DIAGNOSTICS_PATH`, `PluginDiagnostic`)
5. Fix pre-existing TypeScript errors in `session-enforcement.ts` (`"session.created"` hook key → `event` hook with `event.type` discrimination; `part.synthetic` access → narrow to `part.type === 'text'` first)
6. Create `.opencode/plugins/AGENTS.md` documenting plugin development requirements

### Phase 2: `with-test-home` — model discovery unification

`seed_model_config()` currently discovers models via `ollama_models()` → `ollama list`. Per the [official docs](https://opencode.ai/docs/models/), `opencode-cli models` is the authoritative model discovery command. The test config must use the same discovery path.

**Changes:**
1. Replace `ollama_models()` call in `seed_model_config()` with `opencode-cli models` filtered to `ollama/*` entries
2. Add `ollama-cloud` provider block to the seeded config with extended timeouts (30min)
3. Remove the `ollama_models()` function entirely — no callers remain
4. Add `TEST_HOME` to `pass_through_env` array so `env -i` preserves it across sequential dispatches
5. **Keep** `OPENCODE_CONFIG_CONTENT` — it is a [documented opencode env var](https://opencode.ai/docs/cli/) ("Inline json config content"), a valid override mechanism for test-specific needs (e.g., disabling notebook MCP). It does not replace the seeded config; it merges on top.

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
| SC-1 | `env-loader.ts` loads without "Plugin export is not a function" error | `behavioral` | Run `with-test-home opencode-cli run "test"` — stderr must not contain "Plugin export is not a function" |
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
| SC-13 | `env-loader.ts` uses named export (not `export default`) | `string` | Grep `env-loader.ts` for `export const EnvLoaderPlugin` — must appear; `export default` must not appear |
| SC-14 | `env-loader.ts` preserves named exports (`parseEnvFile`, `isEnvGitignored`, `writeDiagnostic`, `DIAGNOSTICS_PATH`, `PluginDiagnostic`) | `string` | Grep for each export name in `plugins/env-loader.ts` |
| SC-15 | No TypeScript compilation errors in `.opencode/plugins/` | `string` | `tsc --noEmit --project .opencode/tsconfig.json` exits 0 |
| SC-16 | `.opencode/plugins/AGENTS.md` exists documenting plugin dev requirements | `string` | File existence check |
| SC-17 | `shell.env` hook injects env vars (BRANCH_NAME, GIT_OWNER, GIT_REPO) | `behavioral` | Run `with-test-home opencode-cli run "echo $BRANCH_NAME"` — output must be non-empty |
| SC-18 | Full behavioral test suite passes with clean results after all changes | `behavioral` | Run `bash .opencode/tests/test-enforcement.sh --changed` — all tests must pass with 0 failures |

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
| `.opencode#1370` | Absorbed — Phase 1 covers #1370's env-loader.ts fix (named export per plugin API) |
| `.opencode#1653` | Absorbed — Phases 1, 2, and 4 cover #1653's scope, corrected per discussion |

## Interdependencies

| Issue | Relationship | Action Required |
|-------|-------------|-----------------|
| `.opencode#492` | **Depends on this spec** — #492's behavioral test scripts require a working test harness. Must wait for this spec to merge | No action on this spec; #492 must update its dependency after merge |
| `.opencode#294` | **Upstream** — added `seed_model_config()`. Already merged | No action needed |
| `.opencode#706` | **Upstream** — added sourcing guard and cloud model pool. Already merged | No action needed |

## Affected Files

| File | Phase | Change |
|------|-------|--------|
| `.opencode/plugins/env-loader.ts` | 1 | Change `export default` to named `export const EnvLoaderPlugin`; fix TypeScript errors in `session-enforcement.ts` |
| `.opencode/plugins/AGENTS.md` | 1 | Create new file documenting plugin dev requirements |
| `.opencode/tests/with-test-home` | 2 | Replace `ollama_models()` with `opencode-cli models`; add `ollama-cloud` provider; add `TEST_HOME` passthrough; remove `ollama_models()` function |
| `.opencode/tests/behaviors/helpers.sh` | 3 | No code changes needed (dead code already removed); regression guard SCs only |
| `.opencode/tools/ollama-model-resolve` | 3 | Delete file |
| `.opencode/guidelines/060-tool-usage.md` | 3 | Remove `ollama-model-resolve` from Tier 3 tool list |
| `.opencode/tests/test-enforcement.sh` | 3 | Remove `ollama-model-resolve` assertion from `ollama-tooling-registration` scenario |
| `.opencode/skills/approval-gate/tasks/verify-authorization.md` | 3 | Remove model resolution via `ollama-model-resolve` from Step 0.2 |
| `.opencode/tests/AGENTS.md` | 4 | Add §Session Failure Diagnosis section |
| `.opencode/AGENTS.md` | 4 | Add session failure diagnosis cross-reference |

## Root Cause Analysis

**`env-loader.ts` plugin crash:** Per the [official opencode plugin docs](https://opencode.ai/docs/plugins/), plugins must use **named exports** (`export const MyPlugin = async (...) =\u003e`). The current code uses `export default async function envLoaderPlugin(input: PluginInput)` — the plugin system iterates over module exports looking for named function exports; `export default` is a `default` key on the module, not a named export, so the loader doesn't find it. This is not a "both export styles conflict" issue — it's a "wrong export style" issue.

**`--pure` flag:** Per the [official CLI docs](https://opencode.ai/docs/cli/), `--pure` is a documented global flag meaning "Run without external plugins." It is a legitimate opencode feature, not a workaround. The question is whether to use it in the test harness — using it makes the test environment diverge from production (no plugins loaded), which violates the core principle. The correct approach is to fix the plugin so it loads without `--pure`.

**`OPENCODE_CONFIG_CONTENT`:** Per the [official CLI docs](https://opencode.ai/docs/cli/), this is a documented env var ("Inline json config content"). It is a valid override mechanism for test-specific needs. It does not replace the seeded config; it merges on top. Keep it.

**`opencode-cli models`:** Per the [official models docs](https://opencode.ai/docs/models/), this is the authoritative model discovery command. Using `ollama list` in `seed_model_config()` means the test config may not match what the agent actually sees at runtime.

## Implementation Plan

Implement in phase order (each phase depends on the previous):
1. **Phase 1** — Fix `env-loader.ts` (SC-1, SC-13, SC-14, SC-15, SC-16, SC-17)
2. **Phase 2** — Fix `with-test-home` (SC-2 through SC-6)
3. **Phase 3** — Dead code cleanup (SC-7 through SC-10)
4. **Phase 4** — Documentation (SC-11, SC-12)
5. **Phase 5** — Full suite verification (SC-18)

All phases on a single feature branch, single PR.

## Compliance Statement

This spec complies with all applicable guidelines: `000-critical-rules.md` (no escape hatches, no lobotomization), `080-code-standards.md` (evidence type taxonomy, SC-to-test traceability), `091-incremental-build.md` (per-item TDD cycle), `010-approval-gate.md` (spec before code).

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
