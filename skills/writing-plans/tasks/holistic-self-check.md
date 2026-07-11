# Task: holistic-self-check

<!-- Dimensions synced from .opencode/reference/holistic-dimensions.yaml -->
<!-- Sync locations: see cross-reference table in that file -->

## Purpose

Clean-room sub-agent evaluates a plan against the 11 plan dimensions defined in `.opencode/reference/holistic-dimensions.yaml`. Returns PASS/FAIL per dimension. Does NOT modify the plan — only evaluates.

## Entry Criteria

- Plan body (index + phase files) is available for evaluation
- `.opencode/reference/holistic-dimensions.yaml` exists and is readable

## Procedure

1. Read `.opencode/reference/holistic-dimensions.yaml` to load the 11 plan dimension definitions
2. Read the plan body (index file + all phase files)
3. For each of the 11 plan dimensions, produce a single PASS or FAIL with evidence:
   - **Implementability**: Can an agent execute this plan? Single clear sequence? Correct phase ordering? Resolved dependencies?
   - **Internal Consistency**: Does the plan contradict itself? Phase preconditions vs actions? Step outputs vs downstream inputs? Phase ordering vs dependency DAG?
   - **Completeness**: Are there gaps forcing the implementor to guess? Missing steps? Unspecified handoffs? Undefined terms? TBD/TODO markers?
   - **Scope Discipline**: Does the plan stay within the spec's boundaries? Phases implementing things the spec didn't ask for? Steps exceeding Files Affected?
   - **Testability**: Can every step be independently verified? Steps with no verification criteria? Subjective judgment steps?
   - **Escape Hatches**: Does the plan contain language that lets the agent short-circuit steps? Prohibited patterns: "skip if fails", "attempt X else Y" without criteria, "verify manually", "may need adjustment", "left to implementor", "TBD", "TODO", "if time permits", "simplify if needed"
   - **Provenance**: Are the plan's claims backed by evidence? Steps referencing files/functions without verification? Assertions about code state without tool-call evidence?
   - **Feasibility**: Can this plan actually be executed? Non-existent files/functions? Physically impossible phase ordering? Unavailable dependencies?
   - **Safety**: Does the plan have failure modes that could cause irreversible harm? Destructive operations without rollback plans? Data loss scenarios? Security vulnerabilities?
   - **Traceability**: Does every step connect to something else in a coherent chain? Steps not tracing to spec SCs? Phases not tracing to spec phases? Orphan steps?
   - **Correctness**: Does this plan actually implement the spec it claims to implement? Plan approach vs spec approach mismatch? Extra phases? Omitted required phases?

4. Return result contract:
   - `status`: `DONE` (all PASS) or `BLOCKED` (any FAIL)
   - `finding_summary`: Summary of PASS/FAIL per dimension
   - `artifact_path`: Path to evidence artifact
   - `blocker_reason`: If BLOCKED, list failing dimension IDs, names, and resolution guidance

## Exit Criteria

- All 11 dimensions evaluated
- Each dimension has a single PASS/FAIL verdict with evidence
- Plan is NOT modified
- Result contract returned to orchestrator

## Context Required

- `plan_context`: Plan body (index + phase files) to evaluate
- `.opencode/reference/holistic-dimensions.yaml`: Canonical dimension definitions
