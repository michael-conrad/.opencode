---
trigger_on: script, scripting, script header, shebang, bash
tier: 2
load_when: sub-agent
---

# Scripting Standards

## Script Headers (mandatory)

Every script/notebook MUST include root resolution:

  - **Shell:** Walk up from script location until the current directory is named `.opencode`; the project root is the parent:
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_DIR="$SCRIPT_DIR"
  while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
      PARENT="$(dirname "$PROJECT_DIR")"
      if [ "$PARENT" = "$PROJECT_DIR" ]; then
          echo "FATAL: Could not find .opencode/ directory" >&2
          exit 1
      fi
      PROJECT_DIR="$PARENT"
  done
  PROJECT_DIR="$(dirname "$PROJECT_DIR")"
  ```

- **Python:**
  ```python
  from pathlib import Path
  _path = Path(__file__).resolve().parent
  while _path.name != ".opencode":
      parent = _path.parent
      if parent == _path:
          raise RuntimeError("Could not find .opencode/ directory")
      _path = parent
  PROJECT_DIR = _path.parent
  ```

- **Notebooks**: Set `base_dir` using Jupyter's directory hint:
  `base_dir = Path(globals()['_dh'][0])`. Add a comment noting this uses `_dh[0]` (Jupyter's directory hint) to locate
  the notebook's directory reliably without relying on CWD.

## Self-Location & Root Resolution

- Scripts self-locate via `dirname "${BASH_SOURCE[0]}"` (Shell) or `Path(__file__).resolve().parent` (Python). No reliance on user's CWD.
- **Canonical method (REQUIRED for all scripts):** Walk up from script location until the current directory is named `.opencode`. The parent of `.opencode/` is the project root. This method works correctly whether `.opencode/` is a git submodule or a tracked directory.
- **Zero shared functions.** Every script inlines its own walk-up loop. No imports, no source, no `sys.path` manipulation for root detection.
- **The walk-up loop is the ONLY permitted root detection method.** No exceptions, except for git hooks (see below).
- **Filesystem-root guard REQUIRED:** Every walk-up loop MUST include a guard detecting when the traversal reaches the filesystem root (`/`). If `.opencode/` is unreachable, the script MUST fail with an explicit error rather than hanging. See canonical patterns below for the required guard implementation.

## Hooks Exception

Git hooks execute from `.git/hooks/`, which is outside the `.opencode/` tree. The walk-up-to-`.opencode` pattern cannot resolve correctly in hook context because hooks are structurally separate from all other `.opencode/` scripts.

**For hook files ONLY (`pre-commit`, `pre-push`, `pre-merge-commit`, `prepare-commit-msg`, `post-commit`):**
- `git rev-parse --show-toplevel` is PERMITTED for project root detection
- Hooks are repo-scoped by definition — `--show-toplevel` correctly returns the repo root
- All other `.opencode/` scripts continue to use the walk-up pattern exclusively

This exception is narrow and intentional: hooks are the only scripts that do not execute from inside `.opencode/`.

## Prohibited Patterns (ZERO TOLERANCE)

These root resolution methods are forbidden in ALL `.opencode/` scripts:

- `git rev-parse --show-cdup` — fails in submodule context
- `git rev-parse --show-toplevel` — returns submodule root, not parent repo root
- `../..` or deeper relative traversals from `BASH_SOURCE`/`__file__` (e.g., `dirname "${BASH_SOURCE[0]}"/../..`)
- `.parent.parent` (or deeper) chains in Python (e.g., `Path(__file__).resolve().parent.parent.parent`)
- `sys.path.insert` or `sys.path.append` for enabling root detection imports
- Any shared or imported function for root detection
- `.git` directory walking to determine project root

## Notebook Operations — MANDATORY MCP

**ALL notebook operations MUST use `the-notebook-mcp` tools.** See `notebook-operations` skill for the complete tool reference.

### ✅ MANDATORY

- Use `the-notebook-mcp_notebook_read` to read notebook content
- Use `the-notebook-mcp_notebook_read_cell` to read specific cell source
- Use `the-notebook-mcp_notebook_edit_cell` to edit cell source
- Use `the-notebook-mcp_notebook_add_cell` to add new cells
- Use `the-notebook-mcp_notebook_get_outline` to get notebook structure
- Use `the-notebook-mcp_notebook_delete` to delete notebooks (for retirement)
- Use `the-notebook-mcp_notebook_rename` to move notebooks (for archival)

### 🚫 FORBIDDEN

- `nbformat` direct access
- Jupyter Server REST API
- Any file tool (`read`/`edit`/`write`) on `.ipynb` files
- `.opencode/tools/nb` (removed — use `the-notebook-mcp` exclusively)

### Notebook Cell Edit Workflow

When editing a notebook cell:

1. **Read**: `the-notebook-mcp_notebook_read_cell(notebook_path="...", cell_index=N)` — get current cell source
2. **Edit**: Modify source as needed
3. **Update**: `the-notebook-mcp_notebook_edit_cell(notebook_path="...", cell_index=N, source="new source")`

### Retiring Notebooks

To retire a notebook:

1. Add a deprecation warning cell using `the-notebook-mcp_notebook_add_cell`
2. Move notebook to archive directory using `git mv`
3. Or delete entirely using `the-notebook-mcp_notebook_delete`

### Swap and Reorder Workflows

**Swap two cells** (indices `i < j`): Move cell `i` to `j`, then move cell `j-1` to `i`.

**Reorder cells**: Sequence of `move_cell` operations from target layout backward.

**If `the-notebook-mcp` is unavailable, REFUSE all notebook operations.** See `notebook-operations` skill for the no-fallback policy and detailed workflows.

## Command Restrictions

- Strictly follow all command and path restrictions defined in `060-tool-usage.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: scripting-001
    title: "All notebook operations must use the-notebook-mcp"
    conditions:
      all:
        - "file_type == '.ipynb'"
        - "tool not in ['the-notebook-mcp_notebook_read', 'the-notebook-mcp_notebook_read_cell', 'the-notebook-mcp_notebook_edit_cell', 'the-notebook-mcp_notebook_add_cell', 'the-notebook-mcp_notebook_get_outline', 'the-notebook-mcp_notebook_delete', 'the-notebook-mcp_notebook_rename']"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [notebook-operations]
    source: "210-scripting.md §Notebook Operations"

  - id: scripting-002
    title: "No direct nbformat or file tool access on ipynb files"
    conditions:
      any:
        - "tool == 'nbformat'"
        - "tool == 'read' AND file_type == '.ipynb'"
        - "tool == 'edit' AND file_type == '.ipynb'"
        - "tool == 'write' AND file_type == '.ipynb'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [notebook-operations]
    source: "210-scripting.md §FORBIDDEN"

  - id: scripting-003
    title: "Refuse notebook operations when the-notebook-mcp unavailable"
    conditions:
      all:
        - "the-notebook-mcp_available == false"
        - "notebook_operation_requested == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [notebook-operations]
    source: "210-scripting.md §Notebook Operations"

  - id: scripting-004
    title: "Scripts must use walk-up-to-.opencode pattern for root resolution"
    conditions:
      all:
        - "script_created == true"
        - "has_walk_up_root_resolution == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "210-scripting.md §Script Headers, Self-Location"

  - id: scripting-005
    title: "Prohibited root detection patterns — no git rev-parse, no depth counting, no sys.path hacks"
    conditions:
      any:
        - "code_contains == '--show-cdup'"
        - "code_contains == '--show-toplevel'"
        - "code_contains == '.parent.parent'"
        - "code_contains == 'sys.path.insert'"
        - "code_contains == 'sys.path.append'"
        - "code_contains == '.git'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "210-scripting.md §Prohibited Patterns"
```
