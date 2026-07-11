# Task: holistic-self-check

<!-- Dimensions synced from .opencode/reference/holistic-dimensions.yaml -->
<!-- Sync locations: see cross-reference table in that file -->

## Purpose

Evaluate a spec against the 11-dimension holistic semantic gate before finalization. This is a clean-room sub-agent dispatch — the sub-agent reads the spec independently and produces a PASS/FAIL verdict per dimension. If any dimension FAILs, the spec must be returned to the create task for revision.

## Entry Criteria

- Spec body is assembled (all sections present)
- Spec is not yet finalized or posted to the remote issue
- `.opencode/reference/holistic-dimensions.yaml` exists (loaded from #1850)

## Exit Criteria

- Each of the 11 dimensions receives a single PASS/FAIL verdict
- If all 11 PASS: spec is ready for finalization
- If any FAIL: spec is returned to create task with failed dimensions listed and resolution guidance

## Procedure

- [ ] 1. **Load dimension definitions** — Read `.opencode/reference/holistic-dimensions.yaml` to load the canonical 11 spec dimensions with their questions and checks.

- [ ] 2. **Read the spec** — Read the full spec body from the local `.issues/{N}/spec.md` file. Read all sections: preamble, problem statement, root cause analysis, alternatives considered, safety considerations, success criteria, traceability table, feasibility assessment, constraints, dependencies, and any other content.

- [ ] 3. **Evaluate each dimension** — For each of the 11 dimensions, produce a single PASS/FAIL verdict. The sub-agent reads the full spec and judges independently — no grep, no pattern matching, no checklist. Each dimension is a semantic question:

    | # | Dimension | Question |
    |---|-----------|----------|
    | 1 | **Implementability** | Can an agent produce correct output from this spec? Does the spec present exactly one approach, or multiple competing approaches? Are the success criteria unambiguous? Would any reasonable implementor produce the same output? |
    | 2 | **Internal Consistency** | Does the spec contradict itself across sections? Preamble vs body alignment. SCs vs constraints. Files Affected vs phases. Causal chain coherence (problem → root cause → fix approach → SCs). |
    | 3 | **Completeness** | Are there gaps forcing the implementor to guess? Undefined terms in SCs. Missing SCs for stated goals. Implicit dependencies. "TBD"/"TODO" markers. Unspecified handoffs between phases. |
    | 4 | **Scope Discipline** | Does the spec stay within its stated boundaries? Unbounded requirements. Scope creep in phases. Blast radius mismatch (small problem → massive fix, or vice versa). |
    | 5 | **Testability** | Can every SC be independently verified? Untestable SCs ("must be intuitive", "should feel responsive"). Subjective judgment SCs. Circular verification. Evidence type mismatch (behavioral SC with structural evidence declared). |
    | 6 | **Escape Hatches** | Does the spec contain language that lets the agent short-circuit requirements? "Use best judgment", "implementer's discretion", "if time permits", "stretch goal", "may be deferred", "simplify if needed", "reduce scope if complex", "as appropriate", "as needed" (without criteria), "preferably", "ideally", "should" (weasel words), "TBD", "TODO", "to be determined", "left to implementor", "implementor's choice", "consider X" (without mandating it), "optionally", "if desired". |
    | 7 | **Provenance** | Are the spec's claims backed by evidence? Unsupported factual assertions ("the API supports X" without verification). Claims about code state without tool-call evidence. References to files/functions that haven't been verified to exist. Assertions about behavior without source. |
    | 8 | **Feasibility** | Can this actually be done with available tools and constraints? References to files/functions/libraries that don't exist. Requirements that exceed available infrastructure. Phase ordering that is physically impossible. Dependencies that are unavailable. |
    | 9 | **Safety** | Does the spec have failure modes that could cause irreversible harm? Destructive operations without rollback plans. Data loss scenarios. Security vulnerabilities introduced by the change. Operations that cannot be undone. Changes to production data without safeguards. |
    | 10 | **Traceability** | Does every element connect to something else in a coherent chain? Orphan SCs that don't trace to any root cause. Root causes with no SCs testing them. Phases that don't trace to any SC. Steps that don't trace to any phase. Forward traceability (root cause → SC → phase → step) and backward traceability (step → phase → SC → root cause) must both be coherent. |
    | 11 | **Correctness** | Does this spec actually solve the right problem? Preamble describes problem X but SCs test problem Y. Root cause analysis identifies cause A but fix approach targets cause B. The spec's stated problem doesn't match the actual defect it claims to fix. The spec addresses a symptom, not the root cause. |

- [ ] 4. **Produce verdict** — Return a structured verdict:

    ```yaml
    holistic_self_check:
      status: PASS | FAIL
      dimensions:
        - id: 1
          name: Implementability
          verdict: PASS | FAIL
          finding: "<brief finding>"
        - id: 2
          name: Internal Consistency
          verdict: PASS | FAIL
          finding: "<brief finding>"
        # ... all 11 dimensions
      failed_dimensions:
        - id: <N>
          name: "<dimension name>"
          finding: "<what failed>"
          resolution: "<what needs to be fixed>"
      artifact_path: "{project_root}/tmp/{issue-N}/holistic-self-check.yaml"
    ```

- [ ] 5. **If all PASS** — Return `status: DONE` with the verdict artifact. Spec is ready for finalization.

- [ ] 6. **If any FAIL** — Return `status: BLOCKED` with `reason: HOLISTIC_GATE_FAILED`. Include the failed dimensions, findings, and resolution guidance in the result contract. The orchestrator will route back to the create task for revision.

## Context Required

- `spec_context` — The spec body or path to the local spec file
- `issue_number` — The issue number for artifact paths
- `project_root` — For resolving artifact output paths

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "Holistic self-check: <N>/11 PASS, <M>/11 FAIL. Failed: <dimension names>"
artifact_path: "{project_root}/tmp/{issue-N}/holistic-self-check.yaml"
blocker_reason: "HOLISTIC_GATE_FAILED: <dimension names> failed. See artifact for details."  # if BLOCKED
```
