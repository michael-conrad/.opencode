# Task: validate — Spec verification pipeline

## Category

VERIFICATION

## Purpose

Run the 11-dimension holistic self-check and structural validation (SC completeness, evidence types, traceability) on a completed spec. Produce PASS/FAIL verdict per check. This task does NOT perform analysis steps or production steps.

## Entry Criteria

- [ ] `issue_number` and `spec_path` received in dispatch context
- [ ] No producer context, orchestrator reasoning, or expected outcomes in the prompt
- [ ] Spec file exists at `{spec_path}`
- [ ] Spec has all required sections (Objective, Background, SCs, Requirements, Phases, Traceability)

## Procedure

### Step 1: Read spec

Read the full spec from `{spec_path}`.

### Step 2: Run 11-dimension holistic self-check

Evaluate the spec against all 11 holistic dimensions:

| # | Dimension | What to Check |
|---|-----------|---------------|
| 1 | **Completeness** | All required sections present (Objective, Background, SCs, Requirements, Phases, Traceability, Dependencies) |
| 2 | **Clarity** | Each SC is unambiguous, testable, and has a single interpretation |
| 3 | **Consistency** | No internal contradictions between sections, SCs, and requirements |
| 4 | **Correctness** | All factual claims verified against codebase (file paths, function names, config values) |
| 5 | **Feasibility** | Each SC is achievable with available tools and within project constraints |
| 6 | **Testability** | Each SC has a clear verification method matching its evidence type |
| 7 | **Traceability** | Every requirement maps to ≥1 SC, every SC maps to ≥1 phase, every phase maps to ≥1 requirement |
| 8 | **Atomicity** | Every SC is a single independently verifiable claim (no compound SCs) |
| 9 | **Evidence type correctness** | Each SC's evidence type matches its verification method per the Evidence Type Taxonomy |
| 10 | **Scope fidelity** | Spec does not exceed or contradict the problem statement and requirements |
| 11 | **Clean-room compliance** | No task file contains task() or skill() calls; sub-agent context is scoped per spec |

For each dimension, produce a PASS or FAIL verdict with a brief justification.

### Step 3: Run structural validation

Check:

- **SC completeness:** Every SC has an ID, Criterion, Evidence Type, and Verification Method
- **Evidence type validity:** Every evidence type is one of `behavioral`, `semantic`, `string`, `structural`
- **Traceability completeness:** Every requirement appears in the Traceability table; every SC appears in the Traceability table
- **Phase coverage:** Every phase has REQ references in its heading
- **No orphaned sections:** No section that is required but empty or missing

### Step 4: Produce verdict

Aggregate all dimension and structural check results:

- **PASS** — All checks pass
- **FAIL** — One or more checks fail (include which checks failed and why)

## Exit Criteria

- [ ] All 11 holistic dimensions evaluated with PASS/FAIL per dimension
- [ ] Structural validation complete
- [ ] Aggregate verdict produced
- [ ] No spec content written, no analysis performed, no remote issue operations

## Result Contract

```yaml
status: DONE | BLOCKED
verdicts:
  - check_name: "completeness"
    result: PASS | FAIL
    justification: "Brief explanation"
  - check_name: "clarity"
    result: PASS | FAIL
    justification: "Brief explanation"
  # ... all 11 dimensions + structural checks
aggregate_verdict: PASS | FAIL
finding_summary: "Summary of all check results, key failures if any"
blocker_reason: "If BLOCKED: why validation could not complete"
```
