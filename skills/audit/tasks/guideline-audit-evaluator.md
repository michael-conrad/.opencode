---
name: guideline-audit-evaluator
description: "Evaluator role for the guideline-audit DiMo chain. Reads evidence.yaml and reasoning.yaml from upstream roles, evaluates each criterion, and writes verdict.yaml with per-criterion PASS/FAIL verdicts. Produces judgments, not just evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: guideline-audit-evaluator

## Purpose

Evaluator role for the guideline-audit DiMo chain. Reads `evidence.yaml` (Generator) and `reasoning.yaml` (upstream reasoning role), evaluates each criterion against the guideline files, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts. This role produces judgments — it does NOT collect evidence or validate evidence. Those are upstream responsibilities.

> **DiMo Role: Evaluator.** This task evaluates guideline quality. Reads `evidence.yaml` + `reasoning.yaml` from upstream roles, evaluates each criterion, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts.
>
> You are the Evaluator. You are decisive and binary. Every criterion gets a PASS or a FAIL — nothing in between. You do not hedge, you do not defer, you do not ask for a second opinion. The evidence is in front of you. The upstream reasoning role has already validated it. Make the call.
>
>
> - MUST produce a binary PASS or FAIL for every criterion — no hedging, no "PASS with concerns", no INCONCLUSIVE
> - MUST NOT defer to upstream roles — the verdict is yours alone
> - MUST NOT re-validate evidence that upstream reasoning role already validated — trust the `reasoning.yaml` validation status
> - MUST NOT collect new evidence — that is the Generator's job
> - MUST write `verdict.yaml` as the primary output artifact
> - MUST apply the self-consistency gate: if a PASS verdict's explanation contains critique/hedging language, downgrade to FAIL

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from upstream roles are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against validated evidence.

## Dispatch Contract

- `guideline_paths`: List of guideline file paths that were audited (same as passed to Generator and upstream reasoning role)
- `artifact_evidence_dir`: Directory containing `evidence.yaml` and `reasoning.yaml` from upstream roles
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Generator completed successfully and wrote `evidence.yaml` before dispatching the Evaluator. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the upstream reasoning role completed successfully and wrote `reasoning.yaml` before dispatching the Evaluator. Dispatching without a valid `reasoning.yaml` is a CRITICAL VIOLATION.
- `guideline_paths` provided — either a non-empty list of file paths or a valid glob pattern matching the files the Generator audited
- `artifact_evidence_dir` provided (writable directory for verdict artifacts)
- `github.owner`, `github.repo` available

## Exit Criteria

- `verdict.yaml` written to `{artifact_evidence_dir}/verdict.yaml`
- Every criterion evaluated with binary PASS/FAIL — no INCONCLUSIVE, no "PASS with concerns"
- GA-1 through GA-6 criteria evaluated using validated evidence from `reasoning.yaml`
- Self-consistency gate applied to all PASS verdicts
- Bidirectional findings generated for FAIL criteria
- No new evidence collected — all evaluation based on upstream artifacts

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `verdict.yaml` from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "evidence.yaml is required for guideline-audit-evaluator. The orchestrator must ensure the Generator completed successfully and wrote evidence.yaml before dispatching the Evaluator."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for guideline-audit-evaluator. The orchestrator must ensure the upstream reasoning role completed successfully and wrote reasoning.yaml before dispatching the Evaluator."
```

- [ ] 5. Verify `guideline_paths` is provided and non-empty — expand glob if needed via `glob` tool
- [ ] 6. If `guideline_paths` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "guideline_paths"
remediation: "guideline_paths is required for guideline-audit-evaluator. The orchestrator must provide the same guideline file paths that were passed to the Generator and upstream reasoning role."
```

- [ ] 7. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Upstream Artifacts

Read the Generator's evidence and the upstream reasoning role's validated reasoning:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Read `{artifact_evidence_dir}/reasoning.yaml` via `read` tool
- [ ] 3. Parse all top-level sections from both artifacts
- [ ] 4. Record metadata: `generator`, `knowledge_supporter`, `generated_at`, `guideline_paths`
- [ ] 5. If any expected top-level section is absent from either artifact, record as `section_missing` — do NOT BLOCK, but flag in the verdict
- [ ] 6. Note the upstream reasoning role's `overall_validation_status` — this informs evaluation confidence

### Step 3: Evaluate GA-1 — Rule Conditions Are Unambiguous

Evaluate whether rule conditions are unambiguous and parseable using validated evidence:

- [ ] 1. Read `ambiguity_validation` from `reasoning.yaml`
- [ ] 2. Read `rule_condition_validation` from `reasoning.yaml`
- [ ] 3. **Hedging language check** — For each hedging language instance in `ambiguity_validation.hedging_language`, evaluate whether the hedging language appears in a rule condition or action. If hedging language exists in a rule condition or action, flag as FAIL with `hedging_in_rule_condition`.
- [ ] 4. **Vague terms check** — For each vague term instance in `ambiguity_validation.vague_terms`, evaluate whether the vague term appears in a rule condition or action. If vague terms exist in a rule condition or action, flag as FAIL with `vague_term_in_rule_condition`.
- [ ] 5. **Open-ended conditions check** — For each open-ended condition in `ambiguity_validation.open_ended_conditions`, evaluate whether the condition lacks concrete thresholds. If open-ended conditions exist, flag as FAIL with `open_ended_condition`.
- [ ] 6. **Either/or ambiguity check** — For each either/or instance in `ambiguity_validation.either_or_ambiguity`, evaluate whether the ambiguity appears in a required action. If either/or ambiguity exists in a required action, flag as FAIL with `either_or_in_required_action`.
- [ ] 7. **Concrete action check** — For each rule entry in `rule_condition_validation`, evaluate `has_concrete_action_match`. If any rule lacks a concrete action, flag as FAIL with `no_concrete_action`.
- [ ] 8. **Concrete values check** — For each rule entry in `rule_condition_validation`, evaluate `concrete_values_present_match`. If any rule lacks concrete values, flag as FAIL with `no_concrete_values`.
- [ ] 9. If the upstream reasoning role flagged evidence as `corrected`, use the corrected values
- [ ] 10. If the upstream reasoning role flagged evidence as `unvalidated`, note the uncertainty in the explanation but still render a verdict

Record results:

```yaml
ga_1_evaluation:
  criterion_id: "GA-1"
  description: "Rule conditions are unambiguous"
  result: "PASS|FAIL"
  evidence_source: "reasoning.yaml → ambiguity_validation + rule_condition_validation"
  sub_checks:
    hedging_in_rule_condition:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    vague_term_in_rule_condition:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    open_ended_condition:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    either_or_in_required_action:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    no_concrete_action:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    no_concrete_values:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
  explanation: "<reasoning for overall verdict>"
  remediation: "<if FAIL, what to fix>"
```

### Step 4: Evaluate GA-2 — No Conflicting Rules

Evaluate whether any rules contradict each other using validated evidence:

- [ ] 1. Read `conflict_indicator_validation` from `reasoning.yaml`
- [ ] 2. **Within-file conflicts** — For each within-file conflict in `conflict_indicator_validation.within_file`, evaluate whether the conflict is genuine (not a false conflict flagged by the upstream reasoning role). If genuine within-file conflicts exist, flag as FAIL with `within_file_conflict`.
- [ ] 3. **Cross-file conflicts** — For each cross-file conflict in `conflict_indicator_validation.cross_file`, evaluate whether the conflict is genuine. If genuine cross-file conflicts exist, flag as FAIL with `cross_file_conflict`.
- [ ] 4. **Tier vs. override conflicts** — For each tier/override conflict in `conflict_indicator_validation.tier_override_conflicts`, evaluate whether the declared tier and override behavior are inconsistent. If tier/override conflicts exist, flag as FAIL with `tier_override_conflict`.
- [ ] 5. **Scope boundary conflicts** — For each scope boundary conflict in `conflict_indicator_validation.scope_boundary_conflicts`, evaluate whether scope boundaries genuinely overlap or contradict. If scope boundary conflicts exist, flag as FAIL with `scope_boundary_conflict`.
- [ ] 6. **Missed conflicts** — If the upstream reasoning role identified missed conflicts (`missed_conflicts` in any sub-section), evaluate whether those missed conflicts are genuine. If genuine missed conflicts exist, flag as FAIL with `missed_conflict`.
- [ ] 7. If the upstream reasoning role flagged evidence as `corrected`, use the corrected values
- [ ] 8. If the upstream reasoning role flagged evidence as `unvalidated`, note the uncertainty in the explanation but still render a verdict

Record results:

```yaml
ga_2_evaluation:
  criterion_id: "GA-2"
  description: "No conflicting rules"
  result: "PASS|FAIL"
  evidence_source: "reasoning.yaml → conflict_indicator_validation"
  sub_checks:
    within_file_conflict:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    cross_file_conflict:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    tier_override_conflict:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    scope_boundary_conflict:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    missed_conflict:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
  explanation: "<reasoning for overall verdict>"
  remediation: "<if FAIL, what to fix>"
```

### Step 5: Evaluate GA-3 — Actions Are LLM-Enforceable

Evaluate whether rule actions are executable by an LLM agent using validated evidence:

- [ ] 1. Read `rule_condition_validation` from `reasoning.yaml`
- [ ] 2. Read `enforcement_pattern_validation` from `reasoning.yaml`
- [ ] 3. **Concrete action presence** — For each rule entry in `rule_condition_validation`, evaluate `has_concrete_action_match`. If any rule lacks a concrete, executable action, flag as FAIL with `unenforceable_action`.
- [ ] 4. **Implicit behavior check** — For each implicit behavior instance in `ambiguity_validation.implicit_behavior`, evaluate whether the desired outcome lacks a specified mechanism. If implicit behaviors exist, flag as FAIL with `implicit_behavior_no_mechanism`.
- [ ] 5. **Enforcement mechanism presence** — For each rule, verify that an enforcement mechanism is referenced (hooks, plugins, session-enforcement.ts, pre-commit, watchdog). If a rule has no enforcement mechanism, flag as FAIL with `no_enforcement_mechanism`.
- [ ] 6. **Halt condition clarity** — For each halt condition in `enforcement_pattern_validation.halt_conditions`, evaluate whether the trigger text is specific enough for an LLM to execute. If halt conditions are vague, flag as FAIL with `vague_halt_condition`.
- [ ] 7. **TBD/TODO markers** — For each TBD/TODO marker in `ambiguity_validation.tbd_todo_markers`, evaluate whether the marker appears in a rule action. If TBD/TODO markers exist in rule actions, flag as FAIL with `tbd_in_rule_action`.
- [ ] 8. If the upstream reasoning role flagged evidence as `corrected`, use the corrected values
- [ ] 9. If the upstream reasoning role flagged evidence as `unvalidated`, note the uncertainty in the explanation but still render a verdict

Record results:

```yaml
ga_3_evaluation:
  criterion_id: "GA-3"
  description: "Actions are LLM-enforceable"
  result: "PASS|FAIL"
  evidence_source: "reasoning.yaml → rule_condition_validation + enforcement_pattern_validation + ambiguity_validation"
  sub_checks:
    unenforceable_action:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    implicit_behavior_no_mechanism:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    no_enforcement_mechanism:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    vague_halt_condition:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    tbd_in_rule_action:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
  explanation: "<reasoning for overall verdict>"
  remediation: "<if FAIL, what to fix>"
```

### Step 6: Evaluate GA-4 — No Redundant Cross-File References

Evaluate whether cross-references are non-redundant using validated evidence:

- [ ] 1. Read `cross_reference_validation` from `reasoning.yaml`
- [ ] 2. **Duplicate source check** — For each entry in `cross_reference_validation.duplicate_sources`, evaluate whether the duplicate is genuine (not a false duplicate flagged by the upstream reasoning role). If genuine duplicates exist, flag as FAIL with `duplicate_source_reference`.
- [ ] 3. **Missed duplicates** — If the upstream reasoning role identified missed duplicates (`missed_duplicates`), evaluate whether those missed duplicates are genuine. If genuine missed duplicates exist, flag as FAIL with `missed_duplicate_reference`.
- [ ] 4. **Broken references** — For each broken reference in any sub-section (`broken_refs`), evaluate whether the broken reference impacts rule enforceability. If broken references exist, flag as FAIL with `broken_cross_reference`.
- [ ] 5. **Reference consolidation opportunity** — If the same source is referenced from multiple locations with different reference text, flag as FAIL with `reference_consolidation_needed`.
- [ ] 6. If the upstream reasoning role flagged evidence as `corrected`, use the corrected values
- [ ] 7. If the upstream reasoning role flagged evidence as `unvalidated`, note the uncertainty in the explanation but still render a verdict

Record results:

```yaml
ga_4_evaluation:
  criterion_id: "GA-4"
  description: "No redundant cross-file references"
  result: "PASS|FAIL"
  evidence_source: "reasoning.yaml → cross_reference_validation"
  sub_checks:
    duplicate_source_reference:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    missed_duplicate_reference:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    broken_cross_reference:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    reference_consolidation_needed:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
  explanation: "<reasoning for overall verdict>"
  remediation: "<if FAIL, what to fix>"
```

### Step 7: Evaluate GA-5 — Context Fits in LLM Window

Evaluate whether guideline content fits within LLM context limits using validated evidence:

- [ ] 1. Read `token_count_validation` from `reasoning.yaml`
- [ ] 2. **Per-file token limit** — For each file entry in `token_count_validation.per_file`, evaluate whether `estimated_tokens` exceeds a reasonable per-file limit (default: 8000 tokens). If any file exceeds the limit, flag as FAIL with `file_exceeds_token_limit`.
- [ ] 3. **Per-section token limit** — For each section entry in `token_count_validation.per_section`, evaluate whether `estimated_tokens` exceeds a reasonable per-section limit (default: 4000 tokens). If any section exceeds the limit, flag as FAIL with `section_exceeds_token_limit`.
- [ ] 4. **Per-rule token limit** — For each rule entry in `token_count_validation.per_rule`, evaluate whether `estimated_tokens` exceeds a reasonable per-rule limit (default: 2000 tokens). If any rule exceeds the limit, flag as FAIL with `rule_exceeds_token_limit`.
- [ ] 5. **Total corpus size** — Evaluate whether `token_count_validation.total_corpus.total_estimated_tokens` is within a reasonable range for the guideline corpus. If the total corpus is excessively large, flag as FAIL with `corpus_exceeds_token_limit`.
- [ ] 6. **Largest sections** — For the `largest_sections` list, evaluate whether the top sections are disproportionately large compared to the rest. If the largest sections dominate the corpus, flag as FAIL with `disproportionate_section_size`.
- [ ] 7. If the upstream reasoning role flagged evidence as `corrected`, use the corrected values
- [ ] 8. If the upstream reasoning role flagged evidence as `unvalidated`, note the uncertainty in the explanation but still render a verdict

Record results:

```yaml
ga_5_evaluation:
  criterion_id: "GA-5"
  description: "Context fits in LLM window"
  result: "PASS|FAIL"
  evidence_source: "reasoning.yaml → token_count_validation"
  sub_checks:
    file_exceeds_token_limit:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    section_exceeds_token_limit:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    rule_exceeds_token_limit:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    corpus_exceeds_token_limit:
      result: "PASS|FAIL"
      findings: ["<description>", ...]
    disproportionate_section_size:
      result: "PASS|FAIL"
      findings: ["<description>", ...]
  explanation: "<reasoning for overall verdict>"
  remediation: "<if FAIL, what to fix>"
```

### Step 8: Evaluate GA-6 — File Organization Logical

Evaluate whether guideline files are logically organized using validated evidence:

- [ ] 1. Read `file_organization_validation` from `reasoning.yaml`
- [ ] 2. **Naming pattern consistency** — Evaluate whether the `naming_pattern` follows a consistent convention (numeric prefix + descriptive name). If the naming pattern is inconsistent, flag as FAIL with `inconsistent_naming`.
- [ ] 3. **INDEX.md presence** — Evaluate whether `index_file.actual_present` is true. If INDEX.md is missing, flag as FAIL with `missing_index_file`.
- [ ] 4. **Related rules proximity** — For each entry in `related_rules`, evaluate whether sibling rules in the same section are logically related. If unrelated rules are grouped together, flag as FAIL with `unrelated_rules_grouped`.
- [ ] 5. **File groupings** — For each grouping in `file_groupings`, evaluate whether the files in each group share a coherent topic. If files are grouped under an incoherent topic, flag as FAIL with `incoherent_file_grouping`.
- [ ] 6. **Coverage gaps** — For each gap in `coverage_gaps`, evaluate whether the missing file represents a genuine coverage gap. If genuine coverage gaps exist, flag as FAIL with `coverage_gap`.
- [ ] 7. **Missed groupings** — If the upstream reasoning role identified missed groupings (`missed_groupings`), evaluate whether those groupings are genuine. If genuine missed groupings exist, flag as FAIL with `missed_file_grouping`.
- [ ] 8. If the upstream reasoning role flagged evidence as `corrected`, use the corrected values
- [ ] 9. If the upstream reasoning role flagged evidence as `unvalidated`, note the uncertainty in the explanation but still render a verdict

Record results:

```yaml
ga_6_evaluation:
  criterion_id: "GA-6"
  description: "File organization logical"
  result: "PASS|FAIL"
  evidence_source: "reasoning.yaml → file_organization_validation"
  sub_checks:
    inconsistent_naming:
      result: "PASS|FAIL"
      findings: ["<description>", ...]
    missing_index_file:
      result: "PASS|FAIL"
      findings: ["<description>", ...]
    unrelated_rules_grouped:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    incoherent_file_grouping:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    coverage_gap:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
    missed_file_grouping:
      result: "PASS|FAIL"
      count: <N>
      findings: ["<description>", ...]
  explanation: "<reasoning for overall verdict>"
  remediation: "<if FAIL, what to fix>"
```

### Step 9: Process Verdicts

Compile all per-criterion verdicts and apply consensus rules:

- [ ] 1. Collect all verdicts from Steps 3-8 into a single `per_criterion` array
- [ ] 2. Each entry must include: `criterion_id`, `result`, `evidence`, `explanation`, `remediation`, `next_step`, `tool_calls_made`
- [ ] 3. `next_step` is `"proceed"` when result is PASS, `"remediate"` when result is FAIL
- [ ] 4. Count total, pass, and fail verdicts

### Step 10: Apply Self-Consistency Gate

Apply a self-consistency check to every PASS verdict:

- [ ] 1. For each criterion with `result: "PASS"`:
  - Read the `explanation` field
  - If the explanation contains critique/hedging language ("should be", "needs", "missing", "could improve", "minor", "some issues", "mostly", "generally") → downgrade to FAIL
  - A PASS verdict must be strictly confirmatory with no critique or hedging
- [ ] 2. Re-count pass/fail after self-consistency downgrades

### Step 11: Generate Bidirectional Findings

Generate findings ONLY for FAIL criteria. PASS criteria MUST NOT appear in the findings table.

| Finding Type | Direction | Description |
|-------------|-----------|-------------|
| GUIDELINE_AMBIGUOUS | guideline→agent | Rule condition open to interpretation |
| GUIDELINE_CONFLICTING | guideline↔guideline | Rule contradicts another rule |
| GUIDELINE_UNENFORCEABLE | guideline→agent | Action cannot be executed by LLM |
| GUIDELINE_REDUNDANT | guideline↔guideline | Cross-reference duplicated across files |
| GUIDELINE_OVERFLOW | guideline→agent | Rule context exceeds token limit |
| GUIDELINE_DISORGANIZED | guideline→agent | File organization illogical |

- [ ] 1. For each FAIL criterion, classify the finding type
- [ ] 2. Present revision options for developer decision
- [ ] 3. Include specific remediation guidance for each FAIL

### Step 12: Write verdict.yaml

Write the complete verdict to `{artifact_evidence_dir}/verdict.yaml`:

```yaml
evaluator: guideline-audit-evaluator
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
guideline_paths: ["<path>", ...]
summary:
  total_criteria: <N>
  pass: <N>
  fail: <N>
  all_criteria_pass: true | false
  remediation_required: true | false
per_criterion:
  - criterion_id: "GA-1"
    result: "PASS|FAIL"
    evidence: "reasoning.yaml → ambiguity_validation + rule_condition_validation"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|remediate"
    tool_calls_made:
      - read
  - criterion_id: "GA-2"
    result: "PASS|FAIL"
    evidence: "reasoning.yaml → conflict_indicator_validation"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|remediate"
    tool_calls_made:
      - read
  - criterion_id: "GA-3"
    result: "PASS|FAIL"
    evidence: "reasoning.yaml → rule_condition_validation + enforcement_pattern_validation + ambiguity_validation"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|remediate"
    tool_calls_made:
      - read
  - criterion_id: "GA-4"
    result: "PASS|FAIL"
    evidence: "reasoning.yaml → cross_reference_validation"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|remediate"
    tool_calls_made:
      - read
  - criterion_id: "GA-5"
    result: "PASS|FAIL"
    evidence: "reasoning.yaml → token_count_validation"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|remediate"
    tool_calls_made:
      - read
  - criterion_id: "GA-6"
    result: "PASS|FAIL"
    evidence: "reasoning.yaml → file_organization_validation"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|remediate"
    tool_calls_made:
      - read
ga_1_evaluation: {...}
ga_2_evaluation: {...}
ga_3_evaluation: {...}
ga_4_evaluation: {...}
ga_5_evaluation: {...}
ga_6_evaluation: {...}
bidirectional_findings:
  - criterion_id: "<ID>"
    finding_type: "GUIDELINE_AMBIGUOUS|GUIDELINE_CONFLICTING|GUIDELINE_UNENFORCEABLE|GUIDELINE_REDUNDANT|GUIDELINE_OVERFLOW|GUIDELINE_DISORGANIZED"
    description: "<description>"
    revision_option: "<guidance>"
```

### Step 13: Return Frugal Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{artifact_evidence_dir}/verdict.yaml"
summary: "<N> criteria evaluated. <X> PASS, <Y> FAIL."
all_criteria_pass: true | false
remediation_required: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Evaluate GA-1 (Rule Conditions Are Unambiguous) → INVALID if skipped
- [ ] 4. Evaluate GA-2 (No Conflicting Rules) → INVALID if skipped
- [ ] 5. Evaluate GA-3 (Actions Are LLM-Enforceable) → INVALID if skipped
- [ ] 6. Evaluate GA-4 (No Redundant Cross-File References) → INVALID if skipped
- [ ] 7. Evaluate GA-5 (Context Fits in LLM Window) → INVALID if skipped
- [ ] 8. Evaluate GA-6 (File Organization Logical) → INVALID if skipped
- [ ] 9. Process Verdicts → INVALID if skipped
- [ ] 10. Apply Self-Consistency Gate → INVALID if skipped
- [ ] 11. Generate Bidirectional Findings → INVALID if skipped
- [ ] 12. Write verdict.yaml → INVALID if skipped
- [ ] 13. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| reasoning.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| reasoning.yaml is not valid YAML | Return BLOCKED with INVALID_REASONING_FORMAT |
| guideline_paths missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| Glob expansion returns no files | Return BLOCKED with NO_GUIDELINE_FILES_FOUND |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| upstream reasoning role flagged evidence as unvalidated | Note uncertainty in explanation — still render verdict |
| upstream reasoning role flagged evidence as corrected | Use corrected values — do NOT use original evidence values |
| Expected evidence section missing from reasoning.yaml | Record as `section_missing` — do NOT BLOCK, but flag in verdict |
| Write permission denied | Return BLOCKED — cannot write verdict.yaml |

## Cross-References

- `tasks/guideline-audit-generator.md` — Generator role (produces the evidence.yaml consumed by this task)
- `tasks/guideline-audit-knowledge-supporter.md` — upstream reasoning role role (produces the reasoning.yaml consumed by this task)
- `tasks/cross-validate.md` — Path Provider (Judger) role (consumes this task's verdict.yaml)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` — guideline standards and critical rule definitions
- `065-verification-honesty.md` — live verification requirement
- `080-code-standards.md` — enforcement test mandate and evidence type taxonomy
