# Phase 2 — End-to-end plan creation verification

**Concern:** Prove that plan creation for a retroactive-backfill issue completes end to end (backfill → research → solve model/check → plan plan) without `DEPENDENCY_CONTRACT_NOT_FOUND`.

**Files:**
- `.opencode/skills/writing-plans/tasks/backfill.md`
- `.opencode/skills/writing-plans/tasks/research.md`

**SCs:** SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `backfill.md` and `research.md` agree on the `interface-compatibility.yaml` schema.
- Phase 1 VbC passed (SC-1, SC-2 verified).

**Exit Conditions:**
- Plan creation for a retroactive-backfill issue completes without `DEPENDENCY_CONTRACT_NOT_FOUND`.
- `solve model` SAT, `solve check` SAT, `plan plan` SOLVED; `dependency-contract.yaml` written for downstream consumption.

## Code Path Coverage

(from `code-path-inventory.yaml`)

- Run `backfill.md` → `research.md` → `tools/solve model/check` → `tools/plan plan` for a retroactive-backfill issue — SC-3: end-to-end plan creation must complete without `DEPENDENCY_CONTRACT_NOT_FOUND`.
- Write `{issues_prefix}/{N}/dependency-contract.yaml` from `research.md` step 9 extraction — SC-3: the extracted dependency contract must be produced for downstream solve/plan steps.

## Cross-Cutting SCs

(from `cross-cutting-matrix.yaml`)

- `downstream_z3_tool_contract` — SC-1, SC-3: the `dependency_contract` schema must match what `solve`/`plan` expect (Risk 1 mitigation).
- `regression_guard_2232` — SC-3: guards against regression of the closed #2232 dependency-contract generation work; scope stays limited to `backfill.md`/`research.md`.

## Interface Boundaries

(from `interface-compatibility.yaml`)

- `dependency_contract_extraction` — `research.md` step 9 extracts `dependency_contract` and writes it to `{issues_prefix}/{N}/dependency-contract.yaml`, consumed by `solve` (model/check) and `plan`. If `interface-compatibility.yaml` has no `dependency_contract` section, `research.md` returns BLOCKED `DEPENDENCY_CONTRACT_NOT_FOUND` — the defect this phase proves resolved.

## State Transitions

(from `state-analysis.yaml`)

- `backfill_artifacts_complete` → `dependency_contract_extracted` → `plan_created` (trigger: solve model SAT, solve check SAT, plan plan SOLVED).
- Forbidden state: `contract_missing` — must never be entered for a retroactive-backfill issue (SC-3).

## Step-by-step

- [ ] 12. **RED (**sub-agent**).** Write an enforcement test that plan creation for a retroactive-backfill issue never hits `DEPENDENCY_CONTRACT_NOT_FOUND`. Test FAILS because the producer/consumer mismatch (or the unresolved schema) blocks plan creation. **→ SC-3**
- [ ] 13. **GREEN (**sub-agent**).** Run the backfill → research → solve model/check → plan plan pipeline for a retroactive-backfill issue; confirm the `dependency_contract` produced by the agreed schema is consumed by `solve` and `plan`. Fix any residual pipeline break. **→ SC-3**
- [ ] 14. **GREEN doublecheck (**clean-room**).** Verify plan creation completes end to end with no `DEPENDENCY_CONTRACT_NOT_FOUND` in stderr, `solve model` SAT, `solve check` SAT, `plan plan` SOLVED. **→ SC-3**
- [ ] 15. **Checkpoint commit (**inline**).** Stage and commit the enforcement test and the pipeline-verification change atomically. **→ SC-3**

#### Phase 2 VbC

- [ ] 16. **VbC (**clean-room**).** Verify SC-3 against its evidence type (behavioral — opencode run showing the full plan-creation pipeline completes without `DEPENDENCY_CONTRACT_NOT_FOUND` and plan output is written). **→ SC-3**

**Concern transition:** Leaving end-to-end plan creation verification → entering post-implementation gates (structural checks, verification, audit, cross-validate, review-prep, completion).

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*