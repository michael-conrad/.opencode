> **Full spec and artifacts: `.opencode/.issues/1705/`** — this issue is a condensed exec summary; the authoritative spec lives in local artifacts.

## Problem

The Channel-Routing Table in `000-critical-rules.md` line 1017 routes `PR created` to `Issue comment`. This causes the agent to post "PR created: #NNN" as a GitHub Issue comment on the parent issue after creating a PR. This is noise — the user has to delete it. The PR URL is already visible in chat output and in the PR itself.

### Root Cause

The Channel-Routing Table was designed with the assumption that "PR created" is substantive information that belongs on the issue. It is not. The PR URL is already:
1. Returned by `github_create_pull_request` in chat
2. Visible in the repository's PR list
3. Linked from the issue via GitHub's cross-reference auto-detection (when the PR body says "Closes #N")

Posting it again as an issue comment adds zero value and creates cleanup work.

## Scope

**In scope:**
- Change `000-critical-rules.md` Channel-Routing Table: `PR created` → `Chat only`
- Behavioral enforcement test: agent does NOT post "PR created" as an issue comment

**Out of scope:**
- Other Channel-Routing Table entries (they are correct)
- Changes to `completion-core` or `git-workflow` completion tasks (they produce chat output, which is correct)

## Approach

One change:

1. **`000-critical-rules.md`** — Change line 1017 from `| PR created | Issue comment |` to `| PR created | Chat only |`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Channel-Routing Table routes "PR created" to Chat only | `string` | `grep -A1 "PR created" .opencode/guidelines/000-critical-rules.md \| grep "Chat only"` |
| SC-2 | Behavioral test: agent does NOT post "PR created" as an issue comment | `behavioral` | `opencode-cli run` with behavioral test → stderr shows no `github_add_issue_comment` call with PR URL |

## Dependencies

- None

## Edge Cases

- **PR body already says "Closes #N"** — GitHub auto-links the PR to the issue. No comment needed.
- **PR body does NOT say "Closes #N"** — still no comment needed. The PR URL is in chat output.

---

🤖 OpenCode (deepseek-v4-flash) created