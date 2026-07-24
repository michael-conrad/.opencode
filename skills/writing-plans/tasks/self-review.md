---
name: self-review
purpose: "Scan plan for placeholder patterns, SC coverage gaps, type/name inconsistencies, and verify every task follows every step from the implementation-pipeline's per-task cycle"
entry_gate: plan_exists
returns: "{status, artifact_path, finding_summary}"
---

# Task: self-review

## Purpose

Scan the plan at `{issues_prefix}/{N}/plan.md` for placeholder patterns, SC coverage gaps, type/name inconsistencies, and verify every task follows every step from the implementation-pipeline's per-task cycle.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The plan file must exist at `{issues_prefix}/{N}/plan.md`
  - If missing: return BLOCKED with `PLAN_NOT_FOUND`
- The spec file must exist at `{issues_prefix}/{N}/spec.md`
  - If missing: return BLOCKED with `SPEC_NOT_FOUND`
- The issue number `{N}` must be provided
- The project root and issues prefix must be set

## Procedure

1. **Load the implementation-pipeline TDT.** Call `skill({name: "implementation-pipeline"})` and read the Trigger Dispatch Table. Extract the per-task cycle steps — these are the rows that form the RED→GREEN→COMMIT cycle for a single task. The TDT is the single authoritative source for what steps exist. Do NOT hardcode or assume any step ordering.

2. **Read the plan file** from `{issues_prefix}/{N}/plan.md`. Extract all task sections and their step lists.

3. **Placeholder detection.** Scan the plan body for each of the following placeholder patterns:
   - `TODO`, `FIXME`, `XXX` markers
   - `{{...}}` or `{...}` template variables that were not resolved
   - `<...>` angle-bracket placeholders (e.g., `<description>`, `<path>`)
   - `[...]` bracketed gaps (e.g., `[add details]`, `[TBD]`)
   - `lorem ipsum` or other dummy text
   - Empty checkbox items (`- [ ] ` with no following text)
   - Vague or non-actionable descriptions (e.g., "handle edge cases" without specifying which)
   - For each placeholder found: record as a finding with file path, line reference, and placeholder type.

4. **SC coverage check.** Read the spec file from `{issues_prefix}/{N}/spec.md` and extract all success criteria IDs (SC-1, SC-2, etc.). Then:
   - Verify every SC from the spec is referenced in at least one phase or task in the plan.
   - Verify no SC is referenced in a phase that cannot satisfy its evidence type (e.g., a `behavioral` SC assigned to a structural-only phase).
   - For each uncovered SC: record as a finding with `SC_NOT_COVERED`.
   - For each evidence-type mismatch: record as a finding with `EVIDENCE_TYPE_MISMATCH`.

5. **Type/name consistency check.** Scan the plan for:
   - Inconsistent skill names (same skill referenced with different casing or spelling)
   - Inconsistent task names (same task referenced with different names)
   - Mismatched file paths (paths that don't match the project's actual file structure)
   - Mismatched dispatch indicators (steps marked `(**inline**)` that should be `(**sub-agent**)` or vice versa)
   - For each inconsistency: record as a finding with the specific type.

6. **Per-task cycle verification.** For every task in every phase:
   - Compare the task's step list against the per-task cycle from the implementation-pipeline TDT (loaded in step 1).
   - Verify every step from the per-task cycle is present in the task.
   - Verify no steps are combined (e.g., a single checkbox item covering both RED and GREEN).
   - Verify no steps are skipped (e.g., missing Z3 check, missing doublecheck, missing enforcement).
   - Verify the step ordering matches the TDT ordering.
   - For each missing step: record as a finding with `MISSING_STEP` and the step name.
   - For each combined step: record as a finding with `COMBINED_STEP`.
   - For each out-of-order step: record as a finding with `OUT_OF_ORDER_STEP`.

7. **Write the review artifact** to `{issues_prefix}/{N}/artifacts/self-review.yaml`:
   - Placeholder findings list
   - SC coverage findings list
   - Type/name inconsistency findings list
   - Per-task cycle findings list
   - Overall verdict: PASS (no findings) or BLOCKED (any finding)

8. **Return the result contract.**
   - If any finding exists: return BLOCKED with `SELF_REVIEW_FAILED` and a summary of findings.
   - If no findings: return DONE with PASS verdict.

## Exit Criteria

- The plan has been scanned for placeholder patterns
- All SCs from the spec have been checked for coverage in the plan
- Type/name consistency has been verified across the plan
- Every task's step list has been verified against the implementation-pipeline per-task cycle
- The review artifact has been written to `{issues_prefix}/{N}/artifacts/self-review.yaml`
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing placeholder count, SC coverage gaps, type/name issues, and per-task cycle violations>"
artifact_path: "<{issues_prefix}/{N}/artifacts/self-review.yaml>"
blocker_reason: "<SELF_REVIEW_FAILED + summary of findings if BLOCKED>"
```
