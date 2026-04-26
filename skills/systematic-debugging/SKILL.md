---
name: systematic-debugging
description: Use when encountering a bug, error, or unexpected behavior, or before making code changes to fix an issue. Triggers on: bug, error, fix, debug, diagnose, crash, failure, unexpected behavior, vibe debugging.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: systematic-debugging

## Overview

Systematic debugging process that enforces root cause analysis, hypothesis testing, and minimal fixes. Prevents "vibe debugging" — making random changes without understanding the problem. All bugs must be diagnosed before fixing, and fixes must be minimal and targeted.

**Source Attribution:** This skill is adapted from <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `diagnose` | Systematic bug diagnosis workflow | ≈400 |
| `fix` | Minimal targeted fix after diagnosis | ≈350 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Invocation

- `/skill systematic-debugging` — Overview only
- `/skill systematic-debugging --task diagnose` — Diagnose a bug
- `/skill systematic-debugging --task fix` — Apply minimal fix
- `/skill systematic-debugging --task completion` — Invoke when workflow halts at any point

## Operating Protocol

1. **Diagnosis-first approach:** All bugs require diagnosis before fix. Diagnosis must identify root cause. Fix must target root cause, not symptoms. Fix must be minimal — no scope creep.
2. **Mandatory invocation:** The agent MUST invoke this skill when a bug or error is encountered during implementation, or when user reports a bug or says "fix this" or "debug this."
3. **Exit conditions:** Debugging is COMPLETE when root cause identified and documented, fix applied targeting root cause only, verification confirms fix resolves issue, and no new issues introduced.
4. **Authorization separation:** Bug diagnosis does NOT require approval (read-only). Bug FIX requires approval (code change). See `approval-gate` skill for authorization workflow.
5. **Self-correction:** If the agent catches itself editing code without an approved spec, immediately `git checkout -- <affected-files>` and HALT.

## Bug Discovery Guardrail

**⚠️ Finding a bug during diagnosis does NOT authorize fixing it.**

| Action | Requires Authorization? |
|--------|------------------------|
| Diagnosis (read-only analysis) | ❌ No |
| Fix (code change) | ✅ Yes — requires approved spec or explicit "approved"/"go" |
| Creating bug report issue | ❌ No — always permitted |
| Invoking `analyze-and-spec` after bug report | ❌ No — auto-proceeds to fix spec creation |

**After creating a bug report issue, invoke `issue-review --task analyze-and-spec` to perform root cause analysis and create a fix spec sub-issue.** This ensures every bug report has a corresponding fix spec before closure.

### Bug Report → Fix Spec Flow

When the `diagnose` task creates a bug report:

1. Bug report issue created (permitted without authorization)
2. Invoke `/skill issue-review --issue N --task analyze-and-spec` automatically
3. Root cause analysis performed
4. Fix spec sub-issue created and linked to bug report
5. Fix spec requires explicit authorization before code changes proceed

## Enforcement Matrix

| Situation | Action |
|-----------|--------|
| Bug reported, no diagnosis | REQUIRE diagnosis first |
| Diagnosis incomplete | COMPLETE diagnosis before fix |
| Fix targets symptoms, not root cause | REJECT fix, require root cause fix |
| Fix includes unrelated changes | REJECT scope creep |
| Fix is refactoring disguised as bug fix | REJECT, require spec |

## Live Verification: Hypothesis Evidence (MANDATORY)

**🚫 CRITICAL: When this skill forms a hypothesis about a bug's root cause, it MUST verify the hypothesis against live code/runtime evidence before proceeding. Hypotheses without verification are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Hypothesis Claim | Verification Action | Tool Call | Problem Class |
|-----------------|-------------------|-----------|---------------|
| "Bug is in function X" | Verify function X actually exhibits the buggy behavior (trace execution, read source) | `srclight_get_symbol(name="X")` → read implementation | VERIFICATION-GAP |
| "Error caused by missing dependency Y" | Verify dependency Y is actually missing or misconfigured | `srclight_get_callers(symbol_name="Y")` → check usage | CONFLICTING |
| "Code path reaches Z" | Verify actual call path via call graph | `srclight_get_callees(symbol_name="caller")` → trace execution | VERIFICATION-GAP |
| "Fix is minimal — only change file F" | Verify no other files depend on the changed code | `srclight_get_dependents(symbol_name="symbol")` → check blast radius | CONFLICTING |
| "No new issues introduced" | Verify by running tests after fix | `bash` to run `uv run pytest test/` → confirm pass | VERIFICATION-GAP |

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
| Bug not in assumed function | VERIFICATION-GAP | conditional | Broaden search, form new hypothesis |
| Dependency not actually missing | CONFLICTING | conditional | Re-hypothesize root cause |
| Call path doesn't reach target | VERIFICATION-GAP | conditional | Re-trace actual execution path |
| Fix has larger blast radius | CONFLICTING | flag-for-review | HALT — fix may need broader scope |
| Tests fail after fix | VERIFICATION-GAP | flag-for-review | HALT — revert and re-diagnose |

## Cross-Reference Verification (MANDATORY)

**🚫 CRITICAL: Each cross-reference must be verified against actual skill content. Assertions without verification are VERIFICATION-GAP findings.**

| Reference | Verification | Finding Class |
| -- | -- | -- |
| `verification-before-completion` in Cross-References | File exists at `.opencode/skills/verification-before-completion/SKILL.md` | MISSING-TRACEABILITY if missing |
| `approval-gate` in Cross-References | File exists at `.opencode/skills/approval-gate/SKILL.md` | MISSING-TRACEABILITY if missing |
| `git-workflow` in Cross-References | File exists at `.opencode/skills/git-workflow/SKILL.md` | MISSING-TRACEABILITY if missing |
| `issue-review` in Bug Discovery Guardrail | File exists at `.opencode/skills/issue-review/SKILL.md` | MISSING-TRACEABILITY if missing |
| `spec-auditor` ground-truth subtask | File exists at `.opencode/skills/spec-auditor/tasks/ground-truth.md` | MISSING-TRACEABILITY if missing |
| `065-verification-honesty.md` metadata extension | Guideline contains "Metadata Verification Extension" section | CONFLICTING if missing |
| Task table entry `diagnose` | File exists at `.opencode/skills/systematic-debugging/tasks/diagnose.md` | MISSING-TRACEABILITY if missing |
| Task table entry `fix` | File exists at `.opencode/skills/systematic-debugging/tasks/fix.md` | MISSING-TRACEABILITY if missing |
| Task table entry `completion` | File exists at `.opencode/skills/systematic-debugging/tasks/completion.md` | MISSING-TRACEABILITY if missing |

**Verification Procedure:**

Before invoking any cross-referenced skill:
1. `ls .opencode/skills/<skill-name>/SKILL.md` → EVIDENCE: file exists or MISSING-TRACEABILITY
2. `grep -c "<task-name>" .opencode/skills/<skill-name>/SKILL.md` → EVIDENCE: task referenced or MISSING-TRACEABILITY
3. Compare described behavior with actual content → EVIDENCE: match or CONFLICTING

**Classification on failure:**

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Referenced skill file missing | MISSING-TRACEABILITY | flag-for-review | Cannot verify cross-reference |
| Referenced task file missing | MISSING-TRACEABILITY | flag-for-review | Task may have been renamed |
| Described behavior mismatches | CONFLICTING | flag-for-review | Cross-reference may be stale |

**Adversarial cross-reference:** The `spec-auditor --task ground-truth` subtask (Phase 1 of spec #827) performs adversarial verification of metadata claims including authorization currency and code reference existence. When this skill forms a hypothesis about code behavior, ground-truth verification ensures the referenced code actually exists and behaves as claimed. See `065-verification-honesty.md` → "Metadata Verification Extension" for the extended principle.

## Cross-References

- Related skills: `verification-before-completion` (evidence), `approval-gate` (authorization), `git-workflow` (branch), `issue-review` (analyze-and-spec for bug reports), `spec-auditor` (ground-truth adversarial verification)
- Related guidelines: `050-scope-autonomy.md` (no vibe coding), `090-data-integrity.md` (no synthetic data), `065-verification-honesty.md` (metadata verification extension)
- Related task files: `diagnose.md`, `fix.md`

## Platform Compatibility

- **GitHub:** Not applicable (this repository uses GitBucket)
- **GitBucket:** Use Python client from gitbucket-api skill
- **Platform Detection:** Uses `github.platform` environment variable

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps are never skipped. It is idempotent and safe to invoke multiple times.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: sys-debug-001
    title: "Read-only analysis mandate during diagnosis"
    conditions:
      all:
        - "current_task == 'diagnose'"
        - "code_modification_attempted == true"
    actions:
      - HALT
      - REVERT(git checkout -- <affected-files>)
    conflicts_with: []
    requires: []
    triggers: [diagnose]
    source: "systematic-debugging/SKILL.md §Operating Protocol point 4"

  - id: sys-debug-002
    title: "Bug discovery does NOT authorize fixing"
    conditions:
      all:
        - "bug_found_during_diagnosis == true"
        - "fix_authorization_received == false"
    actions:
      - HALT
      - CREATE(bug_report_issue)
      - INVOKE(issue-review --task analyze-and-spec)
    conflicts_with: []
    requires: []
    triggers: [diagnose]
    source: "systematic-debugging/SKILL.md §Bug Discovery Guardrail"

  - id: sys-debug-003
    title: "Hypothesis must be verified before proceeding"
    conditions:
      all:
        - "hypothesis_formed == true"
        - "hypothesis_verified_against_live_evidence == false"
    actions:
      - HALT
      - VERIFY(via srclight_get_symbol OR srclight_get_callees OR bash)
    conflicts_with: []
    requires: []
    triggers: [diagnose]
    source: "systematic-debugging/SKILL.md §Live Verification"

  - id: sys-debug-004
    title: "Fix must target root cause, not symptoms"
    conditions:
      all:
        - "fix_applied == true"
        - "fix_targets_root_cause == false"
    actions:
      - REJECT
      - REVERT
    conflicts_with: []
    requires: []
    triggers: [fix]
    source: "systematic-debugging/SKILL.md §Enforcement Matrix"

  - id: sys-debug-005
    title: "Self-correction on unauthorized code edits"
    conditions:
      all:
        - "code_edited_without_spec == true"
    actions:
      - REVERT(git checkout -- <affected-files>)
      - HALT
    conflicts_with: []
    requires: []
    triggers: [diagnose, fix]
    source: "systematic-debugging/SKILL.md §Operating Protocol point 5"

  - id: sys-debug-006
    title: "Fix requires authorization; diagnosis does not"
    conditions:
      all:
        - "action == 'code_change'"
        - "authorization_received == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [fix]
    source: "systematic-debugging/SKILL.md §Operating Protocol point 4"

  - id: sys-debug-007
    title: "No scope creep in fixes"
    conditions:
      all:
        - "fix_applied == true"
        - "fix_includes_unrelated_changes == true"
    actions:
      - REJECT
    conflicts_with: []
    requires: []
    triggers: [fix]
    source: "systematic-debugging/SKILL.md §Enforcement Matrix"

tasks:
  - id: diagnose
    skill: systematic-debugging
    preconditions: ["bug_or_error_identified"]
    postconditions: ["root_cause_identified", "hypothesis_verified", "bug_report_created_if_new_bug"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping diagnosis leads to vibe debugging — random changes without understanding"
    source: "systematic-debugging/SKILL.md §Tasks"

  - id: fix
    skill: systematic-debugging
    preconditions: ["diagnosis_complete", "root_cause_identified", "authorization_received"]
    postconditions: ["fix_applied_targeting_root_cause", "verification_tests_pass", "no_new_issues_introduced"]
    mandatory: true
    bypass_violation: "CRITICAL: Fix without diagnosis targets symptoms, not root cause"
    source: "systematic-debugging/SKILL.md §Tasks"

  - id: completion
    skill: systematic-debugging
    preconditions: ["workflow_halted_or_completed"]
    postconditions: ["mandatory_steps_verified", "status_reported"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping completion task may leave terminal-state dispatch unverified"
    source: "systematic-debugging/SKILL.md §Tasks"

decomposition:
  - type: skill-task
    skill: issue-review
    task: analyze-and-spec
    mandatory: true
    bypass_violation: "After creating bug report, root cause analysis and fix spec creation must follow"
    source: "systematic-debugging/SKILL.md §Bug Discovery Guardrail"

  - type: skill-task
    skill: approval-gate
    task: verify-authorization
    mandatory: true
    bypass_violation: "Code fixes require authorization; diagnosis is read-only and exempt"
    source: "systematic-debugging/SKILL.md §Operating Protocol point 4"

  - type: skill-task
    skill: verification-before-completion
    task: verify
    mandatory: true
    bypass_violation: "Post-fix verification confirms fix resolves issue without introducing new problems"
    source: "systematic-debugging/SKILL.md §Cross-References"

gates:
  - id: no-code-edits-during-diagnosis
    condition: "code_modification_attempted == false"
    on_fail: HALT
    critical_violation: true
    source: "systematic-debugging/SKILL.md §Operating Protocol point 4"

  - id: hypothesis-verified
    condition: "hypothesis_verified_against_live_evidence == true"
    on_fail: HALT
    critical_violation: false
    source: "systematic-debugging/SKILL.md §Live Verification"

  - id: fix-targets-root-cause
    condition: "fix_targets_root_cause == true"
    on_fail: HALT
    critical_violation: true
    source: "systematic-debugging/SKILL.md §Enforcement Matrix"

  - id: fix-authorization-present
    condition: "authorization_received == true"
    on_fail: HALT
    critical_violation: true
    source: "systematic-debugging/SKILL.md §Operating Protocol point 4"

  - id: no-scope-creep
    condition: "fix_includes_unrelated_changes == false"
    on_fail: HALT
    critical_violation: true
    source: "systematic-debugging/SKILL.md §Enforcement Matrix"

evidence_artifacts:
  - name: hypothesis_verification
    type: tool_call
    verification: "srclight_get_symbol/srclight_get_callees/bash command confirming hypothesis matches live code behavior"
    source: "systematic-debugging/SKILL.md §Live Verification"

  - name: root_cause_identified
    type: constructed_url
    verification: "Bug report issue body contains 'Root Cause' section with identified cause"
    source: "systematic-debugging/SKILL.md §Bug Discovery Guardrail"

  - name: fix_minimal_verification
    type: tool_call
    verification: "srclight_get_dependents → check blast radius; uv run pytest → confirm pass"
    source: "systematic-debugging/SKILL.md §Live Verification"

  - name: bug_report_issue
    type: api_call
    verification: "github_issue_read(method=get, issue_number=N) → confirm bug report exists"
    source: "systematic-debugging/SKILL.md §Bug Discovery Guardrail"
```