# Implementation Plan — [#1838](https://github.com/michael-conrad/.opencode/issues/1838) — Remove Dead-Weight yaml+symbolic Blocks

- **Goal:** Remove all `yaml+symbolic` code-fenced blocks from 54 files (35 SKILL.md, 16 task files, 3 reference files), update tooling, fix misleading claim, and verify no content loss or behavioral regression.
- **Architecture:** 8 sequential phases — removal (Phases 1-3) → fix (Phase 4) → tooling (Phases 5-7) → docs (Phase 8). Each removal phase includes content-loss verification. All phases include behavioral regression testing.
- **Files:** 35 `skills/*/SKILL.md` files, 16 `skills/*/tasks/*.md` files, 3 reference files, `guidelines/000-critical-rules.md`, `tools/skildeck/`, `skills/skill-creator/`, `tests/test-enforcement.sh`, `guidelines/` docs.

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the result before proceeding. Do NOT batch steps, skip verification, or assume a step succeeded without checking. Each step's output is the next step's input — skipping verification means propagating unknown state.

> **Step Status:** After each step, report: `Step N: <status> — <brief summary>`. Status is PASS, FAIL, or BLOCKED. On FAIL or BLOCKED, HALT and report the issue.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Remove yaml+symbolic from SKILL.md files | Remove blocks from 35 SKILL.md files, migrate orphan rules to prose | SC-1, SC-10, SC-11, SC-12 | None | 1-12 |
| 2 | Remove yaml+symbolic from task files | Remove blocks from 16 task files, handle duplicate boilerplate | SC-2, SC-10, SC-11, SC-12 | Phase 1 | 13-24 |
| 3 | Remove yaml+symbolic from reference files | Remove blocks from 3 reference files | SC-3, SC-10, SC-11, SC-12 | Phase 2 | 25-36 |
| 4 | Update 000-critical-rules.md misleading claim | Fix line 12 misleading "machine-parseable" claim | SC-4 | Phase 3 | 37-42 |
| 5 | Update skildeck tooling | Update lint/validate/extract to not require yaml+symbolic blocks | SC-5, SC-6 | Phase 4 | 43-52 |
| 6 | Update skill-creator skill | Remove yaml+symbolic generation from templates | SC-7 | Phase 5 | 53-60 |
| 7 | Update test-enforcement.sh | Remove yaml-rule content-verification scenarios, add behavioral tests | SC-8, SC-11 | Phase 6 | 61-70 |
| 8 | Update documentation | Remove references to yaml+symbolic blocks from guidelines/docs | SC-9 | Phase 7 | 71-78 |

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do NOT skip the step or mark it as "manually verified." Every step must produce a PASS result from the actual tool execution, not from manual assertion. If remediation fails after 2 attempts, HALT and report the blocker.

## Exit Criteria

- [ ] C1. No `yaml+symbolic` code-fenced blocks remain in any SKILL.md file (SC-1)
- [ ] C2. No `yaml+symbolic` code-fenced blocks remain in any task file (SC-2)
- [ ] C3. No `yaml+symbolic` code-fenced blocks remain in any reference file (SC-3)
- [ ] C4. `000-critical-rules.md` line 12 no longer contains the misleading claim (SC-4)
- [ ] C5. `skildeck lint` and `skildeck validate` pass on files without yaml+symbolic blocks (SC-5)
- [ ] C6. `skildeck extract` produces valid output from prose-only files (SC-6)
- [ ] C7. `skill-creator` templates no longer generate yaml+symbolic blocks (SC-7)
- [ ] C8. No "yaml-rule" content-verification scenarios remain in `test-enforcement.sh` (SC-8)
- [ ] C9. No documentation references yaml+symbolic blocks as required (SC-9)
- [ ] C10. No rule from any removed block was lost — every rule with enforcement value exists in prose (SC-10)
- [ ] C11. Agent behavior does not regress — existing behavioral enforcement tests all PASS (SC-11)
- [ ] C12. No SC was weakened, deferred, or reclassified to a lower evidence type (SC-12)
- [ ] C13. All 8 phase files written and validated
- [ ] C14. Plan cross-reference synced to spec issue #1838
- [ ] C15. All implementation-pipeline gate steps enumerated in phase structure
- [ ] C16. Step numbering is globally sequential across all phases
- [ ] C17. Phase exit criteria for behavioral SCs include both `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch steps
- [ ] C18. Each SC in exit criteria carries an `evidence_type` metadata annotation
- [ ] C19. VbC section for behavioral SCs includes mandatory gate: dispatch `behavioral-test-evaluation` before allowing PASS verdict
