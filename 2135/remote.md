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

Complete rewrite establishing dual-authority model: spec authoritative for intent, code authoritative for state. 6 rules. Remove 3 superseded rules (relocate to spec-creation SKILL.md and 065-verification-honesty.md).

## Requirements

| ID | Requirement |
|----|-------------|
| REQ-1 | Spec for intent, code for state |
| REQ-2 | Spec before code |
| REQ-3 | Documentation Drift Protocol |
| REQ-4 | Spec revision revokes plan approval |
| REQ-5 | Suppression of Reactive Remediation |
| REQ-6 | Verification against spec |
| REQ-7 | Dual-authority principle |
| REQ-8 | Removed sections semantic preservation |
| REQ-9 | No mechanical compaction (word/line count as targets) |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Dual-authority principle stated | string |
| SC-2 | Rule 1: Spec for intent, code for state | semantic |
| SC-3 | Rule 2: Spec before code | semantic |
| SC-4 | Rule 3: Documentation Drift Protocol | semantic |
| SC-5 | Rule 4: Spec revision revokes plan approval | semantic |
| SC-6 | Rule 5: Suppression of Reactive Remediation | semantic |
| SC-7 | Rule 6: Verification against spec | semantic |
| SC-8a | Superseding Issues absent from 130-authority-source.md | semantic |
| SC-8b | Superseding Issues present in spec-creation SKILL.md | semantic |
| SC-9a | Verification First absent from 130-authority-source.md | semantic |
| SC-9b | Verification First present in 065-verification-honesty.md | semantic |
| SC-10a | Plan Audit absent from 130-authority-source.md | semantic |
| SC-10b | Plan Audit present in spec-creation SKILL.md | semantic |
| SC-11a | Superseding Issues semantic preservation | semantic |
| SC-11b | Verification First semantic preservation | semantic |
| SC-11c | Plan Audit semantic preservation | semantic |
| SC-12 | No mechanical compaction metrics used | semantic |

## Files Affected

- `.opencode/guidelines/130-authority-source.md`
- `.opencode/skills/spec-creation/SKILL.md`

## Dependencies

None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
