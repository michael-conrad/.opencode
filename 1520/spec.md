## Defects

- D2 FAIL — TDT has 12 specific operations but description doesn't enumerate them explicitly
- D3 INCOMPLETE — covers many operations but lacks mandatory dispatch language clarity

## Current → Proposed

**Current:** "Use when browsing the web, automating browser interactions, navigating pages, filling forms, capturing snapshots, evaluating JavaScript, mocking network requests, managing storage/cookies/tabs, recording traces or video, running or generating Playwright tests, managing browser sessions, or installing/setting up Playwright. REQUIRED: dispatch via skill() before any browser automation — do not skip this skill."

**Proposed:** Same as current (already covers all 12 operations) + ensure mandatory dispatch language is preserved and emphasized.

## Required Action

Verify `.opencode/skills/playwright-cli/SKILL.md` frontmatter `description` retains full operation enumeration and mandatory dispatch language — confirm no drift from proposed text.