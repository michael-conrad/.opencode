<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-audit

## Purpose

Audit a spec for quality, structure, and completeness using dual-adversarial cross-validation. Each criterion is independently verified by two cross-family auditors with clean-room context.

## Entry Criteria

- `spec_local_dir` provided (local issue directory containing spec.md)
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- Audit phase context: `audit_phase: spec_creation`
- Optional: `artifact_evidence_dir` (behavioral evidence directory, single or list)
- Optional: `failure_description` from prior implementation attempt (triggers enhanced determinism evaluation)

## Exit Criteria

- All subtask criteria evaluated with PASS/FAIL consensus (no INCONCLUSIVE verdicts)
- Bidirectional findings reported
- Executive summary generated

## Procedure

### Step 1: Load Spec Content

Read spec from `spec_local_dir/spec.md` when `spec_local_dir` is provided:
1. Read `<spec_local_dir>/spec.md` via `read` tool
2. Extract spec body and metadata
3. If `spec_local_dir` is a list, read each entry's `spec.md`, extract SCs from each, perform interdependency analysis (overlaps, conflicts, independences)

Fallback to GitHub fetch only when `spec_local_dir` is absent:
```bash
issue-operations -> read-issue (github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=<N>) <!-- Routes through issue-operations per SPEC #683 -->
```

Extract spec body and metadata.

### Step 2: Build Evaluation Criteria

Define audit criteria based on spec-auditor task structure:

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| SC-1 | Problem statement present | Non-empty problem statement section |
| SC-2 | Success criteria measurable | Each criterion has verification method |
| SC-3 | Phases well-structured | Clear phase boundaries |
| SC-4 | Steps actionable | Each step has file path or task |
| SC-5 | Dependencies identified | Phase dependencies documented |
| SC-6 | Concerns separated | Single concern per phase |
| SC-7 | Fidelity maintained | Plan matches spec |
| SC-8 | Operational clarity | Edge cases and error recovery defined |
| SC-9 | Determinism achieved | Repeatable execution path |
| SC-10 | Prose structure valid | Headers, lists, tables properly formatted |
| SC-11 | Documentation Sources present and populated | Non-empty Documentation Sources section with live-source verification evidence |
| SC-12 | Preamble present | "## Intent and Executive Summary" section with all 5 fields (Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions) present for standard+ specs; omitted is acceptable for minimal specs only. Missing preamble for a standard+ spec is a SPEC-PRODUCER defect, not a reviewer oversight — the spec producer owns the omission regardless of whether downstream gates caught it. |
| SC-13 | Cost-frame prose + runtime execution in SCs | Each SC carries cost-frame reformation language and requires a real test execution command, not a structural check |
| SC-STRUCTURAL-FAIL | Structural evidence rejected for behavioral SCs | If an SC describes testable behavior (correctness, output, result, pass/fail, runtime logic) but verification evidence is purely structural (grep/read/file-exists), return FAIL with `STRUCTURAL_EVIDENCE` classification. **SC-STRUCTURAL-FAIL uplift:** When auditing spec SCs, if a change affects runtime behavior, classify the SC evidence type as `behavioral` regardless of declared type. See `guidelines/000-critical-rules.md` §critical-rules-BEH-EV. Structural checks do NOT verify correct behavior — they only verify existence. Exception: non-testable prose changes (docs, runbooks, guidelines) may use semantic intent verification by direct AI agent read — NOT grep/pattern matching. |
| SC-EVIDENCE-TYPE | Evidence type matches declared type | For each SC, the auditor MUST check the declared evidence type and verify using the minimum acceptable method: `structural` → file existence; `string` → grep/pattern; `semantic` → sub-agent read + judgment; `behavioral` → test execution with output inspection. If the declared evidence type is `behavioral` and the auditor provides structural evidence only, the verdict MUST be FAIL with `EVIDENCE_TYPE_MISMATCH`. If the declared type is `semantic` and the auditor provides string-only evidence, the verdict MUST be FAIL with `EVIDENCE_TYPE_MISMATCH`. Default to `string` if no evidence type is declared. |
| SC-DET | SC Determinism | Each SC produces the same PASS/FAIL from any reasonable auditor |
| SC-14 | SC Enforcement Gate present and explicit | Spec contains all-or-nothing gate statement with PASS/FAIL/Remediation requirements per gate format |

<!-- Fragment ID: sc-enforcement-gate -->

### Step 3: Cross-Validate with Pre-Resolved Verdicts

This task does NOT dispatch auditors. The orchestrator dispatches auditors and passes pre-resolved `auditor_artifact_paths` to this task. Invoke `cross-validate` with artifact paths already available:

When dispatching auditors, the `evaluation_criteria` array MUST include each SC's `evidence_type` field. Auditors MUST use the declared evidence type to determine their verification method. For `behavioral` SCs, auditors MUST require execution evidence (test output, stderr) — not file existence. This is enforced by the cross-validate evidence type gate (per `cross-validate.md` §Evidence Type Gate). Each auditor writes its full YAML verdict to disk and returns a frugal contract. The orchestrator collects artifact paths and passes them to cross-validate.

```python
task(
    subagent_type="general",
    prompt="""Use adversarial-audit skill --task cross-validate with:

spec_issue_number: <spec_issue_number>
audit_phase: spec_creation
auditor_artifact_paths: <auditor_artifact_paths>
authorization_scope: <authorization_scope>
halt_at: <halt_at>
pr_strategy: <pr_strategy>
pipeline_phase: <pipeline_phase>

worktree.path: <worktree.path>
github.owner: <github.owner>
github.repo: <github.repo>

failure_description: <failure_description>  # Optional — provided when routed from remediation loop

Mandatory: cross-validate receives pre-resolved artifact paths and reads YAMLs from disk — it does NOT dispatch auditors.
"""
)
```

**When `failure_description` is provided:** The spec auditor must evaluate whether the SCs are deterministic and testable specifically in light of the failure evidence. The evaluation should answer: "Would this SC have prevented the observed failure if it were properly deterministic?" or "Is the failure attributable to a non-deterministic SC?" If yes, return SPEC_GAP with revision recommendation. If no (SCs are deterministic but the implementer failed), return confirmation that implementation failure is the root cause.

### Step 4: Process Verdicts

For each criterion:
- Both auditors PASS → criterion consensus PASS
- Either auditor FAIL → criterion consensus FAIL
- Auditors disagree → mark as DISAGREE, present bidirectional finding

### Step 4.5: Evaluate SC Determinism (SC-DET)

For each success criterion in the spec, evaluate determinism:

- Can two reasonable auditors independently produce the same PASS/FAIL result?
- Does the SC contain any fail patterns (adverbs without thresholds, comparatives without baselines, open-ended quality, missing expected values, implicit behavior)?
- Can an executable verification command be written for this SC?

**If any SC would produce INCONCLUSIVE from any reasonable auditor**, flag that SC as `SPEC_GAP` and include a revision recommendation that specifies:
1. Which fail pattern(s) the SC contains
2. What a deterministic rewrite would look like
3. An example executable verification command

**Result format:**

```yaml
{
  "criterion_id": "SC-DET",
  "description": "SC Determinism",
  "deterministic_scs": ["SC-1", "SC-2", ...],
  "non_deterministic_scs": [
    {
      "sc_id": "SC-N",
      "fail_pattern": "missing_expected_values",
      "revision_recommendation": "...",
      "executable_verification": "..."
    }
  ],
  "consensus": "PASS | FAIL",
  "evidence": "<tool-call reference>"
}
```

### Step 5: Generate Bidirectional Findings

For FAIL/DISAGREE criteria:

| Finding Type | Direction | Description |
|-------------|-----------|-------------|
| SPEC_INCOMPLETE | spec→code | Spec missing required element |
| SPEC_AMBIGUOUS | spec↔code | Spec open to interpretation |
| SPEC_OUTDATED | code→spec | Implementation diverged from spec |
| SPEC_OVERSPECIFIED | spec→code | Spec constrains implementation unnecessarily |

Present revision options for developer decision.

### Step 6: Write Verdict Artifact to Disk

Write the full YAML verdict artifact to `./tmp/artifacts/pipeline-{issue_number}-audit-spec-audit-{STATUS}-{timestamp}.yaml`:

```yaml
audit_phase: spec_creation
auditor_type: spec-audit
family: <family>
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
summary:
  total_criteria: N
  pass: N
  fail: N
per_criterion:
  - criterion_id: "SC-1"
    declared_evidence_type: "string"
    result: "PASS"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: ""
    next_step: "proceed"
    tool_calls_made:
      - read
      - grep
```

### Step 7: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "./tmp/artifacts/pipeline-{issue_number}-audit-spec-audit-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
```

## Dispatch Mandate (CRITICAL — per critical-rules-048)

This task is a **reference document** that defines evaluation criteria and result contracts. The orchestrator is responsible for:
1. Dispatching a sub-agent for `resolve-models` to obtain auditor pair
2. Dispatching auditor sub-agents in parallel
3. Dispatching a sub-agent for `cross-validate` with pre-resolved `auditor_artifact_paths`

This task MUST NOT be read and executed inline. Reading this file and performing the described steps via raw tool calls is a CRITICAL VIOLATION per critical-rules-048.

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

1. Load spec content → INVALID if skipped
2. Build evaluation criteria → INVALID if skipped
3. Cross-validate with verdicts → INVALID if skipped
4. Process verdicts → INVALID if skipped
5. Evaluate SC determinism → INVALID if skipped
6. Generate bidirectional findings → INVALID if skipped
7. Build result contract → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After spec-audit completes:
- If consensus PASS: proceed to `concern-separation` or next pipeline step
- If consensus FAIL: remediate findings, then re-audit (resolve-models → auditors → cross-validate)

This step is MANDATORY — the pipeline does not terminate early.

## Error Handling

| Error | Action |
|-------|--------|
| Spec issue not found | Return BLOCKED with issue number |
| Spec body empty | Return FAIL for SC-1, continue remaining |
| Cross-validate fails | Return OVERFLOW, log error |
| Auditor unavailable | Use fallback chain per multimodal-dispatch |

## Cross-References

- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
- `tasks/resolve-models.md` — cross-family selection (orchestrator dispatches, then passes results)
- `spec-auditor/SKILL.md` — original task breakdown
- `spec-auditor/tasks/fidelity.md` — plan fidelity check
- `000-critical-rules.md` — co-authored requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: spec-audit-001
    title: "Dual auditors required — no single-auditor evaluation"
    conditions:
      all: ["auditor_count < 2"]
    actions: [HALT, RESOLVE_SECOND_AUDITOR]
    source: "spec-audit.md §Step 3"

  - id: spec-audit-002
    title: "Clean-room task() — no orchestrator reasoning leaked to auditors"
    conditions:
      all: ["auditor_context contains 'expected' OR 'should' OR 'correct'"]
    actions: [HALT, STRIP_BIASED_CONTEXT]
    source: "spec-audit.md §Step 3"

  - id: spec-audit-003
    title: "Disagreement requires bidirectional finding"
    conditions:
      all: ["auditor_1_result != auditor_2_result", "bidirectional_finding == null"]
    actions: [APPEND_BIDIRECTIONAL_FINDING]
    source: "spec-audit.md §Step 5"

  - id: spec-audit-004
    title: "Documentation Sources section required and populated"
    conditions:
      all: ["doc_sources_missing_or_empty == true"]
    actions: [FAIL_CRITERION(SC-11)]
    source: "spec-audit.md §Step 2"
```