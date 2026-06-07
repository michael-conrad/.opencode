> **Full spec and artifacts: [`.issues/1061/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1061)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1061/spec-artifacts/` — card catalogue, solve contracts, SC coverage summary, lifecycle manifest, verification consistency contract, revision re-entry contract

## Intent and Executive Summary

**Problem Statement:** The artifact infrastructure layer — solve contracts, plan validations, SC coverage YAML, lifecycle manifests, blocker documentation, and verification consistency checks — currently exists as disconnected recommendations in the requirements analysis (#850). These capabilities must be codified as spec-level infrastructure: machine-parseable, permanent, append-only, and integrated into spec-creation and writing-plans at invocation time, not deferred to downstream verification gates.

**Root Cause / Motivation:** Spec artifacts are currently ad-hoc. Solve contracts are hand-written when needed. SC tables are prose-only. Lifecycle state is uncaptured. Blocker events vanish into chat logs. Without structured artifact infrastructure, downstream consumers (pipeline verification dispatchers, spec-auditors, plan authors) must re-parse prose on every invocation, introducing interpretation variance and EVIDENCE_TYPE_MISMATCH risk.

**Approach Chosen:** Eight coordinated changes across six concerns: (1) dependency ordering as Z3 constraint problems via `solve`, (2) pre-approval exit criteria gate expansion, (3) `solve` and `plan` utility invocations in spec-creation and writing-plans, (4) machine-parseable SC coverage YAML, (5) spec revision re-entry protocol as solve contract, (6) artifact retention policy, (7) lifecycle manifest as permanent tracked artifact, (8) blocker documentation protocol, (9) verification gate × evidence type consistency contract.

**Alternatives Considered & Why Discarded:**
- Single monolithic YAML file instead of per-artifact files — discarded: per-artifact files allow independent validation and avoid single-file merge conflicts
- No machine-parseable layer, keep prose-only — discarded: downstream consumers (pipeline, auditors) cannot parse prose reliably; EVIDENCE_TYPE_MISMATCH at every gate
- Runtime generation instead of spec-time artifact creation — discarded: artifacts must exist before the pipeline starts; runtime generation creates a chicken-and-egg problem for verification dispatchers

**Key Design Decisions:**
- DEC-1: All permanent artifacts under `.issues/{issue-N}/spec-artifacts/` — never cleaned, survives pipeline restarts
- DEC-2: All ephemeral artifacts under `./tmp/{issue-N}/` — cleaned at PR merge
- DEC-3: Lifecycle manifest is append-only — never overwrites, provides full audit trail
- DEC-4: Solve contracts are spec-level, not plan-level — dependency ordering is a spec concern
- DEC-5: Utility invocations happen at artifact creation time, not downstream verification — catches defects before the pipeline commits

**Decomposition Classification:** multi-phase

## Objective

Establish a permanent, machine-parseable artifact infrastructure layer integrated into spec-creation and writing-plans. Every spec SHALL produce structured artifacts that downstream consumers (pipeline verification dispatchers, spec-auditors, plan authors) read without parsing prose. Every artifact SHALL have a defined path, schema, retention policy, and validation method.

## Problem

Spec artifacts are currently produced as unstructured prose in issue bodies. Downstream consumers must parse Markdown tables to extract SC coverage, phase bindings, verification gates, and artifact paths. This introduces:

1. **Parsing variance** — two consumers reading the same spec may interpret the SC table differently
2. **No traceability** — blockers, lifecycle events, and revision state vanish after the issue is closed
3. **No structural validation** — SC tables with missing columns or inconsistent evidence types are not caught until verification step 8
4. **No dependency modeling** — phase ordering constraints are prose statements, not machine-checkable Z3 problems
5. **No retention policy** — artifacts from the spec and plan phases are cleaned with `./tmp/` at unpredictable intervals

## Context

This spec depends on the artifact underlay defined in [parent coordination issue #850](https://github.com/michael-conrad/.opencode/issues/850) and the pre-approval gate solve contract infrastructure established in [adjacent spec #1060](https://github.com/michael-conrad/.opencode/issues/1060). The `solve` utility at `.opencode/tools/solve` and `plan` utility at `.opencode/tools/plan` provide the computational infrastructure for constraint modeling and planning validation.

## Scope

### In Scope

- Dependency-ordering verification as Z3 solve contracts (item 10 from requirements analysis)
- Pre-approval exit criteria gate expansion with new column checks (item 21)
- `solve` and `plan` utility integration into spec-creation and writing-plans (item 22)
- Machine-parseable SC coverage summary YAML (item 24)
- Spec revision re-entry protocol as solve contract (item 29)
- Artifact retention policy (item 30)
- Spec lifecycle manifest (item 33)
- Blocker documentation protocol in lifecycle manifest (item 35)
- Verification gate × evidence type consistency contract (item 37)

### Non-Goals

- Implementation of pipeline verification dispatchers — those consume these artifacts but are specified separately
- Cross-repo artifact sync — all artifacts are local to the issue repo
- Artifact visualization or dashboard UI — artifacts are machine-parseable only
- Migration of existing specs to the new artifact format — applies to new specs only

## Affected Files

| File | Change | Anchor |
|------|--------|--------|
| `.opencode/skills/spec-creation/tasks/write.md` | Add `solve`/`plan` utility invocations after Step 5.5; add SC coverage YAML generation in Step 1; add artifact path column mandate; add verification consistency check in Step 6 | `spec-creation/tasks/write.md` §Procedure |
| `.opencode/skills/writing-plans/tasks/create.md` | Add `solve` model invocation for phase dependency ordering; add `plan` validation for phase solvability; add SC coverage YAML consumption substep | `writing-plans/tasks/create.md` §Steps 0-5 |
| `.opencode/skills/writing-plans/tasks/create/plan-structure.md` | Add phase dependency solve contract creation; add plan validation via `plan` utility; add SC-ID mapping substep | `plan-structure.md` §Procedure |
| `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` | Add spec-to-plan handoff artifact check; add SC coverage YAML cross-reference validation | `create-and-validate.md` §Procedure |
| `.opencode/skills/approval-gate/SKILL.md` | Expand pre-approval gate with new column checks (Pipeline Step Binding, Re-Entry Step, Verification Gate, Artifact Path, Phase Binding) | `approval-gate/SKILL.md` §Routing Rules |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Add artifact path convention, lifecycle manifest event emission points, artifact retention policy reference | `implementation-pipeline/SKILL.md` §Pipeline Steps |

## Affected Artifacts

| Artifact | Path | Type |
|----------|------|------|
| Dependency-ordering verification contract | `.issues/{issue-N}/spec-artifacts/dependency-ordering-verification/` | Solve contract |
| Pre-approval gate contract (expanded) | `.issues/{issue-N}/spec-artifacts/pre-approval-gate-contract.yaml` | Solve contract |
| Verification consistency contract | `.issues/{issue-N}/spec-artifacts/verification-consistency-contract.yaml` | Solve contract |
| Revision re-entry protocol contract | `.issues/{issue-N}/spec-artifacts/revision-re-entry-contract.yaml` | Solve contract |
| SC coverage summary | `.issues/{issue-N}/spec-artifacts/sc-summary.yaml` | YAML metadata |
| Lifecycle manifest | `.issues/{issue-N}/spec-artifacts/lifecycle.yaml` | Append-only YAML |
| Constraints contract | `./tmp/{issue-N}/artifacts/constraints-contract.yaml` | Solve contract (ephemeral) |
| Decomposition validation | `./tmp/{issue-N}/artifacts/decomposition-validation.yaml` | Plan validation (ephemeral) |
| Phase exit contract | `./tmp/{issue-N}/artifacts/phase-{N}-exit-contract.yaml` | Solve contract (ephemeral) |
| Phase plan validated | `./tmp/{issue-N}/artifacts/phase-plan-validated.yaml` | Plan validation (ephemeral) |

## Decision Ledger

| ID | Decision | Rationale | RFC 2119 Key |
|----|----------|-----------|-------------|
| DEC-1 | Permanent artifacts under `spec-artifacts/`, ephemeral under `./tmp/{issue-N}/` | PR merge cleanup removes `./tmp/`; `spec-artifacts/` survives pipeline restarts and branch switches | MUST |
| DEC-2 | Lifecycle manifest is append-only | Full audit trail for post-hoc inspection; no overwrite risk | MUST |
| DEC-3 | Solve contracts are spec-level, not plan-level | Dependency ordering is a spec concern; plan reads the contract, does not create it | MUST |
| DEC-4 | Utility invocations at artifact creation time, not downstream | Catches defects before pipeline commits; downstream gates only check, do not create | MUST |
| DEC-5 | SC coverage YAML is generated during spec assembly (Step 1), validated during self-review (Step 6) | Early generation allows downstream consumers to reference it throughout the lifecycle | MUST |
| DEC-6 | Blocker events are append-only entries in the lifecycle manifest, not separate files | Avoids artifact proliferation; single source of truth for all lifecycle state | MUST |
| DEC-7 | Verification consistency contract is a solve contract, not a prose table | Allows automated gate validation at spec-approval time without re-parsing | MUST |
| DEC-8 | Revision re-entry protocol is a solve contract | `solve check` returns SAT for valid re-entry plans, UNSAT for insufficient replay scope | MUST |

## Risk Traceability

| ID | Risk | Likelihood | Impact | Mitigation | Verifying SC | Pipeline Step |
|----|------|-----------|--------|------------|-------------|---------------|
| RISK-1 | Solve contract domain error (Z3 model mismatch with actual phase structure) | Medium | High | Pre-approval gate validates contract against SC table Phase Binding column | SC-1 | pre-approval-gate |
| RISK-2 | Lifecycle manifest drift (events not appended at correct pipeline stages) | Medium | Medium | Manifest append is a mandatory substep in each emitting pipeline stage's exit criteria | SC-6 | post-implementation-gate |
| RISK-3 | SC coverage YAML desync from prose SC table | Low | High | Self-review validation (Step 6) compares YAML vs prose; pre-approval gate re-checks | SC-4 | self-review, pre-approval-gate |
| RISK-4 | Revision re-entry protocol not consulted on spec revision | Low | High | approval-gate reads the contract before applying label; pre-approval gate re-runs on re-approval | SC-5 | approval-gate |
| RISK-5 | `solve` utility not installed or not runnable in agent environment | Medium | High | Fallback: agent models constraints manually and emits a WARNING in lifecycle manifest | SC-2, SC-3 | spec-creation, writing-plans |
| RISK-6 | Verification consistency contract not updated when SC evidence type changes | Low | Medium | Pre-approval gate re-reads the contract on every spec revision; mismatch = BLOCK | SC-8 | pre-approval-gate |
| RISK-7 | Ephemeral artifacts cleaned before pipeline completes | Low | High | Retention policy is documented and enforced by `implementation-pipeline` step preconditions | SC-7 | implementation-pipeline |

## Success Criteria

**All-or-nothing gate: ALL success criteria MUST pass for implementation to be considered complete. Behavioral verification IS completion — there is no valid state called "implemented but unverified." A verification step that runs a structural check (file exists, grep match) instead of a behavioral test is accepting the death spiral — behavioral testing is the break, structural-only is compounding exponential cost. Any SKIPPED SC is treated as FAIL. Any FAILED SC triggers autonomous remediation before proceeding.**

| ID | Criterion | Evidence Type | Verification Method | Artifact Path | Pipeline Step | Re-Entry Step | Remediation |
|----|-----------|---------------|-------------------|--------------|--------------|---------------|-------------|
| SC-1 | Dependency-ordering solve contract created and stored at `spec-artifacts/dependency-ordering-verification/` for multi-phase specs | `string` | `ls .issues/{issue-N}/spec-artifacts/dependency-ordering-verification/*.yaml` — confirm at least one YAML contract file exists | `.issues/{issue-N}/spec-artifacts/dependency-ordering-verification/` | spec-creation Step 5.5 | spec-creation | If missing: regenerate from phase structure during spec-creation. Re-verify with `ls`. |
| SC-2 | `solve` utility invoked during spec-creation after Step 5.5, producing constraints contract at `./tmp/{issue-N}/artifacts/constraints-contract.yaml` | `behavioral` | `./.opencode/tools/solve check --state-path ./tmp/{issue-N}/artifacts/constraints-contract.yaml --contract-path .issues/{issue-N}/spec-artifacts/pre-approval-gate-contract.yaml` — confirm SAT or documented UNSAT with WARNING in lifecycle manifest | `./tmp/{issue-N}/artifacts/constraints-contract.yaml` | spec-creation Step 5.5 | spec-creation | If solve check returns error: verify `solve` utility is installed. If utility unavailable: log WARNING in lifecycle manifest, model constraints manually in spec prose. |
| SC-3 | `plan` utility invoked during writing-plans after phase structure defined, validating phase solvability | `behavioral` | `./.opencode/tools/plan plan --problem ./tmp/{issue-N}/artifacts/phase-plan-problem.yaml` — confirm planner returns SOLVED_SATISFICING or SOLVED_OPTIMALLY | `./tmp/{issue-N}/artifacts/phase-plan-validated.yaml` | writing-plans Step 5 | writing-plans | If planner returns UNSOLVABLE: re-examine phase ordering, add missing action/precondition, re-run. If utility unavailable: log WARNING in lifecycle manifest. |
| SC-4 | Machine-parseable SC coverage summary YAML generated at `.issues/{issue-N}/spec-artifacts/sc-summary.yaml` during spec assembly, with all required fields per schema | `string` | `./.opencode/tools/solve check --state-path .issues/{issue-N}/spec-artifacts/sc-summary.yaml --contract-path .issues/{issue-N}/spec-artifacts/sc-summary-schema.yaml` — confirm valid parse; cross-reference `sc_coverage.total` against prose SC table row count | `.issues/{issue-N}/spec-artifacts/sc-summary.yaml` | spec-creation Step 1 | spec-creation | If YAML parse fails or total mismatch: regenerate from prose SC table during self-review. Re-verify. |
| SC-5 | Revision re-entry protocol solve contract created at `.issues/{issue-N}/spec-artifacts/revision-re-entry-contract.yaml` with cascade variables for each revision scope | `string` | `./.opencode/tools/solve model --contract-path .issues/{issue-N}/spec-artifacts/revision-re-entry-contract.yaml --query "revision_sc_mandates_rerun_pre_approval_gate == pre_approval_gate_required"` — confirm query is satisfiable | `.issues/{issue-N}/spec-artifacts/revision-re-entry-contract.yaml` | spec-creation Step 1 | spec-creation | If UNSAT: fix variable declarations or cascade constraints. Re-generate from Revision Policy prose section. |
| SC-6 | Lifecycle manifest created at `.issues/{issue-N}/spec-artifacts/lifecycle.yaml` with `spec_created` event; each pipeline stage appends its event. Blocker events appended on FAIL with severity, reason, and resolution | `string` | `grep -c "event: spec_created" .issues/{issue-N}/spec-artifacts/lifecycle.yaml` — confirm ≥1; `grep -c "event: blocker" .issues/{issue-N}/spec-artifacts/lifecycle.yaml` — confirm present if any pipeline gate returned FAIL | `.issues/{issue-N}/spec-artifacts/lifecycle.yaml` | spec-creation Step 1, post-implementation-gate | spec-creation | If missing: create initial manifest with `spec_created` event. If blocker events absent on FAIL: re-run emitting stage to append. |
| SC-7 | Artifact retention policy documented in `implementation-pipeline` SKILL.md: `./tmp/{issue-N}/` cleaned at PR merge, step-specific pre-cleanup at each pipeline step, `spec-artifacts/` never cleaned | `structural` | `grep "Artifact Retention" .opencode/skills/implementation-pipeline/SKILL.md` — confirm section exists with all three rules | (structural — no artifact) | implementation-pipeline | spec-creation | If section missing: add retention policy prose to SKILL.md. Re-verify with grep. |
| SC-8 | Verification consistency contract created at `.issues/{issue-N}/spec-artifacts/verification-consistency-contract.yaml` with compliance matrix as solve variables. Pre-approval gate validates every SC's Verification Gate against its Evidence Type. | `string` | `./.opencode/tools/solve check --state-path .issues/{issue-N}/spec-artifacts/verification-consistency-contract.yaml --contract-path .issues/{issue-N}/spec-artifacts/verification-consistency-contract.yaml` — confirm SAT for compliant specs, UNSAT with unsat_core for non-compliant | `.issues/{issue-N}/spec-artifacts/verification-consistency-contract.yaml` | spec-creation Step 1, pre-approval-gate | spec-creation | If UNSAT: identify non-compliant SC, fix Verification Gate or Evidence Type, re-run solve check. |

## Edge Cases

| Case | Handling |
|------|----------|
| **Single-task spec (no phases)** | No dependency-ordering solve contract needed. `sc-summary.yaml` sets `single_task: true`, all SCs in `phase: 1` or no phase binding. Revision re-entry protocol still generated. |
| **Solve utility unavailable** | Agent models constraints manually, writes them to the artifact path with a WARNING in lifecycle manifest. Pre-approval gate skip validation for UNSAT results. See RISK-5. |
| **Plan utility unavailable** | Agent validates phase solvability manually (acyclic check on phase ordering), writes manual validation result to `phase-plan-validated.yaml` with WARNING. |
| **Lifecycle manifest at spec creation with zero events** | Invalid — must have at least `spec_created`. SC-6 requires ≥1 `spec_created` event. |
| **Blocker events after spec closure** | Allowed — blocker can be appended post-issue-closure for audit trail completeness. |
| **Spec revision that changes SC count** | Revision re-entry protocol contract MUST be updated. Pre-approval gate BLOCKs if contract is stale (SC count mismatch between contract and revised spec). |
| **Pre-approval gate for for_spec scope** | Gate runs but does not block on missing columns that are standard/complex-only (Pipeline Step Binding, Re-Entry Step). Only minimal-tier requirements enforced. |
| **Cross-repo specs (submodule)** | Artifacts are local to the spec's repo — no cross-repo artifact sync. |
| **Multi-phase spec with common SCs** | `sc-summary.yaml` uses `phase: common` for cross-cutting SCs. Dependency-ordering contract excludes common SCs. |

## Dependencies

- [Parent coordination issue #850](https://github.com/michael-conrad/.opencode/issues/850) — Spec/Plan Writer Injection — provides the artifact infrastructure layer that this spec builds on
- [Adjacent spec #1060](https://github.com/michael-conrad/.opencode/issues/1060) — Pre-Existing Solve Contract — establishes the pre-approval gate contract that this spec expands
- `.opencode/tools/solve` — MUST be installed and runnable (Z3 solver)
- `.opencode/tools/plan` — MUST be installed and runnable (unified-planning)
- `spec-creation/tasks/write.md` — MUST exist and support Step 5.5 insertion point
- `writing-plans/tasks/create.md` — MUST exist and support phase structure definition substeps

## Risk

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Solve contract proliferation (too many contracts, maintenance burden) | Medium | Low | Only 4 permanent contracts (dependency-ordering, pre-approval, revision-re-entry, verification-consistency). Ephemeral contracts cleaned at PR merge. |
| Downstream consumer ignores artifacts (reads prose instead) | Low | Medium | Pipeline verification dispatchers consume artifacts by convention; spec-auditor validates artifact presence |
| YAML schema drift (spec-artifacts schema changes without updating consumers) | Medium | Medium | Self-review validation checks YAML against in-memory schema; pre-approval gate re-checks |
| Write amplification (every spec change touches 3+ artifact files) | High | Low | Artifacts are generated during spec assembly (Step 1), not hand-maintained. Write amplification is automation cost, not human cost. |

## Phases

### Phase 1: Permanent Artifact Creation (spec-creation changes)
- Create SC coverage YAML generation substep in Step 1
- Create verification consistency contract generation substep in Step 1
- Create lifecycle manifest initialization substep in Step 1
- Create revision re-entry protocol contract generation substep in Step 1
- Add `solve` utility invocation after Step 5.5
- Add artifact path column to SC table format
- Update self-review (Step 6) with YAML-vs-prose validation
- Update pre-approval gate contract with new column validation (expanded item 21)

### Phase 2: Plan-Level Artifact Consumption (writing-plans changes)
- Add phase dependency-ordering solve contract creation in plan-structure
- Add `plan` utility invocation for phase solvability validation
- Add SC-ID mapping substep consuming `sc-summary.yaml`
- Add spec-to-plan handoff artifact enumeration and validation
- Add spec-to-plan handoff manifest generation

### Phase 3: Pipeline Integration
- Add lifecycle manifest event emission points to implementation-pipeline steps
- Add artifact retention policy documentation to implementation-pipeline SKILL.md
- Add step-specific pre-cleanup substeps (clean previous-run artifacts at step start)

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `srclight_search_symbols("solve")` in `.opencode/tools/solve` | Verify solve utility actions (check, model, prove, state) |
| Direct source search | `srclight_search_symbols("plan")` in `.opencode/tools/plan` | Verify plan utility actions (plan, validate, ground, pddl, discover, state) |
| MCP search | `srclight_get_signature("_action_check")` in `solve` | Verify check action signature (state-path + contract-path) |
| MCP search | `srclight_get_signature("_action_plan")` in `plan` | Verify plan action signature (problem + engine parameters) |
| Local docs | `spec-creation/tasks/write.md` §Steps 1-6 | Verify insertion points for utility invocations |
| Local docs | `writing-plans/tasks/create.md` §Steps 0-5 | Verify phase structure definition substeps |
| Local docs | `approval-gate/SKILL.md` §Routing Rules | Verify pre-approval gate dispatch context |
| Local docs | `implementation-pipeline/SKILL.md` | Verify pipeline step labels for event emission |
| Requirements analysis | `tmp/spec-output-requirements-analysis.md` items 10, 21, 22, 24, 29, 30, 33, 35, 37 | Source requirements for all success criteria |

**Co-authored with AI: OpenCode (deepseek-v4-flash)**