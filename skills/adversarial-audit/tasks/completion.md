# Task: completion

Idempotent completion subtask for adversarial-audit. Ensures mandatory steps ran regardless of where the workflow halted.

## State Check Phase

1. **Auditor models resolved:** Check whether `resolve-models` successfully returned two cross-family auditor selections
2. **Cross-validation dispatched:** Check whether auditor sub-agents were dispatched via `task(subagent_type="auditor-*")`
3. **Verdicts collected:** Check whether structured JSON verdicts were received from both auditors
4. **Consensus gate evaluated:** Check whether cross-reference produced a definitive PASS or FAIL result

## Skill-Specific Completion

1. **Auditor dispatch verification** (if not already performed):
   - Confirm that exactly two auditors from different model families were dispatched
   - Confirm neither auditor shares the orchestrator's model family
   - If incorrect: re-invoke `resolve-models` to select proper cross-family pair

2. **Verdict integrity check** (if not already performed):
   - Each auditor verdict MUST be structured as `[{id, result, explanation}]`
   - Both verdicts MUST be present (no single-auditor fallback)
   - If missing or malformed: report VERDICT-INTEGRITY failure, do NOT fabricate results

3. **Consensus enforcement** (if not already performed):
   - PASS iff both auditors independently agree PASS
   - Any disagreement, partial result, or missing verdict = FAIL
   - If consensus not evaluated: compute from collected verdicts

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
| "Auditors dispatched" | Verify dispatch occurred | Check `task()` call logs in work state file | MISSING-ELEMENT |
| "JSON verdicts received" | Verify structured output | Parse `[{id, result, explanation}]` from auditor results | VERDICT-INTEGRITY |
| "Consensus evaluated" | Verify PASS/FAIL determination | Cross-reference both verdicts | CONSENSUS-GAP |

**Evidence artifact:** Tool call results for each completion state check.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| No auditors resolved | MISSING-ELEMENT | auto-fix | Invoke `resolve-models` |
| Single auditor dispatched | MISSING-ELEMENT | flag-for-review | HALT — dual-auditor invariant violated |
| Malformed verdict | VERDICT-INTEGRITY | flag-for-review | HALT — cannot fabricate consensus from bad data |
| Consensus not computed | CONSENSUS-GAP | auto-fix | Compute from collected verdicts |
| Both auditors same family | STRUCTURE-VIOLATION | auto-fix | Re-select using `resolve-models` |
