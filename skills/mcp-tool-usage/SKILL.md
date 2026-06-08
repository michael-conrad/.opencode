---
name: mcp-tool-usage
description: When you need to read, write, edit, search, or grep files, load this skill first. Use viewport-editor for all file operations. Built-in read/write/edit/grep have been superseded. Triggers on: read, write, edit, grep, search, find, open, view, create, modify, replace, delete, file, content, text, line, code, which tool, tool priority, MCP, PyCharm, JetBrains, read file, write file, edit file, search file, search code, grep file, open file, view file, create file, find text, tool selection. viewport-editor is the default tool for reading, writing, editing, and searching files.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# MCP Tool Usage

## Overview

Tool selection guidance for non-obvious choices: srclight, glob/grep, guidelines, notebooks.

## Tasks

| Task | Purpose |
|------|---------|
| `read` | Read a file or directory from the local filesystem. |
| `write` | Writes a file to the local filesystem. |
| `edit` | Performs string replacements in files. |
| `grep` | Search tool for file content. |
| `search` | Search across files in the project. |
| `selection-guide` | Decision trees for Python code, file ops, notebooks |

## Sub-Agent Tasks

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `pre-analysis` | Before any sub-agent routing, determine scope independently | Issue number, task description, audit_phase, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `selection-guide` | When tool selection guidance is needed for file operations, notebooks, or code search | Operation type, file extension, project context | Implementation context, agent memory | NO |

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

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

## Invocation

`skill({name: "mcp-tool-usage"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `read` | `task(..., prompt: "execute read task from mcp-tool-usage")` |
| `write` | `task(..., prompt: "execute write task from mcp-tool-usage")` |
| `edit` | `task(..., prompt: "execute edit task from mcp-tool-usage")` |
| `grep` | `task(..., prompt: "execute grep task from mcp-tool-usage")` |
| `search` | `task(..., prompt: "execute search task from mcp-tool-usage")` |
| `selection-guide` | `task(..., prompt: "execute selection-guide task from mcp-tool-usage")` |

**CLI equivalent (for human TUI use):** `/skill mcp-tool-usage --task <task>`

## Tool Reference

* viewport-editor: Read, write, edit, and search files. Default tool for all file operations. Mandatory to use for reading, writing, editing, and searching files.
* srclight: Python code analysis (search symbols, callers, callees, type hierarchy, tests)
* GitHub MCP: Issue/PR operations, branch management, file contents
* .opencode/tools/guidelines: Guideline search/read
* Direct CLI (bash): git, docker, package management only

## Critical Rules

`.ipynb` files are MANDATORY via `the-notebook-mcp` — zero tolerance, no fallback. Do NOT infer GitHub owner from file paths or cached values. See `060-tool-usage.md` §2 for worktree path resolution rules.