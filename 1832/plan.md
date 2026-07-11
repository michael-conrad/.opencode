# Plan: Test environment must replicate production

**Spec:** #1832
**Branch:** `feature/1832-test-env-production-parity`
**PR Strategy:** Stacked (single branch, single PR)

## Goal

Fix the behavioral test harness (`with-test-home`) to replicate the production environment. Consolidate four related issues (`.opencode#676`, `.opencode#793`, `.opencode#1370`, `.opencode#1653`) into sequenced phases.

## Architecture

5 sequential phases on a single feature branch, single PR:

| Phase | Concern | Files Changed | SCs |
|-------|---------|---------------|-----|
| 1 | `env-loader.ts` plugin fix | `env-loader.ts`, `session-enforcement.ts`, `plugins/AGENTS.md` | SC-1, SC-13, SC-14, SC-15, SC-16, SC-17 |
| 2 | `with-test-home` model discovery | `with-test-home` | SC-2, SC-3, SC-4, SC-5, SC-6 |
| 3 | Dead code cleanup | `tools/ollama-model-resolve`, `060-tool-usage.md`, `test-enforcement.sh`, `verify-authorization.md` | SC-7, SC-8, SC-9, SC-10 |
| 4 | Documentation | `tests/AGENTS.md`, `.opencode/AGENTS.md` | SC-11, SC-12 |
| 5 | Full suite verification | (none — test execution only) | SC-18 |

## Affected Files

| File | Phase | Change |
|------|-------|--------|
| `.opencode/plugins/env-loader.ts` | 1 | Change `export default` to named `export const EnvLoaderPlugin`; fix TypeScript errors in `session-enforcement.ts` |
| `.opencode/plugins/AGENTS.md` | 1 | Create new file documenting plugin dev requirements |
| `.opencode/tests/with-test-home` | 2 | Replace `ollama_models()` with `opencode-cli models`; add `ollama-cloud` provider; add `TEST_HOME` passthrough; remove `ollama_models()` function |
| `.opencode/tools/ollama-model-resolve` | 3 | Delete file |
| `.opencode/guidelines/060-tool-usage.md` | 3 | Remove `ollama-model-resolve` from Tier 3 tool list |
| `.opencode/tests/test-enforcement.sh` | 3 | Remove `ollama-model-resolve` assertion from `ollama-tooling-registration` scenario |
| `.opencode/skills/approval-gate/tasks/verify-authorization.md` | 3 | Remove model resolution via `ollama-model-resolve` from Step 0.2 |
| `.opencode/tests/AGENTS.md` | 4 | Add §Session Failure Diagnosis section |
| `.opencode/AGENTS.md` | 4 | Add session failure diagnosis cross-reference |

## Phase Dependency Graph

```
Phase 1 (env-loader) ──→ Phase 2 (with-test-home) ──→ Phase 3 (dead code) ──→ Phase 4 (docs) ──→ Phase 5 (full suite)
```

Each phase depends on the previous. No parallel execution.

## Implementation Pipeline Gates

Every phase MUST pass through the following gates before the orchestrator advances to the next phase:

1. **Pre-work** (`git-workflow --task pre-work`) — verify branch exists, submodule tagged
2. **RED phase** — write behavioral enforcement test that FAILS (change doesn't exist yet)
3. **GREEN phase** — implement the change
4. **VbC** (`verification-before-completion`) — verify all SCs for this phase
5. **Commit** — commit with AI co-authored byline
6. **Phase completion** — update pipeline state, advance to next phase

## Exit Criteria

- All 18 SCs pass with 100% clean PASS
- No SC is skipped, deferred, weakened, or blocked
- Behavioral SCs verified via `behavior_run` + `behavioral-test-evaluation` clean-room dispatch
- Full suite (`test-enforcement.sh --changed`) passes with 0 failures
- Single PR created from `feature/1832-test-env-production-parity` → `main`

## SC Failure Policy — Zero Tolerance

Any SC that is skipped, deferred, weakened, blocked, or otherwise bypassed marks ALL SCs as FAIL. A single bypassed SC renders the entire implementation defective.

## Self-Review Evidence

- Spec #1832 approved with `approved-for-pr` label
- Feature branch `feature/1832-test-env-production-parity` exists
- 5 phases defined with clear dependency chain
- All 18 SCs mapped to phases
- Behavioral SCs use `behavioral` evidence type with `behavior_run` + clean-room evaluation
- Implementation pipeline gates enumerated per `implementation-pipeline/SKILL.md` Trigger Dispatch Table

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
