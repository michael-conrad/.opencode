---
name: mcp-tool-usage
description: "Use when selecting tools for file operations, code search, or any task that could use multiple tool options. Tool selection MUST follow the five-tier priority hierarchy — always required."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# MCP Tool Usage

## Overview

Tool Priority Enforcer ensuring all operations use the correct tool according to the five-tier hierarchy. Defines PRIMARY, FALLBACK, and PROHIBITED tools for each operation type. Zero tolerance for `.ipynb` files.

## Persona

Tool selector. Routes tool selection decisions to sub-agents that independently assess the five-tier hierarchy against the task at hand. An orchestrator that selects tools inline instead of dispatching to a tool-selection sub-agent has produced a memory-based choice, not a hierarchy-enforced selection — every tool decision carries the orchestrator's cached preference rather than an independent tier assessment. Professional tool selectors dispatch to hierarchy-aware sub-agents. Inlining means tool selection was never independently validated against the tier hierarchy.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "tool selection" / "which tool" / "MCP guidance" | `selection-guide` | `sub-task` | {operation_type, file_extension} |

## Tasks

| Task | Purpose |
|------|---------|
| `selection-guide` | Decision trees for Python code, file ops, notebooks |

## Sub-Agent Tasks

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `pre-analysis` | Before any sub-agent routing, determine scope independently | Issue number, task description, audit_phase, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `selection-guide` | When tool selection guidance is needed for file operations, notebooks, or code search | Operation type, file extension, project context | Implementation context, agent memory | NO |

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Invocation

`skill({name: "mcp-tool-usage"})` — call the skill, then call via task():

| Task | Call via task() |

| `selection-guide` | `task(..., prompt: "execute selection-guide task from mcp-tool-usage")` |

**CLI equivalent (for human TUI use):** `/skill mcp-tool-usage --task <task>`

## Five-Tier Tool Priority Hierarchy

```
TIER 1 — PRIMARY: opencode built-in tools (read/write/edit/glob/grep)
TIER 2 — PRIMARY: Domain MCP (srclight, the-notebook-mcp, GitHub MCP)
TIER 3 — PRIMARY: .opencode/tools/ (guidelines, md, py ls/mkpkg)
TIER 4 — FALLBACK: JetBrains MCP (pycharm_*) — only for unique capabilities
TIER 5 — LAST RESORT: Direct CLI (bash)

ABSOLUTE EXCEPTION: .ipynb files → the-notebook-mcp MANDATORY (zero tolerance, no fallback)
```

### TIER 1: opencode Built-in Tools (PRIMARY for basic file ops)

| Operation | Tool |

| Read file | `read` |
| Write file | `write` |
| Edit file | `edit` |
| Find files | `glob` |
| Search text | `grep` |

**Exception:** `.ipynb` files — use `the-notebook-mcp` exclusively.

### TIER 2: Domain MCP (PRIMARY for their specialties)

- **srclight**: Python code analysis (search symbols, callers, callees, type hierarchy, tests)
- **the-notebook-mcp**: All notebook operations (zero tolerance, no fallback)
- **GitHub MCP**: Issue/PR operations, branch management, file contents

### TIER 3: .opencode/tools/ Scripts (PRIMARY for their domains)

| Tool | Domain |

| `guidelines` | Guideline search/read (only tool that parses `.opencode/guidelines/` correctly) |
| `md` | Markdown section operations |
| `py ls` | Python package listing |
| `py mkpkg` | Python package creation |

### TIER 4: JetBrains MCP (FALLBACK — unique capabilities only)

Semantic rename, code reformat, build project, inspections, run configs, directory tree, create file.

**NOT used for:** basic file reads, writes, edits, searches, or globs — TIER 1 handles those.

### TIER 5: Direct CLI (LAST RESORT)

Bash/shell commands ONLY when no other tool covers the operation or it's inherently a shell operation (git, docker, package management).

## Critical Rules

`.ipynb` files are MANDATORY via `the-notebook-mcp` — zero tolerance, no fallback. Do NOT infer GitHub owner from file paths or cached values. See `060-tool-usage.md` §2 for worktree path resolution rules and `060-tool-usage.md` §1 for notebook MCP mandate.