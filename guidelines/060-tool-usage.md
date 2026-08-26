---
trigger_on: tool, path rule, temp file, command restriction, file operation
tier: 1
load_when: sub-agent
---

# Tool Usage & Terminal Rules

## 1. Tool Priority Hierarchy

> **Read [the mcp-tool-usage skill](skills/mcp-tool-usage/SKILL.md) for the complete five-tier hierarchy with tool selection tables.**

### Tier Summary

```
TIER 1 — PRIMARY: opencode built-in tools (read/write/edit/glob/grep)
TIER 2 — PRIMARY: Domain MCP (srclight, the-notebook-mcp, GitHub MCP)
│  └─ srclight indexes Python code only (.py files, symbols). Does NOT index .md, docs, configs, or non-Python files.
TIER 3 — PRIMARY: .opencode/tools/ (guidelines, md, memory, py ls/mkpkg, ollama-probe)
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

## 2. Built-in glob: verified semantics and silent-failure modes

This section is the single authoritative source for the built-in glob tool's verified semantics, its six silent-failure modes, the canonical path-parameter invocation idiom, and the empty-result disambiguation rule. Every agent-facing remediation site across the deck cites this section via Read-link rather than restating the semantics inline — the definition lives here once.

### 2.1 Verified limitations (LIM-1 through LIM-6)

Live probing (2026-08-26, against this repository) confirmed six distinct failure modes of the built-in glob tool:

| ID | Limitation | Detail |
|----|-----------|--------|
| **LIM-1** | Hidden-directory traversal skip | Traversal never enters dot-prefixed directories (`.opencode`, `.issues`, `.github`) when scanning via a pattern-from-CWD. Any pattern requiring descent into a dot-dir returns empty. The entire agent deck lives under `.opencode/`. |
| **LIM-2** | Gitignore filtering during traversal | Gitignored directories (`tmp/`, `.issues/`) are excluded from traversal. `tmp/` is where all pipeline artifacts live (`{project_root}/tmp/{issue}/...`). |
| **LIM-3** | Silent-empty conflation | "No files found" is returned identically for no-match, wrong-pattern, hidden-dir-skip, gitignore-skip, and absolute-pattern-rejection. No error, no reason, no distinction. |
| **LIM-4** | Files-only matching | Directory entries are never returned. Patterns ending in `/` (e.g. `**/runbooks/`) structurally cannot match anything. |
| **LIM-5** | Absolute-pattern rejection | Absolute paths embedded in the pattern parameter silently return empty. Only relative-to-CWD patterns or the path-parameter form work. |
| **LIM-6** | Opaque nonexistent-path error | A nonexistent path parameter yields "ripgrep execution failed" without naming the missing path or cause. Not silent, but cryptic. |

### 2.2 Canonical path-parameter invocation idiom

The only reliable invocation form, verified to reach hidden directories (`.opencode/.issues/`, `.issues/research-cards/`), gitignored directories, and normal tracked directories, is the path-parameter form:

```text
glob(pattern=<pattern-relative-to-path>, path=<target-dir-absolute-or-relative>)
```

- `pattern` holds a pattern **relative to** the `path` argument — never an absolute path and never a CWD-anchored dot-prefix chain (LIM-1, LIM-5).
- `path` holds the target directory as an **absolute or relative** value; passing the target directory explicitly bypasses both the hidden-directory skip (LIM-1) and the gitignore skip (LIM-2).
- Directory-only patterns (`path/` suffixes) are never valid — glob is files-only (LIM-4).

**Examples — verified working:**

```text
glob(pattern="*.md", path=".issues/research-cards")            # hidden dir target — works
glob(pattern="src/**/*.py", path="<worktree.path>")            # absolute/relative path target
glob(pattern="**/*.md", path="<spec_local_dir>")               # placeholder path target
```

**Forbidden — silently empty shapes:**

```text
glob(pattern=".issues/research-cards/*.md")                    # LIM-1 dot-prefix pattern-from-CWD
glob(pattern="**/runbooks/")                                    # LIM-4 directory-only pattern
glob(pattern="/abs/path/docs/**/*.md")                          # LIM-5 absolute pattern
glob(pattern="{project_root}/tmp/{issue}/artifacts/verification-*")  # LIM-2 gitignored + LIM-5 absolute
```

### 2.3 Empty-result disambiguation rule

A silent "No files found" result is **not evidence of absence**. Because LIM-3 conflates five distinct causes behind one identical output, the agent MUST NOT conclude that a file or directory does not exist from an empty glob result alone.

**Rule:** Before any absence conclusion (e.g. "no existing runbooks", "zero spec files", "verification evidence missing"), the agent MUST disambiguate the empty result:

1. Confirm the invocation used the canonical path-parameter form with a bracketed placeholder (not an f-string, unbracketed placeholder, absolute pattern, directory suffix, or CWD dot-prefix chain).
2. Confirm the target directory exists and is reachable as a `path` parameter (not silently skipped by LIM-1/LIM-2).
3. Only when the invocation shape is confirmed correct AND the path is confirmed reachable may a remaining empty result be treated as a true empty — an absence conclusion.

This rule is the verification-signal discipline for glob: an empty result is a signal that requires tool-call evidence of a correct invocation before it becomes an absence claim. An agent that treats a silent-empty result as proof of nonexistence has concluded from a defect, not from data.

## 3. Temp Files & Cleanliness

### ✅ ALWAYS DO

- All temporary scripts and output files MUST be written ONLY to `{project_root}/tmp/` (project root). NO OTHER FOLDERS OR PATHS ARE PERMITTED.
- Create the directory if needed: `mkdir -p ./tmp`.
- **ALWAYS clean up temp files after modification tasks are complete.**
- **Behavioral evidence artifacts are exempt from mandatory cleanup.** Files matching `{project_root}/tmp/behavioral-evidence-*.{log,json}` MUST NOT be deleted by the agent during VbC or verification stages. These artifacts are preserved until PR merge cleanup (`git-workflow --task cleanup`), which is the ONLY authorized cleanup point. The `{project_root}/tmp/` cleanup rule applies to all other temporary files, but behavioral evidence artifacts serve as cross-validation inputs and MUST survive until the PR is merged.

### 🚫 NEVER DO

- **ZERO TOLERANCE — NEVER use or access any other folder (e.g., `/tmp/`, `.tmp/`, etc.) for any reason.** Only `{project_root}/tmp/` is permitted.
- **NEVER delete `{project_root}/tmp/behavioral-evidence-*` files before PR merge cleanup.** These artifacts are required for audit cross-validation. Deleting them before the auditor inspects them produces a false "no behavioral evidence found" — indistinguishable from "evidence was never produced."

## 4. Command Restrictions & Quality

### 🚫 NEVER DO

- No destructive checkouts (`git checkout` files).
- **ZERO TOLERANCE — NEVER edit or modify production data or database seed files.** All changes to production data MUST be performed by a human developer.
- **NEVER use `--recursive` with any git submodule command** (e.g., `git submodule update --init --recursive`, `git clone --recursive`). The `--recursive` flag can pull in unintended nested submodules, cause unexpected network traffic, break reproducibility by implicitly resolving submodule chains, and conflict with explicit submodule management. Always use `git submodule update --init` (without `--recursive`) or explicit per-submodule operations.

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

### [critical-rules-016] Leaving stale todowrite state after task completion
A stale todowrite state means the next agent picks up your abandoned context. Professional engineers complete the full todowrite lifecycle before every halt — amateurs leave their workspace dirty for others to clean.


### [critical-rules-030] Skipping Clean-Room task() for Sub-Agents
Skipping clean-room task() means contaminating sub-agent context with orchestrator bias — every downstream result inherits that contamination. Amateurs shortcut isolation. Professionals dispatch clean.


### [critical-rules-031] Skipping Pre-Flight Checks for Sub-Agents
Dispatching a sub-agent without pre-flight checks means sending a worker into an unprepared workspace. Amateurs assume readiness. Professionals verify it.


### [critical-rules-032] Skipping Post-Flight Checks for Sub-Agents
Accepting sub-agent results without post-flight checks means trusting instead of verifying. Amateurs accept output at face value. Professionals inspect the deliverable.


### [critical-rules-linters-advisory] All linters are advisory only — no auto-modify

All linters (current and future) MUST run in read-only/report-only mode. No linter may auto-modify files. A linter that modifies files is not advisory — it is destructive.

| Linter | Forbidden | Required |
|--------|-----------|----------|
| `ruff check` | `ruff check --fix` (auto-fixes) | `ruff check` (report only) |
| `ruff format` | `ruff format` (auto-formats) | `ruff format --check` (report what would change) |
| `mdformat` | `mdformat` (without `--check`) | `mdformat --check` (report what would change) |
| Any future linter | Auto-modify mode | Read-only/report-only mode |

