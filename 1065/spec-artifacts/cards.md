# Card Catalogue — #1065

## Card: Spec Overview

| Field | Value |
|-------|-------|
| **Issue** | #1065 |
| **Title** | [SPEC] local-issues tool: AI-consumable output format and cross-repo operations |
| **Status** | spec |
| **Scope** | Tool output format, cross-repo read/search, mutation qualified-form requirement |
| **Dependencies** | [#1059](https://github.com/michael-conrad/.opencode/issues/1059) (worktree infra), parent: #1060 |
| **Items from analysis** | local-issues tooling format + cross-repo disambiguation |
| **SC Count** | 13 (5 behavioral, 8 string) |

## Card: Output Format (SC-1, SC-2, SC-3)

| Field | Value |
|-------|-------|
| **Tool function** | `local-issues list` |
| **Current format** | `#7 [open] Title` |
| **Required format** | `opencode-config#7 ./.issues/7/ open Title` |
| **New fields** | `{repo}#{N}`, `spec_path`, `status`, `title` |
| **Sorting** | Main repo first → submodules alpha → issue number desc |
| **Evidence type** | string (SC-1), string (SC-2), behavioral (SC-3) |

## Card: Cross-Repo Read (SC-4, SC-5)

| Field | Value |
|-------|-------|
| **Tool function** | `local-issues read` |
| **Bare number behavior** | Scan all repos, return all matches with qualified prefix |
| **Qualified form behavior** | `read opencode-config#10` targets specific repo directly |
| **Evidence type** | string (SC-4), string (SC-5) |

## Card: Mutation Qualified-Form (SC-6)

| Field | Value |
|-------|-------|
| **Tool functions** | update, close, delete, promote, push-body, pull-body |
| **Bare number behavior** | REJECTED — "Use qualified form `{repo}#{N}`" |
| **Qualified form required** | `local-issues close opencode-config#7 --reason completed` |
| **Evidence type** | behavioral |

## Card: Cross-Repo Search (SC-7)

| Field | Value |
|-------|-------|
| **Tool function** | `local-issues search` |
| **Default scope** | Cross-repo (all immediate child repos) |
| **Output includes** | `repo`, `spec_path`, `number`, `title`, `status` |
| **Evidence type** | behavioral |

## Card: Create Collision Check (SC-8)

| Field | Value |
|-------|-------|
| **Tool function** | `local-issues create --number N` |
| **Current behavior** | Local-only collision check |
| **Required behavior** | Cross-repo collision check — blocks if any repo has `{repo}#{N}` |
| **Evidence type** | behavioral |

## Card: Skill Task Card Updates (SC-9, SC-10, SC-11, SC-12)

| File | Change | SC |
|------|--------|----|
| `platforms/local/tasks/list.md` | Update YAML output format (repo, spec_path) | SC-9 |
| `platforms/local/tasks/read.md` | Document cross-repo lookup behavior | SC-10 |
| `platforms/local/tasks/search.md` | Document cross-repo default scope | SC-11 |
| `platforms/local/tasks/update.md` | Use `{repo}#{N}` in examples | SC-12 |
| `platforms/local/tasks/close.md` | Same | SC-12 |
| `platforms/local/tasks/delete.md` | Same | SC-12 |
| `platforms/local/tasks/promote.md` | Same | SC-12 |
| `platforms/local/tasks/push-body.md` | Same | SC-12 |
| `platforms/local/tasks/pull-body.md` | Same | SC-12 |
| `platforms/local/tasks/body-edit.md` | Same | SC-12 |
| `sync-pull-to-local.md` | Same | SC-12 |

## Card: Read Scan Order (SC-13)

| Field | Value |
|-------|-------|
| **Scan priority** | Main repo first → immediate child repos alphabetical |
| **Duplicate behavior** | First match is primary; secondary matches listed in disambiguation section |
| **Evidence type** | string |