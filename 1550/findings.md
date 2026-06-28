# Findings: "needs approval" label regression (Issue #1550)

## 1. Current State: No Automated Label Application Exists Today

**There is zero automated `approved-for-*` or `needs-approval` label application in any platform sub-skill today.** Neither the GitHub MCP nor GitBucket API platform sub-skills contain code that applies authorization-scoped labels during issue creation. The label application described across SKILL.md files exists only as documentation — no implementation passes the labels through to the actual API call.

### Evidence: Creation task (`issue-operations/tasks/creation.md`)

The `creation` task documents `needs-approval` in multiple places but never actually implements it:

| Location | What It Says | What It Does |
|----------|-------------|---------------|
| Exit Criteria (line 23) | "`needs-approval` label applied" | Advisory exit criterion — no code enforces it |
| Step 2.1 GitHub (lines 164-170) | "Route to `platforms/github-mcp/` sub-skill via task(). Pass issue parameters (title, body, labels)." | The word "labels" appears in the instruction but NO specific label value is passed |
| Step 2.1 GitBucket (lines 169-170) | Same as GitHub — "Pass issue parameters" | No label parameter concretely specified |
| Line 318 | "Apply `needs-approval` label" (single-task exemption section) | Advisory instruction only, no code path that actually applies it |
| Step 2.2 local-first (line 196) | "Pass: `{title: "<title>", labels: ["needs-approval"]}`" | **This is the ONLY place a concrete label value appears** — but this is for local platform only, NOT remote GitHub/GitBucket |
| Safety Checks (line 343) | "`needs-approval` label applied" | Listed as a safety check with no mechanism to verify it |

### Evidence: Platform sub-skills have no label application logic

- **`platforms/github-mcp/SKILL.md`** lines 57-69: Documents the `approved-for-*` labels exist and are supported. Line 40 states "Labels on creation ✅ — `github_issue_write(method="create", labels=[...])`". But this is a capability manifest (what GitHub MCP CAN do), not an instruction to apply specific labels during issue creation. No task file in the github-mcp sub-skill constructs or passes any label values.

- **`platforms/gitbucket-api/SKILL.md`** lines 120-132: Same situation — documents label support and lists all eight `approved-for-*` labels plus `needs-approval`. No task file applies them during creation.

### Evidence: approval-gate skill has no apply-label implementation

The `approval-gate/SKILL.md` Trigger Dispatch Table (line 151) maps `"apply label" / "set approval label"` to an `apply-label` sub-task with context `{issue_number, authorization_scope}`. However:

- **No file named `apply-label` exists** in `.opencode/skills/approval-gate/tasks/`
- The dispatch table entry references a task that was never implemented
- Even if it existed, this is an *authorization-time* label application (when developer says "approved"), not a creation-time application

### Evidence: `verify-authorization.md` confirms labels are advisory, not gates

Line 15 of `approval-gate/tasks/verify-authorization.md`:
> "Advisory scope-marker written as GitHub label after work state file is updated; deprecated `needs-approval` label removed asynchronously"

Line 29:
> "Label write (advisory-only, asynchronous) — Write authorization-scope label after work state file is written; labels are visibility markers, not gates."

This confirms the design decision that labels are **visibility markers** applied as a side effect of authorization (post-work-state-write), NOT automatic labels applied during issue creation. The `needs-approval` label on newly created issues is therefore expected to be set manually by the agent or via the local platform's CLI tool — never automatically from remote API calls.

## 2. Where It SHOULD Be Applied

The documentation expects label application at these points:

### Creation-time (on spec issue creation)
- **File**: `issue-operations/tasks/creation.md`
- **Expected behavior**: When creating a new spec issue via remote platform (GitHub/GitBucket), the agent should pass `["needs-approval"]` as labels to the API call
- **Actual state**: For GitHub/GitBucket platforms, no label value is concretely specified in Step 2.1's routing instructions. The instruction says "Pass issue parameters (title, body, labels)" but provides no concrete values for what those labels should be

### Authorization-time (when developer approves)
- **File**: `approval-gate/tasks/verify-authorization.md` Step 2 ("Label write")
- **Expected behavior**: After work state is written, apply the appropriate `approved-for-*` label based on authorization scope
- **Actual state**: The task description exists but no concrete implementation mechanism (no `apply-label` task file; the dispatch table references a non-existent sub-task)

### Local platform (the only place that works)
- **File**: `.opencode/tools/local-issues` CLI tool (line 1757: `--labels` flag support)
- **Actual state**: The local platform DOES pass labels through. Step 2.2 of creation.md passes `{title, labels: ["needs-approval"]}` to the local creation flow

## 3. Was It Removed? Git History Analysis Required

The investigation shows this was likely **never implemented for remote platforms** rather than removed. Evidence:

1. The `creation.md` task file has always documented label application in exit criteria but never concretely specified which labels to pass for GitHub/GitBucket creation calls
2. The platform sub-skills document the *capability* (labels are supported by both GitHub and GitBucket APIs) without ever implementing the automatic application logic
3. No `apply-label` task file exists in approval-gate — this has been a long-standing gap, not a recent regression

The most plausible explanation is that **the system was designed with label application as an agent-discretionary responsibility** (the agent reads the exit criteria and "knows" to apply labels) but never had concrete implementation enforcing it. The documentation conflates "should happen" with "does happen."

## 4. What's Missing — Root Cause Analysis

### Gap 1: No label values passed for remote creation
In `issue-operations/tasks/creation.md` Step 2.1, the routing instruction says to pass labels but never specifies WHAT labels. The local-first flow (Step 2.2) does specify `["needs-approval"]`, creating an asymmetry between local and remote platforms.

**Fix**: Add concrete label specification for GitHub/GitBucket creation calls in Step 2.1, e.g., "Pass: `{title, body, labels: ["needs-approval", "SPEC"]}`" (or whatever the appropriate initial labels are).

### Gap 2: No `apply-label` task implementation
The approval-gate skill's dispatch table references an `apply-label` sub-task that doesn't exist. The Step 2 label write in `verify-authorization.md` has no concrete implementation.

**Fix**: Create `.opencode/skills/approval-gate/tasks/apply-label.md` with the actual procedure for applying `approved-for-*` labels based on authorization scope, using either:
- GitHub MCP: `github_issue_write(method="update", labels=[...])` 
- GitBucket API: `gb issue edit <N> --add-label <label>` (with known limitation that post-creation label mutation is broken — may need workaround)

### Gap 3: No verification of label application
The exit criteria list "`needs-approval` label applied" as a requirement, but the safety checks section has no mechanism to verify it was actually applied. The live verification table at line 366 only verifies that `read-labels` can be called — not whether the label is present.

**Fix**: Add a concrete post-creation step: "Call `issue-operations → read-labels`, verify `needs-approval` is in the returned list, re-apply if absent."

### Gap 4: GitBucket post-creation label mutation is broken
`gitbucket-api/SKILL.md` line 67 explicitly states: "Post-creation labels ❌ — Returns empty array — labels NOT added". This means even IF a `apply-label` task were implemented, it would not work for GitBucket. The workaround documented at line 132 is "remove old label via comment, apply new on next creation cycle" — which is impractical for an automated workflow.

**Fix**: Either accept this as a known platform limitation and document it clearly, or implement a GitBucket-specific workaround (e.g., use `gb issue edit --add-label` if newer gb versions support it).

### Gap 5: Documentation conflates capability with implementation
Both platform SKILL.md files list "Labels on creation ✅" in their capability manifests, which suggests automated label application works. It doesn't — the capability manifest documents what the underlying API supports, not what this codebase actually does.

**Fix**: Rename or clarify the "Capabilities Manifest" section to distinguish between "API supports X" and "We implement X."

## Summary Table

| Gap | Location | Severity | Fix Required |
|-----|----------|----------|-------------|
| No label values for remote creation | `creation.md` Step 2.1 | HIGH — this is the direct cause of the regression symptom | Add concrete labels to routing instruction |
| Missing apply-label task | `approval-gate/` skill | MEDIUM — blocks authorization-time label updates | Create `apply-label.md` task file |
| No post-creation verification | `creation.md` safety checks | LOW — advisory gap | Add read-labels verification step |
| GitBucket labels broken | `gitbucket-api/SKILL.md` line 67 | HIGH — platform limitation | Document or work around |
| Capability vs implementation confusion | Both platform SKILL.md files | MEDIUM — misleading documentation | Clarify capability manifest semantics |

## Result Contract

```yaml
status: DONE
finding_summary: "No automated approved-for-* label application exists for remote platforms. Labels are documented as exit criteria but never concretely passed to creation API calls. The apply-label task referenced in approval-gate dispatch table was never implemented. Only local platform (local-issues CLI) passes labels correctly."
artifact_path: .opencode/.issues/1550/findings.md
blocker_reason: null
