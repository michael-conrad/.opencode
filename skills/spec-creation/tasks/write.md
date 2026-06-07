# Task: write

## Purpose

Assemble the final spec with acceptance criteria, ambiguity elimination, and deliverable structure. Includes self-review and user-review steps adapted from brainstorming Steps 7-9, extended with principles #4, #6, #10.

## Entry Criteria

- Requirements extraction completed (mandatory)
- Other prerequisite tasks completed or explicitly skipped via simplicity heuristic

## Exit Criteria

- GitHub Issue created with `[SPEC]` prefix and `needs-approval` label
- Self-review completed (placeholder scan, consistency, scope, ambiguity)
- Chat output is ONLY: `<exec summary>` + `<issue URL>` + `<byline>` (no full spec dump)
- User reviews spec ON THE ISSUE (not in chat)
- Ready for spec-auditor and approval-gate

## Procedure

### Pre-Step: Verification Gate (MANDATORY FIRST)

Before assembling the spec, invoke `verification-enforcement --task verify`. This gate task()s section-based sub-agents to collect evidence artifacts for the factual claims the spec will make — file references, API signatures, configuration fields, code behavior, and environment details. Evidence artifacts collected here ensure that the spec's claims are grounded in live sources. Claims that cannot be verified at this stage are marked with `⚠️ UNVERIFIED` for resolution in the post-generation revisit pass.

### Step 0.5: Behavioral Test Mandate in Success Criteria (MANDATORY)

**Behavioral enforcement tests are NOT written during spec creation.** They are written during implementation, per the post-approval spec mandate. However, the spec MUST include a Success Criterion mandating behavioral test creation before implementation.

**For rule-changing specs** (guidelines, skills, critical violations): Include a success criterion that mandates "Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rule; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes."

**For code-changing specs**: Include a success criterion that mandates "Before any implementation, write unit or integration tests that verify the changed behavior; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes."

**Cross-reference:** See `091-incremental-build.md` → Per-Item TDD Cycle → RED phase, `080-code-standards.md` → SC-to-Test Traceability and RED-Phase Ordering, and `080-code-standards.md` → Behavioral Enforcement Tests (PRIMARY) for the behavioral RED/GREEN gate.

**Cost-frame mandate in SCs:** Each success criterion MUST carry a short cost-frame reformation statement that reframes what "expensive" means for that SC's domain. The statement uses the dark-prose-007 formula from `250-dark-prose-reference.md` §Section 3 — the implementing agent derives the exact prose autonomously based on the SC's verification method. Each SC's verification method MUST require a real test execution command — not a structural check (file exists, grep match). Structural verification is NEVER a valid substitute for behavioral execution: a skipped runtime equals a defect undiscovered. The death spiral / break dynamics are formalized in `065-verification-honesty.md` §Cost Model — behavioral PASS is a break (zero downstream cost); structural-only PASS is a death spiral (compounding exponential cost).

### Step 0.5a: Behavioral Test Definition — Stderr-Based Evidence (MANDATORY)

Valid behavioral enforcement tests use **stderr-based assertion helpers** (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`) to verify agent actions (skill dispatches, file reads, tool invocations). **Prose-recall prompts** (e.g., "Describe how you would resolve models") produce stdout prose, not behavioral evidence, and are NOT accepted as valid behavioral tests.

**Behavioral evidence = agent actions visible in stderr (skill dispatches, file reads, sub-agent task() calls, tool invocations). Prose recall (what the agent says in stdout when asked to describe a procedure) is NOT behavioral evidence.**

When creating the behavioral test success criterion, ensure it mandates real-domain prompts and stderr-based assertions, not prose-recall prompts.

### Pre-Step 0.8: Remote Stub Creation (SC-22)

After the card catalogue is complete but before requirements extraction begins, dispatch a routed `local-issues create` call with a minimal exec summary:

1. Dispatch: `.opencode/tools/local-issues create --title "<spec-title>" --labels SPEC`
2. Capture the returned issue number `N` — this number is used for all subsequent:
   - Local paths (`.issues/{N}/`)
   - Spec body cross-references
   - Artifact directories (`spec-artifacts/`)
3. The stub body MUST be minimal: title + dependency list + "Full spec forthcoming at `.issues/{N}/`"
4. The stub body is later replaced with the full exec summary in Step 7b

**Rationale:** Creating the remote stub early establishes the issue number that all downstream paths depend on. Waiting until Step 7 means artifact directories, cross-references, and spec folder URLs cannot reference the final issue number during spec creation. The stub body is explicitly temporary — Step 7b replaces it with the final exec summary.

### Step 1: Assemble Spec

Combine outputs from prerequisite tasks into a coherent spec. The spec should address the following content areas — the agent decides which sections to use and how to organize them:

- **Objectives and goals** — What this spec achieves
- **Explicit Non-Goals** — MUST be present (mandatory, not optional). Template header followed by bullet list of exclusions.
- **Regression Invariants** — MUST be present (mandatory, not optional), appearing directly after Explicit Non-Goals. Numbered list of things that MUST NOT change.
- **Constraints and scope** — What's in and out of scope
- **Success criteria** — Testable, binary pass/fail conditions
- **Risk and edge cases** — What could go wrong and boundary conditions
- **Implementation approach** — For the reader's understanding, not prescribing HOW (see Step 5.5)

Skip areas that don't apply to simple specs; add areas that do. **Exception:** Explicit Non-Goals and Regression Invariants are mandatory for ALL specs regardless of complexity. The spec should be self-contained and clear, regardless of structure.

### Preamble Section: Decision Ledger (SC-8)

Records architectural decisions with stable identifiers and explicit requirement obligation levels. Each decision MUST carry a DEC-ID and a table mapping requirement keys (MUST/SHOULD/MAY per RFC 2119) to their functional areas.

```markdown
### Decision Ledger

| DEC-ID | Decision | Rationale | MUST | SHOULD | MAY |
|--------|----------|-----------|------|--------|-----|
| DEC-1 | Use polling over webhooks | Simpler deployment, no external endpoint requirement | Poll interval ≤ 30s | Configurable poll interval | Dynamic interval adjustment |
| DEC-2 | Single-process architecture | Avoid distributed complexity for v1 | All state in memory | WAL for crash recovery | Cluster mode |
```

### Preamble Section: Risk Traceability Table (SC-9)

Maps identified risks to specific success criteria. Each risk MUST carry a RISK-ID and a Verifying SC column that binds the risk to exactly one SC.

```markdown
### Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Upstream API rate limit exceeded | Medium | High | Implement backoff + circuit breaker | SC-3 |
| RISK-2 | State corruption on partial write | Low | Critical | Atomic batch operations + rollback | SC-7 |
```

### Preamble Section: Revision Policy (SC-10)

Declares which dependent artifacts MUST be revised when this spec is revised. When a parent spec is revised, the cascade defines which downstream artifacts are affected and what action is required.

```markdown
### Revision Policy

| Artifact | Cascade Action | Trigger |
|----------|---------------|---------|
| Implementation plan | MUST be revised | Any SC change |
| Sub-issues | MUST be revised | Phase structure change |
| Behavioral enforcement tests | MUST be revised | SC verification method change |
| Dependency contracts | MUST be revised | Integration mode or gate change |
```

### Preamble Section: Decomposition Classification (SC-18)

Distinguishes single-task specs from multi-phase specs. The classification determines sub-issue requirements, PR strategy, and authorization scope behavior.

| Criterion | Single-Task | Multi-Phase |
|-----------|-------------|-------------|
| Number of phases | 1 | 2+ |
| Sub-issues required | No | Yes — one per phase |
| PR strategy | One commit, one PR | Stacked PR or sequential PRs per phase |
| Authorization scope | Single scope covers all work | Cascade to all sub-issues |
| Phase dependency | None — all work independent | Sequential — phase N depends on phase N-1 |

Include the applicable classification as a `**Classification:** single-task` or `**Classification:** multi-phase` line in the spec preamble.

### Preamble Section: Spec Family Annotation (SC-19)

Optional annotation for specs that reuse the same structure across multiple related issues. Allows selecting a subset of preamble sections via a selector syntax rather than duplicating content.

```markdown
**Spec Family:** `spec-family/http-handler`
**Selector syntax:** `<preamble-section>:[include|exclude]`
**Selected sections:**
- `decision-ledger: include`
- `risk-traceability: include`
- `revision-policy: exclude`
- `decomposition-classification: include`
```

When a spec family is declared, the spec author MUST include at least one preamble section. The selector syntax controls per-issue inclusion without modifying the shared spec family template. If `Spec Family Annotation` is absent, all preamble sections present in the spec apply normally.

A **Documentation Sources** section documents where the spec author verified factual claims. This is especially important for specs making claims about code behavior, config schemas, or API signatures. Place it before the AI byline section.

**Source Categories:**

| Category | Description | Examples |
|----------|-------------|----------|
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

### Preamble Section: Explicit Non-Goals (SC-11) — MANDATORY

**Every spec MUST include an `## Explicit Non-Goals` section.** This is not optional. Non-goals are what the spec explicitly WILL NOT address, distinguished from out-of-scope items (which are merely unaddressed) by being deliberately excluded.

```markdown
## Explicit Non-Goals

- **High availability:** This implementation does not include HA/failover. Single-node only.
- **Multi-tenancy:** User isolation and tenant-specific configuration are not addressed.
- **Audit logging:** Operational audit trails are excluded from this scope.
- **Internationalization:** All user-facing text is English-only.
```

Non-goals protect against scope creep by making exclusions explicit. They also frame validation expectations — reviewers know what NOT to expect.

### Preamble Section: Regression Invariants (SC-12) — MANDATORY

**Every spec MUST include a `## Regression Invariants` section appearing directly after Explicit Non-Goals.** Numbered list of things that MUST NOT change under any implementation of this spec.

```markdown
## Regression Invariants

1. **Public API signatures MUST NOT change** — All exported function signatures, method names, and parameter contracts remain stable.
2. **Storage schema MUST remain backward-compatible** — No column removals, data type changes, or constraint relaxations that would break existing readers.
3. **Default behavior for unconfigured systems MUST NOT change** — An unconfigured deployment behaves identically before and after the change.
4. **Error exit codes MUST NOT be reassigned** — Exit code 2 means "feature removed", not "validation failure".
```

Each invariant carries a use-case rationale explaining why it cannot change. Invariants are verified during the Regression Gate of the verification pipeline.

### Step 1a: Forward-Looking Mandate (SC-1/SC-4)

**Every spec is from the point of view "NEEDS TO BE IMPLEMENTED — HERE ARE THE REQUIREMENTS."** Never describe what has been done; describe what must be done.

- **Prohibit status language** — Do not use "implemented", "pending", "confirmed", "viable", "completed" as status markers in spec body content. Status belongs on the GitHub Issue as labels, not in the spec prose.
- **Use MUST/SHOULD/MAY (RFC 2119)** for all requirements. "The system MUST log errors" not "The system logs errors". This enforces the forward-looking stance of describing what the implementation MUST achieve, not what has been decided.
- **No tracking dashboards** — The spec is a requirements document, not a project tracker. Decision logs, status badges, and verification annotations belong in `spec-artifacts/`, not in the spec itself.

### Step 1b: Sub-Folder References, No Hardcoded File Lists (SC-9)

Reference artifact directories by sub-folder path (e.g., `spec-artifacts/`) rather than listing individual files. Agents discover content by globbing directories; hardcoded file lists go stale when files are renamed or reorganized.

**Correct:** "See `spec-artifacts/research/` for capability probe results"

**Wrong:** "See `spec-artifacts/research/fastmcp-capabilities.md` for capability probe results"

### Step 1c: No Bare `#N` References (SC-10)

**Never use bare `#N` in any spec content.** Always use the full URL: `https://github.com/{owner}/{repo}/issues/{N}` wrapped in descriptive Markdown link text.

| Pattern | Classification | Action |
|---------|---------------|--------|
| `#46` | ❌ WRONG | Replace with full URL + descriptive link text |
| `https://github.com/owner/repo/issues/46` | ⚠️ Bare URL | Wrap in descriptive Markdown link text |
| [fastmcp switch issue](https://github.com/owner/repo/issues/46) | ✅ CORRECT | Descriptive link text |
| [viewport-editor#46](https://github.com/owner/repo/issues/46) | ✅ CORRECT | Link text with repo prefix |

The agent MUST check the entire spec body for bare `#N` patterns before submission and replace any found. This applies to all cross-references regardless of whether they point to the same repo or a different repo.

### Step 2: Eliminate Ambiguity (Principle #4)

Review every requirement statement:

- Replace vague terms with measurable, testable statements
- Replace "should" with "MUST", "SHALL", or "MAY"
- Replace "fast" with specific thresholds
- Replace "user-friendly" with specific UX criteria
- Every "etc." must become an explicit list

### Step 3: Define Acceptance Criteria (Principle #6)

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| Rule | Description |
|------|-------------|
| ALL pass | Implementation is complete — proceed to next pipeline step |
| Any SKIPPED | Treated as FAIL — skipped SCs must be explicitly documented as superseded or out of scope with rationale |
| Any FAILED | Triggers autonomous remediation by the producing agent. Gate holds position (does not pass) until remediation is verified. If re-verification also fails (double-failure), HALT with blocker report. The agent MUST attempt remediation before any escalation. |
| Remediated SC | Re-verified independently — same PASS/FAIL gate applies; no carryover credit from prior passes |
| Re-verification | Repeat the verification command/assertion; confirm PASS before claiming remediation complete |

**SC Table Format (12-column):**

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step |
|----|-----------|-------------------|-------------|-----------------------|---------------|--------------------------|---------------|-------------------|-----------------|----------------|---------------|
| SC-1 | ... | Executable command/assertion producing deterministic PASS/FAIL | What corrective action is required on FAIL, including re-verification procedure | Step where SC is verified (e.g., write, requirements, diagram) | `./tmp/{issue-N}/` — verification artifact path | RFC 2119 key: MUST/SHOULD/MAY — **mandatory ALL tiers** | Phase ID (multi-phase only; absent for single-task) | Gate tier: red-green, pre-commit, ci | Required when Gate=ci; optional otherwise | Optional; SCs sharing test fixture | **Mandatory ALL tiers** — re-entry semantics |

**Column Conditions:**

| Column | Condition | Details |
|--------|-----------|---------|
| ID | Mandatory | Sequential SC identifier |
| Criterion | Mandatory | Binary pass/fail requirement statement |
| Verification Method | Mandatory | Executable command/assertion producing deterministic PASS/FAIL |
| Remediation | Mandatory | Corrective action on FAIL, including re-verification procedure |
| Pipeline Step Binding | Mandatory | Binds SC to the pipeline step that produces or verifies it (write, requirements, diagram, etc.) |
| Artifact Path | Mandatory | Path to the verification artifact using `./tmp/{issue-N}/` convention |
| Requirement Traceability | **MUST** (RFC 2119) | Requirement key declaring implementation obligation — mandatory for ALL tiers |
| Phase Binding | Conditional | Multi-phase specs only; absent for single-task specs |
| Verification Gate | Mandatory | 3 tiers: **red-green** (per-item unit test), **pre-commit** (integration check), **ci** (full pipeline) |
| Integration Mode | Conditional | Required when Gate=ci; optional for red-green and pre-commit |
| Affinity Group | Optional | Groups SCs sharing a verification setup (e.g., same test fixture) |
| Re-Entry Step | **MUST** (RFC 2119) | Documents re-entry semantics on FAIL — mandatory for ALL tiers; specifies which pipeline step to re-enter on remediation |

**The Verification Method column MUST specify an executable command or assertion producing deterministic PASS/FAIL. The Remediation column MUST specify what corrective action is required on FAIL and how re-verification is performed.**

### Evidence Type Classification Gate (MANDATORY)

**When authoring success criteria, the agent MUST classify each SC's evidence type by asking: "Does this change affect runtime behavior? If YES, evidence type MUST be behavioral."**

The declared evidence type in the SC table MUST reflect the classification question's answer:

| Change Affects Runtime Behavior? | Required Evidence Type | Minimum Verification |
|----------------------------------|----------------------|---------------------|
| YES | `behavioral` | Test execution with output inspection |
| NO | Per declared type | Per Evidence Type Taxonomy |

**🚫 FORBIDDEN:** Declaring a runtime-behavioral change as `structural` or `string` evidence type. The classification question is substrate-determined — the code path either executes at runtime or it does not.

**Remediation:** If the agent classifies an SC as structural/string for a runtime-behavioral change, the VbC pre-flight classification gate will uplift it to behavioral anyway. Classifying correctly at authorship time prevents downstream rework.

**Authority:** `guidelines/000-critical-rules.md` §critical-rules-BEH-EV, `guidelines/080-code-standards.md` §Evidence Type Taxonomy

### Cross-cutting / Common SC Designation (SC-15)

When a success criterion applies across multiple phases or components, annotate it with a `[COMMON]` prefix in the Criterion column. Common SCs share a verification budget — they MUST pass once for all phases, and a single verification artifact suffices regardless of phase count.

```markdown
| ID | Criterion | Verification Method | ... |
|----|-----------|-------------------|-----|
| SC-3 | [COMMON] API rate limit backoff MUST activate within configured threshold | ... |
```

**Semantics:**
- **Single PASS suffices** — ONE verification run covers ALL phases. Do not re-verify per phase.
- **Shared verification budget** — Cost of a single behavioral test is split across all phases.
- **FAIL blocks all phases** — A [COMMON] SC that fails blocks the entire pipeline, not just the current phase.
- **Preamble annotation alternative:** For specs where many SCs are cross-cutting, use a preamble block listing all common SCs by ID instead of per-row annotations:

```markdown
**Cross-cutting SCs:** SC-3, SC-7, SC-11 — verified once, apply to all phases.
```

<!-- Fragment ID: sc-enforcement-gate -->

For each feature/requirement:

- Binary pass/fail criteria (NOT subjective)
- Edge case coverage
- Negative test cases (what must NOT happen)
- Integration test expectations
- **Behavioral test assertions for rule-changing SCs** — Success criteria that change agent behavior (guideline rules, skill enforcement, critical violations) MUST include a behavioral test assertion describing the RED state (agent behavior without the rule) and GREEN state (agent behavior with the rule), not just a content-verification grep command. Content-verification commands are SECONDARY for rule-changing SCs; behavioral assertions are PRIMARY. See `080-code-standards.md` → Behavioral Enforcement Tests (PRIMARY).
- **Semantic intent field** — Each success criterion MUST include a brief prose annotation explaining WHY the exact criterion value matters and what semantic distinction it represents. This prevents substituting functionally similar values. Example: "Exit code 2 specifically signals removal of a feature, distinct from exit code 1 which signals a validation failure — these are different error categories for different consumer behaviors." Without semantic intent, an SC is a checklist — it verifies that something happened, but not that the right thing happened for the right reason.

### Step 4: Determinism Gate

For each success criterion, ask: **"If two different auditors read this SC, will they independently produce the same PASS/FAIL result against the same implementation?"**

If the answer is "no", the SC must be rewritten.

**Fail patterns (SC must be rewritten if any match):**

| Pattern | Example | Problem |
|---------|---------|---------|
| Adverbs without thresholds | "efficiently", "gracefully", "quickly" | Subjective — different auditors assign different thresholds |
| Comparatives without baselines | "faster than before", "more robust" | Unknown reference point — cannot be evaluated without historical data |
| Open-ended quality requirements | "handle edge cases", "be resilient" | No enumerated cases or failure modes specified |
| Missing expected values | "returns the correct result", "validates input" | No concrete expected value to compare against |
| Implicit behavior | "should not crash", "works normally" | No negative criterion — what constitutes "not crashing" is undefined |

**Verification:** For each SC, attempt to write an executable verification command (`uv run pytest test_X.py::test_Y`, `bash verify.sh arg`, `issue-operations -> read-issue (github_issue_read())` with specific field check). If no executable command can be written, the SC is not deterministic. <!-- Routes through issue-operations per SPEC #683 -->

✅ **Gate presence verification:** Verify the all-or-nothing gate statement is present in the assembled spec body. If absent → `STRUCTURE-VIOLATION` requiring rewrite before submission.

### Step 5: Structure the Deliverable (Principle #10)

**Content coverage matters more than section structure.** The agent chooses the optimal structure for the spec's complexity:

- **Minimal specs** (bug fixes, one-file changes): May use a minimal format — Problem, Context, Non-Goals, Invariants, Fix, Criteria, Edge Cases — all in flowing prose without section headers. Preamble is optional except Explicit Non-Goals and Regression Invariants (mandatory).
- **Standard specs** (multi-file changes): May use typical sections — Intent and Executive Summary (mandatory), Objective, Problem, Context, Fix Approach, Success Criteria, Edge Cases. Include a `## Intent and Executive Summary` preamble with the 5 fields (Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions) before the Objective section.
- **Complex specs** (cross-cutting, multi-phase): May use full structure — Intent and Executive Summary (mandatory), Objective, Problem, Context, Affected Files, Fix Approach, Success Criteria, Edge Cases, Dependencies, Risk, Decision Rationale, Phases. Preamble is mandatory.

**Any format that covers the required content areas is acceptable.** The agent decides the structure that best serves the specific spec.

### Step 5.5: Spec/Plan Boundary Check

Review the assembled spec for plan-level content that belongs in the implementation plan, not the spec. Specs describe **WHAT** and **WHY**; plans describe **HOW**.

**Replacement rules:**

| Plan-Level Content (remove) | Spec-Level Replacement |
| -- | -- |
| Function/class definitions with code | Function names + responsibilities table |
| SQL DDL statements (`CREATE TABLE...`) | Table names + constraints table |
| Implementation algorithms with step-by-step logic | Input/output contract (what goes in, what comes out) |
| File paths with "what to change" language | Affected files + anchors table (what exists, not what to write) |
| Architecture decisions without constraints | Architecture requirements table (what the system MUST satisfy) |

**Self-review question:** "Could two developers produce valid but different implementations from this spec?" If yes, the spec is at the right level. If no — if the spec only allows one implementation — it contains plan-level detail that should be removed.

### Step 6: Self-Review

After writing the spec, review with fresh eyes:

1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
3. **Scope check:** Is this focused enough for a single implementation plan, or does it need decomposition?
4. **Ambiguity check:** Could any requirement be interpreted two different ways? If so, pick one and make it explicit.
5. **SC-to-SC coherence check (SC-13):** Verify that no two SCs contradict each other (e.g., SC-A says "MUST reject X" and SC-B says "MUST accept X"). Perform a pairwise comparison scan across all SCs in the success criteria table.
6. **Verification-Method-to-Artifact-Path consistency check (SC-14):** Verify that each SC's Artifact Path column value is consistent with its Verification Method column (e.g., if Verification Method references a tool, Artifact Path references the same file or directory). Perform a cross-column comparison across all SCs.

Fix any issues inline. No need to re-review — just fix and move on.

**Prose-structure check:** After checking for placeholders, consistency, scope, and ambiguity, verify that the spec body is prose-first. Rigid numbered procedures where flowing prose would serve better, tabular mappings that should be prose descriptions, and fixed checklists that have replaced narrative should be flagged and rewritten. Success criteria table FORMAT and affected file tables are exempt from this check as they are naturally structured content. However, the VERIFICATION METHOD CONTENT within SC table columns must meet the same precision standards as prose — a verification method that says "check exit code" is no more acceptable inside a table cell than it would be in a paragraph.

**SC Verification Column Precision Sub-Check:** Scan the Verification column of every SC table for vague verification methods (describes what to check without specifying exact expected value). Flag each vague entry as a STRUCTURE-VIOLATION requiring rewrite with an executable verification command per `140-planning-spec-creation.md` Executable Verification Commands mandate. The spec should read as a coherent narrative document, not as a mechanical checklist.

### Step 6.5: Evidence Artifact Verification (MANDATORY)

**🚫 CRITICAL: Each self-review checkpoint MUST produce a tool-call artifact demonstrating the verification was performed. Assertions without tool-call evidence are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Checkpoint | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| No placeholders remain | Verify spec body contains no "TBD", "TODO", "FIXME", or incomplete section markers | `issue-operations -> read-issue (github_issue_read(method=get, issue_number=N)` → search body for `/TBD\|TODO\|FIXME/` | STRUCTURE-VIOLATION | <!-- Routes through issue-operations per SPEC #683 -->
| Internal consistency | Cross-reference requirement IDs between sections; verify no contradictions | `issue-operations -> read-issue (github_issue_read(method=get)` → parse section anchors vs referenced IDs | CONFLICTING | <!-- Routes through issue-operations per SPEC #683 -->
| Scope check evidence | Verify scope is appropriate for single plan or flagged for decomposition | `issue-operations -> read-issue (github_issue_read(method=get)` → count affected files, check for phase markers | VERIFICATION-GAP | <!-- Routes through issue-operations per SPEC #683 -->
| Ambiguity resolved | Verify no requirement can be interpreted two ways | `issue-operations -> read-issue (github_issue_read(method=get)` → scan for "should", "etc.", vague terms | STRUCTURE-VIOLATION | <!-- Routes through issue-operations per SPEC #683 -->
| SC-to-SC coherence (SC-13) | Pairwise comparison of all SCs for contradictions | `issue-operations -> read-issue (github_issue_read(method=get)` → parse SC table rows, compare requirement statements pairwise for conflict | CONFLICTING | <!-- Routes through issue-operations per SPEC #683 -->
| Verification-Method-to-Artifact-Path consistency (SC-14) | Cross-column consistency check per SC | `issue-operations -> read-issue (github_issue_read(method=get)` → parse Verification Method vs Artifact Path columns, match tool/file references across each row | VERIFICATION-GAP | <!-- Routes through issue-operations per SPEC #683 -->

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
| -- | -- | -- | -- |
| Placeholders found in spec body | STRUCTURE-VIOLATION | auto-fix | Replace with concrete content |
| Contradictory requirements across sections | CONFLICTING | flag-for-review | Report, do not auto-resolve |
| Scope too large for single plan | VERIFICATION-GAP | conditional | Flag decomposition, then apply if confirmed |
| Vague/ambiguous terms present | STRUCTURE-VIOLATION | auto-fix | Replace with measurable terms |
| Contradictory SC requirements (SC-13) | CONFLICTING | flag-for-review | Report both SCs with contradiction summary |
| Verification-Method/Artifact-Path mismatch (SC-14) | VERIFICATION-GAP | conditional | Flag mismatch, apply fix if path is clearly wrong |

**These verifications are MANDATORY after self-review. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

### Post-Review: Verification Revisit (MANDATORY)

After Step 6 self-review and Step 6.5 evidence verification, invoke `verification-enforcement --task revisit`. This pass scans the spec for any remaining `⚠️ UNVERIFIED` markers and attempts to resolve them using domain-appropriate tools. Claims that cannot be resolved are escalated to the developer. The spec must not be submitted as a GitHub Issue while unverified claims remain without developer acknowledgment.

### Step 6.8: Generate Spec Folder URL (SC-6)

Generate the spec folder URL and prepare the blockquote for embedding at the top of the issue body. Follow the `.issues/AGENTS.md` pattern:

```
> **Full spec and artifacts: [`.issues/{N}/`](https://github.com/{owner}/{repo}/tree/issues-data/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/{N}/spec-artifacts/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
```

The URL follows the pattern: `{github.html_url}/tree/issues-data/{N}/spec-artifacts/`

Embed this blockquote at the TOP of the issue body (before the spec content), prepended when creating the issue body or updated after creation.

### Step 7: Create GitHub Issue

Invoke `issue-operations` skill to persist the spec as a GitHub Issue:

1. Generate spec folder URL blockquote (Step 6.8) and prepend it to the issue body
2. Invoke `issue-operations --task pre-creation` to validate (check for conflicts, superseded issues, content coverage)
3. If validation fails → HALT and report. Fix issues and re-validate.
4. If validation passes → invoke `issue-operations --task single-task-check` to determine sub-issue needs
5. Invoke `issue-operations --task creation` to create the GitHub Issue with the blockquote-prepended body
6. Record the issue number and URL

**Chat output is ONLY:**

```
<exec summary>

<issue URL>

🤖 <AgentName> (<ModelId>) created
```

**🚫 NEVER:**

- Dump full spec content to chat as the "review" step
- Claim spec is "written" without a GitHub Issue URL
- Ask the user to review the spec in chat

### Step 7a: Exec Summary Format Rules (SC-20)

The exec summary pushed to the remote platform MUST conform to the following format rules. These constraints ensure the summary remains a concise user-facing document, not a project tracker.

**Format constraints:**

- **No checkboxes** — the exec summary is a narrative summary, not a task tracker
- **No status markers** — no `[DONE]`, `[PENDING]`, `[BLOCKED]`, or completion flags in the summary body. Status belongs on the issue labels, not in prose
- **No completion flags** — do not declare items as "complete", "implemented", or "verified" in the summary
- **Cards listed in dependency order** — reference each card from the card catalogue in dependency sequence, with SC count + evidence type breakdown per card
- **Key Decisions section** — present and stable, capturing architectural decisions with DEC-IDs
- **Risk Callouts section** — present and stable, capturing RISK-IDs and their mitigation status

**Rules table:**

| Rule | Description | Rationale | Violation |
|------|-------------|-----------|-----------|
| No checkboxes | Exec summary uses prose, not task lists | Checkboxes imply trackable sub-tasks that belong on the issue tracker, not the summary | STRUCTURE-VIOLATION |
| No status markers | No `[DONE]`/`[PENDING]`/`[BLOCKED]` in body | Status markers fragment narrative flow and create a false sense of tracking. Labels and issue state handle status | STRUCTURE-VIOLATION |
| No completion flags | No "completed", "implemented", "verified" in summary | Completion assertions in the summary body contradict the spec's forward-looking mandate. Verification status belongs in pipeline artifacts | STRUCTURE-VIOLATION |
| Dependency-ordered cards | Cards listed in spec-artifact dependency order | Dependency order preserves the implementation sequence — reviewers see what depends on what | STRUCTURE-VIOLATION |
| SC count + type breakdown | Per card: how many SCs, each with evidence type | Evidence type determines verification cost and gate position — exposing it per card enables reviewer risk assessment | STRUCTURE-VIOLATION |
| Key Decisions present | DEC-ID section with MUST/SHOULD/MAY mappings | Architectural decisions documented in the preamble must be visible in the summary for reviewer context | STRUCTURE-VIOLATION |
| Risk Callouts present | RISK-ID section with mitigation status | Risks identified in the preamble carry through to the summary so reviewers can assess residual exposure | STRUCTURE-VIOLATION |

### Step 7b: Local Mirror Persistence (SC-21)

After the exec summary is pushed to the remote platform, save a local mirror at `.issues/{N}/remote-exec-summary.md`:

1. Copy the final exec summary (from Step 7 chat output format) to `.issues/{N}/remote-exec-summary.md`
2. The mirror is updated whenever the remote body is updated (re-run this step after any revision)
3. The mirror is NEVER the authoritative spec — it is a maintenance convenience copy

**Authoritative spec location:** `.issues/{N}/spec.md` is ALWAYS the authoritative spec. The `remote-exec-summary.md` mirror exists for offline reference and diff tracking between versions. Never edit the remote body alone — always update `.issues/{N}/spec.md` first, then sync to the remote issue body, then update the mirror.

### Step 8: User Review on Issue

The user reviews the spec ON THE GITHUB ISSUE, not in chat.

- If user requests revisions via issue comments: update the issue body, then post update summary + URL + byline to chat
- If user approves the spec on the issue: proceed to Step 9
- Do NOT re-dump the spec to chat for any reason

### Step 9: Transition

After user approval of the spec on the GitHub Issue:

- Invoke `spec-auditor` for quality audit
- Then proceed to `approval-gate` for authorization
- Then `writing-plans` for implementation planning

## Context Required

- Preceded by: `requirements` (mandatory), `decompose`, `traceability`, `risk` (or explicitly skipped)
- Extends: brainstorming Steps 7-9 (adapted, not verbatim move)
- Calls: `issue-operations` (pre-creation → single-task-check → creation)
- Followed by: `spec-auditor`, then `approval-gate`
