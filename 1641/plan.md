# Implementation Plan — [#1641](https://github.com/michael-conrad/.opencode/issues/1641) — Semantic Audit Depth — Nine Evaluation Dimensions

**Spec:** #1641

**Goal:** Transform auditor sub-agents from mechanical checklists into semantic evaluators by adding nine structured evaluation dimensions (A1-A9) as integrated steps within existing adversarial-audit task files.

**Architecture:** Additive — each dimension adds new steps or criteria to existing task files (spec-audit.md, plan-fidelity.md, concern-separation.md). No new task files, no new agent cards. Each dimension produces exactly one behavioral enforcement test. Rollback checkpoints between phases.

**Files:**
- `.opencode/skills/adversarial-audit/tasks/spec-audit.md` — Phases 2-5
- `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` — Phases 3-5
- `.opencode/skills/adversarial-audit/tasks/concern-separation.md` — Phases 3-5
- `.opencode/guidelines/000-critical-rules.md` — Phase 6
- `.opencode/tests/behaviors/auditor-reasoning-soundness.sh` — Phase 2 (NEW)
- `.opencode/tests/behaviors/auditor-claim-accuracy.sh` — Phase 2 (NEW)
- `.opencode/tests/behaviors/auditor-blast-radius.sh` — Phase 3 (NEW)
- `.opencode/tests/behaviors/auditor-research-adequacy.sh` — Phase 3 (NEW)
- `.opencode/tests/behaviors/auditor-gap-analysis.sh` — Phase 4 (NEW)
- `.opencode/tests/behaviors/auditor-scope-creep.sh` — Phase 4 (NEW)
- `.opencode/tests/behaviors/auditor-scope-narrowness.sh` — Phase 4 (NEW)
- `.opencode/tests/behaviors/auditor-concern-orthogonality.sh` — Phase 5 (NEW)
- `.opencode/tests/behaviors/auditor-cross-reference-integrity.sh` — Phase 5 (NEW)
- `.opencode/tests/behaviors/full-pipeline-semantic-audit.sh` — Phase 6 (NEW)

> **Compliance requirement:** This plan is a binding execution specification. Every step MUST be executed in order. No step may be skipped, reordered, or combined. Each step produces a specific artifact or state change. If a step cannot be completed, the plan is BLOCKED and must be reported as such. The orchestrator MUST NOT deviate from this plan without explicit developer authorization. Defective deliverables are discarded and reworked from scratch with loss of all prior work — no partial salvage, no patching around failures.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the step's output before proceeding. Do not batch steps. Do not combine steps. Do not skip ahead. Each step is a discrete unit of work with a defined output.

> **Step Status instruction:** Before each step, the orchestrator MUST announce which step number it is executing. After each step, the orchestrator MUST report the step's outcome (PASS/FAIL/BLOCKED). This status reporting is mandatory for every step.

> **Cost-frame reformation:** Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics (word count, line count, token count, byte-dispatch formulas) are NOT valid proxies for implementation complexity. Orchestrator context discipline is operational bookkeeping — it describes how context flows through the pipeline, not how much work is being done.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Foundation | Already complete (#397 closed) | — | None | — |
| 2 | Reasoning + Claims | A1 (Reasoning Soundness) + A2 (Claim Accuracy) in spec-audit.md | SC-1, SC-2 | Phase 1 | 1-12 |
| 3 | Blast Radius + Research | A3 (Blast Radius) + A4 (Research Adequacy) in spec-audit.md, plan-fidelity.md, concern-separation.md | SC-3, SC-4 | Phase 2 | 13-24 |
| 4 | Scope Triad | A5 (Gap Analysis) + A6 (Scope Creep) + A7 (Scope Narrowness) in spec-audit.md, plan-fidelity.md, concern-separation.md | SC-5, SC-6, SC-7 | Phase 3 | 25-42 |
| 5 | Concerns + References | A8 (Separation of Concerns) + A9 (Cross-Reference Completeness) in concern-separation.md, spec-audit.md, plan-fidelity.md | SC-8, SC-9 | Phase 4 | 43-53 |
| 6 | Integration + Rules | Critical rules expansion + full pipeline integration test | SC-10, SC-11 | Phase 5 | 54-64 |

> **Compliance requirement:** This plan is a binding execution specification. Every step MUST be executed in order. No step may be skipped, reordered, or combined. Each step produces a specific artifact or state change. If a step cannot be completed, the plan is BLOCKED and must be reported as such. The orchestrator MUST NOT deviate from this plan without explicit developer authorization.

> **Self-remediation protocol:** If a step fails, the orchestrator MUST NOT halt immediately. Instead, attempt remediation: diagnose the root cause, fix the issue, and re-verify. Only after 2+ remediation attempts with confirmed failure should the orchestrator HALT and report BLOCKED. Rollback to the last checkpoint tag if remediation cannot resolve the failure.

## Exit Criteria

- [ ] C1. spec-audit.md includes A1 step with causal chain, SC traceability, and contradiction detection checks
- [ ] C2. spec-audit.md Step 2 extended with A2 checks (FABRICATED verdict, negation verification, interface contract verification)
- [ ] C3. spec-audit.md and plan-fidelity.md include A3 blast radius step
- [ ] C4. spec-audit.md includes A4 research adequacy step
- [ ] C5. spec-audit.md and plan-fidelity.md include A5 gap analysis step
- [ ] C6. spec-audit.md, plan-fidelity.md, and concern-separation.md include A6 scope creep step
- [ ] C7. spec-audit.md and plan-fidelity.md include A7 scope narrowness step
- [ ] C8. concern-separation.md extended with A8 SC orthogonality and cross-concern overlap detection
- [ ] C9. spec-audit.md and plan-fidelity.md include A9 cross-reference step
- [ ] C10. 000-critical-rules.md contains critical-rules-046a through 046h
- [ ] C11. All 9 behavioral tests pass (one per dimension)
- [ ] C12. Full pipeline integration test passes
