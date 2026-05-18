<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-audit

## Purpose

Audit a spec for quality, structure, and completeness using dual-adversarial cross-validation. Each criterion is independently verified by two cross-family auditors with clean-room context.

## Entry Criteria

- Spec issue number provided OR spec content provided
- `github.owner`, `github.repo` available
- Audit phase context: `audit_phase: spec_creation`
- Optional: `failure_description` from prior implementation attempt (triggers enhanced determinism evaluation)

## Exit Criteria

- All subtask criteria evaluated with PASS/FAIL consensus
- Bidirectional findings reported
- Executive summary generated

## Procedure

### Step 1: Load Spec Content

Fetch spec via GitHub MCP if issue number provided:
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
| SC-DET | SC Determinism | Each SC produces the same PASS/FAIL from any reasonable auditor |

### Step 3: Cross-Validate with Pre-Resolved Verdicts

This task does NOT dispatch auditors. The orchestrator dispatches auditors and passes pre-resolved `auditor_verdicts` to this task. Invoke `cross-validate` with verdicts already available:

```python
task(
    subagent_type="general",
    prompt="""Use adversarial-audit skill --task cross-validate with:

evidence_payload: <spec_body>
evaluation_criteria: <criteria_json>
audit_phase: spec_creation
auditor_verdicts: <auditor_verdicts>
authorization_scope: <authorization_scope>
halt_at: <halt_at>
pr_strategy: <pr_strategy>
pipeline_phase: <pipeline_phase>

worktree.path: <worktree.path>
github.owner: <github.owner>
github.repo: <github.repo>

failure_description: <failure_description>  # Optional — provided when routed from remediation loop

Mandatory: cross-validate receives pre-resolved verdicts — it does NOT dispatch auditors.
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

```json
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

### Step 6: Build Result Contract

```json
{
  "status": "DONE",
  "audit_type": "spec-audit",
  "auditor_1": { "type": "auditor-<model>", "family": "<family>" },
  "auditor_2": { "type": "auditor-<model>", "family": "<family>" },
  "cross_validation": [
    {
      "criterion_id": "SC-1",
      "description": "Problem statement present",
      "auditor_1_result": "PASS",
      "auditor_2_result": "PASS",
      "consensus": "PASS",
      "evidence": "<tool-call reference>"
    }
  ],
  "overall_consensus": "PASS | FAIL",
  "disagreements": [],
  "bidirectional_findings": [],
  "exec_summary": "Spec audit: {pass_count}/{total} criteria passed. Consensus: {overall}."
}
```

## Dispatch Mandate (CRITICAL — per critical-rules-048)

This task is a **reference document** that defines evaluation criteria and result contracts. The orchestrator is responsible for:
1. Dispatching a sub-agent for `resolve-models` to obtain auditor pair
2. Dispatching auditor sub-agents in parallel
3. Dispatching a sub-agent for `cross-validate` with pre-resolved `auditor_verdicts`

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