---
number: 2562
title: "[BUG] pre-commit store-path gate over-scoped: blocks tests-v2 scenario scripts referencing injected fixture stores"
state: OPEN
labels: [bug]
---

## Problem Statement

The pre-commit store-path reference gate in `.opencode/hooks/pre-commit` was
intended to keep deck-facing content (skill cards, guidelines, agent-read
deck files) from pointing into the real `issues-data` store, which renumbers
issues without updating dependents. As implemented, it scans every tracked
file outside `.issues/` and `tests-v2/behaviors/fixtures/` — so `tests-v2/
behaviors/*.sh` scenario scripts, whose prompts legitimately reference the
harness-*injected* fixture store (a fabricated copy in an ephemeral test
repo, not the real store), are blocked.

## Observed Failure (session 2026-10-09)

Committing the #2561 behavioral scenario scripts was blocked:
`BLOCKED: staged file 'tests-v2/behaviors/2561-sc1-verified-moot-closes-remote.sh'
references an issue-store path`. The reference was to the injected fixture
store — the same content class the hook's own `fixtures/` exclusion already
treats as legitimate. Developer confirmed the gate was only supposed to
apply to the skill cards in `.opencode`.

## Success Criteria

### SC-1 — Deck-facing scope only (behavioral)

Given a commit that adds or modifies a deck-facing file (skill card,
guideline, or other agent-read deck file) containing a literal
`.issues/<digits>` reference, when the pre-commit hook runs, then the commit
is blocked.

Evidence: behavioral — hook execution on a staged deck-file fixture;
observed output shows BLOCKED.

### SC-2 — Test-harness content exempt (behavioral)

Given a commit that adds or modifies a `tests-v2/behaviors/*.sh` scenario
script referencing `.issues/<digits>` (fixture-store references), when the
pre-commit hook runs, then the commit is allowed.

Evidence: behavioral — hook execution on a staged scenario-script fixture;
observed output shows the commit allowed (exit 0, no BLOCKED line).

### SC-3 — Real-store worktree references still exempt (structural)

References inside the `.issues/` worktree itself remain excluded from the
gate (existing behavior preserved).

Evidence: structural — inspection of the hook's exclusion cases in the diff.

## Predicate Classification

The gate stays **fact-decidable** (textual pattern match on staged file
paths and content) — this fix narrows scope, it does not introduce an
intent-decidable predicate.

## Fix Direction

Narrow the scan scope to deck-facing content, or extend the existing
exclusion to `tests-v2/behaviors/` scenario scripts. The intent boundary:
deck instructions must not point into the renumbering store; test-fixture
references to injected stores are not deck instructions.

## Provenance

- Filed from session 2026-10-09 during the #2561 implementation cycle.
- Related: `.opencode#2506` (original store-path gate rationale).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
