# Scripting Standards

## Script Headers (mandatory)

Every script/notebook MUST include root resolution:

- **Shell**: `_root="$(cd "$(dirname "$0")" && while [ "$(pwd)" != "/" ]; do [ -d ".opencode" ] && echo "$(pwd)" && break; cd ..; done)"` — if empty, `exit 1`
- **Python**:
  ```python
  def _find_project_root() -> Path:
      current = Path(__file__).resolve().parent
      while current != current.parent:
          if (current / ".opencode").is_dir():
              return current
          current = current.parent
      raise RuntimeError("Could not find project root (no .opencode/ directory found)")

  PROJECT_ROOT = _find_project_root()
  ```
- **Notebooks**: Set `base_dir` using Jupyter's directory hint:
  `base_dir = Path(globals()['_dh'][0])`. Add a comment noting this uses `_dh[0]` (Jupyter's directory hint) to locate
  the notebook's directory reliably without relying on CWD.

## Self-Location & Root Resolution

- Scripts self-locate via `dirname "$0"` (Shell) or `Path(__file__).resolve().parent` (Python). No reliance on user's
  CWD.
- Resolve project root by walking up from the script's location until a directory containing `.opencode/` is found. This works correctly in both standalone repos and git submodules without relying on `git` being available or correct remote configuration.
- `git rev-parse --show-cdup` is **prohibited** — it returns empty string inside submodules, causing path doubling bugs.
- `git rev-parse --show-toplevel` is **prohibited** — inside a submodule it returns the submodule root, not the project root.
- `git rev-parse --show-superproject-working-tree` is **prohibited** — it depends on git remote configuration and fails when git is unavailable or misconfigured. Walk-up-directory detection via `.opencode/` is more reliable.

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
    title: "Scripts must self-locate and resolve project root via _find_project_root walk-up"
    conditions:
      all:
        - "script_created == true"
        - "has_root_resolution == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "210-scripting.md §Script Headers, Self-Location"

  - id: scripting-005
    title: "Never use git rev-parse for root resolution (submodule and git-unavailable breakage)"
    conditions:
      any:
        - "code_contains == 'rev-parse --show-cdup'"
        - "code_contains == 'rev-parse --show-toplevel'"
        - "code_contains == 'rev-parse --show-superproject-working-tree'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "210-scripting.md §Self-Location & Root Resolution"

  - id: scripting-006
    title: "Scripts must use _find_project_root walk-up pattern, not git commands"
    conditions:
      all:
        - "script_created == true"
        - "root_resolution_uses_git == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "210-scripting.md §Self-Location & Root Resolution"
```
