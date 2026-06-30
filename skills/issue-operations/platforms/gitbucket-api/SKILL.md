---
name: gitbucket-api
description: "Use when GitBucket platform operations are needed. Also use when routing issue operations to GitBucket via the gb CLI tool, or when GitBucket-specific API capabilities are required. Invoke for: GitBucket issue creation, GitBucket issue comment, GitBucket issue closure, GitBucket label management, gb CLI operations. GitBucket operations without platform awareness fail silently. Platform-aware routing is what makes multi-platform workflows reliable. Trigger phrases: GitBucket, gb CLI, GitBucket issue, GitBucket API, GitBucket platform."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# GitBucket API Platform Sub-Skill

## Overview

GitBucket platform implementation using the `gb` CLI tool. Implements a GitHub-compatible API v3 with known deficiencies. This is a platform sub-skill under `issue-operations` — the router passes GitBucket operations here when `github.platform=gitbucket`.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## TOOL_MISSING Detection

Before any `gb` command, verify the tool is available:

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found. Install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs"
  return 1
fi
```

## Version Check

Verify `gb` version >= 0.6.1 before proceeding:

```bash
GB_VERSION=$(gb --version 2>/dev/null | grep -oP '[\d]+\.[\d]+\.[\d]+' | head -1)
if [ -z "$GB_VERSION" ]; then
  echo "VERSION_CHECK_FAILED: Could not determine gb version"
  return 1
fi
if ! printf '%s\n' "0.6.1" "$GB_VERSION" | sort -V | head -1 | grep -q "^0.6.1$"; then
  echo "VERSION_CHECK_FAILED: gb $GB_VERSION < required 0.6.1"
  return 1
fi
```

## Capability Manifest (gb CLI v0.6.1)

| Operation | Supported | gb Command |
|----------|-----------|------------|
| Create issue | ✅ | `gb issue create -t "<title>" -R O/R [--body ...] [--label ...]` |
| List issues | ✅ | `gb issue list -R O/R [--state ...]` |
| Get issue | ✅ | `gb issue view <N> -R O/R` |
| Edit issue | ✅ | `gb issue edit <N> -R O/R [--title ...] [--add-label ...]` (web fallback) |
| Close issue | ✅ | `gb issue close <N> -R O/R` |
| Reopen issue | ✅ | `gb issue reopen <N> -R O/R` |
| Add comment | ✅ | `gb issue comment <N> -b "<body>" -R O/R` |
| Delete comment | ❌ | No API |
| Sub-issues | ❌ | No API — use comment-based linking |
| Search issues | ❌ | No API — use iterative listing + client-side filter |
| Search PRs | ❌ | No API — use iterative listing + client-side filter |
| Labels on creation | ✅ | `gb issue create --label l1,l2` |
| Post-creation labels | ❌ | Returns empty array — labels NOT added |
| List labels | ✅ | `gb label list -R O/R` |
| Create label | ✅ | `gb label create <name> --color <hex> -R O/R` |
| View label | ✅ | `gb label view <name> -R O/R` |
| Edit label | ✅ | `gb label edit <name> -R O/R` |
| Delete label | ✅ | `gb label delete <name> --yes -R O/R` |
| Create PR | ✅ | `gb pr create -t "<title>" --head <b> -B <b> -R O/R` |
| List PRs | ✅ | `gb pr list -R O/R [--state ...]` |
| Get PR | ✅ | `gb pr view <N> -R O/R` |
| Edit PR | ✅ | `gb pr edit <N> -R O/R [--add-assignee ...]` |
| Merge PR | ✅ | `gb pr merge <N> -R O/R` |
| Close PR | ✅ | `gb pr close <N> -R O/R` |
| PR diff | ✅ | `gb pr diff <N> -R O/R` |
| PR comment | ✅ | `gb pr comment <N> -b "<body>" -R O/R` |
| PR reviews | ❌ | No API — use git log fallback |
| PR comments/files | ❌ | No API — use git log fallback |
| File contents | ❌ | 404/500 — use git CLI fallback |
| Commits API | ❌ | 500 JGit NPE — use git CLI fallback |
| Create branch | ❌ | 404 — use git CLI |
| Releases/tags | ❌ | Use `gb api` passthrough |
| List branches | ✅ | `gb api repos/O/R/branches -R O/R` (passthrough) |
| Get repository | ✅ | `gb repo view O/R` |
| List repos | ✅ | `gb repo list [owner]` |
| Create repo | ✅ | `gb repo create <name> [-g group]` |
| API passthrough | ✅ | `gb api <endpoint> [-X method] [--input ...]` |

## Tasks

| Task | Purpose |
|------|---------|
| `issue-operations` | Issue CRUD patterns, create/update/list workarounds |
| `label-operations` | Label CRUD, auto-creation, post-creation limitations |
| `error-recovery` | Error handling, retry logic, credential failures |
| `mcp-operations` | gb command reference, tool selection, error classification |
| `repository-operations` | Repository CRUD, branch operations |
| `session-integration` | Session init integration, env var detection |

## Sub-Agent Tasks

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `issue-operations` | When GitBucket issue CRUD patterns are needed | Operation type, issue data, github.owner, github.repo | Implementation context, agent memory | NO |
| `label-operations` | When GitBucket label CRUD is needed | Label name, color, github.owner, github.repo | Implementation context, agent memory | NO |
| `error-recovery` | When GitBucket error handling/retry is needed | Error details, retry context | Implementation context, agent memory | NO |
| `mcp-operations` | When GitBucket gb command reference is needed | Operation type, gb context | Implementation context, agent memory | NO |
| `repository-operations` | When GitBucket repository CRUD is needed | Repository data, github.owner, github.repo | Implementation context, agent memory | NO |
| `pre-analysis` | Before any sub-agent routing, determine scope independently | Issue number, task description, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `session-integration` | When GitBucket session init integration is needed | Session context, environment variables | Implementation context, agent memory | NO |

## Authorization Labels (Platform-Supported)

GitBucket API supports labels via creation only (post-creation label mutation is broken). The eight `approved-for-*` labels are:

| Label | Purpose |
| `approved-for-spec` | Authorization through spec creation |
| `approved-for-plan` | Authorization through plan creation |
| `approved-for-implementation` | Authorization through implementation |
| `approved-for-code-review` | Authorization through code review |
| `approved-for-pr` | Full pipeline through PR creation |
| `approved-for-pr-only` | PR creation only |
| `approved-for-review` | Code review only |
| `approved-for-review-prep` | Default authorization |

`needs-approval` is the default label for unapproved issues. It is applied on creation and replaced by the corresponding `approved-for-*` label at time of authorization. No `approved-for-*` label = awaiting approval. Label replacement on re-authorization is implemented via comment fallback (remove old label via comment, apply new on next creation cycle).

## Authentication

Token authentication ONLY. Basic auth is broken in GitBucket (returns "Bad credentials" for all requests).

```bash
gb auth status
```

## CLI Tool

**Use `gb` CLI for all GitBucket operations.** The CLI handles authentication, response parsing, and error handling. See task files for command-specific patterns.

**CRITICAL: Agent MUST use the `gb` CLI for ALL API calls on GitBucket platform. If a needed command is missing, use `gb api` passthrough. NEVER fall back to inline `requests` scripts or `python -c` strings.**

### Command Reference

| Command | Description |
| `gb issue list -R O/R [--state ...]` | List issues |
| `gb issue view <N> -R O/R` | Get single issue |
| `gb issue create -t "<title>" -R O/R [--body ...] [--label ...]` | Create issue |
| `gb issue edit <N> -R O/R [--title ...] [--add-label ...]` | Edit issue |
| `gb issue close <N> -R O/R` | Close issue |
| `gb issue reopen <N> -R O/R` | Reopen issue |
| `gb issue comment <N> -b "<body>" -R O/R` | Add comment |
| `gb pr list -R O/R [--state ...]` | List pull requests |
| `gb pr view <N> -R O/R` | Get pull request |
| `gb pr create -t "<title>" --head <b> -B <b> -R O/R` | Create pull request |
| `gb pr edit <N> -R O/R` | Edit pull request |
| `gb pr merge <N> -R O/R` | Merge pull request |
| `gb pr close <N> -R O/R` | Close pull request |
| `gb pr diff <N> -R O/R` | Show PR diff |
| `gb pr comment <N> -b "<body>" -R O/R` | Add PR comment |
| `gb label list -R O/R` | List labels |
| `gb label create <name> --color <hex> -R O/R` | Create label |
| `gb label view <name> -R O/R` | View label |
| `gb label edit <name> -R O/R` | Edit label |
| `gb label delete <name> --yes -R O/R` | Delete label |
| `gb repo list [owner]` | List repositories |
| `gb repo view O/R` | Get repository |
| `gb repo create <name> [-g group]` | Create repository |
| `gb auth status` | Validate authentication |
| `gb api <endpoint> [-X method] [--input ...]` | API passthrough |

## Response Schema

All `list` endpoints return arrays, NOT objects. Use `--json --no-pager` flags for JSON output.

## Operating Protocol

- [ ] 1. Detect GitBucket platform from session init output
- [ ] 2. Verify `gb` is installed (TOOL_MISSING check)
- [ ] 3. Verify `gb --version` >= 0.6.1
- [ ] 4. Use `gb` CLI for all API operations
- [ ] 5. Use explicit `-R owner/repo` flags (not auto-resolution from git remote)
- [ ] 6. Add labels ONLY during `gb issue create --label`
- [ ] 7. Use `gb issue close` for closing issues
- [ ] 8. Use comment-based linking for sub-issues
- [ ] 9. Use iterative listing for search operations
- [ ] 10. Follow error recovery procedures in `tasks/error-recovery.md`

## Cross-References

| Guideline | Section |
| Router | `../../SKILL.md` (issue-operations) |
| GitHub platform | `../github-mcp/SKILL.md` |
| Session init plugin | GitBucket detection and credentials |
| `reference/` | OpenAPI v4.42.1 specification |
| `tests/` | API verification test suite |
| `API-DEFICIENCIES.md` | Detailed deficiency documentation |
