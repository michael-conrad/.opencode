# [SPEC] Canonical project_root variable for submodule-aware path resolution

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | Relative paths resolve against submodule root when CWD is inside a submodule, breaking `./tmp/`, `./.issues/`, and all derived paths |
| **Root Cause / Motivation** | No canonical "project root" anchor exists; session-init emits repo info but not the absolute top-level git root |
| **Approach Chosen** | Emit `project_root` from session-init as `git rev-parse --show-toplevel`; update all task files to use `{project_root}` prefix |
| **Alternatives Considered & Why Discarded** | Workdir-aware path composition (060-tool-usage.md) only addresses `.opencode/.opencode/` nesting, not general submodule resolution; `*/.issues/` wildcard is a glob pattern that breaks `mkdir` |
| **Key Design Decisions** | `project_root` is set once at session start, never ambiguous; never hardcode submodule names — use session-init's `path` field from `## Repo Information` |

## Problem

When the agent's CWD is inside a git submodule (e.g., `.opencode/`, `vendor/`, `lib/`), every relative path resolves against the submodule root, not the project root. This breaks:

- `./tmp/` → resolves to `.opencode/tmp/` instead of `./tmp/`
- `./.issues/` → resolves to `.opencode/.issues/` instead of `.issues/`
- `./tmp/{N}/work.md` → resolves to `.opencode/tmp/{N}/work.md`
- Any `mkdir -p ./tmp/` creates the wrong directory

## Existing Mitigations (fragmented and inconsistent)

1. **`*/.issues/` wildcard** — used in 42+ task files as a workaround, but `mkdir -p */.issues/` literally creates a directory named `*`. It's a glob pattern used where a real path is needed.
2. **Workdir-aware path composition** (060-tool-usage.md) — only addresses the `.opencode/.opencode/` nesting case, not general submodule resolution.
3. **`local-issues` tool** — handles `.issues/` via qualified names but doesn't solve `./tmp/` or other paths.
4. **No canonical "project root" anchor** — there's no mechanism to say "resolve this path from the project root, not the current submodule."

## Constraints

1. **Never hardcode submodule names.** The `path` field from session-init's `## Repo Information` is the submodule path relative to project root. The resolution pattern is `{project_root}/{path}/.issues/{N}/` where `path` comes from the repo entry — never hardcoded.
2. **`project_root` is set once, never ambiguous.** Emitted at session start. Every sub-agent receives it in dispatch context.
3. **Covers all file types** — `{project_root}/tmp/`, `{project_root}/.issues/`, `{project_root}/tmp/{N}/work.md`, `{project_root}/.opencode/skills/...`
4. **Works for any submodule** — `.opencode/`, `vendor/`, `lib/`, any depth.
5. **Eliminates the `*/.issues/` wildcard hack** — 42+ task files use `*/.issues/` as a workaround. With `project_root`, they'd use `{project_root}/.issues/` — a real path, not a glob pattern that breaks `mkdir`.

## What `project_root` Does NOT Replace

The need to know *which* repo an issue belongs to (root vs submodule). That's still resolved by session-init's `## Repo Information` section and the `local-issues` tool's qualified names. `project_root` just gives the absolute anchor to construct paths from — it doesn't change the routing logic.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | `project_root` from `git rev-parse --show-toplevel` | Single source of truth; git already computes this; no config file needed | MUST | SC-1, SC-2 |
| DEC-2 | Emit at session start, propagate in dispatch context | Every sub-agent needs it; session-init is the canonical emission point | MUST | SC-3 |
| DEC-3 | Replace `*/.issues/` with `{project_root}/.issues/` | `*/.issues/` is a glob pattern, not a real path; `mkdir -p */.issues/` creates a literal `*` directory | MUST | SC-4 |
| DEC-4 | No env-loader changes | env-loader is a separate pipeline; `project_root` is LLM context only | MUST | SC-5 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Existing task files miss `project_root` update | High | High | Automated grep for `./tmp/` and `*/.issues/` across all task files | SC-4 |
| RISK-2 | `project_root` not propagated to sub-agents | Medium | High | Mandatory field in dispatch context contract; behavioral test verifies propagation | SC-3 |
| RISK-3 | Behavioral tests fail on submodule CWD | Medium | Medium | Tests run from project root with explicit `project_root` set | SC-6 |
| RISK-4 | `local-issues` tool needs update for `project_root` | Low | Medium | Assess during implementation; update if needed | SC-5 |

## Decomposition Classification

| Classification | Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ------ | --------------------- | ----------- |
| multi-phase | 4 | One sub-issue per phase | stacked |

## Phases

### Phase 1: session-init emission
Add `project_root` to session-init output. Verify via `./.opencode/tools/session-init | grep project_root`.

### Phase 2: 060-tool-usage.md update
Replace workdir-aware path composition section with `project_root`-based resolution. Add `project_root` to the path rules.

### Phase 3: Task file migration
Grep all task files for `./tmp/` and `*/.issues/` patterns. Replace with `{project_root}`-based paths. Update `local-issues` tool if needed.

### Phase 4: Behavioral enforcement tests
Write behavioral tests that verify the agent uses `project_root` when CWD is inside a submodule.

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `project_root` is emitted by session-init as absolute path from `git rev-parse --show-toplevel` | Run `./.opencode/tools/session-init` and grep for `project_root`; verify value matches `git rev-parse --show-toplevel` | If missing: add to session-init output; if wrong value: fix resolution logic | Phase 1 | `.opencode/tools/session-init` | DEC-1 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | `project_root` value is the top-level git root, not submodule root | Run `git rev-parse --show-toplevel` from inside `.opencode/` submodule; verify `project_root` matches project root, not `.opencode/` | Fix session-init to use `--show-toplevel` not `--git-dir` | Phase 1 | `.opencode/tools/session-init` | DEC-1 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | `project_root` is propagated in sub-agent dispatch context | Behavioral test: task a sub-agent, verify `project_root` is present in its context | Add `project_root` to dispatch context contract in all skill SKILL.md files | Phase 1 | skill SKILL.md files | DEC-2 | Phase 1 | behavioral | cross-cutting | SC-3 | — | — | Phase 1 |
| SC-4 | All task files using `./tmp/` or `*/.issues/` are updated to `{project_root}`-based paths | Automated grep for `./tmp/` and `*/.issues/` across all `.opencode/skills/*/tasks/*.md` and `.opencode/guidelines/*.md`; verify zero remaining instances | For each remaining instance: replace with `{project_root}/tmp/` or `{project_root}/.issues/` | Phase 3 | `.opencode/skills/` and `.opencode/guidelines/` | DEC-3 | Phase 3 | pre-commit | standalone | — | — | — | Phase 3 |
| SC-5 | `local-issues` tool works correctly with `project_root`-based paths | Run `local-issues` commands from inside `.opencode/` submodule; verify they resolve to correct `.issues/` directory | Update `local-issues` tool to use `project_root` for path resolution | Phase 3 | `.opencode/tools/local-issues` | DEC-4 | Phase 3 | pre-commit | standalone | — | — | — | Phase 3 |
| SC-6 | Behavioral enforcement test verifies agent uses `project_root` when CWD is inside submodule | `opencode-cli run` with prompt that triggers path resolution from submodule CWD; verify stderr shows `project_root`-based path | Fix dispatch context propagation; fix task file paths | Phase 4 | `.opencode/tests/behaviors/` | — | Phase 4 | behavioral | standalone | — | — | — | Phase 4 |
| SC-7 | `060-tool-usage.md` references `project_root` instead of workdir-aware composition | Read `060-tool-usage.md`; verify workdir-aware composition section is replaced with `project_root`-based resolution | Replace the section; update all path examples | Phase 2 | `.opencode/guidelines/060-tool-usage.md` | — | Phase 2 | pre-commit | standalone | — | — | — | Phase 2 |
| SC-8 | Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rule; confirm RED state (test fails before change) | Check `.opencode/tests/behaviors/` for test files; run each test and confirm FAIL before implementation | Create behavioral test files; verify RED state | Phase 4 | `.opencode/tests/behaviors/` | — | Phase 4 | pre-commit | cross-cutting | SC-8 | — | — | Phase 4 |

## Cross-Cutting SCs

SC-3, SC-8 — Verified once in Phase 1/Phase 4 respectively, applies to all subsequent phases.

## Regression Invariants

1. Session-init output format MUST NOT change for existing fields — `project_root` is additive only
2. All existing `local-issues` qualified name resolution MUST continue to work unchanged
3. Existing `*/.issues/` patterns in non-task-file documentation (e.g., AGENTS.md) MAY remain if they are documentation-only references

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "\*/.issues/" .opencode/` | Identify wildcard hack usage count |
| Local docs | `060-tool-usage.md` | Understand existing workdir-aware composition |
| Local docs | `AGENTS.md` | Understand session-init output format |
| MCP search | `srclight_get_signature("session-init")` | Verify session-init emission mechanism |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1677/plan.md` before implementation begins.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
