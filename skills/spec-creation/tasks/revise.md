# Task: revise — Spec revision pipeline

## Category

PRODUCTION

## Purpose

Revise an existing spec based on validation findings or revision requests. Update the spec body, update change control tracking, and write the revised spec to both remote and local paths. This task does NOT perform analysis steps or verification steps.

## Entry Criteria

- [ ] `issue_number`, `spec_path`, and `validation_findings` or `revision_reason` received in dispatch context
- [ ] No preloaded spec content, orchestrator reasoning, or expected outcomes in the prompt
- [ ] Spec file exists at `{spec_path}`
- [ ] Validation findings or revision reason provided

## Procedure

### Step 1: Read current spec

- [ ] 1.1. Read the full spec from `{spec_path}`.

### Step 2: Read validation findings

- [ ] 2.1. Read the validation findings or revision reason to understand what needs to change. If validation findings are provided, each finding includes the check name, FAIL result, and justification.

### Step 3: Apply revisions

- [ ] 3.1. For each validation finding or revision request:

  1. Identify the spec section(s) that need revision
  2. Apply the fix (correct SC wording, add missing sections, fix evidence types, update traceability, etc.)
  3. Do NOT change the spec's scope, requirements, or success criteria beyond what the findings require

### Step 4: Update change control

- [ ] 4.1. Append a change control entry to the spec documenting:

  - Date of revision
  - What was changed
  - Why it was changed (which validation finding or revision reason)
  - Who authorized the change

### Step 5: Regenerate exec-summary remote issue body

- [ ] 5.1. When a remote API is available, regenerate the exec-summary remote issue body from the revised spec. Route the regenerated body to the canonical exec-summary body format defined in [issue-operations-core/tasks/creation.md](issue-operations-core/tasks/creation.md) Step 5, so the remote body reflects the revised spec content (Spec Reference Blockquote, Problem, Scope, Approach, Impact). Do NOT leave a stale exec-summary body that contradicts the authoritative local spec.

### Step 6: Write revised local spec

- [ ] 6.1. Write the revised spec to the local path at `{spec_path}`.

### Step 7: Delete stale analytical artifacts

- [ ] 7.1. Delete all files in `{project_root}/{path}/.issues/{N}/artifacts/` to ensure stale artifacts from the previous spec version do not accumulate. Use `rm -rf {project_root}/{path}/.issues/{N}/artifacts/` to remove the entire artifacts directory.

## Exit Criteria

- [ ] All validation findings addressed (or documented as won't-fix with justification)
- [ ] Change control entry appended
- [ ] Exec-summary remote issue body regenerated from the revised spec (when API available)
- [ ] Local spec updated at `{spec_path}`
- [ ] Stale analytical artifacts deleted from `{project_root}/{path}/.issues/{N}/artifacts/`
- [ ] No analysis steps performed (no inspection, decomposition, or artifact generation)
- [ ] No verification steps performed (no holistic check or structural validation)

## Result Contract

```yaml
status: DONE | BLOCKED
spec_path: "{spec_path}"
finding_summary: "Summary of what was revised and why"
blocker_reason: "If BLOCKED: why the revision could not complete"
```
