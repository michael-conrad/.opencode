<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
---
trigger_on: tool, local tool, isolated, project-local, .tools, .node
tier: 2
load_when: sub-agent
---

# Project-Local Isolated Tool Installation

## Principle

When a project requires build tools not available on the host system (e.g., `tsc`, `esbuild`, `sass`), the agent MAY install them **project-locally** — inside `.tools/<tool>/` (primary) or `.node/`, `.uv/`, `.jdk/` (acceptable alternatives). This is the exception to the global Node.js/runtime prohibition when the tool is needed for a TypeScript or build step within a Python/Java project. This guideline is the single canonical home for project-local tool installation rules — Read [020-go-prohibitions.md](020-go-prohibitions.md) for the authorization-law core that governs when file modifications are permitted at all.

## Rules

### ✅ REQUIRED

- **Primary pattern**: `.tools/<tool>/` (e.g., `.tools/node/`, `.tools/jdk/`)
- **Acceptable alternatives**: `.node/`, `.uv/`, `.jdk/`
- **Gitignored**: `.tools/`, `.node/`, `.uv/`, `.jdk/` MUST be in `.gitignore` — never tracked
- **Never tracked**: These directories MUST NEVER be committed to git
- **PATH-prefixed invocation**: Tools are invoked via prefixed PATH, e.g. `PATH=.tools/node/bin:$PATH npx tsc --noEmit`
- **Never modifies project config**: No changes to `pyproject.toml`, `package.json`, or any project configuration
- **System-isolated**: MUST NOT install to `~/.local/`, `/usr/local/`, or any system-level path
- **No system PATH pollution**: The `.tools/` directory must never be added to `$HOME/.bashrc`, `$HOME/.profile`, `$HOME/.zshenv`, or any user shell config
- **Cleanable**: `rm -rf .tools/` (or `.node/`, `.uv/`, `.jdk/`) removes everything — no trace left on the system

### 🚫 FORBIDDEN

- Installing Node.js/Java/other runtimes globally
- Committing `.tools/`, `.node/`, `.uv/`, or `.jdk/` directories
- Modifying project config files to reference local tools
- Adding local tool directories to shell profiles or system PATH

## Invocation Examples

```bash
# TypeScript type checking with project-local Node
PATH=.tools/node/bin:$PATH npx tsc --noEmit

# TypeScript type checking with .node/ alternative
PATH=.node/bin:$PATH npx tsc --noEmit

# Installing Node.js locally via nvm-style pattern
mkdir -p .tools && cd .tools && curl -fsSL https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz | tar xJ && mv node-v20.11.0-linux-x64 node
```

## Relationship to Other Guidelines

- Read [020-go-prohibitions.md](020-go-prohibitions.md) — authorization-law core (this guideline holds the full project-local tool rules)
- Read [§2](060-tool-usage.md) — Path Rules (project-local tools follow worktree path resolution)
- Read [§4](060-tool-usage.md) — Command Restrictions (sed/printf/heredoc prohibitions apply)
