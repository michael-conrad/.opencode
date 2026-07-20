> **Full spec and artifacts: [`.opencode/.issues/1540/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1540)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1540/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

**Parent:** #1540

## Problem

The spec for issue #1540 had four defects that should have been caught by the spec writer, plan writer, and auditor skills. These defects are systemic — they recur because the skills lack rules to prevent them:

1. **Either/or is not a single path.** SC-7 said "removed or unified" — two possible outcomes with no decision criteria. The spec-creation skill has no rule requiring that either/or choices in Required Actions be resolved to a single concrete outcome.

2. **"Unified" was not concretely defined.** The spec said "delegate to create-pr" but didn't specify what happens to the 6 unique capabilities of `release-promotion.md`. The spec-creation skill has no rule requiring that every "delegate to" or "unified" reference specify exact file changes including routing table updates, cross-reference updates, and capability migration.

3. **Routing table not addressed.** The dual-path routing in `git-workflow/SKILL.md` was the heart of the problem, but the spec didn't mention it. The concern-separation auditor has no check for routing table changes being omitted when a task file is removed.

4. **Evidence type mismatch.** SC-7 was `structural` but the change affects runtime agent dispatch routing — should be `behavioral`. The spec-auditor has no check for either/or ambiguity, and the plan-fidelity auditor has no check for undefined delegation targets.

## Required Actions

### 1. Add single-outcome rule to spec-creation skill
- **File:** `.opencode/skills/spec-creation/tasks/write.md`
- **Change:** Add a new step after Step 2 (Eliminate Ambiguity) that scans Required Actions for either/or patterns ("or", "either", "alternatively") and requires resolution to a single concrete outcome.

### 2. Add delegation concretization rule to spec-creation skill
- **File:** `.opencode/skills/spec-creation/tasks/write.md`
- **Change:** Add a new step requiring every "delegate to", "unified", "merged into", or "replaced by" reference to specify exact file changes, routing table updates, cross-reference updates, and capability migration.

### 3. Add SC-DET-AMBIGUITY check to spec-auditor
- **File:** `.opencode/skills/adversarial-audit/tasks/spec-audit.md`
- **Change:** Add `SC-DET-AMBIGUITY` criterion checking for either/or patterns in Required Actions.

### 4. Add PF-DELEGATION check to plan-fidelity auditor
- **File:** `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`
- **Change:** Add `PF-DELEGATION` criterion checking that every delegation reference has concrete plan definitions.

### 5. Add CS-ROUTING check to concern-separation auditor
- **File:** `.opencode/skills/adversarial-audit/tasks/concern-separation.md`
- **Change:** Add `CS-ROUTING` criterion checking that routing table changes are addressed when a task file is removed.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Spec writer rejects either/or in Required Actions | behavioral |
| SC-2 | Spec writer requires concrete delegation targets | behavioral |
| SC-3 | Spec-auditor detects either/or in Required Actions | behavioral |
| SC-4 | Plan-fidelity auditor detects undefined delegation targets | behavioral |
| SC-5 | Concern-separation auditor detects missing routing table changes | behavioral |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)