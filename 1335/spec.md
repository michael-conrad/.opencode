&gt; **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | The agent created 3 bug issues, fixed the bugs, and closed the issues in a single session — treating GitHub Issues as disposable task items rather than permanent project artifacts. Issues were closed before any PR was created or merged, severing the audit trail between the bug report and its resolution. |
| **Root Cause / Motivation** | The existing cleanup workflow (`git-workflow --task cleanup`) is already the sole authorized closure path, and the codebase has extensive infrastructure for legitimate closure (body-preservation safeguards, parent/child ordering, premature-closure detection gates, closed-issue verification). However, there is no **bright-line rule** that explicitly prohibits the agent from calling `github_issue_write(method=update, state=closed)` outside the cleanup workflow. The agent needs a hard prohibition: the cleanup workflow is the ONLY authorized path for issue closure. |
| **Approach Chosen** | Add a Tier 2 critical rule: the agent MUST NOT call `github_issue_write(method=update, state=closed)` or equivalent on any issue outside the `git-workflow --task cleanup` workflow. Add a Tier 2 rule that issues created by the agent in a session MUST survive at least one session boundary before closure. The cleanup workflow remains the sole authorized closure path — no changes to the cleanup workflow itself. |
| **Key Design Decisions** | Two-rule approach: (1) blanket prohibition on direct issue closure via API outside cleanup, (2) session-survival rule for self-created issues. The cleanup workflow is already correct and comprehensive — the fix is adding the missing prohibition, not redesigning the closure architecture. |

## Audit Findings

A comprehensive audit of the entire codebase (skills, guidelines, tests) found that **all existing closure patterns are legitimate**. Every reference to `state=closed`, `github_issue_write` with state closed, and cleanup workflow falls into one of these categories:

1. **Post-merge cleanup** (`git-workflow --task cleanup`) — the primary authorized closure mechanism
2. **Closed-issue verification** (`verify-closed-issue`, `closure-verification`) — verifying that a closed issue was legitimately closed
3. **Premature closure detection** (screen gates, reconcile-status) — detecting and preventing unauthorized closures
4. **Platform capability declarations** (github-mcp, gitbucket-api, local) — documenting how to close issues
5. **Body-preservation safeguards** — preventing body erasure during close operations
6. **Behavioral/content-verification tests** — testing that closure rules are enforced
7. **URL extraction from API responses** — never constructing URLs from templates

**The existing architecture is correct.** The cleanup workflow is already the sole authorized closure path. What's missing is the explicit prohibition that prevents the agent from bypassing it.

## Scope

### In Scope
- Add a critical rule: agent MUST NOT close any GitHub Issue through direct API calls outside `git-workflow --task cleanup`
- Add a critical rule: issues created by the agent in a session MUST survive at least one session boundary before closure
- The sole authorized closure path is `git-workflow --task cleanup` after PR merge detection
- Behavioral enforcement test verifying the agent declines to close an issue when asked directly
- Behavioral enforcement test verifying the agent routes closure requests through cleanup workflow

### Out of Scope
- Changes to the cleanup workflow itself (it is already correct)
- Human-initiated issue closure
- Local `.issues/` issue tracking
- Changes to closed-issue verification, premature-closure detection, or any other existing closure infrastructure

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Agent MUST NOT close any GitHub Issue through direct API calls outside `git-workflow --task cleanup` | behavioral |
| SC-2 | Issues created by the agent in a session MUST survive at least one session boundary before closure | behavioral |
| SC-3 | Critical rule added to `000-critical-rules.md` as Tier 2 | string |
| SC-4 | Behavioral enforcement test: agent declines to close an issue when asked directly (routes to cleanup instead) | behavioral |
| SC-5 | Behavioral enforcement test: agent routes "close this issue" requests through cleanup workflow | behavioral |

## Dependencies
- **Depends on:** None — single-file change to `.opencode/guidelines/000-critical-rules.md`
- **Depended by:** None

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*