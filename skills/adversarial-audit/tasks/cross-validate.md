# Task: cross-validate

## Purpose

Accept an evidence payload and evaluation criteria, task() two pre-resolved cross-family auditor agents with clean-room context via `task(subagent_type="auditor-*")`, collect structured JSON verdicts `[{id, result, evidence, explanation}]` from both, and cross-reference them per criterion — producing PASS only when both auditors independently return PASS. Returns a cross-validation result table with per-criterion consensus tracking. Auditor models are resolved by the orchestrator BEFORE invoking this task.

## Entry Criteria

- `evidence_payload`: The claim or output to evaluate (free text, spec body, code snippet, or structured assertion)
- `evaluation_criteria`: Array of criterion objects, each with `{ id, description, expected_result, source_reference }`
- `auditor_1`: First auditor subagent type (e.g. `auditor-glm-5.1`) — pre-resolved by orchestrator
- `auditor_2`: Second auditor subagent type from a different model family — pre-resolved by orchestrator
- `github.owner`, `github.repo` present in task context

## Exit Criteria

- Cross-validation result array `[{ criterion_id, auditor_1_result, auditor_2_result, consensus, auditor_1_evidence, auditor_2_evidence }]` returned
- Each criterion has a definitive `PASS` or `FAIL` consensus verdict
- Consensus is `PASS` only when both auditors independently return PASS for that criterion
- Aggregate `overall_consensus`: `PASS` iff ALL criteria have consensus `PASS`
- No fabricated verdicts — missing or unparseable auditor output is treated as `FAIL`

## Procedure

### Step 1: Validate Input

Confirm `evidence_payload` and `evaluation_criteria` are present and non-empty. If either is missing, return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }`.

### Step 2: Validate Auditor Models

Confirm `auditor_1` and `auditor_2` are present, non-null, and belong to different model families. Use the orchestrator-provided values directly — they were resolved by `resolve-models` before this task was invoked.

If `auditor_1` or `auditor_2` is missing: return `{ status: "BLOCKED", error: "MISSING_AUDITOR", missing: "<field>" }`.

Verify `auditor_1 != auditor_2` and the implied families differ. If same family: HALT and report orchestrator error — cross-family task() violated.

### Step 3: Task() Auditor 1 (Clean-Room)

Run `task(subagent_type="<auditor_1>")` with context containing ONLY:

```
evidence_payload: "<evidence_payload>"
evaluation_criteria: "<evaluation_criteria as JSON>"
```

MUST NOT include: orchestrator reasoning, expected outcomes, prior verification results, the other auditor's task() status, or any hint of which model family is the second auditor.

### Step 4: Task() Auditor 2 (Clean-Room)

Run `task(subagent_type="<auditor_2>")` with context containing ONLY:

```
evidence_payload: "<evidence_payload>"
evaluation_criteria: "<evaluation_criteria as JSON>"
```

MUST NOT include: auditor 1's verdict, any cross-reference comparison, orchestrator reasoning, or expected outcomes.

Both task() calls MAY run in parallel (independent clean-room contexts). Wait for both to complete before proceeding.

### Step 5: Parse Auditor Verdicts

Each auditor returns a YAML block document (with `---` delimiters). Expected format:

```
---
criterion_id: "SC-1"
result: "PASS"
evidence: "<tool-call reference>"
explanation: "<reasoning>"
remediation: ""
next_step: "proceed"
---
---
criterion_id: "SC-2"
result: "FAIL"
evidence: "<tool-call reference>"
explanation: "<reasoning>"
remediation: "Add missing validation for X"
next_step: "re-evaluate"
---
```

Validation rules per verdict:
- `criterion_id` MUST match a criterion id from `evaluation_criteria`
- `result` MUST be one of: `PASS`, `FAIL`, `AUDIT_FAIL`, `INCONCLUSIVE`, `LIMITED-EVIDENCE`, `FABRICATED`
- `evidence` MUST reference a live tool call (URL, file path, or command output) — memory-cached claims are FORBIDDEN
- `explanation` MUST be present and non-empty
- `remediation` MUST be present when result is not PASS
- `next_step` MUST be one of: `proceed`, `re-evaluate`, `escalate`

If an auditor's output is unparseable YAML, missing the `---` delimiters, or contains no recognizable criterion ids: treat the entire auditor's contribution as `FAIL` for ALL criteria. Do NOT re-task — the protocol requires accepting real output, not retrying until PASS is obtained.

If an auditor's output has extra criterion ids not in `evaluation_criteria`: ignore extra verdicts, flag in result contract as `EXTRA_VERDICTS` warning.

If an auditor's output is missing a criterion id from `evaluation_criteria`: treat that criterion as `FAIL` for that auditor with explanation `"MISSING_VERDICT"`.

### Step 6: Cross-Reference Verdicts

For each criterion in `evaluation_criteria`:

| Rule | Result |
|---|---|
| Both auditors return `PASS` | `consensus = PASS` |
| Either auditor returns `FAIL` | `consensus = FAIL` |
| Non-PASS result (AUDIT_FAIL, INCONCLUSIVE, LIMITED-EVIDENCE, FABRICATED) | `consensus = BLOCKED` |
| Either auditor's verdict is missing or unparseable | `consensus = FAIL` |
| Auditors disagree (one PASS, one non-PASS) | `consensus = FAIL` |

Non-PASS (FAIL, AUDIT_FAIL, INCONCLUSIVE, LIMITED-EVIDENCE, FABRICATED) = BLOCKED pipeline. Orchestrator reads `next_step` from verdict and routes accordingly — does NOT interpret or override.

Track disagreements explicitly in the result contract for transparency: a `PASS`/`FAIL` split is different from a double `FAIL`.

Empty/error sub-agent → re-task with fresh random pair. Never proceed with single auditor.

### Step 7: Compute Aggregate Consensus

`overall_consensus = PASS` iff `consensus == PASS` for ALL criteria. Any single `FAIL` in the table cascades to `overall_consensus = FAIL`.

### Step 8: Build Result Contract

Return structured result:

```json
{
  "status": "DONE",
  "overall_consensus": "PASS|FAIL",
  "auditor_1": {
    "type": "auditor-glm-5.1",
    "family": "glm",
    "raw_verdict": "[...]",
    "parseable": true
  },
  "auditor_2": {
    "type": "auditor-mistral-large",
    "family": "mistral",
    "raw_verdict": "[...]",
    "parseable": true
  },
  "cross_validation": [
    {
      "criterion_id": "SC-1",
      "description": "<criterion description>",
      "auditor_1_result": "PASS",
      "auditor_2_result": "PASS",
      "consensus": "PASS",
      "auditor_1_evidence": "<tool-call reference>",
      "auditor_2_evidence": "<tool-call reference>",
      "agreement": true
    }
  ],
  "disagreements": [
    {
      "criterion_id": "SC-3",
      "auditor_1_result": "FAIL",
      "auditor_2_result": "PASS",
      "auditor_1_explanation": "<reasoning>",
      "auditor_2_explanation": "<reasoning>"
    }
  ],
  "warnings": ["EXTRA_VERDICTS: auditor_1 returned 1 verdict not in criteria"]
}
```

## Context Required

- `evidence_payload`: The claim, output, or assertion to be evaluated
- `evaluation_criteria`: Array of `{ id, description, expected_result, source_reference }`
- `auditor_1`: First auditor subagent type (e.g. `auditor-glm-5.1`) — pre-resolved by orchestrator
- `auditor_2`: Second auditor subagent type from a different model family — pre-resolved by orchestrator
- `audit_phase`: Current audit phase for task context
- `github.owner`, `github.repo`: For API calls

## Red Flags

- Never task() a single auditor — dual task() is mandatory per SKILL.md rule `adversarial-audit-001`
- Never leak orchestrator reasoning into auditor task context — clean-room means evidence + criteria ONLY
- Never leak auditor 1's verdict to auditor 2 — their evaluations must be fully independent
- Never soft-pass a mismatch — `PASS`/`FAIL` split = FAIL per SKILL.md rule `adversarial-audit-004`
- Never fabricate verdicts when auditor output is unparseable — missing data = FAIL per SKILL.md rule `adversarial-audit-005`
- Never accept memory-cached claims as evidence — every verdict must reference a live tool call
- Never re-task an auditor after a FAIL verdict — FAIL stays FAIL
- Never resolve auditors inline — `resolve-models` is called by orchestrator before this task

## Cross-References

- `adversarial-audit/SKILL.md` — skill-level operating protocol and enforcement rules
- `adversarial-audit/tasks/resolve-models.md` — cross-family auditor model selection
- `adversarial-audit/tasks/completion.md` — halt guarantee
- `.opencode/agents/auditor-*.md` — auditor agent files with model and permission definitions
- `065-verification-honesty.md` — live-source verification mandate, stale evidence prohibition
- `000-critical-rules.md` — clean-room task() protocol, orchestrator purity
- Spec #381, Plan #382

## Sub-Agent Routing

Authorization context is passed alongside audit context:

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|
| `evidence_payload`, `evaluation_criteria`, `auditor_1`, `auditor_2`, `audit_phase`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase`, `github.owner`, `github.repo` | Orchestrator reasoning, expected outcomes, prior verification results, other auditor's verdict or task() status | N/A — auditor types are pre-resolved by orchestrator | NO |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-04T00:00:00Z"
rules:
  - id: cross-validate-001
    title: "Input validation — evidence_payload and evaluation_criteria must be non-empty"
    conditions:
      all: ["evidence_payload_present == false OR evaluation_criteria_present == false"]
    actions: [RETURN_BLOCKED, REPORT_MISSING_INPUT]
    source: "cross-validate.md §Step 1"

  - id: cross-validate-002
    title: "Auditors must be provided by orchestrator — cross-validate does not call resolve-models"
    conditions:
      all: ["auditor_types == null", "auditor_dispatch_attempted == true"]
    actions: [HALT, REPORT_MISSING_AUDITOR]
    source: "cross-validate.md §Step 2"

  - id: cross-validate-003
    title: "Dual auditor task() mandatory — exactly two auditors must be invoked"
    conditions:
      all: ["auditor_dispatch_count != 2"]
    actions: [HALT]
    source: "cross-validate.md §Steps 3-4"

  - id: cross-validate-004
    title: "Cross-family verification — auditor families must differ"
    conditions:
      all: ["family_1 == family_2"]
    actions: [HALT, REPORT_ORCHESTRATOR_ERROR]
    source: "cross-validate.md §Step 2"

  - id: cross-validate-005
    title: "Clean-room task() — auditor context must not contain orchestrator reasoning or expected outcomes"
    conditions:
      any: ["auditor_task_context contains 'expected_result' OR 'orchestrator_reasoning' OR 'should_find' OR 'correct_answer'"]
    actions: [HALT, STRIP_BIASED_CONTEXT, RE_TASK]
    source: "cross-validate.md §Steps 3-4"

  - id: cross-validate-006
    title: "Auditor 1 verdict must not leak to auditor 2 task()"
    conditions:
      all: ["auditor_2_task_context contains auditor_1_verdict"]
    actions: [HALT, STRIP_LEAKED_CONTEXT, RE_TASK]
    source: "cross-validate.md §Step 4"

  - id: cross-validate-007
    title: "Unparseable auditor output = FAIL for all criteria"
    conditions:
      all: ["auditor_verdict_parseable == false"]
    actions: [ASSIGN_FAIL_ALL]
    source: "cross-validate.md §Step 5"

  - id: cross-validate-008
    title: "Missing criterion verdict = FAIL for that criterion"
    conditions:
      all: ["criterion_id not in auditor_verdict_ids"]
    actions: [ASSIGN_FAIL_PER_CRITERION, SET_EXPLANATION("MISSING_VERDICT")]
    source: "cross-validate.md §Step 5"

  - id: cross-validate-009
    title: "Consensus gate — PASS only when both auditors return PASS; non-PASS results block pipeline"
    conditions:
      all: ["auditor_1_result != 'PASS' OR auditor_2_result != 'PASS'", "consensus_reported_as == 'PASS'"]
    actions: [REJECT, DECLARE_FAIL]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-009a
    title: "Non-PASS verdicts (AUDIT_FAIL, INCONCLUSIVE, LIMITED-EVIDENCE, FABRICATED) cascade to BLOCKED"
    conditions:
      any: ["auditor_result == 'AUDIT_FAIL'", "auditor_result == 'INCONCLUSIVE'", "auditor_result == 'LIMITED-EVIDENCE'", "auditor_result == 'FABRICATED'"]
    actions: [SET_CONSENSUS_BLOCKED, ROUTE_VIA_NEXT_STEP]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-010
    title: "Aggregate consensus cascades — single criterion FAIL/BLOCKED = overall FAIL"
    conditions:
      any: ["any_criterion_consensus == 'FAIL'", "any_criterion_consensus == 'BLOCKED'"]
      all: ["overall_consensus_reported_as == 'PASS'"]
    actions: [REJECT, DECLARE_OVERALL_FAIL]
    source: "cross-validate.md §Step 7"

  - id: cross-validate-011
    title: "No re-task on FAIL verdict — accept real auditor output"
    conditions:
      all: ["auditor_result == 'FAIL'", "re_task_attempted == true"]
    actions: [HALT]
    source: "cross-validate.md §Step 5"

  - id: cross-validate-012
    title: "Evidence must reference live tool call — memory-cached claims rejected"
    conditions:
      all: ["auditor_evidence matches 'from memory' OR 'as I recall' OR 'training data' OR missing_tool_call_reference"]
    actions: [REJECT_EVIDENCE, ASSIGN_FAIL]
    source: "cross-validate.md §Step 5"

  - id: cross-validate-013
    title: "Result contract must include disagreements list when auditors diverge"
    conditions:
      all: ["disagreement_exists == true", "result_contract_disagreements == null"]
    actions: [APPEND_DISAGREEMENTS]
    source: "cross-validate.md §Step 8"

  - id: cross-validate-014
    title: "Missing auditors must return BLOCKED status, not silent halt"
    conditions:
      all: ["auditor_1 == null OR auditor_2 == null", "proceeded_without_auditors == true"]
    actions: [RETURN_BLOCKED]
    source: "cross-validate.md §Step 2"
```
