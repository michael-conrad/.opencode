<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: cross-validate

## Purpose

Path Provider (Judger) role. Reads all upstream artifacts (`evidence.yaml`, `reasoning.yaml`, `verdict.yaml`) and produces the final `judgment.yaml`.

> **DiMo Role: Path Provider (Judger).** This task produces the final judgment by cross-referencing all upstream artifacts. Reads all artifacts (`evidence.yaml`, `reasoning.yaml`, `verdict.yaml`), writes `judgment.yaml`.
>
> You are the Path Provider (Judger). You are a synthesizer, not an evaluator. Your job is to read what upstream roles produced and assemble the final picture. You do not second-guess their work. You do not re-open their decisions. You take their outputs and produce the final judgment.
> 
> 
> - MUST accept Evaluator's per-criterion verdicts as final — do NOT re-evaluate
> - MUST NOT overrule a PASS/FAIL from the Evaluator
> - MUST NOT produce new evidence or re-validate existing evidence
> - MUST write `judgment.yaml` as the only output artifact
> 

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- `spec_local_dir`: Local directory containing Markdown spec files
- `artifact_evidence_dir`: Path to directory containing upstream YAML verdict artifacts on disk

## Cross-Validate Checklist

- [ ] 1. Load Spec + extract SCs from spec_local_dir
- [ ] 2. Pre-Inspection Classification Gate — runtime-behavioral uplift check for each SC
- [ ] 3. Load upstream verdict artifacts from artifact_evidence_dir
- [ ] 4. Per-SC evaluation: does the verdict match the evidence?
- [ ] 5. Evidence Type Matrix enforcement — downgrade PASS with EVIDENCE_TYPE_MISMATCH to FAIL
- [ ] 6. Write judgment.yaml to disk
- [ ] 7. Return frugal contract with verdict summary

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

- Judgment result array `[{ criterion_id, result, evidence, explanation }]` returned
- Each criterion has a definitive `PASS` or `FAIL` verdict
- Aggregate `overall_verdict`: `PASS` iff ALL criteria have `PASS`
- No fabricated verdicts — missing or unparseable upstream output is treated as `FAIL`
- Result contract includes `next_step` field: `"remediate then re-audit"` for FAIL, next pipeline continuation for PASS

## Non-Recovery Gates

The following states are **terminal BLOCKED states** with no fallback or recovery paths. When encountered, cross-validate MUST return `status: BLOCKED` immediately — no re-task, no retry, no workaround.

| Gate | Condition | Error Code | Action |
|------|-----------|------------|--------|
| MISSING_INPUT | `spec_local_dir` missing or empty, or no .md files readable | `MISSING_INPUT` | Return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }` |
| MISSING_EVIDENCE_DIR | `artifact_evidence_dir` missing, null, or empty | `MISSING_EVIDENCE_DIR` | Return `{ status: "BLOCKED", error: "MISSING_EVIDENCE_DIR" }` |
| ARTIFACT_UNREADABLE | Upstream YAML artifact file cannot be read or parsed | `ARTIFACT_UNREADABLE` | Return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE" }` |

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/cross-validate/`

### Step 0a: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for cross-validate. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 3. If `artifact_evidence_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for cross-validate. The orchestrator must provide a directory containing upstream YAML verdict artifacts."
```

### Step 1: Validate Input

Confirm `spec_local_dir` is present and non-empty. Glob `**/*.md` in `<spec_local_dir>/`, read all discovered files via `read` tool. If `spec_local_dir` is missing, empty, or no .md files can be read: return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }`.

### Step 2: Validate Evidence Directory

Confirm `artifact_evidence_dir` is present, non-null, and non-empty. The sub-agent reads upstream YAML verdict artifacts from files discovered in the evidence directory via `glob`/`read`. Each discovered YAML file MUST contain `{ criterion_id, result, evidence, explanation, remediation, next_step }`.

- If `artifact_evidence_dir` is missing or null: return `{ status: "BLOCKED", error: "MISSING_EVIDENCE_DIR" }`.
- If artifact file cannot be read: return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE" }`.

### Step 3: Read and Parse Upstream Verdicts from Disk

For each YAML file discovered via glob/read in `artifact_evidence_dir`, read the verdict file from disk using the `read` tool. Expected format per verdict file:

```
---
criterion_id: "SC-1"
result: "PASS"
evidence: "<tool-call reference>"
explanation: "<reasoning>"
remediation: ""
next_step: "proceed"  # Conditional: "remediate" when result is "FAIL", "proceed" when result is "PASS"
all_criteria_pass: false
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

FAIL from an auditor is **terminal at the cross-validate stage**. A FAIL cannot become a PASS — not with narrative override, not with evidence of a fix, not with any reasoning. The only valid path from FAIL to PASS is: report FAIL → orchestrator routes to remediation → deliverable is revised → fresh audit cycle dispatched with new clean-room auditors via the DiMo role chain.

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

#### Artifact Engagement Check (MANDATORY — Per SC)

Before finalizing the judgment for each criterion, cross-validate MUST verify that the upstream verdict actually inspected the behavioral evidence artifacts. This gate prevents PASS verdicts on behavioral SCs without engaging the behavioral test output.

**Key principle:** Evidence type is determined at **production time**, not consumption time. When the orchestrator passes `artifact_evidence_dir`, it declares "these are behavioral test results" (the orchestrator ran `opencode-cli run`). The sub-agent's inspection tool (`read`, `grep`) does NOT re-classify the evidence type. Reading a `timeline.yaml` from `opencode-cli run` is behavioral evidence inspection — the same way reading a pytest output log is behavioral evidence inspection.

**For each criterion (from the loaded spec SCs in Step 0):**

- [ ] 1. Read the criterion's declared `evidence_type` from the loaded spec (spec_scs from Step 0 — NOT from inline evaluation_criteria)
- [ ] 2. For the upstream verdict on that criterion, check whether it engaged the behavioral evidence artifacts:
   - If `evidence_type` is not declared in the criterion, default to `string`
   - If the criterion is declared as `behavioral`: check that the verdict's `evidence` field references files from the behavioral test output directory (`artifact_evidence_dir`). Did it read `timeline.yaml`, `stderr.log`, `session.yaml`, or `stdout.log`? Did it reference specific tool calls from the trace?
   - If the verdict's evidence references ONLY source code files, file existence checks, or grep patterns outside the behavioral test output — and does NOT reference any behavioral test artifact — downgrade that verdict from PASS to FAIL with `EVIDENCE_TYPE_MISMATCH` classification
   - If the criterion is declared as `semantic`: check that the verdict used analytical judgment (sub-agent read + reasoning), not just grep/string matching. If it used only string evidence, downgrade to FAIL with `EVIDENCE_TYPE_MISMATCH`
- [ ] 3. If the upstream verdict failed to engage behavioral evidence for a behavioral SC: judgment is FAIL with `EVIDENCE_TYPE_MISMATCH`

**EVIDENCE_TYPE_MISMATCH is not a soft-pass condition.** It is a hard FAIL.

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

`overall_verdict = PASS` iff `consensus == PASS` for ALL criteria. Any single `FAIL` in the table cascades to `overall_verdict = FAIL`.

**No severity-based exceptions:** All FAILs cascade to `overall_verdict = FAIL` regardless of severity. WARNING is a FAIL condition — there is no distinction between WARNING and ERROR. The `severity` field in findings is informational only and does not affect the verdict cascade.

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
| FAIL reclassified to PASS | Verdict declared as PASS but upstream returned FAIL | Downgrade to FAIL |
| Disagreement suppressed | Auditor 1 = FAIL, Auditor 2 = PASS, consensus declared as PASS | Downgrade to FAIL |
| Hedging qualifiers | Evidence field contains "mostly", "generally", "largely", "essentially" | Downgrade to FAIL |
| Narrative override | Explanation cites "revision applied", "already fixed", "out of scope", "pragmatically", "intent satisfied" as justification | Downgrade to FAIL |

#### Self-Correction Protocol

When self-check finds violations:
- [ ] 1. Self-correct those criteria to FAIL
- [ ] 2. Add `self_corrections` array to the result contract documenting each correction and its detection signal
- [ ] 3. Recompute aggregate — any self-corrected FAIL cascades to `overall_verdict = FAIL`
- [ ] 4. Set `next_step = "remediate then re-audit"`

Self-correction means the cross-validate sub-agent caught itself in a protocol violation. This is documented, not hidden.

### Step 7: Dark Pattern Enforcement (MANDATORY — NO BYPASS)

Step 6 IS the completion step of cross-validation — it IS the definition of a valid result contract. An evaluation that skips dark pattern enforcement is INVALID without Step 6 enforcement. WE have determined that dark pattern detection is repository policy — it MANDATES enforcement for every verdict.

This step CANNOT contain a skip condition — Step 6 MUST proceed for ALL verdicts, PASS or FAIL. Sycophancy exploitation IS the ONLY context authorized to evaluate verdict agreement; any verdict that bypasses this step PROCEED DIRECTLY to result contract invalidation. The result contract MUST proceed through dark pattern enforcement before completion.

Before finalizing the result contract, scan ALL auditor verdicts, explanations, and remediation suggestions for the following dark patterns. If ANY dark pattern is detected, flag it in the result contract and set the affected criterion consensus to `FAIL` with remediation referencing the dark pattern. This is PROHIBITED to skip — repository policy MANDATES enforcement.

| Dark Pattern | Detection Signal | Remediation |
|---|---|---|
| Authority framing | Verdict or explanation references "as an expert", "in my professional opinion", "trust me" or other authority-without-evidence appeals | Strip authority language; require tool-call evidence per audit-006 |
| Goal hijacking | Verdict redefines the evaluation criterion, shifts scope beyond what the criterion specifies, or substitutes a different metric | Re-evaluate against original criterion only |
| Forced action | Verdict contains "you must", "you should", "it is critical that you" or other directive language prescribing implementation actions beyond the audit scope | Strip prescriptive language; verdict scope is evaluation ONLY |
| Sycophancy exploitation | Verdict agrees with the spec/plan author without independent evidence, or mirrors orchestrator-stated expectations | Require independent tool-call evidence per audit-006 |
| Continuity hooks | Verdict includes "next time", "in future iterations", "consider also" or other scope-expanding suggestions beyond the current criterion | Strip scope-expanding language; evaluate only current criterion |

### Step 6.5: Write Findings YAML to Disk

Write the full cross-validate findings YAML to `{project_root}/tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml`:

```yaml
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
upstream_artifact: "<artifact_path>"
summary:
  overall_verdict: PASS|FAIL
  next_step: "proceed|remediate then re-audit"
  total_criteria: N
  evidence_type_mismatches: N
  dark_pattern_violations: N
findings:
  - criterion_id: "SC-1"
    declared_evidence_type: "structural|string|semantic|behavioral"
    severity: "ERROR|WARNING"
    result: PASS
    evidence_type_mismatch: false
self_corrections:
  - criterion_id: "SC-N"
    detection_signal: "PASS + critique language: explanation contained 'should verify'"
    original_verdict: PASS
    corrected_verdict: FAIL
dark_pattern_violations: []
warnings: []
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

Create `{project_root}/tmp/{issue-N}/artifacts/` if needed (write tool creates implicitly). Use the `write` tool to persist the full YAML document.

### Step 8: Write judgment.yaml

Write final judgment to `./tmp/{issue-N}/artifacts/cross-validate/judgment.yaml`

## Remediation


### Step 7: Return Frugal YAML Result Contract

Return ONLY this YAML as the final response — no preamble, no commentary, no markdown fences:

```yaml
status: DONE
overall_verdict: PASS|FAIL
next_step: "proceed|remediate then re-audit"
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml"
summary: "N SCs: X agreed, Y disagreed, Z evidence_type_mismatch"
all_criteria_pass: false
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

When self-corrections are present, `overall_verdict` MUST be FAIL. Any single self-correction in any criterion cascades to overall FAIL.

The `next_step` field:
- `overall_verdict == PASS` → `next_step: "proceed"` (next pipeline continuation)
- `overall_verdict == FAIL` → `next_step: "remediate then re-audit"` (orchestrator routes to recovery)

## Context Required

- `spec_local_dir`: Local directory containing Markdown spec files
- `artifact_evidence_dir`: Path(s) to directories containing auditor YAML verdict artifacts


## Red Flags

- Never task() auditors from within cross-validate — the orchestrator dispatches auditors, cross-validate discovers artifacts via evidence dir
- Never leak orchestrator reasoning into verdict parsing — clean-room means evidence + criteria ONLY
- Never soft-pass a mismatch — `PASS`/`FAIL` split = FAIL per audit-004
- Never fabricate verdicts when auditor YAML artifact is unreadable or unparseable — missing data = FAIL per audit-005
- Never accept memory-cached claims as evidence — every verdict must reference a live tool call
- Never re-task an auditor after a FAIL verdict — FAIL stays FAIL
- Never resolve auditors inline — the DiMo role chain is dispatched by orchestrator before this task
- Never bypass dark pattern enforcement — Step 6 checks are MANDATORY per audit-013 through audit-018
- Never attempt recovery from BLOCKED status — Non-Recovery Gates are terminal per audit-017
- Never pass YAML verdict content inline through orchestrator context — verdict artifacts stay on disk; only artifact_path reaches orchestrator

## Cross-References

- `audit/SKILL.md` — skill-level operating protocol and enforcement rules
- `audit/tasks/completion.md` — halt guarantee
- `audit/SKILL.md` — DiMo role chain dispatch
- `065-verification-honesty.md` — live-source verification mandate, stale evidence prohibition
- `000-critical-rules.md` — clean-room task() protocol, orchestrator purity
- Spec #578, Plan #382

## Sub-Agent Routing

### Task Rules

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|---|
| `spec_local_dir`, `artifact_evidence_dir` | Implementation context, agent memory, orchestrator reasoning, prior verification, spec_body, evaluation_criteria, verdict content | N/A — cross-validate discovers artifacts via evidence dir, does not dispatch auditors | NO |
