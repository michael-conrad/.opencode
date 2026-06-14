# Plan: Flatten .issues/{N}/ directory layout — remove spec-artifacts/ wrapper

**Issue:** [#1176](https://github.com/michael-conrad/.opencode/issues/1176) — [SPEC] Restructure .issues/{N}/ folder layout — flatten spec-artifacts/

**Authorization:** `for_pr` — auto-approved via pipeline scope

## Goal

Remove the `spec-artifacts/` wrapper directory. Single-file artifacts move to `.issues/{N}/` level. Multi-file concerns (audit/, research/, designs/, state/, dependency-ordering-verification/) remain as sub-folders at the `.issues/{N}/` level.

## Architecture

Path-only refactor across ~35 files in `.opencode/skills/`, `.opencode/AGENTS.md`, `.opencode/tests/behaviors/`, `.opencode/.issues/AGENTS.md`. Every reference to `spec-artifacts/plan.md` becomes `plan.md`, `spec-artifacts/sc-summary.yaml` becomes `sc-summary.yaml`, etc. Sub-folders (audit/, research/, designs/, state/, dependency-ordering-verification/) stay at the same logical level — just move out of spec-artifacts/.

## Scope

This plan covers ONLY files inside `.opencode/`. The parallel layout update in `opencode-config/.issues/AGENTS.md` is a separate mechanical update.

---

## Phase 4: Flatten .issues/{N}/ directory layout

**Concern:** Path-only refactor. No content changes. Every reference to `spec-artifacts/` path prefix must be removed and replaced with the flat path.

**Files affected (~35):**
- `.opencode/.issues/AGENTS.md` — directory layout + examples + URL convention
- `.opencode/AGENTS.md` — directory layout
- `.opencode/skills/writing-plans/tasks/create.md` — plan storage path
- `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` — plan storage, artifact checks
- `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — plan path references
- `.opencode/skills/writing-plans/SKILL.md` — plan model path
- `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` — handoff paths
- `.opencode/skills/spec-creation/tasks/write.md` — artifact generation paths
- `.opencode/skills/spec-creation/tasks/completion.md` — completion paths
- `.opencode/skills/spec-creation/tasks/pipeline-readiness-gate.md`
- `.opencode/skills/implementation-pipeline/SKILL.md` — artifact references
- `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md`
- `.opencode/skills/implementation-pipeline/tasks/sc-closeout.md`
- `.opencode/skills/test-driven-development/tasks/red.md`
- `.opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md`
- `.opencode/tests/behaviors/` — multiple test files

**SCs covered:** SC-1 through SC-8

### Implementation Pipeline Checklist (14 steps, mandatory)

Z3 state at `./tmp/1176/state/state.yaml`. Contract: `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`.

- [ ] 1. **SC-COHERENCE-GATE** — **orchestrator routes to pre-analysis**: verify SCs internally consistent. SC-1 (AGENTS.md layout updated), SC-2 (no spec-artifacts/ in skills/), SC-3 (no spec-artifacts/ in tests/), SC-4 (push-artifacts updated), SC-5 (AGENTS.md shows flat), SC-6 (URL convention flat), SC-7 (sub-folders preserved), SC-8 (files at {N}/ level). `solve check` MUST return SAT.
- [ ] 2. **PRE-RED-BASELINE** — **orchestrator routes to exploration**: run `grep -r "spec-artifacts/" .opencode/skills/ .opencode/AGENTS.md .opencode/.issues/AGENTS.md .opencode/tests/behaviors/` to establish baseline count. `grep -r "spec-artifacts/" .opencode/ | wc -l` returns baseline count.
- [ ] 3. **RED-PHASE** — **orchestrator routes to RED sub-agent**: write a structural test at `.opencode/tests/behaviors/1176-no-spec-artifacts.sh` that greps for `spec-artifacts/` across the skills/ tree. Expected FAIL (> 0 matches because spec-artifacs refs still exist). Output to `./tmp/1176/artifacts/phase4-test-output.log`.
- [ ] 4. **RED-DOUBLECHECK** — **orchestrator inline**: confirm RED artifact shows non-zero exit from grep finding matches.
- [ ] 5. **GREEN-PHASE** — **orchestrator routes to GREEN sub-agent (clean-room)**: perform path-only find-and-replace across all affected files. For each file, replace `spec-artifacts/plan.md` with `plan.md`, `spec-artifacts/sc-summary.yaml` with `sc-summary.yaml`, `spec-artifacts/` → (empty, for remaining paths). Run the structural test → expected PASS (exit 0, zero matches). Output to `./tmp/1176/artifacts/phase4-green-output.log`.

  **Critical preservation rules:**
  - Multi-file sub-folders (audit/, research/, designs/, state/, dependency-ordering-verification/) MUST remain as `.issues/{N}/audit/` etc. — do NOT remove the sub-folder reference, only the `spec-artifacts/` prefix.
  - The `push-artifacts` task does `git add .issues/{N}/` — confirm this still works with flat structure (it does, since it adds the entire directory).
  - `.opencode/.issues/AGENTS.md` directory layout diagram must be updated to the flat structure.
  - `.opencode/AGENTS.md` must be updated if it references the old layout.
  - GitHub URL convention in `.opencode/.issues/AGENTS.md` must point to `.issues/{N}/` not `spec-artifacts/`.
  - Behavioral tests must use new flat paths.
- [ ] 6. **CHECKPOINT-COMMIT** — **orchestrator inline**: `git add -u && git commit -m "phase4 checkpoint: flatten .issues/{N}/ layout"`
- [ ] 7. **STRUCTURAL-CHECKS** — **orchestrator routes to structural sub-agent**: `grep -r "spec-artifacts/" .opencode/` MUST return 0 matches. Verify each affected file is readable and its YAML/Markdown structure is intact.
- [ ] 8. **GREEN-DOUBLECHECK** — **orchestrator inline**: confirm GREEN artifact shows exit 0. Re-run structural test.
- [ ] 9. **GREEN-VBC** — **orchestrator routes to VbC sub-agent**: verification-before-completion against all 8 Phase 4 SCs.
- [ ] 10. **ADVERSARIAL-AUDIT** — **orchestrator routes to resolve-models**: dispatch 2 auditors. Audit: `plan-fidelity` (all spec-artifacts/ refs removed), `concern-separation` (path-only change, no content logic modified).
- [ ] 11. **CROSS-VALIDATE** — **orchestrator inline**: verify dual-auditor consensus.
- [ ] 12. **REGRESSION-CHECK** — **orchestrator routes to regression sub-agent**: run behavioral test suite for any affected skills. Confirm no path-related test failures.
- [ ] 13. **REVIEW-PREP** — **orchestrator routes to review-prep sub-agent**: compare URL for Phase 4 changes.
- [ ] 14. **EXEC-SUMMARY** — **orchestrator inline**: collect all sub-agent result contracts, produce phase summary.

### Post-All-Phases Sweep (after Phase 4 gate 14)

- [ ] FINISHING CHECKLIST — **orchestrator routes to finishing sub-agent**: `git status` clean. Verify all 4 phases committed. `grep -r "spec-artifacts/" .opencode/` returns 0 (SC-1, SC-2, SC-3 all confirmed globally).
- [ ] PR CREATION — **orchestrator routes to git-workflow pr-creation**: create stacked PR for feature/plan-1175-1178 targeting dev. Extract `html_url` from `github_create_pull_request` response. PR body contains 4-phase summary.
- [ ] POST-MERGE CLEANUP — **orchestrator routes to git-workflow cleanup**: delete merged branch, close issues 1175-1178, sync dev.

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-artifacts/` wrapper eliminated from `.opencode/.issues/AGENTS.md` directory layout | `string` | `grep -c "spec-artifacts/" .opencode/.issues/AGENTS.md` returns 0 |
| SC-2 | All skill task files reference new flat paths (no `spec-artifacts/`) | `string` | `grep -r "spec-artifacts/" .opencode/skills/` returns 0 |
| SC-3 | Behavioral tests updated to use new flat paths | `string` | `grep -r "spec-artifacts/" .opencode/tests/` returns 0 |
| SC-4 | `push-artifacts` task verification updated to flat paths | `string` | `push-artifacts.md` no longer references `spec-artifacts/` in verification steps |
| SC-5 | `.opencode/AGENTS.md` directory layout shows flat structure | `structural` | File uses new flat directory layout diagram |
| SC-6 | GitHub URL convention in `.opencode/.issues/AGENTS.md` points to `.issues/{N}/` | `string` | `grep -c "spec-artifacts"` in URL convention section returns 0 |
| SC-7 | Sub-folders preserved (audit/, research/, designs/, state/, dependency-ordering-verification/) | `structural` | Each sub-folder still referenced in directory layout docs |
| SC-8 | `plan.md`, `cards.md`, lifecycle YAMLs, contract YAMLs listed at `{N}/` level | `string` | Directory layout docs show these at `{N}/` level, not in subdirectory |

---

## Z3 SAT Contract

Same pipeline contract. `solve check` MUST return SAT before every step transition.

*Co-authored with AI: OpenCode (deepseek-v4-flash)*