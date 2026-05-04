---
name: mcp-tool-usage
description: Use when selecting tools for file operations, code search, or any task that could use multiple tool options. Triggers on: which tool, tool priority, MCP, PyCharm, JetBrains, read file, write file, search code, tool selection.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# MCP Tool Usage

## Overview

Tool Priority Enforcer ensuring all operations use the correct tool according to the five-tier hierarchy. Defines PRIMARY, FALLBACK, and PROHIBITED tools for each operation type. Zero tolerance for `.ipynb` files.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `selection-guide` | Decision trees for Python code, file ops, notebooks | ≈500 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `pre-analysis` | Before any execution sub-agent dispatch, determine scope independently | Issue number, task description, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `selection-guide` | When tool selection guidance is needed for file operations, notebooks, or code search | Operation type, file extension, project context | Implementation context, agent memory | NO |

## Invocation

- `/skill mcp-tool-usage --task selection-guide` - Tool selection decision trees
- `/skill mcp-tool-usage` - Overview only

## Operating Protocol

1. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Five-Tier Tool Priority Hierarchy

```
TIER 1 — PRIMARY: opencode built-in tools (read/write/edit/glob/grep)
TIER 2 — PRIMARY: Domain MCP (srclight, the-notebook-mcp, GitHub MCP)
TIER 3 — PRIMARY: .opencode/tools/ (guidelines, md, memory, py ls/mkpkg)
TIER 4 — FALLBACK: JetBrains MCP (pycharm_*) — only for unique capabilities
TIER 5 — LAST RESORT: Direct CLI (bash)

ABSOLUTE EXCEPTION: .ipynb files → the-notebook-mcp MANDATORY (zero tolerance, no fallback)
```

### TIER 1: opencode Built-in Tools (PRIMARY for basic file ops)

| Operation | Tool |
|-----------|------|
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
|------|--------|
| `guidelines` | Guideline search/read (only tool that parses `.opencode/guidelines/` correctly) |
| `md` | Markdown section operations |
| `py ls` | Python package listing |
| `py mkpkg` | Python package creation |
| `memory` | Session memory management |

### TIER 4: JetBrains MCP (FALLBACK — unique capabilities only)

Semantic rename, code reformat, build project, inspections, run configs, directory tree, create file.

**NOT used for:** basic file reads, writes, edits, searches, or globs — TIER 1 handles those.

### TIER 5: Direct CLI (LAST RESORT)

Bash/shell commands ONLY when no other tool covers the operation or it's inherently a shell operation (git, docker, package management).

## Critical Rules

`.ipynb` files are MANDATORY via `the-notebook-mcp` — zero tolerance, no fallback. Do NOT infer GitHub owner from file paths or cached values. See `060-tool-usage.md` §2 for worktree path resolution rules and `notebook-operations` skill for complete notebook zero-tolerance rules.