> **Full spec and artifacts: [`.opencode/.issues/1585/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1585)** — this issue is a condensed exec summary; the authoritative plan lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1585/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Plan: Fix playwright-cli/SKILL.md YAML frontmatter parse error

**Spec:** #1585
**Bug:** #1578

### Phase 1 — fix-frontmatter

Single-phase, single-file change. Quote the `description` field in the YAML frontmatter of `.opencode/skills/playwright-cli/SKILL.md`.

**Success Criteria:**
- SC-1: `description` field is wrapped in double quotes (string evidence)
- SC-2: Content-verification test suite passes for playwright-cli (behavioral evidence)
- SC-3: No other content modified (string evidence)

**Dependencies:** None

**Full plan:** `.opencode/.issues/1585/plan.md` (23 steps covering RED→GREEN→VbC→audit→review-prep)

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
