## Problem

The implementation pipeline reaches `halt_at: pr_created` but has no `create-pr` step in its Trigger Dispatch Table. The last two steps are `review-prep` → `exec-summary` — neither dispatches PR creation. This causes the agent to ad-hoc the PR creation inline (calling `github_create_pull_request` directly) instead of routing through `pr-creation-workflow` → `git-workflow --task create-pr`.

## Root Cause

Two gaps:

1. **`implementation-pipeline/SKILL.md`** — Trigger Dispatch Table has no `create-pr` step between `review-prep` and `exec-summary`. The pipeline state machine (`halt_at: pr_created`) has no mapping to a PR creation task.

2. **`pr-creation-workflow/SKILL.md`** — Has `pre-pr-checklist` and `sub-issue-collection` tasks but no `create` task that dispatches to `git-workflow --task create-pr`. The skill is advisory-only (checklist, collection) with no execution path.

## Required Changes

### 1. `implementation-pipeline/SKILL.md` — Add `create-pr` pipeline step

Add a new row to the Trigger Dispatch Table between `review-prep` and `exec-summary`:

| `create-pr` | `pr-creation-workflow --task create` | `sub-task` | `{issue_number, authorization_scope, halt_at}` |

Also add to the Step Labels list and the Canonical Dispatch Strings table:

| `create-pr` | `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")` |

### 2. `pr-creation-workflow/SKILL.md` — Add `create` task

Add a new task entry:

| `create` | `sub-task` | `{issue_number, authorization_scope, halt_at}` |

Add to Invocation table:

| `create` | `task(..., prompt: "execute create task from pr-creation-workflow")` |

### 3. Create `pr-creation-workflow/tasks/create.md`

New task file that:
- Verifies PR authorization scope (`halt_at >= pr_created`)
- Reads the VbC table artifact from `{project_root}/tmp/{issue-N}/artifacts/vbc-table-*.md`
- Dispatches to `git-workflow --task create-pr` for the actual PR creation
- Extracts PR URL from `github_create_pull_request` response `html_url`
- Returns result contract with PR URL

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `implementation-pipeline` Trigger Dispatch Table has `create-pr` step between `review-prep` and `exec-summary` | `string` | grep for `create-pr` in implementation-pipeline/SKILL.md |
| SC-2 | `pr-creation-workflow` has `create` task in Trigger Dispatch Table | `string` | grep for `create` in pr-creation-workflow/SKILL.md |
| SC-3 | `pr-creation-workflow/tasks/create.md` exists and dispatches to `git-workflow --task create-pr` | `string` | file existence + grep for `git-workflow` |
| SC-4 | Agent routes PR creation through pipeline instead of ad-hoc `github_create_pull_request` | `behavioral` | `opencode-cli run` with `for_pr` scope → verify stderr shows `pr-creation-workflow` dispatch |

## Affected Files

- `.opencode/skills/implementation-pipeline/SKILL.md`
- `.opencode/skills/pr-creation-workflow/SKILL.md`
- `.opencode/skills/pr-creation-workflow/tasks/create.md` (new)

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*