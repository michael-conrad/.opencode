# Implementation Plan — #1650 — Replace `/skill` References with `skill()` Syntax

## Goal

Replace all 51 `/skill` references across `.opencode/` with proper `skill()` invocation syntax, eliminating the non-existent `/skill` CLI command pattern.

## Architecture

Six phases: (1) SKILL.md CLI lines, (2) task file `--task` examples, (3) other references (prose, README, dispatch-table), (4) behavioral test, (5) global zero-remaining verification, (6) review-prep. Each phase is a find-and-replace pass over a specific file set, followed by verification that no `/skill` references remain in that category.

## Files

- `.opencode/skills/*/SKILL.md` (31 files + 1 template)
- `.opencode/skills/*/tasks/*.md` (7 files with `--task` examples, 1 without)
- `.opencode/skills/brainstorming/tasks/enforcement.md`
- `.opencode/.guidelines/README.md`
- `.opencode/README.md`
- `.opencode/dispatch-table.yaml`
- `.opencode/.issues/1372/spec.md`
- `.opencode/tests/behaviors/` (new behavioral test file)

> **Compliance requirement:** This plan is a binding contract. Every step MUST be executed exactly as specified. No step may be skipped, reordered, or combined. If a step cannot be completed, the plan is BLOCKED and must be reported as such. The plan is not a suggestion — it is the implementation specification.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the output before proceeding. Do not batch steps. Do not skip verification. Each step depends on the previous step's verified output.

> **Step Status:** Before each step, check the step's checkbox status. If `[x]`, the step is complete — skip it. If `[ ]`, execute it. After execution, mark `[x]` and proceed to the next step.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | SKILL.md CLI Lines | Replace `/skill` in 32 SKILL.md "CLI equivalent" lines | SC-1 | None | 1-4 |
| 2 | Task File `--task` Examples | Replace `/skill` in 7 task file examples with `--task` | SC-2 | Phase 1 | 5-8 |
| 3 | Other References | Replace `/skill` in squash-push.md, enforcement.md, .issues/, README, dispatch-table | SC-3, SC-4 | Phase 2 | 9-14 |
| 4 | Behavioral Test | Write behavioral test verifying agent uses `skill()` syntax | SC-6 | Phase 3 | 15-18 |
| 5 | Global Zero-Remaining Verification | Verify zero `/skill` references remain in `.opencode/` | SC-5 | Phase 4 | 19-22 |
| 6 | Review Prep | Finishing checklist, PR creation | All | Phase 5 | 23-26 |

> **Compliance requirement:** This plan is a binding contract. Every step MUST be executed exactly as specified. No step may be skipped, reordered, or combined. If a step cannot be completed, the plan is BLOCKED and must be reported as such. The plan is not a suggestion — it is the implementation specification.

> **Self-remediation protocol:** If a step fails (verification mismatch, audit finding, test failure), the agent MUST self-remediate: diagnose the root cause, fix the defect, re-verify, and continue. Do NOT halt on the first failure — remediate first. Only halt if remediation fails twice consecutively.

## Exit Criteria

- [ ] C1. All 32 SKILL.md "CLI equivalent" lines use `skill({name: "..."})` instead of `/skill`
- [ ] C2. All 7 task file examples with `--task` use `skill()` + `task()` patterns
- [ ] C3. The squash-push.md example uses `skill()` instead of `/skill`
- [ ] C4. The enforcement.md prose mention uses `skill()` instead of `/skill`
- [ ] C5. Zero `/skill` references remain in `.opencode/`
- [ ] C6. Behavioral test verifies agent uses `skill()` syntax, not `/skill`

---

## Phase 1 — SKILL.md CLI Lines

**Concern:** Replace `/skill` in 32 SKILL.md "CLI equivalent" lines with `skill({name: "..."})` syntax.

**Files:** `.opencode/skills/*/SKILL.md` (31 files) + `.opencode/skills/routing-only-template.md`

**SCs:** SC-1

**Dependencies:** None

**Entry conditions:** None

**Exit conditions:** All 32 SKILL.md CLI lines use `skill({name: "..."})` syntax

- [ ] 1. **RED (**sub-agent**).** Write a grep-based verification script that checks all 32 SKILL.md files for remaining `/skill` patterns in CLI equivalent lines. Save to `./tmp/1650/phase1-red.sh`. The script must FAIL (exit non-zero) because `/skill` patterns still exist. **→ SC-1**

- [ ] 2. **GREEN (**sub-agent**).** For each of the 32 SKILL.md files, replace the `CLI equivalent:` line from `/skill <name> --task <task>` to `` `skill({name: "<name>"})` `` with the appropriate task. Use `skill({name: "writing-plans"})` for the writing-plans skill's own CLI line. **→ SC-1**

- [ ] 3. **GREEN doublecheck (**sub-agent**).** Run the verification script from Step 1. It must now PASS (exit zero) for Phase 1 files. **→ SC-1**

- [ ] 4. **Checkpoint commit (**inline**).** `git add .opencode/skills/*/SKILL.md .opencode/skills/routing-only-template.md && git commit -m "Phase 1: replace /skill CLI lines with skill() syntax in 32 SKILL.md files"` **→ SC-1**

#### Phase 1 VbC

- [ ] 1. **VbC (**clean-room**).** Run `grep -rn '/skill' .opencode/skills/*/SKILL.md .opencode/skills/routing-only-template.md | grep -i 'cli equivalent'` — verify zero matches. **→ SC-1**

**Concern transition:** Leaving SKILL.md CLI lines → entering task file `--task` examples. Phase 2 depends on Phase 1 completing the SKILL.md replacements so task file examples can reference the correct syntax.

---

## Phase 2 — Task File `--task` Examples

**Concern:** Replace `/skill` in 7 task file examples that use `--task` pattern.

**Files:** 7 task files with concrete `/skill <name> --task <task>` invocations

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry conditions:** Phase 1 verified complete

**Exit conditions:** All 7 task file `--task` examples use `skill()` + `task()` patterns

- [ ] 5. **RED (**sub-agent**).** Write a grep-based verification script that checks all task files for `/skill.*--task` patterns. Save to `./tmp/1650/phase2-red.sh`. Must FAIL initially. **→ SC-2**

- [ ] 6. **GREEN (**sub-agent**).** For each of the 7 task files, replace `/skill <name> --task <task>` with `` `task(..., prompt: "execute <task> from <skill>")` `` or appropriate `skill()` invocation. **→ SC-2**

- [ ] 7. **GREEN doublecheck (**sub-agent**).** Run verification script from Step 5. Must PASS. **→ SC-2**

- [ ] 8. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 2: replace /skill --task patterns in task file examples"` **→ SC-2**

#### Phase 2 VbC

- [ ] 2. **VbC (**clean-room**).** Run `grep -rn '/skill.*--task' .opencode/skills/` — verify zero matches. **→ SC-2**

**Concern transition:** Leaving task file `--task` examples → entering other references (prose, README, dispatch-table). Phase 3 depends on Phase 2 completing the task file replacements.

---

## Phase 3 — Other References

**Concern:** Replace `/skill` in squash-push.md, enforcement.md, .issues/1372/spec.md, .guidelines/README.md, README.md, dispatch-table.yaml.

**Files:**
- `.opencode/skills/git-workflow/tasks/squash-push.md` (1 example without `--task`)
- `.opencode/skills/brainstorming/tasks/enforcement.md` (1 prose mention)
- `.opencode/.issues/1372/spec.md` (2 references)
- `.opencode/.guidelines/README.md` (3 references)
- `.opencode/README.md` (3 references)
- `.opencode/dispatch-table.yaml` (2 references)

**SCs:** SC-3, SC-4

**Dependencies:** Phase 2

**Entry conditions:** Phase 2 verified complete

**Exit conditions:** All 12 remaining `/skill` references replaced

- [ ] 9. **RED (**sub-agent**).** Write a grep-based verification script covering all 6 file groups. Save to `./tmp/1650/phase3-red.sh`. Must FAIL initially. **→ SC-3, SC-4**

- [ ] 10. **GREEN (**sub-agent**).** Replace `/skill changelog-generator --since-last-release` in `squash-push.md` with `` `skill({name: "changelog-generator"})` ``. **→ SC-3**

- [ ] 11. **GREEN (**sub-agent**).** Replace `Say '/skill brainstorming'` in `enforcement.md` with `` `skill({name: "brainstorming"})` ``. **→ SC-4**

- [ ] 12. **GREEN (**sub-agent**).** Replace `/skill fragment-manager` references in `.guidelines/README.md`, `README.md`, and `/skill` references in `.issues/1372/spec.md` and `dispatch-table.yaml` with `skill()` syntax. **→ SC-3, SC-4**

- [ ] 13. **GREEN doublecheck (**sub-agent**).** Run verification script from Step 9. Must PASS. **→ SC-3, SC-4**

- [ ] 14. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 3: replace /skill in remaining references (prose, README, dispatch-table)"` **→ SC-3, SC-4**

#### Phase 3 VbC

- [ ] 3. **VbC (**clean-room**).** Run `grep -rn '/skill' .opencode/` — verify zero matches across all Phase 3 files. **→ SC-3, SC-4**

**Concern transition:** Leaving other references → entering behavioral test. Phase 4 depends on Phase 3 completing all `/skill` replacements so the behavioral test can verify the final state.

---

## Phase 4 — Behavioral Test

**Concern:** Write a behavioral enforcement test that verifies the agent uses `skill()` syntax, not `/skill`, when describing skill invocation.

**Files:** `.opencode/tests/behaviors/skill-syntax.sh` (new file)

**SCs:** SC-6

**Dependencies:** Phase 3

**Entry conditions:** Phase 3 verified complete

**Exit conditions:** Behavioral test exists and passes

- [ ] 15. **RED (**sub-agent**).** Write the behavioral test script at `.opencode/tests/behaviors/skill-syntax.sh`. The test sends a prompt asking the agent to describe how to invoke a skill, then asserts the agent uses `skill({name: "..."})` syntax and does NOT use `/skill` syntax. Use `assert_stderr_pattern_present` and `assert_forbidden_pattern_absent` helpers. Run the test — it must FAIL because the agent may still reference `/skill` from training data. **→ SC-6**

- [ ] 16. **GREEN (**sub-agent**).** No code change needed — the `/skill` references have already been removed from all files in Phases 1-3. The behavioral test should now PASS because the agent no longer sees `/skill` patterns in its skill files. Re-run the test. **→ SC-6**

- [ ] 17. **GREEN doublecheck (**sub-agent**).** Run the behavioral test 3 times to verify non-flaky PASS. **→ SC-6**

- [ ] 18. **Checkpoint commit (**inline**).** `git add .opencode/tests/behaviors/skill-syntax.sh && git commit -m "Phase 4: add behavioral test for skill() syntax"` **→ SC-6**

#### Phase 4 VbC

- [ ] 4. **VbC (**clean-room**).** Run `bash .opencode/tests/behaviors/skill-syntax.sh` — verify PASS. **→ SC-6**

**Concern transition:** Leaving behavioral test → entering global verification. Phase 5 depends on Phase 4 confirming the behavioral test passes.

---

## Phase 5 — Global Zero-Remaining Verification

**Concern:** Verify zero `/skill` references remain anywhere in `.opencode/`.

**Files:** All `.opencode/` files

**SCs:** SC-5

**Dependencies:** Phase 4

**Entry conditions:** Phase 4 verified complete

**Exit conditions:** Zero `/skill` references remain in `.opencode/`

- [ ] 19. **RED (**sub-agent**).** Run `grep -rn '/skill' .opencode/ --include='*.md' --include='*.yaml' --include='*.yml' --include='*.json'` — count matches. Must be zero. If non-zero, report file list. **→ SC-5**

- [ ] 20. **GREEN (**sub-agent**).** If Step 19 found any remaining `/skill` references, fix them. Re-run grep to confirm zero. **→ SC-5**

- [ ] 21. **GREEN doublecheck (**sub-agent**).** Run `grep -rn '/skill' .opencode/` with no file-type filter — verify zero matches across ALL file types. **→ SC-5**

- [ ] 22. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 5: global verification — zero /skill references remain"` **→ SC-5**

#### Phase 5 VbC

- [ ] 5. **VbC (**clean-room**).** Run exhaustive grep: `grep -rn '/skill' .opencode/` — verify zero matches. **→ SC-5**

**Concern transition:** Leaving global verification → entering review prep. Phase 6 depends on Phase 5 confirming zero remaining references.

---

## Phase 6 — Review Prep

**Concern:** Finishing checklist, PR creation.

**Files:** N/A (process phase)

**SCs:** All

**Dependencies:** Phase 5

**Entry conditions:** Phase 5 verified complete

**Exit conditions:** PR created with compare URL

- [ ] 23. **Finishing checklist (**sub-agent**).** Run `finishing-a-development-branch` skill — verify branch readiness, uncommitted changes, commit history. **→ All**

- [ ] 24. **Adversarial audit (**sub-agent**).** Run `adversarial-audit` plan-fidelity and concern-separation audits against the plan. **→ All**

- [ ] 25. **Cross-validate (**sub-agent**).** Run `verification-before-completion` — verify all 6 SCs with evidence artifacts. **→ All**

- [ ] 26. **PR creation (**sub-agent**).** Create PR with body containing Summary, Outcome, Fixes #1650, and SC verification table. **→ All**

#### Phase 6 VbC

- [ ] 6. **VbC (**clean-room**).** Verify PR exists and all SCs are verified PASS in PR body. **→ All**
