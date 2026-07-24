---
name: create
purpose: "Write self-contained plan with full implementation-pipeline workflow per task"
entry_gate: structure_artifact
returns: "{status, artifact_path, finding_summary}"
---

# Task: create

## Purpose

Generates a structured implementation plan from the structure artifact. The plan is structured markdown with English instructions. Every task in every phase enumerates every step from the implementation-pipeline's per-task cycle — no skipping, no combining, no grouping.

The per-task cycle steps are discovered at runtime by loading the `implementation-pipeline` skill and reading its Trigger Dispatch Table. The plan writer MUST NOT embed a hardcoded copy of the workflow.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The structure artifact must exist at `{issues_prefix}/{N}/artifacts/structure.yaml`
- The spec file must exist at `{issues_prefix}/{N}/spec.md`

## Procedure

1. **Load the implementation-pipeline TDT.** Call `skill({name: "implementation-pipeline"})` and read the Trigger Dispatch Table. Extract the per-task cycle steps — these are the rows that form the RED→GREEN→COMMIT cycle for a single task. The TDT is the single authoritative source for what steps exist. Do NOT hardcode or assume any step ordering.

2. **Read the structure artifact** from `{issues_prefix}/{N}/artifacts/structure.yaml`.
   - If missing: return BLOCKED with `STRUCTURE_ARTIFACT_NOT_FOUND`.
   - Extract: phase list, phase DAG, concern-to-phase mapping, SC-to-phase mapping, skill+task dispatch references per phase.

3. **Read the spec file** from `{issues_prefix}/{N}/spec.md` to extract all success criteria with their evidence types.

4. **Build the plan frontmatter.** Write YAML frontmatter with:
   - `plan_schema_version: "1.0"`
   - `issue: {N}`
   - `title: "<short description>"`
   - `dispatch:` array — one entry per phase with `phase`, `skill`, `task` references from the structure artifact.

5. **Build the plan body.** For each phase from the structure artifact:
   - Write a phase heading with concern and SC coverage.
   - For each task in the phase, enumerate every step from the implementation-pipeline's per-task cycle (discovered in step 1). Each step gets its own checkbox list item with:
     - Step name and description
     - Dispatch indicator: `(**inline**)`, `(**sub-agent**)`, or `(**clean-room**)`
     - Context parameters as dash sub-bullets
   - Every task MUST enumerate every step from the per-task cycle. No skipping. No combining. No grouping.

6. **Write pre-implementation steps** at the start of the plan (before any phase):
   - Coherence gate step
   - Baseline check step
   - These appear once per plan, not per phase.

7. **Write post-implementation steps** at the end of the last phase:
   - Structural checks, verification, audit, cross-validate, review-prep, PR creation, completion.
   - These appear once per plan, not per phase.

8. **Write the plan to disk** at `{issues_prefix}/{N}/plan.md`:
   - Frontmatter with dispatch metadata.
   - Pre-implementation section.
   - Phase sections with per-task per-step enumeration.
   - Post-implementation section.
   - Use structured markdown: checkbox lists with dash sub-bullets for context parameters.
   - No machine-parseable cross-references, no identifier IDs (REQ-001, TASK-001), no JSON/YAML code blocks in the body.
   - English text only — the plan is read by the orchestrator, not parsed.

9. **Return the result contract.**

## Exit Criteria

- The plan has been written to `{issues_prefix}/{N}/plan.md`
- The plan frontmatter contains `dispatch:` array with skill+task refs per phase
- Every task in every phase enumerates every step from the implementation-pipeline per-task cycle
- All SCs are mapped to at least one phase
- No circular dependencies in the phase DAG
- The plan uses structured markdown: checkbox lists with dash sub-bullets
- No machine-parseable cross-references, no identifier IDs, no JSON/YAML code blocks in the body
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing phase count, task count, and SC coverage>"
artifact_path: "<{issues_prefix}/{N}/plan.md>"
blocker_reason: "<reason if BLOCKED>"
```
