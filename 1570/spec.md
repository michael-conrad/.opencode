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

## Closure — Triage Verdict: MOOT (evidence-backed), 2026-10-17

Closed not_planned per developer direction ("close per recommendation"). The
reported defect mechanism no longer exists in the tree; implementing as filed
would re-create prior issues' resolved work.

1. **Evidence mechanism retired.** The reported format (`Skills discovered: 42`
   / `Skill invocation: FAIL (no skills detected)`) traces to the retired
   v1-era test script — zero matches in the current tree; `.opencode/tests/`
   was removed 2026-07-14 and `tests-v2/test-enforcement.sh` was rewritten in
   #2490 stage 4e (2026-10-05) to the artifact-only generator paradigm (model
   probes generate artifacts and exit 0; no script-side evaluation).
2. **As-filed fix now prohibited.** Re-adding script-side skill-invocation
   detection emitting FAIL verdicts violates `tests-v2/AGENTS.md` §1/§2
   (scripts never evaluate model output; `session.yaml` via clean-room
   sub-agent is the PRIMARY evidence source).
3. **Stale expectation.** The `create-spec` → `brainstorming` mapping targets a
   skill retired in the #2490 deck rip; pre-spec exploration now routes to
   `explore`.

**Residual finding recorded (outside this bug's intent):**
`tests-v2/test-enforcement.sh` registry carries stale deck references —
`SCENARIO_TAGS` tags scenarios with retired skill names (`brainstorming`,
`issue-review`), and `FILE_SCENARIO_MAP` maps ~13 dead paths (guidelines/
`000|010|020|060|091|022|257`; skills/`approval-gate`, `brainstorming`,
`issue-operations`, `issue-review`, `git-workflow`,
`verification-before-completion`) — so the `--changed` filter silently never
fires for those entries. Left unaddressed, this decay class is what caused
this issue's stale evidence in the first place and can re-create prior
issues' work; any repair is new scoped work, not this closure.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)