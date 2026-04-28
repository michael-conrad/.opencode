# Task: provenance

## Purpose

Create provenance tracking issues and PRs in submodule repositories after push or promotion operations. Detects the submodule's host platform and falls back gracefully through a three-tier model. Provenance ensures that submodule changes are tracked in the submodule's own repository, creating an audit trail for cross-repo modifications.

## Operating Protocol

1. **Triggered after push or promotion** — submodule push/merge triggers provenance attempt
2. **Three-tier fallback** — if full API access unavailable, fall back silently to next tier
3. **Platform detection** — determine submodule's issue system from remote URL before API calls
4. **Never HALT** — all fallbacks are silent; git workflow continues regardless of provenance success

## Entry Criteria

- A submodule has been pushed or promoted
- `.gitmodules` exists in the worktree
- Submodule remote URL is available via `git remote get-url origin`

## Exit Criteria

- Platform detection cached for session
- Provenance tracked at the highest available tier
- All detection results logged
- Git workflow continues (no blocking — provenance is non-blocking)

## Three-Tier Fallback Model

| Tier | Access Level | Action |
| -- | -- | -- |
| **Tier 1** | `full` | Create issue + PR in submodule repo linking to parent context |
| **Tier 2** | `issue-only` | Create issue only in submodule repo (no PR capability) |
| **Tier 3** | `no-access`, `auth-failed`, `no-repo` | Commit message as provenance record (no API access) |

**All fallbacks are silent.** No HALT, no blocking, no error reporting that stops the workflow. Provenance failure is logged but never blocks git operations.

## Procedure

### Step 0-2: Platform Detection and API Testing

**Route to:** `provenance/platform-detection`

Parses submodule remote URL, identifies platform (github/gitbucket/unknown), tests API availability, and caches result for the session. This step determines which provenance tier applies.

### Steps 6-10: Dev-Push Provenance

**Route to:** `provenance/dev-push-provenance`

For submodule push operations during review-prep: creates issue + PR (Tier 1), issue only (Tier 2), or commit message fallback (Tier 3). Includes parent branch reference and change description.

### Steps 11-16: Promotion Provenance

**Route to:** `provenance/promotion-provenance`

For submodule release promotion: creates issue + PR (Tier 1), issue only (Tier 2), or commit message fallback (Tier 3) with tag context and release notes.

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `provenance/platform-detection` | Detect platform, test API, cache results | ≈450 |
| `provenance/dev-push-provenance` | Create dev-push provenance with Tier 1-3 fallback | ≈550 |
| `provenance/promotion-provenance` | Create promotion provenance with release tag context | ≈500 |

## Context Parameters

**For dev-push-provenance:**

| Parameter | Source |
| -- | -- |
| parent_repo | `<github.owner>/<github.repo>` from session |
| parent_branch | Current feature branch name |
| parent_issue | Issue number from implementation |
| submodule_path | Path of pushed submodule in parent |
| change_description | Brief description of what changed |

**For promotion-provenance:**

| Parameter | Source |
| -- | -- |
| tag_name | Semver tag created for release |
| source_branch | Branch promoted (typically `dev`) |

## Error Handling

| Error | Resolution |
|-------|-----------|
| Platform detection fails | Classify as `unknown`, fall back to Tier 3 |
| API test timeout | Treat as `no-access`, fall back to Tier 3 |
| Issue creation fails | Fall back to Tier 3 commit message |
| PR creation fails | Keep issue (Tier 2), skip PR |

## Context Required

- Related tools: `.opencode/tools/gitbucket-api`
- Related skills: `git-workflow --task release-promotion`, `conflict-resolution`
- Related tasks: `review-prep`, `release-promotion`