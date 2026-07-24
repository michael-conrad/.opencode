---
number: 1199
title: "[SPEC] extract DISPATCH_GATE protocol to single reference, mandate as G1 in every task dispatch table"
state: OPEN
---

## Summary

The DISPATCH_GATE protocol is duplicated identically across ~35 SKILL.md files. ~1,750 lines of boilerplate. Every update must touch 35 files. Extract to one flat reference file — the file IS the section, no subsections inside it. Mandate reading it as G1 in every task dispatch table.

## Core Principle: File IS the section

Cross-referenced material is a flat card with no subsections. The agent reads the whole file or not at all. No parsing out sections.

## Root Cause

The DISPATCH_GATE protocol was embedded in every SKILL.md to ensure visibility — achieving visibility at 35× replication cost.

## Affected Components

| Component | Change |
|-----------|--------|
| `.opencode/.guidelines/dispatch-gate-protocol.md` | New flat card (no subsections, no internal headings) |
| `.opencode/skills/*/SKILL.md` (~35 files) | Replace embedded DISPATCH_GATE section with reference to card |
| `.opencode/skills/*/tasks/*.md` | Mandate G1 (DISPATCH-GATE-LOAD) as first gate |
| `.opencode/skills/verification-before-completion/` | Add SC-DG verification |
| `.opencode/.guidelines/INDEX.md` | Add entry |
| `.opencode/.guidelines/registry.yaml` | Remove DISPATCH_GATE fragment entry |

## Spec

### Phase 1: Create Flat Reference Card

Create `.opencode/.guidelines/dispatch-gate-protocol.md` containing:

```
DISPATCH_GATE Protocol — Single Source of Truth

All task() prompts MUST be objectives, not tool recipes. The orchestrator passes what to achieve, not how to achieve it. Preloading file paths, step definitions, expected outcome structures, or orchestrator reasoning into task() prompts is a context contamination violation.

A sub-agent receiving a task() prompt MUST return status: BLOCKED with reason: PRELOADED_CONTEXT_REJECTED if the prompt contains: inline file paths to task files or source files; inline step or procedure definitions; expected outcome structures or schema constraints; pre-loaded evidence or orchestrator-derived conclusions.

Every task() call MUST include ONLY: worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase. Plus skill-specific fields per each SKILL.md's Sub-Agent Routing section.
```

No headings, no subsections, no sections. The file IS the protocol.

Include SPDX and provenance headers per `080-code-standards.md`.

### Phase 2: Replace Embedded Sections with Reference

In every SKILL.md, replace the full DISPATCH_GATE block with:

```markdown
### DISPATCH_GATE

See `.opencode/.guidelines/dispatch-gate-protocol.md` — mandatory reading as G1 in every task dispatch table.
```

### Phase 3: Add G1 to Every Task Dispatch Table

Every task dispatch table MUST include G1 as the first gate:

```
| G1: DISPATCH-GATE-LOAD | inline | N/A | N/A | — | SC-DG |
```

For tasks without dispatch tables yet: first procedure bullet is `DISPATCH-GATE-LOAD: Read .opencode/.guidelines/dispatch-gate-protocol.md before constructing any task() prompts in this procedure.`

### Phase 4: Add SC-DG to VbC

In verification-before-completion, add SC-DG: dispatch table rows G2+ must not contain preloaded context violations.

### Phase 5: Remove from Fragment Registry

Remove DISPATCH_GATE from `.opencode/.guidelines/registry.yaml`.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | dispatch-gate-protocol.md exists as flat card (no internal headings) | `string` |
| SC-2 | All ~35 SKILL.md files reference the card instead of embedding | `string` |
| SC-3 | Every task dispatch table includes G1 as first gate | `string` |
| SC-4 | VbC includes SC-DG checking for preloaded context violations | `string` |
| SC-5 | Fragment registry no longer lists DISPATCH_GATE | `string` |
| SC-6 | Behavioral: agent reads the card before constructing task() prompts | `behavioral` |
| SC-7 | Behavioral: sub-agent returns PRELOADED_CONTEXT_REJECTED on preloaded prompt | `behavioral` |
| SC-8 | SKILL.md files reduced by ~1,500 lines total | `structural` |

## Non-Goals

- Not changing the PRELOADED_CONTEXT_REJECTED protocol
- Not changing `sync-guidelines` skill
- Not removing sub-agent routing sections from SKILL.md — only the DISPATCH_GATE section

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/extract-dispatch-gate-protocol`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)