---
trigger_on: comment, context completeness, read all, all comments
tier: 1
load_when: sub-agent
---

# Context Completeness — Read All Comments Before Acting

## Zero Tolerance Rule

**🚫 CRITICAL VIOLATION: Acting on a GitHub/GitBucket resource without reading ALL comments first.**

The body or description alone is NEVER sufficient context. Comments may contain critical information: authorizations, direction changes, clarifications, blockers, or bug reports.

## Scope of Resources

| Resource | What to Read |
| -- | -- |
| Issues | Issue body + ALL issue comments |
| Pull Requests | PR description + ALL PR comments + ALL review comments |
| Discussions | Discussion body + ALL discussion comments |

## When This Applies

Before any action on a resource, read all comments. Exception: passive reading (no subsequent action) does not require comment reading.

## Evidence Requirement

When the agent reads comments before acting, it MUST show evidence:

- **Reference specific comments**: "Saw comment by @user on 2026-04-09 approving Phase 2" not just "I read the comments"
- **Count or summarize**: "Read 5 comments — 2 approvals, 1 clarification, 2 progress updates"
- **Highlight relevant ones**: Call out comments that change or clarify the spec content

## Staleness Rule

Comments may have been added **since the agent last read the resource**. The agent MUST re-read comments if:

- The agent is about to take a significant action (implementation, approval check, PR creation, issue closure, spec revision)
- The agent previously relied on memory instead of re-reading (see `065-verification-honesty.md`)
- Any time has passed since the last read — comments are live, async data

### Significant Actions Requiring Re-Read

The staleness rule is NOT about time estimation. It is about **action significance**. Before any of these actions, re-read comments even if read moments ago:

1. Starting implementation
2. Checking authorization status
3. Creating or updating a PR
4. Closing an issue
5. Revising a spec
6. Creating sub-issues

### De Minimis Bound

If the resource was read in the same session and no state-change trigger has occurred, re-reading comments before a subsequent action on the SAME resource is OPTIONAL, not mandatory. The staleness rule applies to resources NOT read in the current session, or where a state-change trigger has occurred.

**Examples:**
| Action | Resource last read | State-change trigger? | Re-read required? |
| -- | -- | -- | -- |
| Check authorization | 2 exchanges ago | No | No — session-verified |
| Create PR | Comments read 1 exchange ago | No | No — still within session |
| Revise spec | User just posted new comment | Yes | Yes — state changed |
| Close issue | Session started 10 min ago, no prior read | N/A | Yes — staleness rule applies |

## Single Exchange Window

If comments were read in the **immediately preceding exchange** (the last assistant turn in the same conversation), the agent MAY reference those results without re-reading. Any earlier reference requires re-checking for new comments.

This is consistent with the Single Exchange Window defined in `065-verification-honesty.md`.

## 🚫 FORBIDDEN

- Acting on an issue after reading only the issue body
- Reviewing a PR without reading review comments
- Checking authorization without reading recent comments
- Assuming "no new comments" without actually checking
- Caching comment state from a previous session
- Skipping comment reads because "I checked earlier"

## ✅ REQUIRED

- Read ALL comments before ANY action on a resource
- Show evidence of having read comments (count, summarize, or cite)
- Re-read before significant actions even if recently read
- Use `github_issue_read` with `method=get_comments` (or equivalent) to fetch comments
- Treat comment reading as mandatory verification work (per `065-verification-honesty.md`)

## Related Guidelines

- `065-verification-honesty.md` — Never rely on memory when instructed to check
- `000-critical-rules.md` — Zero tolerance violations including "Ignoring Issue Comments"
- `075-docs-verification.md` — Mandatory live documentation verification
- `130-authority-source.md` — Code as authoritative source

### [critical-rules-012] Acting on Resources Without Reading All Comments
Acting on a resource after reading only the body means you are working with partial context. Every unread comment is a defect vector. Professional engineers read ALL comments before any action — see `067-context-completeness.md`. Amateurs act on partial context and call assumptions facts.

### [critical-rules-012] Ignoring Issue Comments
Acting on an issue without reading all its comments is the signature move of engineers who produce work that needs to be redone. Every unread comment is a defect waiting to surface. Professional engineers read every comment before touching a single line of code. Read [issue-operations skill](skills/issue-operations/SKILL.md) → `comment` task.
