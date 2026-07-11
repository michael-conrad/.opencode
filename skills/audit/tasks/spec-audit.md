<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

<!-- Dimensions synced from .opencode/reference/holistic-dimensions.yaml -->
<!-- Sync locations: see cross-reference table in that file -->

# Task: spec-audit

## Purpose

Audit a spec for quality, structure, and completeness. Each criterion is evaluated against the spec's declared evidence types with clean-room context.

> **DiMo Role: Evaluator.** This task evaluates spec quality. Reads `evidence.yaml` (Generator), validates evidence → writes `reasoning.yaml`, evaluates → writes `verdict.yaml`.
>
> You are the Evaluator. You are decisive and binary. Every criterion gets a PASS or a FAIL — nothing in between. You do not hedge, you do not defer, you do not ask for a second opinion. The evidence is in front of you. Make the call.
> 
> 
> - MUST produce a binary PASS or FAIL for every criterion — no hedging, no "PASS with concerns"
> - MUST NOT defer to upstream roles — the verdict is yours alone
> - MUST NOT re-evaluate evidence that Knowledge Supporter already validated
> - MUST write `verdict.yaml` as the primary output artifact
> 

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against evidence.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts
- `blast_radius_path`: Path to blast radius analysis artifact (optional)
- `concern_map_path`: Path to concern map artifact (optional)
- `code_path_inventory_path`: Path to code path inventory artifact (optional)
- `cross_cutting_matrix_path`: Path to cross-cutting matrix artifact (optional)
- `interface_compatibility_path`: Path to interface compatibility artifact (optional)
- `state_analysis_path`: Path to state analysis artifact (optional)
- `testability_assessment_path`: Path to testability assessment artifact (optional)

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
- [ ] 3. Holistic Semantic Evaluation Gate — evaluate 11 dimensions; if any FAIL, halt with DRAFT verdict
- [ ] 4. Verify Documentation Sources — research each cited URL, API reference, or documentation claim against live sources
- [ ] 5. Build Evaluation Criteria — define SC table with evidence types
- [ ] 5a. Evaluate Semantic Auditor Criteria (SC-SEM) — evaluate skill card description quality (skip if not a skill card audit)
- [ ] 6. Process Verdicts — per-criterion PASS/FAIL consensus
- [ ] 7. Evaluate SC Determinism (SC-DET) — check each SC for determinism
- [ ] 8. Generate Bidirectional Findings — FAIL/DISAGREE criteria with revision options
- [ ] 9. Write verdict.yaml — write verdict to `./tmp/{issue-N}/artifacts/spec-audit/verdict.yaml`
- [ ] 10. Return Frugal Result Contract

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

- [ ] 3. Check optional analytical artifact paths — for each of `blast_radius_path`, `concern_map_path`, `code_path_inventory_path`, `cross_cutting_matrix_path`, `interface_compatibility_path`, `state_analysis_path`, `testability_assessment_path`:
  - If the field is present in the dispatch contract, verify the path exists and is non-empty
  - If the path is missing or empty, emit a WARNING (do NOT BLOCK) — missing optional artifacts produce a warning, not a BLOCKED status
  - If the field is absent from the dispatch contract, skip silently (artifact not produced by upstream)

**This gate fires BEFORE any other step.** If any required criterion fails, the task returns BLOCKED immediately — no globbing, no reading, no analysis.

### Step 1: Load Spec Content

`spec_local_dir` is REQUIRED. Auditors mandate this directory and BLOCK if absent. The orchestrator MUST provide a valid local path before dispatching.

Read spec from `spec_local_dir/`:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool, read all discovered files
- [ ] 2. Extract spec body and metadata from each
- [ ] 3. If `spec_local_dir` is a list, glob each entry's `**/*.md`, extract SCs from each, perform interdependency analysis (overlaps, conflicts, independences)

Auditors return BLOCKED with `SPEC_NOT_FOUND` if `spec_local_dir` is absent.

### Step 2: Holistic Semantic Evaluation Gate

**Gate semantics:** This step runs BEFORE all narrow criteria (Steps 3+). If the holistic gate FAILs, the spec is returned as DRAFT — narrow criteria never execute. This prevents wasting evaluation effort on specs that fail at the structural level.

- [ ] 1. Dispatch a clean-room sub-agent with the spec body (no orchestrator preload, no expected outcomes)
- [ ] 2. The sub-agent evaluates the spec against all 11 holistic dimensions defined in `.opencode/reference/holistic-dimensions.yaml`:

| # | Dimension | Question | Checks |
|---|-----------|----------|--------|
| 1 | Implementability | Can an agent produce correct output from this spec? | Single approach, unambiguous SCs, consistent output across implementors |
| 2 | Internal Consistency | Does the spec contradict itself across sections? | Preamble vs body, SCs vs constraints, Files Affected vs phases, causal chain |
| 3 | Completeness | Are there gaps forcing the implementor to guess? | Undefined terms, missing SCs, implicit dependencies, TBD/TODO markers, unspecified handoffs |
| 4 | Scope Discipline | Does the spec stay within its stated boundaries? | Unbounded requirements, scope creep in phases, blast radius mismatch |
| 5 | Testability | Can every SC be independently verified? | Untestable SCs, subjective judgment, circular verification, evidence type mismatch |
| 6 | Escape Hatches | Does the spec contain language that lets the agent short-circuit requirements? | "Use best judgment", "implementer's discretion", "if time permits", "stretch goal", "may be deferred", "simplify if needed", "reduce scope if complex", "as appropriate", "as needed", "preferably", "ideally", "should", "TBD", "TODO", "to be determined", "left to implementor", "implementor's choice", "consider X", "optionally", "if desired" |
| 7 | Provenance | Are the spec's claims backed by evidence? | Unsupported factual assertions, claims about code state without tool-call evidence, references to unverified files/functions, assertions about behavior without source |
| 8 | Feasibility | Can this actually be done with available tools and constraints? | References to non-existent files/functions/libraries, requirements exceeding infrastructure, physically impossible phase ordering, unavailable dependencies |
| 9 | Safety | Does the spec have failure modes that could cause irreversible harm? | Destructive operations without rollback plans, data loss scenarios, security vulnerabilities, irreversible operations, production data changes without safeguards |
| 10 | Traceability | Does every element connect to something else in a coherent chain? | Orphan SCs, root causes with no SCs, phases not tracing to SCs, steps not tracing to phases, forward and backward traceability coherence |
| 11 | Correctness | Does this spec actually solve the right problem? | Preamble vs SCs mismatch, root cause vs fix approach mismatch, stated problem vs actual defect mismatch, symptom vs root cause |

- [ ] 3. Each dimension gets a single PASS/FAIL — no hedging, no "PASS with concerns"
- [ ] 4. If any dimension FAILs:
  - Halt — do NOT proceed to narrow criteria (Steps 3+)
  - Read the spec's STATUS marker from the issue body
  - If STATUS is not already DRAFT, set STATUS to DRAFT
  - Post a comment: "Spec marked DRAFT: [dimension(s)] failed holistic evaluation. [Explanation of each failure]. Resolution: [specific guidance on what to fix for each failed dimension]."
  - Include the DRAFT status change in the verdict artifact
  - Return verdict with `holistic_status: DRAFT`
- [ ] 5. If all 11 dimensions PASS:
  - Proceed to narrow criteria (Steps 3+)
  - Record holistic PASS in the verdict artifact

Record results:

```yaml
holistic_evaluation:
  status: "PASS|DRAFT"
  dimensions:
    - id: 1
      name: "Implementability"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 2
      name: "Internal Consistency"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 3
      name: "Completeness"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 4
      name: "Scope Discipline"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 5
      name: "Testability"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 6
      name: "Escape Hatches"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 7
      name: "Provenance"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 8
      name: "Feasibility"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 9
      name: "Safety"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 10
      name: "Traceability"
      result: "PASS|FAIL"
      finding: "<brief finding>"
    - id: 11
      name: "Correctness"
      result: "PASS|FAIL"
      finding: "<brief finding>"
  draft_status_changed: true|false
  comment_posted: true|false
```

### Step 3: Verify Documentation Sources Against Live Sources

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

### Step 5: Build Evaluation Criteria

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
| SC-SEM-001 | Unambiguous dispatch condition | Does the description unambiguously tell an agent when to invoke this skill? Sub-agent reads the description and the Trigger Dispatch Table, judges whether the description provides clear dispatch conditions. Failure: description is ambiguous about when to invoke (e.g., "Use when working with data" is too vague). |
| SC-SEM-002 | Mandatory invocation signal | Does the description signal that invocation is mandatory (not optional)? Sub-agent reads the description and judges whether an agent would understand that this skill MUST be invoked when conditions match. Failure: description reads as optional or discretionary (e.g., "Use when you want to..." implies choice). |
| SC-SEM-003 | Dispatch table alignment | Does the description match the Trigger Dispatch Table's intent? Sub-agent compares the description against the table's trigger conditions and judges alignment. Failure: description describes use cases the table does not cover, or table has triggers the description omits. |
| SC-SEM-004 | Full coverage of dispatch conditions | Would an agent reading only the description know to invoke this skill in all conditions listed in the dispatch table? Sub-agent reads the description, then reads the table, and judges whether every table trigger is represented in the description. Failure: one or more table triggers are not reflected in the description. |
| SC-SEM-005 | No optional/discretionary language | Does the description contain any language that could be interpreted as making dispatch optional or discretionary? Sub-agent reads the description and identifies phrases that imply choice ("you can", "you may", "optionally", "if desired", "consider using"). Failure: description contains optional/discretionary language. |
| SC-SEM-006 | Dispatch table sub-item type correctness | Do dispatch table sub-items use the correct semantic type — sub-bullets for parameter metadata, sub-checkboxes for actionable sub-steps? Sub-agent reads the Trigger Dispatch Table and classifies each sub-item as parameter metadata (context fields, task file paths, dispatch type) or actionable sub-step (must be performed). Verifies sub-bullets used for metadata, sub-checkboxes used for actions. Failure: sub-bullet used for an actionable sub-step, or sub-checkbox used for parameter metadata. |

<!-- Fragment ID: sc-enforcement-gate -->

### Step 5a: Evaluate Reasoning Soundness (A1)

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

### Step 5b: Evaluate Claim Accuracy (A2)

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
| SC-BLAST-RADIUS | Blast radius artifact present and complete | Blast radius artifact exists, all affected files/components traced, downstream dependents identified |
| SC-CONCERN-MAP | Concern map artifact present and complete | Concern map artifact exists, concerns separated, no overlapping concerns |
| SC-CODE-PATH | Code path inventory artifact present and complete | Code path inventory exists, all code paths affected by the change are enumerated |
| SC-CROSS-CUTTING | Cross-cutting matrix artifact present and complete | Cross-cutting matrix exists, cross-cutting concerns identified and mapped |
| SC-INTERFACE | Interface compatibility artifact present and complete | Interface compatibility analysis exists, all interface changes documented |
| SC-STATE | State analysis artifact present and complete | State analysis exists, state transitions and invariants documented |
| SC-TESTABILITY | Testability assessment artifact present and complete | Testability assessment exists, test strategy and coverage plan documented |

### Step 5c: Evaluate Blast Radius (A3)

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

### Step 5d: Evaluate Research Adequacy (A4)

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

### Step 5e: Evaluate Gap Analysis (A5)

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

### Step 5f: Evaluate Scope Creep (A6)

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

### Step 5g: Evaluate Scope Narrowness (A7)

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

### Step 5h: Evaluate Cross-Reference Completeness (A9)

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

### Step 5i: Validate Blast Radius Artifact

Validate the blast radius analysis artifact against the spec content:

- [ ] 1. **Artifact existence** — Check that `blast_radius_path` exists and is non-empty
- [ ] 2. **Cross-reference** — For each file mentioned in the spec's Files Affected table, verify the blast radius artifact lists that file and its downstream dependents
- [ ] 3. **Gap detection** — If the blast radius artifact is missing files that `srclight_get_dependents` would identify, flag as `BLAST_RADIUS_GAP` with `artifact_incomplete`
- [ ] 4. **Non-code impact** — Verify the artifact addresses guideline/skill cross-references and behavioral test implications

Record results:

```yaml
blast_radius_artifact:
  artifact_path: "<blast_radius_path>"
  status: "PASS|FAIL"
  findings: ["<description of each gap>"]
```

### Step 5j: Validate Concern Map Artifact

Validate the concern map artifact against the spec content:

- [ ] 1. **Artifact existence** — Check that `concern_map_path` exists and is non-empty
- [ ] 2. **Concern separation** — Verify each phase in the spec maps to exactly one concern in the artifact
- [ ] 3. **Overlap detection** — Check for overlapping concerns across phases; flag as `CONCERN_MAP_GAP` with `overlapping_concerns`
- [ ] 4. **Coverage** — Verify all spec phases are represented in the concern map

Record results:

```yaml
concern_map_artifact:
  artifact_path: "<concern_map_path>"
  status: "PASS|FAIL"
  findings: ["<description of each gap>"]
```

### Step 5k: Validate Code Path Inventory

Validate the code path inventory artifact against the spec content:

- [ ] 1. **Artifact existence** — Check that `code_path_inventory_path` exists and is non-empty
- [ ] 2. **Path enumeration** — Verify all code paths affected by the change are enumerated in the artifact
- [ ] 3. **Entry/exit points** — Check that entry points and exit points are documented for each path
- [ ] 4. **Gap detection** — If the spec references a code path not in the inventory, flag as `CODE_PATH_GAP` with `missing_path`

Record results:

```yaml
code_path_inventory_artifact:
  artifact_path: "<code_path_inventory_path>"
  status: "PASS|FAIL"
  findings: ["<description of each gap>"]
```

### Step 5l: Validate Cross-Cutting Matrix

Validate the cross-cutting matrix artifact against the spec content:

- [ ] 1. **Artifact existence** — Check that `cross_cutting_matrix_path` exists and is non-empty
- [ ] 2. **Concern identification** — Verify cross-cutting concerns (logging, auth, error handling, etc.) are identified
- [ ] 3. **Mapping** — Verify each cross-cutting concern is mapped to the affected phases/files
- [ ] 4. **Gap detection** — If a cross-cutting concern is implied by the spec but absent from the matrix, flag as `CROSS_CUTTING_GAP` with `missing_concern`

Record results:

```yaml
cross_cutting_matrix_artifact:
  artifact_path: "<cross_cutting_matrix_path>"
  status: "PASS|FAIL"
  findings: ["<description of each gap>"]
```

### Step 5m: Validate Interface Compatibility

Validate the interface compatibility artifact against the spec content:

- [ ] 1. **Artifact existence** — Check that `interface_compatibility_path` exists and is non-empty
- [ ] 2. **Interface changes** — Verify all interface changes (function signatures, API endpoints, class interfaces) referenced in the spec are documented in the artifact
- [ ] 3. **Backward compatibility** — Check that the artifact addresses backward compatibility for each changed interface
- [ ] 4. **Gap detection** — If the spec changes an interface not documented in the artifact, flag as `INTERFACE_GAP` with `undocumented_change`

Record results:

```yaml
interface_compatibility_artifact:
  artifact_path: "<interface_compatibility_path>"
  status: "PASS|FAIL"
  findings: ["<description of each gap>"]
```

### Step 5n: Validate State Analysis

Validate the state analysis artifact against the spec content:

- [ ] 1. **Artifact existence** — Check that `state_analysis_path` exists and is non-empty
- [ ] 2. **State transitions** — Verify all state transitions implied by the spec are documented in the artifact
- [ ] 3. **Invariants** — Check that state invariants are identified and documented
- [ ] 4. **Gap detection** — If the spec implies a state change not documented in the artifact, flag as `STATE_GAP` with `missing_transition`

Record results:

```yaml
state_analysis_artifact:
  artifact_path: "<state_analysis_path>"
  status: "PASS|FAIL"
  findings: ["<description of each gap>"]
```

### Step 5o: Validate Testability Assessment

Validate the testability assessment artifact against the spec content:

- [ ] 1. **Artifact existence** — Check that `testability_assessment_path` exists and is non-empty
- [ ] 2. **Test strategy** — Verify the artifact defines a test strategy for each SC in the spec
- [ ] 3. **Coverage plan** — Check that the artifact includes a coverage plan (unit, integration, behavioral)
- [ ] 4. **Gap detection** — If an SC in the spec has no corresponding test strategy in the artifact, flag as `TESTABILITY_GAP` with `missing_test_strategy`

Record results:

```yaml
testability_assessment_artifact:
  artifact_path: "<testability_assessment_path>"
  status: "PASS|FAIL"
  findings: ["<description of each gap>"]
```

### Step 5p: Evaluate Semantic Auditor Criteria (SC-SEM) for Skill Card Audits

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

Record each SC-SEM criterion result in the per_criterion array with the same format as other criteria:

```yaml
  - criterion_id: "SC-SEM-001"
    declared_evidence_type: "semantic"
    result: "PASS|FAIL"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: "<if FAIL, what to fix>"
    next_step: "proceed|re-evaluate"
    tool_calls_made:
      - read
```

**When `failure_description` is provided:** The spec auditor must evaluate whether the SCs are deterministic and testable specifically in light of the failure evidence. The evaluation should answer: "Would this SC have prevented the observed failure if it were properly deterministic?" or "Is the failure attributable to a non-deterministic SC?" If yes, return SPEC_GAP with revision recommendation. If no (SCs are deterministic but the implementer failed), return confirmation that implementation failure is the root cause.

### Step 6: Process Verdicts

For each criterion:
- Both auditors PASS → criterion consensus PASS
- Either auditor FAIL → criterion consensus FAIL
- Auditors disagree → mark as DISAGREE, present bidirectional finding

**Self-consistency gate:** After computing consensus, apply a self-consistency check to every PASS verdict. If `result: "PASS"` and the `explanation` contains critique/hedging language ("should be", "needs", "missing", "could improve", "minor", "some issues", "mostly", "generally"), the verdict is downgraded to FAIL. A PASS verdict must be strictly confirmatory with no critique or hedging.

### Step 7: Evaluate SC Determinism (SC-DET)

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

### Step 8: Generate Bidirectional Findings

Generate findings ONLY for FAIL/DISAGREE criteria. PASS criteria MUST NOT appear in the findings table — a PASS verdict with findings is contradictory and will be caught by the self-consistency gate in Step 4.

| Finding Type | Direction | Description |
|-------------|-----------|-------------|
| SPEC_INCOMPLETE | spec→code | Spec missing required element |
| SPEC_AMBIGUOUS | spec↔code | Spec open to interpretation |
| SPEC_OUTDATED | code→spec | Implementation diverged from spec |
| SPEC_OVERSPECIFIED | spec→code | Spec constrains implementation unnecessarily |

Present revision options for developer decision.

### Step 9: Write verdict.yaml

Write verdict to `./tmp/{issue-N}/artifacts/spec-audit/verdict.yaml`

### Step 10: Write Verdict Artifact to Disk (Legacy — kept for backward compatibility)

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

### Step 11: Return Frugal Result Contract

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
- [ ] 2. Holistic Semantic Evaluation Gate → INVALID if skipped (gate blocks all downstream steps on FAIL)
- [ ] 3. Verify documentation sources → INVALID if skipped
- [ ] 4. Build evaluation criteria → INVALID if skipped
- [ ] 5. Build Evaluation Criteria → INVALID if skipped
- [ ] 5a. Evaluate reasoning soundness (A1) → INVALID if skipped
- [ ] 5b. Evaluate claim accuracy (A2) → INVALID if skipped
- [ ] 5c. Evaluate blast radius (A3) → INVALID if skipped
- [ ] 5d. Evaluate research adequacy (A4) → INVALID if skipped
- [ ] 5e. Evaluate gap analysis (A5) → INVALID if skipped
- [ ] 5f. Evaluate scope creep (A6) → INVALID if skipped
- [ ] 5g. Evaluate scope narrowness (A7) → INVALID if skipped
- [ ] 5h. Evaluate cross-reference completeness (A9) → INVALID if skipped
- [ ] 5i. Validate blast radius artifact → INVALID if skipped
- [ ] 5j. Validate concern map artifact → INVALID if skipped
- [ ] 5k. Validate code path inventory → INVALID if skipped
- [ ] 5l. Validate cross-cutting matrix → INVALID if skipped
- [ ] 5m. Validate interface compatibility → INVALID if skipped
- [ ] 5n. Validate state analysis → INVALID if skipped
- [ ] 5o. Validate testability assessment → INVALID if skipped
- [ ] 5p. Evaluate semantic auditor criteria (SC-SEM) → INVALID if skipped for skill card audits; N/A for non-skill-card audits
- [ ] 6. Process Verdicts → INVALID if skipped
- [ ] 7. Evaluate SC Determinism → INVALID if skipped
- [ ] 8. Generate Bidirectional Findings → INVALID if skipped
- [ ] 9. Write verdict.yaml → INVALID if skipped
- [ ] 10. Write Verdict Artifact to Disk → INVALID if skipped
- [ ] 11. Return Frugal Result Contract → INVALID if skipped

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
