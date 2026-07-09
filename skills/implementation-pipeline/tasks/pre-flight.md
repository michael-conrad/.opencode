# Pre-Flight

## Entry Criteria

- Plan is approved and ready for pipeline dispatch
- Authorization scope is `for_implementation` or above

## Procedure

Before the pipeline dispatches to `sc-coherence-gate`, the orchestrator MUST run plan-to-pipeline handoff verification:

- [ ] 1. **Plan-to-pipeline handoff:** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state, verification gate preservation, and manifest writes at `{project_root}/tmp/{issue-N}/artifacts/plan-to-pipeline-handoff-*.yaml`
- [ ] 2. **Handoff-consistency check:** Reads both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests and compares shared variables (SC coverage total, decomposition classification, phase count). BLOCKs on mismatch.
- [ ] 3. **Submodule state check:** Resolve default branch via `git remote show origin | sed -n 's/.*HEAD branch: //p'`, then verify `git submodule status` shows submodules at that branch's tip. If submodules are stale, BLOCK and report `SUBMODULE-DRIFT`.
- [ ] 4. **Pre-flight PASS required:** The pipeline MUST NOT proceed to `sc-coherence-gate` (step 1) if pre-flight returns BLOCKED. This is a hard gate — no bypass path.

### Authorization Context

Every task context MUST include:

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

## Exit Criteria

- Pre-flight PASS confirmed
- Authorization context included in all task dispatches
