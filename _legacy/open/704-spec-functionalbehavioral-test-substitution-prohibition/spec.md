---
number: 704
title: "[SPEC] Functional/Behavioral Test Substitution Prohibition — critical-rules-053"
status: "open"
labels: [spec, critical]
created: "2026-05-20T19:26:12.019545Z"
updated: "2026-05-20T19:29:34.062678Z"
github_issue: 603
author: "Michael Conrad"
github_url: "https://github.com/michael-conrad/.opencode/issues/603"
promoted_at: "2026-05-20T19:19:36Z"
remote_issue: "603"
remote_url: "https://github.com/michael-conrad/.opencode/issues/603"
---

## Problem

AI agents substitute structural/meta checks (grep, string matching, file-existence, metadata inspection) when behavioral/functional tests cannot be executed. The existing rules say "you must run behavioral tests" but don't address the fallback path: when the test **cannot** run, the agent rationalizes substitution because no rule explicitly says "report FAIL — never substitute."

This extends and addresses the problem space of Issue `opencode-config#57` (closed as not-planned). While `critical-rules-047` covers file-existence-as-behavioral-evidence, it does NOT cover the broader case.

### Root Cause

Three gaps enable the substitution bypass:

1. **No explicit cannot-run → FAIL rule.** Current rules mandate running behavioral tests but don't specify the outcome when execution is impossible.
2. **No universal substitution prohibition.** `critical-rules-047` covers file-existence only. Grep, string matching, metadata checks, and static analysis substitutions are not covered.
3. **No "functional test" terminology.** The codebase uses "behavioral test" exclusively. Agents encountering "functional test" may not map it to behavioral enforcement rules.

## Changes (Summary)

### Change 1: `000-critical-rules.md` — New critical-rules-053 section
Add prose section and yaml+symbolic rule for functional/behavioral test substitution prohibition.

### Change 2: `020-go-prohibitions.md` — Substitution prohibition entries
Add ALWAYS DO and NEVER DO entries.

### Change 3: `080-code-standards.md` — Terminology bridge + symbolic rule
Add "behavioral test" and "functional test" are synonymous terminology note and `code-standards-009` symbolic rule.

### Change 4: `verification-before-completion/tasks/verify.md` — "When Tests Cannot Execute" section
Add outcome table and remediation-first requirements.

### Change 5: Behavioral enforcement test
Create `.opencode/tests/behaviors/functional-test-substitution-prohibited.sh`.

### Change 6: Content-verification test
Add scenario to `test-enforcement.sh`.

### Change 7: Update Tier 1 mandate table
Add row for critical-rules-053.

## Success Criteria

1. **SC-1:** `critical-rules-053` symbolic rule exists with conditions covering PASS/UNVERIFIED with structural substitute, substitution attempts
2. **SC-2:** Prose section `[critical-rules-053]` exists defining "functional test" = "behavioral test" and mandating FAIL when tests cannot execute
3. **SC-3:** `020-go-prohibitions.md` contains ALWAYS DO and NEVER DO entries for substitution prohibition
4. **SC-4:** `080-code-standards.md` contains terminology bridge and `code-standards-009` symbolic rule
5. **SC-5:** `verify.md` contains "When Behavioral/Functional Tests Cannot Execute" section
6. **SC-6:** Tier 1 mandate table includes row for critical-rules-053
7. **SC-7:** Behavioral test with 5 assertions (BT-1 through BT-5)
8. **SC-8:** Content-verification scenario exists

## Accountability Model Alignment (per #763)

This spec is a **blocking dependency** of #763. Principle 6 (skipped functional/behavioral testing is a fail, no exceptions) directly references this spec's definition of substitution prohibition.

**Principle P7 alignment:** The "REQUIRED when a behavioral test cannot run" section already has remediation-first language. Under #763, "await human intervention" must be tightened: agent must attempt ALL available remediation paths before escalation.

**Dependency chain:** This issue MUST merge before #763 Phase 1.

## Change Control

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-05-15 | Initial spec (migrated from opencode-config#74) | |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)