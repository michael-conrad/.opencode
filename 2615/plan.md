<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan — .opencode#2615 PR body contract

Branch: `feature/2615-pr-body-contract` (base tip `2f55bc61`, `.opencode` trunk).
Spec: `spec.md` (this store). All SCs structural — full-card reads are the instruments.

## Empirical steps (spec §4, feed SC-2) — executed 2026-10-14 session

1. **GitBucket closing-keyword behavior:** disposable container (image
   `gitbucket/gitbucket:latest`), disposable repo/issue/PR — PR body carried
   `Closes #1`; merge via API returned 200; issue stayed `state: open`.
   **Outcome: GitBucket has no closing-keyword auto-close → cleanup class.**
2. **GitHub cross-repo form:** disposable issue
   `test-submodule-1#3`, disposable PR `test-submodule-2#1` with body
   `Closes michael-conrad/test-submodule-1#3`; PR merged 03:27:51Z, issue
   `closedAt` 03:27:52Z. **Outcome: cross-repo form confirmed in the
   keyword-closure class.** (Same-repo form: pre-recorded in spec §4.)

## Implementation items (one squashed commit at PR)

1. `skills/git-workflow-pr/SKILL.md` — replace §4 with the body contract:
   closing-keyword mechanics + prohibitions (SC-1), platform closure classes
   from the empirical outcomes (SC-2), fixed section set (SC-4),
   summary-sourcing rule (SC-5), evidence rule (SC-6), anti-bloat rule
   (SC-7), ~30-line size guard with release exemption (SC-8), bump-section
   content requirement (SC-9). Provenance: frontmatter + SPDX line cite
   #2615.
2. `skills/git-workflow-cleanup/SKILL.md` — item 3 redefined as
   verify-and-sync closure (SC-3); frontmatter description's "sole authorized
   closure path" amended to match. Provenance #2615 ×2.
3. `skills/release-promoter/SKILL.md` — release PR body composition:
   changelog + Submodule-bump section, `Closes` lines only when a release
   issue exists (SC-10); GitHub Release body stays changelog-only (SC-11).
   Provenance #2615 ×2.
4. `skills/changelog-generator/SKILL.md` — one-line alignment note (SC-12).
   Provenance #2615 ×2.

## Verification

- SC-1…SC-14: full-card reads + root-agnostic grep (SC-13) + #2615 grep
  (SC-14, 4 cards × 2 locations).
- Full test suite green this session with captured output.
- Fresh-context `verify` PASS against the spec.
- Then squash-commit, push, `gh pr create` on `.opencode`, HALT.
