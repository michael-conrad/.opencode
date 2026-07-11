# [SPEC-FIX] Remove dead body-revision check from comment task, add routing gate for spec/plan corrections

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The `issue-operations/tasks/comment.md` task file has a dead body-revision check (Step 1.5b) that creates a routing trap. The classification table at line 56 of `comment.md` says "Revising/correcting spec → internal (triggers Phase 3 body update)" but the procedural gate at line 65 only fires for stakeholder-classified content. The body update never executes. Agents dispatch to `issue-operations --task comment` thinking it will update the spec body, but the correction gets stranded in `comments.md` while the spec body stays stale.

The correct architecture already exists:
- `spec-creation --task change-control` handles full spec revision (update body → post executive summary comment to GitHub for substantive changes → HALT for re-authorization)
- `writing-plans --task update` handles plan revision

## Root Cause Analysis

The comment task was designed with a dual purpose: posting comments AND revising spec bodies. This violates the Single Concern Principle. The body-revision path (Step 1.5b) was added as a convenience shortcut, but it has a fatal design flaw: the classification gate at Step 1.5 classifies "Revising/correcting spec" as `internal`, and Step 1.5b only fires for `stakeholder`-classified content. The body update path is unreachable.

The dead annotation "(triggers Phase 3 body update)" on line 56 is misleading — it promises a behavior that the code cannot deliver. Agents read this annotation and route to the comment task expecting body revision, but the procedural gate silently drops the revision.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/issue-operations/tasks/comment.md` | Remove Step 1.5b, remove dead annotation from classification table, add routing gate |

## Fix

1. **Remove Step 1.5b (body-revision check)** from `comment.md` entirely. The comment task's only job is posting comments — not revising bodies.

2. **Remove the dead parenthetical** "(triggers Phase 3 body update)" from the classification table at line 56. The annotation promises behavior that does not exist.

3. **Add a routing gate** to the comment task that redirects spec/plan corrections to the correct pipeline:
   - Spec corrections → `spec-creation --task change-control`
   - Plan corrections → `writing-plans --task update`

4. **Ensure the comment task's only job is posting comments** — not revising bodies, not updating specs, not modifying plans.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation |
|----|-----------|---------------|---------------------|-------------|
| SC-1 | Step 1.5b (body-revision check) is removed from `comment.md` | `string` | `grep -c "Step 1.5b" .opencode/skills/issue-operations/tasks/comment.md` returns 0 | Re-read file, confirm removal |
| SC-2 | Dead parenthetical "(triggers Phase 3 body update)" is removed from classification table | `string` | `grep -c "triggers Phase 3 body update" .opencode/skills/issue-operations/tasks/comment.md` returns 0 | Re-read file, confirm removal |
| SC-3 | Comment task has a routing gate that redirects spec corrections to `spec-creation --task change-control` | `string` | `grep "spec-creation.*change-control" .opencode/skills/issue-operations/tasks/comment.md` returns match | Add routing gate prose |
| SC-4 | Comment task has a routing gate that redirects plan corrections to `writing-plans --task update` | `string` | `grep "writing-plans.*update" .opencode/skills/issue-operations/tasks/comment.md` returns match | Add routing gate prose |
| SC-5 | Agent routes spec corrections to `spec-creation`, not `issue-operations --task comment` | `behavioral` | `opencode-cli run` with spec-correction prompt → stderr shows `Skill "spec-creation"` dispatch, NOT `issue-operations` comment task | Diagnose routing, fix gate, re-test |
| SC-6 | Comment task's only job is posting comments — no body-revision logic remains | `string` | `grep -c "body.*revision\|body.*update\|spec body" .opencode/skills/issue-operations/tasks/comment.md` returns 0 (excluding the routing gate itself) | Re-read file, confirm removal |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1861](https://github.com/michael-conrad/.opencode/issues/1861) | RELATED | Substantive comment gate reinforcement — same file, different concern |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source read | `.opencode/skills/issue-operations/tasks/comment.md` | Identify dead code (Step 1.5b, line 56 annotation) |
| Direct source read | `.opencode/skills/spec-creation/tasks/change-control.md` | Verify correct spec revision pipeline exists |
| Direct source read | `.opencode/skills/writing-plans/tasks/update.md` | Verify correct plan revision pipeline exists |
| Direct source read | `.opencode/skills/issue-operations/SKILL.md` | Verify comment task routing table |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1871/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
