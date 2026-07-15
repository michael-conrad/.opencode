# Task: verify-authorization — Step 5: Verify Sub-Issue Structure

## Purpose

This gate is the SINGLE AUTHORITATIVE verification point for sub-issue readiness. The `issue-operations` `link-sub-issue` task's verification logic is superseded — all sub-issue verification logic lives here.

## Procedure

### 5.1 Determine Plan Type

```
# Read plan from local file (plans are local artifacts, not GitHub Issues)
plan_paths = [f".issues/{N}/plan.md", f"{project_root}/{path}/.issues/{N}/plan.md"]
plan_body = read_local_plan_file(plan_paths)

if plan_body:
    phases = parse_phases_from_plan_body(plan_body)
```

### 5.2 Verify Sub-Issues Under Plan (All Plans)


For all plans:

```python
sub_issues = issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=plan_issue) <!-- Routes through issue-operations per SPEC #683 -->

# Verify sub-issues exist under the plan (NOT the spec)
if not sub_issues:
    # Auto-create sub-issues under the plan
    # Plan approval covers sub-issue creation — no separate auth needed
    # See issue-operations --task link-sub-issue for creation procedure
    pass

# Verify sub-issue structure matches plan phases
for phase in phases:
    matching_sub_issue = find_sub_issue_for_phase(sub_issues, phase)
    if not matching_sub_issue:
        # HALT: sub-issue structure incomplete
        pass

# Verify sub-issue bodies contain phase context (Phase 1 enrichment)
for sub_issue in sub_issues:
    body = issue-operations -> read-issue (github_issue_read(method="get", issue_number=sub_issue["number"])["body"] <!-- Routes through issue-operations per SPEC #683 -->
    if phase_context_insufficient(body):
        # Report: sub-issue body lacks phase context
        pass
```

### 5.2.1 Phase-Count Cross-Reference Check

For multi-task plans, verify that the number of sub-issues matches the number of phases in the plan body. A mismatch indicates incomplete sub-issue linkage. See `enforcement/sub-issue-graph-traversal.md` for the phase-count cross-reference algorithm.

**Finding Classification:** See `enforcement/adversarial-verification.md` for the binary PASS/FAIL classification model (auto-fix as remediation action only) and evidence artifact format.

### 5.3 Adversarial Verification of Sub-Issue State

**Before trusting any sub-issue claim, verify against actual GitHub API state.**

```
For each sub-issue:
  child = issue-operations -> read-issue (github_issue_read(method="get", issue_number=sub_issue_number) <!-- Routes through issue-operations per SPEC #683 -->
  - Verify child.state matches claimed state (do NOT trust cache)
  - If child.state == "closed" → verify merged PR exists (not premature closure)
  - Verify child is linked under plan (NOT spec) → STRUCTURE-VIOLATION if under spec
  - Verify needs-approval label absent if parent plan has explicit authorization
```

**Evidence artifact:** `issue-operations -> read-issue (github_issue_read(method=get)` for each sub-issue showing actual state, title, labels, and parent link. <!-- Routes through issue-operations per SPEC #683 -->

### 5.4 Closed-Issue Verification Before Skipping

Before skipping a closed issue in any workflow gate, verify it was closed for the right reason. See `enforcement/closed-issue-verification.md` for the complete closed-issue verification procedure.

**Finding Classification for Closed-Issue Verification:** See `enforcement/adversarial-verification.md` for the binary PASS/FAIL classification model and evidence artifact format.

### 5.5 Transitive Issue Graph Verification (MANDATORY on Authorization and Re-Approval)

When any issue is authorized (approved, re-approved, or `Fixes`-closed), the agent MUST traverse the entire reachable issue graph to verify every node is in a consistent state. See `enforcement/sub-issue-graph-traversal.md` for the complete traversal algorithm, edge types, depth limits, and finding classification.

**When to Traverse:**

| Trigger | When | Depth Limit |
| -- | -- | -- |
| Issue approved/re-approved | `verify-authorization` receives explicit authorization | 5 |
| Issue closed by `Fixes` keyword (post-merge) | `cleanup` processes merged PR | 5 |
| Issue being verified as already-implemented | `verify-already-implemented` encounters a closed issue | 3 |
| Issue encountered during triage | `triage` classifies a closed issue | 3 |

After traversal completes, dispatch `reconcile-issue-graph` to act on findings. See `tasks/reconcile-issue-graph.md` for the reconciliation procedure.

**Every node in the reachable graph MUST produce an evidence artifact** — a `issue-operations -> read-issue (github_issue_read` tool call result. Graph traversal without per-node evidence is a verification honesty violation. <!-- Routes through issue-operations per SPEC #683 -->

### Finding Classification for Sub-Issue Verification

See `enforcement/adversarial-verification.md` for the binary PASS/FAIL classification model (auto-fix as remediation action only) and evidence artifact format.

## Work State I/O

- **Reads from:** `## scope-auto-resolve`, `## item-decomposition-check`
- **Writes to:** `## sub-issue-verification`

After completing this task, write results to the work state file under section `## sub-issue-verification` using the YAML format defined in `enforcement/work-state-schema.md`.