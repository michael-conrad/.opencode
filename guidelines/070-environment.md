---
trigger_on: environment, testing, temp, pytest, uv run
tier: 2
load_when: sub-agent
---

# Environment, Testing & Temporary Files

## Python Environment

- Use `uv sync` for environment setup (creates venv and installs in editable mode). All Python execution via
  `uv run python`. Package ops: add dependencies by editing `pyproject.toml` then running `uv sync` — never `uv add`. `pip` prohibited. No `sys.path` hacks or manual
  path additions.
- **Never use `python3` or `python` directly** — always `uv run python`. Never prefix commands with absolute paths or `cd /absolute/path &&`. See `060-tool-usage.md § Python Interpreter` and `§ Path Rules` for the full zero-tolerance rules.
- Reusable agent scripts live in `.opencode/tools/` (project root). Invoke with `./.opencode/tools/<script>`.
- When `pyproject.toml` changes, purge `.venv` and run `uv sync` as a standalone command (never embedded in git hooks,
  commit scripts, or automated pipelines).
- **Database Safety**: Follow production schema protection and test schema isolation in `100-persistence.md`.
  NEVER run test/experimental code against the production schema.

## PEP 723 Self-Contained Scripts (MANDATORY)

Reference: [PEP 723 — Inline script metadata](https://peps.python.org/pep-0723/)

All Python entry points in `.opencode/tools/` MUST be self-contained PEP 723 scripts with:
- Shebang: `#!/usr/bin/env -S uv run --script`
- PEP 723 `# /// script` metadata block with `requires-python` and `dependencies`
- Zero dependency on project `pyproject.toml` or `uv.lock`
- Execute permission (`chmod +x`)

New tools MUST follow this pattern. Do NOT use `uv run python .opencode/tools/X`.

### Version Pinning (MANDATORY)

Every PEP 723 script MUST pin both `requires-python` and all `dependencies` using the `~=` compatible release operator:

- `requires-python`: MUST use `~=X.Y.0` (three-part version, e.g., `~=3.12.0`). Bare `>=` is prohibited (permits untested future Python versions). Bare `X.Y` is rejected by `uv`.
- `dependencies`: Each entry MUST use `~=` to constrain to a compatible release window (e.g., `pyyaml~=6.0`). Bare unversioned packages and `>=` are prohibited (permit untested major upgrades).

### Marker Validation

The ONLY standardized PEP 723 marker is `# /// script`. The deprecated `# /// pyproject.toml` marker is INVALID — tools MUST NOT read metadata blocks with non-standardized types. `uv` ignores blocks with the wrong marker, causing dependency installation to silently fail.

### Polyglot Bash Guard (MANDATORY)

Every PEP 723 script MUST include a polyglot bash guard as the second line, immediately after the shebang and before the PEP 723 header:

```python
#!/usr/bin/env -S uv run --script
"exec" "uv" "run" "--script" "$0" "$@" # MUST GO BEFORE PEP 723 HEADER

# PEP 723 HEADER MUST BE AFTER BASH GUARD
# /// script
# requires-python = "~=3.12.0"
# dependencies = ["pyyaml~=6.0"]
# ///
```

The guard prevents catastrophic failure when an agent or user invokes `bash <script>` instead of `uv run --script <script>` — bash sees `"exec" "uv" "run" "--script" "$0" "$@"` and replaces itself with `uv`, forwarding all arguments. Under Python, the guard is a bare string expression and is silently discarded.

### `# fmt: off` / `# fmt: on` Ruff Protection (MANDATORY)

`ruff format` interprets the bash guard line as a Python string expression and will corrupt it by stripping spaces between the quoted tokens, producing `"execuvrun--script$0$@"`. This renders the tool non-functional (cannot execute under bash).

**Every PEP 723 script MUST wrap the bash guard and PEP 723 header in `# fmt: off` / `# fmt: on` guards:**

```python
#!/usr/bin/env -S uv run --script
# fmt: off
"exec" "uv" "run" "--script" "$0" "$@" # MUST GO BEFORE PEP 723 HEADER

# PEP 723 HEADER MUST BE AFTER BASH GUARD
# /// script
# requires-python = "~=3.12.0"
# dependencies = ["pyyaml~=6.0"]
# ///

# fmt: on
```

- **`# fmt: off`** MUST be on line 2 (immediately after shebang)
- **`# fmt: on`** MUST be on the line after `# ///` (closing PEP 723 block), before any imports or code
- The `# fmt: on` guard MUST NOT be inside the PEP 723 TOML block — it goes AFTER `# ///`, not between `# /// script` and `# ///`
- Failure to include these guards WILL result in the bash guard being corrupted by `ruff format` during review-prep or any automated formatting pass

**Structure rules:**
- Line 1: `#!/usr/bin/env -S uv run --script` (only allowed shebang)
- Line 2: `# fmt: off` (ruff protection guard)
- Line 3: `"exec" "uv" "run" "--script" "$0" "$@" # MUST GO BEFORE PEP 723 HEADER` (bash guard)
- Lines 4-5: Comment line, PEP 723 header
- Lines 6-8: PEP 723 metadata block (`requires-python` with `~=X.Y.0`, `dependencies` with `~=` pins)
- Line 9: `# ///` (closing PEP 723)
- Line 10: `# fmt: on` (ruff protection guard off)
- After: blank line, then optional `from __future__` or `__doc__ = ` or imports

This error was discovered during audit of issue #980. Both `tools/plan` and `tools/solve` were affected.

Scripts that print `__doc__` at runtime MUST use `__doc__ = """..."""` assignment (not bare `"""..."""`) because the bash guard string captures the first docstring slot.

### --description Flag (MANDATORY)

Every tool in `tools/` MUST implement a `--description` flag that prints a one-line description of the tool's purpose to stdout and exits 0. This allows the `help` tool and other aggregators to discover tool descriptions without parsing source code.

For PEP 723 Python scripts (top of `main()`):

```python
if len(sys.argv) == 2 and sys.argv[1] == "--description":
    print("One-line description of the tool's purpose.")
    return 0
```

For bash scripts (top of script, before substantive logic):

```bash
if [[ "${1:-}" == "--description" ]]; then
    echo "One-line description of the tool's purpose."
    exit 0
fi
```

The description should be a single sentence stating what the tool does from the caller's perspective ("does X") rather than describing its implementation ("uses Y to do X").

## Isolated Tool Environments

When developing local tools that need their own dependencies (separate from the main project), use isolated tool environments to keep the main project's `pyproject.toml` clean.

### Directory Structure Pattern

```
project/
├── pyproject.toml          # Main project dependencies (kept clean)
├── src/
├── tools/                  # Isolated tool environment
│   ├── pyproject.toml      # Tool-specific dependencies
│   └── my_tool.py
```

The `tools/` directory contains its own `pyproject.toml` with only the dependencies needed by that tool. This keeps heavy or tool-specific dependencies isolated from the main project.

### Invocation Methods

**1. Ephemeral (recommended for one-time use):**

```bash
# Runs in temp venv, cleaned up after execution
uvx --from ./tools my-tool [args]

# Does NOT install globally, does NOT pollute main venv
```

**2. Persistent (for frequently-used tools):**

```bash
# Installs tool globally (available in any directory)
uv tool install ./tools

# Run from anywhere
my-tool [args]

# Uninstall when no longer needed
uv tool uninstall my-tool
```

### Benefits

- **Clean main dependencies**: Main project's `pyproject.toml` stays focused on production dependencies
- **Dependency isolation**: Tool conflicts don't affect the main project
- **No version conflicts**: Tool can use different versions of shared dependencies
- **Faster `uv sync`**: Main project re-sync is faster without tool dependencies
- **Portable**: Tool environment is self-contained and reproducible

### When to Use

Use isolated tool environments when:

- A local tool needs dependencies that are NOT useful for the main project
- You want to try a tool without committing it to `pyproject.toml`
- A tool requires mutually exclusive dependency versions
- You're developing a standalone utility that could be extracted later

Use direct `pyproject.toml` dependencies when:

- The dependency is needed for production code
- The dependency is needed by tests that run against production code
- The dependency is already in the main dependency tree

### Example: Local Analysis Tool

**tools/pyproject.toml:**

```toml
[project]
name = "analysis-tool"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [ "pandas>=2.0", "matplotlib>=3.7", "seaborn>=0.12",]

[project.scripts]
analyze = "analyze:main"
```

**tools/analyze.py:**

```python
def main():
    import pandas as pd
    import matplotlib.pyplot as plt
    # Tool implementation
```

**Usage:**

```bash
# Ephemeral (no install)
uvx --from ./tools analyze

# Persistent (global install)
uv tool install ./tools
analyze  # Available from any directory
```

This pattern is especially useful for data science tools, analysis scripts, and one-off utilities that would otherwise clutter the main dependency list.

## Node.js Prohibition

**DETESTABLE**: Installing Node.js in a Python-only or Java-only environment is absolutely prohibited. This introduces an unnecessary runtime dependency that pollutes the ecosystem and creates maintenance burden.

### 🚫 NEVER DO

- **NEVER install Node.js globally or locally** on Python-only or Java-only projects.
- **NEVER use NPX** to run packages — NPX requires Node.js runtime.
- **NEVER add Node.js-based tools to project dependencies.**
- **NEVER suggest npm packages as solutions** in Python/Java contexts.
- **NEVER use Node.js-based formatters, linters, or tooling** when native alternatives exist.

### Context

This rule applies universally to:

- **Python projects**: Use `uv`, `pip`, `ruff`, `pytest` — never npm/pnpm/yarn.
- **Java projects**: Use Maven/Gradle, JVM tooling — never npm/pnpm/yarn.
- **Projects with mixed languages**: Isolate Node.js to its designated frontend/service layer.

### ✅ ALLOWED

- **Docker containers that internally use Node.js** — Node.js runs inside container, not on host.
- **Pure Python alternatives** — `githubkit` instead of `@octokit/rest`, `httpx` instead of `axios`.
- **Dedicated frontend repositories** where Node.js IS the correct tool for that codebase.
- **MCP servers via Docker** — Node.js isolated in container only.

### Why This Is Critical

- **Security**: Node.js ecosystem has known supply-chain attack vectors.
- **Dependency bloat**: Adds unnecessary runtime and package manager complexity.
- **Maintenance burden**: Mixed language projects require additional CI/CD configuration.
- **Ecosystem mismatch**: npm packages don't integrate with Python/Java tooling chains.
- **Team friction**: Requires developers to install/maintain Node.js on their machines.

## Production System Protection

- **The AI agent is never permitted to run code against production data.** This is an absolute prohibition with no exceptions — not even for verification, inspection, or read-only queries. Any step that would execute code against production data requires explicit user instruction before execution.
- **DIAGNOSTIC REQUESTS ARE READ-ONLY:** When asked to "check error", "investigate bug", "review logs", or similar diagnostics, the agent MUST:
  1. Look for log files (`.log` files in `{project_root}/tmp/` or project directories)
  2. Read source code and error messages statically
  3. Analyze code paths without execution
  4. NEVER run the failing script, reproduce the error, or execute against production
- **BUG FIXES ARE CODE-ONLY:** When fixing a bug in production-touching code:
  1. Make the code fix
  2. Use static analysis (lint, typecheck) to verify syntax
  3. STOP — do not run the script against production to verify
  4. Ask user if they want to test/verify (they may provide a test fixture)
- **NEVER run any script, notebook, or command that connects to, reads from, or writes to a production data path**
  (e.g. `pubmed_data_3/db/`, any path outside `{project_root}/tmp/`) without explicit user authorization in the current session.
- This includes verification steps: do NOT run `pgserver_start.py`, `pgserver_stop.py`, or any script that starts,
  stops, or force-kills a PostgreSQL server process unless the user explicitly says to do so.
- Verification of script correctness must use static analysis (lint, grep, code review) or a dedicated test fixture
  with an isolated `{project_root}/tmp/` path — never the live production instance.
- **NEVER use production spec files (GitHub Issues) as smoke-test or verification targets.** Spec issues are authoritative tracking artifacts — they are never modified for testing purposes.
- **This applies to `.opencode/tools/` tool verification too.** When fixing or verifying any tool that mutates plan files,
  always create a throwaway plan copy in `{project_root}/tmp/` and run the tool against that copy. Never invoke a mutating tool
  against a live plan file as a "test" or "verification" step.
  To create a throwaway copy: `cp plans/SPEC-some-plan.md {project_root}/tmp/spec_test.md`, then pass
  `{project_root}/tmp/spec_test.md` to the tool. Discard after testing. Using `cp` to `{project_root}/tmp/` for this purpose is the one permitted exception to the
  raw-shell-command prohibition for plan files.
- Violating this rule can crash the production system and corrupt live data.

## Testing

- Use `unittest`. Run from root: `uv run python -m unittest tests/test_filename.py`.
- **NEVER run tests against production data or live data.** Tests must use isolated test fixtures with dedicated test databases (e.g., `PgServerManager` with a test schema). Running tests against production/live data is an absolute prohibition — no exceptions.
- **Never use SQLite for tests.** The project uses PostgreSQL-specific types (JSONB, Vector) that are incompatible with SQLite. All test database fixtures must use a real PostgreSQL instance (via `PgServerManager`).
- No regression tests unless explicitly requested. A regression test is a test added to prevent a previously fixed bug
  from reappearing; this rule does not prohibit new unit tests or reproduction scripts required by the current task.
  Temp test artifacts in `{project_root}/tmp/` only.
- If `SyntaxWarning: invalid escape sequence` appears in output, stop execution and fix the offending code before
  proceeding.

## Temporary Files

- All temp scripts/data/artifacts in `{project_root}/tmp/` ONLY. NO OTHER FOLDERS PERMITTED. **Never use `/tmp/` (system temp) or any other folder.** This includes any diagnostic or exploratory Python scripts — files named `temp_*.py`, `test_*.py` (outside `test/`), or similar one-off scripts must be placed in `{project_root}/tmp/`, never at the project root.
- **NO BOGUS PATHS**: Using relative paths that exit the current directory (e.g., `.{project_root}/tmp/`) in scripts or notebooks is **absolutely forbidden**. This creates brittle, non-portable code. All file system operations MUST use paths derived from `project_root` or `base_dir` (e.g., `project_root / 'tmp' / 'index.html'`) as provided by the project's standard utilities (e.g., `notebook_utils.py`).
- **Mandatory for CLI text updates:** Use `{project_root}/tmp/` to store input files for `.opencode/tools` text update tools to avoid shell escaping and newline issues.
- Project root must stay clean — no root-level temp files.
- **`.output.txt` files must be placed in `{project_root}/tmp/` (e.g., `{project_root}/tmp/.output.txt`), never at the project root (`.output.txt` is a violation).**
- **Mandatory pre-submit root cleanliness check:** Before calling `submit`, confirm the project root is clean:
  (1) Never create `.output.txt`, `temp_*.py`, or any other temp/diagnostic file at the project root — always use `{project_root}/tmp/` at time of creation.
  (2) Run `./.opencode/tools/file-exists .output.txt` — if it exists, move it to `{project_root}/tmp/.output.txt` immediately (`mv .output.txt {project_root}/tmp/.output.txt`).
  (3) Check for any `temp_*.py` files at the project root (`ls temp_*.py 2>/dev/null`) — if any exist, move them to `{project_root}/tmp/` before submitting.

### ⚠️ MANDATORY: Temp Files Cleanup After Task Completion

**Temp files MUST be cleaned up after every task — no exceptions.**

### ✅ ALWAYS DO — After Task Completion

1. **Remove temp scripts** — `rm {project_root}/tmp/temp_*.py` or `rm {project_root}/tmp/test_*.py`
2. **Remove temp data files** — `rm {project_root}/tmp/*.json {project_root}/tmp/*.csv {project_root}/tmp/*.html` (task-specific artifacts)
3. **Preserve persistent temp files** — Files intentionally kept for caching or future runs:
   - `{project_root}/tmp/*.db` (SQLite databases)
   - `{project_root}/tmp/*.log` (log files)
   - `{project_root}/tmp/.*` (hidden files like `.output.txt`)
4. **Verify cleanup** — `ls {project_root}/tmp/` should only show intentional persistent files

### 🚫 NEVER DO

- **NEVER leave temp files "for later cleanup"** — cleanup is mandatory, not optional
- **NEVER leave diagnostic scripts in `{project_root}/tmp/` after task ends** — delete immediately after use
- **NEVER defer cleanup** — it happens in the same session as task completion
- **NEVER delete persistent temp files** (`.db`, `.log`, hidden files) without explicit instruction

### Cleanup Commands

```bash
# Remove temporary scripts (safe for task artifacts)
rm {project_root}/tmp/temp_*.py {project_root}/tmp/test_*.py 2>/dev/null

# Remove temporary data files (safe for task artifacts)
rm {project_root}/tmp/*.json {project_root}/tmp/*.csv {project_root}/tmp/*.html 2>/dev/null

# List remaining files (should only show persistent ones)
ls {project_root}/tmp/
```

## Local LLM Agent (Ollama)

- **Location:** `local-agent-setup/uv-ollama/`
- **Start command:** run `bash local-agent-setup/uv-ollama/start-ollama-uv.sh` from the project root.
- **What it does:** installs `uv` locally (if absent), checks for a global Ollama binary (falls back to local download if not found), starts the Ollama server in the background, pulls `qwen2.5-coder:32b-instruct-q4_0`, and prints the API URL when ready.
- **API URL:** `http://127.0.0.1:11434`
- **PyCharm connection:** use the printed URL to configure the local AI assistant endpoint in PyCharm Settings.
- **Recommendation:** install Ollama globally (`curl -fsSL https://ollama.com/install.sh | sh`) before running the script — the global binary is preferred over the local download.

## PyCharm IDE

- No usability-conflicting shortcuts are enabled (e.g., double-Shift / Search Everywhere is disabled). Do not suggest
  shortcuts or navigation paths that depend on these features being active.
- For IDE settings, direct the user via **Settings** menus only — never via keyboard shortcuts that may be disabled.
- The **New UI is not in use** and must never be suggested. It is inaccessible and adversarial to the user's workflow.
  Always assume Classic UI.

## Markdown Formatting

- Use triple backtick fenced code blocks for all examples. No backslash escapes or HTML entities for backticks within
  fenced blocks.
- **Forbidden operation (Step-0205 hard rule)**: Do **not** execute any notebook that touches production data. This includes `the-notebook-mcp_notebook_execute_cell`, `pycharm_runNotebookCell`, or any execution method.
- **Global forbidden execution on production-touching workflows**: Never run full notebook/script execution commands for any notebook or script that touches production data. If verification is required, use non-executing inspection/read-only checks via `the-notebook-mcp` tools and production-safe alternatives only.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: environment-001
    title: "Never run code against production data — absolute prohibition"
    conditions:
      all:
        - "code_targets_production_data == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "070-environment.md §Production System Protection"

  - id: environment-002
    title: "Must use uv run for Python — never bare python"
    conditions:
      all:
        - "python_invocation_method == 'bare_python'"
    actions:
      - HALT
    conflicts_with: [tool-usage-005]
    requires: []
    triggers: []
    source: "070-environment.md §Python Environment"

  - id: environment-003
    title: "Node.js prohibited in Python/Java-only projects"
    conditions:
      all:
        - "project_language in ['Python', 'Java']"
        - "nodejs_install_attempted == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "070-environment.md §Node.js Prohibition"

  - id: environment-004
    title: "Temp files must use {project_root}/tmp/ only"
    conditions:
      all:
        - "temp_file_path matches '^/tmp/'"
    actions:
      - HALT
    conflicts_with: [critical-rules-004, tool-usage-004]
    requires: []
    triggers: []
    source: "070-environment.md §Temporary Files"

  - id: environment-005
    title: "Tests must never run against production data"
    conditions:
      all:
        - "test_targets_production_data == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "070-environment.md §Testing"

  - id: environment-006
    title: "Temp files must be cleaned up after task completion"
    conditions:
      all:
        - "task_completed == true"
        - "temp_files_remaining_in_tmp == true"
    actions:
      - CLEANUP
    conflicts_with: []
    requires: []
    triggers: []
    source: "070-environment.md §Temp Files Cleanup After Task Completion"

  - id: environment-007
    title: "PEP 723 self-contained scripts mandatory for .opencode/tools/"
    conditions:
      all:
        - "new_tool_in_opencode_tools == true"
        - "script_has_pep723_metadata == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "070-environment.md §PEP 723 Self-Contained Scripts"

  - id: environment-008
    title: "Polyglot bash guard mandatory on line 2 of all PEP 723 scripts"
    conditions:
      all:
        - "pep723_script_created_or_modified == true"
        - "bash_guard_missing_on_line_2 == true"
    actions:
      - HALT
    conflicts_with: []
    requires: [environment-007]
    triggers: []
    source: "070-environment.md §Polyglot Bash Guard (MANDATORY)"
```
