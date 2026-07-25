---
remote_issue: 2138
remote_url: https://github.com/michael-conrad/.opencode/issues/2138
labels: [spec]
---

## Problem

Agents repeatedly use line counts, word counts, or file size as a measurement of success in specs. These are size metrics — they measure how much text exists, not whether the content is correct, focused, or semantically complete.

The defective pattern is: a spec success criterion that declares a target line count or word count as evidence of correctness. Examples from closed issues:

```
| SC-N | Final file size < 200 lines | structural | wc -l |
```

This is a proxy measurement. A 199-line file that lost critical rules is worse than a 250-line file with all rules intact. The compaction's success should be measured by content correctness and structural integrity — not by byte count.

### What IS legitimate

- **Problem statement context**: "This file is ~420 lines / ~43KB" as a factual description of scope — this is information, not a success criterion.
- **User-mandated targets**: If the user explicitly says "keep this under 200 lines" as a requirement, that is a legitimate SC.
- **Complexity analysis**: "This function has high cyclomatic complexity" — word count as a signal, not a target.

### What is NOT legitimate

- `Final file size < N lines | structural | wc -l` as a success criterion
- Any SC where the verification method is `wc -l` and the criterion is about size rather than content
- Using line count as a proxy for "compacted" or "focused" — compaction is about removing duplication and dead content, not hitting a byte target

## Scope

Audit the entire `.opencode/` directory for this defective pattern:

1. **Success criteria tables** — any SC where the criterion is a line count, word count, or file size target
2. **Verification methods** — any SC where the verification method is `wc -l` or equivalent size measurement
3. **Evidence type misuse** — any SC where `structural` evidence type is used with `wc -l` to verify a behavioral/semantic claim (e.g., "file is compacted" verified by line count)
4. **Spec bodies** — any non-SC text that uses line count as a proxy for correctness (e.g., "Phase 5: Verify file is < 200 lines")

**Out of scope:**
- Factual descriptions of file size in problem statements ("~420 lines / ~43KB")
- User-mandated size targets (explicit user requirement)
- Informational line counts in changelogs, release notes, or commit messages
- The `lessons-learned/` directory

## Approach

A research sub-agent will:

1. Search all `.md` and `.yaml` files in `.opencode/` for patterns matching line-count/word-count SCs
2. For each match, classify as:
   - **DEFECT**: Size metric used as success criterion or verification method
   - **LEGITIMATE**: Factual description, user mandate, or informational
3. Report findings with file path, line number, matched text, and classification
4. For DEFECT findings, also check whether the issue is open or closed (closed issues are flagged for audit, not rework)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Spec defines the defective pattern with examples of what IS and IS NOT legitimate | string | grep for 'What IS legitimate' and 'What is NOT legitimate' |
| SC-2 | Spec scopes the audit to `.opencode/` with explicit out-of-scope categories | string | grep for 'Out of scope' section |
| SC-3 | Spec defines a classification system (DEFECT vs LEGITIMATE) for findings | string | grep for 'DEFECT' and 'LEGITIMATE' classification |
| SC-4 | Spec requires per-finding reporting with file path, line number, matched text, and classification | string | grep for 'file path' and 'line number' in approach |
| SC-5 | Spec distinguishes open vs closed issues in findings | string | grep for 'open or closed' in approach |
| SC-6 | Spec does NOT contain any line-count or word-count success criterion itself | string | Extract SC table rows; verify no row uses size measurement as criterion or verification method |

## Implementation Plan

### Phase 1: Write spec with clear pattern definition and classification system
### Phase 2: Dispatch research sub-agent to audit `.opencode/`
### Phase 3: Compile findings report with per-finding classification
### Phase 4: For each DEFECT finding in an OPEN issue, create a remediation sub-issue
### Phase 5: For each DEFECT finding in a CLOSED issue, flag for audit

## Files Affected

- `.opencode/.issues/2138/spec.md` — this spec
- `.opencode/.issues/2138/research/` — audit findings
- `.opencode/.issues/2138/audit/` — audit verdicts

## Risks

- **False positives**: Line counts in problem statements or user mandates could be flagged. Mitigation: classification system distinguishes DEFECT from LEGITIMATE.
- **Scope creep into content reformatting**: Strictly limit to identifying the pattern — remediation is a separate spec per finding.

## Dependencies

- None. Standalone audit spec.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
