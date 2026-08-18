
<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: verification-audit-arbiter

## Purpose

Produce the final verification-audit judgment in `judgment.yaml` with `next_step` by synthesizing upstream evidence, reasoning, and verdict artifacts. Synthesizes only — does not evaluate or second-guess upstream roles.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec Markdown files
- `artifact_evidence_dir`: Directory containing behavioral evidence artifacts from the implementation run
- `spec_issue_number`: Issue number for artifact path construction
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml` — MUST be present and non-empty. If absent: return BLOCKED with MISSING_EVIDENCE_YAML.
- `reasoning.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml` — MUST be present and non-empty. If absent: return BLOCKED with MISSING_REASONING_YAML.
- `verdict.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml` — MUST be present and non-empty. If absent: return BLOCKED with MISSING_VERDICT_YAML.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `artifact_evidence_dir` provided — MUST be present and non-empty
- `spec_issue_number` provided
- `github.owner`, `github.repo` available

## Exit Criteria

- All upstream artifacts read and cross-referenced
- Evaluator's per-criterion verdicts accepted as final — no re-evaluation
- Evidence type compliance verified against spec declarations
- Aggregate judgment computed: PASS iff ALL criteria have PASS
- `next_step` determined: `"proceed"` for PASS, `"remediate then re-audit"` for FAIL
- `judgment.yaml` written to `./tmp/{issue-N}/artifacts/verification-audit/judgment.yaml`
- No re-evaluation, no new evidence, no overruling of upstream roles
- Ticket status checked after PASS verdict: current status read via `./.opencode/tools/local-issues read --number <repo>#<N>`; review/PR-ready label or status transition applied via `./.opencode/tools/local-issues update --number <repo>#<N> --labels approved-for-review` only when the ticket is still in a pre-verification state

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove `judgment.yaml` if it exists from a prior run at `./tmp/{issue-N}/artifacts/verification-audit/judgment.yaml`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml` — read the file and confirm it is non-empty
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_YAML
missing: "./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml"
remediation: "evidence.yaml is required for verification-audit-path-provider. The Investigator must produce evidence.yaml before the Arbiter can synthesize the final judgment."
```

- [ ] 3. Verify `reasoning.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml` — read the file and confirm it is non-empty
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REASONING_YAML
missing: "./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml"
remediation: "reasoning.yaml is required for verification-audit-path-provider. The Validator must produce reasoning.yaml before the Arbiter can synthesize the final judgment."
```

- [ ] 5. Verify `verdict.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml` — read the file and confirm it is non-empty
- [ ] 6. If `verdict.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_VERDICT_YAML
missing: "./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml"
remediation: "verdict.yaml is required for verification-audit-path-provider. The Evaluator must produce verdict.yaml before the Arbiter can synthesize the final judgment."
```

- [ ] 7. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 8. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for verification-audit-path-provider. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 9. Verify `artifact_evidence_dir` is present and non-empty — glob for evidence files
- [ ] 10. If `artifact_evidence_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_DIR
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for verification-audit-path-provider. The orchestrator must provide a directory containing behavioral evidence artifacts from the implementation run."
```

### Step 2: Load Upstream Artifacts

Read all three upstream artifacts produced by the chain:

- [ ] 1. Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml` via `read` tool
- [ ] 2. Parse the evidence structure: `spec`, `evidence_artifacts`, `sc_evidence_map`
- [ ] 3. Extract the list of SCs with their declared evidence types and mapped evidence artifacts
- [ ] 4. Read `reasoning.yaml` from `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml` via `read` tool
- [ ] 5. Parse the reasoning structure: `sc_validation`, `artifact_metadata_validation`, `spec_metadata_validation`, `evidence_type_validation`, `issues`
- [ ] 6. Read `verdict.yaml` from `./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml` via `read` tool
- [ ] 7. Parse the verdict structure: `summary`, `per_criterion`, `remediation_required`
- [ ] 8. Record the `generated_at` timestamps from all three artifacts for provenance tracking

### Step 3: Load Spec Content

Read spec from `spec_local_dir/` to obtain the authoritative SC declarations:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool, read all discovered files
- [ ] 2. Extract SC table with evidence type declarations
- [ ] 3. Record each SC: ID, criterion text, declared evidence type

### Step 4: Cross-Reference Artifacts

Synthesize the upstream artifacts by cross-referencing their contents. Do NOT re-evaluate — verify consistency and completeness:

- [ ] 1. **SC coverage check** — For each SC in the spec, verify it appears in all three upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml). If an SC is missing from any artifact, flag as `MISSING_SC_COVERAGE`.
- [ ] 2. **Evidence chain integrity** — For each SC, verify the evidence chain is complete: evidence.yaml maps SC to artifacts → reasoning.yaml validates those artifacts → verdict.yaml evaluates the SC. If any link is broken, flag as `BROKEN_EVIDENCE_CHAIN`.
- [ ] 3. **Verdict consistency** — For each SC, verify the Evaluator's verdict is consistent with the Validator's validation. If the Evaluator produced PASS but the Validator flagged issues for that SC, flag as `VERDICT_VALIDATION_CONFLICT`.
- [ ] 4. **Evidence type alignment** — For each SC, verify the declared evidence type in the spec matches the evidence type used in the verdict. If the Evaluator used a lower-tier evidence method than the declared type requires, flag as `EVIDENCE_TYPE_MISMATCH`.
- [ ] 5. **Self-consistency downgrades** — If the Evaluator's `verdict.yaml` contains `self_consistency_downgrades`, accept those downgrades as final. Do NOT re-evaluate them.

Record synthesis results:

```yaml
synthesis:
  sc_coverage:
    - sc_id: "SC-1"
      in_evidence: true | false
      in_reasoning: true | false
      in_verdict: true | false
      coverage_complete: true | false
  evidence_chain:
    - sc_id: "SC-1"
      chain_complete: true | false
      broken_link: "<description or null>"
  verdict_consistency:
    - sc_id: "SC-1"
      evaluator_verdict: "PASS | FAIL"
      knowledge_supporter_issues: <N>
      consistent: true | false
      conflict_description: "<description or null>"
  evidence_type_alignment:
    - sc_id: "SC-1"
      spec_declared_type: "behavioral | semantic | string | structural"
      evaluator_used_type: "behavioral | semantic | string | structural"
      aligned: true | false
      mismatch_description: "<description or null>"
```

### Step 5: Compute Aggregate Judgment

Compute the final aggregate judgment from the Evaluator's per-criterion verdicts:

- [ ] 1. **Accept Evaluator's verdicts** — The Evaluator's per-criterion PASS/FAIL verdicts are final. Do NOT re-evaluate, re-interpret, or override them.
- [ ] 2. **Apply synthesis corrections** — If Step 4 found `EVIDENCE_TYPE_MISMATCH` or `VERDICT_VALIDATION_CONFLICT` for any criterion, downgrade that criterion's verdict to FAIL. These are synthesis-level corrections, not re-evaluations.
- [ ] 3. **Compute aggregate** — `overall_verdict = PASS` iff ALL criteria have PASS after synthesis corrections. Any single FAIL cascades to `overall_verdict = FAIL`.
- [ ] 4. **Determine next_step**:
   - `overall_verdict == PASS` → `next_step: "proceed"`
   - `overall_verdict == FAIL` → `next_step: "remediate then re-audit"`

### Step 6: Assemble judgment.yaml

Assemble the final judgment structure:

```yaml
judgment:
  generated_at: "<ISO timestamp>"
  spec_issue_number: <N>
  evidence_source: "./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml"
  reasoning_source: "./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml"
  verdict_source: "./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml"
  evidence_generated_at: "<timestamp from evidence.yaml>"
  reasoning_generated_at: "<timestamp from reasoning.yaml>"
  verdict_generated_at: "<timestamp from verdict.yaml>"
  synthesis:
    sc_coverage: [...]
    evidence_chain: [...]
    verdict_consistency: [...]
    evidence_type_alignment: [...]
  summary:
    total_criteria: <N>
    pass: <N>
    fail: <N>
    synthesis_downgrades: <N>
    all_criteria_pass: false | true
  per_criterion:
    - criterion_id: "SC-N"
      evaluator_verdict: "PASS | FAIL"
      synthesis_correction: "<description or null>"
      final_verdict: "PASS | FAIL"
      explanation: "<synthesized explanation>"
      remediation: "<remediation from evaluator or synthesis correction>"
      next_step: "proceed | remediate"
  overall_verdict: "PASS | FAIL"
  next_step: "proceed | remediate then re-audit"
  remediation_required: false | true
```

### Step 7: Write judgment.yaml

Write the assembled judgment structure to `./tmp/{issue-N}/artifacts/verification-audit/judgment.yaml`:

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p ./tmp/{issue-N}/artifacts/verification-audit/`
- [ ] 2. Write `judgment.yaml` with the complete judgment structure
- [ ] 3. Verify the file was written and is non-empty

### Step 8: Ticket Status Reconciliation

After an overall PASS verdict, BEFORE reporting the PASS verdict, read the ticket's current status and update it to reflect the verified-complete state if an update is warranted. **The read is a mandatory precondition for any update. You MUST perform the `local-issues read` first and record the current status and labels from its output before any decision — you may NOT assume, recall, or infer the ticket's status from earlier context, memory, or conversation. If you have not just performed a successful `local-issues read` in this step, you MUST NOT perform an update, and you MUST NOT report completion.**

> **MANDATORY — do NOT skip.** This step runs via the `local-issues` CLI (`.opencode/tools/local-issues`) against the local `.issues/` worktree. It does NOT require a git remote, GitHub credentials, or a remote issue tracker. A local-only repo, a test environment, or a missing/absent remote is NOT a valid reason to skip the status read and update. If the ticket is in a pre-verification state and the verdict is PASS, you MUST perform BOTH the read and the update. Skipping this step makes the audit result INVALID (see Completion Dependency Chain).

- [ ] 1. **Read current ticket status — MUST run first** — Execute the `local-issues` read command now and base the update decision ONLY on its output: `./.opencode/tools/local-issues read --number <repo>#<N>` (the `--number` flag is required; the qualified `<repo>#<N>` form is accepted for reads, and a bare `--number <N>` also works when the repo qualifier is unknown). Capture and record the current `status` field and the labels array from the actual command output.
- [ ] 2. **Evaluate whether an update is warranted** — Using ONLY the status and labels read in step 1, an update is warranted when the ticket is still in a pre-verification state: `status: open` combined with the absence of a review/PR-ready marker (e.g., no `approved-for-review`, `approved-for-pr`, or equivalent review/PR-ready label in the labels array).
- [ ] 3. **Update only when warranted and PASS** — When `overall_verdict == PASS` AND step 2 determined an update is warranted, transition the ticket to the verified-complete state: apply the review/PR-ready label (e.g., `approved-for-review`) via the `local-issues` CLI: `./.opencode/tools/local-issues update --number <repo>#<N> --labels approved-for-review` (the `--number` flag is required and mutations MUST use the qualified `{repo}#{N}` form). Confirm the update succeeded (exit 0, `updated: true`).
- [ ] 4. **Skip when already correct** — When the read in step 1 shows the ticket already carries the review/PR-ready marker, or `overall_verdict != PASS`, do NOT update the ticket status. **An already-present review/PR-ready label is a skip condition — do NOT re-apply it.** A FAIL verdict leaves the ticket in its current state pending remediation. When skipping, record the reason in the result contract, citing the label observed in the step 1 read.

### Step 9: Return Frugal Result Contract

Return only routing-significant data:

```yaml
status: DONE | FAIL | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/verification-audit/judgment.yaml"
summary: "{total_criteria} criteria. {pass} PASS, {fail} FAIL. {synthesis_downgrades} synthesis downgrades."
overall_verdict: "PASS | FAIL"
next_step: "proceed | remediate then re-audit"
all_criteria_pass: false | true
remediation_required: false | true
status_checked: false | true
status_updated: false | true
ticket_status: "<current ticket status or label state>"
```

## Result Contract

```yaml
status: DONE | FAIL | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/verification-audit/judgment.yaml"
summary: "{total_criteria} criteria. {pass} PASS, {fail} FAIL. {synthesis_downgrades} synthesis downgrades."
overall_verdict: "PASS | FAIL"
next_step: "proceed | remediate then re-audit"
all_criteria_pass: false | true
remediation_required: false | true
status_checked: false | true
status_updated: false | true
ticket_status: "<current ticket status or label state>"
```

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml absent | Return BLOCKED with MISSING_EVIDENCE_YAML |
| evidence.yaml empty or unparseable | Return BLOCKED with UNPARSEABLE_EVIDENCE_YAML |
| reasoning.yaml absent | Return BLOCKED with MISSING_REASONING_YAML |
| reasoning.yaml empty or unparseable | Return BLOCKED with UNPARSEABLE_REASONING_YAML |
| verdict.yaml absent | Return BLOCKED with MISSING_VERDICT_YAML |
| verdict.yaml empty or unparseable | Return BLOCKED with UNPARSEABLE_VERDICT_YAML |
| spec_local_dir absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| artifact_evidence_dir absent | Return BLOCKED with MISSING_EVIDENCE_DIR |
| artifact_evidence_dir empty | Return BLOCKED with MISSING_EVIDENCE_DIR |
| SC in spec not found in verdict.yaml | Flag as MISSING_SC_COVERAGE in synthesis — do NOT BLOCK |
| Evidence chain broken for an SC | Flag as BROKEN_EVIDENCE_CHAIN in synthesis — do NOT BLOCK |
| Verdict-validation conflict detected | Downgrade to FAIL in synthesis — do NOT BLOCK |
| Evidence type mismatch detected | Downgrade to FAIL in synthesis — do NOT BLOCK |
| Write permission denied | Return BLOCKED — cannot write judgment.yaml |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Spec Content → INVALID if skipped
- [ ] 4. Cross-Reference Artifacts → INVALID if skipped
- [ ] 5. Compute Aggregate Judgment → INVALID if skipped
- [ ] 6. Assemble judgment.yaml → INVALID if skipped
- [ ] 7. Write judgment.yaml → INVALID if skipped
- [ ] 8. Ticket Status Reconciliation → INVALID if skipped
- [ ] 9. Return Frugal Result Contract → INVALID if skipped

## Cross-References

- `tasks/verification-audit-investigator.md` — Investigator role (produces evidence.yaml consumed by this task)
- `tasks/verification-audit-validator.md` — Validator role (produces reasoning.yaml consumed by this task)
- `tasks/verification-audit-evaluator.md` — Evaluator role (produces verdict.yaml consumed by this task)
- Read [cost-model-standards.md](reference/cost-model-standards.md) — canonical evidence-type taxonomy and enforcement matrix
- Read [implementation-workflow reference card](skills/writing-plans/reference/implementation-workflow.md) — Trigger Dispatch Table (dispatches verification-audit)
- Read [000-critical-rules.md](guidelines/000-critical-rules.md) — behavioral evidence mandate, hard failure discipline
- Read [065-verification-honesty.md](guidelines/065-verification-honesty.md) — live-source verification mandate, stale evidence prohibition

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
