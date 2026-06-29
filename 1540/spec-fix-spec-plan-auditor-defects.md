# Spec-Fix: Systemic Defects in Spec Writer, Plan Writer, and Auditor Skills

**Source:** Issue #1540 — Single-Path Workflow  
**Created:** 2026-06-29  
**Parent:** #1540

## Problem

The spec for issue #1540 had four defects that should have been caught by the spec writer, plan writer, and auditor skills. These defects are systemic — they recur because the skills lack rules to prevent them:

1. **Either/or is not a single path.** SC-7 said "removed or unified" — two possible outcomes with no decision criteria. A single-path spec must define exactly one outcome. The spec-creation skill has no rule requiring that either/or choices in Required Actions be resolved to a single concrete outcome.

2. **"Unified" was not concretely defined.** The spec said "delegate to create-pr" but didn't specify what happens to the 6 unique capabilities of `release-promotion.md` (semver tagging, submodule SHA locking, platform release creation, release notes synthesis, post-merge execution model, submodule/non-submodule routing). The spec-creation skill has no rule requiring that every "delegate to" or "unified" reference specify exact file changes including routing table updates, cross-reference updates, and capability migration.

3. **Routing table not addressed.** The dual-path routing in `git-workflow/SKILL.md` was the heart of the problem, but the spec didn't mention it. The concern-separation auditor has no check for routing table changes being omitted when a task file is removed.

4. **Evidence type mismatch.** SC-7 was `structural` but the change affects runtime agent dispatch routing — should be `behavioral` per the automatic uplift rule. The spec-auditor has no check for either/or ambiguity in Required Actions, and the plan-fidelity auditor has no check for undefined delegation targets.

## Root Cause

| Defect | Root Cause | Missing Rule |
|--------|-----------|--------------|
| Either/or ambiguity | spec-creation skill has no rule requiring single concrete outcome per Required Action | `spec-creation` → Required Actions must be single-outcome |
| Undefined delegation | spec-creation skill has no rule requiring concrete file changes for "delegate to" references | `spec-creation` → Delegation targets must specify exact file changes |
| Missing routing table changes | concern-separation auditor has no check for routing table omissions when task files are removed | `concern-separation` → CS-ROUTING check |
| Evidence type mismatch | spec-auditor has no check for either/or ambiguity; plan-fidelity has no check for undefined delegation | `spec-audit` → SC-DET-AMBIGUITY; `plan-fidelity` → PF-DELEGATION |

## Required Actions

### 1. Add single-outcome rule to spec-creation skill

- **File:** `.opencode/skills/spec-creation/tasks/write.md`
- **Change:** Add a new step after Step 2 (Eliminate Ambiguity) that scans Required Actions for either/or patterns ("or", "either", "alternatively") and requires resolution to a single concrete outcome before the spec is finalized.
- **SC:** SC-1 (behavioral — verify spec writer rejects either/or in Required Actions)

### 2. Add delegation concretization rule to spec-creation skill

- **File:** `.opencode/skills/spec-creation/tasks/write.md`
- **Change:** Add a new step that requires every "delegate to", "unified", "merged into", or "replaced by" reference in Required Actions to specify:
  - The exact file changes for each capability being migrated
  - Routing table updates (if the target file has a routing/dispatch table)
  - Cross-reference updates (if other files reference the removed file)
  - Capability migration (what happens to each unique capability of the removed file)
- **SC:** SC-2 (behavioral — verify spec writer requires concrete delegation targets)

### 3. Add SC-DET-AMBIGUITY check to spec-auditor

- **File:** `.opencode/skills/adversarial-audit/tasks/spec-audit.md`
- **Change:** Add a new evaluation criterion `SC-DET-AMBIGUITY` to the Step 3 evaluation criteria table. The criterion checks for either/or patterns ("or", "either", "alternatively") in Required Actions. If any Required Action contains an unresolved either/or choice, the criterion FAILs.
- **SC:** SC-3 (behavioral — verify spec-auditor detects either/or in Required Actions)

### 4. Add PF-DELEGATION check to plan-fidelity auditor

- **File:** `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`
- **Change:** Add a new evaluation criterion `PF-DELEGATION` to the Step 3 evaluation criteria table. The criterion checks that every "delegate to", "unified", "merged into", or "replaced by" reference in the spec has a corresponding concrete definition in the plan — specific file changes, routing table updates, cross-reference updates, and capability migration.
- **SC:** SC-4 (behavioral — verify plan-fidelity auditor detects undefined delegation targets)

### 5. Add CS-ROUTING check to concern-separation auditor

- **File:** `.opencode/skills/adversarial-audit/tasks/concern-separation.md`
- **Change:** Add a new evaluation criterion `CS-ROUTING` to the Step 2 evaluation criteria table. The criterion checks that when a spec removes or delegates a task file that has a routing/dispatch table, the spec also addresses the routing table changes. If the routing table is not updated, the criterion FAILs.
- **SC:** SC-5 (behavioral — verify concern-separation auditor detects missing routing table changes)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Spec writer rejects either/or in Required Actions — new step in `write.md` scans for "or"/"either"/"alternatively" and requires single concrete outcome | behavioral |
| SC-2 | Spec writer requires concrete delegation targets — new step in `write.md` requires exact file changes, routing table updates, cross-reference updates, and capability migration for every "delegate to"/"unified"/"merged into"/"replaced by" reference | behavioral |
| SC-3 | Spec-auditor detects either/or in Required Actions — new `SC-DET-AMBIGUITY` criterion in `spec-audit.md` evaluation table | behavioral |
| SC-4 | Plan-fidelity auditor detects undefined delegation targets — new `PF-DELEGATION` criterion in `plan-fidelity.md` evaluation table | behavioral |
| SC-5 | Concern-separation auditor detects missing routing table changes — new `CS-ROUTING` criterion in `concern-separation.md` evaluation table | behavioral |

## Non-Goals

- Does NOT change the existing SC-DET determinism check in spec-auditor — SC-DET-AMBIGUITY is a new criterion, not a replacement
- Does NOT change the existing PF-3 (SC coverage) check in plan-fidelity — PF-DELEGATION is a new criterion, not a replacement
- Does NOT change the existing CS-1 through CS-6 checks in concern-separation — CS-ROUTING is a new criterion, not a replacement
- Does NOT change the existing evidence type classification gate (critical-rules-BEH-EV) — SC-7's evidence type mismatch is already covered by that rule; this spec adds the upstream prevention
- Does NOT change the spec-creation skill's SKILL.md or other task files — only `write.md` is modified
- Does NOT change the adversarial-audit skill's SKILL.md — only the individual task files are modified
- Does NOT add behavioral enforcement tests — those are created during implementation per the post-approval spec mandate

## Regression Invariants

1. All existing spec-creation rules remain unchanged — this is an additive change to `write.md` only
2. All existing spec-auditor criteria remain unchanged — SC-DET-AMBIGUITY is a new criterion, not a modification
3. All existing plan-fidelity criteria remain unchanged — PF-DELEGATION is a new criterion, not a modification
4. All existing concern-separation criteria remain unchanged — CS-ROUTING is a new criterion, not a modification
5. Existing specs that already pass all auditor checks continue to pass — the new criteria only flag defects that were previously undetected
6. The existing SC-DET determinism check continues to function as before — SC-DET-AMBIGUITY is additive
