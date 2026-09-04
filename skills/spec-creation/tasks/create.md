# Task: create

## Category

PRODUCTION

## Purpose

Assemble the full spec document from analysis artifacts, create a remote issue stub FIRST (when remote API available) and take the issue number N from the API create response's `number` field (remote-number-first — the remote API is the sole number source when a remote exists), write the full spec to the remote issue body, and write the local spec to the correct `.issues/{N}/` path (local record created at exactly N — local == remote BY CONSTRUCTION; the local counter is used ONLY in local-only mode). This task does NOT perform analysis steps or verification steps.

## Label Canonical Source

The `needs-approval` and `spec-draft` labels are written to the local `{issues_prefix}/{N}/issue.yaml` labels array as the **primary canonical source**; remote label writes are best-effort/secondary and MUST NEVER block the pipeline.

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

### Step 3: Create remote issue stub FIRST — remote-number-first numbering

**Remote-number-first rule (MANDATORY):**
When a remote API is available (github.platform is not `local`), the remote
API's assigned number is the SOLE source of truth for the issue number. The
flow creates the remote stub FIRST — before ANY local record exists — and
takes the issue number N from the API create response's `number` field. The
local issue record is then created at exactly N. Local == remote BY
CONSTRUCTION (both derive from the same response `number` field) — no
after-the-fact collision check, no divergence possibility.

When a remote API is available:

- [ ] 1. Create the remote stub FIRST (before any local record): a minimal remote issue with `[SPEC]` prefix and `needs-approval` label
- [ ] 2. Read the remote-assigned number N from the API create response's `number` field
- [ ] 3. Extract the `html_url` from the API response
- [ ] 4. Create the local issue record at exactly N: local directory `{issues_prefix}/{N}/` (`.issues/N/`), issue.yaml with `remote_issue: N`, and binding fields (`remote_issue`, `remote_url`, `github_url`) all referencing N
- [ ] 5. If the remote assigns a number whose local directory `{issues_prefix}/{N}/` already exists: follow the renumber/migrate repair pattern — migrate the existing local directory to the remote-assigned number, then create the local record at exactly N. This is a post-defect repair, not the primary guard; construction-by-remote-number remains the guard.
- [ ] 6. If the API fails mid-flow (remote stub created but the local write fails): return BLOCKED with blocker_reason `API_FAILURE_MID_FLOW` — MUST NOT silently reassign a different local number and MUST NOT leave a half-bound state. Recovery is a re-run that binds to the remote-assigned number, never a local-counter fallback.

**Local counter restriction:**
The create task MUST NOT use the local counter to pick the number when a
remote API is available. The local counter (`.counter` autonumber via
`local-issues create` without `--number`) is used ONLY in local-only mode
(no remote API — github.platform is `local`); in that mode, use the local
issue number directly.

**Downstream number binding:**
From this step onward, every `{issue_number}` reference in subsequent steps
(sc-summary.yaml path, spec path, artifact copy destination) resolves to N —
the remote-assigned number — never to a dispatch-context provisional number
or a local-counter value. The exact-match invariant holds: local directory
`.issues/N/`, issue.yaml `remote_issue: N`, and binding fields all reference
the same N.

### Step 3.1: Record labels in local `issue.yaml` as PRIMARY CANONICAL (MANDATORY)

The `needs-approval` and `spec-draft` labels MUST be written to the local `{issues_prefix}/{N}/issue.yaml` labels array via `./.opencode/tools/local-issues update <repo>#<N> --labels needs-approval,spec-draft`. This is the **primary canonical source** for the label state — it MUST be written regardless of remote API success.

- [ ] 1. Write `needs-approval` and `spec-draft` to the local `issue.yaml` labels array via `local-issues update --labels`
- [ ] 2. If this local write fails: return BLOCKED with `LOCAL_LABEL_WRITE_FAILED` — the pipeline MUST NOT proceed without the canonical local record
- [ ] 3. Verify the local canonical write by reading back the labels array via `./.opencode/tools/local-issues read-labels --number <repo>#<N>`

### Step 3.2: Apply `spec-draft` label to remote (SECONDARY — best-effort, never blocking)

When a remote API is available, apply the `spec-draft` label to the newly created issue to mark it as a draft spec. This is best-effort/secondary only — if the remote write fails, log the failure and continue; it MUST NOT block the pipeline. The local `issue.yaml` remains the canonical source.

- [ ] 1. Use the platform's label API to add `spec-draft` to the issue
- [ ] 2. The `spec-draft` label indicates the spec is in draft state and has not yet been reviewed
- [ ] 3. If the remote label write fails (e.g., GitBucket label limitation, API error), report the gap as a known limitation and proceed — the local `issue.yaml` is canonical

### Step 4: Write full spec to remote issue body

When a remote API is available, write the full assembled spec to the remote issue body using the platform's update API.

Route the remote issue body to the canonical exec-summary body format defined in [skills/issue-operations-core/tasks/creation.md](skills/issue-operations-core/tasks/creation.md) Step 5. The remote issue body MUST contain the following sections in order:

- [ ] 1. **Spec Reference Blockquote** (mandatory — top of body, before all other content) — the forward-reference link pointing to the issues-data branch URL:

   ```
   > Full spec and plan artifacts: {{REMOTE_BROWSER_URL}}/{{OWNER}}/{{REPO}}/tree/issues-data/.issues/N/
   ```

   - `{{REMOTE_BROWSER_URL}}` from session-init (platform-agnostic — use `github.html_url` or `gitbucket.html_url` as appropriate)
   - `{{OWNER}}` / `{{REPO}}` from session-init, verified against the target issue's repository
   - `{{SPEC_BRANCH}}` always `issues-data`
   - `{{SPEC_PATH}}` always `.issues/N/` (where N is the created issue number)
   - All links MUST be full resolved URLs — no platform shortcuts (`#NNN`, relative paths)

- [ ] 1. **Problem** (mandatory) — What problem this solves, why now, BLUF (Bottom Line Up Front) format. 1-3 sentences.
- [ ] 1. **Scope** (mandatory) — 3-5 bullets describing what is in-scope, followed by an explicit `**Out of scope:**` list describing what is NOT covered.
- [ ] 1. **Approach** (mandatory) — High-level solution description, 3-5 sentences. Focus on architectural choices and rationale, not implementation details.
- [ ] 1. **Impact** (mandatory) — Top 3 risks with one-line mitigation each, key dependencies, and a call to action.

**Post-creation enforcement:** Run this check after the remote issue body is written. If any section is missing, call `issue-operations → update-issue` to amend the body with the missing section(s). Do NOT proceed to Step 5 until all 5 sections are verified present.

### Step 5: Write local spec

Write the full spec to the correct local path:

- Root repo issues: `{project_root}/.issues/{N}/spec.md`
- Submodule issues: `{project_root}/{path}/.issues/{N}/spec.md` (where `path` comes from session-init Repo Information; N is the remote-assigned number from Step 3 — local == remote BY CONSTRUCTION)

Include the GitHub URL blockquote at the top of the local spec:

### Step 6: Copy analytical artifacts

Copy **only analysis artifacts** from the analysis step to the issue's artifact directory. The `.issues/{N}/artifacts/` directory is a metadata-only store — it MUST NOT receive source code, test files, test fixtures, or any other non-analysis content. Only the analysis artifacts produced by the spec-creation pipeline (pre-spec-inspection, requirements, decomposition, and the 7 analytical artifacts) belong here.

- [ ] 1. Source: `tmp/{issue_number}/artifacts/`
- [ ] 2. Destination: `{project_root}/{path}/.issues/{issue_number}/artifacts/`
- [ ] 3. Copy only the analysis artifacts (`.yaml`/`.md` analysis outputs such as `pre-spec-inspection.yaml`, `requirements-output.yaml`, `decompose-output.yaml`, `blast-radius.yaml`, `concern-map.yaml`, `code-path-inventory.yaml`, `cross-cutting-matrix.yaml`, `interface-compatibility.yaml`, `state-analysis.yaml`, `testability-assessment.yaml`, `pipeline-readiness.yaml`) — do NOT copy source code, test files, test fixtures, or test configuration
- [ ] 4. Use `shutil.copytree` or equivalent to copy the analysis-artifact directory
- [ ] 5. If the source directory does not exist, log a warning and continue (artifacts may have been cleaned up)

This ensures analysis artifacts are preserved alongside the spec for downstream consumers (auditors, plan creators) while keeping `.issues/{N}/artifacts/` free of source/test/fixture content.

```
> **Full spec and artifacts: [`{issues_prefix}{N}/`]({browser_url}/{owner}/{repo}/tree/issues-data/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `{issues_prefix}{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
```

### Step 7: Hand off post-push reconciliation to the reconcile-push task

After [skills/issue-operations/platforms/local/tasks/push-artifacts.md](skills/issue-operations/platforms/local/tasks/push-artifacts.md) runs and returns the `artifact_url`, the post-push reconciliation of the Spec Reference Blockquote / artifact URL is performed by the separate `reconcile-push` task card. This task does NOT dispatch `push-artifacts` or `reconcile-push` internally — the orchestrator dispatches each as a separate workflow step.

- [ ] 1. Record the `artifact_url` returned by `push-artifacts` in the result contract for the orchestrator to pass to the `reconcile-push` step.
- [ ] 2. Do NOT call `task()` or `skill()` from within this task — sub-agents cannot dispatch sub-agents. The orchestrator sequences the `reconcile-push` step after this task completes.

## Exit Criteria

- [ ] Spec assembled with all required sections
- [ ] Format-level rules applied (SHALL language, dark-prose-007, SC determinism, Documentation Sources columns)
- [ ] Remote issue stub created FIRST (when API available), before any local record
- [ ] Issue number N taken from the API create response's `number` field (remote-number-first — remote API is the source of truth; local counter NOT used when a remote API is available)
- [ ] Local issue record created at exactly N: `.issues/N/`, issue.yaml with `remote_issue: N`, binding fields (remote_issue, remote_url, github_url) all referencing N — local == remote BY CONSTRUCTION
- [ ] `needs-approval` and `spec-draft` labels recorded in local `{issues_prefix}/{N}/issue.yaml` labels array as primary canonical source (REQUIRED — via `local-issues update --labels`)
- [ ] Remote `spec-draft` label write attempted best-effort; remote failure does not block completion
- [ ] Full spec written to remote issue body (when API available)
- [ ] Local spec written to correct `.issues/{N}/spec.md` path
- [ ] Analysis artifacts (not source/test/fixture) copied from `tmp/{issue_number}/artifacts/` to `.issues/{N}/artifacts/`
- [ ] `artifact_url` from `push-artifacts` recorded in the result contract for the `reconcile-push` step
- [ ] No internal sub-agent dispatch performed — this task executes its steps directly
- [ ] No analysis steps performed (no inspection, decomposition, or artifact generation)
- [ ] No verification steps performed (no holistic check or structural validation)

## Result Contract

```yaml
status: DONE | BLOCKED
spec_path: "{project_root}/.issues/{N}/spec.md"
issue_url: "https://github.com/{owner}/{repo}/issues/{N}"
artifact_url: "https://github.com/{owner}/{repo}/tree/issues-data/{N}/"
remote_issue: <N>
remote_url: "https://github.com/{owner}/{repo}/issues/{N}"
github_url: "https://github.com/{owner}/{repo}/issues/{N}"
finding_summary: "Brief summary of spec structure, sections, and key decisions"
blocker_reason: "If BLOCKED: why the spec could not be created (e.g., API_FAILURE_MID_FLOW, LOCAL_LABEL_WRITE_FAILED)"
```
