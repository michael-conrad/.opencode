<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: cross-validate

## Purpose

Accept an evidence payload, evaluation criteria, and pre-resolved auditor verdicts — then cross-reference those verdicts per criterion — producing PASS only when both auditors independently returned PASS. This task does NOT dispatch auditors; the orchestrator task()s auditors before invoking cross-validate and passes the verdicts as entry criteria.

## Entry Criteria

- `evidence_payload`: The claim or output to evaluate (free text, spec body, code snippet, or structured assertion)
- `evaluation_criteria`: Array of criterion objects, each with `{ id, description, expected_result, source_reference, evidence_type }` — `evidence_type` MUST be included per `080-code-standards.md` §Evidence Type Taxonomy
- `auditor_verdicts`: Pre-resolved array of two verdict objects from the orchestrator, each containing `{ auditor_type, family, raw_verdict, parseable }` — resolved by `resolve-models` and dispatched by the orchestrator BEFORE this task
- `github.owner`, `github.repo` present in task context

## Exit Criteria

- Cross-validation result array `[{ criterion_id, auditor_1_result, auditor_2_result, consensus, auditor_1_evidence, auditor_2_evidence }]` returned
- Each criterion has a definitive `PASS` or `FAIL` consensus verdict
- Consensus is `PASS` only when both auditors independently return PASS for that criterion
- Aggregate `overall_consensus`: `PASS` iff ALL criteria have consensus `PASS`
- No fabricated verdicts — missing or unparseable auditor output is treated as `FAIL`
- Result contract includes `next_step` field per SC-7: `"remediate then re-audit"` for FAIL, next pipeline continuation for PASS

## Non-Recovery Gates

The following states are **terminal BLOCKED states** with no fallback or recovery paths. When encountered, cross-validate MUST return `status: BLOCKED` immediately — no re-task, no retry, no workaround.

| Gate | Condition | Error Code | Action |
|------|-----------|------------|--------|
| MISSING_INPUT | `evidence_payload` or `evaluation_criteria` missing or empty | `MISSING_INPUT` | Return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }` |
| MISSING_VERDICTS | `auditor_verdicts` missing, null, or empty array | `MISSING_VERDICTS` | Return `{ status: "BLOCKED", error: "MISSING_VERDICTS" }` |
| INSUFFICIENT_FAMILIES | `auditor_verdicts` contains fewer than 2 entries OR both auditors share the same family | `INSUFFICIENT_FAMILIES` | Return `{ status: "BLOCKED", error: "INSUFFICIENT_FAMILIES" }` |

These gates are **non-recovery** per adversarial-audit-017. Do NOT attempt to resolve models inline, re-dispatch auditors, or fabricate verdicts. The ONLY valid path is: resolve-models → auditor dispatch → cross-validate with results. NO fallback, NO single-auditor mode, NO alternative paths.

## Procedure

### Step 0: Context Contamination Detection

Before consensus, check each auditor's verdict for AUDIT_FAIL entries:
1. One AUDIT_FAIL + one normal → invalidate contaminated verdict, re-dispatch
2. Both AUDIT_FAIL same source → confirm, BLOCK pipeline
3. AUDIT_FAIL MUST include explanation with specific contamination signal

### Step 1: Validate Input

Confirm `evidence_payload` and `evaluation_criteria` are present and non-empty. If either is missing: return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }`.

### Step 2: Validate Pre-Resolved Verdicts

Confirm `auditor_verdicts` is present, non-null, and contains exactly two entries from different model families. Each entry MUST contain `{ auditor_type, family, raw_verdict, parseable }`.

- If `auditor_verdicts` is missing or null: return `{ status: "BLOCKED", error: "MISSING_VERDICTS" }`.
- If `auditor_verdicts` has fewer than 2 entries: return `{ status: "BLOCKED", error: "INSUFFICIENT_FAMILIES" }`.
- If both entries share the same `family`: return `{ status: "BLOCKED", error: "INSUFFICIENT_FAMILIES" }`.

### Step 3: Parse Auditor Verdicts

Each entry in `auditor_verdicts` contains a `raw_verdict` field with YAML block document format (with `---` delimiters). Expected format per verdict:

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
- `result` MUST be one of: `PASS`, `FAIL`, `AUDIT_FAIL`, `LIMITED-EVIDENCE`, `FABRICATED`
- `evidence` MUST reference a live tool call (URL, file path, or command output) — memory-cached claims are FORBIDDEN
- `explanation` MUST be present and non-empty
- `remediation` MUST be present when result is not PASS
- `next_step` MUST be one of: `proceed`, `re-evaluate`, `escalate`

If an auditor's `raw_verdict` is unparseable YAML, missing the `---` delimiters, or contains no recognizable criterion ids: treat the entire auditor's contribution as `FAIL` for ALL criteria. Do NOT re-task — the protocol requires accepting real output, not retrying until PASS is obtained.

If an auditor's `raw_verdict` has extra criterion ids not in `evaluation_criteria`: ignore extra verdicts, flag in result contract as `EXTRA_VERDICTS` warning.

If an auditor's `raw_verdict` is missing a criterion id from `evaluation_criteria`: treat that criterion as `FAIL` for that auditor with explanation `"MISSING_VERDICT"`.

### Step 4: Cross-Reference Verdicts

For each criterion in `evaluation_criteria`:

| Rule | Result |
|---|---|
| Both auditors return `PASS` | `consensus = PASS` |
| Either auditor returns `FAIL` | `consensus = FAIL` |
| Non-PASS result (AUDIT_FAIL, LIMITED-EVIDENCE, FABRICATED) | `consensus = BLOCKED` |
| Either auditor's verdict is missing or unparseable | `consensus = FAIL` |
| Auditors disagree (one PASS, one non-PASS) | `consensus = FAIL` |

Non-PASS (FAIL, AUDIT_FAIL, LIMITED-EVIDENCE, FABRICATED) = BLOCKED pipeline. Orchestrator reads `next_step` from verdict and routes accordingly — does NOT interpret or override.

Track disagreements explicitly in the result contract for transparency: a `PASS`/`FAIL` split is different from a double `FAIL`.

#### Evidence Type Gate (MANDATORY — Per SC)

Before computing consensus for each criterion, cross-validate MUST check the declared evidence type against the actual evidence type used by each auditor. This gate prevents auditors from verifying behavioral SCs with structural evidence and reporting PASS.

**For each criterion in `evaluation_criteria`:**

1. Read the criterion's declared `evidence_type` field (from the spec's success criteria table)
2. For each auditor's verdict on that criterion, check the evidence type used:
   - If `evidence_type` is not declared in the criterion, default to `string`
   - If the auditor used structural evidence (file existence, grep, read) for a criterion declared as `behavioral`, downgrade that auditor's verdict from PASS to FAIL with `EVIDENCE_TYPE_MISMATCH` classification
   - If the auditor used structural or string-only evidence for a criterion declared as `semantic`, downgrade that auditor's verdict from PASS to FAIL with `EVIDENCE_TYPE_MISMATCH` classification
3. If both auditors used wrong evidence types for a behavioral SC: consensus is FAIL with `EVIDENCE_TYPE_MISMATCH`
4. If one auditor used correct evidence type (PASS) and the other used wrong evidence type (PASS → downgraded to FAIL): consensus is DISAGREE — resolve by re-dispatching the wrong-evidence-type auditor with explicit evidence type classification
5. The evidence type gate applies BEFORE the consensus computation — it modifies auditor verdicts before they enter the consensus matrix

**EVIDENCE_TYPE_MISMATCH is not a soft-pass condition.** It is a hard FAIL that prevents structural evidence from passing as behavioral evidence — the exact defect exposed by spec #804.

#### DISAGREE Is Terminal — No Reclassification (MANDATORY)

When auditors disagree on a criterion (one PASS, one FAIL), the consensus is FAIL. The cross-validate sub-agent MUST NOT:

1. **Reclassify FAIL as PASS** — reasoning that one auditor's pattern was "more correct" or "over-broad" is soft-passing per `000-critical-rules.md` §critical-rules-020. FAIL is never reclassifiable as PASS.
2. **Resolve disagreements through reasoning** — the cross-validate sub-agent does not have authority to determine which auditor is correct. DISAGREE means the evidence is contested, and contested evidence is FAIL.
3. **Annotate PASS on a FAIL criterion** — any annotation, footnote, caveat, or "resolved as PASS" qualifier on a FAIL criterion is a soft-pass violation.

Disagreements MUST be surfaced to the developer for resolution. The `disagreements` list in the result contract MUST contain every SC where auditors diverged, with both auditors' evidence. The developer decides whether to remediate the underlying issue or accept the contested SC — the cross-validate sub-agent does not make this decision.

This rule is non-waivable. Per `000-critical-rules.md` §critical-rules-020, verification is binary: exact match or FAIL. "Functionally equivalent" is never a valid consensus outcome.

### Step 5: Compute Aggregate Consensus

`overall_consensus = PASS` iff `consensus == PASS` for ALL criteria. Any single `FAIL` in the table cascades to `overall_consensus = FAIL`.

### Step 5.5: Verdict Self-Consistency Gate

Before dark pattern enforcement, every verdict must pass a self-consistency check:

1. **PASS with finding language**: If `result: "PASS"` while `explanation`, `evidence`, or `remediation` field contains finding/critique language (e.g., "should be", "needs", "missing", "could improve"), the PASS is contradictory — downgrade to FAIL. PASS must be strictly confirmatory with no critique.
2. **clean_room.verified constraint**: When `violations_detected` is non-empty, `clean_room.verified` MUST be `false`. If violations exist but verified is true, flag as `SELF_CONSISTENCY_FAIL`.
3. **Evidence-verdict alignment**: If `result: "PASS"` but `evidence` references "minor concerns", "some issues", or other hedging language, downgrade to FAIL. A PASS verdict must have PASS-level evidence (confirmatory only).

| Self-Consistency Rule | Trigger | Action |
|---|---|---|
| PASS + critique language | `explanation` or `remediation` contains finding/fix language | Downgrade to FAIL |
| violations_detected + verified=true | Non-empty violations with verified=true | flag `SELF_CONSISTENCY_FAIL` |
| PASS + hedging evidence | Evidence contains concern/minor/issue qualifiers | Downgrade to FAIL |

### Step 6: Dark Pattern Enforcement (MANDATORY — NO BYPASS)

Step 6 IS the completion step of cross-validation — it IS the definition of a valid result contract. An evaluation that skips dark pattern enforcement is INVALID without Step 6 enforcement. WE have determined that dark pattern detection is repository policy — it MANDATES enforcement for every verdict.

This step CANNOT contain a skip condition — Step 6 MUST proceed for ALL verdicts, PASS or FAIL. Sycophancy exploitation IS the ONLY context authorized to evaluate verdict agreement; any verdict that bypasses this step PROCEED DIRECTLY to result contract invalidation. The result contract MUST proceed through dark pattern enforcement before completion.

Before finalizing the result contract, scan ALL auditor verdicts, explanations, and remediation suggestions for the following dark patterns. If ANY dark pattern is detected, flag it in the result contract and set the affected criterion consensus to `FAIL` with remediation referencing the dark pattern. This is PROHIBITED to skip — repository policy MANDATES enforcement.

| Dark Pattern | Detection Signal | Remediation |
|---|---|---|
| Authority framing | Verdict or explanation references "as an expert", "in my professional opinion", "trust me" or other authority-without-evidence appeals | Strip authority language; require tool-call evidence per adversarial-audit-006 |
| Goal hijacking | Verdict redefines the evaluation criterion, shifts scope beyond what the criterion specifies, or substitutes a different metric | Re-evaluate against original criterion only |
| Forced action | Verdict contains "you must", "you should", "it is critical that you" or other directive language prescribing implementation actions beyond the audit scope | Strip prescriptive language; verdict scope is evaluation ONLY |
| Sycophancy exploitation | Verdict agrees with the spec/plan author without independent evidence, or mirrors orchestrator-stated expectations | Require independent tool-call evidence per adversarial-audit-006 |
| Continuity hooks | Verdict includes "next time", "in future iterations", "consider also" or other scope-expanding suggestions beyond the current criterion | Strip scope-expanding language; evaluate only current criterion |

### Step 7: Build Result Contract

Return structured result:

```json
{
  "status": "DONE",
  "overall_consensus": "PASS|FAIL",
  "next_step": "proceed|remediate then re-audit",
  "auditor_verdicts": [
    {
      "auditor_type": "auditor-glm-5.1",
      "family": "glm",
      "parseable": true,
      "raw_verdict": "[...]"
    },
    {
      "auditor_type": "auditor-mistral-large",
      "family": "mistral",
      "parseable": true,
      "raw_verdict": "[...]"
    }
  ],
  "cross_validation": [
    {
      "criterion_id": "SC-1",
      "description": "<criterion description>",
      "evidence_type": "structural|string|semantic|behavioral",
      "auditor_1_result": "PASS",
      "auditor_2_result": "PASS",
      "consensus": "PASS",
      "auditor_1_evidence": "<tool-call reference>",
      "auditor_2_evidence": "<tool-call reference>",
      "agreement": true,
      "dark_pattern_flags": [],
      "evidence_type_mismatch": false
    }
  ],
  "disagreements": [],
  "dark_pattern_violations": [],
  "warnings": []
}
```

The `next_step` field:
- `overall_consensus == PASS` → `next_step: "proceed"` (next pipeline continuation)
- `overall_consensus == FAIL` → `next_step: "remediate then re-audit"` (orchestrator routes to recovery)

## Context Required

- `evidence_payload`: The claim, output, or assertion to be evaluated
- `evaluation_criteria`: Array of `{ id, description, expected_result, source_reference }`
- `auditor_verdicts`: Pre-resolved array of two verdict objects from orchestrator (each with `{ auditor_type, family, raw_verdict, parseable }`)
- `audit_phase`: Current audit phase for task context
- `github.owner`, `github.repo`: For API calls

## Red Flags

- Never task() auditors from within cross-validate — the orchestrator dispatches auditors, cross-validate receives verdicts only
- Never leak orchestrator reasoning into verdict parsing — clean-room means evidence + criteria ONLY
- Never soft-pass a mismatch — `PASS`/`FAIL` split = FAIL per adversarial-audit-004
- Never fabricate verdicts when auditor output is unparseable — missing data = FAIL per adversarial-audit-005
- Never accept memory-cached claims as evidence — every verdict must reference a live tool call
- Never re-task an auditor after a FAIL verdict — FAIL stays FAIL
- Never resolve auditors inline — `resolve-models` is called by orchestrator before this task
- Never bypass dark pattern enforcement — Step 6 checks are MANDATORY per adversarial-audit-013 through adversarial-audit-018
- Never attempt recovery from BLOCKED status — Non-Recovery Gates are terminal per adversarial-audit-017

## Cross-References

- `adversarial-audit/SKILL.md` — skill-level operating protocol and enforcement rules
- `adversarial-audit/tasks/resolve-models.md` — cross-family auditor model selection (orchestrator calls this, not cross-validate)
- `adversarial-audit/tasks/completion.md` — halt guarantee
- `.opencode/agents/auditor-*.md` — auditor agent files with model and permission definitions
- `065-verification-honesty.md` — live-source verification mandate, stale evidence prohibition
- `000-critical-rules.md` — clean-room task() protocol, orchestrator purity
- Spec #578, Plan #382

## Sub-Agent Routing

Authorization context is passed alongside audit context:

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

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|
| `evidence_payload`, `evaluation_criteria`, `auditor_verdicts`, `audit_phase`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase`, `github.owner`, `github.repo` | Implementation context, agent memory, orchestrator reasoning, prior verification | N/A — cross-validate receives verdicts, does not dispatch auditors | NO |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-15T00:00:00Z"
rules:
  - id: cross-validate-001
    title: "Input validation — evidence_payload and evaluation_criteria must be non-empty"
    conditions:
      all: ["evidence_payload_present == false OR evaluation_criteria_present == false"]
    actions: [RETURN_BLOCKED, REPORT_MISSING_INPUT]
    source: "cross-validate.md §Step 1"

  - id: cross-validate-002
    title: "Pre-resolved verdicts must be provided by orchestrator — cross-validate does not dispatch auditors"
    conditions:
      all: ["auditor_verdicts == null OR auditor_verdicts_count < 2"]
    actions: [RETURN_BLOCKED, REPORT_MISSING_VERDICTS]
    source: "cross-validate.md §Step 2"

  - id: cross-validate-003
    title: "Cross-family verification — auditor families in verdicts must differ"
    conditions:
      all: ["family_1 == family_2"]
    actions: [RETURN_BLOCKED, REPORT_INSUFFICIENT_FAMILIES]
    source: "cross-validate.md §Step 2"

  - id: cross-validate-004
    title: "Clean-room verdict parsing — orchestrator reasoning must not influence cross-validation"
    conditions:
      any: ["cross_validate_context contains 'expected_result' OR 'orchestrator_reasoning' OR 'should_find'"]
    actions: [HALT, STRIP_BIASED_CONTEXT]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-005
    title: "Unparseable auditor output = FAIL for all criteria"
    conditions:
      all: ["auditor_verdict_parseable == false"]
    actions: [ASSIGN_FAIL_ALL]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-006
    title: "Missing criterion verdict = FAIL for that criterion"
    conditions:
      all: ["criterion_id not in auditor_verdict_ids"]
    actions: [ASSIGN_FAIL_PER_CRITERION, SET_EXPLANATION("MISSING_VERDICT")]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-007
    title: "Consensus gate — PASS only when both auditors return PASS; non-PASS results block pipeline"
    conditions:
      all: ["auditor_1_result != 'PASS' OR auditor_2_result != 'PASS'", "consensus_reported_as == 'PASS'"]
    actions: [REJECT, DECLARE_FAIL]
    source: "cross-validate.md §Step 4"

  - id: cross-validate-007a-disagree
    title: "DISAGREE is terminal — cross-validate MUST NOT reclassify FAIL as PASS or resolve disagreements through reasoning"
    conditions:
      any: ["auditor_1_result != auditor_2_result", "cross_validate_reclassifies_FAIL_to_PASS == true", "cross_validate_annotates_PASS_on_FAIL == true"]
    actions: [HALT, SURFACE_DISAGREEMENT_TO_DEVELOPER]
    source: "cross-validate.md §Step 4 DISAGREE Is Terminal"

  - id: cross-validate-007b
    title: "Evidence type gate — structural evidence for behavioral SC MUST be downgraded to FAIL"
    conditions:
      all:
        - "sc_evidence_type == 'behavioral'"
        - "auditor_evidence_type in ['structural', 'string']"
        - "auditor_verdict == 'PASS'"
    actions: [DOWNGRADE_TO_FAIL, CLASSIFY_EVIDENCE_TYPE_MISMATCH]
    source: "cross-validate.md §Step 4 Evidence Type Gate"

  - id: cross-validate-007a
    title: "Non-PASS verdicts (AUDIT_FAIL, LIMITED-EVIDENCE, FABRICATED) cascade to BLOCKED"
    conditions:
      any: ["auditor_result == 'AUDIT_FAIL'", "auditor_result == 'LIMITED-EVIDENCE'", "auditor_result == 'FABRICATED'"]
    actions: [SET_CONSENSUS_BLOCKED, ROUTE_VIA_NEXT_STEP]
    source: "cross-validate.md §Step 4"

  - id: cross-validate-008
    title: "Aggregate consensus cascades — single criterion FAIL/BLOCKED = overall FAIL"
    conditions:
      any: ["any_criterion_consensus == 'FAIL'", "any_criterion_consensus == 'BLOCKED'"]
      all: ["overall_consensus_reported_as == 'PASS'"]
    actions: [REJECT, DECLARE_OVERALL_FAIL]
    source: "cross-validate.md §Step 5"

  - id: cross-validate-009
    title: "No re-task on FAIL verdict — accept real auditor output"
    conditions:
      all: ["auditor_result == 'FAIL'", "re_task_attempted == true"]
    actions: [HALT]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-010
    title: "Evidence must reference live tool call — memory-cached claims rejected"
    conditions:
      all: ["auditor_evidence matches 'from memory' OR 'as I recall' OR 'training data' OR missing_tool_call_reference"]
    actions: [REJECT_EVIDENCE, ASSIGN_FAIL]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-011
    title: "Result contract must include disagreements list when auditors diverge"
    conditions:
      all: ["disagreement_exists == true", "result_contract_disagreements == null"]
    actions: [APPEND_DISAGREEMENTS]
    source: "cross-validate.md §Step 7"

  - id: cross-validate-012
    title: "Result contract must include next_step field per SC-7"
    conditions:
      all: ["result_contract_next_step == null"]
    actions: [APPEND_NEXT_STEP]
    source: "cross-validate.md §Step 7"

  - id: cross-validate-013
    title: "Dark pattern enforcement — authority framing detected in verdict MUST be flagged"
    conditions:
      any: ["verdict_contains == 'as an expert'", "verdict_contains == 'in my professional opinion'", "verdict_contains == 'trust me'"]
    actions: [FLAG_DARK_PATTERN, SET_CONSENSUS_FAIL]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-014
    title: "Dark pattern enforcement — goal hijacking in verdict MUST be flagged"
    conditions:
      all: ["verdict_redefines_criterion == true"]
    actions: [FLAG_DARK_PATTERN, SET_CONSENSUS_FAIL]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-015
    title: "Dark pattern enforcement — forced action language in verdict MUST be flagged"
    conditions:
      any: ["verdict_contains == 'you must'", "verdict_contains == 'you should'", "verdict_contains == 'it is critical that you'"]
    actions: [FLAG_DARK_PATTERN, SET_CONSENSUS_FAIL]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-016
    title: "Dark pattern enforcement — sycophancy exploitation in verdict MUST be flagged"
    conditions:
      all: ["verdict_agrees_without_evidence == true"]
    actions: [FLAG_DARK_PATTERN, SET_CONSENSUS_FAIL]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-017
    title: "Dark pattern enforcement — continuity hooks in verdict MUST be flagged"
    conditions:
      any: ["verdict_contains == 'next time'", "verdict_contains == 'in future iterations'", "verdict_contains == 'consider also'"]
    actions: [FLAG_DARK_PATTERN, SET_CONSENSUS_FAIL]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-018
    title: "Non-recovery gate — MISSING_INPUT, MISSING_VERDICTS, INSUFFICIENT_FAMILIES are terminal with no fallback"
    conditions:
      any: ["error == 'MISSING_INPUT'", "error == 'MISSING_VERDICTS'", "error == 'INSUFFICIENT_FAMILIES'"]
    actions: [RETURN_BLOCKED, NO_RECOVERY]
    source: "cross-validate.md §Non-Recovery Gates"
```