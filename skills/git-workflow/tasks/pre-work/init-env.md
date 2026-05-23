# Sub-Task: pre-work/init-env

## Purpose

Environment initialization IS the prerequisite for reproducible work. Uninitialized submodules produce phantom file states.

## Entry Criteria

- Feature branch created (create-branch completed)
- Branch environment verified
- Submodule operations completed (if applicable)

## Procedure

### Step 1: Initialize Srclight Index

Ensure the code knowledge base is indexed for the current codebase state:

```bash
# Verify srclight is indexed
srclight index_status
```

If the index is stale or missing, trigger re-indexing:

```bash
srclight reindex
```

Report index status in the yield output.

### Step 2: Initialize Project Dependencies

Set up project dependencies for the current environment:

```bash
# Python projects
uv sync

# Node.js projects (if applicable and project-local)
PATH=.tools/node/bin:$PATH npm install
```

Use project-local tool paths per `085-project-local-tools.md`. Do NOT install tools globally.

### Step 3: Verify Development Toolchain

Confirm essential development tools are available and functional:

| Tool | Purpose | Verification |
|------|---------|-------------|
| `uv` | Package management | `uv --version` |
| `ruff` | Linting/formatting | `uvx ruff --version` |
| `pyright` | Type checking | `uvx pyright --version` |
| `srclight` | Code navigation | `srclight index_status` |
| `local-issues` | Issue tracking | `local-issues --help` |

If any essential tool is missing, report in yield output. Missing tools are not necessarily blocking — report and let orchestration layer decide.

### Step 4: Verify Hooks Installation

Pre-commit and other git hooks should be functional:

```bash
# Check hooks exist
ls -la .git/hooks/ | head -20
```

Hooks are installed by `session-enforcement.ts` at session start. If hooks are missing, report in yield output.

### Step 5: Yield Environment State

```yaml
status: success
srclight_indexed: true|false
dependencies_installed: true|false
toolchain_verified: true|false
hooks_installed: true|false
missing_tools: <list or empty>
ready_for: implementation
```

## Exit Criteria

- Srclight index verified (stale is acceptable, missing is reported)
- Project dependencies installed
- Development toolchain verified
- Hooks installation status confirmed
- Environment ready for implementation work

## Task Context Rules

- **must_receive**: `branch`, `worktree.path` (if worktree mode)
- **must_not_receive**: Implementation context, expected outcomes, orchestrator reasoning

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)