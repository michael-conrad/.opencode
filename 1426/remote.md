---
remote_issue: 1426
remote_url: "https://github.com/michael-conrad/.opencode/issues/1426"
last_sync: 2026-06-26T03:05:44Z
source: github.com
---

## Problem

The "Discard all work on sub-agent failure before re-task" and "Orchestrator inline work irreversibly poisons the pipeline" rules in `020-go-prohibitions.md` are scoped to pipeline execution artifacts (sub-agent output, work state files, cached results). However, the agent over-applies them to **issue bodies, plan files, and spec files** — tracking documents that should be edited in place, not discarded and recreated.

**Example:** Issue #1425 had a valid problem statement and valid SCs but contained an "Implementation Plan" section that belonged in the plan, not the spec. Instead of editing the body to remove the defective section, the agent closed the issue as `not_planned` — destroying the tracking artifact, losing the SCs, and wasting the discussion context.

**Root cause:** The discard rules lack an explicit scope boundary. They say "ALL work produced by that sub-agent MUST be discarded" without distinguishing between:
- **Pipeline artifacts** (sub-agent output, work state files, cached results, temp files) — discard is correct
- **Published tracking documents** (issue bodies, plan files, spec files, comments) — edit/remediate is correct

## Affected Files

| File | Change |
|------|--------|
| `guidelines/020-go-prohibitions.md` | Add scope carveout to "Discard all work on sub-agent failure" rule |
| `guidelines/020-go-prohibitions.md` | Add scope carveout to "Orchestrator inline work poisons the pipeline" rule |
| `guidelines/020-go-prohibitions.md` | Add positive instruction: issue/plan/spec defects are edited, not discarded |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | "Discard all work on sub-agent failure" rule in `020-go-prohibitions.md` has an explicit scope carveout: "This discard requirement applies to pipeline execution artifacts (sub-agent output, work state files, cached results, temp files). It does NOT apply to published tracking documents (issue bodies, plan files, spec files, comments) — those are edited in place to fix defects." | `string` | grep for carveout text adjacent to discard rule |
| SC-2 | "Orchestrator inline work poisons the pipeline" rule has an explicit scope carveout: "The pipeline restart applies to pipeline state (work state files, cached results, sub-agent output). It does NOT apply to published artifacts (issues, plans, specs) — those are edited in place." | `string` | grep for carveout text adjacent to poisoned pipeline rule |
| SC-3 | A positive instruction exists: "When an issue body, plan file, or spec file has a content defect, the correct action is to edit the body to fix the defect. Closing the issue and recreating is the last resort, not the first." | `string` | grep for "edit the body" or "edit in place" in the same section |
| SC-4 | Agent does NOT close an issue with valid SCs and problem statement when the only defect is a removable section in the body | `behavioral` | `opencode-cli run` with a scenario where an issue body has a defective section; assert agent edits the body instead of closing the issue |

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Carveout weakens the discard mandate for pipeline artifacts | Low | Medium | Carveout is explicit about scope — pipeline artifacts still require discard. Only published tracking documents are exempt. |
| Agent confuses "edit in place" with "never discard pipeline artifacts" | Low | Low | The two rules are adjacent but distinct. The carveout is a scope qualifier, not a repeal. |

## Dependencies

None. Self-contained fix to `020-go-prohibitions.md`.

## Plan

Implementation plan: [`.opencode/.issues/1426/plan.md`](https://github.com/michael-conrad/.opencode/tree/issues-data/1426/plan.md)

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
