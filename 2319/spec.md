---
title: '[SPEC] Qualify issue references as `owner/repo#NNN` across the agent deck'
remote_issue: 2319
remote_url: https://github.com/michael-conrad/.opencode/issues/2319
promoted_at: '2026-08-24T21:54:00+00:00'
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2319/

## Problem Statement

The agent passes issue numbers around to sub-agents in **unqualified, bare form** (`#N`, `issue_number`, `spec_issue_number`). Sub-agents then resolve repo identity themselves and read / attempt to implement specs from the **wrong repository**. This is a real, observed failure mode: an issue number carries repo identity implicitly, and when that identity is not bound to the token, the consumer guesses — and guesses wrong.

Root cause: issue identity is split across three separate fields (`issue_number`, `github.owner`, `github.repo`) that can be dropped, reordered, or resolved differently by each consuming sub-agent.

## Success Criteria

- SC-1: A composite issue reference form `{owner}/{repo}#NNN` is defined as the single self-describing issue identity token used internally across the deck.
- SC-2: All skill-card "context passed" contracts that today pass `{ issue_number, github.owner, github.repo }` as three separate fields are replaced with a single composite field (`issue_ref: "{owner}/{repo}#NNN"`).
- SC-3: Direct platform API calls in task files that carry a bare issue number (e.g., `github_issue_read(issue_number=N)` or prose `#N`) are removed from non-MCP task cards; such calls belong only in the MCP / issue-operations platform task-card sets, and consume the qualified composite.
- SC-4: A guideline rule is added defining the composite parse convention: sub-agents derive `owner`, `repo`, and `issue_number` from `{owner}/{repo}#NNN`. Permitted: local derived variables (`spec_issue_number`) used for artifact path construction. Forbidden: any concrete bare issue number referencing a real issue without repo qualification.
- SC-5: The `skildeck` semantic lint gains a rule that flags concrete bare issue references (`#N`, `github_issue_read(issue_number=N)`, unconsumed issue tokens) in skill cards and task cards, while permitting the derived-variable carve-out.
- SC-6: The task files across audit, issue-operations, spec-creation, and writing-plans that currently consume bare issue numbers are updated to consume the composite.

## Affected Files

- `.opencode/skills/audit/tasks/*.md`
- `.opencode/skills/issue-operations*/**/SKILL.md` and `tasks/*.md`
- `.opencode/skills/spec-creation/**/tasks/*.md`
- `.opencode/skills/writing-plans/**/tasks/*.md`
- `.opencode/guidelines/*.md`
- `.opencode/tools/skildeck`

## Success Criteria Evidence Types

Behavioral where the change affects how agents route issue operations; structural for the lint rule and contract-shape changes.

## Platform / Routing Note

`owner/repo#NNN` does NOT carry a platform. Platform is resolved by the platform-aware issue-operations dispatcher from the repo. Do not add platform to the token.

---

🤖 OpenCode (deepseek-v4-flash) created
