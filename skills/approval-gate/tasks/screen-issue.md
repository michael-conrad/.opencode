# Task: screen-issue (Routing Document)

## Purpose

Per-issue screening for pre-implementation analysis. Screen a single approved issue against screening categories (already-implemented, superseded, moot, stale assumptions, partial implementation, revision status, meta/non-code, cross-issue sub-issue handling). Produce a compact result contract for cross-issue merge.

This is the primary screening gate between authorization verification and implementation dispatch. Every approved issue MUST pass through screen-issue before any implementation work begins.

## Key Principles

### Sub-Agent Dispatch (MANDATORY)

This task is a routing document — it delegates to two atomic gate tasks:
- `screen/screen-issue-gate1`: Steps 1-3 (read issue, screening categories, Gate 1)
- `screen/screen-issue-gate2`: Steps 4-10 (Gate 2, evidence audit, result contract)

The orchestrator MUST NOT perform screening inline. Sub-agent dispatch is mandatory regardless of approval set size.

### No Inline Screening

Loading issue bodies into the orchestrator's own context for screening is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Inline Screening of Authorization Sets. Every approved issue — whether 1, 2, or 20 — MUST be screened by a `screen-issue` sub-agent dispatched via `task(subagent_type="general")`.

## Gate Tasks

This task delegates to two atomic gate tasks executed sequentially:

| Gate Task | Concern | Steps |
|-----------|---------|-------|
| `screen/screen-issue-gate1` | Read issue, screening categories, Gate 1 (sub-issue enumeration) | Steps 1-3 |
| `screen/screen-issue-gate2` | Gate 2 (success criteria verification), cross-references, evidence audit GA-2–GA-4, sub-issue expansion, cross-issue handling, file/symbol extraction, result contract | Steps 4-10 |

## Chain

```
gate1 → gate2
```

Gate 1 classifies the issue and executes sub-issue enumeration. If the issue is an "already-implemented" candidate, Gate 1 MUST pass before gate2 runs. Gate 2 verifies success criteria, completes the evidence audit, and produces the final result contract.

**Chain-of-responsibility note:** Each gate task uses the work state file for inter-task I/O. Gate tasks read inputs from predecessor sections and write results to their own section per `enforcement/work-state-schema.md`.

## Entry Criteria

- Single issue number to screen (passed via dispatch context)
- Issue has been verified by `verify-authorization`
- User has explicitly authorized implementation
- `<github.owner>` and `<github.repo>` available from dispatch context

## Exit Criteria

- Issue classified into one screening category
- Gate 1 (sub-issue enumeration) executed if applicable
- Gate 2 (success criteria verification) executed if applicable
- Compact result contract produced (≈100-500 words, YAML-structured)

## Screening Categories

| Category | Meaning | Action |
|----------|---------|--------|
| `already-implemented` | All SCs verified as implemented in codebase | Auto-close with evidence |
| `superseded` | Newer spec exists that replaces this issue | Close as superseded, reference newer issue |
| `moot` | Issue no longer relevant (requirements changed) | Close as not_planned |
| `stale-assumptions` | Spec refers to outdated code/APIs | Flag for revision |
| `partial-implementation` | Some SCs implemented, others not | Screen partially-implemented SCs only |
| `revision` | Spec has been revised since authorization | Verify revision status |
| `meta` | Non-code issue (discussion, question, tracking) | Skip implementation |
| `ready` | Issue passes all screening and is ready for implementation | Proceed to assemble-work |

## Pre-Flight Checks

Before screening begins, verify:
1. `github.owner`, `github.repo`, `github.platform` are set in dispatch context
2. Issue number is a valid integer
3. Issue exists and is accessible via `github_issue_read`

## Enforcement References

- Evidence format + finding classification: see `enforcement/adversarial-verification.md`
- Scope parsing: see `enforcement/scope-parsing.md`
- Auto-dispatch routing: see `enforcement/auto-dispatch-table.md`
- Closed-issue verification: see `enforcement/closed-issue-verification.md`
- Sub-issue graph traversal: see `enforcement/sub-issue-graph-traversal.md`

## Result Contract

```yaml
status: DONE | BLOCKED | SKIP
task: screen-issue
issue_number: <N>
screening_category: <category>
screening_reason: <text>
gate1_result: <passed|failed|skipped>
gate2_result: <passed|failed|skipped>
sub_issues: [<N>, ...]
files_to_modify: [<path>, ...]
symbols_to_modify: [<symbol>, ...]
ready_for_implementation: bool
blocking_reason: <text|null>
```