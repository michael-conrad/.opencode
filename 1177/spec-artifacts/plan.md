# Plan: Fix local-issues tool repo resolution for submodule context

**Issue:** [#1177](https://github.com/michael-conrad/.opencode/issues/1177) — [BUG] local-issues create reports success but does not create .issues/{N}/ directory

**Authorization:** `for_pr` — auto-approved via pipeline scope

## Goal

Fix the `local-issues` Python tool at `.opencode/tools/local-issues` so that when `--number` is provided without a repo qualifier in submodule context (i.e., when invoked from parent repo but targeting a `.opencode` submodule issue), it resolves to the correct repo's `.issues/` directory and creates the directory entry.

## Root Cause

The tool uses the parent repo's `github.owner`/`github.repo` even when the issue exists on the submodule repo (michael-conrad/.opencode). The number is reported under `opencode-config#1175` instead of `.opencode#1175`, and the directory is created under the parent's `.issues/` rather than `.opencode/.issues/`.

## Architecture

Single Python file modification in `.opencode/tools/local-issues`. Need to add or fix repo-resolution logic to detect when the `--number` targets a submodule repo issue.

**Files:** `.opencode/tools/local-issues`

---

## Phase 2: Fix local-issues repo resolution

**Concern:** Fix the tool so it correctly resolves which `.issues/` directory to use when creating entries for submodule repo issues.

**File:** `.opencode/tools/local-issues`

**SCs covered:** SC-1, SC-2, SC-3

### Implementation Pipeline Checklist (14 steps, mandatory)

Z3 state at `./tmp/1177/state/state.yaml`. Contract: `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`.

- [ ] 1. **SC-COHERENCE-GATE** — **orchestrator routes to pre-analysis**: verify SCs are internally consistent. Confirms: fix affects `.opencode/tools/local-issues` only. Resolution logic for submodule repos must detect context.
- [ ] 2. **PRE-RED-BASELINE** — **orchestrator routes to exploration**: read the local-issues tool entry point. Identify where `--number` is parsed and where the repo/issue path is resolved. Confirm existing test behavior: `local-issues list` shows issues as `opencode-config#N` not `.opencode#N`. Run `local-issues create --number 1175 --title "test" --labels test` and verify it creates in wrong location.
- [ ] 3. **RED-PHASE** — **orchestrator routes to RED sub-agent**: write a test script at `.opencode/tests/behaviors/1177-local-issues-repo-resolution.sh` that creates a test issue via `local-issues create --number 9999 --title "test-repo-resolve" --labels test` and checks whether the directory appears in the correct `.opencode/.issues/` location. Expected FAIL because tool creates in wrong location. Output to `./tmp/1177/artifacts/phase2-test-output.log`.
- [ ] 4. **RED-DOUBLECHECK** — **orchestrator inline**: confirm `./tmp/1177/artifacts/phase2-test-output.log` exists and shows non-zero exit.
- [ ] 5. **GREEN-PHASE** — **orchestrator routes to GREEN sub-agent (clean-room)**: fix the repo-resolution logic in `.opencode/tools/local-issues`. The fix should detect when the parent process is working with a submodule issue and route to `.opencode/.issues/` instead of `.issues/`. Implementation notes: the tool may need to check whether the working directory is inside a submodule or check `.gitmodules`. Run the behavioral test → expected PASS. Output to `./tmp/1177/artifacts/phase2-green-output.log`.
- [ ] 6. **CHECKPOINT-COMMIT** — **orchestrator inline**: `git add .opencode/tools/local-issues .opencode/tests/behaviors/1177-local-issues-repo-resolution.sh && git commit -m "phase2 checkpoint: fix local-issues repo resolution for submodule context"`
- [ ] 7. **STRUCTURAL-CHECKS** — **orchestrator routes to structural sub-agent**: `uv run ruff check .opencode/tools/local-issues` MUST pass.
- [ ] 8. **GREEN-DOUBLECHECK** — **orchestrator inline**: confirm `./tmp/1177/artifacts/phase2-green-output.log` shows exit 0. Re-run behavioral test.
- [ ] 9. **GREEN-VBC** — **orchestrator routes to VbC sub-agent**: verification-before-completion against Phase 2 SCs. Confirm SC-1 (correct `.opencode/.issues/` directory), SC-2 (correct `spec_path`), SC-3 (no regression for parent repo issues).
- [ ] 10. **ADVERSARIAL-AUDIT** — **orchestrator routes to resolve-models**: dispatch 2 auditors. Audit: `plan-fidelity` (does fix match bug #1177 root cause), `concern-separation` (clean single-file change).
- [ ] 11. **CROSS-VALIDATE** — **orchestrator inline**: verify dual-auditor consensus.
- [ ] 12. **REGRESSION-CHECK** — **orchestrator routes to regression sub-agent**: run `local-issues list` to confirm existing entries still readable. Run `local-issues create --number 9998 --title "regression-test" --labels test` in parent repo context; confirm it creates in `.issues/9998/` not `.opencode/.issues/9998/`.
- [ ] 13. **REVIEW-PREP** — **orchestrator routes to review-prep sub-agent**: compare URL for Phase 2 changes.
- [ ] 14. **EXEC-SUMMARY** — **orchestrator inline**: collect all sub-agent result contracts, produce phase summary.

### Inter-Phase Handoff (after Phase 2, before Phase 3)

- `solve state update` — set phase2 step states
- `solve check` — confirm SAT
- Append lifecycle manifest event

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues create --number N --title T` for a `.opencode` issue creates `.opencode/.issues/{N}/` directory | `behavioral` | Create a test issue; `ls .opencode/.issues/{N}/` returns directory with `issue.yaml` |
| SC-2 | `local-issues list` shows `.opencode` issues with correct repo prefix (`.opencode#N`) not parent prefix | `string` | `grep -c "^opencode-config#N"` → 0 for submodule issues; entries show `.opencode#N` instead |
| SC-3 | Parent repo issues continue to work in `.issues/{N}/` (no regression) | `behavioral` | Create test in parent; confirm `.issues/9999/` created, not `.opencode/.issues/9999/` |

---

## Z3 SAT Contract

Same pipeline contract as Phase 1. `solve check` MUST return SAT before every step transition.

*Co-authored with AI: OpenCode (deepseek-v4-flash)*