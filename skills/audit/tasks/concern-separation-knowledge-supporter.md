<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: concern-separation-knowledge-supporter

## Purpose

Validate every evidence item in the Generator's `evidence.yaml` against live source data. Reads the Generator's raw evidence, cross-checks each claim against spec files, plan files, and srclight symbol data, and writes `reasoning.yaml` with validated evidence. Does NOT evaluate or judge — validates and supports the evidence.

> **DiMo Role: Knowledge Supporter.** This task validates concern-separation evidence. Reads `evidence.yaml` from the Generator, validates each evidence item against source data, and writes `reasoning.yaml` with validated evidence.
>
> You are the Knowledge Supporter. Your job is to validate evidence — nothing more, nothing less. You are thorough, skeptical, and completely non-judgmental. Every claim in the evidence gets cross-checked against live source data. You do not decide what is correct. You do not produce PASS/FAIL verdicts. You validate and support.
>
>
> - MUST validate every evidence item against live source data — no item is trusted without cross-check
> - MUST NOT produce any PASS/FAIL judgment — that is the Evaluator's job
> - MUST NOT evaluate whether evidence is "good" or "bad" — only whether it is accurate
> - MUST write `reasoning.yaml` as the only output artifact
> - MUST flag evidence items that cannot be validated as `validation_status: UNVERIFIED`
>

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `plan_local_dir`: Local directory containing plan files (optional)
- `artifact_evidence_dir`: Directory for evidence artifacts
- `evidence_path`: Path to `evidence.yaml` produced by the Generator

## Entry Criteria

- `evidence.yaml` present at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml`
- `spec_local_dir` present and non-empty
- `github.owner`, `github.repo` available
- Write access to `{project_root}/tmp/{issue-N}/artifacts/`

## Exit Criteria

- All evidence items from `evidence.yaml` validated against source data
- Each validation recorded with `validation_status` (VALIDATED, UNVERIFIED, CONTRADICTED)
- Source references recorded for each validated item
- `reasoning.yaml` written to `{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml`

## Procedure

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml`
- [ ] 2. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 3. If any criterion fails, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "<field_name>"
remediation: "<field_name> is required for concern-separation-knowledge-supporter. The orchestrator must provide a valid path."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load evidence.yaml

Read the Generator's evidence artifact:

```python
evidence = read_yaml(f"{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml")
```

Extract all evidence sections:
- `phases` — phase structure data
- `symbol_evidence` — symbol-level callers/callees/dependents
- `cross_phase_overlaps` — shared files and symbols between phases
- `blast_radius` — dependency impact chains
- `dependency_order` — declared dependency ordering
- `sc_orthogonality` — SC independence data
- `routing_evidence` — routing table references

### Step 3: Load Source Data

Load all source files for cross-checking:

```python
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
for f in spec_files:
    read(filePath=f)

if plan_local_dir:
    plan_files = glob(pattern="**/*.md", path=f"<plan_local_dir>")
    for f in plan_files:
        read(filePath=f)
```

### Step 4: Validate Phase Structure Evidence

For each phase in `evidence.phases`, cross-check against spec source files:

- [ ] 1. Verify `phase_name` exists in spec files — grep for the phase name in spec content
- [ ] 2. Verify `step_count` matches actual step count in spec — count steps in the spec's phase section
- [ ] 3. Verify `declared_dependencies` match spec text — check if each dependency is declared in the spec
- [ ] 4. Verify `concern_keywords` are present in phase text — grep for each keyword in the phase's steps
- [ ] 5. Verify `referenced_files` exist in the codebase — glob each file path
- [ ] 6. Verify `referenced_symbols` exist via srclight — call `srclight_get_signature(name=<symbol>)` for each

Record validation results:

```yaml
phase_validation:
  - phase_name: "<name>"
    validations:
      - field: "phase_name"
        validation_status: "VALIDATED"
        source: "spec file <path>, line range <N>-<M>"
      - field: "step_count"
        validation_status: "VALIDATED"
        source: "counted <N> steps in spec phase section"
      - field: "declared_dependencies"
        validation_status: "VALIDATED"
        source: "spec text: '<quote>'"
      - field: "concern_keywords"
        validation_status: "VALIDATED"
        source: "keyword '<keyword>' found in phase step '<step_text>'"
      - field: "referenced_files"
        validation_status: "VALIDATED"
        source: "glob confirmed file exists: <path>"
      - field: "referenced_symbols"
        validation_status: "VALIDATED"
        source: "srclight_get_signature confirmed symbol: <symbol>"
```

### Step 5: Validate Symbol-Level Evidence

For each entry in `evidence.symbol_evidence`, cross-check against live srclight data:

- [ ] 1. Verify the symbol exists — call `srclight_get_signature(name=<symbol>)`
- [ ] 2. Verify `callers` — call `srclight_get_callers(symbol_name=<symbol>)` and compare
- [ ] 3. Verify `callees` — call `srclight_get_callees(symbol_name=<symbol>)` and compare
- [ ] 4. Verify `dependents` — call `srclight_get_dependents(symbol_name=<symbol>, transitive=true)` and compare

Record validation results:

```yaml
symbol_validation:
  - phase: "<phase_name>"
    symbol: "<symbol>"
    validations:
      - field: "symbol_existence"
        validation_status: "VALIDATED"
        source: "srclight_get_signature returned <N> matches"
      - field: "callers"
        validation_status: "VALIDATED"
        source: "srclight_get_callers returned <N> callers, <M> match evidence"
      - field: "callees"
        validation_status: "VALIDATED"
        source: "srclight_get_callees returned <N> callees, <M> match evidence"
      - field: "dependents"
        validation_status: "VALIDATED"
        source: "srclight_get_dependents returned <N> dependents, <M> match evidence"
    discrepancies:
      - field: "<field>"
        evidence_has: ["<symbol>", ...]
        live_has: ["<symbol>", ...]
        evidence_missing: ["<symbol>", ...]
        live_missing: ["<symbol>", ...]
```

### Step 6: Validate Cross-Phase Overlap Evidence

For each entry in `evidence.cross_phase_overlaps`, cross-check against live data:

- [ ] 1. Verify `shared_files` — glob each file path to confirm existence
- [ ] 2. Verify `shared_symbols` — call `srclight_get_signature(name=<symbol>)` for each
- [ ] 3. Verify the overlap is genuine — check that both phases actually reference the shared file/symbol in the spec

Record validation results:

```yaml
cross_phase_validation:
  - phase_a: "<name>"
    phase_b: "<name>"
    validations:
      - field: "shared_files"
        validation_status: "VALIDATED"
        source: "glob confirmed <N>/<N> files exist"
      - field: "shared_symbols"
        validation_status: "VALIDATED"
        source: "srclight confirmed <N>/<N> symbols exist"
      - field: "overlap_genuine"
        validation_status: "VALIDATED"
        source: "both phases reference <file/symbol> in spec text"
    discrepancies: []
```

### Step 7: Validate Blast Radius Evidence

For each entry in `evidence.blast_radius`, cross-check against live srclight data:

- [ ] 1. Verify the file exists — glob the file path
- [ ] 2. Verify the symbol exists in that file — call `srclight_symbols_in_file(path=<file>)` and check
- [ ] 3. Verify `dependents` — call `srclight_get_dependents(symbol_name=<symbol>, transitive=true)` and compare
- [ ] 4. Verify `cross_phase_dependents` — check that each cross-phase dependent is actually referenced by another phase in the spec

Record validation results:

```yaml
blast_radius_validation:
  - phase: "<phase_name>"
    file: "<path>"
    symbol: "<symbol>"
    validations:
      - field: "file_existence"
        validation_status: "VALIDATED"
        source: "glob confirmed file exists"
      - field: "symbol_in_file"
        validation_status: "VALIDATED"
        source: "srclight_symbols_in_file confirmed symbol in file"
      - field: "dependents"
        validation_status: "VALIDATED"
        source: "srclight_get_dependents returned <N> dependents, <M> match evidence"
      - field: "cross_phase_dependents"
        validation_status: "VALIDATED"
        source: "<N>/<M> cross-phase dependents confirmed in other phase specs"
    discrepancies: []
```

### Step 8: Validate Dependency Order Evidence

For each entry in `evidence.dependency_order`, cross-check against spec text:

- [ ] 1. Verify `from_phase` declares dependency on `to_phase` in spec text
- [ ] 2. Verify `from_index` and `to_index` match the phase ordering in the spec
- [ ] 3. Verify `order_valid` is consistent with phase indices

Record validation results:

```yaml
dependency_order_validation:
  - from_phase: "<name>"
    to_phase: "<name>"
    validations:
      - field: "dependency_declared"
        validation_status: "VALIDATED"
        source: "spec text: '<quote>' declares dependency"
      - field: "phase_indices"
        validation_status: "VALIDATED"
        source: "from_index=<N>, to_index=<M> match spec ordering"
      - field: "order_valid"
        validation_status: "VALIDATED"
        source: "from_index (<N>) > to_index (<M>) = <true|false>"
    discrepancies: []
```

### Step 9: Validate SC Orthogonality Evidence

For each entry in `evidence.sc_orthogonality`, cross-check against spec source:

- [ ] 1. Verify each SC exists in the spec — grep for SC ID in spec files
- [ ] 2. Verify `criterion` text matches spec text — compare character-for-character
- [ ] 3. Verify `evidence_type` matches spec declaration
- [ ] 4. Verify `referenced_symbols` exist via srclight
- [ ] 5. Verify `referenced_files` exist via glob
- [ ] 6. For each `sc_overlap`, verify both SCs actually share the claimed symbols/files

Record validation results:

```yaml
sc_orthogonality_validation:
  scs:
    - sc_id: "<id>"
      validations:
        - field: "sc_exists"
          validation_status: "VALIDATED"
          source: "grep found SC in spec file <path>"
        - field: "criterion_text"
          validation_status: "VALIDATED"
          source: "text matches spec exactly"
        - field: "evidence_type"
          validation_status: "VALIDATED"
          source: "type '<type>' matches spec declaration"
        - field: "referenced_symbols"
          validation_status: "VALIDATED"
          source: "srclight confirmed <N>/<N> symbols exist"
        - field: "referenced_files"
          validation_status: "VALIDATED"
          source: "glob confirmed <N>/<N> files exist"
      discrepancies: []
  sc_overlaps:
    - sc_a: "<id>"
      sc_b: "<id>"
      validations:
        - field: "shared_symbols"
          validation_status: "VALIDATED"
          source: "srclight confirmed <N>/<N> shared symbols exist"
        - field: "shared_files"
          validation_status: "VALIDATED"
          source: "glob confirmed <N>/<N> shared files exist"
      discrepancies: []
```

### Step 10: Validate Routing Evidence

For each entry in `evidence.routing_evidence`, cross-check against live routing tables:

- [ ] 1. Verify `referenced_task` exists in the codebase — glob for the task file
- [ ] 2. Verify `routing_references_found` — re-run grep for the task name in `.opencode/skills/` and compare
- [ ] 3. Verify the spec step actually mentions removal or delegation of the task

Record validation results:

```yaml
routing_validation:
  - phase: "<phase_name>"
    step: "<raw text>"
    referenced_task: "<task_name>"
    validations:
      - field: "task_exists"
        validation_status: "VALIDATED"
        source: "glob found task file: <path>"
      - field: "routing_references"
        validation_status: "VALIDATED"
        source: "grep found <N> routing references, <M> match evidence"
      - field: "step_mentions_removal"
        validation_status: "VALIDATED"
        source: "spec step text contains removal/delegation language"
    discrepancies: []
```

### Step 11: Write reasoning.yaml

Write all validated evidence to `{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml`:

```yaml
supporter_type: concern-separation-knowledge-supporter
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
evidence_source: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml"
evidence_items_total: <N>
evidence_items_validated: <N>
evidence_items_unverified: <N>
evidence_items_contradicted: <N>
phase_validation:
  - phase_name: "<name>"
    validations:
      - field: "<field>"
        validation_status: "VALIDATED|UNVERIFIED|CONTRADICTED"
        source: "<reference>"
        note: "<explanation if UNVERIFIED or CONTRADICTED>"
symbol_validation:
  - phase: "<phase_name>"
    symbol: "<symbol>"
    validations:
      - field: "<field>"
        validation_status: "VALIDATED|UNVERIFIED|CONTRADICTED"
        source: "<reference>"
    discrepancies: []
cross_phase_validation:
  - phase_a: "<name>"
    phase_b: "<name>"
    validations:
      - field: "<field>"
        validation_status: "VALIDATED|UNVERIFIED|CONTRADICTED"
        source: "<reference>"
    discrepancies: []
blast_radius_validation:
  - phase: "<phase_name>"
    file: "<path>"
    symbol: "<symbol>"
    validations:
      - field: "<field>"
        validation_status: "VALIDATED|UNVERIFIED|CONTRADICTED"
        source: "<reference>"
    discrepancies: []
dependency_order_validation:
  - from_phase: "<name>"
    to_phase: "<name>"
    validations:
      - field: "<field>"
        validation_status: "VALIDATED|UNVERIFIED|CONTRADICTED"
        source: "<reference>"
    discrepancies: []
sc_orthogonality_validation:
  scs:
    - sc_id: "<id>"
      validations:
        - field: "<field>"
          validation_status: "VALIDATED|UNVERIFIED|CONTRADICTED"
          source: "<reference>"
      discrepancies: []
  sc_overlaps:
    - sc_a: "<id>"
      sc_b: "<id>"
      validations:
        - field: "<field>"
          validation_status: "VALIDATED|UNVERIFIED|CONTRADICTED"
          source: "<reference>"
      discrepancies: []
routing_validation:
  - phase: "<phase_name>"
    referenced_task: "<task_name>"
    validations:
      - field: "<field>"
        validation_status: "VALIDATED|UNVERIFIED|CONTRADICTED"
        source: "<reference>"
    discrepancies: []
```

### Step 12: Return Frugal Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/reasoning.yaml"
summary: "Evidence validated: {N} items checked, {M} VALIDATED, {K} UNVERIFIED, {J} CONTRADICTED."
```

## Validation Status Definitions

| Status | Meaning |
|--------|---------|
| `VALIDATED` | Evidence item confirmed against live source data — exact match |
| `UNVERIFIED` | Evidence item could not be confirmed — source unavailable, symbol not found, or tool error |
| `CONTRADICTED` | Evidence item conflicts with live source data — discrepancy found |

## Error Handling

| Error | Action |
|-------|--------|
| `evidence.yaml` not found | Return BLOCKED — Generator must produce evidence first |
| `spec_local_dir` missing or empty | Return BLOCKED — cannot validate without source data |
| Symbol not found in srclight | Record `validation_status: UNVERIFIED` with note, continue |
| srclight unavailable | Record `validation_status: UNVERIFIED` with `srclight_unavailable: true`, continue with file-path-only validation |
| File path in evidence does not exist | Record `validation_status: CONTRADICTED` with note, continue |
| Evidence field missing from evidence.yaml | Record `validation_status: UNVERIFIED` with `field_missing: true`, continue |
| Write permission denied | Return BLOCKED — cannot write reasoning.yaml |

## Cross-References

- `tasks/concern-separation-generator.md` — Generator role (produces evidence.yaml)
- `tasks/concern-separation.md` — Evaluator role (consumes reasoning.yaml)
- `tasks/cross-validate.md` — Path Provider (final judgment)
- `000-critical-rules.md` — Single Concern Principle
- `065-verification-honesty.md` — live verification requirement
