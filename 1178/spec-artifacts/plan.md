# Plan: Remove Evidence Gate 4 (Noise Gate) from session-enforcement.ts

**Issue:** [#1178](https://github.com/michael-conrad/.opencode/issues/1178) — [BUG] Evidence Gate fires false positives on every turn with no dedup

**Authorization:** `for_pr` — auto-approved via pipeline scope

## Goal

Remove the `buildEvidenceGateBlock()` function (lines 186-190) and the injection logic (lines 1187-1222) from `.opencode/plugins/session-enforcement.ts`. Rule already enforced by `git-workflow --task cleanup` and `000-critical-rules.md` §critical-rules-013.

## Architecture

Single TypeScript file modification in `.opencode/plugins/session-enforcement.ts`. No state changes, no new dependencies.

**Concern:** Noise gate removal — pure deletion, no behavioral regressions.

---

## Phase 1: Remove Evidence Gate 4

**Concern:** Eliminate the `buildEvidenceGateBlock()` function and all injection/scanning logic for the Evidence Gate.

**File:** `.opencode/plugins/session-enforcement.ts`

**SCs covered:** SC-1, SC-2

### Implementation Pipeline Checklist (14 steps, mandatory)

Z3 state at `./tmp/1178/state/state.yaml`. Contract: `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`.

- [ ] 1. **SC-COHERENCE-GATE** — **orchestrator routes to pre-analysis**: verify SCs are internally consistent. `solve check` MUST return SAT. Confirm #1178's intent (remove gate) matches affected code region (lines 186-190, 1187-1222).
- [ ] 2. **PRE-RED-BASELINE** — **orchestrator routes to exploration**: confirm existing test suite PASSes. `cd .opencode && npx tsc --noEmit` MUST pass. `ls .opencode/tests/` for any session-enforcement tests.
- [ ] 3. **RED-PHASE** — **orchestrator routes to RED sub-agent**: write a behavioral test that verifies the Evidence Gate warning is NOT injected after an `issue-close` API call. Test at `.opencode/tests/behaviors/1178-evidence-gate-removed.sh`. Run it → expected FAIL (exit non-zero) because gate still exists. Output to `./tmp/1178/artifacts/phase1-test-output.log`.
- [ ] 4. **RED-DOUBLECHECK** — **orchestrator inline**: confirm `./tmp/1178/artifacts/phase1-test-output.log` exists and shows non-zero exit. If not present → HALT with blocker.
- [ ] 5. **GREEN-PHASE** — **orchestrator routes to GREEN sub-agent (clean-room)**: delete `buildEvidenceGateBlock()` function (remove lines 186-190 and the function body). Remove the Evidence Gate injection in the `buildEnforcementBlock()` or equivalent injection site (lines 1187-1222). Remove any regex pattern for `state.*closed|state.*:.*"closed"`. Run the behavioral test from step 3 → expected PASS (exit 0). Implementation output to `./tmp/1178/artifacts/phase1-green-output.log`.
- [ ] 6. **CHECKPOINT-COMMIT** — **orchestrator inline**: `git add .opencode/plugins/session-enforcement.ts .opencode/tests/behaviors/1178-evidence-gate-removed.sh && git commit -m "phase1 checkpoint: remove Evidence Gate 4 from session-enforcement.ts"`
- [ ] 7. **STRUCTURAL-CHECKS** — **orchestrator routes to structural sub-agent**: `cd .opencode && npx tsc --noEmit` MUST pass.
- [ ] 8. **GREEN-DOUBLECHECK** — **orchestrator inline**: confirm `./tmp/1178/artifacts/phase1-green-output.log` exists and shows exit 0. Re-run behavioral test. Re-run `npx tsc --noEmit`.
- [ ] 9. **GREEN-VBC** — **orchestrator routes to VbC sub-agent**: run verification-before-completion against Phase 1 SCs (SC-1: no `buildEvidenceGateBlock` in source; SC-2: no evidence gate injection code remains).
- [ ] 10. **ADVERSARIAL-AUDIT** — **orchestrator routes to resolve-models**: dispatch 2 auditors from different model families. Audit: `plan-fidelity` (does the plan match spec #1178 intent), `concern-separation` (is this a clean single-concern change).
- [ ] 11. **CROSS-VALIDATE** — **orchestrator inline**: verify dual-auditor consensus. PASS → proceed. FAIL or DISAGREE → remediate per audit findings, re-run affected steps.
- [ ] 12. **REGRESSION-CHECK** — **orchestrator routes to regression sub-agent**: `cd .opencode && npx tsc --noEmit` PASS. Confirm no TypeScript compilation errors.
- [ ] 13. **REVIEW-PREP** — **orchestrator routes to review-prep sub-agent**: generate compare URL `compare/dev...feature/plan-1175-1178`, draft PR body for Phase 1 changes.
- [ ] 14. **EXEC-SUMMARY** — **orchestrator inline**: collect all sub-agent result contracts, produce phase summary with SC status, artifact paths, byline.

### Inter-Phase Handoff (after Phase 1, before Phase 2)

- `solve state update` — set phase1 step states
- `solve check` — confirm SAT
- Append lifecycle manifest event for Phase 1 completion
- Verify checkpoint tag exists

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Function `buildEvidenceGateBlock` is removed from session-enforcement.ts | `string` | `grep -c "buildEvidenceGateBlock" .opencode/plugins/session-enforcement.ts` returns 0 |
| SC-2 | No Evidence Gate injection logic remains (the regex scan for `state.*closed` and its block builder call) | `string` | `grep -c "Evidence Gate\|state.*closed\|state.*:.*\"closed\"" .opencode/plugins/session-enforcement.ts` returns 0 |
| SC-3 | TypeScript compilation succeeds after removal | `behavioral` | `cd .opencode && npx tsc --noEmit` returns exit code 0 |

---

## Z3 SAT Contract

Phase-step contract at `.opencode/.issues/1178/spec-artifacts/artifacts/pipeline-contract.yaml`:

```yaml
variables:
  current_step:
    type: string
    domain: [sc-coherence-gate, pre-red-baseline, red-phase, red-doublecheck, green-phase, checkpoint-commit, structural-checks, green-doublecheck, green-vbc, adversarial-audit, cross-validate, regression-check, review-prep, exec-summary]
  previous_step:
    type: string
    domain: [init, sc-coherence-gate, pre-red-baseline, red-phase, red-doublecheck, green-phase, checkpoint-commit, structural-checks, green-doublecheck, green-vbc, adversarial-audit, cross-validate, regression-check, review-prep]
  pipeline_state:
    type: string
    domain: [init, running, complete, failed]
```

`solve check` MUST return SAT before every step transition. UNSAT → HALT with blocker report. Remediate → re-check → repeat until clean PASS.

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
