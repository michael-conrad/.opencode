---
number: 1271
title: "[SPEC] Research card catalogue: .issues/research-cards/ for persistent agent research memory"
state: OPEN
---

## Problem

When a sub-agent finishes research, its findings live in the result contract (a few sentences) and are then discarded. The next time a similar question arises, the agent re-dispatches and re-researches from scratch. There is no persistent store of "we already looked into X and found Y."

The discussion-mode mandates in #1270 say: research before answering, dispatch sub-agents, accept the delay. But without a persistent catalogue, every research cycle is cold — no way to check whether a finding already exists before dispatching.

## Design

### Folder

`.issues/research-cards/` in the parent repo (opencode-config root). Not in the `.opencode` submodule. The parent repo is simpler, avoids submodule branch discipline, and the `local-issues` sync already covers the parent's `.issues/`.

The agent owns this folder completely — direct file operations (create, edit, delete, move). No human workflow to learn.

### Card Format

Each card is a `.md` file with YAML frontmatter. The frontmatter is the structured index; the body is the narrative. The agent evolves the frontmatter fields over time by adding new ones — old cards without the new field get a default. No schema migration needed.

```markdown
---
id: rc-20260617-001
question: "What does srclight_get_signature return for ambiguous symbol names?"
created: 2026-06-17T22:30:00Z
updated: 2026-06-17T22:35:00Z
confidence: high
sources:
  - tool: srclight_get_signature
    args: { name: "resolve_models" }
    result: "Returns all matches, not just first"
tags: [srclight, tool-behavior, code-analysis]
status: active
---

## Findings

`srclight_get_signature` returns ALL matches when multiple symbols share a name. ...

## Related Cards

- rc-20260617-002 (srclight fallback behavior)
```

### Reorganization

The agent reorganizes via direct file operations:

| Operation | What the agent does |
|-----------|-------------------|
| Create | Write new `.md` file |
| Update | Edit frontmatter/body, bump `updated` |
| Split | Create 2+ new cards, set old card `status: archived`, add `superseded_by` refs |
| Merge | Create combined card, set originals `status: archived`, add `superseded_by` |
| Archive | Set `status: archived` (keep file, don't delete) |
| Stale detection | Agent checks `updated` vs current date during research cycle |

No index file — the agent globs `*.md` and greps frontmatter at runtime.

### Discovery Protocol

Before dispatching research, the agent checks the catalogue:
1. Glob `.issues/research-cards/*.md`
2. Grep frontmatter `question` and `tags` fields for match
3. If match found with `status: active` and acceptable `confidence`: use existing finding, skip dispatch
4. If no match or stale/archived: dispatch research, create/update card on return

### Registration

Added to `020-go-prohibitions.md` §1.6 Discussion Mode Mandates (the #1270 section) as a new rule:

```
#### ✅ ALWAYS: check research card catalogue before dispatching

Before dispatching a research sub-agent, check `.issues/research-cards/` for existing findings. Glob `*.md` and grep frontmatter `question` and `tags` fields. If an active card with acceptable confidence exists, use it instead of re-researching. Create or update cards when new research completes.
```

## Affected Files

| File | Change |
|------|--------|
| `.opencode/guidelines/020-go-prohibitions.md` | Add research card catalogue rule to §1.6 |
| `.issues/research-cards/` | Create directory (empty, agent populates) |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `020-go-prohibitions.md` §1.6 contains the research card catalogue rule | string |
| SC-2 | Agent checks `.issues/research-cards/` before dispatching research sub-agent | behavioral |
| SC-3 | Agent creates/updates cards in `.issues/research-cards/` when research completes | behavioral |
| SC-4 | Agent reorganizes cards (split, merge, archive) as needs shift | behavioral |
| SC-5 | Agent uses existing card finding instead of re-dispatching when match found | behavioral |

## Labels

- `spec`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)