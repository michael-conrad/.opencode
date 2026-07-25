---
remote_issue: 2131
remote_url: https://github.com/michael-conrad/.opencode/issues/2131
---

> **Full spec and artifacts: [`.opencode/.issues/2131/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2131/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2131/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`080-code-standards.md` contains project-specific rules, testing procedure that belongs in a skill card, and sections duplicated in 000.

## Scope

Generalize 2 project-specific sections. Move Enforcement Test Mandate to test-driven-development skill card. Remove 2 sections duplicated in 000.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Parsing Logic Changes generalized (no project-specific paths) | string |
| SC-2 | Libraries & Packages generalized (no project-specific names) | string |
| SC-3 | Enforcement Test Mandate → test-driven-development skill card | string |
| SC-4 | Behavioral RED/GREEN section removed | string |
| SC-5 | Test Integrity Mandate section removed | string |
| SC-6 | All keep sections remain | string |

## Files Affected

- `.opencode/guidelines/080-code-standards.md`
- `.opencode/skills/test-driven-development/SKILL.md`

## Dependencies

- Depends on 000-critical-rules.md compaction (#2121).

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
