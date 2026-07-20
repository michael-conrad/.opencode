## Problem

The plan writer (`writing-plans`) produced a deficient plan for #1370 with three defects that the plan-fidelity auditor partially detected but the orchestrator soft-passed. Root cause analysis identified gaps in both the plan writer and auditor skills:

1. **Per-phase step numbering restart** — each phase restarts at step 1 instead of global sequential numbering across the entire plan file
2. **Missing mandatory pipeline gates** — implementation-pipeline gate steps (coherence gate, pre-red-baseline, post-red-enforcement, post-green-enforcement, checkpoint-tag-create, structural-checks, green-vbc, adversarial-audit, cross-validate, regression-check, review-prep, exec-summary) were omitted because the plan writer judged them "not needed"
3. **Soft-passed FAIL verdicts** — the orchestrator received FAIL from the plan-fidelity auditor but reclassified it as "core SCs all PASS" instead of remediating

## Root Cause

### writing-plans/tasks/create.md
- Plan Format Requirements (line 78) says "Sequential numbered steps with dispatch indicators" per phase but does NOT specify global sequential numbering
- Exit criteria spec (line 85) says "Numbered checklist C1 through C{N}" but does NOT mandate that the checklist must enumerate all implementation-pipeline gate steps
- No rule prohibits optimizing out mandatory pipeline steps

### writing-plans/tasks/validate.md
- Validation checks (lines 9-18) include "Completeness" and "Actionability" but no check for pipeline-gate completeness or global numbering

### adversarial-audit/tasks/plan-fidelity.md
- PF-SEQUENCE-MATCHES (line 102) exists and correctly flagged the deficiency, but the criterion is not hardened to be an automatic FAIL with no remediation path
- No PF criterion checks for global sequential numbering

### adversarial-audit/tasks/cross-validate.md
- The cross-validate task has strong FAIL-is-terminal language (lines 219-235) but the frugal contract output (lines 385-391) and artifact YAML (lines 340-377) do not include a mandatory "remit for mandatory remediation" field in non-PASS outputs
- The default assumption is not explicitly stated as FAIL

### adversarial-audit/tasks/verification-audit.md, spec-audit.md, concern-separation.md
- Frugal contract outputs (Step 9/Step 7/Step 8) and artifact YAML templates do not include mandatory remediation language for non-PASS results
- Default assumption is not explicitly FAIL

## Fix

### 1. writing-plans/tasks/create.md — Plan format requirements

Add to Required Sections (after line 85):

```
7. **Global sequential numbering** — Steps are numbered sequentially across the entire plan file. Each phase does NOT restart at 1. The first step of Phase 2 continues from the last step of Phase 1.
```

Add to Prohibited Patterns (after line 106):

```
- **No omitted mandatory gates** — All implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` dispatch routing table are mandatory. No step may be omitted because the plan writer judges it "not needed." If a step appears unnecessary, include it anyway — the cost of an extra step is negligible compared to the cost of rework from a skipped step.
```

Add to Exit Criteria (after line 50):

```
- **C{N}.** All implementation-pipeline gate steps enumerated in exit criteria or phase structure
- **C{N}.** Step numbering is globally sequential across all phases
```

### 2. writing-plans/tasks/validate.md — Add validation checks

Add after line 18:

```
- [ ] 11. **Pipeline-gate completeness** — All implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` dispatch routing table are present in the plan's exit criteria or phase structure
- [ ] 12. **Global sequential numbering** — Step numbering is globally sequential across the entire plan file, not restarted per phase
```

### 3. writing-plans/SKILL.md — Mandatory Task Discipline

Add to Mandatory Task Discipline (after line 21):

```
- [ ] 6. **No optimizing out mandatory steps** — All implementation-pipeline gate steps are mandatory regardless of perceived simplicity. Optimizing out steps because they appear "not needed" is defective behavior and produces plans that must be discarded as incomplete and error-ridden.
```

### 4. adversarial-audit/tasks/plan-fidelity.md — Add PF criterion and harden

Add after line 101 (PF-SEQUENCE-MATCHES):

```
| PF-GLOBAL-NUMBERING | Steps numbered globally across all phases | No per-phase restart — step N+1 follows step N across phase boundaries |
```

Harden PF-SEQUENCE-MATCHES description (line 102) to:

```
| PF-SEQUENCE-MATCHES | Gate sequence matches pipeline source — missing gates are automatic FAIL with no remediation path | Gate sequence matches `implementation-pipeline/SKILL.md` dispatch routing table — read dynamically, not hardcoded. Any missing gate is automatic FAIL — the plan MUST be regenerated, not patched. |
```

### 5. All auditor tasks (cross-validate.md, verification-audit.md, spec-audit.md, concern-separation.md) — Hard FAIL coercion

#### 5a. Frugal contract output — add mandatory remediation field

In every auditor task's "Return Frugal Result Contract" section, change the output template to include a `mandatory_remediation` field when status is not PASS:

```yaml
status: DONE
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-audit-{type}-{STATUS}-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

The `mandatory_remediation` field MUST be present when `status` is not a clean PASS. It MUST contain the exact text: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."

#### 5b. Artifact YAML — add mandatory remediation note

In every auditor task's "Write Verdict Artifact to Disk" section, add to the YAML template:

```yaml
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

This field MUST be present in the artifact YAML when the verdict is not a clean PASS.

#### 5c. Default assumption is FAIL

Add to every auditor task's Purpose or Entry Criteria section:

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) live tool-call evidence, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) both auditors independently agree.

#### 5d. Cross-validate specific — mandatory remediation in output

In `cross-validate.md`, add to the frugal contract (Step 7, lines 385-391):

```yaml
status: DONE
overall_consensus: PASS|FAIL
next_step: "proceed|remediate then re-audit"
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml"
summary: "N SCs: X agreed, Y disagreed, Z evidence_type_mismatch"
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

And in the artifact YAML (Step 6.5, lines 340-377), add:

```yaml
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `writing-plans/tasks/create.md` updated with global sequential numbering requirement, mandatory gates prohibition, and pipeline-gate exit criteria | structural | `grep` for "Global sequential numbering", "No omitted mandatory gates", and pipeline-gate exit criteria in `writing-plans/tasks/create.md` |
| SC-2 | `writing-plans/tasks/validate.md` updated with pipeline-gate completeness and global numbering validation checks | structural | `grep` for "Pipeline-gate completeness" and "Global sequential numbering" in `writing-plans/tasks/validate.md` |
| SC-3 | `writing-plans/SKILL.md` updated with "No optimizing out mandatory steps" mandate | structural | `grep` for "No optimizing out mandatory steps" in `writing-plans/SKILL.md` |
| SC-4 | `adversarial-audit/tasks/plan-fidelity.md` updated with PF-GLOBAL-NUMBERING criterion and hardened PF-SEQUENCE-MATCHES | structural | `grep` for "PF-GLOBAL-NUMBERING" and "automatic FAIL" in `plan-fidelity.md` |
| SC-5 | All auditor task files (cross-validate, verification-audit, spec-audit, concern-separation) updated with hard FAIL coercion: default FAIL assumption, mandatory_remediation field in frugal contract and artifact YAML | structural | `grep` for "Default assumption: FAIL" and "Remit for mandatory remediation" in each of the 4 task files |
| SC-6 | Cross-validate task file updated with mandatory_remediation field in both frugal contract and artifact YAML | structural | `grep` for "mandatory_remediation" in `cross-validate.md` |

## Labels

`[SPEC-FIX]`, `plan`, `audit`
