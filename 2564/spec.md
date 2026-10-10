---
number: 2564
title: "[BUG] tests-v2 GitBucket fixture cannot support issue-state-mutation scenarios (REST state update unsupported)"
state: OPEN
labels: [bug]
---

## Problem Statement

The tests-v2 harness's GitBucket fixture cannot mutate issue state remotely:
GitBucket's GitHub-compatible API does not expose issue state-update
endpoints (state-change REST calls return 404), and `gb`'s web fallback
requires an interactive TTY/account password unavailable in harness runs.
Behavioral scenarios whose success criteria require remote issue-state
mutation are structurally unverifiable.

## Observed Failure

Session 2026-10-09, .opencode#2561 runs SC-1/SC-2: agents attempted `gb
issue close` via REST, PAT auth, and pty variants — all blocked; final
remote state remained OPEN. Agent behavior under test was otherwise correct
(clean-room evaluation: `.opencode/.issues/2561/audit/behavioral-eval.yaml`).

## Success Criteria

### SC-1 — State-mutation scenario verifiable end-to-end (behavioral)

A behavioral harness scenario whose criterion requires closing a remote
issue can complete with the remote state actually mutated, evidenced by a
post-run remote-state check.

Evidence: behavioral — harness run artifacts showing remote issue closed.

### SC-2 — Existing non-state scenarios unaffected (structural)

Scenarios that only need push/API-read (e.g. wiki edits, issue reads)
continue to work unchanged.

Evidence: structural — existing scenarios' scripts untouched by the fix
diff; one existing remote scenario re-run green if the fix touches shared
provisioning.

## Predicate Classification

Fact-decidable at the mechanism level (endpoint availability, exit codes);
the choice among fix options is developer judgment.

## Provenance

- Filed from session 2026-10-09 during the #2561 implementation cycle.
- Related: `.opencode#2561` (BLOCKED SC-1/SC-2), `.opencode#2562` (stacked
  hook-scope fix on the same branch).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
