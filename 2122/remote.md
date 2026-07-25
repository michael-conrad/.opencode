---
remote_issue: 2122
remote_url: https://github.com/michael-conrad/.opencode/issues/2122
---

> **Full spec and artifacts: [`.opencode/.issues/2122/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2122/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2122/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`010-approval-gate.md` contains sections only relevant when specific skills are dispatched — not at session start. These consume preloaded context unnecessarily.

## Scope

Move 6 sections to skill cards (approval-gate, audit, issue-operations). Keep 13 universal sections in 010.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Spec-to-Plan Cascade → approval-gate skill card | string |
| SC-2 | Re-implementation Workflow → approval-gate skill card | string |
| SC-3 | Label Handling → approval-gate skill card | string |
| SC-4 | Audit Auto-Fix Exemption → audit skill card | string |
| SC-5 | Bug Report Response → issue-operations skill card | string |
| SC-6 | Bug Discovery Protocol → approval-gate skill card | string |
| SC-7 | All 13 keep sections remain in 010 | string |
| SC-8 | No content loss — moved sections have equivalent content in target cards | behavioral |
| SC-9 | No orphaned cross-references to moved sections | string |
| SC-10 | No line-count or word-count metrics used as success measurement | string |

## Files Affected

- `.opencode/guidelines/010-approval-gate.md`
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/audit/SKILL.md`
- `.opencode/skills/issue-operations/SKILL.md`

## Dependencies

None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
