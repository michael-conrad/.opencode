# Task: analyze — Pre-spec analysis pipeline

## Category

ANALYSIS

## Purpose

Perform pre-spec inspection, research card consultation, requirements extraction, problem decomposition, and analytical artifact generation. This task produces the analysis artifacts that the create task consumes. It does NOT write spec content, create remote issues, or run holistic checks.

## Entry Criteria

- [ ] `issue_number` and `project_root` received in dispatch context
- [ ] No preloaded analysis, orchestrator reasoning, or expected outcomes in the prompt
- [ ] Codebase is indexed (srclight available)

## Procedure

### Step 1: Pre-spec inspection

Search the codebase for affected files, existing patterns, and conventions relevant to the spec topic. Use `srclight_hybrid_search` and `srclight_get_dependents` to identify:

- Files that would be modified by the spec
- Existing patterns and conventions in those files
- Dependencies and callers of affected symbols

Write findings to `{project_root}/tmp/{issue_number}/artifacts/pre-spec-inspection.yaml`.

### Step 2: Research card consultation

Glob `.issues/research-cards/*.md` and grep frontmatter for research questions matching the spec topic. If a card exists with `confidence >= 0.7`, incorporate its findings into the analysis.

Write findings to `{project_root}/tmp/{issue_number}/artifacts/research-card-consultation.yaml`.

### Step 3: Requirements extraction

Extract requirements from the problem statement:

- Explicit requirements (stated directly)
- Implicit requirements (inferred from context)
- Constraint requirements (boundary conditions)
- Non-requirements (explicitly excluded)

Verify every requirement against the actual codebase using srclight, file reads, and config checks. Write structured YAML to `{project_root}/tmp/{issue_number}/contracts/requirements-output.yaml`.

### Step 4: Problem decomposition

Decompose the problem into discrete units with defined interfaces, inputs, outputs, invariants, and failure modes. Decompose until each unit is a single independently verifiable claim. For multi-phase specs, define three-tier phase structure (global pre-phase, per-file RED/GREEN phases, global post-phase).

Write to `{project_root}/tmp/{issue_number}/contracts/decompose-output.yaml`.

### Step 5: Analytical artifact generation

Generate the 7 analytical artifacts consumed by `writing-plans`:

1. **Blast radius** — Affected components and ripple effects per phase
2. **Concern map** — Concern boundaries and separation per phase
3. **Code path inventory** — Code paths touched by each phase
4. **Cross-cutting matrix** — Cross-cutting concerns matrix
5. **Interface compatibility** — Interface compatibility analysis (unchanged, modified, new, removed; backward compatible, breaking, internal only)
6. **State analysis** — State machine transitions per phase
7. **Testability assessment** — Test strategy per phase (unit, integration, behavioral, mixed)

Write each artifact to `{project_root}/tmp/{issue_number}/artifacts/{name}.yaml`.

### Step 6: Pipeline readiness gate

Validate:

- **Atomicity:** Every SC maps to exactly one RED→GREEN→COMMIT cycle
- **Dependency ordering:** SC dependency DAG is acyclic
- **Single concern:** Every SC targets one file category and one verification domain
- **Phase dependency:** Phase dependency graph is acyclic
- **Three-tier structure:** Multi-phase specs have pre/per-file/post structure

Write to `{project_root}/tmp/{issue_number}/artifacts/pipeline-readiness.yaml`.

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
