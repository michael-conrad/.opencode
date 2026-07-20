## Problem

There is no verification that the agent actually follows `Read [Text](path)` cross-reference links. The band-aid (#1923) adds a mandate. The holistic fix (#1924) rewrites the citations. But neither proves the agent calls `read` on the linked path when it encounters one in a guideline.

## Fix

Add behavioral enforcement tests that verify the agent follows `Read [Link](path)` cross-references. Each test:

1. Loads a guideline containing a `Read [Topic](path)` link where the referenced file is NOT pre-loaded
2. Prompts the agent about a topic that requires the referenced content
3. A clean-room sub-agent (dispatched directly by the orchestrator, not via assertion helpers) reads the full session output and returns PASS if the agent called `read` on the linked path, FAIL otherwise

The tests are RED until the rewrites in #1924 are complete. They can ship at any time — they don't block anything and nothing blocks them.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A behavioral test verifies the agent calls `read` on a linked path when it encounters a `Read [Link](path)` cross-reference in a guideline | `behavioral` | Clean-room sub-agent evaluates session output; PASS if agent called `read` on the linked path |
| SC-2 | The test uses a clean-room sub-agent dispatched by the orchestrator, not assertion helpers | `structural` | Verify test script dispatches a sub-agent directly via task() |
| SC-3 | The test is RED until the referenced file exists and the link is in place | `behavioral` | Run test before #1924 rewrites; verify FAIL. Run after; verify PASS |

## Affected Files

- `.opencode/tests/behaviors/` — new behavioral test scripts

## Interdependency Ordering

- **BLOCKED BY**: Nothing (ships independently; tests are RED until #1924 rewrites)
- **BLOCKS**: Nothing
- **INDEPENDENT OF**: #1923 (band-aid), #1924 (rewrites), #1925 (linting)

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)