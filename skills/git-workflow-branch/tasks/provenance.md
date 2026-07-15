# Task: provenance

## Purpose

Create provenance tracking issues and PRs in submodule repositories after push operations. Detects the submodule's host platform and falls back gracefully through a three-tier model.

## Operating Protocol

- [ ] 1. **Triggered after push** — submodule push triggers provenance attempt
- [ ] 2. **Three-tier fallback** — if full API access unavailable, fall back silently to next tier
- [ ] 3. **Platform detection** — determine submodule's issue system from remote URL before API calls
- [ ] 4. **HALT on fallback** — any fallback from primary path causes HALT with degradation report

## Entry Criteria

- A submodule has been pushed
- Glob scan detects non-root git repos at project root (`ls -d .git/ */.git/ */.git`)
- Submodule remote URL is available

## Exit Criteria

- Platform detection cached for session
- Provenance tracked (Tier 1, 2, or 3)
- All detection results logged
- HALT on fallback with degradation report

## Three-Tier Fallback Model

| Tier | Access Level | Action |
| -- | -- | -- |
| **Tier 1** | `full` | Create issue + PR in submodule repo |
| **Tier 2** | `issue-only` | Create issue only in submodule repo |
| **Tier 3** | `no-access`, `auth-failed`, `no-repo` | Tag-based provenance via parent-prefixed tags (see `AGENTS.md` §Tag Layers) |

**HALT on fallback:** Any fallback from primary path causes HALT with degradation report in the halt message. No issue comments for chat-level status.

**Tag-based provenance (Tier 3):** Submodule SHAs are tagged with `<parent>/<issue-number>` tags per `AGENTS.md` §Tag-Based Hash Permanence. These tags serve as the provenance record — no separate issue or PR needed.

## Procedure

### Step 0-2: Platform Detection and API Testing

**Route to:** `provenance/platform-detection`

Parses submodule remote URL, identifies platform (github/gitbucket/unknown), tests API availability, and caches result.

### Steps 6-10: Trunk-Push Provenance

**Route to:** `provenance/trunk-push-provenance`

For submodule push operations during review-prep: creates issue + PR (Tier 1), issue only (Tier 2), or tag-based provenance (Tier 3).

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `provenance/platform-detection` | Detect platform, test API, cache results | ≈450 |
| `provenance/trunk-push-provenance` | Create trunk-push provenance with Tier 1-3 fallback | ≈550 |

## Context Parameters

**For trunk-push-provenance:**
| Parameter | Source |
| -- | -- |
| parent_repo | `<github.owner>/<github.repo>` from session |
| parent_branch | Current feature branch name |
| parent_issue | Issue number from implementation |
| submodule_path | Path of pushed submodule in parent |
| change_description | Brief description of what changed |

**Tag layer reference:** See `AGENTS.md` §Tag Layers for the tag types:

| Tag | When Created | Example |
|-----|-------------|---------|
| `<parent>/<issue-number>` | Pre-work (feature dev start) | `opencode-config/221` |
| `<parent>/<issue-number>-<sub>` | Feature-branch push | `opencode-config/221-opencode` |

## Context Required

- Related tools: `.opencode/tools/gitbucket-api`
- Related skills: `git-workflow --task pr-creation`, `conflict-resolution`
- Related tasks: `review-prep`, `pr-creation`