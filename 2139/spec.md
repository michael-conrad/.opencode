---
issue: .opencode#2139
title: "[SPEC] #2139 — Flatten verify-authorization: delete broken task card, move dispatch sequence to SKILL.md Workflows section"
status: draft
created: 2026-07-25
---

## Intent and Executive Summary

- **Problem Statement:** The `approval-gate-scope` skill's `verify-authorization.md` task card tells a sub-agent to orchestrate a multi-step dispatch sequence by calling `task()` on sub-sub-agents. Sub-agents cannot call `task()` — this is a structural category error.
- **Root Cause / Motivation:** Task cards are for sub-agents (leaf-level executors). A file that orchestrates multiple `task()` calls cannot live in `tasks/` because sub-agents cannot dispatch. The multi-step dispatch sequence belongs in the SKILL.md **Workflows** section, which is the canonical location for orchestrator-level dispatch sequences.
- **Approach Chosen:** Delete the broken task card, add a Workflows section to SKILL.md with 3 workflow paths (fast-path, gap-fill-path, full-path), update cross-references, and convert sub-task files from Work State I/O to Result Contract sections.
- **Alternatives Considered & Why Discarded:**
  1. *Fix the task card to not use `task()`* — Discarded because the task card's entire purpose is orchestration; removing `task()` calls would gut its function. The orchestration logic belongs in SKILL.md, not a task card.
  2. *Restructure as a single sub-agent procedure* — Discarded because the 11 sub-steps are independent leaf-level procedures that the orchestrator must dispatch individually. A single sub-agent cannot dispatch sub-sub-agents.
  3. *Use a different dispatch mechanism* — Discarded because `task()` is the only dispatch mechanism available to the orchestrator. No alternative exists.
- **Key Design Decisions:**
  1. Workflows section uses numbered-list-with-sub-bullets format (Prompt, Context, Returns) per `skill-card-description-standards.md` §7.
  2. Sub-steps write result contracts to individual YAML files (`{project_root}/tmp/{issue-N}/verify-authorization/{step-name}.yaml`) instead of a shared work state file.
  3. Each sub-step reads the prior step's result contract to check for failure before proceeding.

## Problem

The `approval-gate-scope` skill's `verify-authorization.md` task card tells a sub-agent to orchestrate a multi-step dispatch sequence by calling `task()` on sub-sub-agents. Sub-agents in this environment do NOT have access to the `task()` tool — they are leaf-level executors. This is a structural category error: a file that orchestrates multiple `task()` calls cannot live in `tasks/` because task cards are for sub-agents, and sub-agents cannot dispatch.

**Evidence (documentation sources):** The `task: deny` restriction is hardcoded in the opencode binary runtime — sub-agents cannot dispatch sub-agents (`task-card-structure-standards.md:137`). Sub-agents also cannot call `skill()` (`skill-card-description-standards.md:176`), cannot follow Trigger Dispatch Tables, and cannot satisfy Orchestrator Entry Criteria (`000-critical-rules.md:174`). Task cards must not contain `task()` or `skill()` calls (`task-card-structure-standards.md:98`). The only documented exception is `multimodal-dispatch` which allows recursive sub-agent tasking for modality routing — this does not apply to authorization verification.

**Evidence (behavioral verification):** A clean-room sub-agent dispatched to verify `task()` access confirmed: the restriction is hardcoded in the opencode binary runtime (not configurable via `opencode.jsonc`), both `task()` and `skill()` are denied to sub-agents, and task cards include a discipline checklist item prohibiting sub-agent dispatch. No exceptions exist for authorization verification workflows.

The sub-task files in `verify-authorization/` (11 files) are already correctly structured as leaf-level procedures. They are not the problem.

## Preconditions

The following preconditions MUST be met before implementation begins:

1. `approval-gate-scope` skill exists with `verify-authorization/` sub-directory containing 11 sub-task files
2. `approval-gate/SKILL.md` has canonical dispatch strings referencing `verify-authorization.md`
3. All cross-referencing files listed in Affected Files exist at their specified paths
4. `work-state-schema.md` exists at `skills/approval-gate-scope/enforcement/work-state-schema.md`

## Dependencies

- **Structural dependency:** The `approval-gate-scope` skill directory must exist with the `verify-authorization/` sub-directory. This is the existing codebase state — no setup required.
- **Cross-reference dependency:** 5 files reference `verify-authorization.md` and must be updated. These are listed explicitly in the Modify section.
- **No external dependencies:** All changes are within `.opencode/skills/` and `.opencode/guidelines/`. No library, API, or third-party dependencies.

## Edge Cases and Error Recovery

| Scenario | Handling |
|----------|----------|
| File to delete (`verify-authorization.md`) does not exist | Skip deletion, log warning, continue. The Workflows section in SKILL.md is the primary deliverable. |
| File to delete (`work-state-schema.md`) does not exist | Skip deletion, log warning, continue. |
| Cross-reference target already updated by another change | Verify current reference before updating. If already correct, skip. |
| Sub-task file already has Result Contract section (no Work State I/O) | Skip modification for that file. |
| Partial implementation failure (some sub-steps fail) | Each sub-step reads prior step's result contract. If prior step BLOCKED, current step returns BLOCKED with `reason: PRIOR_STEP_FAILED`. Orchestrator halts and reports which step failed. |
| Rollback procedure | If any step fails, restore deleted files from git (`git checkout -- <file>`), revert SKILL.md changes, and report the failure. |

## Success Criteria

All SCs (SC-1 through SC-10) MUST pass for this spec to be considered complete. A single FAIL blocks the entire implementation.

| ID | Criterion | Evidence Type | Verification Method | Cost Rationale |
|----|-----------|---------------|---------------------|----------------|
| SC-1 | `verify-authorization.md` task card is deleted | `structural` | `test ! -f skills/approval-gate-scope/tasks/verify-authorization.md` | Structural check prevents downstream behavioral test failure when orchestrator tries to dispatch a non-existent task card. |
| SC-2 | `work-state-schema.md` is deleted | `structural` | `test ! -f skills/approval-gate-scope/enforcement/work-state-schema.md` | Structural check prevents stale schema references. |
| SC-3 | SKILL.md has a `## Workflows` section with exactly 3 workflow entries (`### Verify authorization (fast-path)`, `### Verify authorization (gap-fill-path)`, `### Verify authorization (full-path)`), each as a numbered list (1. through N.) with sub-bullets for Prompt, Context, and Returns | `string` | grep for `## Workflows` and each workflow heading in SKILL.md | String check catches missing Workflows section before behavioral test would fail on dispatch. |
| SC-4 | All 11 sub-task files in `verify-authorization/` are preserved | `structural` | `ls verify-authorization/` returns 11 files | Structural check prevents accidental deletion during refactoring. |
| SC-5 | No sub-task file contains `Work State I/O` heading (replaced with `Result Contract` section) | `string` | grep returns 0 matches for `Work State I/O` in `verify-authorization/` | String check catches stale Work State I/O references that would confuse sub-agents. |
| SC-6 | No sub-task file references `work.md` | `string` | grep returns 0 matches for `work\.md` in `verify-authorization/` | String check catches stale work state file references. |
| SC-7 | Each cross-reference to `verify-authorization.md` is updated to its target: `000-critical-rules.md` → SKILL.md Workflows section, `reconcile-issue-graph.md` → `sub-issue-verification.md`, `verify-closed-issue.md` → `sub-issue-verification.md`, `verify-qa-mode.md` → SKILL.md Workflows section, `screen-issue-gate2.md` → `scope-auto-resolve.md` | `string` | grep for `verify-authorization.md` in cross-referencing files returns 0 matches | String check catches stale cross-references that would break agent routing. |
| SC-8 | `verify-blockers.md` and `verify-sub-issues.md` no longer read work state file | `string` | grep for `work.md` in these files returns 0 matches | String check catches stale work state file reads. |
| SC-9 | Orchestrator calls `task()` exactly N times for N sub-steps in the selected workflow path (fast-path=4, gap-fill-path=4, full-path=13). No single `task()` call dispatches a sub-agent that internally calls `task()`. | `behavioral` | `assert_semantic` on behavioral test output | Behavioral test catches dispatch pattern errors at the earliest gate — cheaper than discovering in CI that sub-agents are calling task(). |
| SC-10 | No sub-agent ever calls `task()` — all sub-agents are leaf-level executors | `behavioral` | `assert_stderr_pattern_absent_all_models "task("` | Behavioral test catches sub-agent task() calls that would fail at runtime with a hardcoded deny. |

## Approach

### Design Principle

The multi-step dispatch sequence moves from the broken task card to the SKILL.md **Workflows** section, which is the canonical location for orchestrator-level dispatch sequences (per `skill-card-description-standards.md` §7 and `skill-card-schema.md`).

The orchestrator reads the Workflows section, dispatches each step as an individual `task()` call, reads the result contract, and proceeds to the next step. No sub-agent calls `task()`. No work state file. Each sub-step writes its result contract to `{project_root}/tmp/{issue-N}/verify-authorization/{step-name}.yaml` and reads the prior step's result contract to check for failure.

### Workflows Section Format

The Workflows section uses the canonical numbered-list-with-sub-bullets format from `skill-card-description-standards.md` §7 (same pattern as `spec-creation/SKILL.md`). Each path is a separate workflow entry with only the steps that path executes — no "Skip when" annotations.

```markdown
## Workflows

### Verify authorization (fast-path)

When the agent needs to verify authorization with minimal checks — no gap-fill, no sub-issue verification required.

1. **Resolve scope** — Parse authorization text and resolve scope/halt_at/gap_fill_actions
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/scope-auto-resolve.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Verify explicit authorization** — Check for "approved"/"go" + author identity + currency
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/verify-explicit-authorization.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

3. **Apply label** — Write authorization-scope label
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/apply-label.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

4. **Auto-dispatch** — Scope-aware auto-route to next skill
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/auto-dispatch.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Verify authorization (gap-fill-path)

When the agent needs to verify authorization and fill in missing artifacts (spec, plan, or implementation) before proceeding.

1. **Resolve scope** — Parse authorization text and resolve scope/halt_at/gap_fill_actions
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/scope-auto-resolve.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Verify explicit authorization** — Check for "approved"/"go" + author identity + currency
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/verify-explicit-authorization.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

3. **Check gap-fill cascade** — Gap-fill precedence and cascade execution
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/gap-fill-cascade.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

4. **Auto-dispatch** — Scope-aware auto-route to next skill
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/auto-dispatch.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Verify authorization (full-path)

When the agent needs to verify authorization with all gates — item decomposition, SC traceability, sub-issues, codebase staleness, blockers, and prior closure checks.

1. **Resolve scope** — Parse authorization text and resolve scope/halt_at/gap_fill_actions
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/scope-auto-resolve.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Verify explicit authorization** — Check for "approved"/"go" + author identity + currency
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/verify-explicit-authorization.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

3. **Apply label** — Write authorization-scope label
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/apply-label.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

4. **Check item decomposition** — Verify item enumeration, dependency ordering, TDD steps
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/item-decomposition-check.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

5. **Check SC traceability** — Verify SC-to-test traceability, RED-phase ordering
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/sc-traceability-check.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

6. **Verify sub-issues** — Sub-issue phase count, verification, closed-issue check
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/sub-issue-verification.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

7. **Check spec-to-plan cascade** — Spec-to-plan approval cascade
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/spec-to-plan-cascade.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

8. **Check gap-fill cascade** — Gap-fill precedence and cascade execution
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/gap-fill-cascade.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

9. **Verify codebase** — Staleness detection, superseding issue check
   - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/verify-codebase.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, issues_prefix, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

10. **Verify blockers** — Blocking dependency check
    - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/verify-blockers.md\` and follow its instructions. Issue: {issue_number}."`
    - Context: `{issue_number, issues_prefix, project_root}`
    - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

11. **Verify closed issue (main)** — Main issue prior-closure verification
    - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/verify-closed-issue-main.md\` and follow its instructions. Issue: {issue_number}."`
    - Context: `{issue_number, issues_prefix, project_root}`
    - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

12. **Verify already implemented** — Terminal gate: auto-close or proceed
    - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/verify-already-implemented.md\` and follow its instructions. Issue: {issue_number}."`
    - Context: `{issue_number, issues_prefix, project_root}`
    - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

13. **Auto-dispatch** — Scope-aware auto-route to next skill
    - Prompt: `"Read \`skills/approval-gate-scope/tasks/verify-authorization/auto-dispatch.md\` and follow its instructions. Issue: {issue_number}."`
    - Context: `{issue_number, issues_prefix, project_root}`
    - Returns: `{status, finding_summary, artifact_path, blocker_reason}`
```

### Result Contract File Pattern

Each sub-step writes its result contract to `{project_root}/tmp/{issue-N}/verify-authorization/{step-name}.yaml`. The next sub-step reads this file to check if the prior step succeeded. If the prior step's `status` is not `DONE`, the current step returns BLOCKED with `reason: PRIOR_STEP_FAILED`.

The orchestrator reads only the final step's result contract (`auto-dispatch.yaml`) to determine the next action.

### Delete

1. `skills/approval-gate-scope/tasks/verify-authorization.md` — The broken task card that tells sub-agents to call `task()`. Its purpose is replaced by the SKILL.md Workflows section.

2. `skills/approval-gate-scope/enforcement/work-state-schema.md` — No longer needed. Sub-steps write result contracts to individual YAML files, not a shared work state file.

### Create

3. `skills/approval-gate-scope/tasks/apply-label.md` — New leaf-level task card. Referenced in step 3 of fast-path and full-path workflows. Procedure: read authorization scope from context, apply `approved-for-<scope>` label via GitHub API, remove prior scope and `needs-approval` labels. Returns result contract with `{status, finding_summary, artifact_path, blocker_reason}`.

4. `skills/approval-gate-scope/tasks/verify-authorization/verify-explicit-authorization.md` — New leaf-level task card. Referenced in step 2 of all workflows. Procedure: read issue comments via GitHub API, check for "approved"/"go" from a human author (MEMBER/OWNER/COLLABORATOR association), verify authorization is current (not superseded by a later revision), record author identity and timestamp. Returns result contract with `{status, finding_summary, artifact_path, blocker_reason}`.

### Modify

5. `skills/approval-gate-scope/SKILL.md` — Add a Workflows section with 3 verify-authorization workflow entries (fast-path, gap-fill-path, full-path), each as a numbered list with sub-bullets for Prompt, Context, Returns. Remove the old Trigger Dispatch Table entry for `"verify authorization"`. Remove `work-state-schema.md` from Enforcement Modules table.

6. All 11 sub-task files in `verify-authorization/` — Replace `Work State I/O` sections with `Result Contract` sections. Each sub-task writes its result contract to `{project_root}/tmp/{issue-N}/verify-authorization/{step-name}.yaml` and reads the prior step's result contract to check for failure. If the prior step's `status` is not `DONE`, return BLOCKED with `reason: PRIOR_STEP_FAILED`.

7. `skills/approval-gate/SKILL.md` — Update 4 canonical dispatch strings that reference `verify-authorization.md` (verify-authorization, apply-label, revision-revocation, bug-discovery-protocol).

8. Cross-referencing files — Update stale references to `verify-authorization.md`:
   - `guidelines/000-critical-rules.md` → point to SKILL.md Workflows section
   - `skills/approval-gate-scope/tasks/reconcile-issue-graph.md` → point to `sub-issue-verification.md`
   - `skills/approval-gate-scope/tasks/verify-closed-issue.md` → point to `sub-issue-verification.md`
   - `skills/approval-gate-scope/tasks/verify-qa-mode.md` → point to SKILL.md Workflows section
   - `skills/approval-gate-scope/tasks/screen/screen-issue-gate2.md` → point to `scope-auto-resolve.md`

9. `verify-blockers.md` and `verify-sub-issues.md` — Remove work state file reads. Authorization state and phase tracking come from orchestrator-passed context, not work state file.

### Preserve

10. All 11 sub-task files in `verify-authorization/` — Core procedure content preserved. Only Work State I/O sections removed and replaced with Result Contract sections.

## Affected Files

### Deleted
- `skills/approval-gate-scope/tasks/verify-authorization.md`
- `skills/approval-gate-scope/enforcement/work-state-schema.md`

### Created
- `skills/approval-gate-scope/tasks/apply-label.md`
- `skills/approval-gate-scope/tasks/verify-authorization/verify-explicit-authorization.md`

### Modified
- `skills/approval-gate-scope/SKILL.md`
- `skills/approval-gate-scope/tasks/verify-authorization/scope-auto-resolve.md`
- `skills/approval-gate-scope/tasks/verify-authorization/item-decomposition-check.md`
- `skills/approval-gate-scope/tasks/verify-authorization/sc-traceability-check.md`
- `skills/approval-gate-scope/tasks/verify-authorization/sub-issue-verification.md`
- `skills/approval-gate-scope/tasks/verify-authorization/spec-to-plan-cascade.md`
- `skills/approval-gate-scope/tasks/verify-authorization/verify-codebase.md`
- `skills/approval-gate-scope/tasks/verify-authorization/verify-blockers.md`
- `skills/approval-gate-scope/tasks/verify-authorization/verify-closed-issue-main.md`
- `skills/approval-gate-scope/tasks/verify-authorization/verify-already-implemented.md`
- `skills/approval-gate-scope/tasks/verify-authorization/auto-dispatch.md`
- `skills/approval-gate-scope/tasks/verify-blockers.md`
- `skills/approval-gate-scope/tasks/verify-sub-issues.md`
- `skills/approval-gate/SKILL.md`
- `guidelines/000-critical-rules.md`
- `skills/approval-gate-scope/tasks/reconcile-issue-graph.md`
- `skills/approval-gate-scope/tasks/verify-closed-issue.md`
- `skills/approval-gate-scope/tasks/verify-qa-mode.md`
- `skills/approval-gate-scope/tasks/screen/screen-issue-gate2.md`

### Preserved (no content changes)
- `skills/approval-gate-scope/tasks/verify-authorization/gap-fill-cascade.md` (already has correct Result Contract — no Work State I/O)
