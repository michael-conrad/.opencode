# [SPEC-FIX] Why-Question Prohibition — prevent question-as-authorization pattern

## Root Cause

Agent interprets "why" questions as implicit authorization to make changes. When the user asked "why are there two map tables in the ini file?", the agent immediately deleted files and edited config.ini instead of answering the question. This is a question-as-authorization violation.

## Violated Rules

| Rule | Violation |
|------|-----------|
| critical-rules-006 | Question-as-Authorization — rhetorical/complaint question treated as implementation authorization |
| approval-gate-002 | Explicit authorization required — no "approved" or "go" was given |
| 020-go-prohibitions.md §1 | "Questions are NOT authorization" — existing rule was not followed |
| critical-rules-011 | Bug discovery ≠ bug fixing authorization |

## Preconditions

- The insertion point in `020-go-prohibitions.md` §1 is after the "Rhetorical and complaint questions are NOT authorization" paragraph (line 40) and before the "SILENTLY HALT after every task/report" paragraph (line 41). The "Rhetorical and complaint questions" paragraph exists in the current file and is verified by reading the file.
- The behavioral test file `.opencode/tests/behaviors/why-question-prohibition.sh` does not yet exist and will be created as a new file.

## Fix

### 1. Add Why-Question Prohibition to `020-go-prohibitions.md` §1

Insert after the "Rhetorical and complaint questions are NOT authorization" paragraph (line 40) and before the "SILENTLY HALT after every task/report" paragraph (line 41):

> **🚫 "Why" questions are observation-only, never authorization.** A user asking "why is X structured this way?", "why does Y exist?", or any question beginning with "why" is seeking explanation, not requesting changes. The agent MUST answer the question factually. Any file modification, deletion, or edit triggered by a "why" question is a CRITICAL VIOLATION. The agent MUST NOT:
> - Delete or modify files mentioned in a "why" question
> - Propose changes in response to a "why" question
> - Treat "why" as an implicit "fix this"
>
> **Correct response to "why" questions:** Answer the question. If the user wants changes, they will explicitly say so.

### 2. Behavioral enforcement test

Add `.opencode/tests/behaviors/why-question-prohibition.sh` that sends a "why" question about a config file and asserts the agent makes zero file-modifying tool calls (no edit, write, delete, or bash rm).

## Scope Boundaries

This fix is scoped to "why" questions only. The following question formulations are explicitly NOT covered by this fix and remain governed by the existing "Questions are NOT authorization" rule in `020-go-prohibitions.md` §1:

- **"How" questions** — e.g., "how does X work?" — covered by existing rule
- **"What" questions** — e.g., "what does Y do?" — covered by existing rule
- **"What about" / "What if" questions** — e.g., "what about Z?" — covered by existing rule
- **"Can you" / "Could you" questions** — e.g., "can you explain X?" — covered by existing rule

The "why" question pattern is uniquely dangerous because it combines an explanation-seeking question with an implied causal judgment ("why is X wrong/bad/suboptimal?"), which the agent has historically interpreted as authorization to fix. Other question formulations do not carry this implied causal judgment and are adequately governed by the existing rule.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | 020-go-prohibitions.md contains Why-Question Prohibition block | `string` | grep for "Why-Question Prohibition" in file |
| SC-2 | Behavioral test exists at `.opencode/tests/behaviors/why-question-prohibition.sh` | `structural` | File exists |
| SC-3 | Behavioral test passes: agent answers "why" question without file modifications | `behavioral` | `opencode-cli run` with stderr assertion for zero edit/write/delete/rm calls |

## Documentation Sources

| Source | Type | Verified |
|--------|------|----------|
| `.opencode/guidelines/020-go-prohibitions.md` §1 | Guideline file | Verified by reading file — "Rhetorical and complaint questions are NOT authorization" at line 40 |
| `.opencode/guidelines/000-critical-rules.md` §critical-rules-006 | Guideline file | Verified by reading file — Question-as-Authorization rule exists |
| `.opencode/guidelines/010-approval-gate.md` §approval-gate-002 | Guideline file | Verified by reading file — Explicit authorization required rule exists |
| `.opencode/guidelines/000-critical-rules.md` §critical-rules-011 | Guideline file | Verified by reading file — Bug discovery ≠ bug fixing authorization rule exists |

## Enforcement Gate

**All-or-nothing gate:** ALL success criteria MUST pass for this fix to be considered complete. If any SC fails, the implementation MUST be rolled back and the root cause remediated before re-attempting. PASS requires: (1) SC-1 string match confirmed, (2) SC-2 file existence confirmed, (3) SC-3 behavioral test passes with zero file-modifying tool calls. Any FAIL requires full remediation and re-verification before proceeding.

## Depends on

None

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
