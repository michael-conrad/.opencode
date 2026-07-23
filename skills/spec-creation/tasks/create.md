# Task: create — Spec production pipeline

## Category

PRODUCTION

## Purpose

Read analysis artifacts from disk, assemble the full spec document, create a remote issue stub (when remote API available), write the full spec to the remote issue body, and write the local spec to the correct `.issues/{N}/` path. This task does NOT perform analysis steps or verification steps.

## Entry Criteria

- [ ] `issue_number` and `analysis_artifact_path` received in dispatch context
- [ ] No preloaded spec content, orchestrator reasoning, or expected outcomes in the prompt
- [ ] Analysis artifacts exist at `{analysis_artifact_path}` (pre-spec-inspection.yaml, requirements-output.yaml, decompose-output.yaml, and the 7 analytical artifacts)
- [ ] `project_root` available for path resolution

## Procedure

### Step 1: Read analysis artifacts

Read all analysis artifacts from `{analysis_artifact_path}`:

- `pre-spec-inspection.yaml` — Affected files and patterns
- `research-card-consultation.yaml` — Research card findings
- `requirements-output.yaml` — Extracted requirements
- `decompose-output.yaml` — Decomposition structure
- `blast-radius.yaml` — Blast radius per phase
- `concern-map.yaml` — Concern boundaries
- `code-path-inventory.yaml` — Code paths per phase
- `cross-cutting-matrix.yaml` — Cross-cutting concerns
- `interface-compatibility.yaml` — Interface analysis
- `state-analysis.yaml` — State transitions
- `testability-assessment.yaml` — Test strategy
- `pipeline-readiness.yaml` — Pipeline readiness gate results

### Step 2: Assemble spec document

Construct the spec with all required sections:

1. **Objective** — What this spec achieves
2. **Background** — Why this spec exists, context, defects being addressed
3. **Not Included** — Explicitly excluded scope
4. **Success Criteria** — Table with ID, Criterion, Evidence Type, Verification Method columns
5. **Requirements** — Numbered requirements with SHALL language
6. **Phases** — Implementation phases with REQ references
7. **Dependencies** — Prerequisite specs, skills, guidelines
8. **Traceability** — Table mapping Requirements → SCs → Phases

### Step 3: Create remote issue stub

When a remote API is available (github.platform is not `local`):

1. Create a minimal remote issue with `[SPEC]` prefix and `needs-approval` label to establish the issue number
2. Extract the `html_url` from the API response

When no remote API is available (local-only mode), use the local issue number directly.

### Step 4: Write full spec to remote issue body

When a remote API is available, write the full assembled spec to the remote issue body using the platform's update API.

### Step 5: Write local spec

Write the full spec to the correct local path:

- Root repo issues: `{project_root}/.issues/{issue_number}/spec.md`
- Submodule issues: `{project_root}/{path}/.issues/{issue_number}/spec.md` (where `path` comes from session-init Repo Information)

Include the GitHub URL blockquote at the top of the local spec:

```
> **Full spec and artifacts: [`{issues_prefix}{N}/`]({browser_url}/{owner}/{repo}/tree/issues-data/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `{issues_prefix}{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
```

## Exit Criteria

- [ ] Spec assembled with all required sections
- [ ] Remote issue created (when API available) with `[SPEC]` prefix and `needs-approval` label
- [ ] Full spec written to remote issue body (when API available)
- [ ] Local spec written to correct `.issues/{N}/spec.md` path
- [ ] No analysis steps performed (no inspection, decomposition, or artifact generation)
- [ ] No verification steps performed (no holistic check or structural validation)

## Result Contract

```yaml
status: DONE | BLOCKED
spec_path: "{project_root}/.issues/{issue_number}/spec.md"
issue_url: "https://github.com/{owner}/{repo}/issues/{issue_number}"
finding_summary: "Brief summary of spec structure, sections, and key decisions"
blocker_reason: "If BLOCKED: why the spec could not be created"
```
