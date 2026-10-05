# [SPEC-FIX] Stacked-PR definition: one PR, one squashed commit per issue ticket

**Repo**: michael-conrad/.opencode · **Scope**: `skills/git-workflow-pr/SKILL.md` card text · **Remote**: https://github.com/michael-conrad/.opencode/issues/2509

## Problem Statement

Session 2026-10-05 regression: implementing `.opencode#2505` stacked under `.opencode#2504`, the agent produced **two PRs** (#2507 base main + #2508 based on #2507's branch), justified by the `git-workflow-pr` card's "One PR per issue" rule and its ambiguous "stacked work keeps its stack honest" line. The developer ruled the stacked-PR ceremony forbidden and defined the correct shape: **a stacked PR is one PR containing one squashed commit per issue ticket** — base trunk, body closing every stacked issue. The card's current text permits the multi-PR reading; that ambiguity is the defect.

## Success Criteria

- **SC-1 — Definition present (structural).** `skills/git-workflow-pr/SKILL.md` states the stacked-PR definition: one PR against the trunk containing one squashed commit per issue ticket, with the body closing each stacked issue. Instrument: grep finds the definition in the card.
- **SC-2 — Ambiguity removed (structural).** The card can no longer be read as "one PR per stacked layer": the shape rule covers both single-issue work and stacked chains without implying multiple PRs. Instrument: read the card's Shape section; no text implies one-PR-per-layer; the "keeps its stack honest" phrase is either gone or tied to the one-PR definition.
- **SC-3 — Scope discipline (structural).** The edit touches only the `git-workflow-pr` card; no other deck file changes; root-agnostic (no repo names or absolute paths); provenance line updated to cite this issue. Instrument: diff of this branch's commit.

## Requirements

1. **REQ-1**: Rewrite the card's Shape rule to carry the developer's definition (one PR; one squashed commit per issue; stacked chains ride in that one PR).
2. **REQ-2**: Keep the card lean — no new sections, no dispatch boilerplate, no numeric size targets.

## Non-Goals

- No change to the squash-at-PR-creation mechanics beyond the stacked-work wording.
- No change to branch naming or stack ordering rules (the branch chain remains the stack mechanism).

## Admission gate (deck governance)

- **Observed failure**: session 2026-10-05, PRs #2507/#2508 + developer correction (#2509).
- **Consumer**: any agent preparing work for review via `git-workflow-pr`.
- **Mechanism**: card text loaded at the PR boundary (routed from `routing.md`).
- **Predicate classification**: intent-decidable (shape judgment at PR creation) — no scripted enforcement proposed.
- **Root-agnostic**: yes.
- **What it replaces**: replaces the ambiguous "One PR per issue / stacked work keeps its stack honest" phrasing; net wording change, no new artifact.

## Traceability

| Requirement | SCs | Source |
|---|---|---|
| REQ-1 | SC-1, SC-2 | Developer: "one squashed commit per issue ticket in a single PR is a stacked PR" (#2509) |
| REQ-2 | SC-3 | Deck card standards |

> **Full spec and artifacts**: `.opencode/.issues/2509/` — this file is the authoritative spec.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
