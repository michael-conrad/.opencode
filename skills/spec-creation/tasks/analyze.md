# Task: analyze

## Category

ANALYSIS

## Purpose

Perform pre-spec inspection, research card consultation, requirements extraction, problem decomposition, and analytical artifact generation. This task produces the analysis artifacts that the create task consumes. It does NOT write spec content, create remote issues, or run holistic checks.

## Entry Criteria

- [ ] `issue_number` and `project_root` received in dispatch context
- [ ] `issue_number` is a bound, real issue number — NOT an unbound/placeholder value (e.g., `N`, `TBD`, `0`, a literal placeholder token, or a number with no corresponding issue record)
- [ ] No preloaded analysis, orchestrator reasoning, or expected outcomes in the prompt
- [ ] Codebase is indexed (srclight available)

## BLOCK Precondition

**If `issue_number` is unbound or a placeholder** (a literal placeholder token such as `N`/`TBD`, a non-numeric value, `0`, or a number with no corresponding issue record in the project), the analyze task MUST BLOCK immediately. It MUST NOT proceed with pre-spec inspection, requirements extraction, decomposition, or artifact generation.

- **BLOCK reason:** `UNBOUND_ISSUE_NUMBER` — the analyze task cannot anchor its analysis to a real issue. Issue-number binding is NOT analyze.md's responsibility; it is handled upstream by issue-operations-core creation and by create.md remote-stub-first. The orchestrator MUST provide a bound issue number before dispatching analyze.
- **Result contract:** return `status: BLOCKED` with `blocker_reason` explaining that the issue number is unbound/placeholder and must be bound upstream before analyze can run.

## Procedure

### Step 1: Pre-spec inspection

- [ ] 1.1. Search the codebase for affected files, existing patterns, and conventions relevant to the spec topic. Use `srclight_hybrid_search` and `srclight_get_dependents` to identify:

  - Files that would be modified by the spec
  - Existing patterns and conventions in those files
  - Dependencies and callers of affected symbols

- [ ] 1.2. Write findings to `{project_root}/tmp/{issue_number}/artifacts/pre-spec-inspection.yaml`.

### Step 2: Research card consultation

- [ ] 2.1. Glob `.issues/research-cards/*.md` and grep frontmatter for research questions matching the spec topic. If a card exists with `confidence >= 0.7`, incorporate its findings into the analysis.

- [ ] 2.2. Write findings to `{project_root}/tmp/{issue_number}/artifacts/research-card-consultation.yaml`.

### Step 3: Requirements extraction

- [ ] 3.1. Extract requirements from the problem statement:

  - Explicit requirements (stated directly)
  - Implicit requirements (inferred from context)
  - Constraint requirements (boundary conditions)
  - Non-requirements (explicitly excluded)

- [ ] 3.2. Verify every requirement against the actual codebase using srclight, file reads, and config checks. Write structured YAML to `{project_root}/tmp/{issue_number}/contracts/requirements-output.yaml`.

### Step 4: Problem decomposition

- [ ] 4.1. Decompose the problem into discrete units with defined interfaces, inputs, outputs, invariants, and failure modes. Decompose until each unit is a single independently verifiable claim. For each SC in the spec's success criteria table, create one implementation item with its own RED/GREEN/verify/commit cycle. Items are numbered sequentially. Each item references exactly one SC-ID.

- [ ] 4.2. Write to `{project_root}/tmp/{issue_number}/contracts/decompose-output.yaml`.

### Step 5: Analytical artifact generation

- [ ] 5.1. Generate the 7 analytical artifacts consumed by `writing-plans`:

- [ ] 1. **Blast radius** — Affected components and ripple effects per phase
- [ ] 2. **Concern map** — Concern boundaries and separation per phase
- [ ] 3. **Code path inventory** — Code paths touched by each phase
- [ ] 4. **Cross-cutting matrix** — Cross-cutting concerns matrix
- [ ] 5. **Interface compatibility** — Interface compatibility analysis (unchanged, modified, new, removed; backward compatible, breaking, internal only). Include a `dependency_contract` section with entries mapping `source` (from `interfaces`), `target` (from `removed_interfaces` or related), `type` ("artifact schema"), and `constraint` (from `breaking_changes` or implied coupling).
- [ ] 6. **State analysis** — State machine transitions per phase
- [ ] 7. **Testability assessment** — Test strategy per phase (unit, integration, behavioral, mixed)

- [ ] 5.2. Write each artifact to `{project_root}/tmp/{issue_number}/artifacts/{name}.yaml`.

### Step 6: Pipeline readiness gate

- [ ] 6.1. Validate:

  - **Atomicity:** Every SC maps to exactly one RED→GREEN→COMMIT cycle
  - **Dependency ordering:** SC dependency DAG is acyclic
  - **Single concern:** Every SC targets one file category and one verification domain
  - **Phase dependency:** Phase dependency graph is acyclic
  - **Three-tier structure:** Multi-phase specs have pre/per-file/post structure

- [ ] 6.2. Write to `{project_root}/tmp/{issue_number}/artifacts/pipeline-readiness.yaml`.

## Exit Criteria

- [ ] All 7 analytical artifacts written to `{project_root}/tmp/{issue_number}/artifacts/`
- [ ] Requirements extracted and verified against codebase
- [ ] Pipeline readiness gate passed (or BLOCKED with findings)
- [ ] No spec content written, no remote issue created, no holistic check run

## Result Contract

```yaml
status: DONE | BLOCKED
analysis_artifact_path: "{project_root}/tmp/{issue_number}/artifacts/"
finding_summary: "Brief summary of analysis findings, key requirements, and decomposition structure"
blocker_reason: "If BLOCKED: why the analysis could not complete"
```
