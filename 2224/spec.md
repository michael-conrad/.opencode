# [SPEC] Move verify-plan-pipeline from approval-gate-scope to writing-plans

## Intent and Executive Summary

Move the `verify-plan-pipeline` task from `approval-gate-scope` to `writing-plans`, and update all cross-references and skill descriptions so that agent intent matching routes "verify plan pipeline" queries to the correct skill.

**Problem Statement:** The `verify-plan-pipeline` task validates the `writing-plans` pipeline but lives in `approval-gate-scope`. The TDT routes "verify plan pipeline" to `approval-gate` instead of `writing-plans`.

**Root Cause/Motivation:** When the task was originally created, it was placed in `approval-gate-scope` because it was conceived as a verification gate. In practice it validates `writing-plans` pipeline artifacts, making it a post-pipeline integrity check for `writing-plans`.

**Approach Chosen:** Move the task file, update all cross-references in SKILL.md files, and update skill descriptions for correct agent intent matching.

**Alternatives Considered:**
- **Leave in place and update TDT only** — rejected because the task file location would still be wrong, creating confusion for anyone reading the skill directory structure
- **Merge into an existing writing-plans task** — rejected because `verify-plan-pipeline` is a distinct gate with its own entry/exit criteria; merging would violate single-responsibility

**Key Design Decisions:**
- Task procedure unchanged — only location and routing change
- `writing-plans` gets a TDT and Invocation section (it currently lacks both)
- No changes to guidelines or enforcement tests

**User Intent:** When a developer says "verify plan pipeline" or "check pipeline completeness", the agent should route to `writing-plans` where the plan pipeline verification logic lives, not to `approval-gate`.

## Problem

The `verify-plan-pipeline` task lives in `approval-gate-scope` but validates that the `writing-plans` pipeline was followed (checks for spec file, feature branch, Z3 artifacts, audit artifacts, completion artifacts). This is a post-pipeline integrity check for `writing-plans`, not an authorization scope concern.

The Trigger Dispatch Table (TDT) in `approval-gate/SKILL.md` routes the trigger phrase "verify plan pipeline" / "check pipeline completeness" to `approval-gate-scope --task verify-plan-pipeline`. The TDT in `approval-gate-scope/SKILL.md` also routes it to `verify-plan-pipeline`. Neither `writing-plans/SKILL.md` has a TDT entry for this trigger phrase, nor does its description include these trigger phrases for agent intent matching. An agent dispatched with "verify plan pipeline" lands on `approval-gate` instead of `writing-plans`.

## Requirements

1. The `verify-plan-pipeline` task file must live in `writing-plans/tasks/` where it belongs
2. All references in `approval-gate` and `approval-gate-scope` must be removed
3. `writing-plans/SKILL.md` must have a TDT row, Invocation entry, task card, file structure entry, and workflow step for `verify-plan-pipeline`
4. `writing-plans` skill description must include trigger phrases for plan pipeline verification
5. Agent intent matching must route "verify plan pipeline" to `writing-plans`, not `approval-gate`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `verify-plan-pipeline` task file exists at `writing-plans/tasks/verify-plan-pipeline.md` | `structural` | File exists at target path |
| SC-2 | `approval-gate/SKILL.md` no longer references `verify-plan-pipeline` in Trigger Dispatch Table or Invocation section | `string` | grep for `verify-plan-pipeline` in `approval-gate/SKILL.md` returns no matches |
| SC-3 | `approval-gate-scope/SKILL.md` no longer references `verify-plan-pipeline` in Trigger Dispatch Table | `string` | grep for `verify-plan-pipeline` in `approval-gate-scope/SKILL.md` returns no matches |
| SC-4 | `writing-plans/SKILL.md` includes `verify-plan-pipeline` in its Task Cards table | `string` | grep for `verify-plan-pipeline` in `writing-plans/SKILL.md` finds it in Task Cards section |
| SC-5 | `writing-plans/SKILL.md` includes `verify-plan-pipeline` in its File Structure listing | `string` | grep for `verify-plan-pipeline` in `writing-plans/SKILL.md` finds it in File Structure section |
| SC-6 | `writing-plans/SKILL.md` description includes trigger phrases for plan pipeline verification | `string` | Description contains "verify plan pipeline" or "check pipeline completeness" |
| SC-7 | `approval-gate` skill description no longer includes "verify plan pipeline" or "check pipeline completeness" trigger phrases | `string` | grep for those phrases in `approval-gate/SKILL.md` description returns no matches |
| SC-8 | `approval-gate-scope` skill description no longer includes "verify plan pipeline" or "check pipeline completeness" trigger phrases | `string` | grep for those phrases in `approval-gate-scope/SKILL.md` description returns no matches |
| SC-9 | `writing-plans/SKILL.md` has a Trigger Dispatch Table row for "verify plan pipeline" / "check pipeline completeness" | `string` | TDT row exists mapping trigger phrases to `verify-plan-pipeline` task |
| SC-10 | `writing-plans/SKILL.md` has an Invocation section entry for `verify-plan-pipeline` | `string` | Invocation table has row for `verify-plan-pipeline` with canonical dispatch string |
| SC-11 | `writing-plans/SKILL.md` Workflows section includes a "verify pipeline" workflow or step | `string` | Workflows section references `verify-plan-pipeline` dispatch |
| SC-12 | Agent dispatched with "verify plan pipeline" routes to `writing-plans` skill, not `approval-gate` | `behavioral` | `opencode run` with prompt containing "verify plan pipeline" → clean-room semantic inspector evaluates stderr for `Skill "writing-plans"` dispatch and absence of `Skill "approval-gate"` dispatch |

## Items

| Item | SCs | Description |
|------|-----|-------------|
| 1 | SC-1 | Move task file from approval-gate-scope to writing-plans |
| 2 | SC-2, SC-3, SC-7, SC-8 | Remove references from approval-gate and approval-gate-scope |
| 3 | SC-4, SC-5, SC-6, SC-9, SC-10, SC-11 | Add references to writing-plans |
| 4 | SC-12 | Verify behavioral routing |

## Dependencies

None. This is a self-contained file move and cross-reference update within `.opencode/skills/`.

## Traceability

| Artifact | Location |
|----------|----------|
| Spec | `.opencode/.issues/2224/spec.md` |
| Task file (source) | `.opencode/skills/approval-gate-scope/tasks/verify-plan-pipeline.md` |
| Task file (target) | `.opencode/skills/writing-plans/tasks/verify-plan-pipeline.md` |
| approval-gate SKILL.md | `.opencode/skills/approval-gate/SKILL.md` |
| approval-gate-scope SKILL.md | `.opencode/skills/approval-gate-scope/SKILL.md` |
| writing-plans SKILL.md | `.opencode/skills/writing-plans/SKILL.md` |

## Documentation Sources

- `approval-gate/SKILL.md` Trigger Dispatch Table: TDT row routing "verify plan pipeline" to `approval-gate-scope --task verify-plan-pipeline`
- `approval-gate/SKILL.md` Invocation section: Invocation row for `verify-plan-pipeline`
- `approval-gate-scope/SKILL.md` Trigger Dispatch Table: TDT row routing "verify plan pipeline" to `verify-plan-pipeline`
- `approval-gate-scope/tasks/verify-plan-pipeline.md`: Task file with 6-step procedure
- `writing-plans/SKILL.md`: No TDT, no Invocation section, no reference to `verify-plan-pipeline`

## Enforcement Gate

All SCs with `string` evidence type are verified by grep. SC-12 (`behavioral`) requires clean-room semantic inspection of `opencode run` stderr output. No SC may be weakened or reclassified to evade implementation.

## Cost Frame

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

This is a file move and cross-reference update. No runtime behavior changes to the task procedure itself. Implementation work is measured by whether all SCs pass with 100% clean PASS.

## Edge Cases

| Case | Handling |
|------|----------|
| Task file already exists at target | Overwrite with source content (idempotent) |
| Source file already deleted | Skip delete step (idempotent) |
| writing-plans has no TDT section | Create one (writing-plans currently lacks TDT and Invocation sections) |
| writing-plans has no Invocation section | Create one |
| Behavioral test times out | Increase timeout, inspect stderr, diagnose root cause per Test Integrity Mandate |

## Not Included

- Changes to the task procedure itself (the 6-step verification logic stays the same)
- Changes to any other skill's TDT or descriptions
- Changes to guidelines or enforcement tests (SC-12 behavioral test is new but no existing test changes needed)
- Changes to the `verify-plan-pipeline` task's entry/exit criteria or procedure

## Approach

### Phase 1: Move task file

1. Copy `approval-gate-scope/tasks/verify-plan-pipeline.md` to `writing-plans/tasks/verify-plan-pipeline.md`
2. Delete the original file from `approval-gate-scope/tasks/`

### Phase 2: Update approval-gate/SKILL.md

1. Remove the TDT row: `| "verify plan pipeline" / "check pipeline completeness" | \`verify-plan-pipeline\` | ...`
2. Remove the Invocation row: `| \`verify-plan-pipeline\` | \`task(...)\` | ...`

### Phase 3: Update approval-gate-scope/SKILL.md

1. Remove the TDT row for `verify-plan-pipeline`
2. No description change needed (description does not contain these trigger phrases)

### Phase 4: Update writing-plans/SKILL.md

1. Add `verify-plan-pipeline` to Task Cards table
2. Add `tasks/verify-plan-pipeline.md` to File Structure listing
3. Add a "verify pipeline" workflow step in Workflows section
4. Add Trigger Dispatch Table with row for "verify plan pipeline" / "check pipeline completeness"
5. Add Invocation section entry for `verify-plan-pipeline`
6. Update description to include "verify plan pipeline" / "check pipeline completeness" trigger phrases

### Phase 5: Verify

1. grep for stale references — confirm no remaining references in approval-gate files
2. grep for new references — confirm writing-plans has all required references
3. Run behavioral test: dispatch agent with "verify plan pipeline" prompt, confirm it routes to writing-plans

## Affected Files

- `.opencode/skills/approval-gate/SKILL.md` — remove TDT and Invocation rows
- `.opencode/skills/approval-gate-scope/SKILL.md` — remove TDT row
- `.opencode/skills/approval-gate-scope/tasks/verify-plan-pipeline.md` — delete (moved)
- `.opencode/skills/writing-plans/SKILL.md` — add TDT, Invocation, task card, file structure, workflow step, update description
- `.opencode/skills/writing-plans/tasks/verify-plan-pipeline.md` — new file (moved from approval-gate-scope)


