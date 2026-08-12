---
remote_issue: 2272
remote_url: "https://github.com/michael-conrad/.opencode/issues/2272"
last_sync: 2026-08-12T06:01:28Z
source: github.com
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2272/

## Problem Statement

Regression: when the agent performs an implementation audit (e.g. `audit` skill verification-audit chain) or an implementation-for-PR workflow, it does not update the ticket's status, and it does not even check whether the ticket status needs to be updated.

Observed behavior:
- After completing an implementation audit that returns a PASS verdict, the agent reports the verdict in chat but does not update the ticket status (e.g. does not move the issue from `open`/`approved-for-implementation` to a review/PR-ready state, does not apply/remove status labels).
- During implementation-for-PR, the agent does not check whether the ticket status should transition (e.g. from `approved-for-implementation` to `for_pr`/`pr_created`/`review`), and does not perform the status update.
- The agent does not even inspect the current ticket status to determine whether an update is warranted before reporting completion.

## Root Cause / Motivation

The agent treats implementation audit and implementation-for-PR as terminal reporting steps (chat output + verdict artifact) rather than as pipeline stages that carry a ticket-status transition. The audit skill and git-workflow-pr skill do not mandate a status-check-and-update step, so the agent completes the work without reconciling the ticket's lifecycle state. This leaves tickets stuck in `open`/`approved-for-implementation` even after the implementation is verified and a PR is prepared, breaking the ticket lifecycle and downstream tracking.

## Success Criteria

- SC-1: When an implementation audit completes with a PASS verdict, the agent checks the ticket's current status and updates it to reflect the verified-complete state (e.g. applies a review/PR-ready label or transitions status) if an update is warranted.
- SC-2: When an implementation-for-PR workflow completes, the agent checks the ticket's current status and updates it to reflect the PR-created state if an update is warranted.
- SC-3: The agent performs a status check (reads current ticket status) before reporting completion of an implementation audit or implementation-for-PR, and only skips the update when the status is already correct.
- SC-4: The status-check-and-update behavior is documented in the relevant skill(s) (audit, git-workflow-pr) so the agent is instructed to perform it.

## Affected Files (candidate)

- `.opencode/skills/audit/SKILL.md` and/or its task files
- `.opencode/skills/git-workflow-pr/SKILL.md` and/or its task files
- `.opencode/guidelines/` (if a cross-cutting rule is needed)

## Evidence Type

Behavioral (agent must be observed checking and updating ticket status during audit/PR workflows).

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
