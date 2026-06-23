# [PLAN] Eliminate GitHub Issue Comment Spam from Pipeline Skills

**Issue:** #1312
**Scope:** `for_pr` (auto-approved via cascade)
**Strategy:** Sequential per-phase, one sub-agent per file

## Phase 1 — Core Pipeline Steps (P0)

### Item 1.1: `completion-core/tasks/completion.md`

**Change:** Replace issue-comment posting with lifecycle manifest events + chat-only output. Remove the "post comment" step and substantive gate.

**RED:** Write behavioral test verifying completion produces lifecycle event + chat, not `github_add_issue_comment`.
**GREEN:** Remove `github_add_issue_comment` calls, replace with lifecycle event append + chat report.
**Verification:** `grep` for `github_add_issue_comment` in file returns zero.

### Item 1.2: `completion-core/SKILL.md`

**Change:** Remove "post comment" from trigger dispatch table. Remove "post status comment" from step output descriptions.

**RED:** Write string test verifying "post comment" absent from triggers.
**GREEN:** Edit SKILL.md trigger table and step output descriptions.
**Verification:** `grep` for "post comment" in file returns zero.

### Item 1.3: `implementation-pipeline/SKILL.md` + `pipeline-executor.md`

**Change:** Update exec-summary step from "push status + issue comment" to "append lifecycle event + chat exec summary".

**RED:** Write string test verifying "issue comment" absent from exec-summary step.
**GREEN:** Edit both files.
**Verification:** `grep` for "issue comment" in both files returns zero.

## Phase 2 — Pipeline Gate Skills (P1)

### Item 2.1: `finishing-a-development-branch/tasks/completion.md`

**Change:** Replace "route status comment through substantive gate" with "append completion event to lifecycle manifest + report in chat".

**RED:** Behavioral test — completion produces lifecycle event append, not `github_add_issue_comment`.
**GREEN:** Edit file, remove substantive gate call.
**Verification:** `grep` for `github_add_issue_comment` in file returns zero.

### Item 2.2: `git-workflow/tasks/completion.md`

**Change:** Same replacement as Item 2.1.

**RED:** Same behavioral test pattern.
**GREEN:** Edit file.
**Verification:** `grep` for `github_add_issue_comment` in file returns zero.

### Item 2.3: `git-workflow/tasks/cleanup/issue-closure.md`

**Change:** Replace "post evidence and closure comments via issue-operations" with "append closure event to lifecycle manifest + close issue via label update". No closure comment.

**RED:** Behavioral test — issue-closure produces lifecycle event + label update, not `github_add_issue_comment`.
**GREEN:** Edit file.
**Verification:** `grep` for `github_add_issue_comment` in file returns zero.

## Phase 3 — Approval Gate (P1)

### Item 3.1: `approval-gate/tasks/completion.md`

**Change:** Replace "post authorization result comment" with "apply `approved-for-*` label + record in local state file". Zero `github_add_issue_comment` calls for authorization output.

**RED:** Behavioral test — completion applies label and writes local state, does not post comment.
**GREEN:** Edit file.
**Verification:** `grep` for `github_add_issue_comment` in file returns zero for authorization paths.

### Item 3.2: `approval-gate/tasks/reconcile-issue-graph.md`

**Change:** Replace `github_add_issue_comment` calls for evidence/reopening with lifecycle events. Reopen via `github_issue_write(method=update, state=open)` — no comment.

**RED:** Behavioral test — reconcile produces lifecycle event + issue state update, not comment.
**GREEN:** Edit file.
**Verification:** `grep` for `github_add_issue_comment` in file returns zero.

### Item 3.3: `approval-gate/tasks/verify-already-implemented.md`

**Change:** Replace "route verification results through issue-operations comment gate" with lifecycle event + chat output.

**RED:** Behavioral test — verify-already-implemented produces lifecycle event + chat, not comment.
**GREEN:** Edit file.
**Verification:** `grep` for `github_add_issue_comment` in file returns zero.

## Phase 4 — Authorization Sources

### Item 4.1: `approval-gate/tasks/completion.md` (auth reading removal)

**Change:** Remove all `github_issue_read(method=get_comments)` calls that search for authorization patterns. Authorization from session scope + local state files only.

**RED:** Behavioral test — completion reads local state files, not comments for auth.
**GREEN:** Edit file, remove comment-reading steps.
**Verification:** `grep` for `get_comments` in file returns zero for authorization paths.

### Item 4.2: `approval-gate/tasks/verify-qa-mode.md`

**Change:** Gate 2 ("Is authorization documented in comment?") replaced with local state file check. Remove all `github_issue_read(method=get_comments)` for approval patterns.

**RED:** Behavioral test — verify-qa-mode checks local state, not comments.
**GREEN:** Edit file.
**Verification:** `grep` for `get_comments` in file returns zero for authorization paths.

## Phase 5 — Audit Contamination

### Item 5.1: `issue-review/tasks/audit.md` — behavioral enforcement test

**Change:** Add behavioral enforcement test verifying agent routes audit findings to chat + lifecycle manifest, not to `github_add_issue_comment`.

**RED:** Write behavioral test that FAILS (agent currently posts to comments).
**GREEN:** The text prohibition already exists — test should pass after infrastructure is correct.
**Verification:** Behavioral test passes.

### Item 5.2: `issue-review/tasks/triage.md` + `gather.md`

**Change:** Replace `github_issue_read(method=get_comments)` for audit patterns with local file reads from `.issues/{N}/audit/`.

**RED:** Behavioral test — triage/gather read local audit artifacts, not comments.
**GREEN:** Edit both files.
**Verification:** `grep` for `get_comments` in both files returns zero for audit pattern scanning.

### Item 5.3: `adversarial-audit` tasks

**Change:** Verify all adversarial-audit task files write verdicts to `.issues/{N}/audit/` — never `github_add_issue_comment`.

**RED:** Already partially true. Verify no remaining comment-posting paths.
**GREEN:** Fix any remaining paths.
**Verification:** `grep` for `github_add_issue_comment` across all adversarial-audit task files returns zero.

## Dependency Order

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
```

Each phase is independent of the next (no code coupling), but sequential execution prevents feature branch contamination.
