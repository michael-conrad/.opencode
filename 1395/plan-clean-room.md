# Implementation Plan — [#1395](https://github.com/michael-conrad/.opencode/issues/1395) — Remove dead JSONC sub-agent configs, fold submodule ops into general task dispatch

- **Goal:** Delete four dead JSONC files from `agents/`, remove the dedicated "Sub-Agent Tasks for Submodule Operations" table from `git-workflow/SKILL.md`, and update all task files to use standard `task(subagent_type="general")` dispatch language for submodule operations.
- **Architecture:** Structural cleanup — file deletion + text replacement. No runtime behavior changes. The `must_receive`/`must_not_receive` context schemas already inline in each task file are preserved unchanged.
- **Files:**
  - `agents/submodule-dev-restore.jsonc` — DELETE
  - `agents/submodule-feature-push.jsonc` — DELETE
  - `agents/submodule-liveness-check.jsonc` — DELETE
  - `agents/submodule-tag-prework.jsonc` — DELETE
  - `skills/git-workflow/SKILL.md` — Remove sub-agent table, update routing table
  - `skills/git-workflow/tasks/pre-work.md` — Replace dedicated sub-agent language
  - `skills/git-workflow/tasks/cleanup/branch-cleanup.md` — Same
  - `skills/git-workflow/tasks/pr-creation/enforcement-gate.md` — Same
  - `skills/git-workflow/tasks/review-prep/push-and-cleanup.md` — Same
  - `skills/git-workflow/tasks/check-pr.md` — Same
  - `skills/git-workflow/tasks/cleanup.md` — Same
  - `skills/git-workflow/tasks/pr-creation.md` — Same
  - `skills/git-workflow/tasks/review-prep.md` — Same

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step completes, report the result before proceeding to the next step. Do not batch, combine, or parallelize steps. Each step is an atomic unit.

> **Step Status:** After each step, update the step's checkbox with `[x]` and append a brief status note (e.g., `— PASS`, `— 4 files deleted`, `— SC-1 verified`). This provides a live progress trail.

## Phase 1 — Remove dead JSONC configs and update dispatch language

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Remove dead JSONC configs and update dispatch language | Delete 4 dead JSONC files, remove sub-agent table from SKILL.md, update 8 task files to use standard `task(subagent_type="general")` dispatch | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1–12 |

- [ ] 1. **Delete four dead JSONC files (**clean-room**).** Delete `agents/submodule-dev-restore.jsonc`, `agents/submodule-feature-push.jsonc`, `agents/submodule-liveness-check.jsonc`, `agents/submodule-tag-prework.jsonc`. **→ SC-1**
- [ ] 2. **Verify SC-1 (**clean-room**).** Run `ls agents/*.jsonc` and confirm output is empty. **→ SC-1**
- [ ] 3. **Remove "Sub-Agent Tasks for Submodule Operations" table from SKILL.md (**clean-room**).** In `skills/git-workflow/SKILL.md`, remove the dedicated sub-agent table section. **→ SC-3**
- [ ] 4. **Update routing table in SKILL.md (**clean-room**).** In `skills/git-workflow/SKILL.md`, update the routing table so submodule operations appear as standard tasks (not dedicated sub-agents). **→ SC-5**
- [ ] 5. **Verify SC-2, SC-3, SC-5 (**clean-room**).** Run `grep -rn '\.jsonc' skills/git-workflow/` — expect zero. Run `grep -c 'Sub-Agent Tasks for Submodule Operations' skills/git-workflow/SKILL.md` — expect 0. Verify submodule ops are in the main routing table. **→ SC-2, SC-3, SC-5**
- [ ] 6. **Update `pre-work.md` (**clean-room**).** Replace dedicated sub-agent dispatch language (e.g., "dispatches a `submodule-tag-prework` sub-agent") with standard `task(subagent_type="general")` language. Preserve inline `must_receive`/`must_not_receive` schemas. **→ SC-4**
- [ ] 7. **Update `branch-cleanup.md` (**clean-room**).** Replace `submodule-dev-restore` dedicated sub-agent references with standard `task(subagent_type="general")` language. **→ SC-4**
- [ ] 8. **Update `enforcement-gate.md` (**clean-room**).** Replace `submodule-liveness-check` dedicated sub-agent references with standard `task(subagent_type="general")` language. **→ SC-4**
- [ ] 9. **Update `push-and-cleanup.md` (**clean-room**).** Replace `submodule-feature-push` dedicated sub-agent references with standard `task(subagent_type="general")` language. **→ SC-4**
- [ ] 10. **Update `check-pr.md`, `cleanup.md`, `pr-creation.md`, `review-prep.md` (**clean-room**).** Replace all remaining dedicated sub-agent references with standard `task(subagent_type="general")` language. **→ SC-4**
- [ ] 11. **Verify SC-4 (**clean-room**).** Run `grep -rn 'dispatches a `submodule-.*` sub-agent' skills/git-workflow/` — expect zero. **→ SC-4**
- [ ] 12. **Final cross-check (**clean-room**).** Run `grep -rn 'submodule-.*jsonc\|submodule-.*sub-agent\|Sub-Agent Tasks for Submodule' skills/git-workflow/` — expect zero. Confirm all 8 task files updated. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

#### Phase 1 VbC

- [ ] 13. **VbC (**clean-room**).** Verify: (1) `ls agents/*.jsonc` returns empty → SC-1. (2) `grep -rn '\.jsonc' skills/git-workflow/` returns zero → SC-2. (3) `grep -c 'Sub-Agent Tasks for Submodule Operations' skills/git-workflow/SKILL.md` returns 0 → SC-3. (4) No task file says "dispatches a `submodule-*` sub-agent" → SC-4. (5) Submodule ops appear in main routing table, not separate sub-agent table → SC-5. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** If any verification step fails, the agent MUST self-remediate: diagnose the root cause, fix the issue, and re-run the verification. Do not halt on a single failure — remediate and re-verify. Only halt after a verified double-failure (remediation attempt also fails).

## Exit Criteria

- [ ] C1: All four dead JSONC files deleted from `agents/`
- [ ] C2: No `.jsonc` references remain in `skills/git-workflow/`
- [ ] C3: "Sub-Agent Tasks for Submodule Operations" table removed from `git-workflow/SKILL.md`
- [ ] C4: All 8 task files use standard `task(subagent_type="general")` dispatch language
- [ ] C5: Submodule operations listed in main routing table, not a separate sub-agent table
- [ ] C6: Inline `must_receive`/`must_not_receive` schemas preserved unchanged
