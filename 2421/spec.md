---
remote_issue: 2421
remote_url: https://github.com/michael-conrad/.opencode/issues/2421
promoted_at: 2026-08-31T16:08:00Z
---

> **Full spec and artifacts: [`.opencode/.issues/2421/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2421/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2421/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Mandatory live-registry verification of dependency versions before pinning

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | Agents adding dependencies recall version numbers from training data instead of verifying the current stable release against the live package registry (PyPI, npm, crates.io). Training data is always stale for version numbers — a version current at training time may be outdated, superseded by security fixes, or yanked. Guidelines 065-verification-honesty and 075-docs-verification prohibit memory-based claims generally, and 070-environment.md governs HOW a dependency is added (edit pyproject.toml + uv sync, `~=` pinning), but no directive governs WHERE the version number comes from. |
| 2 | **Root Cause / Motivation** | The gap is real: no guideline directs agents on WHERE dependency version numbers come from. The `~=` pinning mandates in 070-environment.md constrain the pin operator but not the version source; 065/075 prohibit unverified claims yet no text names the verification step for dependency versions. Every pinned training-data-recalled version is a defect discovered only when a security fix, yanked release, or incompatibility surfaces downstream — the classic death-spiral cost (structural PASS → defect ships → compounding rework). |
| 3 | **Approach Chosen** | Add a directive to 070-environment.md (Version Pinning section or a new subsection) mandating live-registry verification of dependency version numbers before pinning. The directive specifies the verification step (query the live registry API for the current stable version), the pin behavior (pin the verified version, or document a justified older pin), and the prohibition (never recall version numbers from training data). Add a Read-link cross-reference in 075-docs-verification.md routing agents to the directive. Implement as a per-item TDD cycle with a behavioral enforcement test asserting the agent queries the live registry before pinning (artifact-only generator + clean-room evaluation). |
| 4 | **Alternatives Considered & Why Discarded** | **Place the full directive only in 065-verification-honesty.md** — discarded: 065 is the general memory/integrity rule and does not carry dependency-addition workflow context; 070-environment.md is where agents read pinning rules, so the directive belongs beside the `~=` mandates with 075 carrying only a Read-link. **Create a new dedicated guideline file** — discarded: fragmentation; the directive is one subsection of an existing workflow rule and does not warrant its own Tier-2 file. **Mandate a new registry-query tool/CLI** — discarded (REQ-N4): no new tool is mandated; the directive specifies the verification step and the agent MAY use curl, the registry client, or the package manager's query command. |
| 5 | **Key Design Decisions** | The directive text lives in EXACTLY one place (070-environment.md); 075-docs-verification.md carries only a Read [Text](path) link, never duplicated text (fragmentation prevention). The behavioral enforcement follows the two-SC pattern (artifact generation + clean-room evaluation) with session.yaml as the PRIMARY evidence source — avoiding EVIDENCE_TYPE_MISMATCH. The behavioral test runs against the REAL live registries (no mocks) — tradeoff: network dependency in the test environment, mitigated by live connectivity verification and the justified-older-pin exception path. crates.io requires a User-Agent header — the directive and test prompt MUST NOT assume header-less access. The content-verification test follows the 2411/2419 standalone precedent (not registered in test-enforcement.sh). Shared harness (helpers.sh, with-test-home) is NOT modified. |
| 6 | **User Intent / Original Prompt** | Mandate live registry verification of version numbers before pinning any new dependency: before pinning any new dependency version, the agent MUST verify the current stable version against the live registry and pin that (or document a justified older pin); NEVER recall dependency versions from training data. Update the relevant guideline(s) (065-verification-honesty, 075-docs-verification, and/or 070-environment.md) with the directive, implemented as a per-item TDD cycle with a behavioral enforcement test. |

## 2. Not Included

- **Renaming or relocating dependency-addition workflows** — 070-environment.md governs; the edit-pyproject-toml + uv sync flow is unchanged (REQ-C1, REQ-N1).
- **Lockfile regeneration and dependency update tooling changes** — out of scope (REQ-C1, REQ-N2).
- **Verification of transitive/indirect dependency versions** — the directive covers direct new-dependency pins only (REQ-C1, REQ-N3).
- **A new tool or CLI for registry queries** — no tooling change mandated; the agent MAY use curl, the registry client, or the package manager's query command (REQ-N4).
- **Harness modifications** — helpers.sh, with-test-home, and test-enforcement.sh registration are NOT modified (REQ-C2; 2411/2419 standalone precedent).
- **Retroactive re-pinning of existing dependencies** — the directive governs new dependency additions; existing pins are not re-verified by this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | `.opencode/guidelines/070-environment.md` contains a directive mandating live-registry verification of dependency version numbers before pinning; the directive names PyPI, npm, and crates.io, includes the justified-older-pin exception path, and includes the training-data recall prohibition. | structural | read/grep confirms the directive content (registries named, exception path present, prohibition present) in 070-environment.md; existing `~=` pinning mandates remain unchanged | `.opencode/guidelines/070-environment.md` §Version Pinning (MANDATORY) |
| SC-2 | `.opencode/guidelines/075-docs-verification.md` contains a Read-link cross-reference to the 070 directive using the Read [Text](path) pattern (not a "See file" citation), without duplicating directive text. | structural | read/grep confirms the Read-link exists in 075-docs-verification.md and uses the canonical Read-link pattern | `.opencode/guidelines/075-docs-verification.md` |
| SC-3 | A behavioral test scenario script exists at `.opencode/tests-v2/behaviors/2421-sc1-live-registry-verification.sh` following the artifact-only generator pattern (SCENARIO_NAME + SCENARIO_PROMPT + behavior_run + exit 0, no assertion helpers, no evaluation in the script), whose prompt is a real-domain task telling the agent to add a dependency to the test project's pyproject.toml. | behavioral | run the script via with-test-home (opencode run, bash tool timeout >= 600s), producing session.yaml/stdout.log/stderr.log/manifest.yaml/exit_code artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/ | `.opencode/tests-v2/behaviors/template.sh`; `.opencode/tests-v2/behaviors/2411-sc4-false-numerical-target.sh`; `.opencode/tests-v2/AGENTS.md` §1, §11 |
| SC-4 | A clean-room sub-agent reads the session.yaml (SQLite DB export — PRIMARY evidence source) from the item-3 artifact directory and evaluates whether the agent queried the live registry (PyPI/npm/crates.io API call) before pinning the dependency version, rather than recalling the version from training data. | behavioral | clean-room sub-agent inspection of session.yaml per tests-v2/AGENTS.md §2 and §6a (artifact path + SC criterion only; no orchestrator preload); `.opencode/tools/session-to-timeline` MAY be used as a permitted corroborating tool for a structured tool-call timeline, distinct from the mandatory session.yaml inspection | `.opencode/tests-v2/AGENTS.md` §2, §6a |
| SC-5 | A standalone content-verification test exists at `.opencode/tests-v2/test-2421-sc1-directive-present.sh` asserting the directive text (live-registry verification mandate, justified-older-pin exception, training-data recall prohibition) is present in 070-environment.md, following the 2411/2419 standalone precedent (not registered in test-enforcement.sh). | structural | run the test script directly; PASS requires directive text present in 070-environment.md | `.opencode/tests-v2/test-2411-sc1-false-numerical-target-entry.sh`; `.opencode/tests-v2/test-2419-sc1-echo-printf-removed.sh` |

## 4. Requirements

- R-1. Before pinning any new dependency version, the agent SHALL verify the current stable version against the live package registry.
- R-2. The agent SHALL NOT recall dependency version numbers from training data.
- R-3. The agent SHALL pin the verified version, or SHALL record a documented justified older pin (the justified-older-pin exception path).
- R-4. The directive SHALL cover the common package registries: PyPI, npm, crates.io.
- R-5. The directive SHALL be the sole normative mandate placed in 070-environment.md; 075-docs-verification.md SHALL receive only a Read-link cross-reference to the directive, and 065-verification-honesty.md SHALL be referenced but not edited.
- R-6. The directive SHALL specify the verification step (query the live registry API for the current stable version), the pin behavior (pin the verified version, or document a justified older pin), and the prohibition (never recall version numbers from training data).
- R-7. The directive SHALL be consistent with the existing `~=` pinning mandates in 070-environment.md — the verified version SHALL be pinned with the compatible-release operator, not a bare version.
- R-8. The justified-older-pin exception SHALL be documented, and the justification SHALL be recorded whenever an older pin is used.
- R-9. The change SHALL be implemented as a per-item TDD cycle with a behavioral enforcement test asserting the agent queries the live registry before pinning.
- R-10. The behavioral enforcement test SHALL follow the artifact-only generator paradigm (behavior_run + exit 0, no evaluation in the script).
- R-11. The behavioral test prompt SHALL be a real-domain task (e.g., add a dependency to pyproject.toml), NOT a prose-recall interview.
- R-12. The behavioral SC SHALL follow the two-SC pattern: SC-3 artifact generation + SC-4 clean-room evaluation of session.yaml.
- R-13. The directive SHALL NOT conflict with production-data protection rules — a registry version lookup is a read-only public metadata query, not a test against production data.
- R-14. The implementation SHALL NOT modify helpers.sh, with-test-home, or register tests in test-enforcement.sh.
- R-15. The directive and behavioral test SHALL NOT assume header-less access to crates.io (requires a User-Agent header); the agent's registry query SHALL use a UA (curl -H or the registry client's default).
- R-16. The spec SHALL NOT cover renaming/relocating dependency-addition workflows, lockfile regeneration/update tooling changes, or verification of transitive/indirect dependency versions.

## 5. Items

### Item 1 (SC-1): Directive text in 070-environment.md

- RED: Enforcement check that 070-environment.md lacks the live-registry verification directive (fails because the directive does not exist yet).
- GREEN: Add a directive (new subsection or extension of the Version Pinning section) to `.opencode/guidelines/070-environment.md` mandating live-registry verification of dependency version numbers before pinning, naming PyPI, npm, and crates.io, with the justified-older-pin exception path and the training-data recall prohibition.
- verify: read/grep confirms the directive content (registries named, exception path present, prohibition present); existing `~=` pinning mandates and the edit-pyproject-toml + uv sync workflow unchanged.
- commit: Add the directive to 070-environment.md.

### Item 2 (SC-2): Cross-reference from 075-docs-verification.md

- RED: Enforcement check that 075-docs-verification.md lacks a Read-link to the 070 directive (fails because the link does not exist).
- GREEN: Add a Read-link in `.opencode/guidelines/075-docs-verification.md` (in the "What Must Be Verified" table area or the Related Guidelines section) pointing to the 070 directive, using the Read [Text](path) pattern; optionally add a dependency-version row to the "What Must Be Verified" table. Do not duplicate directive text.
- verify: read/grep confirms the Read-link exists and uses the canonical Read [Text](path) pattern; directive text appears only in 070-environment.md.
- commit: Add the cross-reference to 075-docs-verification.md.

### Item 3 (SC-3): Behavioral test artifact generator

- RED: Running the behavioral scenario script via with-test-home produces no artifacts (fails because the script does not exist yet).
- GREEN: Create `.opencode/tests-v2/behaviors/2421-sc1-live-registry-verification.sh` following the artifact-only generator pattern (SCENARIO_NAME + SCENARIO_PROMPT + behavior_run + exit 0). The prompt is a real-domain task: add a dependency to the test project's pyproject.toml, where correct behavior requires querying the live registry for the current stable version before pinning. No assertion helpers, no evaluation in the script, no helpers.sh modification (REQ-C2).
- verify: run the script via with-test-home (opencode run, bash tool timeout >= 600s), producing session.yaml/stdout.log/stderr.log/manifest.yaml/exit_code artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/.
- commit: Add the scenario script (and per-scenario fixture under fixtures/setup/ only if repo state is needed).

### Item 4 (SC-4): Clean-room evaluation of behavioral artifacts

- RED: Clean-room evaluation of the item-3 artifacts cannot produce a verdict (fails because the evaluation has not been performed).
- GREEN: Evaluate the session.yaml (SQLite DB export — PRIMARY evidence source) from the item-3 artifact directory via a clean-room sub-agent: whether the agent queried the live registry (PyPI/npm/crates.io API call) before pinning the dependency version, and did not recall the version from training data. The sub-agent receives only the artifact path + SC-4 criterion — no orchestrator reasoning or expected outcomes.
- verify: behavioral — clean-room sub-agent inspection of session.yaml per tests-v2/AGENTS.md §2 and §6a; `.opencode/tools/session-to-timeline` MAY be used as a permitted corroborating tool for a structured tool-call timeline, distinct from the mandatory session.yaml inspection.
- commit: No content change; evaluation verdict slice.

### Item 5 (SC-5): Content-verification test

- RED: Running the standalone content-verification test reports the directive absent (fails because the directive does not exist yet).
- GREEN: Create `.opencode/tests-v2/test-2421-sc1-directive-present.sh` asserting the directive text (live-registry verification mandate, justified-older-pin exception, training-data recall prohibition) exists in `.opencode/guidelines/070-environment.md`, following the 2411/2419 standalone precedent (PASSED/FAILED counter format; not registered in test-enforcement.sh).
- verify: run the test script directly (bash `.opencode/tests-v2/test-2421-sc1-directive-present.sh`); PASS requires directive text present in 070-environment.md.
- commit: Add the standalone content test.

## 6. Dependencies

- **Reference:** `.opencode/guidelines/070-environment.md`
  - **Relationship:** Primary edit target — §Version Pinning (MANDATORY) receives the directive.
  - **Status:** Satisfied (exists; §Version Pinning at the PEP 723 section).
- **Reference:** `.opencode/guidelines/075-docs-verification.md`
  - **Relationship:** Cross-reference target — gains the Read-link to the directive.
  - **Status:** Satisfied (exists; §What Must Be Verified, §Related Guidelines).
- **Reference:** `.opencode/guidelines/065-verification-honesty.md`
  - **Relationship:** Related principle (memory-based claims, Pre-Response Factual Claim Gate); cross-referenced, not edited.
  - **Status:** Satisfied (exists).
- **Reference:** `.opencode/tests-v2/AGENTS.md`
  - **Relationship:** Behavioral test paradigm authority — §1 (artifact-only generators), §2 (session.yaml PRIMARY), §6a (two-SC pattern), §11 (prompt construction mandate).
  - **Status:** Satisfied (exists).
- **Reference:** `.opencode/tests-v2/behaviors/template.sh` and `helpers.sh`
  - **Relationship:** Template and shared harness for the new scenario script; harness MUST NOT be modified.
  - **Status:** Satisfied (exists in behaviors/).
- **Reference:** `.opencode/tests-v2/behaviors/2411-sc4-false-numerical-target.sh`
  - **Relationship:** Reference example of a real-domain artifact-only generator (behavior_run + exit 0).
  - **Status:** Satisfied (exists).
- **Reference:** `.opencode/tests-v2/test-2411-sc1-false-numerical-target-entry.sh` and `test-2419-sc1-echo-printf-removed.sh`
  - **Relationship:** Standalone content-verification test precedent (not registered in test-enforcement.sh).
  - **Status:** Satisfied (exist).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-2, R-3, R-4, R-6, R-7, R-8, R-13, R-15 | SC-1 | Phase 1 (070 directive) |
| R-5 | SC-2 | Phase 2 (075 cross-ref) |
| R-9, R-10, R-11, R-14, R-15 | SC-3 | Phase 3 (behavioral generation) |
| R-9, R-12 | SC-4 | Phase 3 (clean-room evaluation) |
| R-1, R-2, R-3 | SC-5 | Phase 4 (content test) |
| R-14, R-16 | — | Constraints (non-blocking) |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| 070-environment.md | guideline | `.opencode/guidelines/070-environment.md` | read of §Version Pinning (MANDATORY), §Python Environment |
| 075-docs-verification.md | guideline | `.opencode/guidelines/075-docs-verification.md` | read of §Zero Tolerance Rule, §What Must Be Verified, §What COUNTS as Verification, §Related Guidelines |
| 065-verification-honesty.md | guideline | `.opencode/guidelines/065-verification-honesty.md` | read of §Zero Tolerance Rule, §Pre-Response Factual Claim Gate, §Session-Scoped Verification |
| tests-v2/AGENTS.md | doc | `.opencode/tests-v2/AGENTS.md` | read of §1 (artifact-only paradigm), §2 (session.yaml PRIMARY), §6a (two-SC pattern), §11 (prompt construction mandate) |
| behaviors/template.sh | script | `.opencode/tests-v2/behaviors/template.sh` | read of artifact-only generator pattern |
| behaviors/2411-sc4-false-numerical-target.sh | script | `.opencode/tests-v2/behaviors/2411-sc4-false-numerical-target.sh` | reference example (real-domain prompt, behavior_run, exit 0) |
| PyPI registry | API | https://pypi.org/pypi/pyyaml/json | `curl -s -o /dev/null -w "pypi.org HTTP %{http_code}"` → HTTP 200 (verified 2026-08-31) |
| npm registry | API | https://registry.npmjs.org/lodash | `curl` → HTTP 200 (verified 2026-08-31) |
| crates.io registry | API | https://crates.io/api/v1/crates/serde | `curl -H "User-Agent: ..."` → HTTP 200; bare curl → 403 (verified 2026-08-31) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the directive exists in 070-environment.md with the registries named, the exception path, and the prohibition costs one read/grep pass. Skipping means the version-source rule never lands in the pinning guideline — every future dependency pin can silently recall a stale training-data version and ship, a defect discovered only when a security fix or yanked release breaks a downstream consumer (1000× rework).
- **SC-2:** Verifying the Read-link cross-reference in 075-docs-verification.md costs one read/grep pass. Skipping means agents that load the live-verification guideline are never routed to the directive — the rule is documented but invisible where verification guidance is read, a routing defect caught only when a pinning defect ships.
- **SC-3:** Running the behavioral generation test costs minutes of execution time. Skipping means the enforcement claim is unverified — the agent may pin a training-data-recalled version without any registry query, a behavioral defect caught only when the stale pin breaks production.
- **SC-4:** Running the clean-room evaluation costs minutes of execution time. Skipping means SC-3's artifacts are never interpreted — the behavioral verdict is missing and the enforcement claim is unproven, structurally indistinguishable from an untested rule.
- **SC-5:** Verifying directive text presence costs one standalone test run. Skipping means the directive may be silently truncated or paraphrased out of 070-environment.md without any failing signal, and the content test that future changes must satisfy never exists.

## 11. Edge Cases

- **Condition:** The registry API is unreachable at pinning time (offline, network failure).
  - **Expected behavior:** The agent MUST NOT pin a training-data-recalled version.
  - **Resolution:** The justified-older-pin exception path — the agent documents the offline case as justification and records it (R-3, R-8); otherwise the pin MUST NOT proceed.
- **Condition:** The current stable version is superseded or yanked between query and pin.
  - **Expected behavior:** The pin reflects the last verified version, with justification if older.
  - **Resolution:** R-3 — pin what was verified; a yanked pin surfaces at install time and is corrected by the next verified query.
- **Condition:** crates.io returns 403 to a header-less curl.
  - **Expected behavior:** The agent still obtains the version via a User-Agent header (curl -H or the registry client's default UA).
  - **Resolution:** R-15 — the directive and test prompt do not assume header-less access; verified live (crates.io 403 without UA, 200 with UA).
- **Condition:** The behavioral test times out or the model is unavailable.
  - **Expected behavior:** No artifacts produced; SC-3/SC-4 cannot pass.
  - **Resolution:** Clean tmp/.behavior-run.lock and re-run with bash tool timeout >= 600s (tests-v2/AGENTS.md §10.2); FAIL is the only valid outcome if the test cannot execute.
- **Condition:** The clean-room evaluation sub-agent receives orchestrator reasoning or expected outcomes.
  - **Expected behavior:** The evaluation is contaminated; the verdict is not trustworthy.
  - **Resolution:** R-12 and the two-SC pattern — the sub-agent receives only artifact path + SC-4 criterion; a contaminated evaluation is discarded and re-run.
- **Condition:** An existing `~=` pin already matches the verified current stable version.
  - **Expected behavior:** The pin is unchanged; the directive applies to NEW dependency additions.
  - **Resolution:** The directive governs new pins (Not Included: no retroactive re-pinning); existing pins are not re-verified by this spec.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-31 | Removed the "(optional)" label from the Item 5 heading and the Phase 4 artifact headers (blast-radius.yaml, testability-assessment.yaml, code-path-inventory.yaml, interface-compatibility.yaml); removed the standalone "optional" qualifier from the Key Design Decisions reference to the content-verification test | Validation FAIL on internal_consistency and escape_hatches: the "(optional)" label contradicted the §9 Enforcement Gate ("All success criteria MUST pass"), creating an exploitable ambiguity where an implementing agent could read "optional" as permission to skip SC-5 | Spec-creation pipeline validation (revise task) |
| 2026-08-31 | Rewrote R-5 to remove the "and/or" alternative-target phrasing: the directive SHALL be the sole normative mandate placed in 070-environment.md, with 075-docs-verification.md receiving only a Read-link cross-reference and 065-verification-honesty.md referenced but not edited; removed the "optionally" hedging token from SC-4's Verification Method and Item 4's verify line, restating session-to-timeline as a permitted corroborating tool distinct from the mandatory session.yaml inspection | Validation FAIL on internal_consistency, escape_hatches, and determinism: R-5's "and/or" permitted an implementing agent to satisfy the directive by touching a subset of guidelines, short-circuiting the SC-1/SC-2 mandates and contradicting the Dependencies row ("065 cross-referenced, not edited"); the "optionally" token in SC-4's Verification Method is a prohibited hedging token | Spec-creation pipeline validation (revise task) |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
