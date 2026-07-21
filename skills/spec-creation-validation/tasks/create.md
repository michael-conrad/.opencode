# Task: write

<!-- Dimensions synced from Load [holistic-dimensions.yaml](.opencode/reference/holistic-dimensions.yaml) -->
<!-- Sync locations: Load [cross-reference table](.opencode/reference/holistic-dimensions.yaml) -->

## Purpose

Assemble the final spec with acceptance criteria, ambiguity elimination, and deliverable structure. Includes self-review and user-review steps adapted from brainstorming Steps 7-9, extended with principles #4, #6, #10.

## Entry Criteria

- Requirements extraction completed (mandatory)
- Other prerequisite tasks completed

## Exit Criteria

- Issue created with `[SPEC]` prefix and `needs-approval` label
- Self-review completed (placeholder scan, consistency, scope, ambiguity)
- Chat output is ONLY: `<exec summary>` + `<issue URL>` + `<byline>` (no full spec dump)
- User reviews spec ON THE ISSUE (not in chat)
- Ready for spec-auditor and approval-gate
- `{project_root}/{path}/.issues/{N}/spec-to-plan-handoff.yaml` generated with artifact manifest (SC-27)
- `{project_root}/{path}/.issues/{N}/sc-summary.yaml` includes flat `scs` list with `id`, `description`, `evidence_type`, `verification_gate`, `plan_phase` per SC (SC-28)
- `{project_root}/{path}/.issues/{N}/spec.md` saved with full spec content (SC-29)
- `.opencode/tools/local-issues sync` run after all `{project_root}/{path}/.issues/{N}/` file changes (SC-33)

## Procedure

- [ ] 1. **Step 1: Verification Gate (MANDATORY FIRST)** — Before assembling the spec, collect evidence artifacts for the factual claims the spec will make — file references, API signatures, configuration fields, code behavior, and environment details. Evidence artifacts collected here ensure that the spec's claims are grounded in live sources. Claims that cannot be verified at this stage are marked with `⚠️ UNVERIFIED` for resolution in the post-generation revisit pass. (The SKILL.md pipeline handles verification-enforcement dispatch as an inline orchestrator step — this sub-agent does not call it.)

- [ ] 2. **Step 2: Stub Creation (SC-22 — behavioral)** — The SKILL.md pipeline handles create-remote-stub as a separate sub-task step before this sub-agent runs. This sub-agent reads the spec number from `{project_root}/{path}/.issues/{N}/remote.md` and uses it for all subsequent artifact paths. The full spec body will be populated in Step 7.

- [ ] 3. **Step 3: Behavioral Test Mandate in Success Criteria (MANDATORY)** — Behavioral enforcement tests are NOT written during spec creation. They are written during implementation, per the post-approval spec mandate. However, the spec MUST include a Success Criterion mandating behavioral test creation before implementation.

    **For rule-changing specs** (guidelines, skills, critical violations): Include a success criterion that mandates "Before any implementation, write behavioral enforcement tests in `.opencode/tests-v2/behaviors/` that verify the new rule; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes."

    **For code-changing specs**: Include a success criterion that mandates "Before any implementation, write unit or integration tests that verify the changed behavior; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes."

    **Cross-reference:** Load [Per-Item TDD Cycle → RED phase](guidelines/091-incremental-build.md), Load [SC-to-Test Traceability and RED-Phase Ordering](guidelines/080-code-standards.md), and Load [Behavioral Enforcement Tests (PRIMARY)](guidelines/080-code-standards.md) for the behavioral RED/GREEN gate.

    **Sequential per-item TDD:** Implementation phases in spec MUST enforce sequential RED/GREEN pairing per the TDD skill. Each RED must be immediately followed by its GREEN before the next RED begins. Combined RED/GREEN phases are prohibited.

    **Cost-frame mandate in SCs:** Each success criterion MUST carry a short cost-frame reformation statement that reframes what "expensive" means for that SC's domain. The statement uses the dark-prose-007 formula from Load [Section 3](guidelines/250-dark-prose-reference.md) — the implementing agent derives the exact prose autonomously based on the SC's verification method. Each SC's verification method MUST require a real test execution command — not a structural check (file exists, grep match). Structural verification is NEVER a valid substitute for behavioral execution: a skipped runtime equals a defect undiscovered. The death spiral / break dynamics are formalized in Load [Cost Model](guidelines/065-verification-honesty.md) — behavioral PASS is a break (zero downstream cost); structural-only PASS is a death spiral (compounding exponential cost).

- [ ] 4. **Step 4: Behavioral Test Definition — Stderr-Based Evidence (MANDATORY)** — Valid behavioral enforcement tests use **stderr-based assertion helpers** (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`) to verify agent actions (skill dispatches, file reads, tool invocations). **Prose-recall prompts** (e.g., "Describe how you would resolve models") produce stdout prose, not behavioral evidence, and are NOT accepted as valid behavioral tests.

    **Behavioral evidence = agent actions visible in stderr (skill dispatches, file reads, sub-agent task calls, tool invocations). Prose recall (what the agent says in stdout when asked to describe a procedure) is NOT behavioral evidence.**

    When creating the behavioral test success criterion, ensure it mandates real-domain prompts and stderr-based assertions, not prose-recall prompts.

- [ ] 5. **Step 5: Assemble Spec** — The generated spec body MUST include YAML frontmatter at the top of the LOCAL `{project_root}/{path}/.issues/{N}/spec.md` file. The remote issue body remains markdown-only (no frontmatter).

    The local `spec.md` MUST begin with YAML frontmatter:

    ```yaml
    ---
    title: <spec title>
    status: <draft|active>
    created: <YYYY-MM-DD>
    license: MIT
    provenance: AI-generated
    issue: <issue number>
    authors:
      - <AgentName> (<ModelId>)
    ---
    ```

    This frontmatter is for the LOCAL `{project_root}/{path}/.issues/{N}/spec.md` file ONLY. The remote issue body (GitHub Issue) uses markdown-only format without frontmatter.

    The local `{project_root}/{path}/.issues/{N}/spec.md` file also includes a STATUS/CREATED preamble header and compliance statement blockquotes at the top and bottom. These are for the LOCAL spec file ONLY — the remote issue body does NOT use this format.

    **Template — STATUS/CREATED header (top of local spec.md, after YAML frontmatter):**

    ```markdown
    **STATUS:** DRAFT
    **CREATED:** <YYYY-MM-DD>
    ```

    **Template — compliance blockquote (top of local spec.md body, after STATUS/CREATED):**

    ```markdown
    > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
    ```

    **Template — compliance blockquote (bottom of local spec.md, before success criteria table):**

    ```markdown
    > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
    ```

    The remote issue body (GitHub/GitBucket issue) uses a DIFFERENT format: the spec reference blockquote from Step 6.8 at the top, followed by the exec summary format from Step 7.2. The remote body MUST NOT include STATUS/CREATED headers, YAML frontmatter, or compliance blockquotes.

    Combine outputs from prerequisite tasks into a coherent spec. The spec should address the following content areas — the agent decides which sections to use and how to organize them:

    - **Objectives** — What this spec achieves
    - **Goals** — Specific, measurable goals this spec targets. Must be testable and binary.
    - **Non-Goals** — Explicitly out of scope: what this spec does NOT address. Each non-goal is a bullet item with rationale.
    - **Constraints and scope** — What's in and out of scope
    - **Root Cause Analysis** — Required section between Problem and Success Criteria. Documents the root cause of the problem, not just the symptoms. Feeds Correctness and Traceability dimensions of the holistic gate.
    - **Alternatives Considered & Why Discarded** — Required field in the preamble. Each alternative must have a discard rationale. Feeds Implementability dimension of the holistic gate.
    - **Safety Considerations** — Required when the spec involves destructive operations, data mutations, or security-sensitive changes. Documents rollback plans and safeguards. Feeds Safety dimension of the holistic gate.
    - **Evidence/Provenance** — Every factual claim in the spec body must be backed by a tool-call artifact (srclight, grep, read, webfetch). Claims without evidence are flagged before finalization. Feeds Provenance dimension of the holistic gate.
    - **SC-to-Root-Cause Traceability Table** — Maps each SC to the root cause element it tests. Feeds Traceability dimension of the holistic gate.
    - **Feasibility Assessment** — Before including a file/function/library reference in the spec, verify it exists. References to non-existent artifacts are flagged before finalization. Feeds Feasibility dimension of the holistic gate.
    - **Success criteria** — Testable, binary pass/fail conditions
    - **Risk and edge cases** — What could go wrong and boundary conditions
    - **Implementation approach** — For the reader's understanding, not prescribing HOW (see Step 5.5)

    All sections are mandatory. The spec should be self-contained and clear, regardless of structure.

    **Guidance: Escape Hatch Prohibition** — The spec body must not contain language that lets the agent short-circuit requirements. Prohibited patterns: "use best judgment", "if time permits", "simplify if needed", "TBD", "TODO", "left to implementor", "implementor's choice", "optionally", "preferably", "ideally", "should" (as weasel word), "as appropriate", "as needed" (without criteria).

    **Guidance: Live-Source Verification** — Before any factual claim enters the spec body, verify it against a live source (srclight, grep, read, webfetch). No claim from memory or training data. Every assertion about code state, API behavior, or file existence must be backed by a tool-call artifact.

    **Guidance: Preamble-Body Alignment** — The preamble's problem statement must match the body's SCs. If the preamble says "fix X" but the SCs test Y, the spec is incorrect. Verify alignment before finalization.

    **Optional content sections (include as needed):**

    - **Decision Ledger** — Captures design decisions with stable DEC-IDs and RFC 2119 requirement keys (MUST/SHOULD/MAY) for traceability across spec revisions.

        ```markdown
        | DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
        |--------|----------|-----------|-----------------|--------------|
        | DEC-1 | Use async API | Non-blocking I/O required for throughput | MUST | SC-3, SC-4 |
        ```

    - **Risk Traceability Table** — Maps RISK-IDs to Verifying SC binding, ensuring each identified risk has a corresponding success criterion that validates its mitigation.

        ```markdown
        | RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
        |---------|-----------------|------------|--------|------------|--------------|
        | RISK-1 | Rate limit exceeded | Medium | High | Implement retry with backoff | SC-7 |
        ```

    - **Revision Policy** — Declares artifact cascade: when a parent spec is revised, which dependent artifacts MUST also be revised. Uses declarative table format.

        ```markdown
        | Artifact | Cascade Trigger | Action on Parent Revision |
        |----------|----------------|---------------------------|
        | Implementation plan | MUST | Revise to match revised spec |
        | Behavioral tests | SHOULD | Review for continued validity |
        | Risk traceability | MAY | Update if new risks introduced |
        ```

    - **Decomposition Classification** — Distinguishes single-task specs from multi-phase specs using distinguishing criteria.

        | Classification | Number of Phases | Phase Artifact Requirements | PR Strategy |
        | -------------- | ---------------- | --------------------------- | ----------- |
        | single-task | 1 | Single `plan.md` file | single PR |
        | multi-phase | 2+ | One `plan-{NN}.md` phase file per phase (local `.issues/` only — do NOT create GitHub Issues for phases) | stacked PRs per phase |

    - **Spec Family Annotation (optional)** — Punch-list annotation for specs that belong to a family. Selector syntax documents which specs share a common concern.

        ```markdown
        family: performance-optimization
        selectors:
          - spec: #42
          - spec: glob(pattern: "specs/performance/*.md")
        ```

    - **Explicit Non-Goals** — Lists what the spec explicitly does NOT address. Each non-goal is a bullet item with rationale.

        ```markdown
        - **Internationalization** — Out of scope for this release; will be addressed in a follow-up spec.
        - **Backward compatibility with v1 API** — Breaking changes are accepted per the deprecation policy.
        ```

    - **Regression Invariants** — Numbered list of behaviors or properties that MUST NOT change as a result of this implementation.

        - [ ] 1. Existing authentication flows MUST continue to accept current tokens.
        - [ ] 1. All existing public API signatures MUST remain unchanged.
        - [ ] 1. Database schema migration MUST NOT drop existing columns.

    - **Cross-Cutting / Common SC Designation** — When a success criterion applies across multiple phases, designate it as cross-cutting using a preamble section marker. Cross-cutting SCs share a verification budget: a single PASS verifies the SC for all phases. MUST pass once for all phases.

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

        This section is MANDATORY for all specs. Each URL listed MUST be verified as reachable before the spec is submitted. Unreachable URLs MUST be replaced or marked with `⚠️ UNREACHABLE`. Online (live) documentation is preferred; local docs are fallback only.

- [ ] 6. **Step 6: Generate Spec Artifacts (MANDATORY)** — Generate the following permanent artifacts:

    - [ ] **SC coverage summary YAML** — Create `{project_root}/{path}/.issues/{issue-N}/sc-summary.yaml` with machine-parseable coverage data including SC IDs, evidence types, phase bindings, and verification gates.
    - [ ] **Verification consistency contract** — Create `{project_root}/{path}/.issues/{issue-N}/verification-consistency-contract.yaml` as a solve contract with compliance matrix variables.
    - [ ] **Lifecycle manifest** — Create `{project_root}/{path}/.issues/{N}/lifecycle.yaml` with initial `spec_created` event. Append-only format; never overwrite.
    - [ ] **Revision re-entry protocol contract** — Create `{project_root}/{path}/.issues/{issue-N}/revision-re-entry-contract.yaml` as a solve contract with cascade variables for each revision scope.

    Artifact generation occurs during Step 1 assembly. Self-review (Step 6) validates YAML-vs-prose consistency.

- [ ] 7. **Step 7: Plan Creation Mandate in Spec Body (MANDATORY)** — The generated spec body MUST include a paragraph in the preamble or before the Success Criteria section that mandates plan creation via `writing-plans`:

    ```markdown
    After this spec is approved, invoke `writing-plans` to create `{project_root}/{path}/.issues/{N}/plan.md` before implementation begins.
    ```

    Where `{N}` is the actual issue number, substituted at generation time. This mandate is in the spec content (what the writer generates), not just the task procedure.

- [ ] 8. **Step 8: SC Coverage YAML Generation (SC-4, SC-28)** — After assembling the spec content, generate a machine-parseable SC coverage summary at `{project_root}/{path}/.issues/{issue-N}/sc-summary.yaml`:

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

- [ ] 9. **Step 9: Verification Consistency Contract Generation (SC-8)** — Generate a verification consistency solve contract at `{project_root}/{path}/.issues/{issue-N}/verification-consistency-contract.yaml` with a compliance matrix as solve variables:

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

- [ ] 10. **Step 10: Lifecycle Manifest Initialization (SC-6)** — Initialize the append-only lifecycle manifest at `{project_root}/{path}/.issues/{N}/lifecycle.yaml` with a `spec_created` event:

    ```yaml
    events:
      - event: spec_created
        timestamp: <YYYY-MM-DDTHH:MM:SSZ>
        issuer: <AgentName> (<ModelId>)
        description: 'Spec #N created'
        severity: info
    ```

    Each pipeline stage appends its event. Blocker events appended on FAIL with severity, reason, and resolution fields.

- [ ] 11. **Step 11: Spec-to-Plan Handoff Manifest Generation (SC-27)** — Generate a spec-to-plan handoff manifest at `{project_root}/{path}/.issues/{issue-N}/spec-to-plan-handoff.yaml` that the plan writer and pre-flight handoff use to verify artifact completeness:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    sc_coverage_total: <integer>
    decomposition_classification: <single-task | multi-phase>
    phase_count: <integer>
    status: <complete | partial>
    artifacts:
      - path: {project_root}/{path}/.issues/{N}/spec.md
        required: true
      - path: {project_root}/{path}/.issues/{N}/sc-summary.yaml
        required: true
      - path: {project_root}/{path}/.issues/{N}/verification-consistency-contract.yaml
        required: true
      - path: {project_root}/{path}/.issues/{N}/revision-re-entry-contract.yaml
        required: true
      - path: {project_root}/{path}/.issues/{N}/spec-to-plan-handoff.yaml
        required: true
    ```

    The handoff manifest is consumed by Load [pre-flight-handoff.md](implementation-pipeline/tasks/pre-flight-handoff.md) which validates that all required artifacts exist before the pipeline proceeds. If any required artifact is missing, pre-flight returns BLOCKED.

- [ ] 12. **Step 12: Revision Re-Entry Protocol Contract Generation (SC-5)** — Generate a revision re-entry solve contract at `{project_root}/{path}/.issues/{issue-N}/revision-re-entry-contract.yaml` with cascade variables for each revision scope:

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

- [ ] 13. **Step 13: Forward-Looking Mandate (SC-1/SC-4)** — Every spec is from the point of view "NEEDS TO BE IMPLEMENTED — HERE ARE THE REQUIREMENTS." Never describe what has been done; describe what must be done.

    - **Prohibit status language** — Do not use "implemented", "pending", "confirmed", "viable", "completed" as status markers in spec body content. Status belongs on the issue as labels, not in the spec prose.
    - **Use MUST/SHOULD/MAY (RFC 2119)** for all requirements. "The system MUST log errors" not "The system logs errors". This enforces the forward-looking stance of describing what the implementation MUST achieve, not what has been decided.
    - **No tracking dashboards** — The spec is a requirements document, not a project tracker. Decision logs, status badges, and verification annotations belong in ``, not in the spec itself.

- [ ] 14. **Step 14: Research Card References (MANDATORY)** — Include references to consulted research cards in the spec body. If research cards were consulted during requirements extraction, reference them in the Documentation Sources section. Format: `| Research cards | \`.opencode/.issues/research-cards/<card-name>.md\` | Findings incorporated for <topic> |`

- [ ] 15. **Step 15: Live Documentation URL Verification (MANDATORY)** — Before the spec is finalized, verify that all documentation source URLs listed in the Documentation Sources section are live and reachable. For each URL:
    - Use `webfetch` or `ddg-search_fetch_content` to confirm the URL returns a 200-level response
    - If a URL is unreachable, replace it with a working alternative or mark it as `⚠️ UNREACHABLE` with a note
    - Prefer online (live) documentation over local; local docs are fallback only
    - Document which URLs were verified and which were unreachable in the spec body
    - This verification MUST be performed before the spec is submitted to the remote platform

- [ ] 16. **Step 16: Interdependency Section (MANDATORY)** — Add an Interdependency section to the spec body listing related issues with classification. Format:

    ```markdown
    ## Interdependency

    | Issue | Classification | Description |
    |-------|---------------|-------------|
    | [#N]({browser_url}/{owner}/{repo}/issues/N) | BLOCKS | This spec blocks issue N |
    | [#N]({browser_url}/{owner}/{repo}/issues/N) | BLOCKED_BY | This spec is blocked by issue N |
    | [#N]({browser_url}/{owner}/{repo}/issues/N) | RELATED | Related but no direct dependency |
    | [#N]({browser_url}/{owner}/{repo}/issues/N) | SUPERSEDES | This spec supersedes issue N |
    | [#N]({browser_url}/{owner}/{repo}/issues/N) | SUPERSEDED_BY | This spec is superseded by issue N |
    ```

    Classifications: BLOCKS, BLOCKED_BY, RELATED, SUPERSEDES, SUPERSEDED_BY. Mark interdependencies explicitly in both this spec and the interdependent issues.

- [ ] 17. **Step 17: Anti-Lobotomization Preamble (MANDATORY)** — Add an anti-lobotomization section to the spec body preamble. This section MUST appear in every generated spec. Language:

    ```markdown
    ## Anti-Lobotomization

    Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).
    ```

    Also add a success criterion in the SC table that explicitly forbids test lobotomization. The SC should read: "No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation" with evidence type `behavioral`.

- [ ] 18. **Step 18: Anti-Merge Gate (MANDATORY)** — Before finalizing the spec, verify that no SC conflicts with already-merged specs. Check merged PRs for related functionality. If a merged spec has SCs that conflict with this spec's SCs, flag the conflict and HALT. Do NOT proceed with conflicting SCs.

- [ ] 19. **Step 19: Doc-Source-Currency Check (MANDATORY)** — Verify that all documentation sources referenced in the spec are current (not stale). For each source:
    - Check the last-modified date or version of the source
    - If the source is a GitHub file, check its last commit date
    - If the source is an external URL, verify the content is still relevant
    - If a source is stale (outdated by more than 30 days for guidelines, 90 days for other docs), flag it and find a current replacement
    - Document which sources were checked and their currency status

- [ ] 20. **Step 20: SC-ID Traceability Check (MANDATORY)** — Verify that every SC ID in the spec maps to a unique, traceable requirement. For each SC:
    - Confirm the SC ID is unique (no duplicates)
    - Confirm the SC maps to at least one requirement in the spec body
    - Confirm the SC has a defined verification method
    - If any SC fails traceability, flag it as a STRUCTURE-VIOLATION and fix before submission

- [ ] 21. **Step 21: Sub-Folder References, No Hardcoded File Lists (SC-9)** — Reference artifact directories by sub-folder path (e.g., ``) rather than listing individual files. Agents discover content by globbing directories; hardcoded file lists go stale when files are renamed or reorganized.

    **Correct:** "See `research/` for capability probe results"

    **Wrong:** "See `research/fastmcp-capabilities.md` for capability probe results"

- [ ] 22. **Step 22: No Bare #N References (SC-10)** — Never use bare `#N` in any spec content. Always use the full URL: `{browser_url}/{owner}/{repo}/issues/{N}` wrapped in descriptive Markdown link text.

    | Pattern | Classification | Action |
    | ------- | -------------- | --------------------------------------------- |
    | `#46` | ❌ WRONG | Replace with full URL + descriptive link text |
    | `{browser_url}/owner/repo/issues/46` | ⚠️ Bare URL | Wrap in descriptive Markdown link text |
    | [fastmcp switch issue]({browser_url}/owner/repo/issues/46) | ✅ CORRECT | Descriptive link text |
    | [viewport-editor#46]({browser_url}/owner/repo/issues/46) | ✅ CORRECT | Link text with repo prefix |

    The agent MUST check the entire spec body for bare `#N` patterns before submission and replace any found. This applies to all cross-references regardless of whether they point to the same repo or a different repo.

- [ ] 23. **Step 23: Eliminate Ambiguity (Principle #4)** — Review every requirement statement:

    - Replace vague terms with measurable, testable statements
    - Replace "should" with "MUST", "SHALL", or "MAY"
    - Replace "fast" with specific thresholds
    - Replace "user-friendly" with specific UX criteria
    - Every "etc." must become an explicit list

    > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

- [ ] 24. **Step 24: Resolve Either/Or in Required Actions (SC-1)** — After eliminating ambiguity, scan all Required Actions for either/or patterns ("or", "either", "alternatively") that present two or more possible outcomes. Each Required Action MUST resolve to a single concrete outcome before the spec is finalized. If an either/or pattern is found, the agent MUST:
    - Identify which outcome is the correct single path
    - Remove the alternative outcome
    - Document the decision rationale in the Decision Ledger
    - Verify no remaining either/or ambiguity exists

- [ ] 25. **Step 25: Concretize Delegation Targets (SC-2)** — After resolving either/or patterns, scan all Required Actions for "delegate to", "unified", "merged into", or "replaced by" references. Each such reference MUST specify:
    - The exact file changes for each capability being migrated
    - Routing table updates (if the target file has a routing/dispatch table)
    - Cross-reference updates (if other files reference the removed file)
    - Capability migration (what happens to each unique capability of the removed file)
    
    If any delegation reference lacks these details, the agent MUST add them before the spec is finalized.

- [ ] 26. **Step 26: Define Acceptance Criteria (Principle #6)** — **🚫 SC-FAIL CASCADING GATE: Any SC that is skipped, deferred, weakened, or otherwise bypassed marks ALL SCs as FAIL. A PR containing any such bypass MUST be immediately rejected and trashed as defective and unusable. There is no partial credit. There is no 'close enough.' 100% clean PASS on ALL SCs is the only acceptable outcome.**

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

    Load [column definitions, rendering note, and per-column conditionality](reference/sc-table-columns.md). See the Evidence Type Classification Gate section below for classification rules when applying these columns.

- [ ] 27. **Step 27: Evidence Type Classification Gate (MANDATORY)** — When authoring success criteria, the agent MUST classify each SC's evidence type by asking: "Does this change affect runtime behavior? If YES, evidence type MUST be behavioral."

    **Presumptive runtime-behavioral file types:** Changes to the following file types ALWAYS affect runtime agent behavior and MUST be classified as `behavioral` evidence type:
    - `SKILL.md` — Trigger Dispatch Tables, Invocation sections, routing metadata
    - `tasks/*.md` — Task card procedures that sub-agents execute inline
    - `guidelines/*.md` — Enforcement blocks, critical rules, zero-tolerance mandates
    - `enforcement/*.md` — Behavioral enforcement test scenarios and assertions

    The declared evidence type in the SC table MUST reflect the classification question's answer:

    | Change Affects Runtime Behavior? | Required Evidence Type | Minimum Verification |
    | -------------------------------- | ---------------------- | ------------------------------------- |
    | YES | `behavioral` | Test execution with output inspection |
    | NO | Per declared type | Per Evidence Type Taxonomy |

    **🚫 FORBIDDEN:** Declaring a runtime-behavioral change as `structural` or `string` evidence type. The classification question is substrate-determined — the code path either executes at runtime or it does not.

    **Presumptive runtime-behavioral file types:** The following file types ALWAYS affect runtime agent behavior and MUST be classified as `behavioral` unless the agent can prove otherwise:
    - `SKILL.md` — Trigger Dispatch Tables, Invocation sections, DISPATCH_GATE protocols control agent dispatch decisions
    - `tasks/*.md` — Task file procedures control sub-agent execution behavior
    - `guidelines/*.md` — Enforcement blocks, critical violation sections, and procedural rules control agent compliance
    - `enforcement/*.md` — Enforcement gate definitions control pipeline routing

    **Remediation:** If the agent classifies an SC as structural/string for a runtime-behavioral change, the VbC pre-flight classification gate will uplift it to behavioral anyway. Classifying correctly at authorship time prevents downstream rework.

    **Authority:** Load [critical-rules-BEH-EV](guidelines/000-critical-rules.md), Load [Evidence Type Taxonomy](guidelines/080-code-standards.md)

    <!-- Fragment ID: sc-enforcement-gate -->

    For each feature/requirement:

    - Binary pass/fail criteria (NOT subjective)
    - Edge case coverage
    - Negative test cases (what must NOT happen)
    - Integration test expectations
    - **Behavioral test assertions for rule-changing SCs** — Success criteria that change agent behavior (guideline rules, skill enforcement, critical violations) MUST include a behavioral test assertion describing the RED state (agent behavior without the rule) and GREEN state (agent behavior with the rule), not just a content-verification grep command. Content-verification commands are SECONDARY for rule-changing SCs; behavioral assertions are PRIMARY. Load [Behavioral Enforcement Tests (PRIMARY)](guidelines/080-code-standards.md).
    - **Semantic intent field** — Each success criterion MUST include a brief prose annotation explaining WHY the exact criterion value matters and what semantic distinction it represents. This prevents substituting functionally similar values. Example: "Exit code 2 specifically signals removal of a feature, distinct from exit code 1 which signals a validation failure — these are different error categories for different consumer behaviors." Without semantic intent, an SC is a checklist — it verifies that something happened, but not that the right thing happened for the right reason.

- [ ] 28. **Step 28: Determinism Gate** — For each success criterion, ask: **"If two different auditors read this SC, will they independently produce the same PASS/FAIL result against the same implementation?"**

    If the answer is "no", the SC must be rewritten.

    **Fail patterns (SC must be rewritten if any match):**

    | Pattern | Example | Problem |
    | ------- | ------- | --------------------------------------------------------------------- |
    | Adverbs without thresholds | "efficiently", "gracefully", "quickly" | Subjective — different auditors assign different thresholds |
    | Comparatives without baselines | "faster than before", "more robust" | Unknown reference point — cannot be evaluated without historical data |
    | Open-ended quality requirements | "handle edge cases", "be resilient" | No enumerated cases or failure modes specified |
    | Missing expected values | "returns the correct result", "validates input" | No concrete expected value to compare against |
    | Implicit behavior | "should not crash", "works normally" | No negative criterion — what constitutes "not crashing" is undefined |

    **Verification:** For each SC, attempt to write an executable verification command (`uv run pytest test_X.py::test_Y`, `bash verify.sh arg`, `read(filePath={project_root}/{path}/.issues/{N}/spec.md)` with specific field check). If no executable command can be written, the SC is not deterministic.

    ✅ **Gate presence verification:** Verify the all-or-nothing gate statement is present in the assembled spec body. If absent → `STRUCTURE-VIOLATION` requiring rewrite before submission.

- [ ] 29. **Step 29: Structure the Deliverable (Principle #10)** — Content coverage matters more than section structure. The agent chooses the optimal structure for the spec's complexity:

    **All specs are mandatory.** Every spec MUST include: Problem Statement, Context, Success Criteria, and Edge Cases. Additional sections (Intent and Executive Summary, Affected Files, Fix Approach, Dependencies, Risk, Decision Rationale, Phases) are included as needed based on spec complexity. The agent decides the structure that best serves the specific spec. No section may be skipped based on a "simple" or "minimal" classification.

- [ ] 30. **Step 30: Spec/Plan Boundary Check** — Review the assembled spec for plan-level content that belongs in the implementation plan, not the spec. Specs describe **WHAT** and **WHY**; plans describe **HOW**.

    **Replacement rules:**

    | Plan-Level Content (remove) | Spec-Level Replacement |
    | --------------------------- | --------------------------------------------------------------- |
    | Function/class definitions with code | Function names + responsibilities table |
    | SQL DDL statements (`CREATE TABLE...`) | Table names + constraints table |
    | Implementation algorithms with step-by-step logic | Input/output contract (what goes in, what comes out) |
    | File paths with "what to change" language | Affected files + anchors table (what exists, not what to write) |
    | Architecture decisions without constraints | Architecture requirements table (what the system MUST satisfy) |

    **Self-review question:** "Could two developers produce valid but different implementations from this spec?" If yes, the spec is at the right level. If no — if the spec only allows one implementation — it contains plan-level detail that should be removed.

- [ ] 31. **Step 31: `solve` and `plan` Utility Invocation (SC-2)** — After the spec/plan boundary check, invoke the `solve` utility to produce a dependency-ordering constraints contract:

    ```bash
    ./.opencode/tools/solve model \
      --contract-path {project_root}/{path}/.issues/{issue-N}/pre-approval-gate-contract.yaml \
      --output {project_root}/{path}/.issues/{N}/artifacts/constraints-contract.yaml
    ```

    On success: constraints contract written to `{project_root}/{path}/.issues/{N}/artifacts/constraints-contract.yaml`.
    On UNSAT: **HALT** with blocker report — do NOT proceed with manual fallback.
    On utility unavailable: **HALT** with blocker report — do NOT proceed without solve verification.

    Post-invocation verification via `solve check`:

    ```bash
    ./.opencode/tools/solve check \
      --state-path {project_root}/{path}/.issues/{N}/artifacts/constraints-contract.yaml \
      --contract-path {project_root}/{path}/.issues/{issue-N}/pre-approval-gate-contract.yaml
    ```

    MUST return SAT. UNSAT → HALT with blocker report. No fallback paths.

    Then invoke the `plan` utility to validate spec phase structure for solvability. The SKILL.md pipeline handles plan plan as an inline orchestrator step — this sub-agent does not call it.

    Proceed with phase solvability check:

    ```bash
    ./.opencode/tools/plan plan \
      --problem {project_root}/{path}/.issues/{N}/artifacts/phase-plan-problem.yaml \
      --output {project_root}/{path}/.issues/{N}/artifacts/phase-plan-validated.yaml
    ```

    On success: planner returns SOLVED_SATISFICING or SOLVED_OPTIMALLY per `plan` skill → `plan.md` task.
    On UNSOLVABLE or utility unavailable: **HALT** with blocker report. Refer to `plan` skill → `fallback.md` task for manual acyclic check when planner is unavailable.

- [ ] 32. **Step 32: Plan Format Requirements** — The spec MUST mandate the following plan format requirements in its preamble or before the Success Criteria section:

    - Every dispatch step in a plan MUST use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form
    - Plan steps MUST NOT contain inline procedure text — the plan is a routing document, not a re-implementation of skill task cards
    - The full implementation pipeline must be enumerated with no skipped or combined steps, each referencing the correct skill/task combination
    - The full pipeline enumeration includes: coherence gate, pre-red-baseline, RED/GREEN per item, VbC, audit, cross-validate, regression check, finishing checklist, review-prep, cleanup

- [ ] 33. **Step 33: Self-Review** — After writing the spec, review with fresh eyes:

    - [ ] **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
    - [ ] **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
    - [ ] **Scope check:** Is this focused enough for a single implementation plan, or does it need decomposition?
    - [ ] **Ambiguity check:** Could any requirement be interpreted two different ways? If so, pick one and make it explicit.

    Fix any issues inline. No need to re-review — just fix and move on.

    **Prose-structure check:** After checking for placeholders, consistency, scope, and ambiguity, verify that the spec body is prose-first. Rigid numbered procedures where flowing prose would serve better, tabular mappings that should be prose descriptions, and fixed checklists that have replaced narrative should be flagged and rewritten. Success criteria table FORMAT and affected file tables are exempt from this check as they are naturally structured content. However, the VERIFICATION METHOD CONTENT within SC table columns must meet the same precision standards as prose — a verification method that says "check exit code" is no more acceptable inside a table cell than it would be in a paragraph.

    **SC Verification Column Precision Sub-Check:** Scan the Verification column of every SC table for vague verification methods (describes what to check without specifying exact expected value). Flag each vague entry as a STRUCTURE-VIOLATION requiring rewrite with an executable verification command per Load [140-planning-spec-creation.md](guidelines/140-planning-spec-creation.md) Executable Verification Commands mandate. The spec should read as a coherent narrative document, not as a mechanical checklist.

    - [ ] **SC-to-SC coherence check**: Scan SC table for contradictions between interdependent criteria. Cross-reference Pipeline Step Binding and Verification Gate columns — verify that an SC gated at 'red-green' does not require a 'ci' tool. Cross-reference Re-Entry Step with Phase Binding — verify re-entry point is valid for the bound phase. Cross-reference Affinity Group members — verify shared SCs have compatible verification methods.

    - [ ] **Verification-Method-to-Artifact-Path consistency check**: Cross-reference Artifact Path and Verification Method columns — verify that the Verification Method's tool references align with the Artifact Path's storage convention. An SC whose Verification Method references 'pytest' should have an Artifact Path matching '{issue-N}/pytest/' convention. An SC whose Verification Method references 'opencode run' should have an Artifact Path matching '{issue-N}/behavioral/' convention.

    - [ ] **YAML-vs-prose SC coverage validation**: Cross-reference `sc-summary.yaml` (from Step 1.1) against the prose SC table. Verify:

       - `sc_coverage.total` matches the number of SC rows in the prose table
       - Every SC ID in the prose table appears in `sc_coverage.phases[].sc_ids` or `sc_coverage.cross_cutting.sc_ids`
       - Every SC ID in `sc-summary.yaml` appears in the prose table
       - Mismatch in any direction → STRUCTURE-VIOLATION requiring YAML regeneration

- [ ] 34. **Step 34: Post-SC Uplift Check (MANDATORY)** — After self-review, before evidence artifact verification, perform a post-creation SC evidence type uplift check:

    1. **SC evidence type re-check**: For each SC in the spec body, evaluate the substrate question: "Does this change affect runtime behavior?"
    2. **Uplift misclassified SCs**: If runtime-behavioral YES but evidence type is NOT behavioral → auto-uplift to `behavioral`. Log the uplift action as a finding.
    3. **Downgrade flag (FAIL)**: If runtime-behavioral NO but evidence type IS behavioral → flag for review. The writer may have intended a behavioral test for structural reasons, but this mismatch warrants human review.
    4. **Remediation guidance**: For each uplifted SC, provide guidance on what changes the verification method needs:
       - `structural` → `behavioral`: Must add a real test execution command (e.g., `opencode run`, `pytest`, `bash test.sh`)
       - `string` → `behavioral`: Must replace grep assertion with test execution + semantic inspection
    5. **Re-check**: After remediation, re-run the classification check. Confirm no remaining misclassifications.
    6. **Evidence artifact**: Write findings to `{project_root}/{path}/.issues/{N}/post-sc-uplift-check.yaml`

- [ ] 35. **Step 35: Evidence Artifact Verification (MANDATORY)** — **🚫 CRITICAL: Each self-review checkpoint MUST produce a tool-call artifact demonstrating the verification was performed. Assertions without tool-call evidence are VERIFICATION-GAP findings per Load [065-verification-honesty.md](guidelines/065-verification-honesty.md).**

    | Checkpoint | Verification Action | Tool Call | Problem Class |
    | ---------- | ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ------------------- |
    | No placeholders remain | Verify spec body contains no "TBD", "TODO", "FIXME", or incomplete section markers | `read(filePath={project_root}/{path}/.issues/{N}/spec.md)` → search body for `/TBD\|TODO\|FIXME/` | STRUCTURE-VIOLATION |
    | Internal consistency | Cross-reference requirement IDs between sections; verify no contradictions | `read(filePath={project_root}/{path}/.issues/{N}/spec.md)` → parse section anchors vs referenced IDs | CONFLICTING |
    | Scope check evidence | Verify scope is appropriate for single plan or flagged for decomposition | `read(filePath={project_root}/{path}/.issues/{N}/spec.md)` → count affected files, check for phase markers | VERIFICATION-GAP |
    | Ambiguity resolved | Verify no requirement can be interpreted two ways | `read(filePath={project_root}/{path}/.issues/{N}/spec.md)` → scan for "should", "etc.", vague terms | STRUCTURE-VIOLATION |

    **Evidence format:**

    ```
    Check: [what was verified]
    Tool: [tool call and parameters]
    Result: [actual state found]
    Classification: [STRUCTURE-VIOLATION|MISSING-ELEMENT|CONFLICTING|VERIFICATION-GAP|MISSING-TRACEABILITY]
    Action: [auto-fix|FAIL]
    ```

    **Classification on failure:**

    | Failure | Problem Class | Classification | Action |
    | ------------------------------------------ | ------------------- | --------------- | ------------------------------------------- |
    | Placeholders found in spec body | STRUCTURE-VIOLATION | auto-fix | Replace with concrete content |
    | Contradictory requirements across sections | CONFLICTING | FAIL | Report, do not auto-resolve |
    | Scope too large for single plan | VERIFICATION-GAP | FAIL | Flag decomposition, then apply if confirmed |
    | Vague/ambiguous terms present | STRUCTURE-VIOLATION | auto-fix | Replace with measurable terms |

    **These verifications are MANDATORY after self-review. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

- [ ] 36. **Step 36: Post-Review: Verification Revisit (MANDATORY)** — After Step 6 self-review and Step 6.5 evidence verification, scan the spec for any remaining `⚠️ UNVERIFIED` markers and attempt to resolve them using domain-appropriate tools. Claims that cannot be resolved are escalated to the developer. The spec must not be submitted to the remote platform while unverified claims remain without developer acknowledgment. (The SKILL.md pipeline handles verification-enforcement revisit as an inline orchestrator step — this sub-agent does not call it.)

- [ ] 37. **Step 37: Generate Spec Folder URL (SC-6)** — Generate the spec folder URL and prepare the blockquote for embedding at the top of the issue body. Follow the pattern from Load [AGENTS.md](.issues/AGENTS.md):

    ```
    > **Full spec and artifacts: [`{path}/.issues/{N}/`]({html_url}/{owner}/{repo}/tree/issues-data/{path}/.issues/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
    >
    > **Local artifacts:** `{path}/.issues/{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
    ```

    The URL follows the pattern: `{html_url}/{owner}/{repo}/tree/issues-data/{N}` where `{html_url}`, `{owner}`, and `{repo}` are resolved from the session-init repo entry whose `path` matches the issue's repo. Load [AGENTS.md](.issues/AGENTS.md) for the canonical URL convention.

    Embed this blockquote at the TOP of the issue body (before the spec content), prepended when creating the issue body or updated after creation.

- [ ] 38. **Step 38: Local Spec Assembly (SC-29)** — After creating the remote issue, save the full spec content to the local `{project_root}/{path}/.issues/{N}/spec.md` file:

    - [ ] Write the complete spec body (including all sections, SC table, compliance blocks, preamble, byline, and YAML frontmatter) to `{project_root}/{path}/.issues/{N}/spec.md`
    - [ ] The local spec.md is the authoritative spec — the remote issue body is a condensed exec summary
    - [ ] The plan writer reads from `{project_root}/{path}/.issues/{N}/spec.md`, not from the remote issue body
    - [ ] Verify the file was written: `ls {project_root}/{path}/.issues/{N}/spec.md`

- [ ] 39. **Step 39: Post-Creation Sync (SC-33)** — After creating or modifying any files in `{project_root}/{path}/.issues/{N}/`, run `local-issues sync` to commit and push the local artifacts to the `issues-data` branch:

    - [ ] Run `.opencode/tools/local-issues sync` to commit all local `{project_root}/{path}/.issues/{N}/` files and push to the `issues-data` branch
    - [ ] This ensures links in the remote issue body that refer to the spec folder (`{path}/.issues/{N}/`) resolve correctly
    - [ ] The `issues-data` branch is the canonical store for all spec artifacts — without sync, downstream consumers (plan writer, auditors) cannot access the local files
    - [ ] Run `local-issues sync` after EVERY change to files in `{project_root}/{path}/.issues/{N}/` — not just at creation time

- [ ] 41. **Step 41: User Review on Issue** — The user reviews the spec ON THE GITHUB ISSUE, not in chat.

    - If user requests revisions via issue comments: invoke `issue-operations --task body-edit` to update the issue body, then post update summary + URL + byline to chat
    - If user approves the spec on the issue: proceed to Step 9
    - Do NOT re-dump the spec to chat for any reason

- [ ] 42. **Step 42: Transition** — After user approval of the spec on the issue, the SKILL.md pipeline handles spec-audit as an inline orchestrator step — this sub-agent does not call it.

## Context Required

- Preceded by: `requirements` (mandatory), `decompose`, `traceability`, `risk` (or explicitly skipped)
- Extends: brainstorming Steps 7-9 (adapted, not verbatim move)
- Calls: `.opencode/tools/local-issues sync` (after all `{project_root}/{path}/.issues/{N}/` file changes)
- Followed by: `spec-auditor`, then user review on the issue

## Input Artifacts

This sub-agent reads prior artifacts from the following paths under `{project_root}/{path}/.issues/{N}/artifacts/`:

| # | Artifact | Path |
|---|----------|------|
| 1 | Pre-spec inspection | `{project_root}/{path}/.issues/{N}/artifacts/pre-spec-inspection.yaml` |
| 2 | Research cards consulted | `{project_root}/{path}/.issues/{N}/artifacts/research-cards-consulted.yaml` |
| 3 | Requirements | `{project_root}/{path}/.issues/{N}/artifacts/requirements.yaml` |
| 4 | Concern map | `{project_root}/{path}/.issues/{N}/artifacts/concern-map.yaml` |
| 5 | Decomposition | `{project_root}/{path}/.issues/{N}/artifacts/decomposition.yaml` |
| 6 | Blast radius | `{project_root}/{path}/.issues/{N}/artifacts/blast-radius.yaml` |
| 7 | Cross-cutting matrix | `{project_root}/{path}/.issues/{N}/artifacts/cross-cutting-matrix.yaml` |
| 8 | Traceability | `{project_root}/{path}/.issues/{N}/artifacts/traceability.yaml` |
| 9 | Code path inventory | `{project_root}/{path}/.issues/{N}/artifacts/code-path-inventory.yaml` |
| 10 | Interface compatibility | `{project_root}/{path}/.issues/{N}/artifacts/interface-compatibility.yaml` |
| 11 | State analysis | `{project_root}/{path}/.issues/{N}/artifacts/state-analysis.yaml` |
| 12 | SC pipeline readiness | `{project_root}/{path}/.issues/{N}/artifacts/sc-pipeline-readiness.yaml` |
| 13 | Testability assessment | `{project_root}/{path}/.issues/{N}/artifacts/testability-assessment.yaml` |
| 14 | Risk | `{project_root}/{path}/.issues/{N}/artifacts/risk.yaml` |
| 15 | Interdependency check | `{project_root}/{path}/.issues/{N}/artifacts/interdependency-check.yaml` |

## Result Contract

| Field | Value |
|-------|-------|
| `status` | `DONE` \| `BLOCKED` |
| `finding_summary` | `"Spec #N written with M SCs"` |
| `artifact_path` | `{project_root}/{path}/.issues/{N}/spec.md` |
| `blocker_reason` | `<why if BLOCKED>` |