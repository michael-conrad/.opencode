# [SPEC-FIX] Fix H: Remaining skill description narrative cleanup (D5)

## Parent

https://github.com/michael-conrad/.opencode/issues/1384 — Audit: Skill Card "Use When" Description Compliance

## Problem

21 SKILL.md descriptions contain narrative-only sentences (slogans, value judgments, metaphors, benefit statements) that add zero dispatch information. These violate D5 and must be removed or replaced with dispatch-relevant content.

## Skills Affected

| # | Skill | Narrative Sentence(s) | Pattern |
|---|-------|----------------------|---------|
| 1 | `adversarial-audit` | "Every unverified deliverable is a defect." | Slogan/aphorism |
| 2 | `correspondence` | "always required for professional credibility" | Professionalism framing |
| 3 | `executing-plans` | "Every skipped step is a defect waiting for CI to find." | Slogan/aphorism |
| 4 | `git-workflow` | "Branch-and-PR discipline is REQUIRED for maintainable projects — always follow the workflow." | Professionalism framing |
| 5 | `issue-operations` | "untracked work is lost work" | Slogan/aphorism |
| 6 | `issue-review` | "every unread comment is a defect risk" | Defect risk framing |
| 7 | `multimodal-dispatch` | "for professional systems" | Professionalism framing |
| 8 | `plan` | "every unplanned phase is a risk" | Slogan/aphorism |
| 9 | `programming-principles` | "every violated principle is technical debt incurred, not saved" | Slogan/aphorism |
| 10 | `receiving-code-review` | "every unresolved comment is a regression waiting to surface" | Defect risk framing |
| 11 | `research` | "every unverified finding is a liability, not evidence" | Slogan/aphorism |
| 12 | `researcher` | "every unverified finding is a liability, not evidence" | Slogan/aphorism |
| 13 | `skill-creator` | "Every unvalidated skill is a gap in your quality system" | Quality system metaphor |
| 14 | `solve` | "every unverified constraint is a defect" | Slogan/aphorism |
| 15 | `spec-creation` | "professional engineers spec first" | Professionalism framing |
| 16 | `sre-runbook` | "produces procedures that survive the next on-call" | Benefit statement |
| 17 | `sync-guidelines` | "not overhead" | Value judgment |
| 18 | `systematic-debugging` | "it finds root causes" | Benefit statement |
| 19 | `test-driven-development` | "produces testable, correct code" | Benefit statement |
| 20 | `using-git-worktrees` | "for professional isolation" | Professionalism framing |
| 21 | `verification` | "turns guesses into facts" | Benefit statement |
| 22 | `verification-before-completion` | "A completion claim without verification is not a completion — it is a placeholder for undiscovered defects." | Slogan/aphorism |
| 23 | `verification-enforcement` | "Every unverified claim in generated content is a trust deficit." | Slogan/aphorism |
| 24 | `writing-plans` | "agents who skip them get lost" | Metaphor |

## Requirements

For each of the 24 skills (21 unique + 3 with multiple sentences), remove or replace the narrative-only sentence(s) from the `description` field in the YAML frontmatter. The description must:

1. Retain all dispatch conditions (the "Use when" content)
2. Retain mandatory language (MUST, REQUIRED, MANDATORY, not optional)
3. Remove narrative-only sentences that add zero dispatch information
4. Not introduce new narrative-only content

## Proposed Descriptions

| Skill | Proposed Description |
|-------|---------------------|
| `adversarial-audit` | Use when running adversarial audits of specs, plans, or code. Dispatch to spec-audit, plan-fidelity, concern-separation, coherence-extraction, coherence-maintenance, guideline-audit, drift-detection, spec-summary, closure-verification, test-quality-audit, verification-audit, resolve-models, cross-validate, or completion. Audits are not optional — dispatch is MANDATORY. |
| `correspondence` | Use when drafting stakeholder emails, status updates, or external communications. Audience separation MUST be maintained — always required. |
| `executing-plans` | Use when executing an approved plan step-by-step or moving through implementation gates sequentially. Every step in the plan MUST be executed — skipping, combining, or reordering steps is not optional. |
| `git-workflow` | Use when creating a branch, committing, pushing, or creating a PR, rebase/merge conflicts (invoke conflict-resolution), "check pr"/"check prs"/"check merged prs"/"pr merged" (PR state verification + cleanup), "release PR"/"promote to main"/"dev to main" (release-promotion). Branch-and-PR discipline is REQUIRED — always follow the workflow. |
| `issue-operations` | Use when creating, commenting on, or closing GitHub Issues. Routes to GitHub MCP or GitBucket API based on github.platform. Issue tracking is REQUIRED. |
| `issue-review` | Use when reviewing a GitHub issue for comments, audits, or Q/A. All comments MUST be read before acting on any issue. |
| `multimodal-dispatch` | Use when routing AI agent tasks to appropriate models based on content modality, probing Ollama model capabilities, or dispatching sub-agents with modality-aware model selection. Modality-aware dispatch is REQUIRED — always use the correct model for each modality. |
| `plan` | Use when generating, validating, or managing plans for phase solvability, converting between YAML and PDDL, grounding action schemas, discovering action schemas, or managing state files. Planning is REQUIRED before implementation. |
| `programming-principles` | Use when designing functions, classes, or modules; writing or reviewing implementation code; making architecture decisions; evaluating tradeoffs, or enforcing code size limits. Programming principles MUST be followed. |
| `receiving-code-review` | Use when receiving code review feedback on a PR, or when addressing review comments. All review comments MUST be addressed. |
| `research` | Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. All findings MUST be verified against live sources. |
| `researcher` | Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. All findings MUST be verified against live sources. |
| `skill-creator` | Use when creating a new skill, updating an existing skill, validating skill cards, or managing duplicate content blocks (fragments) across guidelines or skills. Validation is REQUIRED. |
| `solve` | Use when validating workflow constraints, verifying state against contracts, proving theorems, or checking dependency ordering. Workflow constraints MUST be validated with Z3. |
| `spec-creation` | Use when creating a spec or writing a specification. Spec creation is REQUIRED before implementation. |
| `sre-runbook` | Use when generating operational runbooks for infrastructure incidents or procedures. SRE discipline is REQUIRED. |
| `sync-guidelines` | Use when synchronizing guidelines, skills, or tools between repositories. Sync is REQUIRED maintenance. |
| `systematic-debugging` | Use when encountering a bug, error, or unexpected behavior, or before making code changes to fix an issue. Systematic debugging is REQUIRED. |
| `test-driven-development` | Use when writing tests before implementation, or when adopting a test-first development approach. TDD is REQUIRED. |
| `using-git-worktrees` | Use when creating a feature branch or worktree for implementation. Always invoke before git-workflow pre-work. Worktrees are REQUIRED — always use them. |
| `verification` | Use when verifying claims against evidence using appropriate modalities. Produces PASS/FAIL/UNVERIFIED per claim with evidence artifacts. Verification is REQUIRED. |
| `verification-before-completion` | Use when claiming a task is complete, marking a step done, or closing an issue. Verification is REQUIRED and not optional — MUST use before any completion claim. |
| `verification-enforcement` | Use when generating content that makes factual claims — specs, plans, runbooks, docs, or correspondence. Live-source verification before generation is REQUIRED — always mandatory, never optional. |
| `writing-plans` | Use when creating an implementation plan from an approved spec. Plans are REQUIRED. |

## Files

All `.opencode/skills/*/SKILL.md` files listed above — `description` field in YAML frontmatter.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | All 24 skills have narrative-only sentences removed from description | `string` |
| SC-2 | All descriptions retain mandatory language (MUST, REQUIRED, MANDATORY, not optional) | `string` |
| SC-3 | All descriptions retain all dispatch conditions | `string` |
| SC-4 | No new narrative-only content introduced | `string` |
| SC-5 | All descriptions start with "Use when" | `string` |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
