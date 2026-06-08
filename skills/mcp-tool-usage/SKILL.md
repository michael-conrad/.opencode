---
name: mcp-tool-usage
description: Use when selecting tools for file operations, code search, or any task that could use multiple tool options. Triggers on: which tool, tool priority, MCP, PyCharm, JetBrains, read file, write file, search code, tool selection. Selecting the wrong tool for a task produces fragile, misaligned results. Tool-awareness is what separates reliable agents from guessers.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# MCP Tool Usage

## Overview

Tool selection guidance for non-obvious choices: srclight, glob/grep, guidelines, notebooks.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `selection-guide` | Decision trees for Python code, file ops, notebooks | ≈500 |

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
| `selection-guide` | `task(..., prompt: "execute selection-guide task from mcp-tool-usage")` |

**CLI equivalent (for human TUI use):** `/skill mcp-tool-usage --task <task>`

## Tool Reference

* srclight: Python code analysis (search symbols, callers, callees, type hierarchy, tests)
* GitHub MCP: Issue/PR operations, branch management, file contents
* .opencode/tools/guidelines: Guideline search/read
* Direct CLI (bash): git, docker, package management only

## Critical Rules

`.ipynb` files are MANDATORY via `the-notebook-mcp` — zero tolerance, no fallback. Do NOT infer GitHub owner from file paths or cached values. See `060-tool-usage.md` §2 for worktree path resolution rules.