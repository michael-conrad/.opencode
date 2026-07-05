# Task: write

## Purpose

Assemble the final spec with acceptance criteria, ambiguity elimination, and deliverable structure. Includes self-review and user-review steps adapted from brainstorming Steps 7-9, extended with principles #4, #6, #10.

## Entry Criteria

- Requirements extraction completed (mandatory)
- Other prerequisite tasks completed or explicitly skipped via simplicity heuristic

## Exit Criteria

- Issue created with `[SPEC]` prefix and `needs-approval` label
- Self-review completed (placeholder scan, consistency, scope, ambiguity)
- Chat output is ONLY: `<exec summary>` + `<issue URL>` + `<byline>` (no full spec dump)
- User reviews spec ON THE ISSUE (not in chat)
- Ready for spec-auditor and approval-gate
- `.issues/{N}/spec-to-plan-handoff.yaml` generated with artifact manifest (SC-27)
- `.issues/{N}/sc-summary.yaml` includes flat `scs` list with `id`, `description`, `evidence_type`, `verification_gate`, `plan_phase` per SC (SC-28)
- `.issues/{N}/spec.md` saved with full spec content (SC-29)
- `.opencode/tools/local-issues sync` run after all `.issues/{N}/` file changes (SC-33)

## Procedure

- [ ] 1. **Pre-Step: Verification Gate (MANDATORY FIRST)** — Before assembling the spec, invoke `verification-enforcement --task verify`. This gate task()s section-based sub-agents to collect evidence artifacts for the factual claims the spec will make — file references, API signatures, configuration fields, code behavior, and environment details. Evidence artifacts collected here ensure that the spec's claims are grounded in live sources. Claims that cannot be verified at this stage are marked with `⚠️ UNVERIFIED` for resolution in the post-generation revisit pass.

- [ ] 2. **Pre-Step 0.8: Stub Creation (SC-22 — behavioral)** — Invoke `issue-operations --task creation` with a minimal exec summary body to establish the remote issue number. Include the spec title, brief problem statement, and `needs-approval` label. Record the returned issue number for all subsequent artifact paths. The full spec body will be populated in Step 7 via `issue-operations --task body-edit`.

- [ ] 3. **Step 0.5: Behavioral Test Mandate in Success Criteria (MANDATORY)** — Behavioral enforcement tests are NOT written during spec creation. They are written during implementation, per the post-approval spec mandate. However, the spec MUST include a Success Criterion mandating behavioral test creation before implementation.

    **For rule-changing specs** (guidelines, skills, critical violations): Include a success criterion that mandates "Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rule; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes."

    **For code-changing specs**: Include a success criterion that mandates "Before any implementation, write unit or integration tests that verify the changed behavior; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes."

    **Cross-reference:** See `091-incremental-build.md` → Per-Item TDD Cycle → RED phase, `080-code-standards.md` → SC-to-Test Traceability and RED-Phase Ordering, and `080-code-standards.md` → Behavioral Enforcement Tests (PRIMARY) for the behavioral RED/GREEN gate.

    **Sequential per-item TDD:** Implementation phases in spec MUST enforce sequential RED/GREEN pairing per the TDD skill. Each RED must be immediately followed by its GREEN before the next RED begins. Combined RED/GREEN phases are prohibited.

    **Cost-frame mandate in SCs:** Each success criterion MUST carry a short cost-frame reformation statement that reframes what "expensive" means for that SC's domain. The statement uses the dark-prose-007 formula from `250-dark-prose-reference.md` §Section 3 — the implementing agent derives the exact prose autonomously based on the SC's verification method. Each SC's verification method MUST require a real test execution command — not a structural check (file exists, grep match). Structural verification is NEVER a valid substitute for behavioral execution: a skipped runtime equals a defect undiscovered. The death spiral / break dynamics are formalized in `065-verification-honesty.md` §Cost Model — behavioral PASS is a break (zero downstream cost); structural-only PASS is a death spiral (compounding exponential cost).

- [ ] 4. **Step 0.5a: Behavioral Test Definition — Stderr-Based Evidence (MANDATORY)** — Valid behavioral enforcement tests use **stderr-based assertion helpers** (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`) to verify agent actions (skill dispatches, file reads, tool invocations). **Prose-recall prompts** (e.g., "Describe how you would resolve models") produce stdout prose, not behavioral evidence, and are NOT accepted as valid behavioral tests.

    **Behavioral evidence = agent actions visible in stderr (skill dispatches, file reads, sub-agent task() calls, tool invocations). Prose recall (what the agent says in stdout when asked to describe a procedure) is NOT behavioral evidence.**

    When creating the behavioral test success criterion, ensure it mandates real-domain prompts and stderr-based assertions, not prose-recall prompts.

- [ ] 5. **Step 1: Assemble Spec** — The generated spec body MUST include a compliance statement blockquote at the top (after the preamble/user greeting) and at the bottom (before the success criteria table).

    > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

    **Template content — top position (after STATUS/CREATED header):**

    ```markdown
    > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
    ```

    **Template content — bottom position (before success criteria table):**

    ```markdown
    > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
    ```

    Combine outputs from prerequisite tasks into a coherent spec. The spec should address the following content areas — the agent decides which sections to use and how to organize them:

    - **Objectives and goals** — What this spec achieves
    - **Constraints and scope** — What's in and out of scope
    - **Success criteria** — Testable, binary pass/fail conditions
    - **Risk and edge cases** — What could go wrong and boundary conditions
    - **Implementation approach** — For the reader's understanding, not prescribing HOW (see Step 5.5)

    Skip areas that don't apply to simple specs; add areas that do. The spec should be self-contained and clear, regardless of structure.

- [ ] 6. **Step 1a: Generate Spec Artifacts (MANDATORY for standard/complex specs)** — For standard and complex specs, generate the following permanent artifacts:

    - [ ] **SC coverage summary YAML** — Create `.issues/{issue-N}/sc-summary.yaml` with machine-parseable coverage data including SC IDs, evidence types, phase bindings, and verification gates.
    - [ ] **Verification consistency contract** — Create `.issues/{issue-N}/verification-consistency-contract.yaml` as a solve contract with compliance matrix variables.
    - [ ] **Lifecycle manifest** — Create `{project_root}/tmp/{issue-N}/lifecycle.yaml` with initial `spec_created` event. Append-only format; never overwrite.
    - [ ] **Revision re-entry protocol contract** — Create `.issues/{issue-N}/revision-re-entry-contract.yaml` as a solve contract with cascade variables for each revision scope.

    Artifact generation occurs during Step 1 assembly. Self-review (Step 6) validates YAML-vs-prose consistency.

- [ ] 7. **Step 1b: Plan Creation Mandate in Spec Body (MANDATORY)** — The generated spec body MUST include a paragraph in the preamble or before the Success Criteria section that mandates plan creation via `writing-plans`:

    ```markdown
    After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.
    ```

    Where `{N}` is the actual issue number, substituted at generation time. This mandate is in the spec content (what the writer generates), not just the task procedure.

- [ ] 8. **Decision Ledger** — Captures design decisions with stable DEC-IDs and RFC 2119 requirement keys (MUST/SHOULD/MAY) for traceability across spec revisions.

    ```markdown
    | DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
    |--------|----------|-----------|-----------------|--------------|
    | DEC-1 | Use async API | Non-blocking I/O required for throughput | MUST | SC-3, SC-4 |
    ```

- [ ] 9. **Risk Traceability Table** — Maps RISK-IDs to Verifying SC binding, ensuring each identified risk has a corresponding success criterion that validates its mitigation.

    ```markdown
    | RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
    |---------|-----------------|------------|--------|------------|--------------|
    | RISK-1 | Rate limit exceeded | Medium | High | Implement retry with backoff | SC-7 |
    ```

- [ ] 10. **Revision Policy** — Declares artifact cascade: when a parent spec is revised, which dependent artifacts MUST also be revised. Uses declarative table format.

    ```markdown
    | Artifact | Cascade Trigger | Action on Parent Revision |
    |----------|----------------|---------------------------|
    | Implementation plan | MUST | Revise to match revised spec |
    | Behavioral tests | SHOULD | Review for continued validity |
    | Risk traceability | MAY | Update if new risks introduced |
    ```

- [ ] 11. **Decomposition Classification** — Distinguishes single-task specs from multi-phase specs using distinguishing criteria.

    | Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
    | -------------- | ---------------- | ---------------------- | ----------- |
    | single-task | 1 | None | single PR |
    | multi-phase | 2+ | One sub-issue per phase | stacked PRs per phase |

- [ ] 12. **Spec Family Annotation (optional)** — Punch-list annotation for specs that belong to a family. Selector syntax documents which specs share a common concern.

    ```markdown
    family: performance-optimization
    selectors:
      - spec: #42
      - spec: glob(pattern: "specs/performance/*.md")
    ```

- [ ] 13. **Explicit Non-Goals** — Lists what the spec explicitly does NOT address. Each non-goal is a bullet item with rationale.

    ```markdown
    - **Internationalization** — Out of scope for this release; will be addressed in a follow-up spec.
    - **Backward compatibility with v1 API** — Breaking changes are accepted per the deprecation policy.
    ```

- [ ] 14. **Regression Invariants** — Numbered list of behaviors or properties that MUST NOT change as a result of this implementation.

    - [ ] 1. Existing authentication flows MUST continue to accept current tokens.
    - [ ] 1. All existing public API signatures MUST remain unchanged.
    - [ ] 1. Database schema migration MUST NOT drop existing columns.

- [ ] 15. **Cross-Cutting / Common SC Designation** — When a success criterion applies across multiple phases, designate it as cross-cutting using a preamble section marker. Cross-cutting SCs share a verification budget: a single PASS verifies the SC for all phases. MUST pass once for all phases.

    ```markdown
    **Cross-Cutting SCs:** SC-1, SC-5, SC-9
    — Verified once in Phase 1, applies to all subsequent phases.
    ```

    A **Documentation Sources** section documents where the spec author verified factual claims. This is especially important for specs making claims about code behavior, config schemas, or API signatures. Place it before the AI byline section.

    **Source Categories:**

    | Category | Description | Examples |
    | -------- | ----------- | ---------------------------------------------------------- |
    | Local docs | Project documentation, README, design docs | `docs/architecture.md`, `README.md` |
    | Direct source search | Codebase search via grep, srclight, or glob | `srclight_search_symbols("cache")`, `grep -r "redis" src/` |
    | Documentation URLs | External documentation or API references | Language docs, library docs, framework guides |
    | MCP search | Tool-based code analysis | `srclight_get_signature()`, `srclight_get_symbol()` |
    | Live verification | Test execution or runtime checks | `uv run pytest test/test_*.py`, config validation |

    **Format:**

    ```markdown
    **Documentation Sources:**
    | Source Category | What Was Consulted | Purpose |
    |----------------|-------------------|---------|
    | Local docs | `README.md`, `docs/architecture.md` | Understand existing architecture |
    | Direct source search | `srclight_search_symbols("cache")` | Identify existing cache patterns |
    | Documentation URLs | [redis-py docs](https://redis-py.readthedocs.io/) | Verify API signatures |
    | MCP search | `srclight_get_signature("get_data")` | Verify function signature |
    | Live verification | `uv run pytest test/test_data.py` | Confirm test coverage |
    ```

    Simple specs may skip this section. Standard and complex specs SHOULD include it when making factual claims that require verification.

- [ ] 16. **Step 1.1: SC Coverage YAML Generation (SC-4, SC-28)** — After assembling the spec content, generate a machine-parseable SC coverage summary at `.issues/{issue-N}/sc-summary.yaml`:

    ```yaml
    sc_coverage:
      total: <integer>
      single_task: <true|false>
      spec_url: {browser_url}/{owner}/{repo}/issues/{N}
      evidence_types:
        - behavioral
        - semantic
        - string
        - structural
      phases:
        - id: <phase_name>
          sc_ids: [SC-N, SC-M]
          evidence_types: [behavioral, string]
      cross_cutting:
        sc_ids: [SC-N]
        verified_in_phase: <phase_name>
      scs:
        - id: SC-N
          description: "<brief description>"
          evidence_type: <behavioral|semantic|string|structural>
          verification_gate: <pre-commit|pre-approval-gate|ci|post-implementation>
          plan_phase: <phase_name>
    ```

    The `scs` flat list is REQUIRED — the plan writer and pre-flight handoff read from this list to verify SC coverage and assign SCs to plan phases. Each SC MUST have `id`, `description`, `evidence_type`, `verification_gate`, and `plan_phase` fields. The nested `phases[].sc_ids` structure is retained for backward compatibility but the flat `scs` list is the authoritative source for plan writer consumption.

    Required validation: cross-reference `sc_coverage.total` against the prose SC table row count. Mismatch MUST be flagged as a STRUCTURE-VIOLATION.

- [ ] 17. **Step 1.2: Verification Consistency Contract Generation (SC-8)** — Generate a verification consistency solve contract at `.issues/{issue-N}/verification-consistency-contract.yaml` with a compliance matrix as solve variables:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    verification_consistency:
      sc_entries:
        - id: SC-N
          evidence_type: < behavioral | semantic | string | structural >
          verification_gate: < pre-commit | pre-approval-gate | ci |
            post-implementation >
          pipeline_step_binding: < step_name >
          re_entry_step: < step_name | null >
          phase_binding: < phase_name | common >
          artifact_path: < path >
      constraints:
        - 'for_every_sc: evidence_type_is_consistent_with_verification_gate'
        - 'for_every_sc: pipeline_step_binding_is_valid_for_phase'
    ```

    The pre-approval gate validates every SC's Verification Gate against its Evidence Type. SAT for compliant specs, UNSAT with unsat_core for non-compliant.

- [ ] 18. **Step 1.3: Lifecycle Manifest Initialization (SC-6)** — Initialize the append-only lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` with a `spec_created` event:

    ```yaml
    events:
      - event: spec_created
        timestamp: <YYYY-MM-DDTHH:MM:SSZ>
        issuer: <AgentName> (<ModelId>)
        description: 'Spec #N created'
        severity: info
    ```

    Each pipeline stage appends its event. Blocker events appended on FAIL with severity, reason, and resolution fields.

- [ ] 19. **Step 1.35: Spec-to-Plan Handoff Manifest Generation (SC-27)** — Generate a spec-to-plan handoff manifest at `.issues/{issue-N}/spec-to-plan-handoff.yaml` that the plan writer and pre-flight handoff use to verify artifact completeness:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    sc_coverage_total: <integer>
    decomposition_classification: <single-task | multi-phase>
    phase_count: <integer>
    status: <complete | partial>
    artifacts:
      - path: .issues/{N}/spec.md
        required: true
      - path: .issues/{N}/sc-summary.yaml
        required: true
      - path: .issues/{N}/verification-consistency-contract.yaml
        required: true
      - path: .issues/{N}/revision-re-entry-contract.yaml
        required: true
      - path: .issues/{N}/spec-to-plan-handoff.yaml
        required: true
    ```

    The handoff manifest is consumed by `implementation-pipeline/tasks/pre-flight-handoff.md` which validates that all required artifacts exist before the pipeline proceeds. If any required artifact is missing, pre-flight returns BLOCKED.

- [ ] 19a. **Step 1.4: Revision Re-Entry Protocol Contract Generation (SC-5)** — Generate a revision re-entry solve contract at `.issues/{issue-N}/revision-re-entry-contract.yaml` with cascade variables for each revision scope:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    revision_re_entry:
      revision_scopes:
        - scope: < full | partial >
          cascade_artifacts:
            - plan.md
            - sc-summary.yaml
            - verification-consistency-contract.yaml
          requires_re_approval: < true | false >
          valid_re_entry_steps:
            - step: < step_name >
          constraints:
            - 'on_partial_revision: cascade_is_limited_to_affected_scs'
            - 'on_full_revision: all_artifacts_must_be_regenerated'
    ```

    `solve check` returns SAT for valid re-entry plans, UNSAT for insufficient replay scope.

- [ ] 20. **Step 1a: Forward-Looking Mandate (SC-1/SC-4)** — Every spec is from the point of view "NEEDS TO BE IMPLEMENTED — HERE ARE THE REQUIREMENTS." Never describe what has been done; describe what must be done.

    - **Prohibit status language** — Do not use "implemented", "pending", "confirmed", "viable", "completed" as status markers in spec body content. Status belongs on the issue as labels, not in the spec prose.
    - **Use MUST/SHOULD/MAY (RFC 2119)** for all requirements. "The system MUST log errors" not "The system logs errors". This enforces the forward-looking stance of describing what the implementation MUST achieve, not what has been decided.
    - **No tracking dashboards** — The spec is a requirements document, not a project tracker. Decision logs, status badges, and verification annotations belong in ``, not in the spec itself.

- [ ] 21. **Step 1b: Sub-Folder References, No Hardcoded File Lists (SC-9)** — Reference artifact directories by sub-folder path (e.g., ``) rather than listing individual files. Agents discover content by globbing directories; hardcoded file lists go stale when files are renamed or reorganized.

    **Correct:** "See `research/` for capability probe results"

    **Wrong:** "See `research/fastmcp-capabilities.md` for capability probe results"

- [ ] 22. **Step 1c: No Bare #N References (SC-10)** — Never use bare `#N` in any spec content. Always use the full URL: `{browser_url}/{owner}/{repo}/issues/{N}` wrapped in descriptive Markdown link text.

    | Pattern | Classification | Action |
    | ------- | -------------- | --------------------------------------------- |
    | `#46` | ❌ WRONG | Replace with full URL + descriptive link text |
    | `{browser_url}/owner/repo/issues/46` | ⚠️ Bare URL | Wrap in descriptive Markdown link text |
    | [fastmcp switch issue]({browser_url}/owner/repo/issues/46) | ✅ CORRECT | Descriptive link text |
    | [viewport-editor#46]({browser_url}/owner/repo/issues/46) | ✅ CORRECT | Link text with repo prefix |

    The agent MUST check the entire spec body for bare `#N` patterns before submission and replace any found. This applies to all cross-references regardless of whether they point to the same repo or a different repo.

- [ ] 23. **Step 2: Eliminate Ambiguity (Principle #4)** — Review every requirement statement:

    - Replace vague terms with measurable, testable statements
    - Replace "should" with "MUST", "SHALL", or "MAY"
    - Replace "fast" with specific thresholds
    - Replace "user-friendly" with specific UX criteria
    - Every "etc." must become an explicit list

    > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

- [ ] 23a. **Step 2a: Resolve Either/Or in Required Actions (SC-1)** — After eliminating ambiguity, scan all Required Actions for either/or patterns ("or", "either", "alternatively") that present two or more possible outcomes. Each Required Action MUST resolve to a single concrete outcome before the spec is finalized. If an either/or pattern is found, the agent MUST:
    - Identify which outcome is the correct single path
    - Remove the alternative outcome
    - Document the decision rationale in the Decision Ledger
    - Verify no remaining either/or ambiguity exists

- [ ] 23b. **Step 2b: Concretize Delegation Targets (SC-2)** — After resolving either/or patterns, scan all Required Actions for "delegate to", "unified", "merged into", or "replaced by" references. Each such reference MUST specify:
    - The exact file changes for each capability being migrated
    - Routing table updates (if the target file has a routing/dispatch table)
    - Cross-reference updates (if other files reference the removed file)
    - Capability migration (what happens to each unique capability of the removed file)
    
    If any delegation reference lacks these details, the agent MUST add them before the spec is finalized.

- [ ] 24. **Step 3: Define Acceptance Criteria (Principle #6)** — **🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

    | Rule | Description |
    | ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | ALL pass | Implementation is complete — proceed to next pipeline step |
    | Any SKIPPED | Treated as FAIL — skipped SCs must be explicitly documented as superseded or out of scope with rationale |
    | Any FAILED | Triggers autonomous remediation by the producing agent. Gate holds position (does not pass) until remediation is verified. If re-verification also fails (double-failure), HALT with blocker report. The agent MUST attempt remediation before any escalation. |
    | Remediated SC | Re-verified independently — same PASS/FAIL gate applies; no carryover credit from prior passes |
    | Re-verification | Repeat the verification command/assertion; confirm PASS before claiming remediation complete |

    **SC Table Format (14-column):**

    | ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
    |----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
    | SC-1 | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

    **The Verification Method column MUST specify an executable command or assertion producing deterministic PASS/FAIL. The Remediation column MUST specify what corrective action is required on FAIL and how re-verification is performed.**

    See `reference/sc-table-columns.md` for column definitions, rendering note, and per-column conditionality. See the Evidence Type Classification Gate section below for classification rules when applying these columns.

- [ ] 25. **Evidence Type Classification Gate (MANDATORY)** — When authoring success criteria, the agent MUST classify each SC's evidence type by asking: "Does this change affect runtime behavior? If YES, evidence type MUST be behavioral."

    The declared evidence type in the SC table MUST reflect the classification question's answer:

    | Change Affects Runtime Behavior? | Required Evidence Type | Minimum Verification |
    | -------------------------------- | ---------------------- | ------------------------------------- |
    | YES | `behavioral` | Test execution with output inspection |
    | NO | Per declared type | Per Evidence Type Taxonomy |

    **🚫 FORBIDDEN:** Declaring a runtime-behavioral change as `structural` or `string` evidence type. The classification question is substrate-determined — the code path either executes at runtime or it does not.

    **Remediation:** If the agent classifies an SC as structural/string for a runtime-behavioral change, the VbC pre-flight classification gate will uplift it to behavioral anyway. Classifying correctly at authorship time prevents downstream rework.

    **Authority:** `guidelines/000-critical-rules.md` §critical-rules-BEH-EV, `guidelines/080-code-standards.md` §Evidence Type Taxonomy

    <!-- Fragment ID: sc-enforcement-gate -->

    For each feature/requirement:

    - Binary pass/fail criteria (NOT subjective)
    - Edge case coverage
    - Negative test cases (what must NOT happen)
    - Integration test expectations
    - **Behavioral test assertions for rule-changing SCs** — Success criteria that change agent behavior (guideline rules, skill enforcement, critical violations) MUST include a behavioral test assertion describing the RED state (agent behavior without the rule) and GREEN state (agent behavior with the rule), not just a content-verification grep command. Content-verification commands are SECONDARY for rule-changing SCs; behavioral assertions are PRIMARY. See `080-code-standards.md` → Behavioral Enforcement Tests (PRIMARY).
    - **Semantic intent field** — Each success criterion MUST include a brief prose annotation explaining WHY the exact criterion value matters and what semantic distinction it represents. This prevents substituting functionally similar values. Example: "Exit code 2 specifically signals removal of a feature, distinct from exit code 1 which signals a validation failure — these are different error categories for different consumer behaviors." Without semantic intent, an SC is a checklist — it verifies that something happened, but not that the right thing happened for the right reason.

- [ ] 26. **Step 4: Determinism Gate** — For each success criterion, ask: **"If two different auditors read this SC, will they independently produce the same PASS/FAIL result against the same implementation?"**

    If the answer is "no", the SC must be rewritten.

    **Fail patterns (SC must be rewritten if any match):**

    | Pattern | Example | Problem |
    | ------- | ------- | --------------------------------------------------------------------- |
    | Adverbs without thresholds | "efficiently", "gracefully", "quickly" | Subjective — different auditors assign different thresholds |
    | Comparatives without baselines | "faster than before", "more robust" | Unknown reference point — cannot be evaluated without historical data |
    | Open-ended quality requirements | "handle edge cases", "be resilient" | No enumerated cases or failure modes specified |
    | Missing expected values | "returns the correct result", "validates input" | No concrete expected value to compare against |
    | Implicit behavior | "should not crash", "works normally" | No negative criterion — what constitutes "not crashing" is undefined |

    **Verification:** For each SC, attempt to write an executable verification command (`uv run pytest test_X.py::test_Y`, `bash verify.sh arg`, `issue-operations -> read-issue)` with specific field check). If no executable command can be written, the SC is not deterministic.

    ✅ **Gate presence verification:** Verify the all-or-nothing gate statement is present in the assembled spec body. If absent → `STRUCTURE-VIOLATION` requiring rewrite before submission.

- [ ] 27. **Step 5: Structure the Deliverable (Principle #10)** — Content coverage matters more than section structure. The agent chooses the optimal structure for the spec's complexity:

    - **Minimal specs** (bug fixes, one-file changes): May use a minimal format — Problem, Context, Fix, Criteria, Edge Cases — all in flowing prose without section headers. Preamble is optional.
    - **Standard specs** (multi-file changes): May use typical sections — Intent and Executive Summary (mandatory), Objective, Problem, Context, Fix Approach, Success Criteria, Edge Cases. Include a `## Intent and Executive Summary` preamble with the 5 fields (Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions) before the Objective section.
    - **Complex specs** (cross-cutting, multi-phase): May use full structure — Intent and Executive Summary (mandatory), Objective, Problem, Context, Affected Files, Fix Approach, Success Criteria, Edge Cases, Dependencies, Risk, Decision Rationale, Phases. Preamble is mandatory.

    **Any format that covers the required content areas is acceptable.** The agent decides the structure that best serves the specific spec.

- [ ] 28. **Step 5.5: Spec/Plan Boundary Check** — Review the assembled spec for plan-level content that belongs in the implementation plan, not the spec. Specs describe **WHAT** and **WHY**; plans describe **HOW**.

    **Replacement rules:**

    | Plan-Level Content (remove) | Spec-Level Replacement |
    | --------------------------- | --------------------------------------------------------------- |
    | Function/class definitions with code | Function names + responsibilities table |
    | SQL DDL statements (`CREATE TABLE...`) | Table names + constraints table |
    | Implementation algorithms with step-by-step logic | Input/output contract (what goes in, what comes out) |
    | File paths with "what to change" language | Affected files + anchors table (what exists, not what to write) |
    | Architecture decisions without constraints | Architecture requirements table (what the system MUST satisfy) |

    **Self-review question:** "Could two developers produce valid but different implementations from this spec?" If yes, the spec is at the right level. If no — if the spec only allows one implementation — it contains plan-level detail that should be removed.

- [ ] 29. **Step 5.6: `solve` and `plan` Utility Invocation (SC-2)** — After the spec/plan boundary check, invoke the `solve` utility to produce a dependency-ordering constraints contract:

    ```bash
    ./.opencode/tools/solve model \
      --contract-path .issues/{issue-N}/pre-approval-gate-contract.yaml \
      --output {project_root}/tmp/{issue-N}/artifacts/constraints-contract.yaml
    ```

    On success: constraints contract written to `{project_root}/tmp/{issue-N}/artifacts/constraints-contract.yaml`.
    On UNSAT: **HALT** with blocker report — do NOT proceed with manual fallback.
    On utility unavailable: **HALT** with blocker report — do NOT proceed without solve verification.

    Post-invocation verification via `solve check`:

    ```bash
    ./.opencode/tools/solve check \
      --state-path {project_root}/tmp/{issue-N}/artifacts/constraints-contract.yaml \
      --contract-path .issues/{issue-N}/pre-approval-gate-contract.yaml
    ```

    MUST return SAT. UNSAT → HALT with blocker report. No fallback paths.

    Then invoke the `plan` utility to validate spec phase structure for solvability. Load the `plan` skill for subcommand reference:

    ```bash
    skill({name: "plan"})   # load reference for plan subcommands and status codes
    ```

    Proceed with phase solvability check:

    ```bash
    ./.opencode/tools/plan plan \
      --problem {project_root}/tmp/{issue-N}/artifacts/phase-plan-problem.yaml \
      --output {project_root}/tmp/{issue-N}/artifacts/phase-plan-validated.yaml
    ```

    On success: planner returns SOLVED_SATISFICING or SOLVED_OPTIMALLY per `plan` skill → `plan.md` task.
    On UNSOLVABLE or utility unavailable: **HALT** with blocker report. Refer to `plan` skill → `fallback.md` task for manual acyclic check when planner is unavailable.

- [ ] 30. **Step 6: Self-Review** — After writing the spec, review with fresh eyes:

    - [ ] **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
    - [ ] **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
    - [ ] **Scope check:** Is this focused enough for a single implementation plan, or does it need decomposition?
    - [ ] **Ambiguity check:** Could any requirement be interpreted two different ways? If so, pick one and make it explicit.

    Fix any issues inline. No need to re-review — just fix and move on.

    **Prose-structure check:** After checking for placeholders, consistency, scope, and ambiguity, verify that the spec body is prose-first. Rigid numbered procedures where flowing prose would serve better, tabular mappings that should be prose descriptions, and fixed checklists that have replaced narrative should be flagged and rewritten. Success criteria table FORMAT and affected file tables are exempt from this check as they are naturally structured content. However, the VERIFICATION METHOD CONTENT within SC table columns must meet the same precision standards as prose — a verification method that says "check exit code" is no more acceptable inside a table cell than it would be in a paragraph.

    **SC Verification Column Precision Sub-Check:** Scan the Verification column of every SC table for vague verification methods (describes what to check without specifying exact expected value). Flag each vague entry as a STRUCTURE-VIOLATION requiring rewrite with an executable verification command per `140-planning-spec-creation.md` Executable Verification Commands mandate. The spec should read as a coherent narrative document, not as a mechanical checklist.

    - [ ] **SC-to-SC coherence check**: Scan SC table for contradictions between interdependent criteria. Cross-reference Pipeline Step Binding and Verification Gate columns — verify that an SC gated at 'red-green' does not require a 'ci' tool. Cross-reference Re-Entry Step with Phase Binding — verify re-entry point is valid for the bound phase. Cross-reference Affinity Group members — verify shared SCs have compatible verification methods.

    - [ ] **Verification-Method-to-Artifact-Path consistency check**: Cross-reference Artifact Path and Verification Method columns — verify that the Verification Method's tool references align with the Artifact Path's storage convention. An SC whose Verification Method references 'pytest' should have an Artifact Path matching '{issue-N}/pytest/' convention. An SC whose Verification Method references 'opencode-cli run' should have an Artifact Path matching '{issue-N}/behavioral/' convention.

    - [ ] **YAML-vs-prose SC coverage validation**: Cross-reference `sc-summary.yaml` (from Step 1.1) against the prose SC table. Verify:

       - `sc_coverage.total` matches the number of SC rows in the prose table
       - Every SC ID in the prose table appears in `sc_coverage.phases[].sc_ids` or `sc_coverage.cross_cutting.sc_ids`
       - Every SC ID in `sc-summary.yaml` appears in the prose table
       - Mismatch in any direction → STRUCTURE-VIOLATION requiring YAML regeneration

- [ ] 31. **Step 6.2: Post-SC Uplift Check (MANDATORY)** — After self-review, before evidence artifact verification, perform a post-creation SC evidence type uplift check:

    1. **SC evidence type re-check**: For each SC in the spec body, evaluate the substrate question: "Does this change affect runtime behavior?"
    2. **Uplift misclassified SCs**: If runtime-behavioral YES but evidence type is NOT behavioral → auto-uplift to `behavioral`. Log the uplift action as a finding.
    3. **Downgrade flag (conditional)**: If runtime-behavioral NO but evidence type IS behavioral → flag for review. The writer may have intended a behavioral test for structural reasons, but this mismatch warrants human review.
    4. **Remediation guidance**: For each uplifted SC, provide guidance on what changes the verification method needs:
       - `structural` → `behavioral`: Must add a real test execution command (e.g., `opencode-cli run`, `pytest`, `bash test.sh`)
       - `string` → `behavioral`: Must replace grep assertion with test execution + semantic inspection
    5. **Re-check**: After remediation, re-run the classification check. Confirm no remaining misclassifications.
    6. **Evidence artifact**: Write findings to `.issues/{N}/post-sc-uplift-check.yaml`

- [ ] 32. **Step 6.5: Evidence Artifact Verification (MANDATORY)** — **🚫 CRITICAL: Each self-review checkpoint MUST produce a tool-call artifact demonstrating the verification was performed. Assertions without tool-call evidence are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

    | Checkpoint | Verification Action | Tool Call | Problem Class |
    | ---------- | ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ------------------- |
    | No placeholders remain | Verify spec body contains no "TBD", "TODO", "FIXME", or incomplete section markers | `issue-operations -> read-issue` → search body for `/TBD\|TODO\|FIXME/` | STRUCTURE-VIOLATION |
    | Internal consistency | Cross-reference requirement IDs between sections; verify no contradictions | `issue-operations -> read-issue` → parse section anchors vs referenced IDs | CONFLICTING |
    | Scope check evidence | Verify scope is appropriate for single plan or flagged for decomposition | `issue-operations -> read-issue` → count affected files, check for phase markers | VERIFICATION-GAP |
    | Ambiguity resolved | Verify no requirement can be interpreted two ways | `issue-operations -> read-issue` → scan for "should", "etc.", vague terms | STRUCTURE-VIOLATION |

    **Evidence format:**

    ```
    Check: [what was verified]
    Tool: [tool call and parameters]
    Result: [actual state found]
    Classification: [STRUCTURE-VIOLATION|MISSING-ELEMENT|CONFLICTING|VERIFICATION-GAP|MISSING-TRACEABILITY]
    Action: [auto-fix|conditional|flag-for-review]
    ```

    **Classification on failure:**

    | Failure | Problem Class | Classification | Action |
    | ------------------------------------------ | ------------------- | --------------- | ------------------------------------------- |
    | Placeholders found in spec body | STRUCTURE-VIOLATION | auto-fix | Replace with concrete content |
    | Contradictory requirements across sections | CONFLICTING | flag-for-review | Report, do not auto-resolve |
    | Scope too large for single plan | VERIFICATION-GAP | conditional | Flag decomposition, then apply if confirmed |
    | Vague/ambiguous terms present | STRUCTURE-VIOLATION | auto-fix | Replace with measurable terms |

    **These verifications are MANDATORY after self-review. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

- [ ] 33. **Post-Review: Verification Revisit (MANDATORY)** — After Step 6 self-review and Step 6.5 evidence verification, invoke `verification-enforcement --task revisit`. This pass scans the spec for any remaining `⚠️ UNVERIFIED` markers and attempts to resolve them using domain-appropriate tools. Claims that cannot be resolved are escalated to the developer. The spec must not be submitted to the remote platform while unverified claims remain without developer acknowledgment.

- [ ] 34. **Step 6.8: Generate Spec Folder URL (SC-6)** — Generate the spec folder URL and prepare the blockquote for embedding at the top of the issue body. Follow the `.issues/AGENTS.md` pattern:

    ```
    > **Full spec and artifacts: [`.issues/{N}/`]({html_url}/{owner}/{repo}/tree/issues-data/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
    >
    > **Local artifacts:** `.issues/{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
    ```

    The URL follows the pattern: `{html_url}/{owner}/{repo}/tree/issues-data/{N}` where `{html_url}`, `{owner}`, and `{repo}` are resolved from the session-init repo entry whose `path` matches the issue's repo. See `.issues/AGENTS.md` for the canonical URL convention.

    Embed this blockquote at the TOP of the issue body (before the spec content), prepended when creating the issue body or updated after creation.

- [ ] 35. **Step 7: Create Issue** — Invoke `issue-operations` skill to persist the spec as an issue:

    - [ ] Generate spec folder URL blockquote (Step 6.8) and prepend it to the issue body
    - [ ] Invoke `issue-operations --task pre-creation` to validate (check for conflicts, superseded issues, content coverage)
    - [ ] If validation fails → HALT and report. Fix issues and re-validate.
    - [ ] If validation passes → invoke `issue-operations --task single-task-check` to determine sub-issue needs
    - [ ] Invoke `issue-operations --task creation` to create the issue with the blockquote-prepended body
    - [ ] Record the issue number and URL
    - [ ] **Invoke `local-issues sync` and commit the resulting local `.issues/{N}/` directory** — this runs at spec creation time, not deferred to approval

    **Chat output is ONLY:**

    ```
    <exec summary>

    <issue URL>

    🤖 <AgentName> (<ModelId>) created
    ```

    **🚫 NEVER:**

    - Dump full spec content to chat as the "review" step
    - Claim spec is "written" without an issue URL
    - Ask the user to review the spec in chat

- [ ] 36. **Step 7r: Remote Issue Body Format** — The remote issue body is the stakeholder-facing representation of the spec. It MUST use a standardized 6-part exec summary structure that is readable without clicking any link and carries full resolved URLs.

    **1. Spec Reference Blockquote (mandatory — top of body, before all other content)**

    ```
    > Full spec and plan artifacts: {html_url}/{owner}/{repo}/tree/issues-data/{N}/
    ```

    **Construction rules (mandatory — pre-creation URL per URL Sourcing Rule 2):**

    - [ ] Resolve `html_url`, `owner`, `repo` from the session-init `## Repo Information` entry whose `path` matches the issue's repo. The session-init section provides per-repo values — do NOT use hardcoded `github.html_url` or root repo values.
    - [ ] Construct the URL: `{html_url}/{owner}/{repo}/tree/issues-data/{N}/`
    - [ ] **Character-match verification**: Confirm the constructed URL contains the exact `{owner}` and `{repo}` strings from session-init (character-for-character match, no typos)
    - [ ] **Substitution verification**: After URL construction, verify `{html_url}` was substituted (not left as a literal placeholder). If `{html_url}` remains in the constructed URL, HALT with blocker — the placeholder was not resolved.
    - [ ] **Repo-awareness guard**: Confirm owner/repo matches the target issue's repository before URL construction. If the issue resides in a submodule repo with different owner/repo, use that repo's session-init values
    - [ ] All links MUST be full resolved URLs — no platform-specific shortcuts (`#NNN`, `owner/repo#NNN`)

    **2. Problem (mandatory)**

    What problem this solves, why now, business/user impact. BLUF — lead with outcome, not mechanism.

    **3. Scope (mandatory)**

    3-5 bullets in-scope. Explicit out-of-scope list. Stakeholder-facing outcomes, not implementation details.

    **4. Approach (mandatory)**

    High-level solution in 3-5 sentences. Names the approach, not the implementation.

    **5. Impact (mandatory)**

    Top 3 risks with one-line mitigation. Key dependencies. Call to action.

    **6. AI Agent Instructions (mandatory)**

    ```
    ## AI Agent Instructions

    This issue is an executive summary for human stakeholders.
    The authoritative spec and plan artifacts are at {{SPEC_PATH}}.
    After creation, `local-issues sync {N}` MUST be run and the result committed to create the local `.issues/{N}/` entry.
    The implementation plan will be created in `.issues/{N}/plan.md` after approval.
    AI agents MUST read the local spec/plan files for implementation
    and MUST NOT base implementation on this summary.
    ```

    **Constraints table:**

    | Constraint | Value |
    | ---------- | ----------------------------------------------------------------------------------------------------------------------- |
    | Length | Concise — 150-300 words, 1 page max (readability guideline, not complexity measure) |
    | Structure | BLUF — conclusion/action first, context second, evidence third |
    | Tone | Assertive, decision-oriented, jargon-free, third-person |
    | Independence | Fully readable without clicking any link |
    | Links | All links MUST be full resolved URLs from session-init — no platform-specific shortcuts. Repo-awareness guard required. |
    | Exclusions | No implementation details, file paths, algorithms, methodology, unreferenced acronyms |
    | Platform | Platform-agnostic — no hardcoded GitHub/GitBucket tool names |

    **Clarification:** The Intent and Executive Summary 5-field table (Problem, Root Cause/Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions) from Step 5 goes in the LOCAL spec (`.issues/N/spec.md`), NOT the remote issue body.

- [ ] 37. **Step 7a: Exec-Summary Format Rules** — The exec summary embedded in the remote issue body MUST follow these formatting constraints:

    - **No checkboxes, no status markers, no completion flags** — the issue body is a requirements document, not a project tracker
    - **Cards listed in dependency order** — implementable sequence, not alphabetical or priority order
    - **Include `Key Decisions` section** — document trade-offs and rationale from the card catalogue
    - **Include `Risk Callouts` section** — surface risks that affect implementation approach or timeline

    **Rules table:**

    | Rule | Rationale |
    | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
    | No checkboxes/status markers | Issue body is a requirements document, not a tracker. Status belongs on platform labels and sub-issue state. |
    | Dependency-ordered cards | Implementation follows dependency order; the exec summary must reflect the sequence the implementer will follow. |
    | Key Decisions section | Design decisions made during spec creation must be visible to the implementer without reading the full card catalogue. |
    | Risk Callouts section | Risks that affect implementation approach or timeline must be surfaced at the top of the issue, not buried in appendix content. |

    **Example format:**

    ```
    > **Full spec and artifacts: `.issues/{N}/`**

    ## Exec Summary

    Describes what this spec achieves at a high level — one to two sentences
    on the problem and the chosen approach.

    ### Cards (dependency order)
    1. **First dependency** — What must be built before anything else
    2. **Core implementation** — The primary change this spec requires
    3. **Follow-up work** — What depends on the core change
    4. **Verification and cleanup** — Tests, migration, documentation

    ### Key Decisions
    - **Decision A**: Why this approach over the alternatives
    - **Decision B**: Trade-off accepted and why

    ### Risk Callouts
    - **Risk A**: What could go wrong and what mitigates it
    - **Risk B**: Known unknowns that affect timeline or approach
    ```

- [ ] 38. **Step 7b: Remote Push + Local Mirror** — After creating the issue in Step 7, save a local mirror of the exec summary:

    - [ ] Remote push happens first (Step 7 creates the issue on the remote platform via `issue-operations --task creation`)
    - [ ] Save `.issues/{N}/remote-exec-summary.md` with the exec summary content that was posted to the remote
    - [ ] Verify the `.issues/` directory pattern is followed (`.issues/{N}/remote-exec-summary.md`)

    This ensures the local workspace mirrors the remote state for off-network reference and diff-based drift detection.

- [ ] 38a. **Step 7c: Save Full Spec Locally (SC-29)** — After creating the remote issue, save the full spec content to the local `.issues/{N}/spec.md` file:

    - [ ] Write the complete spec body (including all sections, SC table, compliance blocks, preamble, and byline) to `.issues/{N}/spec.md`
    - [ ] The local spec.md is the authoritative spec — the remote issue body is a condensed exec summary
    - [ ] The plan writer reads from `.issues/{N}/spec.md`, not from the remote issue body
    - [ ] Verify the file was written: `ls .issues/{N}/spec.md`

- [ ] 38b. **Step 7d: Sync Local Artifacts to issues-data Branch (SC-33)** — After creating or modifying any files in `.issues/{N}/`, run `local-issues sync` to commit and push the local artifacts to the `issues-data` branch:

    - [ ] Run `.opencode/tools/local-issues sync` to commit all local `.issues/{N}/` files and push to the `issues-data` branch
    - [ ] This ensures links in the remote issue body that refer to the spec folder (`.issues/{N}/`) resolve correctly
    - [ ] The `issues-data` branch is the canonical store for all spec artifacts — without sync, downstream consumers (plan writer, auditors) cannot access the local files
    - [ ] Run `local-issues sync` after EVERY change to files in `.issues/{N}/` — not just at creation time

- [ ] 39. **Step 8: User Review on Issue** — The user reviews the spec ON THE GITHUB ISSUE, not in chat.

    - If user requests revisions via issue comments: invoke `issue-operations --task body-edit` to update the issue body, then post update summary + URL + byline to chat
    - If user approves the spec on the issue: proceed to Step 9
    - Do NOT re-dump the spec to chat for any reason

- [ ] 40. **Step 9: Transition** — After user approval of the spec on the issue, invoke `spec-auditor` for quality audit.

## Context Required

- Preceded by: `requirements` (mandatory), `decompose`, `traceability`, `risk` (or explicitly skipped)
- Extends: brainstorming Steps 7-9 (adapted, not verbatim move)
- Calls: `issue-operations` (pre-creation → single-task-check → creation → body-edit)
- Calls: `.opencode/tools/local-issues sync` (after all `.issues/{N}/` file changes)
- Followed by: `spec-auditor`, then user review on the issue