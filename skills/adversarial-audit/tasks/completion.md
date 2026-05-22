<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: completion

Idempotent completion subtask for adversarial-audit. Ensures mandatory steps ran regardless of where the workflow halted.

## State Check Phase

1. **Auditor models resolved:** Check whether `resolve-models` successfully returned two cross-family auditor selections
2. **Auditors tasked:** Check whether orchestrator dispatched `task(subagent_type="auditor-*")` for both auditor-1 and auditor-2
3. **Verdicts collected:** Check whether structured JSON verdicts were received from both auditors
4. **Cross-validation computed:** Check whether cross-validate produced a definitive PASS or FAIL result with `next_step` field

## Orchestrator-Driven Dispatch Chain

The dispatch chain is orchestrated by the main agent (orchestrator), NOT by individual sub-tasks. The flow is:

1. **Orchestrator dispatches** `task(general)` ← resolve-models → receives `{ auditor_1, auditor_2 }` pair
2. **Orchestrator dispatches** `task(auditor-1)` and `task(auditor-2)` in parallel → receives verdicts from both
3. **Orchestrator dispatches** `task(general)` ← cross-validate with `auditor_verdicts` (pre-resolved verdict objects, NOT auditor model names) → receives cross-validation result
4. **Orchestrator routes** based on `next_step` field: `"proceed"` for PASS, `"remediate then re-audit"` for FAIL

cross-validate does NOT dispatch auditors — it receives pre-resolved verdicts from the orchestrator. resolve-models does NOT dispatch auditors — it returns model pairs for the orchestrator to dispatch.

## Skill-Specific Completion

1. **Auditor model resolution verification** (if not already performed):
   - Confirm that `resolve-models` returned two different-family auditor selections
   - Confirm neither auditor shares the orchestrator's model family
   - If incorrect: flag STRUCTURE-VIOLATION for orchestrator retry via `resolve-models`

2. **Verdict integrity check** (if not already performed):
   - Each auditor verdict MUST be structured as `[{id, result, explanation}]`
   - Both verdicts MUST be present (no single-auditor fallback)
   - If missing or malformed: report VERDICT-INTEGRITY failure, do NOT fabricate results

3. **Consensus enforcement** (if not already performed):
   - PASS iff both auditors independently agree PASS
   - Any disagreement, partial result, or missing verdict = FAIL
   - If consensus not evaluated: compute from collected verdicts

## Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| No auditors resolved | MISSING-ELEMENT | flag-for-review | HALT — orchestrator must re-invoke `resolve-models` |
| Single auditor invoked | MISSING-ELEMENT | flag-for-review | HALT — dual-auditor invariant violated |
| Malformed verdict | VERDICT-INTEGRITY | flag-for-review | HALT — cannot fabricate consensus from bad data |
| Consensus not computed | CONSENSUS-GAP | auto-fix | Compute from collected verdicts |
| Both auditors same family | STRUCTURE-VIOLATION | flag-for-review | HALT — orchestrator must re-invoke `resolve-models` |
| Missing `resolve-models` invocation | MISSING-ELEMENT | flag-for-review | HALT — resolve-models is mandatory entry point per adversarial-audit-013 |
| Missing auditor task() dispatch | MISSING-ELEMENT | flag-for-review | HALT — orchestrator must task() both auditors |
| Missing cross-validate invocation with verdicts | MISSING-ELEMENT | flag-for-review | HALT — orchestrator must task() cross-validate with verdicts |

## Shared Completion Delegation

Reference `skills/completion-core/completion-core.md` for reporting:

1. Report executive summary in chat (always runs)
2. Action URL (issue URL) as the URL (ALWAYS last)

## Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, partial, error), produce a status message containing:
1. What was completed
2. What was attempted but not completed
3. Why the halt occurred

This is the completion guarantee: NO adversarial-audit workflow ends without a status message.

## Report Phase

Generate executive summary in chat:

```
**Summary:**

<1-2 sentences describing the audit result and stakeholder value>

**Outcome:** <What the consensus verdict means for stakeholders>

<URL if applicable, ALWAYS LAST>

🤖 <AgentName> (<ModelId>) <status>
```

## Pipeline Signal

```
CONTINUE: approval-gate --task verify-authorization
HALT
```

### Format Verification Before Halt (MANDATORY)

**Idempotent — safe to invoke multiple times. This verification runs before EVERY halt, regardless of path.**

- [ ] Executive summary present as **first** element
- [ ] Outcome line present after summary
- [ ] Consensus result (PASS/FAIL) clearly stated in outcome
- [ ] URL present IF relevant (after outcome, before byline)
- [ ] AI byline present as **LAST** element
- [ ] No stale todowrite items remain (all cleared or N/A)

## Live Verification: Completion Evidence (MANDATORY)

**Each completion state check MUST be verified via tool call, not just asserted. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "Cross-family auditors selected" | Verify two different families selected | Check `resolve-models` result contract | MISSING-ELEMENT |
| "Auditors tasked" | Verify task() occurred | Check `task()` call logs in work state file | MISSING-ELEMENT |
| "JSON verdicts received" | Verify structured output | Parse `[{id, result, explanation}]` from auditor results | VERDICT-INTEGRITY |
| "Consensus evaluated" | Verify PASS/FAIL determination | Cross-reference both verdicts | CONSENSUS-GAP |

**Evidence artifact:** Tool call results for each completion state check.

## Sub-Agent Routing

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|
| `auditor_dispatch_status`, `resolve_models_result`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase` | Orchestrator reasoning, expected outcomes, verdict content | N/A — this is a completion task, not a task() routing task | NO |

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`