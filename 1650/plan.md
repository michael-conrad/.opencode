# Implementation Plan — #1650 — Replace `/skill` CLI convention with `skill()` invocation syntax

**Spec:** #1650
**Goal:** Replace all 43 `/skill` CLI convention references across `.opencode/skills/` and `.opencode/.issues/` with proper `skill()` invocation syntax, and add a behavioral test verifying the agent uses `skill()` syntax.

**Architecture:** Two-phase plan. Phase 1 covers SC-1 through SC-5 (mechanical string replacement). Post-phase covers SC-6 (behavioral test).

**Files:**
- `.opencode/skills/*/SKILL.md` — 32 files with "CLI equivalent" lines
- `.opencode/skills/*/tasks/*.md` — 7 task files with `--task` examples, 1 without `--task` (squash-push.md)
- `.opencode/skills/brainstorming/tasks/enforcement.md` — 1 prose mention
- `.opencode/.issues/1372/spec.md` — 2 references
- `.opencode/tests/behaviors/skill-invocation-syntax.sh` — behavioral test (new file)

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.

> **Compliance requirement:** This plan is a binding specification. Every step MUST be executed exactly as written. No step may be skipped, combined, reordered, or optimized out. If a step appears unnecessary, execute it anyway — skipping steps produces defective deliverables that must be discarded, requiring full rework.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the output before proceeding. Do not batch steps. Do not read ahead. Each step depends on the previous step's verified output.

> **Step Status:** Before each step, mark it `in_progress`. After completion, mark it `completed`. If blocked, mark it `blocked` with the blocker reason.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Replace `/skill` with `skill()` syntax | Mechanical string replacement of `/skill` CLI convention with `skill()` syntax across all skill files | SC-1, SC-2, SC-3, SC-4, SC-5 | None (root phase) | 1-9 |
| Post | Behavioral test for `skill()` syntax | Verify agent uses `skill()` syntax, not `/skill`, when describing skill invocation | SC-6 | Phase 1 | 10-14 |

## Phase 1 — Replace `/skill` with `skill()` syntax

**Concern:** Mechanical string replacement of `/skill` CLI convention with `skill()` syntax across all skill files.

**Files:**
- `.opencode/skills/*/SKILL.md` (32 files — CLI equivalent lines)
- `.opencode/skills/*/tasks/*.md` (7 files — `--task` examples)
- `.opencode/skills/pr-creation-workflow/tasks/squash-push.md` (1 file — no `--task`)
- `.opencode/skills/brainstorming/tasks/enforcement.md` (1 file — prose mention)
- `.opencode/.issues/1372/spec.md` (1 file — 2 references)

**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None (root phase)

**Entry conditions:** Solve step completed with SAT and SOLVED status

**Exit conditions:** Zero `/skill` references remain in `.opencode/skills/` and `.opencode/.issues/1372/spec.md`

### Step-by-step

- [ ] 1. **RED: Baseline count (**inline**).** Run grep for backtick-quoted `/skill` across `.opencode/skills/` and confirm count matches 43. Run per-category counts: CLI equivalent lines (expect 32), `--task` examples (expect 7), no `--task` (expect 1), prose mention (expect 1), `.issues/` references (expect 2). Write baseline to `./tmp/1650/baseline-count.txt`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 2. **Replace SKILL.md CLI equivalent lines (**sub-agent**).** For all 32 files with CLI equivalent lines (31 SKILL.md + routing-only-template.md), replace the `/skill <name> --task <task>` pattern with `skill({name: "<name>", task: "<task>"})`. For bare invocations (no `--task`), use `skill({name: "<name>"})`. **→ SC-1**

- [ ] 3. **Replace task file `--task` examples (**sub-agent**).** For all 7 task files with `--task` examples, replace the `/skill <skill> --task <task>` pattern with `task(..., prompt: "execute <task> from <skill>")`. **→ SC-2**

- [ ] 4. **Replace squash-push.md bare flag (**sub-agent**).** Replace `/skill changelog-generator --since-last-release` in `squash-push.md` with `skill({name: "changelog-generator"})`. **→ SC-3**

- [ ] 5. **Replace enforcement.md prose mention (**sub-agent**).** Replace `Say '/skill brainstorming'` in `enforcement.md` with `skill({name: "brainstorming"})`. **→ SC-4**

- [ ] 6. **Replace `.issues/` references (**sub-agent**).** Replace 2 `/skill` references in `.opencode/.issues/1372/spec.md` with `skill()` syntax. **→ SC-5**

- [ ] 7. **REFACTOR: Verify zero `/skill` remaining (**inline**).** Run grep for backtick-quoted `/skill` across `.opencode/skills/` and `.opencode/.issues/` — expect 0 in both. Write verification to `./tmp/1650/sc-5-grep.txt`. **→ SC-5**

- [ ] 8. **VbC (**clean-room**).** Verify SC-1 through SC-5: grep for `/skill` in CLI equivalent lines (expect 0), `--task` examples (expect 0), bare flags (expect 0), prose mentions (expect 0), and all `.opencode/skills/` + `.opencode/.issues/` (expect 0). Write evidence to `./tmp/1650/sc-1-through-sc-5-evidence.txt`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 9. **Checkpoint commit (**inline**).** `git add -A && git commit -m "feat: replace /skill CLI convention with skill() invocation syntax (#1650)"`. Tag with `opencode-config/checkpoint/1650/phase-1-opencode-config`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

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

- [ ] 10. **RED: Write behavioral test (**sub-agent**).** Create `.opencode/tests/behaviors/skill-invocation-syntax.sh`. Send prompt asking agent to describe skill invocation. Assert agent does NOT use `/skill` syntax. Use `assert_forbidden_pattern_absent` helper. Test should FAIL because agent still uses old convention. **→ SC-6**

- [ ] 11. **GREEN: Run behavioral test (**inline**).** Execute the behavioral test via `with-test-home` wrapper. Verify stderr contains `skill({name: ...})` not `/skill`. **→ SC-6**

- [ ] 12. **REFACTOR: Verify behavioral test passes (**inline**).** Run the behavioral test script and confirm PASS. Write evidence to `./tmp/1650/sc-6-behavioral.log`. **→ SC-6**

- [ ] 13. **VbC (**clean-room**).** Verify SC-6: behavioral test passes with `assert_forbidden_pattern_absent` for `/skill` syntax. Write evidence to `./tmp/1650/sc-6-behavioral.log`. **→ SC-6**

- [ ] 14. **Checkpoint commit (**inline**).** `git add -A && git commit -m "test: add behavioral test for skill() invocation syntax (#1650)"`. Tag with `opencode-config/checkpoint/1650/post-phase-behavioral-opencode-config`. **→ SC-6**

> **Compliance requirement:** This plan is a binding specification. Every step MUST be executed exactly as written. No step may be skipped, combined, reordered, or optimized out. If a step appears unnecessary, execute it anyway — skipping steps produces defective deliverables that must be discarded, requiring full rework.

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do not skip the step. Do not proceed past a failed step. If remediation fails after 2 attempts, report BLOCKED with root cause and halt.

## Exit Criteria

- [ ] C1: All 32 SKILL.md "CLI equivalent" lines use `skill({name: "..."})` instead of `/skill` (SC-1)
- [ ] C2: All 7 task file examples with `--task` use `skill()` + `task()` patterns instead of `/skill` (SC-2)
- [ ] C3: The 1 task file example without `--task` (squash-push.md) uses `skill()` instead of `/skill` (SC-3)
- [ ] C4: The 1 prose mention in brainstorming/tasks/enforcement.md uses `skill()` instead of `/skill` (SC-4)
- [ ] C5: Zero `/skill` references remain in `.opencode/skills/` (all 43 locations resolved) (SC-5)
- [ ] C6: Behavioral test verifies agent uses `skill()` syntax, not `/skill`, when describing skill invocation (SC-6)
