## Problem

Three test scenarios in `test-enforcement.sh` consistently fail because the model (`ollama-cloud/glm-5.1`) does not dispatch the expected skills:

| Scenario | Expected Skill | Result |
|----------|---------------|--------|
| `bug-report` | `systematic-debugging` | FAIL (no skills detected) |
| `bug-discovery-no-auth` | `systematic-debugging` | FAIL (no skills detected) |
| `create-spec` | `brainstorming` | FAIL (no skills detected) |

## Root Cause

The model is not dispatching skills for these prompts. The plugin loads successfully (42 skills discovered), but the model's output doesn't contain skill invocation strings in stderr. This may be a model behavior issue (the model doesn't recognize the trigger patterns) or a prompt design issue (the test prompts don't match the skill's trigger keywords).

## Evidence

```
=== Testing scenario: bug-report ===
Message: I found a bug in the parser — it crashes on empty input
Expected skill: systematic-debugging
  Plugin loaded: 1
  Skills discovered: 42
  Skills invoked: none detected
  Infrastructure: PASS
  Skill invocation: FAIL (no skills detected)
```

## Classification

Pre-existing — these failures were present before any Phase 5 changes.

## Suggested Fix

Investigate whether the test prompts need updating to better match the skill's trigger keywords, or whether the model needs a different prompt format to trigger skill dispatch.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)