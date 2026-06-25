<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: cross-validate

## Purpose

Accept an evidence payload, evaluation criteria, and pre-resolved auditor verdicts — then cross-reference those verdicts per criterion — producing PASS only when both auditors independently returned PASS. This task does NOT dispatch auditors; the orchestrator task()s auditors before invoking cross-validate and passes the verdicts as entry criteria.

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) both auditors independently agree.

## Entry Criteria

- `spec_local_dir`: Local directory containing Markdown spec files
- `artifact_evidence_dir`: Path(s) to directories containing auditor YAML verdict artifacts on disk
- Lightweight audit-type structural criteria (SC-1/PF-1/CS-1/GA-1 templates) provided as task-file-defined templates WITHOUT embedded spec SC content
- `auditor_metadata`: Optional array of `{ auditor_type, family, parseable }` for auditor identity context

## Cross-Validate Checklist

- [ ] 1. Load Spec + extract SCs from spec_local_dir
- [ ] 2. Pre-Inspection Classification Gate — runtime-behavioral uplift check for each SC
- [ ] 3. Load both auditor verdict artifacts (artifact_evidence_dir)
- [ ] 4. Per-SC comparison: Auditor-A verdict vs Auditor-B verdict
- [ ] 5. **Do NOT reclassify FAIL** — a FAIL from either auditor is a FAIL in the cross-validate verdict
- [ ] 6. PASS only when BOTH auditors returned PASS for the SC
- [ ] 7. Evidence Type Matrix enforcement — downgrade PASS with EVIDENCE_TYPE_MISMATCH to FAIL
- [ ] 8. Write unified verdict artifact to disk
- [ ] 9. Return frugal contract with verdict summary

### Step 0: Load Spec

`spec_local_dir` is REQUIRED. Auditors BLOCK if absent.

```python
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
spec_scs = []
spec_evidence_types = {}
for f in spec_files:
    content = read(filePath=f)
    extract_success_criteria(content, spec_scs)
    extract_evidence_types(content, spec_evidence_types)
```

Use the loaded spec SCs as the sole authoritative baseline for evidence type checks. Do NOT accept inline-provided evaluation_criteria as authoritative for evidence type — the spec's own declarations are the source of truth.

## Pre-Inspection Classification Gate (MANDATORY)

**Before evaluating any evidence, the auditor MUST classify each SC by asking: "Does this change affect runtime behavior? YES/NO."**

### Classification Question

For each success criterion in the audit scope:

- [ ] 1. Read the implementation diff for the files the SC covers
- [ ] 2. Ask: "Does this change affect runtime behavior?" — this is a substrate-determined question, not intent-determined
- [ ] 3. If YES → the SC's evidence type is UPLIFTED to `behavioral` regardless of how it was declared
- [ ] 4. If NO → the declared type stands

### What Affects Runtime Behavior

| Change Type | Affects Runtime Behavior? | Classification |
|-------------|---------------------------|----------------|
| Function logic changes | YES | Uplift to behavioral |
| Control flow changes | YES | Uplift to behavioral |
| API endpoint changes | YES | Uplift to behavioral |
| New code paths | YES | Uplift to behavioral |
| Config-only changes (no runtime effect) | NO | Declared type stands |
| Documentation-only changes | NO | Declared type stands |
| Style/formatting changes | NO | Declared type stands |
| Data schema changes with runtime effects | YES | Uplift to behavioral |

### Uplift Protocol

When an SC is uplifted:
- [ ] 1. Record the uplift in the audit report: `SC-N: uplifted from [declared_type] to behavioral (change affects runtime behavior: [reason])`
- [ ] 2. Evaluate ALL evidence against the `behavioral` tier
- [ ] 3. Structural or string evidence for an uplifted SC is classified as `EVIDENCE_TYPE_MISMATCH` with a FAIL verdict
- [ ] 4. The uplift is MANDATORY — no opt-out, no "close enough" exception

**🚫 FORBIDDEN:** Accepting structural evidence for an uplifted SC. The uplift is automatic and non-negotiable.

**Authority:** `guidelines/000-critical-rules.md` §critical-rules-BEH-EV, `guidelines/080-code-standards.md` §Evidence Type Taxonomy

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
| MISSING_INPUT | `spec_local_dir` missing or empty, or no .md files readable | `MISSING_INPUT` | Return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }` |
| MISSING_EVIDENCE_DIR | `artifact_evidence_dir` missing, null, or empty | `MISSING_EVIDENCE_DIR` | Return `{ status: "BLOCKED", error: "MISSING_EVIDENCE_DIR" }` |
| ARTIFACT_UNREADABLE | Auditor YAML artifact file cannot be read or parsed | `ARTIFACT_UNREADABLE` | Return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE" }` |
| INSUFFICIENT_ARTIFACTS | Each auditor produces fewer than 1 verdict OR both auditors share the same family | `INSUFFICIENT_ARTIFACTS` | Return `{ status: "BLOCKED", error: "INSUFFICIENT_ARTIFACTS" }` |

These gates are **non-recovery** per adversarial-audit-017. Do NOT attempt to resolve models inline, re-dispatch auditors, or fabricate verdicts. The ONLY valid path is: resolve-models → auditor dispatch → cross-validate with results. NO fallback, NO single-auditor mode, NO alternative paths.

## Procedure

### Step 0: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with cross-validation:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. Verify `artifact_evidence_dir` is present and contains at least 2 YAML files — if fewer than 2, return BLOCKED:

```yaml
status: BLOCKED
error: INSUFFICIENT_ARTIFACTS
missing: "artifact_evidence_dir"
remediation: "At least 2 YAML evidence files are required in artifact_evidence_dir. Ensure both auditors have written their verdict artifacts before dispatching cross-validate."
```

- [ ] 3. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for cross-validate. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 4. If `artifact_evidence_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for cross-validate. The orchestrator must provide a directory containing auditor YAML verdict artifacts."
```

### Step 1: Context Contamination Detection

This section is obsolete with binary PASS/FAIL verdicts. Auditors now return only PASS or FAIL — non-binary verdicts indicate a defective auditor card, not a contaminated dispatch. If an auditor returns anything other than PASS or FAIL, flag it as an auditor card defect and BLOCK pipeline.

### Step 2: Validate Input

Confirm `spec_local_dir` is present and non-empty. Glob `**/*.md` in `<spec_local_dir>/`, read all discovered files via `read` tool. If `spec_local_dir` is missing, empty, or no .md files can be read: return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }`.

### Step 3: Validate Evidence Directory

Confirm `artifact_evidence_dir` is present, non-null, and non-empty. The sub-agent reads auditor YAML verdict artifacts from files discovered in the evidence directory via `glob`/`read`. Each discovered YAML file MUST contain `{ criterion_id, result, evidence, explanation, remediation, next_step }`.

- If `artifact_evidence_dir` is missing or null: return `{ status: "BLOCKED", error: "MISSING_EVIDENCE_DIR" }`.
- If `artifact_evidence_dir` has fewer than 2 YAML files: return `{ status: "BLOCKED", error: "INSUFFICIENT_ARTIFACTS" }`.
- If artifact file cannot be read: return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE" }`.
- If both files share the same `family`: return `{ status: "BLOCKED", error: "INSUFFICIENT_FAMILIES" }`.

### Step 4: Read and Parse Auditor Verdicts from Disk

For each YAML file discovered via glob/read in `artifact_evidence_dir`, read the verdict file from disk using the `read` tool. Each file contains the full YAML verdict artifact. Expected format per verdict file:

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
- `result` MUST be: `PASS` or `FAIL`. These are the only valid verdicts. Auditors BLOCK on contamination or insufficient evidence — they never produce non-binary verdicts.
- `evidence` MUST reference a live tool call (URL, file path, or command output) — memory-cached claims are FORBIDDEN
- `explanation` MUST be present and non-empty
- `remediation` MUST be present when result is not PASS
- `next_step` MUST be one of: `proceed`, `re-evaluate`, `escalate`

If an auditor's YAML artifact is unparseable, missing the expected fields, or contains no recognizable criterion ids: treat the entire auditor's contribution as `FAIL` for ALL criteria. Do NOT re-task — the protocol requires accepting real output, not retrying until PASS is obtained.

If an auditor's YAML artifact has extra criterion ids not in `evaluation_criteria`: ignore extra verdicts, flag in result contract as `EXTRA_VERDICTS` warning.

If an auditor's YAML artifact is missing a criterion id from `evaluation_criteria`: treat that criterion as `FAIL` for that auditor with explanation `"MISSING_VERDICT"`.

### Step 5: Cross-Reference Verdicts — Monotonic Non-Increasing Invariant

**Cross-validate verdicts are monotonic non-increasing in PASSness.** Verdicts must never increase in PASSness at the cross-validate stage. Cross-validate is a rejection filter, not a remediation gate.

| Direction | Allowed? | Mechanism |
|---|---|---|
| FAIL → FAIL | ✅ Stays | If both return FAIL, or one returns FAIL, consensus = FAIL |
| PASS → FAIL | ✅ De-elevation | Caught by Step 5.7 self-check (narrative override, PASS+critique, hedging, weak evidence) |
| FAIL → PASS | 🚫 FORBIDDEN | Only a fresh audit cycle with new clean-room auditors can produce a new verdict on a revised deliverable |
| PASS → PASS | ✅ Stays | Both auditors return clean PASS — confirmed by Step 5.7 self-check |

For each criterion in `evaluation_criteria`:

| Rule | Result |
|---|---|
| Both auditors return `PASS` | `consensus = PASS` |
| Either auditor returns `FAIL` | `consensus = FAIL` |
| Non-PASS result (any non-binary verdict) | `consensus = BLOCKED` — auditors should never produce this |
| Either auditor's verdict is missing or unparseable | `consensus = FAIL` |
| Auditors disagree (one PASS, one non-PASS) | `consensus = FAIL` |

Non-PASS (only valid non-PASS verdict is FAIL) = BLOCKED pipeline. FAIL is terminal — no reclassification permitted. Any non-binary verdict (AUDIT_FAIL, FABRICATED, LIMITED-EVIDENCE, INCONCLUSIVE) means the auditor is operating outside spec — BLOCK pipeline and flag the auditor card for correction. Orchestrator reads `next_step` from verdict and routes accordingly — does NOT interpret or override.

Track disagreements explicitly in the result contract for transparency: a `PASS`/`FAIL` split is different from a double `FAIL`.

#### FAIL Is Terminal — No Reclassification (MANDATORY)

FAIL from an auditor is **terminal at the cross-validate stage**. A FAIL cannot become a PASS — not with narrative override, not with evidence of a fix, not with any reasoning. The only valid path from FAIL to PASS is: report FAIL → orchestrator routes to remediation → deliverable is revised → fresh audit cycle dispatched with new clean-room auditors and fresh resolve-models.

The following rationalization patterns are enumerated as explicit violations:

| Rationalization Pattern | Why Forbidden | Verdict |
|---|---|---|
| "Revision already applied" / "already fixed" | Process metadata substituted for structural correction evaluation | Consensus = FAIL — surface to orchestrator for re-audit |
| "Functionally equivalent" / "close enough" | Soft-pass per critical-rules-020 | Consensus = FAIL |
| "Minor concern / edge case" | Agent judgment substituting for strict agreement | Consensus = FAIL |
| "Resolved in separate change" / "out of scope" | Shifting evaluation target | Consensus = FAIL |
| "Partially addressed" / "mostly correct" | Hedging disqualifies clean PASS | Consensus = FAIL |
| Auditor 1 = FAIL, auditor 2 = PASS, cross-validate "resolves" to PASS | Direct violation of monotonic invariant | Consensus = FAIL |
| Any single-sentence dismissal of a FAIL finding | Insufficient analysis for a gate this important | Consensus = FAIL |
| "Let's look at this pragmatically" / "the intent is satisfied" | Pragmatism ≠ verification — binary rules apply | Consensus = FAIL |

**Cross-validate does NOT perform remediation verification.** That is the job of a fresh audit cycle with new clean-room auditors. Cross-validate only evaluates what the auditors produced — it does not verify fixes.

#### Evidence Type Gate (MANDATORY — Per SC)

Before computing consensus for each criterion, cross-validate MUST check the declared evidence type against the actual evidence type used by each auditor. This gate prevents auditors from verifying behavioral SCs with structural evidence and reporting PASS.

**For each criterion (from the loaded spec SCs in Step 0):**

- [ ] 1. Read the criterion's declared `evidence_type` from the loaded spec (spec_scs from Step 0 — NOT from inline evaluation_criteria)
- [ ] 2. For each auditor's verdict on that criterion, check the evidence type used:
   - If `evidence_type` is not declared in the criterion, default to `string`
   - If the auditor used structural evidence (file existence, grep, read) for a criterion declared as `behavioral`, downgrade that auditor's verdict from PASS to FAIL with `EVIDENCE_TYPE_MISMATCH` classification
   - If the auditor used structural or string-only evidence for a criterion declared as `semantic`, downgrade that auditor's verdict from PASS to FAIL with `EVIDENCE_TYPE_MISMATCH` classification
- [ ] 3. If both auditors used wrong evidence types for a behavioral SC: consensus is FAIL with `EVIDENCE_TYPE_MISMATCH`
- [ ] 4. If one auditor used correct evidence type (PASS) and the other used wrong evidence type (PASS → downgraded to FAIL): consensus is DISAGREE — resolve by re-dispatching the wrong-evidence-type auditor with explicit evidence type classification
- [ ] 5. The evidence type gate applies BEFORE the consensus computation — it modifies auditor verdicts before they enter the consensus matrix

**EVIDENCE_TYPE_MISMATCH is not a soft-pass condition.** It is a hard FAIL that prevents structural evidence from passing as behavioral evidence — the exact defect exposed by spec #804.

#### DISAGREE Is Terminal — No Reclassification (MANDATORY)

When auditors disagree on a criterion (one PASS, one FAIL), the consensus is FAIL. The cross-validate sub-agent MUST NOT:

- [ ] 1. **Reclassify FAIL as PASS** — reasoning that one auditor's pattern was "more correct" or "over-broad" is soft-passing per `000-critical-rules.md` §critical-rules-020. FAIL is never reclassifiable as PASS.
- [ ] 2. **Resolve disagreements through reasoning** — the cross-validate sub-agent does not have authority to determine which auditor is correct. DISAGREE means the evidence is contested, and contested evidence is FAIL.
- [ ] 3. **Annotate PASS on a FAIL criterion** — any annotation, footnote, caveat, or "resolved as PASS" qualifier on a FAIL criterion is a soft-pass violation.

Disagreements MUST be surfaced to the developer for resolution. The `disagreements` list in the result contract MUST contain every SC where auditors diverged, with both auditors' evidence. The developer decides whether to remediate the underlying issue or accept the contested SC — the cross-validate sub-agent does not make this decision.

This rule is non-waivable. Per `000-critical-rules.md` §critical-rules-020, verification is binary: exact match or FAIL. "Functionally equivalent" is never a valid consensus outcome.

#### Finding Types (MANDATORY)

The cross-validate result contract MUST use the following finding type classifications. All produce FAIL verdicts per `critical-rules-hard-fail`:

| Finding Type | When to Use | Verdict |
|-------------|-------------|---------|
| `VERIFICATION-GAP` | Orphan change with no matching SC — implementation exists but no SC covers it | FAIL |
| `COVERAGE-GAP` | Implementation extends beyond spec scope — code does more than the SC requires | FAIL |
| `EVIDENCE_TYPE_MISMATCH` | Wrong evidence type for SC tier — structural evidence for behavioral SC | FAIL |
| `ANTI_EVASION` | Agent evading behavioral testing — claiming model unavailability, "too slow", or test-not-needed for runtime-behavioral changes | FAIL |

**Authority:** `guidelines/000-critical-rules.md` §critical-rules-BEH-EV, §critical-rules-hard-fail, §critical-rules-060

### Step 6: Compute Aggregate Consensus

`overall_consensus = PASS` iff `consensus == PASS` for ALL criteria. Any single `FAIL` in the table cascades to `overall_consensus = FAIL`.

**Severity-based exception for SC-SEM criteria:** SC-SEM criteria carry a `severity` field (`ERROR` or `WARNING`). A FAIL on a WARNING-severity criterion does NOT cascade to `overall_consensus = FAIL` — it is recorded as a warning in the findings but does not block the pipeline. A FAIL on an ERROR-severity criterion DOES cascade to `overall_consensus = FAIL` and blocks the pipeline. Non-SC-SEM criteria (without a `severity` field) are treated as ERROR-severity by default — any FAIL blocks the pipeline.

### Step 6.5: Verdict Self-Consistency Gate

Before dark pattern enforcement, every verdict must pass a self-consistency check:

- [ ] 1. **PASS with finding language**: If `result: "PASS"` while `explanation`, `evidence`, or `remediation` field contains finding/critique language (e.g., "should be", "needs", "missing", "could improve"), the PASS is contradictory — downgrade to FAIL. PASS must be strictly confirmatory with no critique.
- [ ] 2. **clean_room.verified constraint**: When `violations_detected` is non-empty, `clean_room.verified` MUST be `false`. If violations exist but verified is true, flag as `SELF_CONSISTENCY_FAIL`.
- [ ] 3. **Evidence-verdict alignment**: If `result: "PASS"` but `evidence` references "minor concerns", "some issues", or other hedging language, downgrade to FAIL. A PASS verdict must have PASS-level evidence (confirmatory only).

| Self-Consistency Rule | Trigger | Action |
|---|---|---|
| PASS + critique language | `explanation` or `remediation` contains finding/fix language | Downgrade to FAIL |
| violations_detected + verified=true | Non-empty violations with verified=true | flag `SELF_CONSISTENCY_FAIL` |
| PASS + hedging evidence | Evidence contains concern/minor/issue qualifiers | Downgrade to FAIL |

### Step 6.7: Output-Integrity Self-Check (MANDATORY)

Before dark pattern enforcement (Step 6) and before returning the result contract, cross-validate MUST scan its own output for violations of the monotonic invariant. If ANY of the following are detected, self-correct the affected criterion to FAIL:

| Self-Check | Detection Signal | Action |
|---|---|---|
| PASS + critique language | `result: "PASS"` while `explanation` or `remediation` contains finding/fix language ("should be", "needs", "missing", "could improve", "minor", "some issues") | Downgrade to FAIL |
| FAIL reclassified to PASS | Consensus declared as PASS but one or both auditors returned FAIL | Downgrade to FAIL |
| Disagreement suppressed | Auditor 1 = FAIL, Auditor 2 = PASS, consensus declared as PASS | Downgrade to FAIL |
| Hedging qualifiers | Evidence field contains "mostly", "generally", "largely", "essentially" | Downgrade to FAIL |
| Narrative override | Explanation cites "revision applied", "already fixed", "out of scope", "pragmatically", "intent satisfied" as justification | Downgrade to FAIL |

#### Self-Correction Protocol

When self-check finds violations:
- [ ] 1. Self-correct those criteria to FAIL
- [ ] 2. Add `self_corrections` array to the result contract documenting each correction and its detection signal
- [ ] 3. Recompute aggregate — any self-corrected FAIL cascades to `overall_consensus = FAIL`
- [ ] 4. Set `next_step = "remediate then re-audit"`

Self-correction means the cross-validate sub-agent caught itself in a protocol violation. This is documented, not hidden.

### Step 7: Dark Pattern Enforcement (MANDATORY — NO BYPASS)

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

### Step 6.5: Write Findings YAML to Disk

Write the full cross-validate findings YAML to `./tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml`:

```yaml
phase: cross-validate
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
auditor_1:
  type: "<auditor_type>"
  family: "<family>"
  artifact: "<artifact_path>"
auditor_2:
  type: "<auditor_type>"
  family: "<family>"
  artifact: "<artifact_path>"
summary:
  overall_consensus: PASS|FAIL
  next_step: "proceed|remediate then re-audit"
  total_criteria: N
  agreed: N
  disagreed: N
  evidence_type_mismatches: N
  dark_pattern_violations: N
findings:
  - criterion_id: "SC-1"
    declared_evidence_type: "structural|string|semantic|behavioral"
    severity: "ERROR|WARNING"  # Only present for SC-SEM criteria; ERROR blocks pipeline, WARNING flags but does not block
    auditor_1_result: PASS
    auditor_2_result: PASS
    consensus: PASS
    agreement: true
    evidence_type_mismatch: false
self_corrections:
  - criterion_id: "SC-N"
    detection_signal: "PASS + critique language: explanation contained 'should verify'"
    original_consensus: PASS
    corrected_consensus: FAIL
disagreements: []
dark_pattern_violations: []
warnings: []
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

Create `./tmp/{issue-N}/artifacts/` if needed (write tool creates implicitly). Use the `write` tool to persist the full YAML document.

### Step 7: Return Frugal YAML Result Contract

Return ONLY this YAML as the final response — no preamble, no commentary, no markdown fences:

```yaml
status: DONE
overall_consensus: PASS|FAIL
next_step: "proceed|remediate then re-audit"
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml"
summary: "N SCs: X agreed, Y disagreed, Z evidence_type_mismatch"
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

When self-corrections are present, `overall_consensus` MUST be FAIL. Any single self-correction in any criterion cascades to overall FAIL.

The `next_step` field:
- `overall_consensus == PASS` → `next_step: "proceed"` (next pipeline continuation)
- `overall_consensus == FAIL` → `next_step: "remediate then re-audit"` (orchestrator routes to recovery)

## Context Required

- `spec_local_dir`: Local directory containing Markdown spec files
- `artifact_evidence_dir`: Path(s) to directories containing auditor YAML verdict artifacts
- `audit_phase`: Current audit phase for task context

## Red Flags

- Never task() auditors from within cross-validate — the orchestrator dispatches auditors, cross-validate discovers artifacts via evidence dir
- Never leak orchestrator reasoning into verdict parsing — clean-room means evidence + criteria ONLY
- Never soft-pass a mismatch — `PASS`/`FAIL` split = FAIL per adversarial-audit-004
- Never fabricate verdicts when auditor YAML artifact is unreadable or unparseable — missing data = FAIL per adversarial-audit-005
- Never accept memory-cached claims as evidence — every verdict must reference a live tool call
- Never re-task an auditor after a FAIL verdict — FAIL stays FAIL
- Never resolve auditors inline — `resolve-models` is called by orchestrator before this task
- Never bypass dark pattern enforcement — Step 6 checks are MANDATORY per adversarial-audit-013 through adversarial-audit-018
- Never attempt recovery from BLOCKED status — Non-Recovery Gates are terminal per adversarial-audit-017
- Never pass YAML verdict content inline through orchestrator context — verdict artifacts stay on disk; only artifact_path reaches orchestrator

## Cross-References

- `adversarial-audit/SKILL.md` — skill-level operating protocol and enforcement rules
- `adversarial-audit/tasks/resolve-models.md` — cross-family auditor model selection (orchestrator calls this, not cross-validate)
- `adversarial-audit/tasks/completion.md` — halt guarantee
- `.opencode/agents/auditor-*.md` — auditor agent files with model and permission definitions
- `065-verification-honesty.md` — live-source verification mandate, stale evidence prohibition
- `000-critical-rules.md` — clean-room task() protocol, orchestrator purity
- Spec #578, Plan #382

## Sub-Agent Routing

### Task Rules

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|---|
| `spec_local_dir`, `artifact_evidence_dir`, `audit_phase` | Implementation context, agent memory, orchestrator reasoning, prior verification, spec_body, evaluation_criteria, verdict content | N/A — cross-validate discovers artifacts via evidence dir, does not dispatch auditors | NO |

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
    title: "Evidence directory must be provided — cross-validate discovers artifacts via glob/read"
    conditions:
      all: ["artifact_evidence_dir == null OR artifact_evidence_dir_empty == true"]
    actions: [RETURN_BLOCKED, REPORT_MISSING_EVIDENCE_DIR]
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
    title: "Non-PASS verdicts cascade to BLOCKED"
    conditions:
      any: ["auditor_result != .PASS."]
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
    title: "Non-recovery gate — MISSING_INPUT, MISSING_EVIDENCE_DIR, ARTIFACT_UNREADABLE, INSUFFICIENT_ARTIFACTS are terminal with no fallback"
    conditions:
      any: ["error == 'MISSING_INPUT'", "error == 'MISSING_EVIDENCE_DIR'", "error == 'ARTIFACT_UNREADABLE'", "error == 'INSUFFICIENT_ARTIFACTS'"]
    actions: [RETURN_BLOCKED, NO_RECOVERY]
    source: "cross-validate.md §Non-Recovery Gates"
```