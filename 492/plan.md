# Implementation Plan — [#492](https://github.com/michael-conrad/.opencode/issues/492) — Stale-branch detection before PR creation

**Spec:** #492 (v3.0) — Stale-branch detection before PR creation

**Goal:** Add a staleness-check + auto-rebase step to `git-workflow --task review-prep` that detects feature branches forked from stale `dev` and auto-rebases before push/PR creation.

**Architecture:** A new step inserted before the existing Step 1.5 rebase in `review-prep/push-and-cleanup.md`. The step runs `git rev-list --count --left-right origin/dev...HEAD` to detect staleness, then auto-rebases onto `origin/dev`. On Tier 3 (intent) conflicts, HALT and escalate to developer.

**Files:**
- `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` — add staleness-check step
- `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` — new behavioral test

> **⚠️ COMPLIANCE REQUIREMENT:** This plan is a binding implementation contract. Every step MUST be executed in order. No step may be skipped, reordered, or combined. Each step's dispatch indicator (`(**sub-agent**)`, `(**inline**)`) is mandatory. The orchestrator MUST follow the exact dispatch pattern specified. Violations produce defective deliverables that require rework from scratch and loss of all prior work.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute exactly ONE step at a time. After each step, report the result before proceeding to the next. Do NOT batch steps. Do NOT skip ahead. Each step depends on the previous step's output.

> **⚠️ STEP STATUS:** Each step MUST be reported with its status: `✅ completed`, `❌ failed`, or `⏳ in progress`. After each step, update the step's checkbox and report status before proceeding.

> **⚠️ COST FRAME:** Verification cost is measured in defect-discovery-latency, not tool-call count. A behavioral test costs minutes of execution time — a bounded delay that surfaces defects before they reach CI. Skipping behavioral verification to save a tool call costs the full pipeline of rework when the defect surfaces downstream: diagnosis, rework, re-review, re-CI, re-deploy — each roundtrip more expensive than any verification run. Correctness is the only success metric. There is no score for tool-call economy. Structural evidence (grep, file existence) for behavioral SCs is EVIDENCE_TYPE_MISMATCH — a hard FAIL.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Stale-branch detection and auto-rebase | Add staleness-check + auto-rebase to pre-PR gate, add behavioral enforcement test | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | None | 1–23 |

## Phase 01 — Stale-branch detection before PR creation

**Concern:** Add a staleness-check diagnostic step before the existing Step 1.5 rebase in `review-prep/push-and-cleanup.md`. The step detects whether the feature branch is behind `origin/dev` and auto-rebases, only escalating to the developer on Tier 3 (intent) conflicts.

**Files:**
- `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md`
- `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

**Dependencies:** None

**Entry conditions:** Spec #492 approved, plan created, feature branch exists, `origin/dev` is fetchable.

**Exit conditions:** Staleness-check step exists in `push-and-cleanup.md` before Step 1.5; behavioral test passes.

### Global Pre-Steps

- [ ] 1. **SC coherence gate (**sub-agent**).** Dispatch `adversarial-audit --task coherence-extraction`. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

- [ ] 2. **Pre-RED baseline (**sub-agent**).** Dispatch `implementation-pipeline --task pre-red-baseline`. **→ SC-1, SC-6**

### Item 1: Behavioral enforcement test (RED)

- [ ] 3. **RED phase (**sub-agent**).** Dispatch `test-driven-development --task red`. **→ SC-2, SC-3, SC-4, SC-5, SC-6**

- [ ] 4. **Z3 check RED (**inline**).** Run `solve check` against red-phase output contract (`contracts/red-phase-output-template.yaml`). **→ SC-6**

- [ ] 5. **RED doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. **→ SC-6**

- [ ] 6. **Z3 check RED doublecheck (**inline**).** Run `solve check` against red-doublecheck output contract (`contracts/red-doublecheck-output-template.yaml`). **→ SC-6**

- [ ] 7. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-6**

- [ ] 8. **Z3 check post-RED (**inline**).** Run `solve check` against post-red-enforcement output contract (`contracts/post-red-enforcement-output-template.yaml`). **→ SC-6**

### Item 2: Task file modification (GREEN)

- [ ] 9. **GREEN phase (**sub-agent**).** Dispatch `test-driven-development --task green`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 10. **Z3 check GREEN (**inline**).** Run `solve check` against green-phase output contract (`contracts/green-phase-output-template.yaml`). **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 11. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-1**

- [ ] 12. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-green-enforcement output contract (`contracts/post-green-enforcement-output-template.yaml`). **→ SC-1**

### Checkpoint

- [ ] 13. **Checkpoint tag create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ All SCs**

- [ ] 14. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ All SCs**

### Verification

- [ ] 15. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-1**

- [ ] 16. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 17. **GREEN VbC (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

### Audit

- [ ] 18. **Adversarial audit (**orchestrator multi-dispatch**).**
  1. Run `.opencode/tools/resolve-models` to select cross-family auditors
  2. Dispatch `adversarial-audit --task verification-audit` with `subagent_type` from `auditor_1`
  3. On non-clean-pass: remediate root cause, restart from resolve-models
  4. Dispatch same audit task with `subagent_type` from `auditor_2`
  5. On non-clean-pass: remediate root cause, restart from resolve-models
  6. Both clean PASS: collect both `artifact_path` values
  - **→ All SCs**

- [ ] 19. **Cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate` with `auditor_artifact_paths` from step 18. **→ All SCs**

### Global Post-Steps

- [ ] 20. **Regression check (**sub-agent**).** Dispatch `test-driven-development --task patterns` (regression). **→ SC-6**

- [ ] 21. **Review prep (**sub-agent**).** Dispatch `git-workflow --task review-prep`. **→ SC-1, SC-5**

- [ ] 22. **Executive summary (**sub-agent**).** Dispatch `completion-core --task completion`. **→ All SCs**

#### Phase 01 VbC

- [ ] 23. **VbC (**clean-room**).** Dispatch a clean-room sub-agent with the deliverable (modified `push-and-cleanup.md`, behavioral test) and the 6 SCs. The sub-agent independently reads the files, evaluates each SC against the spec, and returns a PASS/FAIL verdict per SC. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

## Exit Criteria

- [ ] **C1.** Staleness-check step (`git rev-list --count --left-right`) added to `review-prep/push-and-cleanup.md` before Step 1.5
- [ ] **C2.** Behavioral enforcement test exists at `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh`
- [ ] **C3.** Behavioral test passes (GREEN) — agent auto-rebases on staleness
- [ ] **C4.** All existing enforcement tests pass (no regression)
- [ ] **C5.** Adversarial audit consensus PASS
- [ ] **C6.** All changes committed on feature branch
- [ ] **C7.** All 22 pipeline gates executed in order with PASS
- [ ] **C8.** Dual-auditor consensus achieved with no unresolved disagreements
- [ ] **C9.** Regression suite passes with no regressions
- [ ] **C10.** Review-prep completes successfully

> **⚠️ COMPLIANCE REQUIREMENT:** This plan is a binding implementation contract. Every step MUST be executed in order. No step may be skipped, reordered, or combined. Each step's dispatch indicator (`(**sub-agent**)`, `(**inline**)`) is mandatory. The orchestrator MUST follow the exact dispatch pattern specified. Violations produce defective deliverables that require rework from scratch and loss of all prior work.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If any step fails verification, the orchestrator MUST NOT halt immediately. It MUST: (1) diagnose the root cause, (2) remediate the defect, (3) re-verify, and (4) proceed on PASS. Only on double-failure (remediation also fails) does the orchestrator HALT with escalation. This applies to ALL steps — RED, GREEN, Z3 checks, doublechecks, enforcement gates, audits, and cross-validate.

## Self-Review Evidence

| Check | Status | Evidence |
|-------|--------|----------|
| Spec coverage | ✅ | All 6 SCs (SC-1 through SC-6) mapped to steps 1-23 |
| Placeholder detection | ✅ | No TBD/TODO found in plan |
| Dispatch indicator consistency | ✅ | 16 sub-agent, 5 inline, 1 multi-dispatch, 1 clean-room — all match SKILL.md |
| Pipeline gate completeness | ✅ | All 22 gates from implementation-pipeline dispatch routing table present |
| TDD structure | ✅ | RED (step 3) → Z3 (4) → doublecheck (5) → Z3 (6) → enforcement (7) → Z3 (8); GREEN (9) → Z3 (10) → enforcement (11) → Z3 (12) |
| Exit criteria completeness | ✅ | 10 exit criteria (C1-C10) covering all SCs and pipeline requirements |
| No inline semantic assertions | ✅ | All sub-agent steps dispatch only — no "verify/confirm/check that X" language. Sub-agents produce their own result contracts. |
