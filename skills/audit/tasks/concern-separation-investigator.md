<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: concern-separation-generator

## Purpose

Collect raw evidence about concern boundaries and scope isolation from spec and plan files. Reads phase structure, extracts symbols, traces dependencies, and records findings without evaluation. Writes `evidence.yaml` as the sole output artifact.

> **DiMo Role: Investigator.** This task generates baseline concern-separation evidence. Reads spec and plan files, collects raw data about concern boundaries, scope isolation, phase structure, and dependency chains. Writes `evidence.yaml` with extracted data and initial observations.
>
> You are the Investigator. Your job is to collect evidence — nothing more, nothing less. You are meticulous, exhaustive, and completely non-judgmental. Every piece of evidence you find gets recorded. You do not decide what matters. You do not decide what is correct. You just collect.
>
>
> - MUST extract all evidence without filtering by perceived relevance
> - MUST NOT produce any PASS/FAIL judgment
> - MUST NOT evaluate whether evidence is "correct" — record what exists
> - MUST write `evidence.yaml` as the only output artifact
>

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `plan_local_dir`: Local directory containing plan files (optional)
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- Spec issue number provided
- `spec_local_dir` present and non-empty
- `github.owner`, `github.repo` available
- Write access to `{project_root}/tmp/{issue-N}/artifacts/`

## Exit Criteria

- All spec files read and phase structure extracted
- All plan files read (if available) and task structure extracted
- Symbol-level evidence collected via srclight for each phase
- Dependency chain data collected
- Blast radius data collected via `srclight_get_dependents`
- `evidence.yaml` written to `{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml`

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/concern-separation/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for concern-separation-generator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load Spec Files

`spec_local_dir` is REQUIRED. Investigator BLOCKs if absent.

```python
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
for f in spec_files:
    read(filePath=f)
```

Extract from each spec file:
- Phase names and descriptions
- Steps per phase
- Declared dependencies between phases
- Success criteria with evidence types
- File paths and symbols referenced in each phase
- Risk classifications if declared

### Step 3: Load Plan Files (if available)

If `plan_local_dir` is provided and non-empty:

```python
plan_files = glob(pattern="**/*.md", path=f"<plan_local_dir>")
for f in plan_files:
    read(filePath=f)
```

Extract from each plan file:
- Task breakdown per phase
- Implementation file paths
- Symbol references
- Dependency ordering

### Step 4: Collect Phase Structure Evidence

For each phase extracted from the spec, collect raw structural data:

```yaml
phases:
  - phase_name: "<name>"
    phase_index: <N>
    description: "<raw description text>"
    step_count: <N>
    steps:
      - step_index: <N>
        description: "<raw step text>"
        referenced_files: ["<path>", ...]
        referenced_symbols: ["<symbol>", ...]
    declared_dependencies: ["<phase_name>", ...]
    declared_risk: "<high|medium|low|not_declared>"
```

Concern keyword mapping (record, do not judge):
- Keywords found: migration, schema, table → record `concern_keywords: [data]`
- Keywords found: repository, query, ORM → record `concern_keywords: [data_access]`
- Keywords found: API, service, handler → record `concern_keywords: [business_logic]`
- Keywords found: UI, component, template → record `concern_keywords: [presentation]`
- Keywords found: test, verify, assert → record `concern_keywords: [testing]`
- Keywords found: deploy, config, infra → record `concern_keywords: [infrastructure]`

### Step 5: Collect Symbol-Level Evidence

For each phase, collect symbol data via srclight:

```python
for phase in phases:
    for symbol in phase.referenced_symbols:
        callers = srclight_get_callers(symbol_name=symbol)
        callees = srclight_get_callees(symbol_name=symbol)
        dependents = srclight_get_dependents(symbol_name=symbol, transitive=true)
        record({
            "phase": phase.phase_name,
            "symbol": symbol,
            "callers": callers,
            "callees": callees,
            "dependents": dependents
        })
```

### Step 6: Collect Cross-Phase Overlap Evidence

Compare symbols and files across phases to identify overlaps (record, do not judge):

```python
cross_phase_evidence = []
for i, phase_a in enumerate(phases):
    for phase_b in phases[i+1:]:
        shared_files = set(phase_a.referenced_files) & set(phase_b.referenced_files)
        shared_symbols = set(phase_a.referenced_symbols) & set(phase_b.referenced_symbols)
        if shared_files or shared_symbols:
            cross_phase_evidence.append({
                "phase_a": phase_a.phase_name,
                "phase_b": phase_b.phase_name,
                "shared_files": list(shared_files),
                "shared_symbols": list(shared_symbols)
            })
```

### Step 7: Collect Blast Radius Evidence

For each phase, trace the full impact chain:

```python
blast_radius_evidence = []
for phase in phases:
    for file_path in phase.referenced_files:
        symbols_in_file = srclight_symbols_in_file(path=file_path)
        for symbol in symbols_in_file:
            dependents = srclight_get_dependents(symbol_name=symbol.name, transitive=true)
            blast_radius_evidence.append({
                "phase": phase.phase_name,
                "file": file_path,
                "symbol": symbol.name,
                "dependent_count": len(dependents),
                "dependents": dependents,
                "cross_phase_dependents": [
                    d for d in dependents
                    if any(d in p.referenced_symbols for p in phases if p != phase)
                ]
            })
```

### Step 8: Collect Dependency Order Evidence

Record the declared dependency order and compare against actual symbol references:

```python
dependency_evidence = []
for phase in phases:
    for dep_phase_name in phase.declared_dependencies:
        dep_phase = find_phase(phases, dep_phase_name)
        if dep_phase:
            dependency_evidence.append({
                "from_phase": phase.phase_name,
                "to_phase": dep_phase_name,
                "from_index": phase.phase_index,
                "to_index": dep_phase.phase_index,
                "order_valid": phase.phase_index > dep_phase.phase_index
            })
```

### Step 9: Collect SC Orthogonality Evidence

For each success criterion in the spec, collect data about independence:

```yaml
sc_orthogonality:
  scs:
    - sc_id: "<id>"
      criterion: "<raw text>"
      evidence_type: "<type>"
      referenced_symbols: ["<symbol>", ...]
      referenced_files: ["<path>", ...]
  sc_overlaps:
    - sc_a: "<id>"
      sc_b: "<id>"
      shared_symbols: ["<symbol>", ...]
      shared_files: ["<path>", ...]
```

### Step 10: Collect Routing Table Evidence

If the spec removes or delegates a task file, check for routing table references:

```python
routing_evidence = []
for phase in phases:
    for step in phase.steps:
        if "remove" in step.description.lower() or "delegate" in step.description.lower():
            referenced_task = extract_task_file_reference(step.description)
            if referenced_task:
                routing_refs = grep(
                    pattern=referenced_task,
                    path=".opencode/skills/"
                )
                routing_evidence.append({
                    "phase": phase.phase_name,
                    "step": step.description,
                    "referenced_task": referenced_task,
                    "routing_references_found": routing_refs
                })
```

### Step 11: Write evidence.yaml

Write all collected evidence to `{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml`:

```yaml
generator_type: concern-separation
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
spec_files_read: <N>
plan_files_read: <N>
phases:
  - phase_name: "<name>"
    phase_index: <N>
    description: "<raw text>"
    step_count: <N>
    steps:
      - step_index: <N>
        description: "<raw text>"
        referenced_files: ["<path>", ...]
        referenced_symbols: ["<symbol>", ...]
    declared_dependencies: ["<phase_name>", ...]
    declared_risk: "<high|medium|low|not_declared>"
    concern_keywords: ["<keyword>", ...]
symbol_evidence:
  - phase: "<phase_name>"
    symbol: "<symbol>"
    callers: ["<symbol>", ...]
    callees: ["<symbol>", ...]
    dependents: ["<symbol>", ...]
cross_phase_overlaps:
  - phase_a: "<name>"
    phase_b: "<name>"
    shared_files: ["<path>", ...]
    shared_symbols: ["<symbol>", ...]
blast_radius:
  - phase: "<phase_name>"
    file: "<path>"
    symbol: "<symbol>"
    dependent_count: <N>
    dependents: ["<symbol>", ...]
    cross_phase_dependents: ["<symbol>", ...]
dependency_order:
  - from_phase: "<name>"
    to_phase: "<name>"
    from_index: <N>
    to_index: <N>
    order_valid: <true|false>
sc_orthogonality:
  scs:
    - sc_id: "<id>"
      criterion: "<raw text>"
      evidence_type: "<type>"
      referenced_symbols: ["<symbol>", ...]
      referenced_files: ["<path>", ...]
  sc_overlaps:
    - sc_a: "<id>"
      sc_b: "<id>"
      shared_symbols: ["<symbol>", ...]
      shared_files: ["<path>", ...]
routing_evidence:
  - phase: "<phase_name>"
    step: "<raw text>"
    referenced_task: "<task_name>"
    routing_references_found: ["<file_path>", ...]
```

### Step 12: Return Frugal Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/concern-separation/evidence.yaml"
summary: "Evidence collected: {N} phases, {M} symbols, {K} cross-phase overlaps, {J} blast-radius traces."
```

## Error Handling

| Error | Action |
|-------|--------|
| No spec files found | Return BLOCKED — spec_local_dir required |
| No phases extracted from spec | Return BLOCKED — spec must contain phases |
| srclight unavailable | Record `srclight_unavailable: true` in evidence, proceed with file-path-only evidence |
| Symbol not found in srclight | Record `symbol_not_found: true` for that symbol, continue |
| Write permission denied | Return BLOCKED — cannot write evidence.yaml |

## Cross-References

- `tasks/concern-separation.md` — Evaluator role (consumes this evidence)
- `tasks/cross-validate.md` — Arbiter (final judgment)
- `000-critical-rules.md` — Single Concern Principle
- `065-verification-honesty.md` — live verification requirement

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
