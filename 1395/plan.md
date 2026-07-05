# Implementation Plan — [#1395](https://github.com/michael-conrad/opencode-config/issues/1395) — Remove Dead Submodule JSONC Agent Configs
- **Goal:** Delete 4 unused `.jsonc` agent configs, remove the Sub-Agent Tasks for Submodule Operations table from `git-workflow/SKILL.md`, update routing and cross-references, and normalize 8 task files to standard `task(subagent_type="general")` dispatch language.
- **Architecture:** Cleanup-only — no new functionality. Delete files, remove references, replace dedicated sub-agent names with standard dispatch language. All inline `must_receive`/`must_not_receive` schemas preserved unchanged.
- **Files:**
  - Delete: `.opencode/agents/submodule-dev-restore.jsonc`, `.opencode/agents/submodule-feature-push.jsonc`, `.opencode/agents/submodule-liveness-check.jsonc`, `.opencode/agents/submodule-tag-prework.jsonc`
  - Edit: `.opencode/skills/git-workflow/SKILL.md`
  - Edit: `.opencode/skills/git-workflow/tasks/pre-work.md`
  - Edit: `.opencode/skills/git-workflow/tasks/cleanup.md`
  - Edit: `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md`
  - Edit: `.opencode/skills/git-workflow/tasks/check-pr.md`
  - Edit: `.opencode/skills/git-workflow/tasks/pr-creation.md`
  - Edit: `.opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md`
  - Edit: `.opencode/skills/git-workflow/tasks/review-prep.md`
  - Edit: `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md`

> **⚠️ COMPLIANCE REQUIREMENT:** All edits to task files MUST preserve inline `must_receive`/`must_not_receive` schemas unchanged. Only replace dedicated sub-agent names (e.g., `submodule-tag-prework`, `submodule-feature-push`, `submodule-liveness-check`, `submodule-dev-restore`) with standard `task(subagent_type="general")` language. Do NOT alter schema structure, field names, or exclusion lists.
> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Each step is one atomic action. Do NOT collapse multiple file edits or deletions into a single step. Do NOT skip steps.
> **⚠️ STEP STATUS:** Each step MUST be marked `[ ]` (pending) initially. After execution, mark `[x]` (completed). Do NOT pre-mark steps.

## Phase 1 — Remove Dead Configs and References

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Remove dead configs and references | Delete JSONC files, remove table and JSONC refs from SKILL.md | SC-1, SC-2, SC-3 | None | 1–6 |

### Item 1 — Delete 4 JSONC Files and Remove Table from SKILL.md (SC-1, SC-2, SC-3, structural + string)

- [ ] 1. **Delete `.opencode/agents/submodule-tag-prework.jsonc` (**inline**).** Remove the file from disk. **→ SC-1**
- [ ] 2. **Delete `.opencode/agents/submodule-feature-push.jsonc` (**inline**).** Remove the file from disk. **→ SC-1**
- [ ] 3. **Delete `.opencode/agents/submodule-liveness-check.jsonc` (**inline**).** Remove the file from disk. **→ SC-1**
- [ ] 4. **Delete `.opencode/agents/submodule-dev-restore.jsonc` (**inline**).** Remove the file from disk. **→ SC-1**
- [ ] 5. **Remove JSONC config path references from `git-workflow/SKILL.md` (**inline**).** In the "Sub-Agent Tasks for Submodule Operations" table (lines 89–98), delete the `Config` column values that reference `.opencode/agents/*.jsonc` paths. **→ SC-2**
- [ ] 6. **Remove the entire "Sub-Agent Tasks for Submodule Operations" table and heading from `git-workflow/SKILL.md` (**inline**).** Delete lines 89–98 (the heading `## Sub-Agent Tasks for Submodule Operations` and the full table). **→ SC-3**

> **⚠️ COMPLIANCE REQUIREMENT:** Steps 1–4 are file deletions only. Step 5 removes JSONC path references from the table. Step 6 removes the entire table. Do NOT combine steps 5 and 6 — they are separate atomic actions.
> **⚠️ SELF-REMEDIATION PROTOCOL:** If a JSONC file is already deleted (step fails with ENOENT), mark the step as completed and proceed. If the table text does not match exactly, re-read the file and adjust the edit to match the current content.

## Phase 2 — Update SKILL.md Routing and Cross-References

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 2 | Update SKILL.md routing and cross-references | Replace dedicated sub-agent names with standard dispatch, update cross-refs | SC-5 | Phase 1 | 7–9 |

### Item 2 — Update Routing Table and Cross-References in SKILL.md (SC-5, string)

- [ ] 7. **Update the "Sub-Agent Routing" section in `git-workflow/SKILL.md` to remove dedicated sub-agent names (**inline**).** In lines 131–135, replace the paragraph that begins "Submodule sub-agents (`submodule-tag-prework`, `submodule-feature-push`, `submodule-liveness-check`, `submodule-dev-restore`) receive scoped context..." with standard language stating that all submodule operations use `task(subagent_type="general")` with the same dispatch context as other tasks. **→ SC-5**
- [ ] 8. **Update the cross-reference from `submodule-tag-prework` to `pre-work.md Step 3.5` in `git-workflow/SKILL.md` (**inline**).** In line 127 (`Cross-references:` section), replace `` `submodule-tag-prework` task — hash permanence tag creation `` with `` `pre-work.md` Step 3.5 — submodule initialization and tag creation ``. **→ SC-5**
- [ ] 9. **Update the Trigger Dispatch Table in `git-workflow/SKILL.md` to list submodule operations as standard tasks (**inline**).** In lines 28–39, ensure the `submodule-sync` row uses standard `task(subagent_type="general")` language in the Dispatch column. **→ SC-5**

> **⚠️ COMPLIANCE REQUIREMENT:** Step 7 must remove all four dedicated sub-agent names from the routing section. Step 8 updates only the cross-reference line — do not modify other cross-references. Step 9 updates only the Dispatch column of the existing table row.
> **⚠️ SELF-REMEDIATION PROTOCOL:** If the exact text to replace is not found, re-read the file and adjust the edit to match the current content.

## Phase 3 — Update 8 Task Files to Standard Dispatch Language

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 3 | Update task files | Replace dedicated sub-agent names with `task(subagent_type="general")` in 8 task files | SC-4 | Phase 1 | 10–17 |

### Item 3 — Update 8 Task Files (SC-4, string)

- [ ] 10. **Update `pre-work.md` to replace `submodule-tag-prework` references with standard dispatch language (**inline**).** In lines 108, 110, 111, 123, 148–165 (Sub-Agent Boundary section), and 208–235 (Step 3.5), replace all references to the `submodule-tag-prework` sub-agent name with `task(subagent_type="general")` language. Preserve all inline `must_receive`/`must_not_receive` schemas unchanged. **→ SC-4**
- [ ] 11. **Update `cleanup.md` to replace `submodule-dev-restore` reference with standard dispatch language (**inline**).** In line 102, replace `tasks \`submodule-dev-restore\` sub-agent via task()` with `dispatches a sub-agent via task(subagent_type="general")`. **→ SC-4**
- [ ] 12. **Update `cleanup/branch-cleanup.md` to replace `submodule-dev-restore` references with standard dispatch language (**inline**).** In lines 191–215 (Orchestrator Dispatching section), replace all references to the `submodule-dev-restore` sub-agent name with `task(subagent_type="general")` language. Preserve all inline `must_receive`/`must_not_receive` schemas unchanged. **→ SC-4**
- [ ] 13. **Update `check-pr.md` to replace `submodule-dev-restore` reference with standard dispatch language (**inline**).** In line 49, replace `Restore submodules to dev tip via \`submodule-dev-restore\` sub-agent task()` with `Restore submodules to dev tip via task(subagent_type="general")`. **→ SC-4**
- [ ] 14. **Update `pr-creation.md` to replace `submodule-liveness-check` reference with standard dispatch language (**inline**).** In line 32, replace `task() \`submodule-liveness-check\` sub-agent` with `task(subagent_type="general")`. **→ SC-4**
- [ ] 15. **Update `pr-creation/enforcement-gate.md` to replace `submodule-liveness-check` references with standard dispatch language (**inline**).** In lines 25–55 (Step 0), replace all references to the `submodule-liveness-check` sub-agent name with `task(subagent_type="general")` language. Preserve all inline `must_receive`/`must_not_receive` schemas unchanged. **→ SC-4**
- [ ] 16. **Update `review-prep.md` to replace `submodule-feature-push` reference with standard dispatch language (**inline**).** In line 50, replace `Tasks \`submodule-feature-push\` sub-agent` with `Dispatches a sub-agent via task(subagent_type="general")`. **→ SC-4**
- [ ] 17. **Update `review-prep/push-and-cleanup.md` to replace `submodule-feature-push` references with standard dispatch language (**inline**).** In lines 21–69 (Step 0), replace all references to the `submodule-feature-push` sub-agent name with `task(subagent_type="general")` language. Preserve all inline `must_receive`/`must_not_receive` schemas unchanged. **→ SC-4**

> **⚠️ COMPLIANCE REQUIREMENT:** Every edit to a task file MUST preserve inline `must_receive`/`must_not_receive` schemas exactly as they are. Only the sub-agent name and dispatch language change — never the schema structure, field names, or exclusion lists.
> **⚠️ SELF-REMEDIATION PROTOCOL:** If the exact text to replace is not found in any task file, re-read the file to confirm current content, then adjust the edit to match. Do NOT skip a file because the expected text differs — read and adapt.

## Exit Criteria
- [ ] C1: No `.jsonc` files remain in `.opencode/agents/` (verified via `ls .opencode/agents/*.jsonc`)
- [ ] C2: `git-workflow/SKILL.md` contains no references to `.opencode/agents/*.jsonc` (verified via `grep`)
- [ ] C3: `git-workflow/SKILL.md` contains no "Sub-Agent Tasks for Submodule Operations" heading or table (verified via `grep`)
- [ ] C4: All 8 task files use `task(subagent_type="general")` language for submodule operations (verified via `grep` for absence of dedicated sub-agent names)
- [ ] C5: `git-workflow/SKILL.md` routing section lists submodule ops as standard tasks (verified via `grep`)
