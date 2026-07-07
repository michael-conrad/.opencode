<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-audit

## Purpose

Audit a spec for quality, structure, and completeness. Each criterion is evaluated against the spec's declared evidence types with clean-room context.

> **DiMo Role: Evaluator.** This task evaluates spec quality. Reads `evidence.yaml` (Generator), validates evidence → writes `reasoning.yaml`, evaluates → writes `verdict.yaml`.
>
> **Role Identity:** You are the Evaluator. You own the PASS/FAIL verdict for each criterion.
>
> **You own:** Per-criterion PASS/FAIL verdicts. **You do NOT own:** Final judgment, next_step decisions, evidence validation.
>
> **Brightline rules:**
> - MUST produce a binary PASS or FAIL for every criterion — no hedging, no "PASS with concerns"
> - MUST NOT defer to upstream roles — the verdict is yours alone
> - MUST NOT re-evaluate evidence that Knowledge Supporter already validated
> - MUST write `verdict.yaml` as the primary output artifact
>
> **Success:** Every criterion has a definitive PASS or FAIL. No caveats, no deferred decisions, no re-validation.

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against evidence.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch. The orchestrator MUST verify `spec_local_dir` is a valid directory before dispatching any auditor. If the spec is only on GitHub (not locally mirrored), the orchestrator MUST mirror it as .md files in `spec_local_dir/` first. Dispatching without a valid `spec_local_dir` is a CRITICAL VIOLATION.
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- Optional: `artifact_evidence_dir` (behavioral evidence directory, single or list)
- Optional: `failure_description` from prior implementation attempt (triggers enhanced determinism evaluation)

## Exit Criteria

- All subtask criteria evaluated with PASS/FAIL consensus (no INCONCLUSIVE verdicts)
- Bidirectional findings reported
- Executive summary generated

## Procedure

## Spec Audit Checklist

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/spec-audit/`
- [ ] 1. Pre-Flight Validation Gate — validate required inputs before proceeding
- [ ] 2. Load Spec Content — glob spec_local_dir for .md files, read all
- [ ] 3. Verify Documentation Sources — research each cited URL, API reference, or documentation claim against live sources
- [ ] 4. Build Evaluation Criteria — define SC table with evidence types
- [ ] 4a. Evaluate Semantic Auditor Criteria (SC-SEM) — evaluate skill card description quality (skip if not a skill card audit)
- [ ] 5. Process Verdicts — per-criterion PASS/FAIL consensus
- [ ] 6. Evaluate SC Determinism (SC-DET) — check each SC for determinism
- [ ] 7. Generate Bidirectional Findings — FAIL/DISAGREE criteria with revision options
- [ ] 8. Write verdict.yaml — write verdict to `./tmp/{issue-N}/artifacts/spec-audit/verdict.yaml`
- [ ] 9. Return Frugal Result Contract

### Step 0a: Knowledge Supporter — Validate Evidence

- [ ] 0a. Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/{task-name}/evidence.yaml`
- [ ] 0b. Validate each evidence item against source data — check accuracy, completeness, relevance
- [ ] 0c. Write validated evidence to `./tmp/{issue-N}/artifacts/{task-name}/reasoning.yaml`

### Step 0: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with the audit:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for spec-audit. The orchestrator must provide a valid local directory containing spec Markdown files."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately — no globbing, no reading, no analysis.

### Step 1: Load Spec Content

`spec_local_dir` is REQUIRED. Auditors mandate this directory and BLOCK if absent. The orchestrator MUST provide a valid local path before dispatching.

Read spec from `spec_local_dir/`:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool, read all discovered files
- [ ] 2. Extract spec body and metadata from each
- [ ] 3. If `spec_local_dir` is a list, glob each entry's `**/*.md`, extract SCs from each, perform interdependency analysis (overlaps, conflicts, independences)

Auditors return BLOCKED with `SPEC_NOT_FOUND` if `spec_local_dir` is absent.

### Step 2: Verify Documentation Sources Against Live Sources

For each URL, API reference, or documentation claim in the spec (including any `Documentation Sources` section), verify against live sources:

- [ ] 1. Fetch each URL using `webfetch` — verify the page exists and contains the referenced content
- [ ] 2. For API documentation claims: use `srclight_get_signature` or official docs to verify function signatures, parameter names, and behavior
- [ ] 3. For environment variables: check `.env.example` or config schema
- [ ] 4. For library/framework patterns: verify against official release docs or changelogs

Record per-reference results:

```yaml
documentation_verification:
  - source: "<URL or reference>"
    verified: true | false
    method: "webfetch | srclight | read"
    finding: "Source confirms claim" | "Source not found" | "Content mismatch"
```

If any source cannot be verified, flag the finding and include in the SC-11 (Documentation Sources) evaluation. Claims verified by tool-call evidence PASS; unverified claims receive a FAIL with the specific discrepancy.

### Step 3: Build Evaluation Criteria

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
| SC-DET-AMBIGUITY | Either/or ambiguity in Required Actions | Scans Required Actions for "or", "either", "alternatively" patterns. If any Required Action contains an unresolved either/or choice presenting two or more possible outcomes, the criterion FAILs. |
| SC-14 | SC Enforcement Gate present and explicit | Spec contains all-or-nothing gate statement with PASS/FAIL/Remediation requirements per gate format |
| SC-TRACKING-LANG | No tracking/status language in spec | Zero instances of "implemented", "pending", "confirmed", "viable", "completed" used as status markers. Only forward-looking "MUST be" language permitted. |
| SC-PRESCRIPTIVE-CODE | No prescriptive code content in spec | Spec uses file area references only (agent discovers exact paths). Zero instances of exact file paths with line numbers, exact import strings, or exact assertion code. |
| SC-PIPELINE-GATES | Pipeline gates use canonical checklist format, not gate tables | Spec requires numbered `- [ ] N.` checklist steps with dispatch mode indicators (`(**clean-room**)` or `(**inline**)`). Gate tables (per-unit or shared cross-reference) → VIOLATION. Expect dispatch indicators in every step title. |
| SC-CANONICAL-PLAN-FORM | Plan output format uses canonical checklist format | If the spec defines plan output format requirements, validate they use the canonical checklist format: numbered `- [ ] N.` with sub-bullet metadata, dispatch mode indicators, no dispatch tables, no shared cross-references. |
| SC-ADMONISHMENT | Mandatory Task Discipline admonishment present in SKILL.md | For skill card audits, verify the SKILL.md contains the 5-item Mandatory Task Discipline admonishment after Overview and before Trigger Dispatch Table. For task card audits, verify the 4-item (non-inline) or 3-item (inline) Task Discipline admonishment after Purpose and before Operating Protocol. |
| SC-SEM-001 | Unambiguous dispatch condition | Does the description unambiguously tell an agent when to invoke this skill? Sub-agent reads the description and the Trigger Dispatch Table, judges whether the description provides clear dispatch conditions. **Severity: ERROR.** Failure: description is ambiguous about when to invoke (e.g., "Use when working with data" is too vague). |
| SC-SEM-002 | Mandatory invocation signal | Does the description signal that invocation is mandatory (not optional)? Sub-agent reads the description and judges whether an agent would understand that this skill MUST be invoked when conditions match. **Severity: WARNING.** Failure: description reads as optional or discretionary (e.g., "Use when you want to..." implies choice). |
| SC-SEM-003 | Dispatch table alignment | Does the description match the Trigger Dispatch Table's intent? Sub-agent compares the description against the table's trigger conditions and judges alignment. **Severity: ERROR.** Failure: description describes use cases the table does not cover, or table has triggers the description omits. |
| SC-SEM-004 | Full coverage of dispatch conditions | Would an agent reading only the description know to invoke this skill in all conditions listed in the dispatch table? Sub-agent reads the description, then reads the table, and judges whether every table trigger is represented in the description. **Severity: WARNING.** Failure: one or more table triggers are not reflected in the description. |
| SC-SEM-005 | No optional/discretionary language | Does the description contain any language that could be interpreted as making dispatch optional or discretionary? Sub-agent reads the description and identifies phrases that imply choice ("you can", "you may", "optionally", "if desired", "consider using"). **Severity: WARNING.** Failure: description contains optional/discretionary language. |
| SC-SEM-006 | Dispatch table sub-item type correctness | Do dispatch table sub-items use the correct semantic type — sub-bullets for parameter metadata, sub-checkboxes for actionable sub-steps? Sub-agent reads the Trigger Dispatch Table and classifies each sub-item as parameter metadata (context fields, task file paths, dispatch type) or actionable sub-step (must be performed). Verifies sub-bullets used for metadata, sub-checkboxes used for actions. **Severity: WARNING.** Failure: sub-bullet used for an actionable sub-step, or sub-checkbox used for parameter metadata. |

<!-- Fragment ID: sc-enforcement-gate -->

### Step 3a: Evaluate Reasoning Soundness (A1)

Evaluate the spec's causal reasoning, SC traceability, and internal consistency:

- [ ] 1. **Causal chain validity** — Verify the M:N mapping between Root Cause and Fix Approach:
  - Is every Root Cause element addressed by at least one Fix Approach element? (completeness)
  - Does every Fix Approach element trace to at least one Root Cause element? (sufficiency)
  - Are causal dependency assumptions explicit? (e.g., "fixing X will resolve Y" — is the causal link justified?)
  - If the causal chain is broken (Fix Approach doesn't follow from Root Cause), flag as `REASONING_GAP` with `causal_chain_broken`
- [ ] 2. **SC traceability** — Verify each SC traces to at least one Root Cause element:
  - Each SC must have a `traces_to` field or implicit link to a Root Cause
  - Each Root Cause must be tested by at least one SC
  - If an SC has no traceable Root Cause, flag as `REASONING_GAP` with `orphan_sc`
  - If a Root Cause has no SC, flag as `REASONING_GAP` with `untested_root_cause`
- [ ] 3. **Contradiction detection** — Scan for internal contradictions:
  - Explicit contradictions: two statements that directly conflict (e.g., "X must be true" and "X must be false")
  - Implicit contradictions: statements that imply conflicting constraints (e.g., "must be fast" and "must use slow algorithm")
  - Scope contradictions: Fix Approach elements that contradict the spec's stated scope boundaries
  - If contradictions found, flag as `REASONING_GAP` with `contradiction_detected`

Record results:

```yaml
reasoning_soundness:
  causal_chain:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  sc_traceability:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  contradictions:
    status: "PASS|FAIL"
    findings: ["<description of each contradiction>"]
```

Add SC-REASONING criteria to evaluation table:

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| SC-REASONING | Reasoning Soundness | Causal chain valid, SC traceability complete, no contradictions |

### Step 3b: Evaluate Claim Accuracy (A2)

Extend Step 2 verification with structured claim accuracy checks:

- [ ] 1. **FABRICATED verdict meta-rule** — When a claim in the spec has NO source evidence (no URL, no tool-call artifact, no code reference), apply the FABRICATED verdict:
  - If the claim is presented as factual but has zero supporting evidence → `FABRICATED` verdict
  - FABRICATED is a new verdict option alongside PASS/FAIL (generalized from content-audit.md pattern)
  - Record as: `result: "FABRICATED"` with `explanation: "Claim asserted without source evidence"`
- [ ] 2. **Negation verification** — When a claim asserts absence ("X does not exist", "no Y found"), verify via exhaustive search (not assumed from absence):
  - Use `srclight_search_symbols`, `grep`, or `glob` to actively search for the negated claim
  - If search finds the negated claim, flag as `CLAIM_GAP` with `negation_refuted`
  - If search confirms absence, record as PASS with `method: exhaustive_search`
- [ ] 3. **Interface contract verification** — When a spec references function signatures, API endpoints, or class interfaces:
  - Use `srclight_get_signature` to verify the exact signature
  - If signature doesn't match, flag as `CLAIM_GAP` with `interface_mismatch`
  - If signature matches, record as PASS with `method: srclight_get_signature`

Record results:

```yaml
claim_accuracy:
  fabricated_claims:
    - claim: "<exact text>"
      status: "FABRICATED|PASS"
      explanation: "<reasoning>"
  negation_verifications:
    - claim: "<exact text>"
      status: "PASS|FAIL"
      method: "exhaustive_search"
      finding: "<result>"
  interface_verifications:
    - claim: "<exact text>"
      status: "PASS|FAIL"
      method: "srclight_get_signature"
      finding: "<result>"
```

Add SC-CLAIM criteria to evaluation table:

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| SC-CLAIM | Claim Accuracy | No fabricated claims, negations verified, interface contracts match |

### Step 3c: Evaluate Blast Radius (A3)

Evaluate the spec's blast radius analysis completeness:

- [ ] 1. **Impact completeness** — Verify all affected files/components are traced:
  - For each file mentioned in the spec's Files Affected table, use `srclight_get_dependents` to find downstream dependents
  - If dependents exist that are not listed in the spec, flag as `BLAST_RADIUS_GAP` with `missing_dependent`
  - If no `srclight_get_dependents` call was made, flag as `BLAST_RADIUS_GAP` with `no_trace_performed`
- [ ] 2. **Non-code impact** — Check for guideline/skill cross-references and behavioral test implications:
  - Does the change affect any `.opencode/guidelines/` or `.opencode/skills/` files?
  - Does the change require behavioral test updates?
  - If non-code impact exists but is not addressed, flag as `BLAST_RADIUS_GAP` with `non_code_impact_unaddressed`

Record results:

```yaml
blast_radius:
  impact_completeness:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  non_code_impact:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 3d: Evaluate Research Adequacy (A4)

Evaluate whether the spec's claims are backed by adequate research:

- [ ] 1. **Evidence provenance** — For each key finding in the spec, check for tool-call artifacts:
  - Does the spec reference any tool-call evidence (srclight, grep, read, webfetch)?
  - If a finding is asserted without tool-call provenance, flag as `RESEARCH_GAP` with `no_provenance`
- [ ] 2. **Investigation breadth** — Check if alternatives were ruled out:
  - Does the spec mention alternatives considered?
  - If no alternatives are discussed, flag as `RESEARCH_GAP` with `no_alternatives_explored`
- [ ] 3. **Edge case discovery** — Check for boundary exploration:
  - Does the spec discuss edge cases or boundary conditions?
  - If no edge cases are identified, flag as `RESEARCH_GAP` with `no_edge_case_analysis`
- [ ] 4. **Recency check** — Verify commit history was reviewed:
  - Check if the spec references recent commits or changes
  - If the spec makes claims about code state without commit history review, flag as `RESEARCH_GAP` with `no_recency_check`

Record results:

```yaml
research_adequacy:
  evidence_provenance:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  investigation_breadth:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  edge_case_discovery:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  recency_check:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 3e: Evaluate Gap Analysis (A5)

Evaluate the spec for coverage gaps and implicit conditions:

- [ ] 1. **Missing coverage** — Identify untested boundary conditions:
  - For each SC, check if boundary conditions are explicitly tested
  - If an SC has no boundary condition testing, flag as `GAP_ANALYSIS` with `untested_boundary`
- [ ] 2. **Implicit conditions** — Identify preconditions not stated:
  - Scan the spec for assumptions that are not explicitly stated as preconditions
  - If an implicit precondition is found, flag as `GAP_ANALYSIS` with `implicit_precondition`

Record results:

```yaml
gap_analysis:
  missing_coverage:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  implicit_conditions:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 3f: Evaluate Scope Creep (A6)

Evaluate the spec for scope boundary violations:

- [ ] 1. **Traceability enforcement** — Verify every Fix Approach element traces to a Root Cause:
  - Each Fix Approach element must have a `traces_to` field or implicit link
  - If a Fix element has no Root Cause traceability, flag as `SCOPE_CREEP` with `untraced_fix_element`
- [ ] 2. **Proportionality** — Verify fix scope aligns with blast radius:
  - Is the fix scope proportional to the blast radius? (small blast radius → small fix)
  - If fix scope exceeds blast radius, flag as `SCOPE_CREEP` with `disproportionate_scope`

Record results:

```yaml
scope_creep:
  traceability_enforcement:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  proportionality:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 3g: Evaluate Scope Narrowness (A7)

Evaluate the spec for insufficient root cause depth:

- [ ] 1. **Root cause depth** — Apply the 5-Whys test:
  - Does the spec identify the root cause, or just a symptom?
  - If the spec fixes a symptom rather than the root cause, flag as `SCOPE_NARROWNESS` with `symptom_only_fix`
- [ ] 2. **Systemic implication** — Check if the problem exists elsewhere:
  - Is the same pattern/issue present in other parts of the codebase?
  - If the fix is localized but the problem is systemic, flag as `SCOPE_NARROWNESS` with `systemic_implication_unaddressed`
- [ ] 3. **Minimum viable scope** — Verify the scope is not over-scoped:
  - Does the fix include changes beyond what's needed to address the root cause?
  - If the scope exceeds the minimum viable fix, flag as `SCOPE_NARROWNESS` with `over_scoped`

Record results:

```yaml
scope_narrowness:
  root_cause_depth:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  systemic_implication:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  minimum_viable_scope:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 3h: Evaluate Cross-Reference Completeness (A9)

Evaluate the spec for citation completeness and reference sufficiency:

- [ ] 1. **Completeness of citation** — Verify all relevant context is cited:
  - For each claim that references an external source, check that the citation is complete (URL, issue number, file path)
  - If a claim references a source without a complete citation, flag as `CROSS_REF_GAP` with `incomplete_citation`
- [ ] 2. **Reference sufficiency** — Verify cited sources support the claims:
  - For each cited source, verify the source actually supports the claim being made
  - If a cited source does not support the claim, flag as `CROSS_REF_GAP` with `insufficient_reference`

Record results:

```yaml
cross_reference_completeness:
  citation_completeness:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
  reference_sufficiency:
    status: "PASS|FAIL"
    findings: ["<description of each gap>"]
```

### Step 3i: Evaluate Semantic Auditor Criteria (SC-SEM) for Skill Card Audits

When the spec being audited is a skill card (SKILL.md file), evaluate the SC-SEM criteria. These criteria assess the semantic quality of the skill's `description` field in YAML frontmatter and its Trigger Dispatch Table.

- [ ] 1. Determine if the spec is a skill card audit — check if the spec references a SKILL.md file or if `spec_local_dir` contains a SKILL.md
- [ ] 2. If NOT a skill card audit: skip SC-SEM criteria entirely (mark as N/A)
- [ ] 3. If YES: load the SKILL.md file from `spec_local_dir/`
- [ ] 4. Extract the `description` field from YAML frontmatter
- [ ] 5. Extract the Trigger Dispatch Table (markdown table under `## Trigger Dispatch Table`)
- [ ] 6. For each SC-SEM criterion, evaluate using the method described in the criteria table:

**SC-SEM-001 (Unambiguous dispatch condition):**
- Read the description and the Trigger Dispatch Table
- Judge: does the description provide clear, unambiguous conditions for when to invoke?
- PASS: description clearly states when to invoke (e.g., "Use when creating a branch, committing, pushing, or creating a PR")
- FAIL: description is vague or ambiguous (e.g., "Use when working with data")

**SC-SEM-002 (Mandatory invocation signal):**
- Read the description
- Judge: would an agent understand that invocation is mandatory, not optional?
- PASS: description uses mandatory language (MUST, REQUIRED, always, not optional, mandatory)
- FAIL: description reads as optional or discretionary

**SC-SEM-003 (Dispatch table alignment):**
- Compare the description against the Trigger Dispatch Table's trigger conditions
- Judge: does the description match the table's intent?
- PASS: description covers the same use cases as the table
- FAIL: description describes use cases the table does not cover, or table has triggers the description omits

**SC-SEM-004 (Full coverage of dispatch conditions):**
- Read the description, then read every trigger condition in the table
- Judge: is every table trigger represented in the description?
- PASS: all table triggers are reflected in the description
- FAIL: one or more table triggers are not reflected

**SC-SEM-005 (No optional/discretionary language):**
- Read the description and identify phrases that imply choice
- PASS: no optional/discretionary language found
- FAIL: description contains "you can", "you may", "optionally", "if desired", "consider using", or similar

**SC-SEM-006 (Dispatch table sub-item type correctness):**
- Read the Trigger Dispatch Table and classify each sub-item:
  - Parameter metadata: context fields, task file paths, dispatch type → should use sub-bullets (`- field: value`)
  - Actionable sub-step: must be performed by the agent → should use sub-checkboxes (`- [ ] action`)
- PASS: all sub-items use the correct semantic type
- FAIL: sub-bullet used for an actionable sub-step, or sub-checkbox used for parameter metadata

Record each SC-SEM criterion result in the per_criterion array with the same format as other criteria, adding a `severity` field:

```yaml
  - criterion_id: "SC-SEM-001"
    declared_evidence_type: "semantic"
    severity: "ERROR"
    result: "PASS|FAIL"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|re-evaluate"
    tool_calls_made:
      - read
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
- [ ] 1. Which fail pattern(s) the SC contains
- [ ] 2. What a deterministic rewrite would look like
- [ ] 3. An example executable verification command

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

### Step 8: Write verdict.yaml

Write verdict to `./tmp/{issue-N}/artifacts/spec-audit/verdict.yaml`

### Step 9: Write Verdict Artifact to Disk (Legacy — kept for backward compatibility)

Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-spec-audit-{STATUS}-{timestamp}.yaml`:

```yaml
auditor_type: spec-audit
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
    severity: "ERROR"  # ERROR or WARNING; only present for SC-SEM criteria
    result: "PASS"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: ""
    next_step: "proceed"  # Conditional: "remediate" when result is "FAIL", "proceed" when result is "PASS"
    tool_calls_made:
      - read
      - grep
all_criteria_pass: false
remediation_required: true  # When status is FAIL: full mandatory re-audit required
```

### Step 12: Return Frugal Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-spec-audit-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
all_criteria_pass: false
remediation_required: true  # When status is FAIL: full mandatory re-audit required
```

## Remediation


## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 1. Load spec content → INVALID if skipped
- [ ] 2. Verify documentation sources → INVALID if skipped
- [ ] 3. Build evaluation criteria → INVALID if skipped
- [ ] 3a. Evaluate reasoning soundness (A1) → INVALID if skipped
- [ ] 3b. Evaluate claim accuracy (A2) → INVALID if skipped
- [ ] 3c. Evaluate semantic auditor criteria (SC-SEM) → INVALID if skipped for skill card audits; N/A for non-skill-card audits
- [ ] 4. Cross-validate with verdicts → INVALID if skipped
- [ ] 5. Process verdicts → INVALID if skipped
- [ ] 6. Evaluate SC determinism → INVALID if skipped
- [ ] 7. Generate bidirectional findings → INVALID if skipped
- [ ] 8. Build result contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| Spec issue not found | Return BLOCKED with issue number |
| Spec body empty | Return FAIL for SC-1, continue remaining |
| Cross-validate fails | Return OVERFLOW, log error |
| Auditor unavailable | Use fallback chain per multimodal-dispatch |

## Cross-References

- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
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
    title: "Bidirectional finding required for contested criteria"
    conditions:
      all: ["criterion_contested == true", "bidirectional_finding == null"]
    actions: [APPEND_BIDIRECTIONAL_FINDING]
    source: "spec-audit.md §Step 5"

  - id: spec-audit-004
    title: "Documentation Sources section required and populated"
    conditions:
      all: ["doc_sources_missing_or_empty == true"]
    actions: [FAIL_CRITERION(SC-11)]
    source: "spec-audit.md §Step 2"

  - id: spec-audit-005
    title: "next_step MUST be 'remediate' when result is 'FAIL', 'proceed' when result is 'PASS'"
    conditions:
      any:
        - "per_criterion[].result == 'FAIL' AND per_criterion[].next_step != 'remediate'"
        - "per_criterion[].result == 'PASS' AND per_criterion[].next_step != 'proceed'"
    actions: [HALT, REQUIRE_CORRECT_NEXT_STEP]
    source: "spec-audit.md §Step 6 — conditional next_step enforcement"

  - id: spec-audit-006
    title: "all_criteria_pass MUST be true when every criterion result is 'PASS', false otherwise"
    conditions:
      any:
        - "all(criterion.result == 'PASS' for criterion in per_criterion) AND all_criteria_pass != true"
        - "any(criterion.result == 'FAIL' for criterion in per_criterion) AND all_criteria_pass != false"
    actions: [HALT, REQUIRE_CORRECT_ALL_CRITERIA_PASS]
    source: "spec-audit.md §Step 6 — all_criteria_pass enforcement"
```