# Task: create — Spec production pipeline

## Category

PRODUCTION

## Purpose

Read analysis artifacts from disk, assemble the full spec document, create a remote issue stub (when remote API available), write the full spec to the remote issue body, and write the local spec to the correct `.issues/{N}/` path. The `needs-approval` and `spec-draft` labels are written to the local `{issues_prefix}/{N}/issue.yaml` labels array as the **primary canonical source**; remote label writes are best-effort/secondary and MUST NEVER block the pipeline. This task does NOT perform analysis steps or verification steps.

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

Read [spec-structure-standards.md](reference/spec-structure-standards.md) and assemble the spec against its required sections.

Read [cost-model-standards.md](reference/cost-model-standards.md) and write per-SC cost-frame statements following the dark-prose-007 pattern.

### Step 2.1: Apply format-level rules

Apply the following format-level rules during spec body assembly:

- **SHALL language:** Use "SHALL" for mandatory requirements, "SHOULD" for recommendations, "MAY" for optional behavior. Avoid "must", "will", "should" (unqualified) in normative statements.
- **dark-prose-007 pattern:** Each SC MUST include a cost-frame statement explaining what failure costs (time, complexity, defects) — written in dark prose authority frame.
- **SC determinism:** Every SC MUST be a single, independently verifiable claim. No compound SCs, no ambiguous wording, no hedging language.
- **Documentation Sources columns:** The SC table MUST include a Documentation Sources column listing the live documentation URLs or source paths that verify each SC's claims.

### Step 2.1: Write sc-summary.yaml

Write the SC summary to `{project_root}/{path}/.issues/{issue_number}/sc-summary.yaml`:

```yaml
sc_count: <total SC count>
scs:
  - id: "<SC-ID>"
    description: "<SC description>"
    evidence_type: "<behavioral|semantic|string|structural>"
    plan_item: <item number>
```

Each SC gets a `plan_item` number instead of a phase group. Items are numbered sequentially starting from 1.

### Step 3: Create remote issue stub

When a remote API is available (github.platform is not `local`):

1. Create a minimal remote issue with `[SPEC]` prefix and `needs-approval` label to establish the issue number
2. Extract the `html_url` from the API response

When no remote API is available (local-only mode), use the local issue number directly.

### Step 3.1: Record labels in local `issue.yaml` as PRIMARY CANONICAL (MANDATORY)

The `needs-approval` and `spec-draft` labels MUST be written to the local `{issues_prefix}/{N}/issue.yaml` labels array via `./.opencode/tools/local-issues update <repo>#<N> --labels needs-approval,spec-draft`. This is the **primary canonical source** for the label state — it MUST be written regardless of remote API success.

1. Write `needs-approval` and `spec-draft` to the local `issue.yaml` labels array via `local-issues update --labels`
2. If this local write fails: return BLOCKED with `LOCAL_LABEL_WRITE_FAILED` — the pipeline MUST NOT proceed without the canonical local record
3. Verify the local canonical write by reading back the labels array via `./.opencode/tools/local-issues read-labels --number <repo>#<N>`

### Step 3.2: Apply `spec-draft` label to remote (SECONDARY — best-effort, never blocking)

When a remote API is available, apply the `spec-draft` label to the newly created issue to mark it as a draft spec. This is best-effort/secondary only — if the remote write fails, log the failure and continue; it MUST NOT block the pipeline. The local `issue.yaml` remains the canonical source.

1. Use the platform's label API to add `spec-draft` to the issue
2. The `spec-draft` label indicates the spec is in draft state and has not yet been reviewed
3. If the remote label write fails (e.g., GitBucket label limitation, API error), report the gap as a known limitation and proceed — the local `issue.yaml` is canonical

### Step 4: Write full spec to remote issue body

When a remote API is available, write the full assembled spec to the remote issue body using the platform's update API.

### Step 5: Write local spec

Write the full spec to the correct local path:

- Root repo issues: `{project_root}/.issues/{issue_number}/spec.md`
- Submodule issues: `{project_root}/{path}/.issues/{issue_number}/spec.md` (where `path` comes from session-init Repo Information)

Include the GitHub URL blockquote at the top of the local spec:

### Step 6: Copy analytical artifacts

Copy analytical artifacts from the analysis step to the issue's artifact directory:

1. Source: `tmp/{issue_number}/artifacts/`
2. Destination: `{project_root}/{path}/.issues/{issue_number}/artifacts/`
3. Use `shutil.copytree` or equivalent to copy the full artifact directory
4. If the source directory does not exist, log a warning and continue (artifacts may have been cleaned up)

This ensures analytical artifacts are preserved alongside the spec for downstream consumers (auditors, plan creators).

```
> **Full spec and artifacts: [`{issues_prefix}{N}/`]({browser_url}/{owner}/{repo}/tree/issues-data/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `{issues_prefix}{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
```

## Exit Criteria

- [ ] Spec assembled with all required sections
- [ ] Format-level rules applied (SHALL language, dark-prose-007, SC determinism, Documentation Sources columns)
- [ ] Remote issue created (when API available) with `[SPEC]` prefix and `needs-approval` label
- [ ] `needs-approval` and `spec-draft` labels recorded in local `{issues_prefix}/{N}/issue.yaml` labels array as primary canonical source (REQUIRED — via `local-issues update --labels`)
- [ ] Remote `spec-draft` label write attempted best-effort; remote failure does not block completion
- [ ] Full spec written to remote issue body (when API available)
- [ ] Local spec written to correct `.issues/{N}/spec.md` path
- [ ] Analytical artifacts copied from `tmp/{issue_number}/artifacts/` to `.issues/{N}/artifacts/`
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
