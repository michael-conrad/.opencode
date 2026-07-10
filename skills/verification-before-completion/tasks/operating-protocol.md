# Verification Before Completion Operating Protocol

## Entry Criteria

- Task completion claimed or SC verification requested
- Spec SC list and file paths available

## Procedure

- [ ] 1. **Structural completeness first:** verify all specified files/components exist before SC verification.
- [ ] 1a. **Analytical artifact presence gate:** Before SC verification, verify that all analytical artifacts required by the spec exist at their expected paths. Analytical artifacts include: `blast-radius.yaml`, `concern-map.yaml`, `code-path-inventory.yaml`, `cross-cutting-matrix.yaml`, `interface-compatibility.yaml`, `state-analysis.yaml`, `testability-assessment.yaml`. Each artifact is checked for file existence and valid YAML. If any artifact is missing or invalid, HALT and report the missing artifact(s).
- [ ] 1b. **Analytical artifact coverage gate:** After artifact presence is confirmed, verify that each analytical artifact's claims are covered by at least one success criterion. Cross-reference artifact claims against the SC table. Any claim with zero matching SCs is flagged as `ANALYTICAL_COVERAGE_GAP` with FAIL verdict. Resolve by adding SCs or documenting out-of-scope claims before proceeding.
- [ ] 2. **Adversarial-audit call:** during verify task, call `audit --task drift-detection --issue <N>` with `audit_phase: implementation_verification` to check spec/code reality alignment.
- [ ] 3. **Per-SC evidence table:** every SC must produce a tool-call artifact with PASS/FAIL.
- [ ] 4. **Exact comparison:** external verifications use exact mode. No "functionally equivalent" soft-passes.
- [ ] 5. **Live-source only:** evidence from memory/training data is FORBIDDEN. Tool-call artifact required.
- [ ] 6. **Clean-room routing:** verification sub-agents receive ONLY spec SC list + file paths. No implementation context, no prior results.
- [ ] 7. **Behavioral test evaluation:** After `behavior_run` produces artifacts, the orchestrator MUST dispatch `behavioral-test-evaluation` to evaluate artifacts via clean-room sub-agents. "Artifact generated" is NOT a valid PASS verdict for behavioral SCs. **This gate is enforced procedurally in `verify.md` Step 2 (evidence type classification) and Step 2b (Behavioral Test Evaluation Gate).** The verify.md workflow is the canonical source — this protocol entry is a cross-reference.
- [ ] 8. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

### Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Exit Criteria

- All SCs verified with evidence artifacts
- Behavioral tests evaluated (if applicable)
- Evidence table produced
