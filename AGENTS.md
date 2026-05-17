# AGENTS.md — Repository Guidelines for Coding Agents

## Identity Detection (MANDATORY FIRST)

The AI agent must determine its identity from the system prompt on EVERY session:

1. **Detect AI agent and model** from your system context
2. **Report identity** in byline format: `🤖 <AgentName> (<ModelId>) <status-icon> <status>`
3. **Examples**: `🤖 OpenCode (ollama-cloud/glm-5) ✅ completed`, `🤖 OpenCode (ollama-cloud/glm-5) 🔄 working`

**Programmatic validation**: The `session-enforcement.ts` plugin injects expected identity values into the `IDENTITY_ECHO` directive and validates the agent's first response against them. On mismatch, an `IDENTITY_VALIDATION_FAILURE` block is injected into the next user message, halting all operations. See `000-critical-rules.md` §Inferring GitHub Owner.

**WHY**: Different agents/loaders provide different context. System prompt tells you what you are.

---

## Universal Skill Dispatch Gate (Tier 1 — Zero Tolerance, Every Message)

**🚫 CRITICAL VIOLATION: Producing any chat output in response to a user message without first evaluating and dispatching applicable skills is a Tier 1 violation.**

### Pre-Response Gate Procedure (MANDATORY — Every User Message)

Before producing ANY output in response to a user message, the agent MUST:

1. **Evaluate the user message against ALL available skill descriptions** (listed in `<available_skills>` at the bottom of the system prompt). Consider the *intent* and *semantic meaning* of the user's request — not keyword matching.

2. **If one or more skills match the intent of the request**: call `skill({name: "..."})` for the most relevant skill before generating any chat output. If multiple skills match, load the most specific one first.

3. **Only after skill content is loaded**: proceed to produce the response, using the loaded skill's instructions.

4. **If no skill applies directly (read-only questions, simple lookup, status checks)**: proceed without skill dispatch. This is the exception, not the default — err on the side of dispatching.

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

### Non-Waivable

This gate is Tier 1. No authorization, scope, or developer instruction can waive it. "Continue" does not waive it. Session momentum does not waive it.

---

## Guidelines Structure

Guidelines are pruned to the absolute minimum. See `.opencode/guidelines/` for:

| Series | Category | Files |
|--------|----------|-------|
| 000-099 | Core Rules | critical-rules, session-enforcement, approval-gate, go-prohibitions, scope-autonomy, tool-usage, environment, incremental-build |
| 200-209 | Error Handling | exception-handling, missing-data, logging-vs-raising |

**Registry of migrated content**: `.opencode/.guidelines/registry.yaml` tracks content moved from guidelines to skills.

---

## Build / Lint / Test Commands

| Task | Command | File Types |
|------|---------|------------|
| Sync dependencies | `uv sync` | - |
| Run all tests | `uv run pytest test/` | - |
| Run one test file | `uv run pytest test/test_filename.py` | - |
| Run one test | `uv run pytest test/test_filename.py::test_function_name` | - |
| Lint + auto-fix | `uvx ruff check --fix src/ test/` | Python ONLY |
| Format | `uvx ruff format src/ test/` | Python ONLY |
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
| Behavioral enforcement test | `bash .opencode/tests/behaviors/run-all.sh` | opencode-cli |
| Behavioral enforcement test (list) | `bash .opencode/tests/behaviors/run-all.sh --list` | opencode-cli |
| Behavioral enforcement test (dry-run) | `bash .opencode/tests/behaviors/run-all.sh --dry-run` | opencode-cli |
| TypeScript check | `PATH=.tools/node/bin:$PATH npx tsc --noEmit` | TypeScript |
| TypeScript check (alt) | `PATH=.node/bin:$PATH npx tsc --noEmit` | TypeScript |
| All enforcement tests (content + behavioral) | `bash .opencode/tests/test-enforcement.sh && bash .opencode/tests/behaviors/run-all.sh` | opencode-cli |
| Isolated opencode-cli run | `bash .opencode/tests/with-test-home opencode-cli run '<message>'` | opencode-cli |
| Clean test artifacts | `bash .opencode/tests/with-test-home --clean` | opencode-cli |

**Never** use bare `python`, `python3`, or `pip`. Always prefix with `uv run` for project commands.

**Ruff version sync:** When bumping the ruff version, update BOTH `pyproject.toml` (`[dependency-groups] dev` and `[tool.ruff] required-version`) AND `.pre-commit-config.yaml` (`rev:` for `ruff-pre-commit`) to keep them in sync. The `ruff-pre-commit` rev maps 1:1 to ruff releases (e.g., `v0.11.0` → ruff `0.11.0`).

**Isolated test environment:** The `with-test-home` wrapper isolates opencode-cli XDG state into a project-relative temporary home (`./opencode/tmp/test-home-<timestamp>`), eliminating SQLite session conflicts with the desktop app. This allows skill enforcement tests to run from within an active opencode session.

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

- **Submodule repos**: `.opencode/` tracks `dev` — never detached HEAD or `main`

---

## Session Context

One plugin runs at session start, and one script provides complementary data:

1. **session-init** (`tools/session-init`): Emits session variables silently (owner, repo, platform, hooks). **Canonical source for identity data including Sub-folder Repo Mappings.**
2. **session_context_triggers.py** (`scripts/session_context_triggers.py`): Emits trigger warnings into first user message

Session context output includes:

- **Identity section** (always, in system prompt): `github.owner`, `github.repo`, `github.platform`, credential status
- **Identity-echo directive** (always, in first user message): mandatory identity echo at session start
- **Trigger alerts** (when detected, in first user message): trigger warnings for special states
- **Tier 3 probes** (opt-in via `.opencode-issue-probe`): `open_pr_on_branch`, `ci_failure`, `stale_pr`

Credential status values: `verified` (token exists + API ping succeeds), `present` (token exists, liveness unchecked), `missing` (no token found), `stale` (token rejected by API), `unavailable` (platform unknown).

- **Sub-folder repo mappings** (when `.gitmodules` exists): `submodule_path: owner/repo (platform)` — files under submodule paths belong to separate repos; use the mapped `owner/repo` for API calls targeting those paths. Emitted by `session-init` (canonical source).

---

## Direct-Branch Primary Workflow

**Direct-branch is the PRIMARY and DEFAULT workflow.** Agent creates feature branch directly in main repo using `git checkout -b` or `git switch -c`. Worktrees are **opt-in**, created only when `WORKTREE_REQUIRED` flag is set or developer explicitly requests them.

| Mode | When | Path Behavior |
|------|------|---------------|
| **Direct-branch (default)** | `WORKTREE_REQUIRED` NOT set | Relative paths work directly; `worktree.path` NOT set |
| **Worktree (opt-in)** | `WORKTREE_REQUIRED` set or developer request | All paths prefixed with `worktree.path` |

**Branch and submodule state model:** See `git-workflow` skill → Branch and Submodule State Model for the complete workflow including proactive repo state verification, mid-feature submodule currency, rebase-always hygiene, and post-merge integration.

**Submodule discipline:**
- Dev parking: `git checkout dev && git pull && git submodule init && git submodule foreach "git checkout dev && git pull"`
- Mid-feature: Sync submodules to upstream `dev` periodically
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