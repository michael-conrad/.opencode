# Task: verify-authorization — Step 5b: Spec-to-Plan Approval Cascade

## Purpose

When a spec is approved and a plan already exists for that spec, the plan inherits the spec's approval status. This eliminates the redundant second approval step when a plan faithfully implements an already-approved spec.

## Conditions

The two-gate model STILL applies when no plan exists at the time of spec approval: spec approval → plan creation → plan approval → implementation. The cascade ONLY activates when a plan already exists.

## 5b.1 Detect Approval Cascade Conditions

This step runs ONLY when the approved issue is a spec (detected in Step 5 Auto-Dispatch Situation differentiation).

```python
# Determine if this is a spec approval
is_spec = "spec" in [l["name"] for l in issue["labels"]] or issue["title"].startswith("[SPEC")

if not is_spec:
    # Skip cascade — only applies to spec approvals
    proceed to Step 6

# Search for local plan files referencing this spec
spec_number = issue["number"]
plan_files = glob_plan_files_for_spec(spec_number)  # Searches .issues/*/plan.md and */.issues/*/plan.md for "Spec: #N"
```

## 5b.2 Process Cascade Approval

If one or more plan files reference the approved spec:

```python
if plan_files:
    # Plans are local artifacts — cascade approval means the plan is considered approved
    # No GitHub Issue labels or comments needed (plans are not GitHub Issues)
    most_recent = plan_files[-1]  # Most recent by file modification time
    older_plans = plan_files[:-1]

    # Cascade-approve the most recent plan
    # (No GitHub Issue mutation — plans are local files)
    log_cascade(spec_number, most_recent)

    # Supersede older plans
    for old_plan in older_plans:
        log_supersede(old_plan, most_recent)

elif not plan_files:
    # No plan exists — cascade does NOT apply
    # Current flow is correct: spec approval → writing-plans create → plan needs approval
    proceed to Step 6 (auto-dispatch to writing-plans)
```

## 5b.3 Cascade Does NOT Apply When

- The approved issue is a plan (not a spec) — cascade is spec-to-plan only
- No plan exists for the spec — current flow is correct, writing-plans will create a new plan
- The spec has been revised — existing revocation rules apply; cascade approval is revoked per Step 6 "Spec Revision Revocation Detection"
- The plan does not faithfully implement the spec — `plan-fidelity-auditor` catches this during implementation review

### Exception: Pipeline-Initiated Non-Substantive Revisions

Per `approval-gate-015`, pipeline-initiated non-substantive spec revisions do NOT trigger cascade revocation. When a pipeline gate (e.g., SC-coherence gate) detects a non-substantive spec defect and the orchestrator revises the spec to fix it, the linked plan approval is preserved. The plan is auto-updated via `writing-plans --task update` and the pipeline continues without requiring re-authorization.

**Non-substantive** means: changes to evidence types, verification methods, artifact paths, or SC wording that do NOT alter the implementation intent, scope, or success criteria semantics. Substantive changes still trigger standard revocation per Step 6.

**⚠️ Body-Preservation Safeguard:** This task only updates labels (no `body=` parameter in `github_issue_write` calls). Status updates use `github_add_issue_comment`. If any future modification were to use `issue-operations -> update-issue (github_issue_write(method=update, body=...)`, it MUST verify that the new body preserves all original content (len(new_body) >= 0.8 * len(original_body)). See `000-critical-rules.md` → "Critical Violation: Issue Body Erasure" for the project-wide rule. <!-- Routes through issue-operations per SPEC #683 -->

## 5b.4 Edge Cases

| Edge Case | Handling |
| -- | -- |
| Multiple plans for same spec | Cascade approves the most recent plan by creation date; older plans are superseded |
| Plan created after spec approval | Handled by `writing-plans --task create` post-creation step |
| Spec revised after cascade | Existing revocation rules apply — see Step 6 "Spec Revision Revocation Detection" |
| No plan exists | Cascade does NOT apply; current flow (spec approval → writing-plans) is correct |
| Plan already approved (no `needs-approval` label) | No action needed — plan is already approved |

**Evidence artifact:** `glob .issues/*/plan.md */.issues/*/plan.md` + grep for `Spec: #N` showing plan files referencing the spec. Plans are local artifacts — no GitHub Issue mutation needed.

## Work State I/O

- **Reads from:** `## sub-issue-verification`
- **Writes to:** `## spec-to-plan-cascade`

After completing this task, write results to the work state file under section `## spec-to-plan-cascade` using the YAML format defined in `enforcement/work-state-schema.md`.