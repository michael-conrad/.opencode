## Root Cause

Comment bodies containing markdown formatting (backticks, quotes, special characters) are passed inline via `--body "..."` in bash commands. Backticks in bash trigger command substitution — the shell tries to execute the content between backticks as a command, producing garbled output.

This affects all GitBucket API (`gb`) and `local-issues` tool calls that pass body content inline. The GitHub MCP path (`github_add_issue_comment`) is safe because it passes body as a structured MCP parameter with no shell interpolation.

At least 10 command patterns across 8 files are vulnerable.

## Fix Approach

Replace all inline `--body "..."` patterns with a temp-file approach:

1. Write body content to `{project_root}/tmp/comment-body-{N}.md`
2. For `local-issues`: use `--body-file <path>` (already supported)
3. For `gb`: use `gb issue comment <N> -b "$(cat <tmpfile>)" -R O/R`
4. Clean up temp file after posting

Add a shared procedure in `completion-core` for safe body posting.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All `--body "..."` patterns in issue-operations tasks replaced with temp-file approach | `string` | grep for `--body "` in all issue-operations task files — zero matches |
| SC-2 | `local-issues` calls use `--body-file` instead of `--body` for body content | `string` | grep for `--body-file` in local platform task files |
| SC-3 | `gb` calls use `$(cat <tmpfile>)` or equivalent file-read pattern instead of inline body | `string` | grep confirms no inline `--body "` in gitbucket-api task files |
| SC-4 | Shared safe-body-posting procedure exists in completion-core | `string` | file exists check for completion-core safe-body procedure |
| SC-5 | Comment with backtick-rich markdown content posts correctly (no shell corruption) | `behavioral` | `opencode run` with comment containing backticks → verify comment body matches expected content exactly |

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/issue-operations-comments/tasks/comment.md` | Replace `-b "<body>"` with temp-file approach |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md` | All `--body "..."` patterns |
| `.opencode/skills/issue-operations-core/tasks/update-issue.md` | `--body "<body>"` pattern |
| `.opencode/skills/issue-operations-core/tasks/body-edit.md` | `--body "<body>"` pattern |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/repository-operations.md` | `--body "..."` pattern |
| `.opencode/skills/issue-operations/platforms/local/tasks/comment.md` | `--body "TEXT"` patterns |
| `.opencode/skills/issue-operations/platforms/local/tasks/update.md` | `--body "..."` pattern |
| `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md` | `--body "<body>"` pattern |
| `.opencode/skills/completion-core/completion-core.md` | Add shared safe-body-posting procedure |

## Risk Assessment

- **Low risk**: The change replaces inline body passing with file-based passing. The behavior is identical — only the mechanism changes. The `local-issues` tool already supports `--body-file`, so that path is proven. The `gb` `$(cat ...)` pattern is standard shell practice. The only risk is a temp file not being cleaned up, which is mitigated by the existing `tmp/` cleanup rules.
