> **Full spec and artifacts: [`.opencode/.issues/1677/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1677)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1677/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

When the agent's CWD is inside a git submodule (`.opencode/`, `vendor/`, etc.), every relative path resolves against the submodule root instead of the project root. This breaks `./tmp/`, `./.issues/`, and all derived paths. The `*/.issues/` wildcard hack used in 42+ task files is a glob pattern that literally creates a `*` directory when used with `mkdir`.

## Scope

**In scope:**
- Emit `project_root` (absolute `git rev-parse --show-toplevel`) from session-init
- Update 060-tool-usage.md to replace workdir-aware composition with `project_root`-based resolution
- Replace all `./tmp/` and `*/.issues/` patterns in task files with `{project_root}`-anchored paths
- Behavioral enforcement tests verifying submodule-aware path resolution

**Out of scope:**
- Changing issue routing logic (which repo an issue belongs to)
- env-loader changes
- Non-task-file documentation references (AGENTS.md etc.)

## Approach

Add `project_root` to session-init output, propagate it in sub-agent dispatch context, and replace all fragile relative-path patterns with explicit project-root-anchored resolution. Four phases: session-init emission → guideline update → task file migration → behavioral tests.

## Impact

| Risk | Mitigation |
|------|------------|
| Existing task files miss `project_root` update | Automated grep for `./tmp/` and `*/.issues/` across all task files |
| `project_root` not propagated to sub-agents | Mandatory field in dispatch context contract; behavioral test verifies propagation |
| Behavioral tests fail on submodule CWD | Tests run from project root with explicit `project_root` set |

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
