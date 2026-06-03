<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

______________________________________________________________________

## name: local description: Use when local .issues/ tracking is needed. Local .issues/ directory platform for issue tracking. Used when github.platform is local or unset. Routes all issue operations to .issues/ directory with YAML frontmatter and markdown files. Untracked work is work that can be lost. Even local issues deserve structured tracking. type: discipline-enforcing license: MIT provenance: AI-generated compatibility: opencode

# Local Platform Sub-Skill

## Overview

Local issue tracking platform using `.issues/` directories at the repo root. This platform is selected when `github.platform` is `local` or when no remote is configured. All operations go through the `./.opencode/tools/local-issues` CLI tool.

## Architecture

```text
.issues/
  .counter                  # Next issue number (auto-incremented)
  open/
    001-slug/spec.md         # Issue body (markdown + YAML frontmatter)
    001-slug/comments.md     # Comments/updates (append-only)
  closed/
    002-slug/spec.md
    002-slug/comments.md
```

## Capability Contract

The orchestrator reads this table at routing time to determine if a requested operation is supported. If the operation is listed, the orchestrator dispatches — never inline-implements. If the operation is NOT listed, the orchestrator reports "not supported by local platform" — never creates a workaround.

```yaml
name: local
description: Local .issues/ issue tracking platform. Files + YAML frontmatter in
  worktree.

capabilities:
  create:
    scenarios: [draft, promote, import-remote]
    task: creation
    parameters:
      draft: {title: string, labels: '[string]'}
      promote: {local_number: int, exec_summary: string, platform_type: string}
      import-remote: {remote_number: int, platform_type: string}
    returns: {local_path: string, remote_url?: string, number: int}

  read:
    types: [full, comments, labels, links, all]
    task: read
    parameters: {number: int, type: string}
    returns: YAML document (varies by type)

  update:
    types: [metadata, body]
    task: update
    parameters: {number: int, title?: string, status?: string, phase?: string, 
        labels?: '[string]', body?: string}
    returns: {number: int, updated_fields: '[string]'}

  comment:
    types: [internal, stakeholder]
    task: comment
    parameters: {number: int, body: string, type: string}
    returns: {number: int, entry_count: int}

  close:
    task: close
    parameters: {number: int, reason?: string}
    returns: {number: int, status: closed}

  delete:
    task: delete
    parameters: {number: int, force?: bool}
    returns: {number: int, deleted: true}

  search:
    task: search
    parameters: {status?: string, labels?: '[string]', query?: string}
    returns: '[{ number: int, title: string, status: string, labels: "[string]", phase?:
      string }]'

  list:
    task: list
    parameters: {status?: string}
    returns: '[{ number: int, title: string, status: string, phase?: string }]'

  body-edit:
    task: body-edit
    parameters: {number: int, edit_script: string}
    returns: {sync_status: string, url?: string}

  push-body:
    task: push-body
    parameters: {number: int}
    returns: {sync_status: string, url?: string}

  pull-body:
    task: pull-body
    parameters: {number: int}
    returns: {number: int, last_sync: string}

  link:
    task: link
    parameters: {number: int, github?: int, child?: int, related?: int, 
        blocked_by?: int}
    returns: {number: int, links_updated: '[string]'}

  promote:
    task: promote
    parameters: {number: int}
    returns: {local_path: string, remote_url: string, remote_number: int}

  tag-gate:
    task: tag-gate
    parameters: {gate_name: string, issue: int, message: string}
    returns: {tag_name: string, verified: bool}
```

## CLI Tool

All operations go through `./.opencode/tools/local-issues`:

```bash
local-issues create [--scenario draft|promote|import-remote] [--title TITLE] [--labels L1,L2]
local-issues read NNN [--type full|comments|labels|links|all]
local-issues update NNN [--title T] [--status S] [FIELD=VALUE]
local-issues comment NNN --body "TEXT" [--type internal|stakeholder]
local-issues close NNN [--reason REASON]
local-issues delete NNN [--force]
local-issues search [--status S] [--labels L1,L2] [--query TEXT]
local-issues list [--status S]
local-issues body-edit NNN [--edit-script SCRIPT]
local-issues push-body NNN
local-issues pull-body NNN
local-issues link NNN [--github N] [--child N] [--related N] [--blocked-by N]
local-issues promote NNN [--remote-url URL]
local-issues tag-gate --gate-name PHASE --issue NNN --message "MSG"
```

## Authorization Labels

The local platform supports all eight `approved-for-*` labels in YAML frontmatter. Labels are stored as a frontmatter array field.

| Label                         | Purpose                              |
| ----------------------------- | ------------------------------------ |
| `approved-for-spec`           | Authorization through spec creation  |
| `approved-for-plan`           | Authorization through plan creation  |
| `approved-for-implementation` | Authorization through implementation |
| `approved-for-code-review`    | Authorization through code review    |
| `approved-for-pr`             | Full pipeline through PR creation    |
| `approved-for-pr-only`        | PR creation only                     |
| `approved-for-review`         | Code review only                     |
| `approved-for-review-prep`    | Default authorization                |

`needs-approval` is the default label for unapproved issues. Applied on creation and replaced by `approved-for-*` label at authorization. No `approved-for-*` label = awaiting approval.

## Promotion Workflow

When `github.platform` is NOT `local` (remote available), local issues can be promoted:

1. Create local issue first (working draft)
1. On authorization event, promote content to GitHub Issue via `issue-operations --task creation`
1. Link local issue to GitHub issue: `./.opencode/tools/local-issues link NNN --github GITHUB_NUM`
1. Add comment on GitHub Issue referencing local path

## Worktree Exemption

`.issues/` files are non-behavioral metadata. Exempt from worktree requirement per `060-tool-usage.md` §Worktree Exemption, but NOT exempt from branching requirement (no direct commits to `dev`/`main`).

## Sub-Agent Tasks

### Task Routing

| Sub-Agent Task | Trigger Condition                                           | Scope of Context                             | Exclusions                                                          | Inline Work? |
| -------------- | ----------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------------- | ------------ |
| `creation`     | When creating a local issue                                 | Scenario, title, body, labels, .issues/ path | Implementation context, agent memory                                | NO           |
| `read`         | When reading a local issue                                  | Issue number, read type, .issues/ path       | Implementation context, agent memory                                | NO           |
| `update`       | When updating a local issue                                 | Issue number, fields, .issues/ path          | Implementation context, agent memory                                | NO           |
| `comment`      | When commenting on a local issue                            | Issue number, body, type, .issues/ path      | Implementation context, agent memory                                | NO           |
| `close`        | When closing a local issue                                  | Issue number, reason, .issues/ path          | Implementation context, agent memory                                | NO           |
| `delete`       | When deleting a local issue                                 | Issue number, force flag, .issues/ path      | Implementation context, agent memory                                | NO           |
| `search`       | When searching local issues                                 | Query, labels, status, .issues/ path         | Implementation context, agent memory                                | NO           |
| `list`         | When listing local issues                                   | Status filter, .issues/ path                 | Implementation context, agent memory                                | NO           |
| `body-edit`    | When editing a local issue body                             | Issue number, edit script, .issues/ path     | Implementation context, agent memory                                | NO           |
| `push-body`    | When pushing local body to remote                           | Issue number, .issues/ path                  | Implementation context, agent memory                                | NO           |
| `pull-body`    | When pulling remote body to local                           | Issue number, .issues/ path                  | Implementation context, agent memory                                | NO           |
| `link`         | When linking local issue to other issues                    | Issue number, link targets, .issues/ path    | Implementation context, agent memory                                | NO           |
| `promote`      | When promoting local issue to remote                        | Issue number, .issues/ path                  | Implementation context, agent memory                                | NO           |
| `tag-gate`     | When creating a pipeline gate tag                           | Gate name, issue number, message             | Implementation context, agent memory                                | NO           |
| `pre-analysis` | Before any sub-agent routing, determine scope independently | Issue number, operation type, .issues/ path  | File paths, line numbers, expected outcomes, orchestrator reasoning | NO           |
| `completion`   | When workflow halts at any point                            | Workflow state, result contract              | Implementation context, agent memory                                | NO           |

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation                        | Forbidden Pattern                                | Correct Pattern                              |
| -------------------------------- | ------------------------------------------------ | -------------------------------------------- |
| Preloaded file paths             | "Read tasks/creation.md then execute step 1"     | "Execute creation task from local platform"  |
| Preloaded step sequences         | "Step 1: write spec.md. Step 2: update counter." | "Execute creation task from local platform"  |
| Preloaded expected outcomes      | "Return { local_path, number }"                  | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The issue was just drafted so we need to..."    | Pure objective, no narrative                 |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `.issues/ path`
- `authorization_scope`
- `pipeline_phase`

Plus operation-specific fields per the task routing table above.

Exclusions (MUST NOT be in prompt):

- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:

- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Cross-References

| Guideline          | Section                                                                   |
| ------------------ | ------------------------------------------------------------------------- |
| Router             | `../../SKILL.md` (issue-operations)                                       |
| GitBucket platform | `../gitbucket-api/SKILL.md`                                               |
| GitHub platform    | `../github-mcp/SKILL.md`                                                  |
| Worktree exemption | `060-tool-usage.md` §Worktree Exemption                                   |
| Critical rules     | `000-critical-rules.md` §Creating .opencode/.opencode/ Nested Directories |
| Card-020           | `.issues/979/cards/card-020-local-skill-capability-contract.md`           |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
