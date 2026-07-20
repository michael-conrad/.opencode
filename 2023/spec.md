## Root Cause

The spec-creation `revise` workflow has no step to write the revised spec body to `.issues/{N}/spec.md`. The workflow is:

```
1. local-issues sync
2. change-control          ← versions the spec, does NOT write body
3. revise-remote-body      ← reads local spec, updates remote
4. spec-audit
5. local-issues sync
6. completion
```

After revision, the remote issue body has new content but `.issues/{N}/spec.md` still has the old content. They drift.

Additionally, the `completion` task doesn't verify mirror integrity (both local and remote exist and are in sync), and `revise-remote-body` has no precondition check that the local spec was actually updated before reading it.

## Fix Approach

1. Add a `revise-local-spec` step to the `revise` workflow (between change-control and revise-remote-body) that writes the revised spec body to `.issues/{N}/spec.md`
2. Add a precondition check to `revise-remote-body` that verifies `.issues/{N}/spec.md` exists and is current
3. Add a mirror integrity check to `completion` that verifies both local and remote are in sync

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `revise` workflow in spec-creation SKILL.md includes `revise-local-spec` step between change-control and revise-remote-body | `string` | grep for `revise-local-spec` in the revise workflow definition |
| SC-2 | `revise-local-spec.md` task file exists and writes revised spec body to `.issues/{N}/spec.md` | `string` | file exists check |
| SC-3 | `revise-remote-body.md` has precondition check: verify `.issues/{N}/spec.md` exists and is current before reading | `string` | grep for precondition/guard in revise-remote-body.md |
| SC-4 | `completion.md` has mirror integrity check: verify both `.issues/{N}/spec.md` exists AND remote body has blockquote | `string` | grep for mirror integrity check in completion.md |
| SC-5 | After a spec revision, both remote issue body AND `.issues/{N}/spec.md` are in sync | `behavioral` | `opencode run` with spec revision scenario → verify both locations have matching content |

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/spec-creation/SKILL.md` | Add `revise-local-spec` step to revise workflow; update Invocation table |
| `.opencode/skills/spec-creation-validation/tasks/revise-local-spec.md` | New file: writes revised spec body to `.issues/{N}/spec.md` |
| `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` | Add precondition check for local spec existence/currency |
| `.opencode/skills/spec-creation-validation/tasks/completion.md` | Add mirror integrity check |

## Risk Assessment

- **Low risk**: The change adds missing steps to an existing workflow. It cannot break existing specs — it only ensures the local spec file is written during revision, which was previously skipped. The only risk is a new task file that doesn't work correctly, which is caught by SC-5's behavioral test.
