# Phase 1: Restore Hard-Gate Content to SKILL.md

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-10
**Evidence types:** `string` (all)
**Chain:** none (first phase)

## Concern

Restore enforcement content that was moved from SKILL.md to `tasks/operating-protocol.md` during the DISPATCH_GATE migration (bfb0a212). The `skill()` function loads SKILL.md only — content in `operating-protocol.md` is invisible to every agent in the execution chain.

## Steps

- [ ] 1. (**sub-agent**) Read `test-driven-development/tasks/operating-protocol.md` — extract the Five Core Principles (lines 8-15: FAIL=FAIL, RED/GREEN separation, TDD discipline, Clean-room, Independent intelligence, Verify LIVE)
  - Dispatch: `task(..., prompt: "execute research task from writing-plans")`
  - Chain: `none`
  - Expected: extracted principles text

- [ ] 2. (**inline**) Z3 check — verify research output contains extracted principles
  - Command: `solve check`
  - Chain: `step_1`

- [ ] 3. (**sub-agent**) Restore Five Core Principles to `test-driven-development/SKILL.md`
  - Read current SKILL.md §Five Core Principles (currently a pointer: "See `test-driven-development/tasks/operating-protocol.md` for the Five Core Principles")
  - Replace the pointer with the full inline prose from `operating-protocol.md` lines 8-15
  - **SC-1:** Verify `grep -q "RED and GREEN may NEVER be combined" test-driven-development/SKILL.md` returns 0
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_2`
  - Expected: SKILL.md updated with inline Five Core Principles

- [ ] 4. (**inline**) Z3 check — verify write output contains file path
  - Command: `solve check`
  - Chain: `step_3`

- [ ] 5. (**sub-agent**) Clean-room plan generation — restore Five Core Principles to `test-driven-development/SKILL.md` (spec body only, no existing plan context)
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_4`
  - Expected: clean_room_plan in output

- [ ] 6. (**inline**) Z3 check — verify clean-room plan output contains clean_room_plan
  - Command: `solve check`
  - Chain: `step_5`

- [ ] 7. (**sub-agent**) Update `test-driven-development/tasks/operating-protocol.md` — remove the Five Core Principles content (lines 8-15), replace with pointer: "See SKILL.md §Five Core Principles for enforcement rules"
  - **SC-2:** Verify `grep -c "Five Core Principles" test-driven-development/tasks/operating-protocol.md` returns 0 or only a pointer reference
  - Dispatch: `task(..., prompt: "execute revisit task from writing-plans")`
  - Chain: `step_6`
  - Expected: operating-protocol.md updated

- [ ] 8. (**inline**) Z3 check — verify revisit output has resolution_status
  - Command: `solve check`
  - Chain: `step_7`

- [ ] 9. (**sub-agent**) Read `writing-plans/tasks/operating-protocol.md` — extract the 22-step pipeline operating protocol (lines 8-37)
  - Dispatch: `task(..., prompt: "execute research task from writing-plans")`
  - Chain: `step_8`
  - Expected: extracted operating protocol text

- [ ] 10. (**inline**) Z3 check — verify research output contains extracted protocol
  - Command: `solve check`
  - Chain: `step_9`

- [ ] 11. (**sub-agent**) Restore operating protocol to `writing-plans/SKILL.md`
  - Read current SKILL.md §Operating Protocol (currently a pointer: "See `writing-plans/tasks/operating-protocol.md` for the full 22-step pipeline")
  - Replace the pointer with the full inline prose from `operating-protocol.md` lines 8-37
  - **SC-3:** Verify `grep` for key operating protocol phrases in SKILL.md returns matches
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_10`
  - Expected: SKILL.md updated with inline operating protocol

- [ ] 12. (**inline**) Z3 check — verify write output contains file path
  - Command: `solve check`
  - Chain: `step_11`

- [ ] 13. (**sub-agent**) Clean-room plan generation — restore operating protocol to `writing-plans/SKILL.md` (spec body only, no existing plan context)
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_12`
  - Expected: clean_room_plan in output

- [ ] 14. (**inline**) Z3 check — verify clean-room plan output contains clean_room_plan
  - Command: `solve check`
  - Chain: `step_13`

- [ ] 15. (**sub-agent**) Update `writing-plans/tasks/operating-protocol.md` — remove the restored content, replace with pointer: "See SKILL.md §Operating Protocol for enforcement rules"
  - **SC-4:** Verify `grep` for restored phrases in operating-protocol.md — must be absent or reduced to a pointer
  - Dispatch: `task(..., prompt: "execute revisit task from writing-plans")`
  - Chain: `step_14`
  - Expected: operating-protocol.md updated

- [ ] 16. (**inline**) Z3 check — verify revisit output has resolution_status
  - Command: `solve check`
  - Chain: `step_15`

- [ ] 17. (**sub-agent**) Restore content to `implementation-pipeline/SKILL.md` — the spec notes 15 lines were moved to `tasks/operating-protocol.md` (which does not exist on disk — content was deleted entirely). Read commit bfb0a212 to identify what was moved. Restore any hard-gate enforcement content to SKILL.md.
  - **SC-5:** Verify `grep` for key phrases in SKILL.md returns matches
  - **SC-10:** Verify deleted content (`assemble-work.md`, `pipeline-executor.md`) is either restored or integrated into SKILL.md
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_16`
  - Expected: SKILL.md updated

- [ ] 18. (**inline**) Z3 check — verify write output contains file path
  - Command: `solve check`
  - Chain: `step_17`

- [ ] 19. (**sub-agent**) Validate — run validation checks on all modified files
  - Dispatch: `task(..., prompt: "execute validate task from writing-plans")`
  - Chain: `step_18`
  - Expected: PASS status

- [ ] 20. (**inline**) Z3 check — verify validate output has PASS status
  - Command: `solve check`
  - Chain: `step_19`

- [ ] 21. (**sub-agent**) Audit fidelity — verify restored content matches original intent
  - Dispatch: `task(..., prompt: "execute audit-fidelity task from writing-plans")`
  - Chain: `step_20`
  - Expected: PASS in audit-fidelity output

- [ ] 22. (**inline**) Z3 check — verify audit-fidelity output has PASS AND `all_criteria_pass == true`
  - Command: `solve check`
  - Chain: `step_21`

- [ ] 23. (**sub-agent**) Audit concern — verify separation of concerns is maintained
  - Dispatch: `task(..., prompt: "execute audit-concern task from writing-plans")`
  - Chain: `step_22`
  - Expected: PASS in audit-concern output

- [ ] 24. (**inline**) Z3 check — verify audit-concern output has PASS AND `all_criteria_pass == true`
  - Command: `solve check`
  - Chain: `step_23`

- [ ] 25. (**sub-agent**) Completion — signal phase 1 complete
  - Dispatch: `task(..., prompt: "execute completion task from writing-plans")`
  - Chain: `step_24`
  - Expected: lifecycle event in completion output

- [ ] 26. (**inline**) Z3 check — verify completion output has lifecycle event
  - Command: `solve check`
  - Chain: `step_25`

## VbC (Verification before Completion)

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `test-driven-development/SKILL.md` contains Five Core Principles including RED/GREEN interleaving hard gate | `string` | `grep -q "RED and GREEN may NEVER be combined" test-driven-development/SKILL.md` |
| SC-2 | `test-driven-development/tasks/operating-protocol.md` no longer contains Five Core Principles as primary | `string` | `grep -c "Five Core Principles" test-driven-development/tasks/operating-protocol.md` returns 0 or pointer only |
| SC-3 | `writing-plans/SKILL.md` contains operating protocol content from `tasks/operating-protocol.md` | `string` | `grep` for key operating protocol phrases in SKILL.md |
| SC-4 | `writing-plans/tasks/operating-protocol.md` no longer contains restored content as primary | `string` | `grep` for restored phrases — absent or reduced to pointer |
| SC-5 | `implementation-pipeline/SKILL.md` contains content moved to `tasks/operating-protocol.md` | `string` | `grep` for key phrases in SKILL.md |
| SC-10 | `implementation-pipeline/tasks/assemble-work.md` and `pipeline-executor.md` content restored or integrated | `string` | Verify deleted content is present in SKILL.md or files recreated with dispatch entries |

## Phase Completion

- [ ] All SCs verified PASS
- [ ] Evidence artifacts written to `tmp/1836/phase-1-evidence/`
- [ ] Phase 1 complete — proceed to Phase 2
