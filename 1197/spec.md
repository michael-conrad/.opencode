---
number: 1197
title: "[SPEC] remove STATUS markers and all STATUS verification tasks — plans/specs are static artifacts, not tracking documents"
state: OPEN
---

## Summary

Per the core principle established in #1191, plans and specs are static definitional artifacts — not tracking documents. STATUS markers (BRAINSTORM / DRAFT / DETAILED / COMPLETE with version numbers) are state-tracking metadata on documents that should not track state. The marker exists between open and closed, which is state that belongs in chat output, not in the artifact body.

Additionally, multiple tasks across `approval-gate`, `brainstorming`, and `writing-plans` consume API calls and sub-agent context to read STATUS lines from issue bodies and verify them against content maturity — producing findings that feed no enforcement gate and drive no behavioral outcome.

## Root Cause

The STATUS marker and its verification tasks were built under the assumption that documents track maturity state. This contradicts the static-definitional-artifact model. STATUS verification produces audit findings with no downstream consumer — it is pure overhead.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/guidelines/141-planning-status-tracking.md` | Remove entire file (STATUS marker definitions, version schemes, revision tracking) |
| `.opencode/guidelines/INDEX.md` | Remove `141-planning-status-tracking.md` entry |
| `.opencode/skills/approval-gate/tasks/*/` | Remove any step that reads or verifies STATUS markers |
| `.opencode/skills/brainstorming/tasks/*/` | Remove any step that writes, reads, or verifies STATUS markers |
| `.opencode/skills/writing-plans/tasks/*/` | Remove any step that reads or verifies STATUS markers |
| `.opencode/skills/spec-creation/tasks/*/` | Remove STATUS marker from issue body template |

Search scope: any task file referencing `STATUS:` or `status marker` or `maturity verification` or `BRAINSTORM`/`DRAFT`/`DETAILED`/`COMPLETE` in a STATUS context.

## Spec

### Phase 1: Remove STATUS Marker from Spec Issue Body Template

In the spec-creation skill, remove the `STATUS:` line from the issue body template. The template should not include any maturity state field.

### Phase 2: Remove 141-planning-status-tracking.md

Delete the entire guideline file. Remove its entry from `INDEX.md`. This file exists solely to define STATUS marker conventions — with no STATUS markers, it has no purpose.

### Phase 3: Remove STATUS Verification from All Tasks

Search all task files under `.opencode/skills/` for:
- `STATUS:` references (parsing a STATUS line from an issue body)
- `status marker` references
- `maturity verification` or content-vs-STATUS comparison steps
- `BRAINSTORM`, `DRAFT`, `DETAILED`, `COMPLETE` in the context of STATUS verification

Remove every step that reads, parses, verifies, or flags STATUS markers. These steps:
- Consume GitHub API calls to read issue bodies
- Consume sub-agent context for analysis
- Produce findings with no downstream enforcement
- Contradict the static-artifact principle

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `141-planning-status-tracking.md` deleted | `structural` |
| SC-2 | `INDEX.md` no longer references `141-planning-status-tracking` | `string` |
| SC-3 | Spec issue body template has no `STATUS:` line | `string` |
| SC-4 | No task file under `skills/` references STATUS markers in a read/verify/write context | `string` |
| SC-5 | Behavioral: plan/spec creation does not produce a STATUS marker in the issue body | `behavioral` |

## Non-Goals

- Not changing the issue open/closed state model — open means not implemented, closed means done
- Not changing any other guideline file content (STATUS removal only)
- Not removing the `141-*` numbering convention — other files in the `141-*` series remain unaffected

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/remove-status-markers`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)