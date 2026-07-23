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

Read the full spec from `{spec_path}`.

### Step 2: Read validation findings

Read the validation findings or revision reason to understand what needs to change. If validation findings are provided, each finding includes the check name, FAIL result, and justification.

### Step 3: Apply revisions

For each validation finding or revision request:

1. Identify the spec section(s) that need revision
2. Apply the fix (correct SC wording, add missing sections, fix evidence types, update traceability, etc.)
3. Do NOT change the spec's scope, requirements, or success criteria beyond what the findings require

### Step 4: Update change control

Append a change control entry to the spec documenting:

- Date of revision
- What was changed
- Why it was changed (which validation finding or revision reason)
- Who authorized the change

### Step 5: Write revised spec to remote issue body

When a remote API is available, update the remote issue body with the revised spec content.

### Step 6: Write revised local spec

Write the revised spec to the local path at `{spec_path}`.

## Exit Criteria

- [ ] All validation findings addressed (or documented as won't-fix with justification)
- [ ] Change control entry appended
- [ ] Remote issue body updated (when API available)
- [ ] Local spec updated at `{spec_path}`
- [ ] No analysis steps performed (no inspection, decomposition, or artifact generation)
- [ ] No verification steps performed (no holistic check or structural validation)

## Result Contract

```yaml
status: DONE | BLOCKED
spec_path: "{spec_path}"
finding_summary: "Summary of what was revised and why"
blocker_reason: "If BLOCKED: why the revision could not complete"
```
