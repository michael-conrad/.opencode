---
remote_issue: 1206
remote_url: "https://github.com/michael-conrad/.opencode/issues/1206"
last_sync: "2026-06-14T18:03:48Z"
source: github
---

## Problem

During Phase 1 implementation of #1191 (write-plan skill dispatch table + protocol), the behavioral test harness repeatedly failed because it cloned the `.opencode` repository from the remote URL at `https://github.com/michael-conrad/.opencode.git`, but the feature branch commits were local-only — never pushed to the remote.

The `behavior_run` function in `helpers.sh` clones the _remote_ `origin` URL into a clean-room temporary home, then checks out the feature branch by name. When the branch exists only in the local repository, the clone sees the baseline `dev` code — not the feature branch code. The GREEN-phase test assertions then pass against the old code, producing false GREEN artifacts that show the 14-item checklist instead of the new dispatch table + protocol.

## Root Cause

The implementation pipeline has no step that requires `git push` before clean-room behavioral test execution. The gap is in the pipeline sequencing: implement → test phases need an explicit "ensure remote has latest commits" gate between GREEN implementation and behavioral test execution.

## Fix Spec

Add a mandatory push-to-remote step to the implementation pipeline, positioned immediately before any clean-room behavioral test execution. This step must verify the push succeeded (remote is up to date) before proceeding.

### Required Changes

1. **Pipeline documentation**: Update the implementation pipeline task files to include a "push feature branch to remote" step before clean-room behavioral test dispatch
2. **Behavioral test harness**: The `behavior_run` function should optionally check if the remote has the current branch SHA before cloning, and emit a clear error message if not
3. **Agent discipline**: Any agent running behavioral tests in clean-room mode MUST push the feature branch to remote first — no shortcuts, no exceptions

### Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Pipeline documentation includes explicit push-to-remote step before clean-room test dispatch | `string` | grep pipeline task files for push step |
| SC-2 | Behavioral test producing false GREEN (old code) is no longer possible when feature branch is pushed | `behavioral` | Run behavioral test with unpushed branch → verify test fails with clear error; push → verify test passes against new code |
| SC-3 | Agent documentation (guidelines/skills) includes the push-before-test mandate | `string` | grep relevant pipeline/skill files for push-before-test instructions |

### Notes

- The push step applies ONLY to feature branches that will be used in clean-room test environments. Dev branch changes that don't need behavioral testing are unaffected.
- This fix does not change the clean-room cloning mechanism — only the pre-flight condition that remote is up to date.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)