# Task: audit

## Purpose

Delegate to `adversarial-audit --task spec-audit` with triage hints about which subtasks are relevant based on the triage classification.

## Pre-Conditions

- **Load guideline:** `.opencode/guidelines/067-context-completeness.md` before proceeding — ALL comments MUST be read before audit

## Entry Criteria

- Triage selected the `audit` path
- Triage output available (path, confidence, reasoning, hints)

## Exit Criteria

- `adversarial-audit --task spec-audit` invoked with context
- Audit findings collected
- Prose exec summary produced for chat

## Procedure

### Step 1: Receive Triage Output

The triage task provides:
- Path: `audit`
- Confidence level
- Reasoning
- Hints about spec complexity

### Step 2: Format Triage Hints for adversarial-audit

Map triage observations to hints for `adversarial-audit --task spec-audit`:

| Spec Type from Triage | Hint for adversarial-audit |
|----------------------|---------------------------|
| Simple bug-fix spec | "likely baseline only" |
| Feature with phases | "baseline + concerns likely relevant" |
| Complex multi-phase spec | "all subtasks likely relevant" |
| Spec with external dependencies | "baseline + traceability + operational" |
| Single-task spec (no phases) | "likely baseline only" |

Hints INFORM but do NOT override — `adversarial-audit --task spec-audit` retains its own subtask selection logic.

### Step 3: Invoke adversarial-audit

```
/skill adversarial-audit --task spec-audit --issue N
```

Pass triage context as part of the invocation. The agent includes the hint about which subtasks are likely relevant based on the spec's nature.

### Step 4: Collect Audit Findings

Gather all findings from the adversarial-audit spec-audit task. These are internal agent guidance.

### Step 5: CRITICAL — Do NOT Post Findings to GitHub

**Audit findings are internal agent guidance — DO NOT post to GitHub comments (per `000-critical-rules.md`).**

Findings inform the agent's behavior but are NOT stakeholder communication. Posting audit findings as issue comments is a FORBIDDEN action.

### Step 6: Produce Prose Exec Summary for Chat

Write a prose exec summary of the audit results for chat output. Include:

- [ ] 1. What was audited (issue number, spec type)
- [ ] 2. Key findings (grouped by severity if multiple)
- [ ] 3. Recommended actions (without prescribing implementation)

Format per `000-critical-rules.md`:

```
<analysis summary>

<exec summary>

🤖 <AgentName> (<ModelId>) analysis
```

## Cross-References

- `adversarial-audit --task spec-audit`: Called for actual spec quality checks
- `000-critical-rules.md`: Audit findings must NOT be posted to GitHub
- `067-context-completeness.md`: All comments were read during gather
- `analyze-and-spec`: For bug-spec audits, verify that fix spec sub-issues exist (per `000-critical-rules.md` — bug reports must have fix spec before closure)

## Live Verification: Audit Delegation Claims (MANDATORY)

**Before trusting that adversarial-audit was invoked or that audit findings are current, verify against actual state. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "adversarial-audit invoked" | Verify audit was actually performed (not just planned) | Check that adversarial-audit output/findings exist in context | VERIFICATION-GAP |
| "Findings are current" | Verify no new comments or revisions since audit | `issue-operations -> read-comments (github_issue_read(method=get_comments)` → check timestamps after last audit | VERIFICATION-GAP | <!-- Routes through issue-operations per SPEC #683 -->
| "Triage classification is accurate" | Verify issue content matches triage label | `issue-operations -> read-issue (github_issue_read(method=get)` → re-read body, compare with triage call | CONFLICTING | <!-- Routes through issue-operations per SPEC #683 -->
| "Bug report has fix spec" | Verify via GitHub API, not cached sub-issue list | `issue-operations -> read-sub-issues (github_issue_read(method=get_sub_issues)` → check children | MISSING-ELEMENT | <!-- Routes through issue-operations per SPEC #683 -->

**Evidence artifact:** Tool call results confirming audit invocation, recency, and classification accuracy.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Audit never performed | VERIFICATION-GAP | conditional | Invoke adversarial-audit now |
| New comments since audit | VERIFICATION-GAP | conditional | Re-audit with new context |
| Triage classification wrong | CONFLICTING | flag-for-review | Report mismatch, re-evaluate path |
| Fix spec missing for bug | MISSING-ELEMENT | conditional | Proceed to `analyze-and-spec` |