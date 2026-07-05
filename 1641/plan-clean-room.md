# Clean-Room Plan — [#1641](https://github.com/michael-conrad/.opencode/issues/1641) — Semantic Audit Depth

**Goal:** Add nine structured semantic evaluation dimensions (A1-A9) as integrated steps within existing adversarial-audit task files, plus 8 critical-rules sub-entries and 10 behavioral enforcement tests.

**Architecture:** All A1-A9 dimensions are additive steps within existing task files (spec-audit.md, plan-fidelity.md, concern-separation.md). No new task files or agent cards. Each dimension produces exactly one behavioral enforcement test. Phase 6 adds critical-rules-046a-046h and a full-pipeline integration test.

**Files:** spec-audit.md (Phases 2-5), plan-fidelity.md (Phases 3-5), concern-separation.md (Phases 3-5), 000-critical-rules.md (Phase 6), 10 behavioral tests (1 per dimension + 1 integration)

**Phase structure:** Linear chain P2→P3→P4→P5→P6. Phase 1 (Foundation) already complete.

| Phase | Name | SCs | Files |
|-------|------|-----|-------|
| 2 | Reasoning + Claims | SC-1, SC-2 | spec-audit.md |
| 3 | Blast Radius + Research | SC-3, SC-4 | spec-audit.md, plan-fidelity.md, concern-separation.md |
| 4 | Scope Triad | SC-5, SC-6, SC-7 | spec-audit.md, plan-fidelity.md, concern-separation.md |
| 5 | Concerns + References | SC-8, SC-9 | concern-separation.md, spec-audit.md, plan-fidelity.md |
| 6 | Integration + Rules | SC-10, SC-11 | 000-critical-rules.md |

**Phase 2 (Steps 1-12):** Write RED tests for A1+A2 → Add A1 step to spec-audit.md (causal chain, SC traceability, contradiction detection) → Add SC-REASONING criteria → Extend Step 2 with A2 (FABRICATED verdict, negation verification, interface contract) → Add SC-CLAIM criteria → Doublecheck → Checkpoint commit → Run tests → VbC

**Phase 3 (Steps 13-24):** Write RED tests for A3+A4 → Add blast radius step to spec-audit.md → Add research adequacy step to spec-audit.md → Add blast radius step to plan-fidelity.md → Extend CS-6 with srclight_get_dependents → Doublecheck → Checkpoint commit → Run tests → VbC

**Phase 4 (Steps 25-42):** Write RED tests for A5+A6+A7 → Add gap analysis + scope creep + scope narrowness to spec-audit.md → Add same to plan-fidelity.md → Add scope creep to concern-separation.md → Doublecheck → Checkpoint commit → Run tests → VbC

**Phase 5 (Steps 43-53):** Write RED tests for A8+A9 → Extend concern-separation.md with SC orthogonality + cross-concern overlap → Add cross-reference step to spec-audit.md and plan-fidelity.md → Doublecheck → Checkpoint commit → Run tests → VbC

**Phase 6 (Steps 54-64):** Write RED integration test → Add critical-rules-046a-046h to 000-critical-rules.md → Generalize FABRICATED verdict to spec-audit.md and plan-fidelity.md → Doublecheck → Checkpoint commit → Run integration test → Run all 9 behavioral tests → VbC → Global post-steps (collect evidence, lint, content-verification)

**Exit criteria:** All 11 SCs verified. All 10 behavioral tests pass. All 4 task files modified. 000-critical-rules.md expanded with 8 sub-rules. FABRICATED verdict generalized.
