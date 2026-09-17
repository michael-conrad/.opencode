# Task: backfill

## Purpose

Generates missing analytical artifacts from the spec body when spec-creation did not produce them, enabling retroactive plan creation for pre-existing specs.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The spec file must exist at `{issues_prefix}/{N}/spec.md`

## Procedure

1. Verify the spec file exists at `{issues_prefix}/{N}/spec.md`.
   - If missing: return BLOCKED with `SPEC_NOT_FOUND` and the resolved path.
2. Read the spec body and extract success criteria, affected files, and scope information.
3. Check for existing analytical artifacts at `{issues_prefix}/{N}/artifacts/`.
   - If all 7 artifacts exist: return DONE with no backfill needed.
   - If any artifact is missing: proceed to backfill.
4. For each missing artifact, backfill from the spec body:
   - `blast-radius.yaml`: Extract affected files from spec, verify each exists in codebase.
   - `concern-map.yaml`: Decompose SCs into concern groups, map each to a phase boundary.
   - `code-path-inventory.yaml`: List code paths implied by each SC.
   - `cross-cutting-matrix.yaml`: Identify SCs that span multiple concerns.
   - `interface-compatibility.yaml`: Check interface boundaries between affected modules. Include a `dependency_contract` section populated with concrete dependency data derived from the spec's affected files and success criteria (real sources, real targets, real type constraints) — not a placeholder schema template. `research.md` step 9 extracts this section into `{issues_prefix}/{N}/dependency-contract.yaml` for the solve/plan tools.
   - `state-analysis.yaml`: Identify state transitions required by each SC.
   - `testability-assessment.yaml`: Assign evidence types to each SC.
5. Write each backfilled artifact to `{issues_prefix}/{N}/artifacts/{name}.yaml`.
   - **Incremental-emission rule (R-18):** Emit each backfilled artifact immediately upon deriving it — one artifact per write. Do NOT batch-derive all missing artifacts and then emit them in a single large turn. Step 3's existing-artifact check already covers resumption: backfill only artifacts not yet on disk, without re-deriving artifacts already written.
   - **Skeleton-first write (R-21):** For each missing artifact, immediately after reading the spec's scope sections and BEFORE any grounding reads, write a minimal valid skeleton artifact to the target path — the YAML header plus empty placeholder sections, a few lines long. All subsequent work APPENDS to and refines the skeleton section-by-section, with one small write per section. Never accumulate a full artifact body across multiple reasoning turns before the first write. This rule refines the emission path only — grounding still occurs, only AFTER the skeleton write.
   - **Action-first transition rule (R-21):** When a write is due — the skeleton write or any section append/refine — the agent's next assistant action MUST be the write tool call itself. No restating what will be written, no summarizing what was derived, no pre-write verification prose between the decision to write and the write call.
6. Write the analysis summary to `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`.
   - Include: spec path, SC count, artifact status per artifact (existing or backfilled), scope summary.
7. **validate-yaml gate (R-13):** After the artifacts are written, run `./.opencode/tools/local-issues validate-yaml` over the affected repos (the root repo and, when the issue belongs to the `.opencode` submodule, the submodule repo via its qualified name). This gate is read-only — it NEVER mutates files.
   - The gate MUST be executed directly by the agent performing this task — do NOT delegate it to another agent and report the outcome second-hand. The result contract MUST include the literal gate invocation evidence: the exact command executed and its exit code (and, on exit 1, the malformed-file report lines). A prose claim that the gate ran, without the recorded command + exit code, is treated as gate-not-run: return BLOCKED (or re-run the gate and capture the evidence).
   - Exit 0 → continue to step 8.
   - Exit 1 → return the BLOCKED result contract with `blocker_reason: VALIDATE_YAML_FAILED`, naming each malformed file with its path and the error class from the report line. Do NOT fix or rewrite the malformed files.
8. Return the result contract.

## Exit Criteria

- The spec file has been verified to exist
- All 7 analytical artifacts exist (either pre-existing or backfilled)
- The analysis summary has been written to `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`
- validate-yaml gate (R-13) executed directly by this agent after artifact generation, with the gate command + exit code recorded in the result contract — or BLOCKED with `VALIDATE_YAML_FAILED` naming malformed files
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing artifact status and backfill actions>"
artifact_path: "<{issues_prefix}/{N}/artifacts/analysis-summary.yaml>"
gate_evidence: "validate-yaml gate invocation: exact command executed and its literal exit code (and, on exit 1, the malformed-file report lines). A result contract without this evidence is treated as gate-not-run."
blocker_reason: "<reason if BLOCKED (e.g., VALIDATE_YAML_FAILED — lists malformed file paths and error classes from the validate-yaml report)>"
```
