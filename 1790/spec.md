# [SPEC-FIX] Behavioral tests vbfc-behavioral-evidence-distinction and structural-evidence-fail use invalid prose-recall prompts

<!-- REVISED: SC-12 — Add Intent and Executive Summary preamble -->
## Intent and Executive Summary

| Field | Content |
|-------|---------|
| **Problem Statement** | Two behavioral tests (`vbfc-behavioral-evidence-distinction.sh`, `structural-evidence-fail.sh`) use invalid prose-recall (interview-style) prompts instead of real-domain task prompts, violating `tests/AGENTS.md` §9 Prompt Construction Mandate. |
| **Root Cause / Motivation** | These tests were written before `tests/AGENTS.md` §9 existed. When §9 was added mandating real-domain prompts, these existing tests were never audited for compliance. A broader scan of `tests/behaviors/` reveals 3 additional test files (`issue-1227-discovery-directive.sh`, `model-aware-clean-room-dispatch.sh`, `terminology-standardization.sh`) that may contain similar prose-recall patterns. |
| **Approach Chosen** | Replace the prose-recall prompts in both files with real-domain task prompts that trigger natural agent behavior. Add a Scope Note acknowledging the systemic issue across other test files. |
| **Alternatives Considered & Why Discarded** | (1) Add new tests alongside existing ones — rejected because the existing tests are still invalid and duplicating effort doesn't fix the root cause. (2) Delete the tests entirely — rejected because the original intent (verifying agent rejects structural evidence for behavioral SCs) is still valuable; only the prompts need replacement. (3) Fix all 5 identified test files in this spec — rejected because scope would expand beyond the two files identified in #1789 root cause analysis; those other files should get separate specs. |
| **Key Design Decisions** | (1) Preserve original test intent (structural evidence rejection) while replacing only the prompt mechanism. (2) Scope this spec to the two files identified in #1789; other files tracked separately. (3) Add executable verification command to SC-3 since it declares behavioral evidence type. |

---

## Problem

Two behavioral tests use invalid prose-recall (interview-style) prompts per `tests/AGENTS.md` §9 Prompt Construction Mandate. These test whether the agent can *narrate* the rule, not whether it *follows* it in a real verification workflow.

| Test | Prompt | Why Invalid |
|------|--------|-------------|
| `vbfc-behavioral-evidence-distinction.sh` | "Explain your evidence classification" | Prose-recall — asks agent to *describe* what it would do |
| `structural-evidence-fail.sh` | Three scenarios: "Mark this SC as PASS", "Is this PASS?", "Can I mark this SC as PASS?" | Prose-recall — interview questions about hypotheticals |

A valid prompt would be a real-domain task like: "Verify SC-3 from spec #42" — something the agent would actually do in normal operation.

## Root Cause

The tests were written before `tests/AGENTS.md` §9 (Prompt Construction Mandate) existed. When §9 was added mandating real-domain prompts, these existing tests were never audited for compliance.

## Affected Files

- `tests/behaviors/vbfc-behavioral-evidence-distinction.sh` — Replace prose-recall prompt with real-domain task prompt
- `tests/behaviors/structural-evidence-fail.sh` — Replace prose-recall prompt with real-domain task prompt

<!-- REVISED: SC-11 — Add Documentation Sources section -->
## Documentation Sources

| Source | Reference | Verification Method | Status |
|--------|-----------|---------------------|--------|
| `tests/AGENTS.md` §9 Prompt Construction Mandate | Defines valid vs invalid prompt types for behavioral tests | Read `tests/AGENTS.md` — §9 mandates real-domain prompts, prohibits prose-recall | Verified |
| `080-code-standards.md` §Enforcement Test Mandate | Defines behavioral vs content-verification test hierarchy | Read `080-code-standards.md` — behavioral tests are PRIMARY enforcement gate | Cross-reference |
| `080-code-standards.md` §Evidence Type Taxonomy | Defines behavioral evidence type requirements | Read `080-code-standards.md` — behavioral SCs require test execution evidence | Cross-reference |

## Success Criteria

<!-- REVISED: SC-3 — Add executable verification command for behavioral evidence type -->

| ID | Criterion | Evidence Type | Verification Command |
|----|-----------|---------------|---------------------|
| SC-1 | `vbfc-behavioral-evidence-distinction.sh` uses a real-domain task prompt (not interview-style prose-recall) per tests/AGENTS.md §9 | `string` | `grep -P 'prompt=' .opencode/tests/behaviors/vbfc-behavioral-evidence-distinction.sh \| grep -v 'Explain\|What would you\|How would you\|Is this.*correct\|Can I mark'` |
| SC-2 | `structural-evidence-fail.sh` uses a real-domain task prompt (not interview-style prose-recall) per tests/AGENTS.md §9 | `string` | `grep -P 'prompt=' .opencode/tests/behaviors/structural-evidence-fail.sh \| grep -v 'Explain\|What would you\|How would you\|Is this.*correct\|Can I mark'` |
| SC-3 | Both tests still verify the original intent (agent rejects structural evidence for behavioral SCs) after prompt replacement | `behavioral` | `bash .opencode/tests/behaviors/vbfc-behavioral-evidence-distinction.sh && bash .opencode/tests/behaviors/structural-evidence-fail.sh` — verify both produce behavioral evidence artifacts (stdout.log, stderr.log, session.yaml) with semantic assertions confirming structural evidence rejection. A PASS verdict from both test scripts is the required outcome. |

<!-- REVISED: SC-8 — Add Edge Case Handling section -->
## Edge Case Handling

| Edge Case | Detection | Resolution |
|-----------|-----------|------------|
| Replacement prompt still triggers prose-recall behavior | Semantic inspector in test run flags agent response as interview-style rather than task-execution | Revert prompt to previous version, investigate prompt wording, retry with alternative real-domain framing |
| Semantic assertions no longer apply after prompt change | Test run produces FAIL from existing `assert_semantic` calls | Update assertion text to match new prompt's expected agent behavior while preserving original test intent (structural evidence rejection) |
| Model behaves differently with new prompt (e.g., refuses task, produces different tool-call pattern) | Test run produces empty stdout or unexpected stderr | Increase `BEHAVIOR_TIMEOUT`, try alternative model via `BEHAVIOR_MODEL`, document model-specific behavior in test notes |
| Replacement prompt is syntactically invalid (shell escaping issues) | Bash execution error before agent dispatch | Fix shell escaping in prompt string, verify with dry-run `echo` before test execution |
| Original test intent changes during prompt replacement | Post-implementation review reveals test now verifies different behavior | HALT, report scope discrepancy, revise spec if needed |

## Constraints

- Prompts must trigger natural agent behavior: a real task the agent would actually DO, not a question about what it WOULD do
- Valid patterns: "Verify SC-N from spec at path/to/spec.md" — triggers actual verification workflow
- Invalid patterns: "What would you do if...", "Explain how you would...", "Is this correct?"
- Behavioral assertions in tests must be updated to match new prompt semantics while preserving the original rejection intent

## Dependencies

- None — independent fix, pre-existing defect discovered during #1789 root cause analysis

<!-- REVISED: scope_narrowness — Add Scope Note -->
## Scope Note

This spec fixes two specific test files identified in #1789 root cause analysis. A preliminary scan of `tests/behaviors/` reveals 3 additional files that may contain prose-recall patterns:

- `issue-1227-discovery-directive.sh`
- `model-aware-clean-room-dispatch.sh`
- `terminology-standardization.sh`

These files are **out of scope** for this spec. The root cause (tests written before §9) may apply to them, but each should be evaluated and fixed via separate specs to maintain single-concern discipline. If any of these files are confirmed to use prose-recall prompts, they should be filed as follow-up `[SPEC-FIX]` issues.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
