## Root Cause

The `change-control` task (`spec-creation-change-control/tasks/change-control.md:33-34`) explicitly mandates posting a comment after spec revision:

> "Post Issue comment with prose revision summary"

This directly contradicts the substantiveness gate in the comment task, which classifies "Revising/correcting spec" as **internal** (not stakeholder-facing) and routes it to `spec-creation --task change-control` instead of posting a comment.

The result: every spec revision produces a useless notification comment ("Spec revised to v1.1 — changes: ...") that provides zero value. The issue body itself already shows the revision. The comment is noise.

Additionally, the Channel-Routing Table in `000-critical-rules.md` says "Substantive spec revision → Chat + Issue comment", which contradicts the comment task's own substantiveness gate. The body update IS the issue communication — no separate comment is needed.

## Fix Approach

1. Remove the "Post Issue comment with prose revision summary" instruction from `change-control.md` Step 2 — keep only chat output
2. Update the Channel-Routing Table in `000-critical-rules.md` to say "Substantive spec revision → Chat only" (body update is the issue communication)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `change-control.md` Step 2 no longer mandates posting an issue comment for spec revisions | `string` | grep for "Issue comment" in change-control.md — zero matches for revision comment mandate |
| SC-2 | Channel-Routing Table in 000-critical-rules.md says "Substantive spec revision → Chat only" | `string` | grep confirms "Substantive spec revision → Chat only" in 000-critical-rules.md |
| SC-3 | After a spec revision, no useless notification comment is posted to the issue | `behavioral` | `opencode run` with spec revision scenario → verify no comment was posted (only body was updated) |

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/spec-creation-change-control/tasks/change-control.md` | Remove "Post Issue comment with prose revision summary" from Step 2 |
| `.opencode/guidelines/000-critical-rules.md` | Change "Substantive spec revision → Chat + Issue comment" to "Substantive spec revision → Chat only" |

## Risk Assessment

- **Low risk**: The change removes a comment-posting mandate that produces noise. The issue body update (handled by `revise-remote-body`) already communicates the revision. No stakeholder loses information — they see the updated body. The only risk is a developer who relied on comment notifications for spec changes, but the body update is the canonical communication channel.
