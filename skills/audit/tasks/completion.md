<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: completion

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

Idempotent completion subtask for audit. Ensures mandatory steps ran regardless of where the workflow halted.

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/completion/`

## State Check Phase

- [ ] 1. **Audit task dispatched:** Check whether the orchestrator dispatched `task(subagent_type="general")` for the audit task
- [ ] 2. **Verdict artifact written:** Check whether the auditor YAML verdict artifact exists on disk at the reported `artifact_path` location
- [ ] 3. **Verdict evaluated:** Check whether the verdict produced a definitive PASS or FAIL result with `next_step` field

## Orchestrator-Driven Dispatch Chain

The dispatch chain is orchestrated by the main agent (orchestrator), NOT by individual sub-tasks. The flow is:

- [ ] 1. **Orchestrator dispatches** `task(general)` for the audit task → receives frugal contract with `artifact_path`
- [ ] 2. **Orchestrator routes** based on `next_step` field: `"proceed"` for PASS, `"remediate then re-audit"` for FAIL

## Skill-Specific Completion

- [ ] 1. **Verdict artifact integrity check** (if not already performed):
   - The auditor YAML verdict artifact MUST exist at the reported `artifact_path` location on disk
   - The artifact MUST contain parseable YAML with `per_criterion` entries including `criterion_id`, `result`, `evidence`, `explanation`
   - If missing, unreadable, or malformed: report VERDICT-INTEGRITY failure, do NOT fabricate results

- [ ] 2. **Verdict enforcement** (if not already performed):
   - PASS iff all criteria pass
   - Any FAIL = overall FAIL
   - If verdict not evaluated: compute from collected verdict (read from YAML artifact on disk)

## Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| No audit task dispatched | MISSING-ELEMENT | flag-for-review | HALT — orchestrator must dispatch audit task |
| Malformed verdict | VERDICT-INTEGRITY | flag-for-review | HALT — cannot use bad data |
| Verdict not evaluated | CONSENSUS-GAP | auto-fix | Compute from collected verdict |

## Shared Completion Delegation

Reference `skills/completion-core/completion-core.md` for reporting:

- [ ] 1. Report executive summary in chat (always runs)
- [ ] 2. Action URL (issue URL) as the URL (ALWAYS last)

## Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, partial, error), produce a status message containing:
- [ ] 1. What was completed
- [ ] 2. What was attempted but not completed
- [ ] 3. Why the halt occurred

This is the completion guarantee: NO audit workflow ends without a status message.

### Write judgment.yaml

Write final judgment to `./tmp/{issue-N}/artifacts/completion/judgment.yaml`

## Remediation

If any step FAILs, restart from step 0 (pre-clean).

## Report Phase

Generate executive summary in chat:

```
**Summary:**

<1-2 sentences describing the audit result and stakeholder value>

**Outcome:** <What the verdict means for stakeholders>

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
- [ ] Verdict result (PASS/FAIL) clearly stated in outcome
- [ ] URL present IF relevant (after outcome, before byline)
- [ ] AI byline present as **LAST** element
- [ ] No stale todowrite items remain (all cleared or N/A)

## Live Verification: Completion Evidence (MANDATORY)

**Each completion state check MUST be verified via tool call, not just asserted. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`. Evidence is read from YAML artifacts on disk, not passed inline.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "Audit task dispatched" | Verify task() occurred | Check `task()` call logs in work state file | MISSING-ELEMENT |
| "YAML verdict artifact on disk" | Verify artifact file exists | Read `artifact_path` from auditor result contract | VERDICT-INTEGRITY |
| "Verdict evaluated" | Verify PASS/FAIL determination | Read YAML artifact on disk | CONSENSUS-GAP |

**Evidence artifact:** Tool call results for each completion state check, plus YAML artifact file reads.

## Sub-Agent Routing

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|
| `auditor_dispatch_status`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase` | Orchestrator reasoning, expected outcomes, verdict content | N/A — this is a completion task, not a task() routing task | NO |

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`
