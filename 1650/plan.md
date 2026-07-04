# Implementation Plan — #1650 — Replace `/skill` CLI convention with `skill()` invocation syntax

**Spec:** #1650
**Goal:** Replace all 51 `/skill` CLI convention references across `.opencode/` with proper `skill()` invocation syntax, and add a behavioral test verifying the agent uses `skill()` syntax.

**Architecture:** Two-phase plan. Phase 1 covers SC-1 through SC-5 (mechanical string replacement across 44 files). Post-phase covers SC-6 (behavioral test).

**Files (44 total):**
- 32 SKILL.md files with "CLI equivalent" lines
- 7 task files with `--task` examples
- 1 task file without `--task` (squash-push.md)
- 1 prose mention (enforcement.md)
- 1 reference template (routing-only-template.md)
- 1 `.issues/` spec (1372/spec.md — 2 references)
- 1 `.guidelines/README.md` (3 references)
- 1 `README.md` (3 references)
- 1 `dispatch-table.yaml` (2 references)

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.

> **Compliance requirement:** This plan is a binding specification. Every step MUST be executed exactly as written. No step may be skipped, combined, reordered, or optimized out. If a step appears unnecessary, execute it anyway — skipping steps produces defective deliverables that must be discarded, requiring full rework.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the output before proceeding. Do not batch steps. Do not read ahead. Each step depends on the previous step's verified output.

> **Step Status:** Before each step, mark it `in_progress`. After completion, mark it `completed`. If blocked, mark it `blocked` with the blocker reason.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Replace `/skill` with `skill()` syntax | Mechanical string replacement of `/skill` CLI convention with `skill()` syntax across all skill files | SC-1, SC-2, SC-3, SC-4, SC-5 | None (root phase) | 1-12 |
| Post | Behavioral test for `skill()` syntax | Verify agent uses `skill()` syntax, not `/skill`, when describing skill invocation | SC-6 | Phase 1 | 13-17 |

## Phase 1 — Replace `/skill` with `skill()` syntax

**Concern:** Mechanical string replacement of `/skill` CLI convention with `skill()` syntax across all skill files.

**Files (44):**

### SKILL.md CLI equivalent lines (32 files)
1. `skills/writing-plans/SKILL.md:80`
2. `skills/programming-principles/SKILL.md:57`
3. `skills/git-workflow/SKILL.md:89`
4. `skills/changelog-generator/SKILL.md:58`
5. `skills/finishing-a-development-branch/SKILL.md:60`
6. `skills/brainstorming/SKILL.md:61`
7. `skills/research/SKILL.md:52`
8. `skills/multimodal-dispatch/SKILL.md:55`
9. `skills/sync-guidelines/SKILL.md:61`
10. `skills/verification-before-completion/SKILL.md:62`
11. `skills/requesting-code-review/SKILL.md:52`
12. `skills/issue-review/SKILL.md:65`
13. `skills/receiving-code-review/SKILL.md:55`
14. `skills/completeness-gate/SKILL.md:110`
15. `skills/issue-operations/SKILL.md:108`
16. `skills/spec-creation/SKILL.md:54`
17. `skills/plan/SKILL.md:123`
18. `skills/mcp-tool-usage/SKILL.md:115`
19. `skills/pre-analysis/SKILL.md:118`
20. `skills/test-driven-development/SKILL.md:136`
21. `skills/skill-creator/SKILL.md:62`
22. `skills/sre-runbook/SKILL.md:55`
23. `skills/pr-creation-workflow/SKILL.md:57`
24. `skills/verification-enforcement/SKILL.md:60`
25. `skills/verification/SKILL.md:56`
26. `skills/engineering-approach/SKILL.md:59`
27. `skills/executing-plans/SKILL.md:55`
28. `skills/systematic-debugging/SKILL.md:55`
29. `skills/using-git-worktrees/SKILL.md:55`
30. `skills/conflict-resolution/SKILL.md:54`
31. `skills/correspondence/SKILL.md:53`
32. `skills/skill-creator/reference/routing-only-template.md:72`

### Task files with `--task` examples (7 files)
33. `skills/git-workflow/tasks/review-prep/push-and-cleanup.md:69` — `/skill git-workflow --task provenance --mode=dev-push`
34. `skills/git-workflow/tasks/cleanup/verify-merge.md:61` — `/skill git-workflow --task rebase-pending`
35. `skills/test-driven-development/tasks/red.md:9` — `/skill test-driven-development --task red`
36. `skills/test-driven-development/tasks/green.md:9` — `/skill test-driven-development --task green`
37. `skills/test-driven-development/tasks/refactor.md:9` — `/skill test-driven-development --task refactor`
38. `skills/sre-runbook/tasks/track.md:68` — `/skill issue-operations --task pre-creation`
39. `skills/systematic-debugging/tasks/diagnose.md:72` — `/skill issue-review --issue N --task analyze-and-spec`

### Task file without `--task` (1 file)
40. `skills/git-workflow/tasks/pr-creation/squash-push.md:25` — `/skill changelog-generator --since-last-release`

### Prose mention (1 file)
41. `skills/brainstorming/tasks/enforcement.md:53` — `Say '/skill brainstorming'`

### `.issues/` spec references (1 file, 2 references)
42. `.issues/1372/spec.md:149` — `/skill verification-enforcement --task revisit`
43. `.issues/1372/spec.md:150` — `/skill` CLI syntax reference

### `.guidelines/README.md` (1 file, 3 references)
44. `.guidelines/README.md:112` — `/skill fragment-manager --task create-fragment`
45. `.guidelines/README.md:124` — `/skill fragment-manager --task sync-fragment --fragment-id <id>`
46. `.guidelines/README.md:136` — `/skill fragment-manager --task check-drift`

### `README.md` (1 file, 3 references)
47. `README.md:252` — `/skill fragment-manager --task create-fragment`
48. `README.md:255` — `/skill fragment-manager --task sync-fragment --fragment-id <id>`
49. `README.md:258` — `/skill fragment-manager --task check-drift`

### `dispatch-table.yaml` (1 file, 2 references)
50. `dispatch-table.yaml:403` — `/skill <skill-name> --task <task-name> for sub-task invocation`
51. `dispatch-table.yaml:404` — `/skill <skill-name> (no --task) for skill overview only`

**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None (root phase)

**Entry conditions:** Solve step completed with SAT and SOLVED status

**Exit conditions:** Zero `/skill` references remain in `.opencode/`

### Step-by-step

- [ ] 1. **RED: Baseline count (**inline**).** Run `grep -rn '`/skill' .opencode/ --include='*.md' --include='*.yaml' --include='*.yml' | grep -v CHANGELOG | grep -v '.issues/1650/' | grep -v 'tests/' | grep -v 'tmp/' | wc -l` and confirm 51. Write baseline to `./tmp/1650/baseline-count.txt`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 2. **Replace SKILL.md CLI equivalent lines — batch 1 (**sub-agent**).** Replace lines in files 1-16 (first 16 SKILL.md files). Pattern: `**CLI equivalent (for human TUI use):** \`/skill <name> --task <task>\`` → `**CLI equivalent:** \`skill({name: "<name>", task: "<task>"})\``. For TDD SKILL.md which uses `--task <name>` instead of `--task <task>`, use `skill({name: "test-driven-development"})`. **→ SC-1**

- [ ] 3. **Replace SKILL.md CLI equivalent lines — batch 2 (**sub-agent**).** Replace lines in files 17-32 (remaining 16 SKILL.md + routing-only-template.md). Same pattern. **→ SC-1**

- [ ] 4. **Replace task file `--task` examples — batch 1 (**sub-agent**).** Replace lines in files 33-36 (push-and-cleanup.md, verify-merge.md, red.md, green.md). Pattern: `/skill <skill> --task <task>` → `task(..., prompt: "execute <task> from <skill>")`. **→ SC-2**

- [ ] 5. **Replace task file `--task` examples — batch 2 (**sub-agent**).** Replace lines in files 37-39 (refactor.md, track.md, diagnose.md). Same pattern. **→ SC-2**

- [ ] 6. **Replace squash-push.md bare flag (**sub-agent**).** File 40: replace `/skill changelog-generator --since-last-release` with `skill({name: "changelog-generator"})`. **→ SC-3**

- [ ] 7. **Replace enforcement.md prose mention (**sub-agent**).** File 41: replace `Say '/skill brainstorming'` with `skill({name: "brainstorming"})`. **→ SC-4**

- [ ] 8. **Replace `.issues/1372/spec.md` references (**sub-agent**).** Files 42-43: replace 2 `/skill` references with `skill()` syntax. **→ SC-5**

- [ ] 9. **Replace `.guidelines/README.md` references (**sub-agent**).** Files 44-46: replace 3 `/skill fragment-manager` references with `skill({name: "fragment-manager"})`. **→ SC-5**

- [ ] 10. **Replace `README.md` references (**sub-agent**).** Files 47-49: replace 3 `/skill fragment-manager` references with `skill({name: "fragment-manager"})`. **→ SC-5**

- [ ] 11. **Replace `dispatch-table.yaml` references (**sub-agent**).** Files 50-51: replace 2 `/skill` usage descriptions with `skill()` syntax. **→ SC-5**

- [ ] 12. **REFACTOR: Verify zero `/skill` remaining (**inline**).** Run `grep -rn '`/skill' .opencode/ --include='*.md' --include='*.yaml' --include='*.yml' | grep -v CHANGELOG | grep -v '.issues/1650/' | grep -v 'tests/' | grep -v 'tmp/' | wc -l` → expect 0. Write verification to `./tmp/1650/sc-5-grep.txt`. **→ SC-5**

- [ ] 13. **VbC (**clean-room**).** Verify SC-1 through SC-5: grep for `/skill` in CLI equivalent lines (expect 0), `--task` examples (expect 0), bare flags (expect 0), prose mentions (expect 0), and all `.opencode/` (expect 0). Write evidence to `./tmp/1650/sc-1-through-sc-5-evidence.txt`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 14. **Checkpoint commit (**inline**).** `git add -A && git commit -m "feat: replace /skill CLI convention with skill() invocation syntax (#1650)"`. Tag with `opencode-config/checkpoint/1650/phase-1-opencode-config`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving mechanical string replacement → entering behavioral test creation. Post-phase depends on Phase 1 having zero `/skill` references remaining.

## Post-Phase — Behavioral test for `skill()` syntax

**Concern:** Verify agent uses `skill()` syntax, not `/skill`, when describing skill invocation.

**Files:**
- `.opencode/tests/behaviors/skill-invocation-syntax.sh` (new file)

**SCs covered:** SC-6

**Dependencies:** Phase 1 (zero `/skill` references remaining)

**Entry conditions:** Phase 1 complete with all SC-1 through SC-5 verified PASS

**Exit conditions:** Behavioral test passes, verifying agent uses `skill()` syntax

### Step-by-step

- [ ] 15. **RED: Write behavioral test (**sub-agent**).** Create `.opencode/tests/behaviors/skill-invocation-syntax.sh`. Send prompt asking agent to describe skill invocation. Assert agent does NOT use `/skill` syntax. Use `assert_forbidden_pattern_absent` helper. Test should FAIL because agent still uses old convention. **→ SC-6**

- [ ] 16. **GREEN: Run behavioral test (**inline**).** Execute the behavioral test via `with-test-home` wrapper. Verify stderr contains `skill({name: ...})` not `/skill`. **→ SC-6**

- [ ] 17. **REFACTOR: Verify behavioral test passes (**inline**).** Run the behavioral test script and confirm PASS. Write evidence to `./tmp/1650/sc-6-behavioral.log`. **→ SC-6**

- [ ] 18. **VbC (**clean-room**).** Verify SC-6: behavioral test passes with `assert_forbidden_pattern_absent` for `/skill` syntax. Write evidence to `./tmp/1650/sc-6-behavioral.log`. **→ SC-6**

- [ ] 19. **Checkpoint commit (**inline**).** `git add -A && git commit -m "test: add behavioral test for skill() invocation syntax (#1650)"`. Tag with `opencode-config/checkpoint/1650/post-phase-behavioral-opencode-config`. **→ SC-6**

> **Compliance requirement:** This plan is a binding specification. Every step MUST be executed exactly as written. No step may be skipped, combined, reordered, or optimized out. If a step appears unnecessary, execute it anyway — skipping steps produces defective deliverables that must be discarded, requiring full rework.

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do not skip the step. Do not proceed past a failed step. If remediation fails after 2 attempts, report BLOCKED with root cause and halt.

## Exit Criteria

- [ ] C1: All 32 SKILL.md "CLI equivalent" lines use `skill({name: "..."})` instead of `/skill` (SC-1)
- [ ] C2: All 7 task file examples with `--task` use `skill()` + `task()` patterns instead of `/skill` (SC-2)
- [ ] C3: The 1 task file example without `--task` (squash-push.md) uses `skill()` instead of `/skill` (SC-3)
- [ ] C4: The 1 prose mention in brainstorming/tasks/enforcement.md uses `skill()` instead of `/skill` (SC-4)
- [ ] C5: Zero `/skill` references remain in `.opencode/` (all 51 locations resolved) (SC-5)
- [ ] C6: Behavioral test verifies agent uses `skill()` syntax, not `/skill`, when describing skill invocation (SC-6)
