# Eliminate GitHub Issue Comment Spam from Pipeline Skills

**Scope:** ~10 skill task files across `completion-core`, `implementation-pipeline`, `finishing-a-development-branch`, `git-workflow`, `approval-gate`, and `verification-before-completion` that hardcode issue-comment posting as a pipeline step.

## Problem

96 references to issue comments across the skill deck. The majority are read-only (reading comments for context/authorization — legitimate). But ~15 files hardcode posting comments to GitHub issues as a standard pipeline step: phase-complete signals, exec summaries, verification results, blocker reports, authorization confirmations, closure comments.

Each post is a network round-trip, a notification to all watchers, and permanent noise in the issue's comment thread. The issue tracker is not a job queue or a build log.

## Principles

1. **GitHub issue comments are for stakeholder communication only.** Platform (platform engineering), spec revision, scope change, question/answer — substantive content that a human stakeholder needs to see. Nothing else.

2. **Remote issue labels are advisory for stakeholders only.** The `approved-for-*` label on a GitHub issue is a human-readable signal — not a state tracking mechanism. Actual authorization state lives in local `.issues/{N}/` files (issue.yaml metadata, lifecycle manifests, state files). No "authorization confirmed" comment, no "approved by" post, no state encoded exclusively on the remote ticket.

3. **GitHub issue comments are never a valid authorization source — they can be spoofed.** Any bot, agent, or collaborator with API access can post "approved" or "go" in a comment. Comments carry no cryptographic provenance. Authorization comes from exactly two sources:
   - The user's explicit command in the current chat session
   - Local state files (`.issues/{N}/issue.yaml` with authorization scope markers)
   
   Advisory `approved-for-*` labels on the remote issue exist for stakeholder awareness only. They are never a valid authorization source and must not be used as one. If a label and local state disagree, local state wins.
   
   The `approval-gate` skill MUST NOT read GitHub issue comments as authorization evidence. All `github_issue_read(method=get_comments)` calls used to detect "approved" patterns must be removed or replaced with local state file reads.

3. **Local state files are the single source of truth for pipeline state.** Lifecycle manifests at `./tmp/{N}/lifecycle.yaml`, issue metadata at `.issues/{N}/issue.yaml`, state files at `.issues/{N}/state/`. These are what agents read to determine pipeline position. Remote labels are never polled for state.

4. **Status, progress, phase-complete, verification results go to lifecycle manifest + chat.** `./tmp/{N}/lifecycle.yaml` for machine-readable audit trail. Chat output for the developer's current session. GitHub issue comments are not a build pipeline dashboard.

## Affected Files

| Priority | File | What It Posts |
|----------|------|---------------|
| P0 | `completion-core/tasks/completion.md` | Entire task built around posting completion comments via substantive gate |
| P0 | `completion-core/SKILL.md` | "post comment" as trigger keyword; "post status comment" as output |
| P0 | `implementation-pipeline/SKILL.md` | `exec-summary` step: "push status + issue comment" |
| P0 | `implementation-pipeline/tasks/pipeline-executor.md` | Step 14 hardcoded to "push status + issue comment" |
| P1 | `finishing-a-development-branch/tasks/completion.md` | Routes status through substantive gate to issue |
| P1 | `git-workflow/tasks/completion.md` | Routes status through substantive gate to issue |
| P1 | `git-workflow/tasks/cleanup/issue-closure.md` | Posts closure/verification comments |
| P1 | `approval-gate/tasks/completion.md` | Posts authorization result comments |
| P1 | `approval-gate/tasks/reconcile-issue-graph.md` | Posts evidence/reopening comments |
| P1 | `approval-gate/tasks/verify-already-implemented.md` | Routes verification results through comment gate |

## Non-Goals

- No changes to read-only comment operations (`github_issue_read(method=get_comments)`) — reading comments for context and audit is legitimate and unchanged. Reading comments for authorization evidence is removed per Phase 4.
- No changes to `issue-operations/tasks/comment.md` — the substantive comment gate remains for legitimate stakeholder posting.
- No changes to blocker reporting via comments *if* the blocker genuinely requires stakeholder attention (e.g., infrastructure failure, authorization gap). The gate decides; the default is NO.

## Phase 1 — Core Pipeline Steps (P0)

### SC-1: `completion-core` no longer posts comments as a pipeline output

`completion-core/tasks/completion.md` replaces issue-comment posting with lifecycle manifest events and chat-only output. The "post comment" step is removed; the outcome is an appended `lifecycle.yaml` event and a chat report with byline. The substantive gate is removed — completion signals are never stakeholder-worthy.

Evidence type: `behavioral` — sub-agent dispatched for completion produces lifecycle event + chat output, not `github_add_issue_comment`.

### SC-2: `completion-core` SKILL.md trigger keywords updated

"post comment" removed from trigger dispatch table. "post status comment" removed from step output descriptions.

Evidence type: `string` — grep confirms trigger keywords removed.

### SC-3: `implementation-pipeline` exec-summary step outputs to lifecycle manifest, not issue comment

`implementation-pipeline/SKILL.md` Dispatch Routing Table `exec-summary` row updates from "push status + issue comment" to "append lifecycle event + chat exec summary". Same change in `pipeline-executor.md` step 14.

Evidence type: `string` — grep for "issue comment" in both files returns zero.

## Phase 2 — Pipeline Gate Skills (P1)

### SC-4: `finishing-a-development-branch` completion uses lifecycle events, not issue comments

`finishing-a-development-branch/tasks/completion.md` replaces "route status comment through substantive gate" with "append completion event to lifecycle manifest + report in chat". The substantive gate call is removed.

Evidence type: `behavioral` — completion produces lifecycle event append, not `github_add_issue_comment`.

### SC-5: `git-workflow` completion uses lifecycle events, not issue comments

`git-workflow/tasks/completion.md` same replacement.

Evidence type: `behavioral`.

### SC-6: `git-workflow` issue-closure uses lifecycle events, not verification/closure comments

`git-workflow/tasks/cleanup/issue-closure.md` replaces "post evidence and closure comments via issue-operations" with "append closure event to lifecycle manifest + close issue via label update". The issue is closed; the label signals completion. No closure comment.

Evidence type: `behavioral` — issue-closure sub-agent produces lifecycle event + label update, not `github_add_issue_comment`.

## Phase 3 — Approval Gate (P1)

### SC-7: `approval-gate` completion applies advisory label only — no authorization comments

`approval-gate/tasks/completion.md` replaces "post authorization result comment" with "apply `approved-for-*` label via `github_issue_write(method=update, labels=[...])` and record authorization in local state file `.issues/{N}/issue.yaml`". The label is stakeholder advisory only — **not an authorization signal**. The local state file is the single source of truth for authorization state. No "Approved by" comment. No verification-result comment. No "authorization confirmed" post. Zero `github_add_issue_comment` calls for authorization-related output.

This is a hard rule: approvals are advisory labels + local state. Any task that currently posts an authorization-related comment to a GitHub issue must be rewritten to produce a lifecycle event + local state update + chat output instead.

Evidence type: `behavioral` — completion applies label and writes local state, does not post any comment.

### SC-8: `approval-gate` reconcile-issue-graph uses labels, not evidence comments

`approval-gate/tasks/reconcile-issue-graph.md` replaces any `github_add_issue_comment` calls for evidence/reopening with lifecycle events. Reopening an issue uses `github_issue_write(method=update, state=open)` — no comment.

Evidence type: `behavioral` — reconcile-issue-graph produces lifecycle event + issue state update, not comment.

### SC-9: `approval-gate` verify-already-implemented uses lifecycle events

`approval-gate/tasks/verify-already-implemented.md` replaces "route verification results through issue-operations comment gate" with lifecycle event + chat output. The closure label on the issue is the signal.

Evidence type: `behavioral`.

## Phase 4 — Authorization Sources (No Comment Reading)

### SC-10: `approval-gate` completion no longer reads comments for authorization evidence

`approval-gate/tasks/completion.md` removes all `github_issue_read(method=get_comments)` calls that search for authorization patterns ("approved", "go", byline pattern). Authorization is determined from:
- Current session authorization scope (if in active session)
- Local `.issues/{N}/issue.yaml` authorization scope markers
- **Never** from advisory labels or issue comments

The "Existing comments: Check if authorization result comment already posted" step and the authorization-result substantive gate check are removed entirely.

Evidence type: `behavioral` — completion sub-agent reads local state files, not comments or labels.

### SC-11: `approval-gate` verify-qa-mode no longer reads comments for authorization

`approval-gate/tasks/verify-qa-mode.md` Gate 2 ("Is authorization documented (explicit 'approved'/'go' comment)?") is replaced with a check against local state files only. All `github_issue_read(method=get_comments)` calls searching for approval patterns are removed. The "author_association" filter for bot/agent detection is removed — comments are never a valid authorization source regardless of who posted them.

Evidence type: `behavioral` — verify-qa-mode sub-agent checks local state files, not comments or labels.

## SC-ID Summary

| ID | Phase | Evidence Type | Verification Method |
|----|-------|---------------|---------------------|
| SC-1 | 1 | `behavioral` | completion-core sub-agent produces lifecycle event + chat, not `github_add_issue_comment` |
| SC-2 | 1 | `string` | grep for "post comment" in SKILL.md triggers returns zero |
| SC-3 | 1 | `string` | grep for "issue comment" in implementation-pipeline files returns zero |
| SC-4 | 2 | `behavioral` | finishing-a-development-branch completion produces lifecycle event append |
| SC-5 | 2 | `behavioral` | git-workflow completion produces lifecycle event append |
| SC-6 | 2 | `behavioral` | issue-closure produces lifecycle event + label update, not comment |
| SC-7 | 3 | `behavioral` | approval-gate completion applies label only, no comment |
| SC-8 | 3 | `behavioral` | reconcile-issue-graph produces lifecycle event + state update, not comment |
| SC-9 | 3 | `behavioral` | verify-already-implemented produces lifecycle event + chat, not comment |
| SC-10 | 4 | `behavioral` | approval-gate completion reads local state + labels, not comments for auth |
| SC-11 | 4 | `behavioral` | verify-qa-mode checks local state + labels, not comments for auth |

## Non-Goals

- No changes to reading comments (context completeness, authorization verification)
- No changes to the substantive comment gate itself — it remains for legitimate stakeholder communication
- No changes to blocker-reporting that genuinely needs stakeholder attention (gate decides, default is no)
- No changes to `issue-operations` skill itself — it's the plumbing, not the offender
- No changes to approvals via labels (labels remain; the change is removing the *comment* that announces the label)