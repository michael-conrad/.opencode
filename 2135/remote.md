---
remote_issue: 2135
remote_url: https://github.com/michael-conrad/.opencode/issues/2135
---

> **Full spec and artifacts: [`.opencode/.issues/2135/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2135/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2135/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`130-authority-source.md` asserts "code wins" — the wrong framing for a spec-driven project. Specs are the primary artifact for intent; code is the implementation.

## Scope

Complete rewrite establishing dual-authority model: spec authoritative for intent, code authoritative for state. 6 rules. Remove 3 superseded rules.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Dual-authority principle stated | string |
| SC-2 | Rule 1: Spec for intent, code for state | string |
| SC-3 | Rule 2: Spec before code | string |
| SC-4 | Rule 3: Documentation Drift Protocol | string |
| SC-5 | Rule 4: Spec revision revokes plan approval | string |
| SC-6 | Rule 5: Suppression of Reactive Remediation | string |
| SC-7 | Rule 6: Verification against spec | string |
| SC-8 | Superseding Issues section removed | string |
| SC-9 | Verification First section removed | string |
| SC-10 | Plan Audit Code Deep Dive section removed | string |

## Files Affected

- `.opencode/guidelines/130-authority-source.md`
- `.opencode/skills/spec-creation/SKILL.md`

## Dependencies

None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
