# Work State File Schema — Chain-of-Responsibility Extension

## Purpose

Define the work state file schema extension for chain-of-responsibility orchestration. Each atomic task in the `verify-authorization/`, `pre-impl/`, and `screen/` chains writes results as a dedicated section in the work state file (`tmp/work-<timestamp>.md`).

## Header Section

```yaml
## chain-context
authorization_scope: <scope_value>
halt_at: <pipeline_stage>
pr_strategy: stacked | none
pipeline_phase: <current_phase_name>
issue_numbers: [<N>]
created_at: <ISO-8601>
```

## Per-Task Result Section

Each atomic task creates a `## <section-name>` heading. The section body is YAML-structured:

```yaml
## <section-name>
inputs_from: [<section-name> | null]
status: pending | in_progress | done | failed | skipped
started_at: <ISO-8601 | null>
completed_at: <ISO-8601 | null>
result: <YAML-structured task output>
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `inputs_from` | Yes | List of section names this task reads from. `[]` for first task in chain. |
| `status` | Yes | Current execution status. Updated by the task on start/completion. |
| `started_at` | Yes | ISO-8601 timestamp when task begins; `null` if pending. |
| `completed_at` | Yes | ISO-8601 timestamp when task finishes; `null` if not done. |
| `result` | Yes | Task-specific YAML output. Schema varies per task. |

### Section Names

| Chain | Section Names |
|-------|---------------|
| `verify-authorization/` | `scope-auto-resolve`, `item-decomposition-check`, `sc-traceability-check`, `sub-issue-verification`, `spec-to-plan-cascade`, `gap-fill-cascade`, `auto-dispatch` |
| `pre-impl/` | `collect-screening-results`, `reconcile-status`, `build-dependency-graph`, `check-cross-spec-overlap`, `write-work-state`, `yield-to-assemble-work` |
| `screen/` | `screen-gate1-<issue_number>`, `screen-gate2-<issue_number>` |

## Constraints

- Each section appears at most once per work state file (except `screen-gate1-`/`screen-gate2-` which are per-issue).
- Task results MUST be compact (≤500 words per section).
- Status transitions: `pending → in_progress → done | failed | skipped`.
- Failed tasks set `status: failed` with error detail in `result.error`.

## `for_analysis` Scope Constraints

When `authorization_scope == "for_analysis"`:

```yaml
## for_analysis-constraints
scope: for_analysis
for_analysis_allowlist:
  - reads (files, code, issues)
  - writes to ./tmp/
  - issue creation and comments
  - investigate/<topic> scratch branches (discard before HALT)
  - test and verification execution
for_analysis_blocklist:
  - writes to src/ or test/
  - feature/* or spec/* branches
  - PR creation
  - dev/main commits
  - bug fixes
  - deleting branches (except investigate/* discard)
investigate_branches_created: []
must_discard_before_halt: true
```

The `investigate_branches_created` field tracks which `investigate/` branches were created during the session. The orchestrator MUST verify every tracked branch is deleted before yielding or halting.

## Orchestrator Context Audit

Every work state file MUST include an Orchestrator Context Audit section. This section tracks whether the orchestrator stayed within its routing role or performed inline work.

```yaml
## orchestrator-context-audit
skill_files_loaded: []
issues_read_inline: []
git_commands_inline: []
sub_agent_dispatches: 0
inline_work_detected: false
```

| Field | Description |
|-------|-------------|
| `skill_files_loaded` | List of SKILL.md files read by the orchestrator for routing metadata (should be routing metadata only) |
| `issues_read_inline` | List of issue numbers read by the orchestrator inline (should be empty — sub-agents read issues) |
| `git_commands_inline` | List of git commands run by the orchestrator inline (should be empty — sub-agents run git) |
| `sub_agent_dispatches` | Count of sub-agent dispatches performed (should be > 0 for any non-trivial workflow) |
| `inline_work_detected` | Boolean flag: `true` if orchestrator performed file operations, analysis, or verification inline (CRITICAL VIOLATION if true) |

**Audit enforcement:**
- If `inline_work_detected == true`, the orchestrator MUST HALT and report a CRITICAL VIOLATION per `000-critical-rules.md` §Inline Work.
- `skill_files_loaded` should contain only SKILL.md files for routing; reading task files or full enforcement documents is inline work.
- `issues_read_inline` tracks issue body reads by the orchestrator; issue reading MUST be delegated to screen-issue sub-agents.
- `git_commands_inline` tracks git operations by the orchestrator; git operations MUST be delegated to git-workflow sub-agents.