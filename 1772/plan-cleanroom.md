# Clean-Room Plan — #1672 — DiMo-Aligned Adversarial Audit

**Goal:** Replace cross-model adversarial audit with DiMo same-model role-differentiated agent chaining.

**Architecture:** 5 sequential phases: (1) delete old infrastructure, (2) create role card, (3) refactor task files, (4) update SKILL.md, (5) behavioral tests.

**Files:** 6 deletes, 1 create, 15 modifies, 2 creates — all within `.opencode/`.

**Phase table:**
| Phase | Name | SCs | Depends On |
|-------|------|-----|------------|
| 1 | Eliminate Cross-Model Infrastructure | SC-1, SC-2, SC-3, SC-12 | None |
| 2 | Create DiMo Role Card | SC-4 | Phase 1 |
| 3 | Refactor 15 Task Files | SC-5 through SC-11 | Phase 1, 2 |
| 4 | Update SKILL.md | SC-5 | Phase 1, 2, 3 |
| 5 | Behavioral Tests | SC-13, SC-14 | Phase 1, 2, 3, 4 |

Each phase follows implementation-pipeline RED/GREEN cycle with checkpoint commits.
