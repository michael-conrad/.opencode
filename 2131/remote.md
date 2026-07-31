---
remote_issue: 2131
remote_url: https://github.com/michael-conrad/.opencode/issues/2131
---

> **Full spec and artifacts: [`.opencode/.issues/2131/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2131/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2131/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Reorganize `080-code-standards.md` by moving testing procedure to the `test-driven-development` skill card, removing sections duplicated in `000-critical-rules.md`, and generalizing project-specific references — without losing any semantic constraints.

## Problem

`080-code-standards.md` conflates multiple concerns: project-specific rules (parsing pipeline, ConfigurationManager), testing procedure that belongs in a skill card, and sections duplicated in 000 (Behavioral RED/GREEN). The sprawl is a symptom of missing concern boundaries, not a size problem.

## Scope

- **Generalize**: Parsing Logic Changes, Libraries & Packages (remove project-specific references)
- **Move**: Enforcement Test Mandate → test-driven-development skill card
- **Remove**: Behavioral RED/GREEN section (normative content preserved in 000)
- **Keep**: Test Integrity Mandate stays in 080 (only summary exists in 000)
- **Keep**: All universal sections (Scope, Typing, Design Principles, Modern Python, etc.)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Parsing Logic Changes generalized | string + semantic |
| SC-2 | Libraries & Packages generalized | string + semantic |
| SC-3 | Enforcement Test Mandate → test-driven-development skill card | string + semantic |
| SC-4 | Behavioral RED/GREEN section removed | string + semantic |
| SC-5 | Test Integrity Mandate remains in 080 | string + semantic |
| SC-6 | All keep sections remain intact | string + semantic |
| SC-7 | No constraint loss in generalized Parsing Logic Changes | semantic |
| SC-8 | No constraint loss in moved Enforcement Test Mandate | semantic |
| SC-9 | No constraint loss in removed Behavioral RED/GREEN | semantic |

## Files Affected

- `.opencode/guidelines/080-code-standards.md`
- `.opencode/skills/test-driven-development/SKILL.md`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
