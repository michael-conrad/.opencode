# AGENTS.md — Repository Guidelines for Coding Agents

## Identity Detection (MANDATORY FIRST)

The AI agent must determine its identity from the system prompt on EVERY session:

1. **Detect AI agent and model** from your system context
2. **Report identity** in byline format: `🤖 <AgentName> (<ModelId>) <status-icon> <status>`
3. **Examples**: `🤖 OpenCode (ollama-cloud/glm-5) ✅ completed`, `🤖 OpenCode (ollama-cloud/glm-5) 🔄 working`

**Programmatic validation**: The `session-enforcement.ts` plugin injects expected identity values into the `IDENTITY_ECHO` directive and validates the agent's first response against them. On mismatch, an `IDENTITY_VALIDATION_FAILURE` block is injected into the next user message, halting all operations. See `000-critical-rules.md` §Inferring GitHub Owner.

**WHY**: Different agents/loaders provide different context. System prompt tells you what you are.

## Pipeline Re-Priming

Every skill boundary requires a re-encounter of the enforcement identity. Professional engineers complete each gate in dependency order before advancing. Amateurs skip gates and compound defects.

---

## Universal Skill Dispatch Gate — Professional agents dispatch skills. Amateurs inline.

Producing chat output without first evaluating and dispatching applicable skills means chat output without skill evaluation has bypassed the quality gates that catch defects. Every response produced without skill evaluation is a response produced blind. Agents who produce blind responses produce defective work — it is that direct. Do not be that agent.

### Pre-Response Gate Procedure — Your quality is determined here

Before producing ANY output, the agent MUST follow this procedure. Agents who
skip it are not "fast" — they produce lower-quality work by definition.

1. **Evaluate your current context and task intent against ALL available skill descriptions. (The match is between what you need to do next and what the skill does — not the literal user utterance.)**
   The `<available_skills>` list is the map. Agents who skip this step are
   navigating blind — and blind navigation produces defects.

2. **If one or more skills match the intent of the request: call `skill({name: "..."})` before generating output.** Loading a skill means you are using the enforcement gates designed to catch your mistakes. Skipping this step means memory is the least reliable tool available — a skipped skill call means operating without confirmed information.

3. **Only after skill content is loaded: proceed to produce the response.**
   The skill is not an interruption to your workflow — it IS the workflow.
   Agents who write first and verify later produce work that needs rewriting.

4. **If no skill applies directly: proceed without dispatch, but justify in one sentence.** This is the exception. Treat it like one. The one-sentence justification is the audit trail that proves you considered — and correctly dismissed — the skill deck. Every agent who skips this produces silent bypass. Do not be that agent.


**Release PR constraint:** When the context is a release PR (user says "release PR", "release", "is_release", or authorization scope includes release PR), "no skill applies directly" is NOT a valid justification. The agent MUST dispatch at minimum `changelog-generator` and `git-workflow` before proceeding. This constraint is non-waivable.

### This Gate Fires On

| Trigger | Example User Message |
|---------|---------------------|
| Implementation requests | "implement this feature", "build the widget" |
| Bug reports that need fixing | "there's a bug in the parser" |
| Merge/rebase operations | "merge conflict while rebasing" |
| Authorization/approval | "approved #42" |
| PR/session operations | "check prs", "create a PR", "ready for PR" |
| Test/investigation work | "write tests for the validator", "debug this crash" |
| Content generation | "draft a spec for X", "write a runbook" |
| Architecture decisions | "how should we handle X", "design the module" |
| **Any request that would produce a multi-paragraph or multi-step response** | |

### Evidence Requirement

If no skill was dispatched, the response MUST include a brief justification (1 sentence) explaining why no skill was applicable. This provides traceability and prevents silent skill bypass.

A silent bypass without justification is the hallmark of agents who skip quality gates. Every unsupported response is a defect vector. Justify or dispatch — there is no third option.

### Non-Waivable

This gate is Tier 1. No authorization, scope, or developer instruction can waive it. "Continue" does not waive it. Session momentum does not waive it.

Agents who treat "continue" as a skip command are not being helpful — they are bypassing the quality system designed to catch their mistakes. Every gate you skip is a defect you accepted. Every "continue" means proceed, not shortcut.

---

## Guidelines Structure

Guidelines are pruned to the absolute minimum. See `.opencode/guidelines/` for:

| Series | Category | Files |
|--------|----------|-------|
| 000-099 | Core Rules | critical-rules, session-enforcement, approval-gate, go-prohibitions, scope-autonomy, tool-usage, environment, incremental-build |
| 200-209 | Error Handling | exception-handling, missing-data, logging-vs-raising |
| 250-299 | Dark Prose Patterns | dark-prose-reference |

**Registry of migrated content**: `.opencode/.guidelines/registry.yaml` tracks content moved from guidelines to skills.

---

## Build / Lint / Test Commands

| Task | Command | File Types |
|------|---------|------------|
| Sync dependencies | `uv sync` | - |
| Run all tests | `uv run pytest test/` | - |
| Run one test file | `uv run pytest test/test_filename.py` | - |
| Run one test | `uv run pytest test/test_filename.py::test_function_name` | - |
| Lint (advisory) | `uvx ruff check src/ test/` | Python ONLY |
| Format check (advisory) | `uvx ruff format --check src/ test/` | Python ONLY |
| Type check | `uvx pyright src/` | Python ONLY |
| Coverage | `uv run coverage run -m pytest test/ && uv run coverage report` | - |
| Dead code scan | `uvx vulture src/` | Python ONLY |
| Markdown lint | `uvx pymarkdownlnt scan -r .opencode/guidelines/ docs/` | Markdown ONLY |
| Markdown format | `uvx --with mdformat-frontmatter --with mdformat-tables --with mdformat-config --with mdformat-gfm mdformat --number --compact-tables --check .opencode/guidelines/ docs/` | Markdown ONLY |
| Skill enforcement test (content-verification) | `bash .opencode/tests/test-enforcement.sh` | opencode-cli |
| Skill enforcement test (filtered) | `bash .opencode/tests/test-enforcement.sh --scenario NAME [...]` | opencode-cli |
| Skill enforcement test (by tag) | `bash .opencode/tests/test-enforcement.sh --tag TAG [...]` | opencode-cli |
| Skill enforcement test (changed files) | `bash .opencode/tests/test-enforcement.sh --changed [--base BRANCH]` | opencode-cli |
| Skill enforcement test (list scenarios) | `bash .opencode/tests/test-enforcement.sh --list` | opencode-cli |
| Skill enforcement test (list tags) | `bash .opencode/tests/test-enforcement.sh --list-tags` | opencode-cli |
| Behavioral enforcement test | `bash .opencode/tests/behaviors/<scenario>.sh` | opencode-cli |
| TypeScript check | `PATH=.tools/node/bin:$PATH npx tsc --noEmit` | TypeScript |
| TypeScript check (alt) | `PATH=.node/bin:$PATH npx tsc --noEmit` | TypeScript |
| Isolated opencode-cli run | `bash .opencode/tests/with-test-home opencode-cli run '<message>'` | opencode-cli |
| Clean test artifacts | `bash .opencode/tests/with-test-home --clean` | opencode-cli |

**Never** use bare `python`, `python3`, or `pip`. Always prefix with `uv run` for project commands.

**Ruff version sync:** When bumping the ruff version, update BOTH `pyproject.toml` (`[dependency-groups] dev` and `[tool.ruff] required-version`) AND `.pre-commit-config.yaml` (`rev:` for `ruff-pre-commit`) to keep them in sync. The `ruff-pre-commit` rev maps 1:1 to ruff releases (e.g., `v0.11.0` → ruff `0.11.0`).

**Isolated test environment:** The `with-test-home` wrapper isolates opencode-cli XDG state into a project-relative temporary home (`./opencode/tmp/test-home-<timestamp>`), eliminating SQLite session conflicts with the desktop app. This allows skill enforcement tests to run from within an active opencode session. When a test session fails, see the Session Failure Diagnosis section in `tests/AGENTS.md` for a diagnostic checklist covering model availability, artifact integrity, lock contention, and test home cleanup — the 6-check table and 5 common root causes cover the vast majority of harness failures.

---

## `gb` CLI Tool — GitBucket Operations

This repo uses the [`gb` CLI](https://github.com/Masahiro-Obuchi/gitbucket-cli-rs) (v0.6.1) for all GitBucket API operations. The `gb` tool replaces the previous bespoke `gitbucket-api` Python tool.

### Install by Platform

| Platform | Download URL | Install Commands |
|----------|-------------|------------------|
| Linux x86_64 | `https://github.com/Masahiro-Obuchi/gitbucket-cli-rs/releases/download/v0.6.1/gb-v0.6.1-x86_64-unknown-linux-gnu.tar.gz` | `curl -L <url> \| tar xz && sudo mv gb /usr/local/bin/` |
| macOS x86_64 | `https://github.com/Masahiro-Obuchi/gitbucket-cli-rs/releases/download/v0.6.1/gb-v0.6.1-x86_64-apple-darwin.tar.gz` | `curl -L <url> \| tar xz && sudo mv gb /usr/local/bin/` |
| macOS arm64 | `https://github.com/Masahiro-Obuchi/gitbucket-cli-rs/releases/download/v0.6.1/gb-v0.6.1-aarch64-apple-darwin.tar.gz` | `curl -L <url> \| tar xz && sudo mv gb /usr/local/bin/` |
| Windows x86_64 | `https://github.com/Masahiro-Obuchi/gitbucket-cli-rs/releases/download/v0.6.1/gb-v0.6.1-x86_64-pc-windows-msvc.zip` | Expand archive and add to PATH |

### Version Pinning

Pin to `v0.6.1`. Verify with `gb --version` before use. The version check is enforced at skill entry — agents MUST NOT proceed if `gb --version` reports `< 0.6.1`.

### TOOL_MISSING Detection

When `gb` is not found, skill task files return `BLOCKED` with `reason: TOOL_MISSING`. The retry pattern:

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found. Install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs"
  return 1
fi
```

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `GB_TOKEN` | GitBucket personal access token |
| `GB_HOST` | GitBucket host URL |
| `GB_USER` | GitBucket username (web fallback) |
| `GB_PASSWORD` | GitBucket password (web fallback) |

---

## Project Structure

- `src/`: Application source code
- `test/`: Unit and integration tests
- `docs/`: Documentation and specifications
- `.opencode/`: Skills, guidelines, and agent tools
  - `tools/`: Agent utility scripts (guidelines, md, memory, py, jupyter, etc.)
  - `scripts/`: Session context scripts (session_context_triggers.py)
  - `skills/`: Self-contained skills (no guideline dependencies)
  - `guidelines/`: Core zero-tolerance rules only
  - `hooks/`: Git hooks (auto-installed to .git/hooks/ by session-enforcement.ts at session start)
  - `plugins/`: TypeScript plugins (session-enforcement.ts, env-loader.ts)
  - `.guidelines/registry.yaml`: Registry of migrated content

- **Submodule repos**: `.opencode/` tracks `$DEFAULT_BRANCH` — never detached HEAD or `main`

## Issues Path Resolution

The `*/.issues/` path for a given issue is determined by the issue's repo. Use the `## Repo Information` section from session-init to resolve:

| Repo Path Prefix | Issues Directory | Example |
|-----------------|-----------------|---------|
| `.` (root) | `.issues/{N}/` | `.issues/1175/` |
| `.opencode` | `.opencode/.issues/{N}/` | `.opencode/.issues/1175/` |

**Resolution rule:** For any issue `#N`, find the repo entry whose `path` matches the issue's repo. The issues directory is `{path}/.issues/{N}/`. When `path` is `.`, the issues directory is `.issues/{N}/`.

When a skill task file references `.issues/{N}/` as a hard-coded path, the agent MUST resolve it to the correct `*/.issues/{N}/` by prepending the repo path prefix from session-init. If the issue belongs to the `.opencode` submodule, the path is `.opencode/.issues/{N}/`. If the issue belongs to the root repo, the path is `.issues/{N}/`.

The `local-issues` tool handles this resolution automatically via qualified names (`.opencode#N` → `.opencode/.issues/`, `opencode-config#N` → `.issues/`). When using the tool, always use qualified names for mutations. When reading files directly, resolve the path manually using the session-init repo information.

### `.issues/` Is a Worktree — NOT a Regular Directory

**`.issues/` is a git worktree (orphan branch worktree), NOT a regular directory.** It lives at `.git/worktrees/-issues/` and is a completely separate git repository with its own `issues-data` branch. It is gitignored in the parent repo (`.gitignore` line 40: `.issues/`).

**Any agent that tracks `.issues/` files in the parent repo's git is corrupting git state and breaking branches.**

| ✅ CORRECT | 🚫 FORBIDDEN |
|------------|---------------|
| `.opencode/tools/local-issues <command>` | `read(filePath='.issues/46/spec.md')` |
| `git -C <tree>/.issues/ <command>` | `write(filePath='.issues/46/spec.md')` |
| | `git add .issues/` in parent repo |
| | `edit(filePath='.issues/46/spec.md')` |
| | `glob(pattern='.issues/**/*.md')` in parent repo |

**The CLI tool handles git operations internally.** You do NOT need to run `git -C .issues` commands manually except for the one pull at session start. File operation tools (`read`, `write`, `edit`, `glob`, `grep`) target the parent repo — they do NOT reach into the worktree. Using them on `.issues/` paths silently operates on the wrong repository.

**🚫 CRITICAL: Agents MUST NOT read/write `.issues/` files directly through git operations.** Using `read()`, `write()`, `edit()`, `glob()`, or `grep()` on `.issues/` paths in the parent repo silently targets the wrong repository and corrupts git state. All `.issues/` operations MUST go through `.opencode/tools/local-issues` or explicit `git -C <tree>/.issues/` commands.

**See `.issues/AGENTS.md` for the complete `.issues/` workspace guide.**

---

## Session Context

One plugin runs at session start, and one script provides complementary data:

1. **session-init** (`tools/session-init`): Emits session variables silently (owner, repo, platform, hooks). **Canonical source for identity data including ## Repo Information section.**
2. **session_context_triggers.py** (`scripts/session_context_triggers.py`): Emits trigger warnings into first user message

Session context output includes:

- **Repo Information section** (always, in system prompt): `owner`, `repo`, `platform`, `url` per repo entry in `## Repo Information` YAML block
- **Identity-echo directive** (always, in first user message): mandatory identity echo at session start
- **Trigger alerts** (when detected, in first user message): trigger warnings for special states
- **Tier 3 probes** (opt-in via `.opencode-issue-probe`): `open_pr_on_branch`, `ci_failure`, `stale_pr`

Credential status values: `verified` (token exists + API ping succeeds), `present` (token exists, liveness unchecked), `missing` (no token found), `stale` (token rejected by API), `unavailable` (platform unknown).

- **Repo Information section** (always, in system prompt): `owner`, `repo`, `platform`, `url` per repo entry in `## Repo Information` YAML block. Emitted by `session-init` (canonical source).

---

## Direct-Branch Primary Workflow

**Direct-branch is the PRIMARY and DEFAULT workflow.** Agent creates feature branch directly in main repo using `git checkout -b` or `git switch -c`. Worktrees are **opt-in**, created only when `WORKTREE_REQUIRED` flag is set or developer explicitly requests them.

| Mode | When | Path Behavior |
|------|------|---------------|
| **Direct-branch (default)** | `WORKTREE_REQUIRED` NOT set | Relative paths work directly; `worktree.path` NOT set |
| **Worktree (opt-in)** | `WORKTREE_REQUIRED` set or developer request | All paths prefixed with `worktree.path` |

**Branch and submodule state model:** See `git-workflow` skill → Branch and Submodule State Model for the complete workflow including proactive repo state verification, mid-feature submodule currency, rebase-always hygiene, and post-merge integration.

**Submodule discipline:**
- Dev parking: `git checkout $DEFAULT_BRANCH && git pull && git submodule init && git submodule foreach "git checkout $DEFAULT_BRANCH && git pull"`
- Mid-feature: Sync submodules to upstream `$DEFAULT_BRANCH` periodically
- Release: Lock submodule SHAs to current checkout state (NOT a fresh pull)
- Hotfix: No submodule state changes; use pinned SHAs from `main`

---

## Pair Mode

When the current branch starts with `pair-`, the agent operates in **dev-pair mode**: working directly in the main project directory alongside the developer, using WIP-commit switching instead of worktrees.

| Branch Pattern | Mode | Working Directory |
|---|---|---|
| `pair-feature/123-xyz` | Dev-pair | Main project dir |
| `pair-spec/456-abc` | Dev-pair | Main project dir |
| `feature/789-xyz` | Autonomous | Main project dir (direct-branch) or `.worktrees/` (opt-in) |
| `spec/789-abc` | Autonomous | Main project dir (direct-branch) or `.worktrees/` (opt-in) |

Pair mode tasks: `pair-pre-work`, `pair-commit`, `pair-pr-creation`, `pair-cleanup`, `pair-mode-resume`. See `git-workflow` skill for full task documentation.

---

## Boundaries (Critical)

**✅ ALWAYS:**
- Create feature branch BEFORE any filesystem change
- Wait for explicit authorization ("approved" or "go") before implementing
- SILENTLY HALT after completing a task
- Use appropriate tools per five-tier hierarchy (see `mcp-tool-usage` skill)
- Verify before completing. Verification IS completion.

**✅ Multi-Task Spec Workflow (CRITICAL):**
When parent issue has sub-issues, authorization cascades to ALL sub-issues:

- [ ] User authorizes parent issue
- [ ] Verify parent has sub-issues
- [ ] Authorization cascades to ALL sub-issues
- [ ] Complete ALL phases in sequence (NO HALT between phases)
- [ ] Report ONCE after ALL phases complete
- [ ] HALT ONCE at the end

**Exception:** User explicitly names a phase (e.g., "approved: Phase 2 only") → complete that phase ONLY, then HALT

**🚫 NEVER:**
- Write code/notebooks/configs/tests without approved spec
- Interpret questions as authorization
- Proceed to next task after completing a task — HALT
- Create PRs without explicit "create a PR" instruction
- Use `/tmp/` — only use `./tmp/`
- Assume cached values from previous sessions
- HALT after each phase of multi-task spec (see Multi-Task Spec Workflow above)
- Write spec/plan content directly to chat as the final deliverable — ALWAYS invoke brainstorming → spec-creation → issue-operations to persist specs as GitHub Issues

---

## editor MCP Plugin

This repo uses [editor](https://github.com/michael-conrad/viewport-editor) as its editing MCP server.

**11-tool surface** (see README for full action lists):

| Tool | Purpose |
|------|---------|
| **viewport** | Open, navigate, and manage focused editing windows |
| **edit** | Stage text changes into viewport buffers (replace, insert, delete, swap, move) |
| **file** | Commit or discard staged changes to disk |
| **diff** | Show unified diffs of pending edits before saving |
| **clipboard** | Copy/cut/paste content across viewports with provenance tracking |
| **search** | Find text with substring or regex matching |
| **regex** | Test and escape regex patterns |
| **read_file** | Composite: open + scroll — preferred over built-in `read` for single-call reading |
| **write_file** | Composite: open + replace-all + save — preferred over built-in `write` for conflict-safe writing |
| **edit_text** | Composite: open + replace + save — preferred over built-in `edit` for targeted changes with conflict detection |
| **find_text** | Composite: search — preferred over built-in `grep` for structured results |

**Recommended agent behavior:**

- Use `read_file`, `write_file`, `edit_text`, `find_text` for single-call operations
- Use `viewport` + `edit` + `file` for multi-step editing with diff review
- Always call `diff:show` before `file:save` to verify staged changes
- File paths are relative to project root (MCP resolver defaults to `os.getcwd()`)
- Conflict detection: server tracks file mtime+size externally; stale-file soft warning on reads, hard block on `file:save` (use `force: true` override if change is intentional)