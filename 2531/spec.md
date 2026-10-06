# Restore Stacked-PR Mandate — Spec

## Problem Statement

The pre-rip deck (tag `pre-rip`, preserved under `attic/`) carried
`[critical-rules-PR-ORG]` — "Stacked PR Is the Only Valid Organization":

> All issues within an authorization scope share one feature branch with one
> commit per issue. The only valid PR strategy is `stacked` — one branch, N
> commits, one PR. The `individual` strategy (N branches, N PRs) does not
> exist. Creating N branches for N issues under any authorization scope is a
> critical violation.

The post-rewrite deck lost that invariant's bright line. The current
`git-workflow-branch` card reads as one-branch-per-issue
(`feature/<issue>-<slug>`, no multi-issue scope rule), and `git-workflow-pr`
defines the stacked-PR shape only for stacked *layer chains* — never binding
issues authorized together into one branch and one PR.

**Observed regression 2026-10-06:** issues `.opencode#2527` and `.opencode#2528`
were authorized in one utterance ("approved for PR: .opencode#2527
.opencode#2528") and the agent produced two branches and two PRs
(`.opencode#2529`, `.opencode#2530`). `.opencode#2530` was closed as redundant
and its commit stacked into `.opencode#2529` by hand. The old deck's rule
existed precisely to prevent this.

## Scope

### In Scope

- Add the single-PR-with-squashed-commits-per-issue mandate to **only** the
  cards that need it at their dispatch surfaces, preserving progressive
  disclosure:
  - `git-workflow-branch` — issues sharing an authorization scope share **one
    feature branch**; branch naming follows from the scope's primary issue.
  - `git-workflow-pr` — that branch becomes **one PR** containing **one
    squashed commit per issue ticket**; the body closes every stacked issue;
    the mandate is declared universal — it applies to **all PRs, including
    release PRs**. N branches / N PRs for one authorization scope is named as
    the violation.
- Skill-creator governance admission for both card edits.

### Out of Scope

- `floor.md`, `routing.md`, `work` card, and every other card — no mandate
  duplication (progressive disclosure: the mandate lives at the two boundary
  surfaces that consume it).
- Release-trio cards (`changelog-generator`, `version-manager`,
  `release-promoter`): release PRs already flow through the `git-workflow-pr`
  surface, which declares the mandate universal — no duplication needed.
- Harness/tests changes; any change to the tool chain.

## Success Criteria

- [ ] **SC-1 (structural):** `git-workflow-branch` card states that issues
  sharing an authorization scope share one feature branch, with the
  branch-naming implication. Verification: card inspection.
- [ ] **SC-2 (structural):** `git-workflow-pr` card binds the stacked-PR shape
  to the authorization scope — one branch, one squashed commit per issue, one
  PR; declares the mandate universal (all PRs including release PRs); names
  N-branches/N-PRs as the violation. Verification: card inspection.
- [ ] **SC-3 (structural):** No other agent-facing surface gained the mandate;
  both edits carry a skill-creator governance record; reference-integrity
  check passes. Verification: sweep + governance record + executed
  reference-integrity output.

## References

- `attic/skills/git-workflow-pr/SKILL.md` and
  `attic/guidelines/000-critical-rules.md` `[critical-rules-PR-ORG]` — the
  pre-rip authority for this invariant
- Regression record: `.opencode#2529` / `.opencode#2530` (2026-10-06)

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
