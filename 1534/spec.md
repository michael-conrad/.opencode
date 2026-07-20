## Defects

- D2 FAIL — description "verifying claims against evidence" doesn't enumerate TDT's verify/completion tasks explicitly
- D3 INCOMPLETE — omits evidence collection and structural verification detail

## Current → Proposed

**Current:** "Use when verifying claims against evidence using appropriate modalities. Produces PASS/FAIL/UNVERIFIED per claim with evidence artifacts. Verification is REQUIRED."

**Proposed:** "Use when collecting evidence via live tool calls, verifying claims against artifacts, performing structural verification checks, and completing a verification workflow — always produce PASS/FAIL/UNVERIFIED verdicts with evidence artifacts for each claim."

## Required Action

Update `.opencode/skills/verification/SKILL.md` frontmatter `description` field with proposed text.