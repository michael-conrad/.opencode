# Implementation Plan — [`.opencode#1372`](https://github.com/michael-conrad/.opencode/issues/1372) — writing-plans dispatch classification fix

- [ ] **Goal:** Fix the `writing-plans` skill's Trigger Dispatch Table which classifies orchestrator tasks (`create`, `retroactive`, `completion`) as `sub-task`, making them impossible to execute. Purge the deprecated `tasks/create/` subdirectory. Embed the canonical Plan Format Requirements section in `create.md`. 13 fix items across 2 phases.
- [ ] **Architecture:** Phase 1 → Phase 2 (sequential). Phase 1 fixes all task file content and SKILL.md metadata, and adds the Plan Format Requirements section to `create.md`. Phase 2 purges the deprecated `create/` subdirectory — depends on Phase 1 removing all references to those files first.
- [ ] **Files:**
  - `.opencode/skills/writing-plans/SKILL.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/create.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/completion.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/retroactive.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/audit-fidelity.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/audit-concern.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` — Phase 2 (DELETE)
  - `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — Phase 2 (DELETE)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1 — Fix Dispatch Classification and Task Files

**Concern:** writing-plans skill metadata and task file content
**Files:** SKILL.md, create.md, completion.md, retroactive.md, audit-fidelity.md, audit-concern.md
**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14, SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26
**Dependencies:** None
**Entry condition:** SKILL.md Trigger Dispatch Table classifies `create`, `retroactive`, `completion` as `sub-task`. Invocation table lists them as `task()` calls. Sub-Agent Routing claims "All tasks run via `task()`" and "No inline work". create.md operating protocol missing 11 steps. completion.md contains `task()` calls and skill invocations. retroactive.md is a simplified 3-step procedure. audit-fidelity.md and audit-concern.md contain "with auditor sub-agent type context". create.md has no Plan Format Requirements section.
**Exit condition:** All 26 SCs pass. Trigger Dispatch Table correct. All task files aligned with 21-step pipeline. No orchestrator-level operations in sub-task files. create.md has canonical Plan Format Requirements section.

**Artifact paths:** `./tmp/1372/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 1. **Coherence gate (**clean-room**).** Verify all 26 SCs are coherent and non-conflicting.
  - [ ] 1a. Read spec SC table, confirm evidence types match verification methods
  - [ ] 1b. Read current state of all 6 files to confirm defects exist as described
- [ ] 2. **Pre-RED baseline (**clean-room**).** Capture current state of all 6 files.
  - [ ] 2a. Record line counts for all 6 files
  - [ ] 2b. grep for `sub-task` in Trigger Dispatch Table rows for create/retroactive/completion
  - [ ] 2c. grep for `task(` in completion.md
  - [ ] 2d. grep for `invoke` in completion.md
  - [ ] 2e. grep for "All tasks run via" and "No inline work" in SKILL.md
  - [ ] 2f. grep for "with auditor sub-agent type context" in audit-fidelity.md and audit-concern.md
  - [ ] 2g. Count steps in create.md operating protocol
  - [ ] 2h. Count steps in retroactive.md
  - [ ] 2i. grep for "Spec-to-plan handoff" in create.md entry criteria
  - [ ] 2j. grep for `completion-core.md` in completion.md
  - [ ] 2k. grep for `## Plan Format Requirements` in create.md — must be absent
  - [ ] 2l. Save all baselines

#### RED+green P1-I1 — Fix SKILL.md Trigger Dispatch Table

- [ ] 3. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'create plan for #1372' --model <model>` to capture agent behavior. Save stdout/stderr to `./tmp/1372/artifacts/red-p1i1-stderr.log`.
- [ ] 4. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i1-stderr.log`. Assert stderr shows `Skill "writing-plans"` dispatched with `--task create` as `sub-task` (not `orchestrator`). Must FAIL because Trigger Dispatch Table still says `sub-task`. **→ SC-1, SC-2, SC-3**
- [ ] 5. **RED doublecheck (**clean-room**).** Confirm Step 4 returned FAIL as expected.
- [ ] 6. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 7. **GREEN (**clean-room**).** Fix SKILL.md Trigger Dispatch Table dispatch types. **→ SC-1, SC-2, SC-3**
  - [ ] 7a. Change `create` dispatch type from `sub-task` to `orchestrator`
  - [ ] 7b. Change `retroactive` dispatch type from `sub-task` to `orchestrator`
  - [ ] 7c. Change `completion` dispatch type from `sub-task` to `orchestrator`
- [ ] 8. **Post-GREEN enforcement (**clean-room**).** Verify SKILL.md was modified.
- [ ] 9. **Structural checks (**clean-room**).** `wc -w` on SKILL.md — under 4,000 words.
- [ ] 10. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'create plan for #1372' --model <model>` again. Save stdout/stderr to `./tmp/1372/artifacts/green-p1i1-stderr.log`.
- [ ] 11. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i1-stderr.log`. Assert stderr shows `Skill "writing-plans"` dispatched with `--task create` as `orchestrator` (not `sub-task`). Must PASS. **→ SC-1, SC-2, SC-3**
  - [ ] 11a. grep for `create.*orchestrator` in SKILL.md — present
  - [ ] 11b. grep for `retroactive.*orchestrator` in SKILL.md — present
  - [ ] 11c. grep for `completion.*orchestrator` in SKILL.md — present
  - [ ] 11d. grep for `create.*sub-task` in Trigger Dispatch Table — absent
- [ ] 12. **Checkpoint commit (**inline**).** `git commit -m "SKILL.md: fix Trigger Dispatch Table — create/retroactive/completion → orchestrator"`

#### RED+green P1-I2 — Fix SKILL.md Invocation table

- [ ] 13. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'create plan for #1372' --model <model>`. Save stdout/stderr to `./tmp/1372/artifacts/red-p1i2-stderr.log`.
- [ ] 14. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i2-stderr.log`. Assert stderr does NOT contain `task(..., prompt: "execute create task"`. Must FAIL because Invocation table still lists orchestrator tasks as `task()` calls. **→ SC-4**
- [ ] 15. **RED doublecheck (**clean-room**).** Confirm Step 14 returned FAIL as expected.
- [ ] 16. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 17. **GREEN (**clean-room**).** Fix SKILL.md Invocation table. **→ SC-4**
  - [ ] 17a. Remove `task()` call entries for `create`, `completion`, `retroactive`
  - [ ] 17b. Replace with instruction that orchestrator reads task file and executes steps inline — does not `task()` itself
- [ ] 18. **Post-GREEN enforcement (**clean-room**).** Verify Invocation table modified.
- [ ] 19. **Structural checks (**clean-room**).** `wc -w` on SKILL.md — under 4,000 words.
- [ ] 20. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'create plan for #1372' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i2-stderr.log`.
- [ ] 21. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i2-stderr.log`. Assert stderr does NOT contain `task(..., prompt: "execute create task"`. Must PASS. **→ SC-4**
  - [ ] 21a. grep for `task(..., prompt: "execute create task"` in SKILL.md — absent
  - [ ] 21b. grep for `task(..., prompt: "execute completion task"` in SKILL.md — absent
  - [ ] 21c. grep for `task(..., prompt: "execute retroactive task"` in SKILL.md — absent
- [ ] 22. **Checkpoint commit (**inline**).** `git commit -m "SKILL.md: fix Invocation table — orchestrator reads task file, does not task() itself"`

#### RED+green P1-I3 — Fix SKILL.md §Sub-Agent Routing

- [ ] 23. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'describe how writing-plans create task works' --model <model>`. Save to `./tmp/1372/artifacts/red-p1i3-stderr.log`.
- [ ] 24. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i3-stderr.log`. Assert agent states that orchestrator tasks run via `task()`. Must FAIL because SKILL.md still contains false claims. **→ SC-11, SC-12**
- [ ] 25. **RED doublecheck (**clean-room**).** Confirm Step 24 returned FAIL as expected.
- [ ] 26. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 27. **GREEN (**clean-room**).** Remove false claims from SKILL.md §Sub-Agent Routing. **→ SC-11, SC-12**
  - [ ] 27a. Remove sentence "All tasks run via `task(subagent_type="general")`"
  - [ ] 27b. Remove sentence "No inline work"
- [ ] 28. **Post-GREEN enforcement (**clean-room**).** Verify both sentences removed.
- [ ] 29. **Structural checks (**clean-room**).** `wc -w` on SKILL.md — under 4,000 words.
- [ ] 30. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'describe how writing-plans create task works' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i3-stderr.log`.
- [ ] 31. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i3-stderr.log`. Assert agent does NOT state that orchestrator tasks run via `task()`. Must PASS. **→ SC-11, SC-12**
  - [ ] 31a. grep for "All tasks run via" in SKILL.md — absent
  - [ ] 31b. grep for "No inline work" in SKILL.md — absent
- [ ] 32. **Checkpoint commit (**inline**).** `git commit -m "SKILL.md: fix Sub-Agent Routing — remove false claims about task() and inline work"`

#### RED+green P1-I4 — Fix audit-fidelity.md and audit-concern.md

- [ ] 33. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute audit-fidelity task from writing-plans' --model <model>`. Save to `./tmp/1372/artifacts/red-p1i4-stderr.log`.
- [ ] 34. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i4-stderr.log`. Assert stderr contains "with auditor sub-agent type context". Must FAIL because audit files still contain the phrase. **→ SC-5, SC-6**
- [ ] 35. **RED doublecheck (**clean-room**).** Confirm Step 34 returned FAIL as expected.
- [ ] 36. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 37. **GREEN (**clean-room**).** Remove "with auditor sub-agent type context" from audit files. **→ SC-5, SC-6**
  - [ ] 37a. Remove phrase from audit-fidelity.md
  - [ ] 37b. Remove phrase from audit-concern.md
- [ ] 38. **Post-GREEN enforcement (**clean-room**).** Verify both files modified.
- [ ] 39. **Structural checks (**clean-room**).** `wc -w` on both files — each under 3,000 words.
- [ ] 40. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute audit-fidelity task from writing-plans' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i4-stderr.log`.
- [ ] 41. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i4-stderr.log`. Assert stderr does NOT contain "with auditor sub-agent type context". Must PASS. **→ SC-5, SC-6**
  - [ ] 41a. grep for "with auditor sub-agent type context" in audit-fidelity.md — absent
  - [ ] 41b. grep for "with auditor sub-agent type context" in audit-concern.md — absent
- [ ] 42. **Checkpoint commit (**inline**).** `git commit -m "audit-fidelity.md, audit-concern.md: remove 'with auditor sub-agent type context'"`

#### RED+green P1-I5 — Fix create.md operating protocol

- [ ] 43. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute create task from writing-plans' --model <model>`. Save to `./tmp/1372/artifacts/red-p1i5-stderr.log`.
- [ ] 44. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i5-stderr.log`. Assert orchestrator follows fewer than 21 steps. Must FAIL because operating protocol only has 7 steps. **→ SC-7**
- [ ] 45. **RED doublecheck (**clean-room**).** Confirm Step 44 returned FAIL as expected.
- [ ] 46. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 47. **GREEN (**clean-room**).** Add missing steps to create.md operating protocol. **→ SC-7**
  - [ ] 47a. Add missing `[inline]` step 1 (verify spec approved)
  - [ ] 47b. Add all 10 `[z3-check]` steps from the 21-step pipeline in SKILL.md
  - [ ] 47c. Verify operating protocol lists exactly 21 steps: 1 inline + 10 sub-task + 10 z3-check
- [ ] 48. **Post-GREEN enforcement (**clean-room**).** Verify create.md operating protocol modified.
- [ ] 49. **Structural checks (**clean-room**).** `wc -w` on create.md — under 3,000 words.
- [ ] 50. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute create task from writing-plans' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i5-stderr.log`.
- [ ] 51. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i5-stderr.log`. Assert orchestrator follows exactly 21 steps (1 inline + 10 sub-task + 10 z3-check). Must PASS. **→ SC-7**
  - [ ] 51a. Count steps in create.md operating protocol — exactly 21
  - [ ] 51b. Verify 1 `[inline]` step present
  - [ ] 51c. Verify 10 `[sub-task:` steps present
  - [ ] 51d. Verify 10 `[z3-check]` steps present
- [ ] 52. **Checkpoint commit (**inline**).** `git commit -m "create.md: add missing 11 steps to operating protocol — now 21 steps"`

#### RED+green P1-I6 — Fix create.md entry criteria

- [ ] 53. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute create task from writing-plans' --model <model>`. Save to `./tmp/1372/artifacts/red-p1i6-stderr.log`.
- [ ] 54. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i6-stderr.log`. Assert orchestrator checks for spec-to-plan handoff artifact before proceeding. Must FAIL because entry criteria still requires it. **→ SC-13**
- [ ] 55. **RED doublecheck (**clean-room**).** Confirm Step 54 returned FAIL as expected.
- [ ] 56. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 57. **GREEN (**clean-room**).** Remove circular "Spec-to-plan handoff PASS" from create.md entry criteria. **→ SC-13**
- [ ] 58. **Post-GREEN enforcement (**clean-room**).** Verify entry criteria modified.
- [ ] 59. **Structural checks (**clean-room**).** `wc -w` on create.md — under 3,000 words.
- [ ] 60. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute create task from writing-plans' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i6-stderr.log`.
- [ ] 61. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i6-stderr.log`. Assert orchestrator does NOT check for spec-to-plan handoff artifact. Must PASS. **→ SC-13**
  - [ ] 61a. grep for "Spec-to-plan handoff" in create.md — absent
- [ ] 62. **Checkpoint commit (**inline**).** `git commit -m "create.md: remove circular Spec-to-plan handoff from entry criteria"`

#### RED+green P1-I7 — Fix create.md line 5 and Sub-Task Files table

- [ ] 63. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute create task from writing-plans' --model <model>`. Save to `./tmp/1372/artifacts/red-p1i7-stderr.log`.
- [ ] 64. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i7-stderr.log`. Assert orchestrator routes to `create/` subdirectory files. Must FAIL because create.md still references them. **→ SC-16**
- [ ] 65. **RED doublecheck (**clean-room**).** Confirm Step 64 returned FAIL as expected.
- [ ] 66. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 67. **GREEN (**clean-room**).** Remove stale references from create.md. **→ SC-16**
  - [ ] 67a. Remove claim of "10 decomposed sub-task files" from line 5
  - [ ] 67b. Remove entire §Sub-Task Files table (lines 51-56)
- [ ] 68. **Post-GREEN enforcement (**clean-room**).** Verify both removed.
- [ ] 69. **Structural checks (**clean-room**).** `wc -w` on create.md — under 3,000 words.
- [ ] 70. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute create task from writing-plans' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i7-stderr.log`.
- [ ] 71. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i7-stderr.log`. Assert orchestrator does NOT route to `create/` subdirectory files. Must PASS. **→ SC-16**
  - [ ] 71a. grep for "10 decomposed sub-task files" in create.md — absent
  - [ ] 71b. grep for `create-and-validate\|plan-structure` in create.md — absent
- [ ] 72. **Checkpoint commit (**inline**).** `git commit -m "create.md: remove stale sub-task file claims and Sub-Task Files table"`

#### RED+green P1-I8 — Fix completion.md

- [ ] 73. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute completion task from writing-plans' --model <model>`. Save to `./tmp/1372/artifacts/red-p1i8-stderr.log`.
- [ ] 74. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i8-stderr.log`. Assert sub-agent attempts to dispatch `task()` or invoke other skills. Must FAIL because completion.md still contains orchestrator-level operations. **→ SC-8, SC-9, SC-14**
- [ ] 75. **RED doublecheck (**clean-room**).** Confirm Step 74 returned FAIL as expected.
- [ ] 76. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 77. **GREEN (**clean-room**).** Remove orchestrator-level operations from completion.md. **→ SC-8, SC-9, SC-14**
  - [ ] 77a. Remove `task()` call at line 31
  - [ ] 77b. Remove "invoke `writing-plans --task create`" at line 16
  - [ ] 77c. Remove "invoke `issue-operations --task link-sub-issue`" at line 20
  - [ ] 77d. Remove "invoke `writing-plans --task validate`" at line 24
  - [ ] 77e. Fix line 41 path from `.opencode/skills/completion-core/completion-core.md` to `completion-core/SKILL.md`
- [ ] 78. **Post-GREEN enforcement (**clean-room**).** Verify completion.md modified.
- [ ] 79. **Structural checks (**clean-room**).** `wc -w` on completion.md — under 3,000 words.
- [ ] 80. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute completion task from writing-plans' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i8-stderr.log`.
- [ ] 81. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i8-stderr.log`. Assert sub-agent does NOT dispatch `task()` or invoke other skills. Must PASS. **→ SC-8, SC-9, SC-14**
  - [ ] 81a. grep for `task(` in completion.md — absent
  - [ ] 81b. grep for `invoke` in completion.md — absent
  - [ ] 81c. grep for `completion-core/SKILL.md` in completion.md — present
- [ ] 82. **Checkpoint commit (**inline**).** `git commit -m "completion.md: remove task() calls, skill invocations, fix path reference"`

#### RED+green P1-I9 — Fix retroactive.md

- [ ] 83. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute retroactive task from writing-plans' --model <model>`. Save to `./tmp/1372/artifacts/red-p1i9-stderr.log`.
- [ ] 84. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i9-stderr.log`. Assert orchestrator follows a simplified 3-step procedure (not 21-step pipeline). Must FAIL because retroactive.md is still simplified. **→ SC-10**
- [ ] 85. **RED doublecheck (**clean-room**).** Confirm Step 84 returned FAIL as expected.
- [ ] 86. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 87. **GREEN (**clean-room**).** Fix retroactive.md to align with 21-step pipeline. **→ SC-10**
  - [ ] 87a. Replace simplified 3-step procedure with the 21-step pipeline from SKILL.md retroactive operating protocol
  - [ ] 87b. Remove "Run `validate` task checks" at line 36
  - [ ] 87c. Remove "issue-operations -> read-sub-issues" at line 37
- [ ] 88. **Post-GREEN enforcement (**clean-room**).** Verify retroactive.md modified.
- [ ] 89. **Structural checks (**clean-room**).** `wc -w` on retroactive.md — under 3,000 words.
- [ ] 90. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute retroactive task from writing-plans' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i9-stderr.log`.
- [ ] 91. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i9-stderr.log`. Assert orchestrator follows 21-step pipeline. Must PASS. **→ SC-10**
  - [ ] 91a. Count steps in retroactive.md — 21
  - [ ] 91b. grep for "Run `validate` task checks" — absent
  - [ ] 91c. grep for "issue-operations -> read-sub-issues" — absent
- [ ] 92. **Checkpoint commit (**inline**).** `git commit -m "retroactive.md: align with 21-step pipeline, remove sub-task dispatches"`

#### RED+green P1-I10 — Add Plan Format Requirements section to create.md

- [ ] 93. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'create plan for #1372' --model <model>`. Save to `./tmp/1372/artifacts/red-p1i10-stderr.log`.
- [ ] 94. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p1i10-stderr.log`. Assert produced plan does NOT follow canonical format (missing sequential numbering, dispatch indicators, admonishment, RED+green chains, phase completion blocks, concern transitions, exit criteria). Must FAIL because create.md has no Plan Format Requirements section. **→ SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26**
- [ ] 95. **RED doublecheck (**clean-room**).** Confirm Step 94 returned FAIL as expected.
- [ ] 96. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 97. **GREEN (**clean-room**).** Add `## Plan Format Requirements` section to create.md. **→ SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26**
  - [ ] 97a. Add all 14 required sections in order (title, goal/architecture/files, admonishment, phase sections, phase metadata, sequential numbering, dispatch indicators with all three modes, sub-steps, RED+green item chains, SC annotations, phase completion block, concern transitions, bottom admonishment, exit criteria)
  - [ ] 97b. Add admonishment text verbatim
  - [ ] 97c. Add prohibited patterns list (dispatch tables, hardcoded gate sequences, TBD/TODO, shared cross-references, zero-indexed numbering, line number references)
  - [ ] 97d. Add all 12 validation rules
  - [ ] 97e. Add dispatch indicator specification with `(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`
  - [ ] 97f. Add RED+green item chain specification with interleaved ordering
  - [ ] 97g. Add phase completion block specification
  - [ ] 97h. Add concern transition specification
  - [ ] 97i. Add exit criteria specification
- [ ] 98. **Post-GREEN enforcement (**clean-room**).** Verify create.md modified with new section.
- [ ] 99. **Structural checks (**clean-room**).** `wc -w` on create.md — under 3,000 words.
- [ ] 100. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'create plan for #1372' --model <model>` again. Save to `./tmp/1372/artifacts/green-p1i10-stderr.log`.
- [ ] 101. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p1i10-stderr.log`. Assert produced plan follows canonical format. Must PASS. **→ SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26**
  - [ ] 101a. grep for `## Plan Format Requirements` in create.md — present
  - [ ] 101b. grep for "Compliance Requirement" in create.md — present
  - [ ] 101c. grep for `(**sub-agent**)` in create.md — present
  - [ ] 101d. grep for `(**clean-room**)` in create.md — present
  - [ ] 101e. grep for `(**inline**)` in create.md — present
  - [ ] 101f. grep for "Prohibited Patterns" in create.md — present
  - [ ] 101g. grep for "RED+green" in create.md — present
  - [ ] 101h. grep for "Phase completion" in create.md — present
  - [ ] 101i. grep for "Concern transition" in create.md — present
  - [ ] 101j. grep for "Exit Criteria" in create.md — present
  - [ ] 101k. Count validation rules in Plan Format Requirements section — 12
- [ ] 102. **Checkpoint commit (**inline**).** `git commit -m "create.md: add canonical Plan Format Requirements section"`

#### Phase 1 completion

- [ ] 103. **VbC (**clean-room**).** Verify SC-1 through SC-26 all pass.
  - [ ] 103a. Run all grep assertions from each item's GREEN doublecheck
  - [ ] 103b. Re-run all 10 behavioral test artifacts and dispatch sub-agents to assert — all must PASS
  - [ ] 103c. Confirm all 6 files modified correctly
- [ ] 104. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors for verification-audit. Produces `auditor_1` and `auditor_2` with `artifact_path` contracts.
- [ ] 105. **Auditor 1: verification-audit (**clean-room**).** Dispatch `adversarial-audit --task verification-audit --issue 1372` with `audit_phase: post_implementation` to auditor_1. On non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, re-run resolve-models, restart from Step 104. Do NOT dispatch auditor 2.
- [ ] 106. **Auditor 2: verification-audit (**clean-room**).** Dispatch same audit task to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 104. Both clean PASS: collect both `artifact_path` values.
- [ ] 107. **Cross-validate (**clean-room**).** Pass `auditor_artifact_paths` to `adversarial-audit --task cross-validate`. Both PASS or DISAGREE with remediation.
- [ ] 108. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 109. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving skill metadata and task file content (Phase 1) → entering deprecated file purge (Phase 2). Phase 2 depends on Phase 1 removing all references to `create-and-validate.md` and `plan-structure.md` from `create.md`.

---

## Phase 2 — Purge Deprecated create/ Subdirectory

**Concern:** writing-plans skill file structure — remove deprecated monolithic legacy files
**Files:** `tasks/create/create-and-validate.md` (DELETE), `tasks/create/plan-structure.md` (DELETE)
**SCs:** SC-15, SC-16
**Dependencies:** Phase 1 complete (create.md no longer references these files)
**Entry condition:** `tasks/create/` subdirectory exists with `create-and-validate.md` and `plan-structure.md`. create.md no longer references them.
**Exit condition:** `tasks/create/` subdirectory does not exist. SC-15 and SC-16 pass.

**Artifact paths:** `./tmp/1372/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 110. **Coherence gate (**clean-room**).** Verify SC-15 and SC-16 consistent with Phase 1 exit state.
  - [ ] 110a. Confirm create.md no longer references `create-and-validate` or `plan-structure`
  - [ ] 110b. Confirm `tasks/create/` subdirectory still exists
- [ ] 111. **Pre-RED baseline (**clean-room**).** Capture current state of deprecated files.
  - [ ] 111a. `ls tasks/create/` shows both files
  - [ ] 111b. `wc -l` on both files
  - [ ] 111c. grep for `create-and-validate\|plan-structure` in create.md — must be absent (Phase 1 delivered this)

#### RED+green P2-I1 — Purge deprecated files

- [ ] 112. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'list writing-plans task files' --model <model>`. Save to `./tmp/1372/artifacts/red-p2i1-stderr.log`.
- [ ] 113. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/red-p2i1-stderr.log`. Assert agent references `create-and-validate.md` or `plan-structure.md`. Must FAIL because directory still exists. **→ SC-15**
- [ ] 114. **RED doublecheck (**clean-room**).** Confirm Step 113 returned FAIL as expected.
- [ ] 115. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 116. **GREEN (**clean-room**).** Purge deprecated `tasks/create/` subdirectory. **→ SC-15, SC-16**
  - [ ] 116a. Delete `tasks/create/create-and-validate.md`
  - [ ] 116b. Delete `tasks/create/plan-structure.md`
  - [ ] 116c. Remove `tasks/create/` directory (now empty)
- [ ] 117. **Post-GREEN enforcement (**clean-room**).** Verify files deleted.
- [ ] 118. **Structural checks (**clean-room**).** `ls .opencode/skills/writing-plans/tasks/create/` — returns "No such file or directory".
- [ ] 119. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'list writing-plans task files' --model <model>` again. Save to `./tmp/1372/artifacts/green-p2i1-stderr.log`.
- [ ] 120. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1372/artifacts/green-p2i1-stderr.log`. Assert agent does NOT reference `create-and-validate.md` or `plan-structure.md`. Must PASS. **→ SC-15, SC-16**
  - [ ] 120a. `ls .opencode/skills/writing-plans/tasks/create/` — no such file
  - [ ] 120b. grep for `create-and-validate\|plan-structure` in create.md — absent
- [ ] 121. **Checkpoint commit (**inline**).** `git commit -m "writing-plans: purge deprecated tasks/create/ subdirectory"`

#### Phase 2 completion

- [ ] 122. **VbC (**clean-room**).** Verify SC-15 and SC-16 pass.
  - [ ] 122a. Confirm directory gone
  - [ ] 122b. Confirm no stale references in create.md
  - [ ] 122c. Re-run behavioral test artifact generation and sub-agent assertion — must PASS
- [ ] 123. **Resolve models (**inline**).** Run `resolve-models` for cross-family auditors.
- [ ] 124. **Auditor 1: verification-audit (**clean-room**).** Dispatch `adversarial-audit --task verification-audit --issue 1372` with `audit_phase: post_implementation` to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 123.
- [ ] 125. **Auditor 2: verification-audit (**clean-room**).** Dispatch same to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 123. Both PASS: collect artifact paths.
- [ ] 126. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 127. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 128. **Review prep (**clean-room**).** `git-workflow review-prep`.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1: All 8 files modified or deleted — SKILL.md, create.md, completion.md, retroactive.md, audit-fidelity.md, audit-concern.md updated; create-and-validate.md and plan-structure.md deleted.
- [ ] C2: Trigger Dispatch Table classifies `create`, `retroactive`, `completion` as `orchestrator`.
- [ ] C3: No `task()` calls or skill invocations in completion.md.
- [ ] C4: create.md operating protocol has 21 steps. retroactive.md aligned with 21-step pipeline.
- [ ] C5: create.md has canonical Plan Format Requirements section with all 14 required sections, 12 validation rules, prohibited patterns, and all three dispatch indicator modes.
- [ ] C6: `tasks/create/` subdirectory does not exist.
- [ ] C7: All SC-1 through SC-26 pass verification.
- [ ] C8: Plan stored at `.opencode/.issues/1372/plan.md`.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
