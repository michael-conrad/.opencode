**Full spec and artifacts: [`.opencode/.issues/1407/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1407)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1407/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

New skills are created with procedure text (step definitions, entry/exit criteria, code snippets) in the SKILL.md file, violating the routing-only discipline. The SKILL.md should contain only: YAML frontmatter, Overview, Mandatory Task Discipline, Trigger Dispatch Table, Invocation, Sub-Agent Routing, Cross-References, and Symbolic rules. No procedure text, no "Structuring This Skill", no "Measurement Standard", no "Context Window Hygiene" sections.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| routing-only template creation | proposed | — |
| init_skill.py update | proposed | — |
| skill-card-spec.md reference | proposed | — |

### Key Decisions

- DEC-1: Template contains NO procedure text — only routing metadata and structural rules

### Risk Callouts

- RISK-1: Low — new template doesn't change existing skill behavior

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)