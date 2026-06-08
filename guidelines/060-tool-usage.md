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

### API Client Mandatory (ZERO TOLERANCE)

When a platform has a dedicated API client (e.g., `gitbucket-api` CLI tool at `.opencode/tools/gitbucket-api`, GitHub MCP), the agent MUST use it for ALL operations. If the client lacks a needed method:

1. HALT
2. Report: executive summary of what was needed, the missing method name, possible resolution
3. Include byline
4. Do NOT bypass the client with raw `requests` calls or `python -c` inline scripts

### Platform Routing Mandate (ZERO TOLERANCE)

All `github_*`/`gitbucket-api` issue calls MUST route through the `issue-operations` dispatcher. Making direct platform API calls outside `issue-operations/platforms/` bypasses the routing layer and creates unmaintainable, platform-locked code. This is a **Tier 1 violation** per `000-critical-rules.md` §critical-rules-platform-routing-bypass.

The dispatcher resolves platform selection automatically based on `github.platform`. Agents MUST NOT deliberate about which platform API to use — the dispatcher handles this. Asking "should I use GitHub or GitBucket?" or choosing a platform API manually is a **Tier 2 violation** per `000-critical-rules.md` §critical-rules-platform-api-deliberation.

| Operation | Dispatcher Task | Direct Call (FORBIDDEN) |
|-----------|----------------|--------------------------|
| Read single issue | `read-issue` | `github_issue_read(method="get")` outside platforms/ |
| Read comments | `read-comments` | `github_issue_read(method="get_comments")` outside platforms/ |
| Read labels | `read-labels` | `github_issue_read(method="get_labels")` outside platforms/ |
| Read sub-issues | `read-sub-issues` | `github_issue_read(method="get_sub_issues")` outside platforms/ |
| List issues | `list-issues` | `github_list_issues()` outside platforms/ |
| Search issues | `search-issues` | `github_search_issues()` outside platforms/ |
| Update issue | `update-issue` | `github_issue_write(method="update")` outside platforms/ |
| Create issue | `creation` | `github_issue_write(method="create")` outside platforms/ |
| Close issue | `close` | `github_issue_write(method="update", state="closed")` outside platforms/ |

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

When working in a git worktree (`worktree.path` is set), file operation tools (`read`, `edit`, `write`, `glob`, `grep`) do **NOT** have a `workdir` parameter. Relative paths like `src/main.py` resolve to the **main repo**, not the worktree. This causes silent file operation errors — edits go to the wrong file.

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

### Workdir-Aware Path Composition — CRITICAL

**When `workdir` resolves to a path inside `.opencode/`, the workdir IS the `.opencode/` directory — do NOT prefix paths with `.opencode/`.** Paths resolve relative to the workdir. Prefixing with `.opencode/` creates `.opencode/.opencode/` nesting which shadows real configuration files and breaks AI agent configuration loading.

**CRITICAL:** Creating `.opencode/.opencode/` directories is FORBIDDEN. See `000-critical-rules.md` §Creating .opencode/.opencode/ Nested Directories.

| Workdir | Path to create `tmp/` | Correct | Wrong (FORBIDDEN) |
| -- | -- | -- | -- |
| (any) | `tmp/` | `mkdir -p tmp/` | N/A — all ephemeral artifacts go in repo root `tmp/` |
| (any) | (any) | Resolve relative to workdir | Do NOT compose `.opencode/.opencode/` |

- 🚫 FORBIDDEN: Any `mkdir`, `write`, or path-creating operation whose resolved path contains `.opencode/.opencode/`
- 🚫 FORBIDDEN: Hardcoding `.opencode/` prefix in paths when workdir is already inside `.opencode/`
- ✅ REQUIRED: Before any path-creating operation, verify the resolved path against workdir — if workdir is inside `.opencode/`, paths are relative to workdir
- ✅ REQUIRED: Submodule context detection: when `git rev-parse --show-toplevel` returns a `.opencode` directory, the agent works inside a submodule — paths must NOT compose `.opencode/.opencode/` nesting

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
- **Behavioral evidence artifacts are exempt from mandatory cleanup.** Files matching `./tmp/behavioral-evidence-*.{log,json}` MUST NOT be deleted by the agent during VbC or verification stages. These artifacts are preserved until PR merge cleanup (`git-workflow --task cleanup`), which is the ONLY authorized cleanup point. The `./tmp/` cleanup rule applies to all other temporary files, but behavioral evidence artifacts serve as cross-validation inputs and MUST survive until the PR is merged.

### 🚫 NEVER DO

- **ZERO TOLERANCE — NEVER use or access any other folder (e.g., `/tmp/`, `.tmp/`, etc.) for any reason.** Only `./tmp/` is permitted.
- **NEVER delete `./tmp/behavioral-evidence-*` files before PR merge cleanup.** These artifacts are required for adversarial audit cross-validation. Deleting them before the auditor inspects them produces a false "no behavioral evidence found" — indistinguishable from "evidence was never produced."

## 4. Command Restrictions & Quality

### ✅ ALWAYS DO

- **ALWAYS use `uv run python` to run Python.**
- **Fixed sleep value for polling**: Always use a fixed value of `15`.
- **One clear command per invocation.** A short `&&` guard is acceptable.
- **Use the-notebook-mcp for Jupyter notebook modifications.**

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

- **CREATE**: When `todowrite` is used, every item MUST have an explicit `status` field: `pending`, `in_progress`, or `completed`
- **UPDATE**: Each item MUST transition to `in_progress` when work on that item begins, and to `completed` when the item is fully done
- **CLEAR**: `todowrite(todos=[])` MUST be called when the task completes — this is required before any HALT

### 🚫 NEVER DO

- Leave items in `pending` or `in_progress` status after task completion
- Halt a session without calling `todowrite(todos=[])` to clear state
- Create items without a `status` field
- Skip status transitions (e.g., jump from `pending` directly to `completed` without `in_progress`)

## 8. Skill Call Principle

Call skills when their trigger keywords match the current task. Each skill defines explicit trigger patterns in its SKILL.md frontmatter (`Triggers on:` line). Match against those patterns, not against mere possibility.

| Principle | Rule |
|-----------|------|
| **Trigger matching** | Skills apply when their frontmatter `Triggers on:` keywords match the current task |
| **Priority ordering** | Process skills (approval-gate, brainstorming, writing-plans, systematic-debugging) before implementation skills |
| **No speculative calling** | Do not call skills "just in case" — call when triggers match |
| **Skill self-describes boundary** | Each SKILL.md defines what it covers; when in doubt, check `Triggers on:` line |
| **Sub-agent task() priority** | When a SKILL.md Sub-Agent Tasks section marks a task as `sub-agent`, the main agent calls via `task()` instead of loading the task file inline. This keeps heavy task files out of the main agent context. Result contracts (≈100-500 words) are read instead of the full task file (>1,000 words) |

## 9. Identity Source Semantics

The `github.identity_source` value (emitted by session-init) determines the agent's relationship to git remotes and GitHub API routing.

| `identity_source` | Routing Description |
|---|---|
| `root` | Standard workflow — repo has its own remote. Owner/repo from remote URL. All git operations work normally. |
| `local` | Local-only mode — no remote exists. All remote git operations (fetch, pull, push) will fail. No GitHub or GitBucket API calls are possible. Do NOT add remotes. |

**When `identity_source == "local"`:**

- No remote exists anywhere — do NOT add remotes
- `github.owner` and `github.repo` are `(none)`
- `github.platform` is `local`
- GitHub/GitBucket MCP calls are not available — use local `.issues/` directory
- Local git operations (branch, commit, stash) work normally
- `git push` is FORBIDDEN — there is no remote to push to
- `git remote add` is FORBIDDEN — the absence of remotes is intentional |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-03T00:00:00Z"
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
    triggers: [mcp-tool-usage]
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

  - id: tool-usage-009
    title: "No .opencode/.opencode/ nesting — workdir-aware path resolution"
    conditions:
      all:
        - "workdir_inside_opencode == true"
        - "path_prefixed_with_opencode == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [git-workflow, implementation-pipeline, approval-gate]
    source: "060-tool-usage.md §2 Workdir-Aware Path Composition"

  - id: tool-usage-010
    tier: 1
    title: "Platform routing mandate — direct github_*/gitbucket-api issue calls outside platforms/ are forbidden"
    conditions:
      all:
        - "issue_operation_pending == true"
        - "direct_platform_api_call == true"
        - "call_location_outside_platforms == true"
    actions:
      - HALT
    conflicts_with: []
    requires: [critical-rules-platform-routing-bypass]
    triggers: [issue-operations]
    source: "060-tool-usage.md §1 Platform Routing Mandate"

  - id: tool-usage-011
    tier: 2
    title: "Platform API deliberation prohibited — dispatcher resolves platform automatically"
    conditions:
      all:
        - "issue_operation_pending == true"
        - "agent_deliberating_platform_choice == true"
    actions:
      - HALT
      - ROUTE_THROUGH_DISPATCHER
    conflicts_with: []
    requires: [critical-rules-platform-api-deliberation]
    triggers: [issue-operations]
    source: "060-tool-usage.md §1 Platform Routing Mandate"

  - id: tool-usage-012
    tier: 2
    title: "Behavioral evidence artifacts exempt from mandatory cleanup — preserved until PR merge"
    conditions:
      any:
        - "file_path matches './tmp/behavioral-evidence-*'"
        - "cleanup_stage in ['vbc', 'verification', 'audit']"
        - "file_deletion_pending == true"
        - "file_path matches 'behavioral-evidence-SC-*'"
    actions:
      - BLOCK_DELETION
    conflicts_with: []
    requires: []
    triggers: [verification-before-completion, adversarial-audit, git-workflow]
    source: "060-tool-usage.md §3 Temp Files & Cleanliness"
```
