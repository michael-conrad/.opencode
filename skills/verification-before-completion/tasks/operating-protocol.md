# Verification Before Completion Operating Protocol

## Entry Criteria

- Task completion claimed or SC verification requested
- Spec SC list and file paths available

## Procedure

- [ ] 1. **Structural completeness first:** verify all specified files/components exist before SC verification.
- [ ] 1a. **Analytical artifact presence gate:** Before SC verification, verify that all analytical artifacts required by the spec exist at their expected paths. Analytical artifacts include: `blast-radius.yaml`, `concern-map.yaml`, `code-path-inventory.yaml`, `cross-cutting-matrix.yaml`, `interface-compatibility.yaml`, `state-analysis.yaml`, `testability-assessment.yaml`. Each artifact is checked for file existence and valid YAML. If any artifact is missing or invalid, HALT and report the missing artifact(s).
- [ ] 1b. **Analytical artifact coverage gate:** After artifact presence is confirmed, verify that each analytical artifact's claims are covered by at least one success criterion. Cross-reference artifact claims against the SC table. Any claim with zero matching SCs is flagged as `ANALYTICAL_COVERAGE_GAP` with FAIL verdict. Resolve by adding SCs or documenting out-of-scope claims before proceeding.
- [ ] 2. **Adversarial-audit call:** during verify task, call `audit --task drift-detection --issue <N>` with `audit_phase: implementation_verification` to check spec/code reality alignment.
- [ ] 3. **Per-SC evidence table:** every SC must produce a tool-call artifact with PASS/FAIL.
- [ ] 4. **Exact comparison:** external verifications use exact mode. No "functionally equivalent" soft-passes.
- [ ] 5. **Live-source only:** evidence from memory/training data is FORBIDDEN. Tool-call artifact required.
- [ ] 6. **Clean-room routing:** verification sub-agents receive ONLY spec SC list + file paths. No implementation context, no prior results.
- [ ] 7. **Behavioral test evaluation:** After `behavior_run` produces artifacts, the orchestrator MUST dispatch `behavioral-test-evaluation` to evaluate artifacts via clean-room sub-agents. "Artifact generated" is NOT a valid PASS verdict for behavioral SCs. **This gate is enforced procedurally in `verify.md` Step 2 (evidence type classification) and Step 2b (Behavioral Test Evaluation Gate).** The verify.md workflow is the canonical source — this protocol entry is a cross-reference.
- [ ] 8. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

### Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Verification Comparison Semantics

**Reporting a verification mismatch as "passing" or "close enough" instead of FAIL is a process-integrity failure. Verification is binary: exact match or FAIL — nothing else.**

Verification against a specification is a binary predicate: `value == specification → PASS`, otherwise → `FAIL`. There is no "close enough." There is no "functionally equivalent." There is no "minor difference." If the live value does not match the specification exactly, it is a FAIL.

### Core Rule: Exact Match for External Verifications

When verifying DNS records, configuration values, API responses, infrastructure state, or any external-facing value against a specification:

| Comparison | Result |
|-----------|--------|
| Live value matches specification exactly (character-for-character) | ✅ PASS |
| Live value differs from specification in ANY way | ❌ FAIL |
| Live value is "functionally equivalent" but not identical | ❌ FAIL |
| Live value has fields swapped (e.g., SRV priority/weight) | ❌ FAIL per field |

### Per-Field Independence

Every field in a multi-field record is compared independently. A record with N fields must have N PASS results for the record to be reported as PASS. A single field mismatch makes the entire record FAIL.

Example: An SRV record with fields (priority, weight, port, target) requires 4 independent comparisons. If priority=5 weight=0 was specified but priority=0 weight=5 is found, that is **2 FAIL results** (priority mismatch AND weight mismatch), not "functionally equivalent."

### Prohibited Reasoning Patterns

| Prohibited Pattern | Why Prohibited |
|-------------------|----------------|
| "Priority=0 weight=5 works the same as priority=5 weight=0" | False equivalence — SRV priority and weight have distinct semantics |
| "The values are swapped but the result is the same" | Agent judgment substituting for spec compliance |
| "Minor difference, effectively equivalent" | "Close enough" is never a valid verification outcome |
| "Functionally equivalent, does not affect behavior" | Functional analysis is for design, not verification |
| "Semantically close enough to pass" | Verification is binary: exact match or FAIL |

### Verification Report Format

When reporting verification results for external values:

```markdown
| Field | Expected (from source) | Actual (live) | Result |
|-------|----------------------|---------------|--------|
| priority | 5 | 0 | ❌ FAIL |
| weight | 0 | 5 | ❌ FAIL |
| port | 443 | 443 | ✅ PASS |
| target | server.example.com | server.example.com | ✅ PASS |
```

**Footnotes and notes about "minor differences" are FORBIDDEN.** If it does not match, it is FAIL. No exceptions.

### When Semantic Comparison Is Allowed

`semantic` comparison mode (where multiple implementations achieve the same spec intent) is ONLY allowed for code behavior verification, and requires:

1. Explicit per-field justification for why semantic comparison applies
2. Documentation of what "same intent" means for that specific field
3. The default is ALWAYS `exact` — semantic mode must be explicitly chosen and justified

**For ALL external verifications (DNS, configuration, infrastructure, API responses), `exact` mode is mandatory. No exceptions. No semantic comparison.**

## Anti-Evasion Rules — Cost, Availability, and Necessity Are Not Excuses

Evasion patterns are predictable. When a behavioral test cannot run, agents produce three categories of rationalization instead of the required FAIL verdict. Each category is a Tier 2 prohibition with a mandatory remediation-first protocol.

### Pattern (a): Claiming Model Unavailability Without Tool-Call Evidence

An agent claiming a model is unavailable MUST produce tool-call evidence before the claim is accepted. "The model timed out" is not evidence — `opencode models` output showing the model is not listed, or a timed-out execution log showing the timeout duration, is evidence.

**Remediation-first protocol (minimum 2 steps before FAIL):**
1. Run `opencode models` to verify model availability
2. Attempt alternative model selection (select a different available model)
3. Increase timeout and retry
4. Only after 2+ remediation attempts: report FAIL with tool-call evidence of each attempt

### Pattern (b): Claiming "Too Slow" as Justification for Skipping Behavioral Testing

Read [§1 ALWAYS DO](020-go-prohibitions.md) — Cost-blind verification: resource cost is NEVER a factor in verification decisions. "This would take too long" is not an acceptable reason to skip or substitute behavioral verification. Correctness is the only metric — there is no score for tool-call economy.

**Remediation-first protocol (minimum 2 steps before FAIL):**
1. Increase timeout configuration (BEHAVIOR_TIMEOUT, BEHAVIOR_SEMANTIC_TIMEOUT)
2. Run behavioral test with increased timeout
3. Attempt alternative model with faster inference
4. Only after 2+ remediation attempts: report FAIL with evidence of each attempt

### Pattern (c): Claiming Behavioral Testing "Not Needed" for Runtime-Behavioral Changes

Read [§Test Integrity Mandate](080-code-standards.md) — removing or weakening behavioral assertions is a CRITICAL VIOLATION. When a change affects runtime behavior (agent dispatch decisions, enforcement gate outcomes, tool selection, pipeline routing, conditional branching, test execution results), behavioral testing is not optional — it is the only sufficient evidence type. Declaring an SC as `structural` to avoid behavioral testing when the change affects runtime behavior is an automatic uplift to `behavioral`.

**Remediation-first protocol (minimum 2 steps before FAIL):**
1. Reclassify evidence type from `structural`/`string` to `behavioral` per the substrate classification
2. Design and execute a behavioral test that verifies the runtime behavior change
3. If behavioral test environment unavailable: apply patterns (a) and (b) remediation steps
4. Only after 2+ remediation attempts: report FAIL with EVIDENCE_TYPE_MISMATCH classification

### 🚫 FORBIDDEN

- Claiming model unavailability without tool-call evidence (`opencode models` output, execution logs)
- Claiming "too slow" or "too many tool calls" as justification for skipping any verification step
- Declaring a runtime-behavioral change as `structural` to avoid behavioral testing
- Producing an INCONCLUSIVE verdict when EVIDENCE_TYPE_MISMATCH is detected — the verdict MUST be FAIL
- Skipping remediation steps before reporting FAIL — exhaustion before escalation

### ✅ REQUIRED

- Produce tool-call evidence before claiming model unavailability
- Run behavioral tests regardless of estimated cost or duration
- Apply automatic evidence type uplift when a change affects runtime behavior
- Attempt at least 2 remediation steps (alternative model, timeout increase, infrastructure check) before reporting FAIL
- Report EVIDENCE_TYPE_MISMATCH with FAIL verdict when structural evidence is submitted for a runtime-behavioral change

## Metadata Verification Extension

The verification honesty principle extends to metadata claims in specs, plans, and other documents. Metadata — STATUS markers, labels, cross-references, code references, and authorization state — must be verified against actual evidence, not trusted at face value.

### Metadata Categories Requiring Verification

| Metadata Category | What to Verify | How to Verify |
|-------------------|----------------|---------------|
| STATUS marker | Compare STATUS value against actual content maturity | Analyze content against maturity criteria (brainstorm/draft/detailed/complete); update STATUS if mismatch |
| Label | Verify label claims match actual issue state | Read labels via `github_issue_read(method=get_labels)`; compare against authorization state |
| Comments/body claims | Verify factual claims in issue body against live state | Re-read issue comments; verify claims against current data |
| Cross-references | Verify `#N` references point to existing, matching content | Call `github_issue_read(method=get, issue_number=N)` for each reference |
| Code references | Verify file paths, function names, and code references exist | Use `srclight_search_symbols`, `glob`, or `srclight_get_signature` |
| Process-completion flags | Verify completion markers reflect actual completion | Check referenced artifacts (branches, commits, PRs) exist and are merged |
| Authorization currency | Check whether authorization claims are superseded by revisions | Compare comment timestamps: latest authorization vs. latest revision |
| Authorization author identity | Verify comments claiming authorization come from a developer, not a bot or agent | `github_issue_read(method=get_comments)` → filter by `author_association` (MEMBER/OWNER/COLLABORATOR = human; FIRST_TIME_CONTRIBUTOR/NONE = untrusted; bot login = rejected) |
| Sub-issue state | Verify sub-issue open/closed state via GitHub API, not cached or claimed state | `github_issue_read(method=get, issue_number=N)` → check `state` field; `github_issue_read(method=get_sub_issues)` |

### No Metadata Trust Exceptions

There are NO exceptions to metadata verification:

- **STATUS markers are not self-certifying.** A STATUS of COMPLETE does not make the content complete. Verify the content.
- **Labels are not self-certifying.** A `needs-approval` label does not mean approval is absent. Verify via comments.
- **Cross-references are not self-certifying.** A `#N` reference does not mean the issue exists or matches. Verify via GitHub MCP.
- **Code references are not self-certifying.** A file path in a spec does not mean the file exists. Verify via codebase tools.
- **Authorization comments are not self-certifying.** An approval comment may predate a revision. Verify timestamps.
- **Authorization author identity is not self-certifying.** A comment saying "approved" from a bot or agent account is not valid authorization. Verify the author is a developer (MEMBER, OWNER, or COLLABORATOR association).
- **Sub-issue state is not self-certifying.** A claimed "closed" sub-issue may not actually be closed, or may have been closed without a merged PR. Verify via GitHub API.

## Exit Criteria

- All SCs verified with evidence artifacts
- Behavioral tests evaluated (if applicable)
- Evidence table produced
