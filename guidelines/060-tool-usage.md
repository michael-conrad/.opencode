---
trigger_on: tool, path rule, temp file, command restriction, file operation
tier: 1
load_when: sub-agent
---

# Tool Usage & Terminal Rules

## 0. Progressive Disclosure — Index-Only Orchestrator Context

**CRITICAL:** Full guideline content lives exclusively in ephemeral sub-agent context windows — loaded fresh on demand and discarded. The orchestrator holds only `.opencode/guidelines/INDEX.md` (trigger-pattern pairs, ≤1,500 words) for routing decisions. Never load full guideline bodies into orchestrator context.

### Loading Protocol

1. **In orchestrator context:** Use INDEX.md for trigger-pattern matching — route to sub-agent based on matching triggers
2. **In sub-agent context:** Load individual guidelines via `./.opencode/tools/guidelines read <filename>` when needed
3. **Default load set:** `000-critical-rules.md` is loaded when sub-agent performs safety-critical operations; other guidelines loaded per trigger match

## 1. Tool Priority Hierarchy

> **See `mcp-tool-usage` skill for the complete five-tier hierarchy with tool selection tables.**

### Tier Summary

```
TIER 1 — PRIMARY: opencode built-in tools (read/write/edit/glob/grep)
TIER 2 — PRIMARY: Domain MCP (srclight, the-notebook-mcp, GitHub MCP)
TIER 3 — PRIMARY: .opencode/tools/ (guidelines, md, memory, py ls/mkpkg, ollama-probe, ollama-model-resolve)
TIER 4 — FALLBACK: JetBrains MCP (pycharm_*) — only for unique capabilities
TIER 5 — LAST RESORT: Direct CLI (bash)

ABSOLUTE EXCEPTION: .ipynb files → the-notebook-mcp MANDATORY (zero tolerance, no fallback)
```

### 🚫 PROHIBITED (Hard stop violation)

- ANY direct access to `.ipynb` files (use `the-notebook-mcp` exclusively)
- JetBrains MCP for basic file operations that opencode built-in tools handle (TIER 1 covers read/write/edit/glob/grep for all non-notebook files)

### API Client Mandatory (ZERO TOLERANCE)

When a platform has a dedicated API client (e.g., `gitbucket-api` CLI tool at `.opencode/tools/gitbucket-api`, GitHub MCP), the agent MUST use it for ALL operations. If the client lacks a needed method:

1. HALT
2. Report: executive summary of what was needed, the missing method name, possible resolution
3. Include byline
4. Do NOT bypass the client with raw `requests` calls or `python -c` inline scripts

## 1. Guidelines Lookup

### ✅ ALWAYS DO

- **Reading or searching guideline files MUST use `./.opencode/tools/guidelines`** — never raw `open`, `cat`, or `grep` on `.opencode/guidelines/` files.
- `./.opencode/tools/guidelines read <filename>` — print a single guideline file.
- `./.opencode/tools/guidelines search <term>` — search all guideline files for a term.
- `./.opencode/tools/guidelines search <term> --file <filename>` — search within one file.

### ⚠️ ASK FIRST

- Significant edits to core guideline files.

### 🚫 NEVER DO

- Use `open`, `cat`, or `grep` on `.opencode/guidelines/` files directly.

## 2. Path Rules (ZERO TOLERANCE)

### 🚫 NEVER DO

- **ABSOLUTE PATHS ARE FORBIDDEN IN ALL AGENT TERMINAL COMMANDS.** Never pass a path beginning with `/` to any terminal command or tool parameter.
- Never issue a `cd` command. Run all commands from project root using relative paths.
- **NEVER prefix commands with `cd /home/<user>/git/<repo> &&` or any variant.**

### ⚠️ Worktree Path Resolution for File Operation Tools (CRITICAL)

When working in a git worktree (`worktree.path` is set), TIER 1 file operation tools (`read`, `edit`, `write`, `glob`, `grep`) do **NOT** have a `workdir` parameter. Relative paths like `src/main.py` resolve to the **main repo**, not the worktree. This causes silent file operation errors — edits go to the wrong file.

**When `worktree.path` is set, ALL file operations MUST prefix paths with the worktree path:**

| Tool | Wrong (operates on main repo) | Correct (targets worktree) |
| -- | -- | -- |
| `read` | `read(filePath="src/main.py")` | `read(filePath=f"{worktree.path}/src/main.py")` |
| `edit` | `edit(filePath="src/main.py", ...)` | `edit(filePath=f"{worktree.path}/src/main.py", ...)` |
| `write` | `write(filePath="src/new.py", ...)` | `write(filePath=f"{worktree.path}/src/new.py", ...)` |
| `glob` | `glob(pattern="src/**/*.py")` | `glob(pattern="src/**/*.py", path=worktree.path)` |
| `grep` | `grep(pattern="TODO", path="src/")` | `grep(pattern="TODO", path=f"{worktree.path}/src/")` |

**When NOT in a worktree** (working in main repo): Relative paths are correct and function as expected.

**For `bash` tool:** Continue using `workdir` parameter (already documented in `using-git-worktrees` skill and `000-critical-rules.md`).

### `.issues/` Worktree Exemption (CRITICAL)

`.issues/` files are non-behavioral metadata (issue specs, comments, frontmatter). They are **exempt from the worktree requirement** — agents MAY create, read, edit, and update `.issues/` files without setting up a worktree first.

**However**, the **branching requirement still applies**: `.issues/` files MUST NOT be committed directly to `dev` or `main`. All `.issues/` changes require a feature branch (or pair-mode branch).

| Rule | `.issues/` files | Source code files |
|------|-------------------|-------------------|
| Worktree required? | NO (exempt) | Only when `WORKTREE_REQUIRED` set (default: NO) |
| Feature branch required? | YES | YES |
| Can commit to `dev`/`main`? | NO | NO |

**Rationale:** `.issues/` files are local workspace metadata, not executable code. Edits to `.issues/` cannot break builds, tests, or deployments. However, they are tracked in git (so devs can resume work on another machine), so branch hygiene still matters.

## 3. Temp Files & Cleanliness

### ✅ ALWAYS DO

- All temporary scripts and output files MUST be written ONLY to `./tmp/` (project root). NO OTHER FOLDERS OR PATHS ARE PERMITTED.
- Create the directory if needed: `mkdir -p ./tmp`.
- **Mandatory pre-submit root cleanliness check:** Before calling `submit`, run `./.opencode/tools/file-exists .output.txt` and confirm it is MISSING. If it exists, move it to `./tmp/.output.txt` immediately.
- **ALWAYS clean up temp files after modification tasks are complete.**

### 🚫 NEVER DO

- **ZERO TOLERANCE — NEVER use or access any other folder (e.g., `/tmp/`, `.tmp/`, etc.) for any reason.** Only `./tmp/` is permitted.

## 4. Command Restrictions & Quality

### ✅ ALWAYS DO

- **ALWAYS use `uv run python` to invoke Python.**
- **Fixed sleep value for polling**: Always use a fixed value of `15`.
- **One clear command per invocation.** A short `&&` guard is acceptable.
- **Use built-in Edit/Write tools for file modifications.** For Jupyter notebooks, use `the-notebook-mcp` tools exclusively — see `notebook-operations` skill.

### 🚫 NEVER DO

- No `stty` (hangs non-interactive sessions).
- No destructive checkouts (`git checkout` files).
- No embedded scripts via heredocs — use standalone script files in `./tmp/`.
- No repeated or iterative `grep`/`zgrep`/`egrep`/`sed` searches. Use `search_project`.
- **ZERO TOLERANCE — `sed -i`, `printf` (for editing or creation), `echo` redirection, and heredocs are absolutely forbidden.**
- **ZERO TOLERANCE — NEVER edit or modify production data or database seed files.** All changes to production data MUST be performed by a human developer.
- **Multi-line shell loops are strictly forbidden.** Never use `for`, `while`, or `until`.
- **NEVER use `sed` for file edits — it is unreliable for structured formats.** The Edit tool handles escaping and encoding correctly; sed does not.
- **NEVER use `--recursive` with any git submodule command** (e.g., `git submodule update --init --recursive`, `git clone --recursive`). The `--recursive` flag can pull in unintended nested submodules, cause unexpected network traffic, break reproducibility by implicitly resolving submodule chains, and conflict with explicit submodule management. Always use `git submodule update --init` (without `--recursive`) or explicit per-submodule operations.

## 5. Verification & Audit

### ✅ ALWAYS DO

- Verify file/path claims with a tool call (`ls`, `open`, `search_project`).
- If a tool call fails or is inconclusive, retry with a different tool.
- For plan audits, validate only the specific anchor needed for the current phase/step/checklist item.

### 🚫 NEVER DO

- Do not run bulk path-audit sweeps.

## 6. File Renaming

- When renaming a file and the developer does not specify the new name, infer the best semantic name based on the file's actual content and purpose — do not ask for clarification.

## 7. Todowrite Lifecycle Management

When the `todowrite` tool is used during a session, the agent MUST maintain the full lifecycle for every item. Failure to do so is a critical violation — see `000-critical-rules.md` → "Stale Todowrite State After Task Completion".

### ✅ ALWAYS DO

- **CREATE**: When `todowrite` is invoked, every item MUST have an explicit `status` field: `pending`, `in_progress`, or `completed`
- **UPDATE**: Each item MUST transition to `in_progress` when work on that item begins, and to `completed` when the item is fully done
- **CLEAR**: `todowrite(todos=[])` MUST be called when the task completes — this is required before any HALT

### 🚫 NEVER DO

- Leave items in `pending` or `in_progress` status after task completion
- Halt a session without calling `todowrite(todos=[])` to clear state
- Create items without a `status` field
- Skip status transitions (e.g., jump from `pending` directly to `completed` without `in_progress`)

## 8. Skill Dispatch Principle

Invoke skills when their trigger keywords match the current task. Each skill defines explicit trigger patterns in its SKILL.md frontmatter (`Triggers on:` line). Match against those patterns, not against mere possibility.

| Principle | Rule |
|-----------|------|
| **Trigger matching** | Skills apply when their frontmatter `Triggers on:` keywords match the current task |
| **Priority ordering** | Process skills (approval-gate, brainstorming, writing-plans, systematic-debugging) before implementation skills |
| **No speculative loading** | Do not load skills "just in case" — load when triggers match |
| **Skill self-describes boundary** | Each SKILL.md defines what it covers; when in doubt, check `Triggers on:` line |
| **Sub-agent dispatch priority** | When a SKILL.md Sub-Agent Tasks section marks a task as `sub-agent`, the main agent dispatches via `task()` instead of loading the task file inline. This keeps heavy task files out of the main agent context. Result contracts (≈100-500 words) are read instead of the full task file (>1,000 words) |

## 9. Identity Source Semantics

The `github.identity_source` value (emitted by session-init) determines the agent's relationship to git remotes and GitHub API routing.

| `identity_source` | Routing Description |
|---|---|
| `root` | Standard workflow — parent repo has a remote, owner/repo from parent remote. All git operations work normally through the parent repo. |
| `submodule` | Submodule-local mode — parent repo has ZERO remotes by design. All remote git operations (fetch, pull, push, remote branch management) must run from inside the submodule directory, not the project root. The submodule path is the only path to the remote repository. Do NOT add remotes to the parent repo. Do NOT push from the parent repo. |
| `none` | Full local-only mode — no remote exists anywhere. All remote git operations (fetch, pull, push) will fail. No GitHub or GitBucket API calls are possible. Do NOT add remotes. |

**When `identity_source == "submodule"`:**

- The parent repo has ZERO remotes by design — do NOT add remotes
- `github.owner` and `github.repo` come from the submodule's remote for API routing only
- GitHub MCP calls route to the submodule's repository, not the parent
- Local git operations (branch, commit, stash) on the parent repo are permitted
- `git push` from the parent repo is FORBIDDEN — there is no remote to push to
- `git remote add` on the parent repo is FORBIDDEN — the absence of remotes is intentional |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: tool-usage-001
    title: "Notebook files require the-notebook-mcp exclusively"
    conditions:
      all:
        - "file_extension == '.ipynb'"
        - "using_notebook_mcp == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [notebook-operations]
    source: "060-tool-usage.md §1 Tool Priority Hierarchy"

  - id: tool-usage-002
    title: "Absolute paths forbidden in agent terminal commands"
    conditions:
      all:
        - "terminal_command_matches == '/^[a-zA-Z0-9_-]+:.*|^/'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "060-tool-usage.md §2 Path Rules NEVER DO"

  - id: tool-usage-003
    title: "Worktree path prefixing required for file operations when worktree.path set"
    conditions:
      all:
        - "worktree_path_is_set == true"
        - "using_relative_paths_for_file_ops == true"
    actions:
      - HALT
    conflicts_with: [critical-rules-007]
    requires: []
    triggers: [using-git-worktrees]
    source: "060-tool-usage.md §2 Worktree Path Resolution"

  - id: tool-usage-004
    title: "Only ./tmp/ permitted for temp files"
    conditions:
      all:
        - "temp_file_path matches '^/tmp/'"
    actions:
      - HALT
    conflicts_with: [critical-rules-004]
    requires: []
    triggers: []
    source: "060-tool-usage.md §3 Temp Files & Cleanliness"

  - id: tool-usage-005
    title: "Must use uv run for Python invocation"
    conditions:
      all:
        - "python_invocation_method == 'bare_python'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "060-tool-usage.md §4 Command Restrictions ALWAYS DO"

  - id: tool-usage-006
    title: "sed -i, printf, echo redirection, and heredocs forbidden"
    conditions:
      all:
        - "command_matches == 'sed -i|printf >|echo >|<<'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "060-tool-usage.md §4 Command Restrictions NEVER DO"

  - id: tool-usage-007
    title: "API client mandatory — no inline mutation scripts"
    conditions:
      all:
        - "platform_has_api_client == true"
        - "using_inline_requests_post == true"
    actions:
      - HALT
    conflicts_with: [critical-rules-029]
    requires: []
    triggers: [issue-operations]
    source: "060-tool-usage.md §1 API Client Mandatory"

  - id: tool-usage-008
    title: "git --recursive forbidden with submodule commands"
    conditions:
      all:
        - "command_matches == 'git submodule.*--recursive'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "060-tool-usage.md §4 Command Restrictions NEVER DO"
```
