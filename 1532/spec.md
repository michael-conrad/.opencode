## Defects

- D2 FAIL — description "verification" doesn't enumerate TDT's verify/collect/structural-verify/completion tasks explicitly
- D3 INCOMPLETE — omits evidence collection and structural verification detail

## Current → Proposed

**Current:** "Use when claiming a task is complete, marking a step done, or closing an issue. Verification is REQUIRED and not optional — MUST use before any completion claim."

**Proposed:** "Use when collecting evidence artifacts, verifying claims against live sources, performing structural verification checks, and completing the verification-before-completion workflow — always verify before any completion claim."

## Required Action

Update `.opencode/skills/verification-before-completion/SKILL.md` frontmatter `description` field with proposed text.

## Interdependency Map

### Backward Dependencies (issues that #1532 depends on)

| Issue | Relationship | Dependency Type | Action Required |
|-------|-------------|-----------------|-----------------|
| #1789 | Adds behavioral-test-evaluation dispatch step to verify.md and updates SKILL.md Operating Protocol §7 | **FILE-OVERLAP** — #1532 modifies SKILL.md frontmatter description; #1789 modifies SKILL.md Operating Protocol §7. Different sections of the same file. | Any order, but coordinate to avoid merge conflicts in SKILL.md. |

### Forward Dependencies (issues that depend on #1532)

None identified.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)