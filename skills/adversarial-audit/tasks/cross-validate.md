# Task: cross-validate

## Purpose

Accept an evidence payload and evaluation criteria, resolve two cross-family auditor agents via `resolve-models`, dispatch each auditor with clean-room context via `task(subagent_type="auditor-*")`, collect structured JSON verdicts `[{id, result, evidence, explanation}]` from both, and cross-reference them per criterion — producing PASS only when both auditors independently return PASS. Returns a cross-validation result table with per-criterion consensus tracking.

## Entry Criteria

- `evidence_payload`: The claim or output to evaluate (free text, spec body, code snippet, or structured assertion)
- `evaluation_criteria`: Array of criterion objects, each with `{ id, description, expected_result, source_reference }`
- `github.owner`, `github.repo` present in dispatch context
- `resolve-models` task exists and is readable

## Exit Criteria

- Cross-validation result array `[{ criterion_id, auditor_1_result, auditor_2_result, consensus, auditor_1_evidence, auditor_2_evidence }]` returned
- Each criterion has a definitive `PASS` or `FAIL` consensus verdict
- Consensus is `PASS` only when both auditors independently return PASS for that criterion
- Aggregate `overall_consensus`: `PASS` iff ALL criteria have consensus `PASS`
- No fabricated verdicts — missing or unparseable auditor output is treated as `FAIL`

## Procedure

### Step 1: Validate Input

Confirm `evidence_payload` and `evaluation_criteria` are present and non-empty. If either is missing, return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }`.

### Step 2: Resolve Auditor Models

Dispatch `resolve-models` via `task(subagent_type="general")` with context `{ orchestrator_model: "<ModelId>", github.owner, github.repo }`. Extract `{ auditor_1, auditor_2, family_1, family_2 }` from the result contract.

If `resolve-models` returns `INSUFFICIENT_FAMILIES` error: return `{ status: "BLOCKED", error: "INSUFFICIENT_FAMILIES", reason: "<explanation>" }`.

Verify `auditor_1 != auditor_2` and `family_1 != family_2`. If same family: HALT — this constitutes a `resolve-models` failure, re-dispatch it.

### Step 3: Dispatch Auditor 1 (Clean-Room)

Dispatch `task(subagent_type="<auditor_1>")` with context containing ONLY:

```
evidence_payload: "<evidence_payload>"
evaluation_criteria: "<evaluation_criteria as JSON>"
```

MUST NOT include: orchestrator reasoning, expected outcomes, prior verification results, the other auditor's dispatch status, or any hint of which model family is the second auditor.

### Step 4: Dispatch Auditor 2 (Clean-Room)

Dispatch `task(subagent_type="<auditor_2>")` with context containing ONLY:

```
evidence_payload: "<evidence_payload>"
evaluation_criteria: "<evaluation_criteria as JSON>"
```

MUST NOT include: auditor 1's verdict, any cross-reference comparison, orchestrator reasoning, or expected outcomes.

Both dispatches MAY run in parallel (independent clean-room contexts). Wait for both to complete before proceeding.

### Step 5: Parse Auditor Verdicts

Each auditor returns a JSON array of objects. Expected format:

```
[
  { "id": "SC-1", "result": "PASS", "evidence": "<tool-call reference>", "explanation": "<reasoning>" },
  { "id": "SC-2", "result": "FAIL", "evidence": "<tool-call reference>", "explanation": "<reasoning>" }
]
```

Validation rules per verdict:
- `id` MUST match a criterion id from `evaluation_criteria`
- `result` MUST be exactly `"PASS"` or `"FAIL"`
- `evidence` MUST reference a live tool call (URL, file path, or command output) — memory-cached claims are FORBIDDEN
- `explanation` MUST be present and non-empty

If an auditor's output is unparseable JSON, missing the array structure, or contains no recognizable criterion ids: treat the entire auditor's contribution as `FAIL` for ALL criteria. Do NOT re-dispatch — the protocol requires accepting real output, not retrying until PASS is obtained.

If an auditor's output has extra criterion ids not in `evaluation_criteria`: ignore extra verdicts, flag in result contract as `EXTRA_VERDICTS` warning.

If an auditor's output is missing a criterion id from `evaluation_criteria`: treat that criterion as `FAIL` for that auditor with explanation `"MISSING_VERDICT"`.

### Step 6: Cross-Reference Verdicts

For each criterion in `evaluation_criteria`:

| Rule | Result |
|---|---|
| Both auditors return `PASS` | `consensus = PASS` |
| Either auditor returns `FAIL` | `consensus = FAIL` |
| Either auditor's verdict is missing or unparseable | `consensus = FAIL` |
| Auditors disagree (one PASS, one FAIL) | `consensus = FAIL` |

Track disagreements explicitly in the result contract for transparency: a `PASS`/`FAIL` split is different from a double `FAIL`.

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
- `github.owner`, `github.repo`: For resolve-models file-path resolution

## Red Flags

- Never dispatch a single auditor — dual dispatch is mandatory per SKILL.md rule `adversarial-audit-001`
- Never leak orchestrator reasoning into auditor dispatch context — clean-room means evidence + criteria ONLY
- Never leak auditor 1's verdict to auditor 2 — their evaluations must be fully independent
- Never soft-pass a mismatch — `PASS`/`FAIL` split = FAIL per SKILL.md rule `adversarial-audit-004`
- Never fabricate verdicts when auditor output is unparseable — missing data = FAIL per SKILL.md rule `adversarial-audit-005`
- Never accept memory-cached claims as evidence — every verdict must reference a live tool call
- Never re-dispatch an auditor after a FAIL verdict — the protocol accepts the real output
- Never skip the `resolve-models` step — cross-family selection is mandatory

## Cross-References

- `adversarial-audit/SKILL.md` — skill-level operating protocol and enforcement rules
- `adversarial-audit/tasks/resolve-models.md` — cross-family auditor model selection
- `adversarial-audit/tasks/completion.md` — halt guarantee
- `.opencode/agents/auditor-*.md` — auditor agent files with model and permission definitions
- `065-verification-honesty.md` — live-source verification mandate, stale evidence prohibition
- `000-critical-rules.md` — clean-room dispatch protocol, orchestrator purity
- Spec #381, Plan #382

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
    title: "resolve-models must be invoked before auditor dispatch"
    conditions:
      all: ["auditor_types == null", "auditor_dispatch_attempted == true"]
    actions: [HALT, INVOKE_RESOLVE_MODELS]
    source: "cross-validate.md §Step 2"

  - id: cross-validate-003
    title: "Dual auditor dispatch mandatory — exactly two auditors must be dispatched"
    conditions:
      all: ["auditor_dispatch_count != 2"]
    actions: [HALT]
    source: "cross-validate.md §Steps 3-4"

  - id: cross-validate-004
    title: "Cross-family verification — auditor families must differ"
    conditions:
      all: ["family_1 == family_2"]
    actions: [HALT, REINVOKE_RESOLVE_MODELS]
    source: "cross-validate.md §Step 2"

  - id: cross-validate-005
    title: "Clean-room dispatch — auditor context must not contain orchestrator reasoning or expected outcomes"
    conditions:
      any: ["auditor_dispatch_context contains 'expected_result' OR 'orchestrator_reasoning' OR 'should_find' OR 'correct_answer'"]
    actions: [HALT, STRIP_BIASED_CONTEXT, REDISPATCH]
    source: "cross-validate.md §Steps 3-4"

  - id: cross-validate-006
    title: "Auditor 1 verdict must not leak to auditor 2 dispatch"
    conditions:
      all: ["auditor_2_dispatch_context contains auditor_1_verdict"]
    actions: [HALT, STRIP_LEAKED_CONTEXT, REDISPATCH]
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
    title: "Consensus gate — PASS only when both auditors return PASS"
    conditions:
      all: ["auditor_1_result != 'PASS' OR auditor_2_result != 'PASS'", "consensus_reported_as == 'PASS'"]
    actions: [REJECT, DECLARE_FAIL]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-010
    title: "Aggregate consensus cascades — single criterion FAIL = overall FAIL"
    conditions:
      all: ["any_criterion_consensus == 'FAIL'", "overall_consensus_reported_as == 'PASS'"]
    actions: [REJECT, DECLARE_OVERALL_FAIL]
    source: "cross-validate.md §Step 7"

  - id: cross-validate-011
    title: "No re-dispatch on FAIL verdict — accept real auditor output"
    conditions:
      all: ["auditor_result == 'FAIL'", "re_dispatch_attempted == true"]
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
    title: "INSUFFICIENT_FAMILIES must return BLOCKED status, not silent halt"
    conditions:
      all: ["resolve_models_error == 'INSUFFICIENT_FAMILIES'"]
    actions: [RETURN_BLOCKED]
    source: "cross-validate.md §Step 2"
```
