# [SPEC-FIX] Audit dispatch: frugal contract enforcement + post-audit orchestrator validation

## Problem

When an auditor sub-agent writes a verdict artifact to disk but fails to return the frugal result contract as proof of completion, the orchestrator has no mechanism to detect the failure. The task() result may contain narrative text about methodology phases instead of the structured YAML contract (`status`, `artifact_path`, `summary`) the orchestrator needs to route the next pipeline step.

During pipeline #884 step 10.4, auditor_1 (mistral-large) produced a valid artifact at `./tmp/artifacts/pipeline-884-audit-auditor_1-PASS-...yaml` but returned narrative text instead of the frugal contract. The orchestrator only detected this via manual inspection — no automated gate exists.

Separately, auditor_2 (qwen3.5) did not produce output at all — the resolve-models selection must be re-run to get a fresh randomized pair after any dispatch failure. Also: the resolve-models selector is supposed to pick from 4 families (deepseek, mistral, gemma, qwen) — qwen3.5 was the second consecutive selection of a non-deepseek-v4-flash auditor despite presumably requesting cross-family pairs. The same model was returned from successive resolve-models invocations, indicating insufficient randomization / candidate pool pruning.

## Root Causes

1. **verification-audit.md Step 9** defines the frugal contract format but has no enforcement mechanism — sub-agents can skip the contract return and the orchestrator accepts any task() output
2. **Orchestrator has no post-audit validation** — it must check that the task() result contains `artifact_path` before proceeding. Missing contract = treat as FAIL + redispatch
3. **resolve-models returns stale pairs** — successive calls return the same auditor types (qwen3.5) instead of fresh randomization. Pool pruning/filtering results in insufficient candidate diversity.

## Solution

### Part A: Frugal contract validation in verification-audit.md

Add a post-audit orchestrator gate after every auditor dispatch:

```
- [ ] N.5a   Validate frugal contract — task() result MUST contain artifact_path field
             If missing → treat as FAIL, re-run resolve-models --re-task, re-dispatch
             If present → verify file exists at artifact_path
             If file missing → treat as FAIL, re-run resolve-models --re-task, re-dispatch
```

### Part B: resolve-models `--re-task` — same pair is valid, no deliberation

The `--re-task` flag requests fresh randomization but MAY return the same auditor pair. This is not an error — it is valid output. The agent MUST NOT deliberate, second-guess, or re-run resolve-models if the same pair is returned. The agent dispatches whatever resolve-models returns. Period.

Rationale: With 4 model families and 4 available auditor types, `--re-task` may randomly select the same pair. This is expected behavior. The agent's job is to dispatch, not to judge the selection.

### Part C: Broader fix

The verification-audit.md Step 9 contract format becomes a **mandatory exit criterion** — auditors must return the YAML contract as their sole task() output. The orchestrator's post-task validation enforces this.

## Affected Files

- `.opencode/skills/adversarial-audit/tasks/verification-audit.md` — add Step 9a post-audit validation gate
- `.opencode/skills/adversarial-audit/tasks/resolve-models.md` — document `--re-task` randomization guarantee
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` — add post-audit orchestrator validation to step 10 dispatch
- `.opencode/tools/resolve-models` — ensure --re-task produces genuinely different pairs

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Auditor returns narrative text instead of frugal contract → orchestrator returns FAIL and re-dispatches | behavioral | opencode-cli run with auditor that returns narrative → stderr shows re-dispatch |
| SC-2 | resolve-models `--re-task` returns valid auditor pair (may be same as previous — agent dispatches without deliberation) | structural | Run `resolve-models --re-task`, dispatch returned pair without re-running |
| SC-3 | verification-audit.md has Step 9a post-audit validation checklist item | structural | grep for "9a" or "validate frugal" in verification-audit.md |