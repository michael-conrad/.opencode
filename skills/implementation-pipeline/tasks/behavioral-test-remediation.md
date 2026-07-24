# Task: behavioral-test-remediation

## Purpose

Remediate behavioral test failures through a structured diagnose → fix → re-run → re-evaluate → confirm PASS loop. This task is dispatched when a behavioral test evaluation returns FAIL.

## Input

- `issue_number`: Issue number for the spec being implemented
- `test_artifact_path`: Path to the behavioral test artifacts directory
- `sc_list`: List of SC IDs that failed evaluation

## Procedure

### 0. Rationalization-Check Gate (MANDATORY — Before Accepting Any "Infrastructure Issue" Diagnosis)

**Before accepting any "infrastructure issue" diagnosis, the agent MUST dispatch a clean-room rationalization-check sub-agent.**

The rationalization-check sub-agent receives ONLY:
- The proposed diagnosis ("infrastructure issue", "timeout", "model unavailable", etc.)
- The relevant rule text (020-go-prohibitions.md §1 cost-blind verification, 065-verification-honesty.md §Cost Model, 065-verification-honesty.md §Anti-Evasion Rules, 000-critical-rules.md §hard-fail)

The sub-agent does NOT receive:
- Orchestrator context or reasoning
- Cached results or preloaded evidence
- Any information about what the orchestrator "meant" or what constraints it was under

- [ ] 1. **Dispatch rationalization-check sub-agent.** Call `task(subagent_type="general")` with the proposed diagnosis and rule text. The sub-agent independently evaluates whether the proposed diagnosis is a rationalization.
- [ ] 2. **If sub-agent returns BLOCKED with REMEDIATION_MANDATORY:** The proposed diagnosis is a rationalization. HALT immediately. Do NOT proceed. Do NOT override. Do NOT reclassify. Do NOT accept "continue" as waiver.
- [ ] 3. **If sub-agent returns DONE (diagnosis is genuine):** Proceed to step 1 below.

**🚫 FORBIDDEN:**
- Accepting "infrastructure issue" as a diagnosis without dispatching the rationalization-check sub-agent
- Overriding, reclassifying, or "continuing" past a REMEDIATION_MANDATORY verdict
- Treating the rationalization-check as optional or skippable
- Preloading the sub-agent with orchestrator reasoning or expected outcomes

**Authority:** Read [020-go-prohibitions.md §1](guidelines/020-go-prohibitions.md), [065-verification-honesty.md §Cost Model](guidelines/065-verification-honesty.md), [065-verification-honesty.md §Anti-Evasion Rules](guidelines/065-verification-honesty.md), [000-critical-rules.md §hard-fail](guidelines/000-critical-rules.md)

### 1. Diagnose Root Cause

- [ ] 1. Read the evaluation YAML and test artifacts (stdout.log, stderr.log, session.yaml) to determine why each SC failed:
   - Prompt issue (missing authorization, wrong fixture, prose-recall)
   - Implementation issue (change not made, wrong approach)
   - Infrastructure issue (timeout, model unavailable, harness problem)

- [ ] 2. **Fix the root cause** — Apply the appropriate fix:
   - Prompt issue: Update the behavioral test prompt
   - Implementation issue: Return to the implementation pipeline
   - Infrastructure issue: Increase timeout, select alternative model, fix harness

- [ ] 3. **Re-run the test** — Execute the behavioral test again with the fix applied

- [ ] 4. **Re-evaluate** — Dispatch `behavioral-test-evaluation` from `verification-before-completion` to evaluate the new artifacts

- [ ] 5. **Confirm PASS** — Only when clean-room evaluation returns PASS for all behavioral SCs may the task report DONE

## Output

```yaml
status: DONE|BLOCKED
remediation_attempts:
  - attempt: 1
    diagnosis: "Root cause of failure"
    fix_applied: "What was changed"
    result: PASS|FAIL
blocker_reason: "Reason if BLOCKED after max attempts"
```

## Rules

- Maximum 2 remediation attempts before BLOCKED
- Each attempt MUST re-run the test and re-evaluate — no shortcutting
- "Looks fixed" without re-running is NOT valid — only re-run + re-evaluate counts
- If remediation requires implementation changes, dispatch to the implementation pipeline, do NOT inline-fix
