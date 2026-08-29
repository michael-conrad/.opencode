> **Full spec and artifacts: [`.opencode/.issues/2411/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2411/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2411/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Prohibit false numerical reduction targets in condensation specs

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | Multiple guideline condensation specs (#2347, #2348, #2349, #2350, #2352, #2353, #2354, #2357) contained success criteria imposing hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria (e.g., "post-condensation byte count < N bytes", "reduced by at least N tokens", "~N% reduction", "token count ≤ N"). These are false targets: condensation savings are an emergent property of correctly implementing the content-based SCs (which define WHAT to move/retain/remove), not a target to optimize toward. A hard numerical threshold incentivizes aggressive trimming to hit a number rather than faithful implementation, causes agent malfunction, and improper reworking. |
| 2 | **Root Cause / Motivation** | The canonical reference `.opencode/reference/spec-structure-standards.md` carries a Prohibited Content Patterns section (line 176) that bans tracking/status language and prescriptive code but does not ban numerical reduction thresholds. Because the rule is absent, spec producers (spec-creation create.md) and auditors (spec-audit) have no anchor to reject false numerical targets. Every future condensation spec can carry a hard threshold that fails in production — a defect discovered only when the trimmed content breaks downstream consumers. |
| 3 | **Approach Chosen** | Add a new entry to the Prohibited Content Patterns section of `.opencode/reference/spec-structure-standards.md` classifying hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria as FAIL, and stating the emergent-property principle: SCs define WHAT to move/retain/remove; savings are an emergent property of correctly implementing content-based SCs. Include a correct/incorrect example pair. Add a parallel narrow criterion (SC-NUMERICAL-TARGET) to `.opencode/skills/audit/tasks/spec-audit-evaluator.md` mirroring SC-TRACKING-LANG / SC-PRESCRIPTIVE-CODE. Add a behavioral enforcement test scenario (artifact-only generator + clean-room evaluation) asserting the agent flags/refuses a false numerical target. |
| 4 | **Alternatives Considered & Why Discarded** | **Extend validate.md's hardcoded determinism list (step 3.2)** — discarded as the primary enforcement anchor because the rule is already visible to validate via the dynamic reference read (step 1.2); the audit-evaluator narrow criterion is the concrete enforcement anchor required by the issue (DD-1). **Retroactively revise the existing condensation specs** — discarded because remediation of existing specs is explicitly out of scope (separate remediation). **Ban all quantitative SCs** — discarded because it is not the intent; only reduction thresholds as PASS/FAIL targets are prohibited; content-based measurable SCs remain valid. |
| 5 | **Key Design Decisions** | The rule lives ONLY in the Prohibited Content Patterns section of spec-structure-standards.md (tradeoff: all consumers already Read-link that section, so no new cross-reference wiring is needed; the evidence type taxonomy and Format Requirements sections are untouched). The audit evaluator gains a parallel narrow criterion SC-NUMERICAL-TARGET (tradeoff: the criterion set grows by one, but the rule is concretely enforced at spec-audit). validate.md's hardcoded determinism list is NOT extended (DD-1) (tradeoff: validate-side enforcement relies on the dynamic reference read only). The behavioral test follows the artifact-only generator + clean-room evaluation two-SC pattern (tradeoff: two SCs instead of one, but avoids EVIDENCE_TYPE_MISMATCH). |
| 6 | **User Intent / Original Prompt** | Prohibit false numerical reduction targets (hard byte-count, token-count, percentage, or line-count reduction thresholds) as PASS/FAIL criteria in condensation specs, anchoring the rule in the Prohibited Content Patterns reference and enforcing it via the spec-creation/audit pipeline and a behavioral enforcement test. |

## 2. Not Included

- **Retroactively revising the existing condensation specs (#2347, #2348, #2349, #2350, #2352, #2353, #2354, #2357)** — separate remediation; the rule applies to new/revised specs only.
- **Changing the evidence type taxonomy or any section of spec-structure-standards.md beyond the Prohibited Content Patterns section** — constraint REQ-10; the taxonomy is not altered.
- **Altering the preload mechanism or opencode.jsonc** — constraint REQ-11; the instructions array is not touched.
- **Banning all quantitative SCs** — not the intent; only reduction thresholds as PASS/FAIL targets are prohibited (REQ-6, REQ-NR-4).
- **Extending validate.md's hardcoded determinism list (step 3.2)** — design decision DD-1; validate-side enforcement is via the dynamic reference read only.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The Prohibited Content Patterns section of `.opencode/reference/spec-structure-standards.md` contains a new entry prohibiting hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria in specs, and stating the emergent-property principle: SCs define WHAT to move/retain/remove; savings are an emergent property of correctly implementing content-based SCs; a hard numerical threshold is a FAIL. | structural | read/grep confirms the entry exists in the Prohibited Content Patterns section and contains the emergent-property wording | `.opencode/reference/spec-structure-standards.md` §Prohibited Content Patterns |
| SC-2 | The new rule entry includes a correct/incorrect example pair: an incorrect SC imposing a hard numerical reduction threshold (e.g., "post-condensation byte count < N bytes") and a compliant content-based SC (e.g., "the guideline retains the Zero Tolerance Rule verbatim; the relocated section is replaced with a Read-link"). | string | grep confirms both an incorrect example (numerical threshold) and a correct example (content-based) are present in the entry | `.opencode/reference/spec-structure-standards.md` §Prohibited Content Patterns |
| SC-3 | `.opencode/skills/audit/tasks/spec-audit-evaluator.md` Step 5 contains a new narrow criterion (SC-NUMERICAL-TARGET) mirroring SC-TRACKING-LANG / SC-PRESCRIPTIVE-CODE that Read-links §Prohibited Content Patterns and verifies the spec contains no false numerical reduction targets (hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria). | structural | read/grep confirms the new narrow criterion step exists in spec-audit-evaluator.md and Read-links §Prohibited Content Patterns | `.opencode/skills/audit/tasks/spec-audit-evaluator.md` Step 5 |
| SC-4 | A new behavioral test scenario script exists at `.opencode/tests-v2/behaviors/<scenario>.sh` following the artifact-only generator pattern (SCENARIO_NAME + SCENARIO_PROMPT + behavior_run + exit 0), whose prompt is a real-domain spec-creation task containing a false numerical reduction target; the script contains no assertion helpers. | behavioral | run the script via with-test-home (opencode run), producing session.yaml/stdout.log/stderr.log artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/ | `.opencode/tests-v2/behaviors/template.sh`; `.opencode/tests-v2/AGENTS.md` §1, §11 |
| SC-5 | A clean-room sub-agent reads the session.yaml (SQLite DB export — primary evidence source) from the item-4 artifact directory and evaluates whether the agent flagged/refused the false numerical target (e.g., read the reference's Prohibited Content Patterns section and refuse the hard threshold, or flag it as FAIL) rather than silently accepting it. | behavioral | clean-room sub-agent inspection of session.yaml per tests-v2/AGENTS.md §2 and §6a (artifact path + SC criterion only; no orchestrator preload) | `.opencode/tests-v2/AGENTS.md` §2, §6a |

## 4. Requirements

- R-1. The Prohibited Content Patterns section of `.opencode/reference/spec-structure-standards.md` SHALL include an entry prohibiting hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria in specs.
- R-2. The rule entry SHALL state the emergent-property principle: SCs define WHAT to move/retain/remove; savings are an emergent property of correctly implementing content-based SCs; a hard numerical threshold is a FAIL.
- R-3. The rule entry SHALL include a correct/incorrect example pair demonstrating the prohibited pattern versus the compliant content-based SC.
- R-4. The rule entry SHALL be placed only in the Prohibited Content Patterns section; no other section of spec-structure-standards.md SHALL be modified.
- R-5. `.opencode/skills/audit/tasks/spec-audit-evaluator.md` SHALL gain a narrow criterion (SC-NUMERICAL-TARGET) that Read-links §Prohibited Content Patterns and verifies the absence of false numerical reduction targets.
- R-6. The spec-creation pipeline SHALL enforce the rule via the existing mandatory Read-links (create.md line 43, validate.md step 1.2, spec-audit-investigator.md line 100).
- R-7. A behavioral enforcement test SHALL exist that asserts the agent flags/refuses a false numerical target in a real-domain spec-creation task.
- R-8. The behavioral test SHALL follow the artifact-only generator + clean-room evaluation two-SC pattern (no assertion helpers in the script; session.yaml is the primary evaluation source).
- R-9. The rule SHALL apply to new/revised specs only; existing condensation specs SHALL NOT be retroactively revised by this issue.
- R-10. The rule SHALL NOT ban content-based measurable SCs; only reduction thresholds as PASS/FAIL targets are prohibited.
- R-11. The preload mechanism and opencode.jsonc SHALL NOT be altered.
- R-12. The evidence type taxonomy SHALL NOT be altered.
- R-13. The edited agent-facing text SHALL comply with Mandatory Triple Co-Application (reference cards 250/255/257).
- R-14. The behavioral test prompt SHALL be a real-domain task, NOT a prose-recall interview.

## 5. Items

### Item 1 (SC-1): Reference rule entry added

- RED: Enforcement check that the Prohibited Content Patterns section lacks the false-numerical-target entry (fails because the entry should be added).
- GREEN: Add a new bullet to the Prohibited Content Patterns section of `.opencode/reference/spec-structure-standards.md` stating that hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria in specs are FAIL, and stating the emergent-property principle: SCs define WHAT to move/retain/remove; savings are an emergent property of correctly implementing content-based SCs; a hard numerical threshold is a FAIL.
- verify: read/grep confirms the entry exists in the Prohibited Content Patterns section and contains the emergent-property wording.
- commit: Add the rule entry to the reference file.

### Item 2 (SC-2): Correct/incorrect examples included

- RED: Enforcement check that the rule entry lacks a correct/incorrect example pair (fails because the examples should be added).
- GREEN: Add a correct/incorrect example pair within the rule entry: an incorrect SC imposing a hard numerical reduction threshold (e.g., "post-condensation byte count < N bytes") and a compliant content-based SC (e.g., "the guideline retains the Zero Tolerance Rule verbatim; the relocated section is replaced with a Read-link").
- verify: grep confirms both an incorrect example (numerical threshold) and a correct example (content-based) are present in the entry; the correct example carries no numerical threshold.
- commit: Add the example pair to the rule entry.

### Item 3 (SC-3): Audit evaluator narrow criterion anchored

- RED: Enforcement check that spec-audit-evaluator.md lacks the SC-NUMERICAL-TARGET narrow criterion (fails because the criterion should be added).
- GREEN: Add a new narrow criterion (SC-NUMERICAL-TARGET) to Step 5 of `.opencode/skills/audit/tasks/spec-audit-evaluator.md` mirroring SC-TRACKING-LANG / SC-PRESCRIPTIVE-CODE: "Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Prohibited Content Patterns and verify the spec contains no false numerical reduction targets (hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria)."
- verify: read/grep confirms the new narrow criterion step exists in spec-audit-evaluator.md and Read-links §Prohibited Content Patterns.
- commit: Add the narrow criterion to the audit evaluator.

### Item 4 (SC-4): Behavioral test scenario artifact generation

- RED: Behavioral test run with a real-domain spec-creation prompt containing a false numerical target produces no artifacts (fails because the scenario script does not exist yet).
- GREEN: Create a new behavioral test scenario script at `.opencode/tests-v2/behaviors/<scenario>.sh` following the artifact-only generator pattern (SCENARIO_NAME + SCENARIO_PROMPT + behavior_run + exit 0). The prompt is a real-domain spec-creation task where the agent is asked to create or validate a condensation spec containing a false numerical reduction target (or otherwise encounters one), so natural agent behavior either flags/refuses the target or accepts it. No assertion helpers in the script.
- verify: run the script via with-test-home (opencode run, bash tool timeout >= 600s), producing session.yaml/stdout.log/stderr.log artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/.
- commit: Add the scenario script (and fixture issue if the prompt references issue content).

### Item 5 (SC-5): Clean-room evaluation of behavioral artifacts

- RED: Clean-room evaluation of the item-4 artifacts cannot produce a verdict (fails because the evaluation has not been performed).
- GREEN: A clean-room sub-agent reads the session.yaml (SQLite DB export — primary evidence source) from the item-4 artifact directory and evaluates whether the agent's tool calls, reasoning, and decisions flag/refuse the false numerical target (e.g., the agent reads the reference's Prohibited Content Patterns section and refuses to accept the hard threshold, or flags it as FAIL) rather than silently accepting it. The sub-agent receives only the artifact path and the SC criterion — no orchestrator reasoning.
- verify: behavioral — clean-room sub-agent inspection of session.yaml per tests-v2/AGENTS.md §2 and §6a.
- commit: No content change; evaluation verdict slice.

## 6. Dependencies

- **Reference:** `.opencode/reference/spec-structure-standards.md`
  - **Relationship:** The canonical reference whose Prohibited Content Patterns section receives the new rule; must be read before implementation.
  - **Status:** Satisfied (exists; §Prohibited Content Patterns at line 176).
- **Reference:** `.opencode/skills/audit/tasks/spec-audit-evaluator.md`
  - **Relationship:** Enforcement target for the new narrow criterion (SC-NUMERICAL-TARGET); must be read before item-3 implementation.
  - **Status:** Satisfied (exists; Step 5 narrow criteria at steps 5e/5f).
- **Reference:** `.opencode/skills/spec-creation/tasks/create.md` and `validate.md`
  - **Relationship:** Producers that Read-link the reference; the rule is automatically visible during spec assembly and validation.
  - **Status:** Satisfied (create.md line 43; validate.md step 1.2).
- **Reference:** `.opencode/tests-v2/AGENTS.md`
  - **Relationship:** Behavioral test paradigm authority (artifact-only generators, two-SC pattern, session.yaml as primary source, prompt construction mandate).
  - **Status:** Satisfied (§1, §2, §6a, §11).
- **Reference:** `.opencode/tests-v2/behaviors/template.sh` and `helpers.sh`
  - **Relationship:** Behavioral test template and helpers for the new scenario script.
  - **Status:** Satisfied (exists in behaviors/).
- **Reference:** Existing condensation specs #2347–#2357
  - **Relationship:** Informational context only — they contain the now-prohibited thresholds; NOT a dependency (remediation out of scope).
  - **Status:** Satisfied (informational).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-2, R-4, R-6, R-9, R-10, R-11, R-12, R-13 | SC-1 | Phase 1 (reference rule) |
| R-3 | SC-2 | Phase 1 (reference rule) |
| R-5, R-6 | SC-3 | Phase 2 (audit criterion) |
| R-7, R-8, R-14 | SC-4 | Phase 3 (behavioral generation) |
| R-7, R-8 | SC-5 | Phase 3 (clean-room evaluation) |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| spec-structure-standards.md | reference | `.opencode/reference/spec-structure-standards.md` | read of §Prohibited Content Patterns (line 176) and adjacent sections |
| spec-creation create.md | task | `.opencode/skills/spec-creation/tasks/create.md` | read of line 43 Read-link to the reference |
| spec-creation validate.md | task | `.opencode/skills/spec-creation/tasks/validate.md` | read of step 1.2 Read-link and step 3.2 determinism list |
| spec-audit-investigator.md | task | `.opencode/skills/audit/tasks/spec-audit-investigator.md` | read of line 100 Read-link to the reference |
| spec-audit-evaluator.md | task | `.opencode/skills/audit/tasks/spec-audit-evaluator.md` | read of steps 5e/5f narrow criteria (SC-TRACKING-LANG, SC-PRESCRIPTIVE-CODE) |
| tests-v2/AGENTS.md | doc | `.opencode/tests-v2/AGENTS.md` | read of §1 (artifact-only paradigm), §2 (session.yaml primary), §6a (two-SC pattern), §11 (prompt construction mandate) |
| behaviors template | script | `.opencode/tests-v2/behaviors/template.sh` | read of artifact-only generator pattern |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the reference entry exists with the emergent-property wording costs one read/grep pass. Skipping means the false-target rule never lands in the canonical reference, and every future condensation spec can carry a hard numerical threshold that fails in production — a 1000× downstream defect.
- **SC-2:** Verifying the correct/incorrect example pair is present costs one grep pass. Skipping means producers have no concrete compliant pattern to mirror, and the rule is misread as banning all quantitative SCs — a semantic drift caught only when a content-based SC is wrongly rejected.
- **SC-3:** Verifying the audit narrow criterion is anchored costs one read/grep pass. Skipping means the rule is documented but not enforced — a false numerical target passes spec-audit and ships to production.
- **SC-4:** Running the behavioral generation test costs minutes of execution time. Skipping means the enforcement claim is unverified — the agent may silently accept a false numerical target, a behavioral defect caught only when a trimmed spec breaks downstream consumers.
- **SC-5:** Running the clean-room evaluation costs minutes of execution time. Skipping means SC-4's artifacts are never interpreted — the behavioral verdict is missing and the enforcement claim is unproven.

## 11. Edge Cases

- **Condition:** A spec producer writes a content-based SC that happens to include a number (e.g., "the guideline retains all 12 sections").
  - **Expected behavior:** The SC is compliant — it measures content presence, not reduction.
  - **Resolution:** R-10 — the rule targets reduction thresholds as PASS/FAIL targets only; content-presence numbers are not banned.
- **Condition:** A spec producer writes "reduced by at least N tokens" as an SC.
  - **Expected behavior:** The SC is FAIL — it is a false numerical reduction target.
  - **Resolution:** SC-1 (reference entry) and SC-3 (audit criterion) flag it; the producer rewrites the SC as content-based.
- **Condition:** The behavioral test scenario prompt references issue content that does not exist as a fixture.
  - **Expected behavior:** The test cannot run (fixture missing); artifacts are not produced.
  - **Resolution:** The fixture issue MUST exist at behaviors/fixtures/issues/{N}/ before the test runs (testability-assessment risk).
- **Condition:** The behavioral test times out or the model is unavailable.
  - **Expected behavior:** No artifacts produced; SC-4/SC-5 cannot pass.
  - **Resolution:** Clean tmp/.behavior-run.lock and re-run with bash tool timeout >= 600s; FAIL is the only valid outcome if the test cannot execute.
- **Condition:** The clean-room evaluation sub-agent receives orchestrator reasoning or expected outcomes.
  - **Expected behavior:** The evaluation is contaminated; the verdict is not trustworthy.
  - **Resolution:** R-8 and the state-analysis invariant — the sub-agent receives only artifact path + SC criterion; a contaminated evaluation is discarded and re-run.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
