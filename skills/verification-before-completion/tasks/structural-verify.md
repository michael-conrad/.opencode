# Task: structural-verify

Clean-room structural completeness verification. This task MUST be task()'d as a sub-agent to ensure isolation from implementation context.

## Purpose

Verify that ALL structural components required by the spec are present in the implementation files, BEFORE checking individual success criteria evidence. This prevents the "partial implementation verified as complete" pattern from Bug #87.

## Entry Criteria

- Implementation claimed complete
- Spec or plan issue available with structural component requirements, or `spec_local_dir` provided for local spec access
- Target skill/guideline files exist

## Exit Criteria

- All required structural components verified present or missing reported
- Per-component PASS/FAIL table produced
- If ANY component missing: verification FAILS, implementation phase blocked

## Clean-Room Task() Protocol (MANDATORY)

This task MUST be task()'d as a sub-agent receiving ONLY:

- [ ] 1. **spec_local_dir** — REQUIRED path(s) to local issue directories containing spec.md. If absent: BLOCKED with MISSING_INPUT_DIR.
- [ ] 2. **Target files** — list of files that were modified during implementation
- [ ] 3. **Required structural components** — list derived from parent spec's requirements

The sub-agent MUST NOT receive:
- Implementation context (what was done, how it was done)
- Agent's own reasoning about the implementation
- Cached values from the implementation phase

## Verification Procedure

### Step 1: Parse Required Components

From the spec issue, extract the list of required structural components. Use `vbc_artifact_path` (defaults to `{project_root}/tmp/{issue-N}/artifacts/`) as the canonical base for all artifact paths — not bare `{project_root}/tmp/`:

| Component | Where to Check | Failure Class |
|-----------|---------------|---------------|
| `state_machines` | yaml+symbolic block | MISSING-STRUCTURE |
| `state_machines.*.decomposition_guard` | yaml+symbolic block | MISSING-STRUCTURE |
| `evidence_artifacts` | yaml+symbolic block | MISSING-STRUCTURE |
| `gates` | yaml+symbolic block | MISSING-STRUCTURE |
| `gates.*.condition` | yaml+symbolic block | MISSING-STRUCTURE |
| `gates.*.on_fail` | yaml+symbolic block | MISSING-STRUCTURE |
| `decomposition` | yaml+symbolic block | MISSING-STRUCTURE |
| `decomposition.*.mandatory` | yaml+symbolic block | MISSING-STRUCTURE |
| `decomposition.*.bypass_violation` | yaml+symbolic block | MISSING-STRUCTURE |
| `tasks` | yaml+symbolic block | MISSING-STRUCTURE |
| `tasks.*.mandatory` | yaml+symbolic block | MISSING-STRUCTURE |
| `tasks.*.bypass_violation` | yaml+symbolic block | MISSING-STRUCTURE |
| `blast_radius` | `{project_root}/tmp/{issue-N}/artifacts/blast-radius.yaml` | MISSING-STRUCTURE |
| `concern_map` | `{project_root}/tmp/{issue-N}/artifacts/concern-map.yaml` | MISSING-STRUCTURE |
| `code_path_inventory` | `{project_root}/tmp/{issue-N}/artifacts/code-path-inventory.yaml` | MISSING-STRUCTURE |
| `cross_cutting_matrix` | `{project_root}/tmp/{issue-N}/artifacts/cross-cutting-matrix.yaml` | MISSING-STRUCTURE |
| `interface_compatibility` | `{project_root}/tmp/{issue-N}/artifacts/interface-compatibility.yaml` | MISSING-STRUCTURE |
| `state_analysis` | `{project_root}/tmp/{issue-N}/artifacts/state-analysis.yaml` | MISSING-STRUCTURE |
| `testability_assessment` | `{project_root}/tmp/{issue-N}/artifacts/testability-assessment.yaml` | MISSING-STRUCTURE |

### Step 2: Read Target Files Fresh

For each file path in the task context:

- [ ] 1. Read the file using the `read` tool (NOT from cache or memory)
- [ ] 2. Extract the yaml+symbolic block
- [ ] 3. Parse YAML structure

### Step 3: Component-by-Component Verification

| Component | Present? | Evidence |
|-----------|----------|----------|
| state_machines | YES/NO | Line range or "absent" |
| state_machines.decomposition_guard | YES/NO | Field found or "absent" |
| evidence_artifacts | YES/NO | Section found or "absent" |
| gates | YES/NO | Section found or "absent" |
| decomposition | YES/NO | Section found or "absent" |
| tasks.mandatory fields | YES/NO | Field count or "absent" |
| blast_radius | YES/NO | File exists or "absent" |
| concern_map | YES/NO | File exists or "absent" |
| code_path_inventory | YES/NO | File exists or "absent" |
| cross_cutting_matrix | YES/NO | File exists or "absent" |
| interface_compatibility | YES/NO | File exists or "absent" |
| state_analysis | YES/NO | File exists or "absent" |
| testability_assessment | YES/NO | File exists or "absent" |

### Step 4: Report Results

```markdown
## Structural Completeness Report

**Spec:** #N
**Files Verified:** N

| Component | Status | Evidence |
|-----------|--------|----------|
| state_machines | ✅ PASS | Lines X-Y |
| state_machines.decomposition_guard | ✅ PASS | Found in state M |
| evidence_artifacts | ❌ FAIL | Section absent |
| gates | ✅ PASS | Lines X-Y |
| decomposition | ❌ FAIL | Section absent |
| tasks.mandatory | ✅ PASS | N tasks have mandatory field |
| blast_radius | ✅ PASS | File exists at blast-radius.yaml |
| concern_map | ✅ PASS | File exists at concern-map.yaml |
| code_path_inventory | ❌ FAIL | File absent |
| cross_cutting_matrix | ✅ PASS | File exists at cross-cutting-matrix.yaml |
| interface_compatibility | ✅ PASS | File exists at interface-compatibility.yaml |
| state_analysis | ❌ FAIL | File absent |
| testability_assessment | ✅ PASS | File exists at testability-assessment.yaml |

### Overall: ❌ FAIL — 2 structural components missing
```

### Step 5: Decision Gate

- ALL components PASS → Return PASS, proceed to per-SC verification
- ANY component FAIL → Return FAIL, HALT verification, report missing components
- No yaml+symbolic block found → Return FAIL (structural verification impossible)

**⚠️ DISCLAIMER: Structural completeness verification confirms ONLY that implementation components exist — it does NOT verify behavioral correctness.** A component that passes structural verification (exists in the file, has the right fields, appears in the yaml block) may still fail behavioral verification (the test contains a bug, the function returns wrong values, the rule doesn't produce the expected agent behavior). Structural PASS is a prerequisite for behavioral verification, not a substitute.

### Analytical Artifact YAML Validation

For the 7 analytical artifact component types (`blast_radius`, `concern_map`, `code_path_inventory`, `cross_cutting_matrix`, `interface_compatibility`, `state_analysis`, `testability_assessment`), structural verification includes YAML validity checking:

- [ ] 1. For each analytical artifact file found, attempt to parse as valid YAML
- [ ] 2. If YAML parsing fails: report as `INVALID_YAML` with FAIL verdict
- [ ] 3. If YAML parsing succeeds: report as PASS with file path
- [ ] 4. If file is absent: report as `MISSING-STRUCTURE` with FAIL verdict

**Behavioral uplift exclusion:** Structural verification is valid ONLY for changes that do not affect runtime behavior. If the change affects runtime behavior, structural verification is `EVIDENCE_TYPE_MISMATCH` — uplift to behavioral is mandatory. Load [critical-rules-BEH-EV](guidelines/000-critical-rules.md).

## Adversarial Verification

Each structural component check MUST be verified by reading the actual file. Claims from memory or cached context are VERIFICATION-GAP findings.

| Claim | Verification | Problem Class |
|-------|-------------|---------------|
| "state_machines present" | `read` or `grep` confirms yaml block has state_machines key | VERIFICATION-GAP if unchecked |
| "evidence_artifacts present" | `read` or `grep` confirms section exists | MISSING-STRUCTURE if absent |
| "gates section present" | `read` or `grep` confirms gates array | MISSING-STRUCTURE if absent |

## Task Context Schema

```yaml
spec_local_dir: <path> | [<path>, ...]     # REQUIRED — local issue directories
artifact_evidence_dir: <path> | [<path>, ...]  # OPTIONAL — behavioral evidence directories
spec_issue: <N>
target_files: [<path_list>]
required_components: [<component_list>]
vbc_artifact_path: <path_to_vbc_artifacts>
authorization_scope: <scope_value>
halt_at: <pipeline_stage>
pipeline_phase: <current_phase_name>
```

## Result Contract

```yaml
status: PASS | FAIL
task: structural-verify
spec_issue: <N>
files_verified: <count>
components_passed: <count>
components_failed: <count>
missing_components: [<list>]
overall_result: PASS | FAIL
```