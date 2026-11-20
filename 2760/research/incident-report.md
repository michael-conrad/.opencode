# Incident record — .opencode#2760 conversion input

Verbatim copy of the remote tracker body for
https://github.com/michael-conrad/.opencode/issues/2760
at conversion time, 2026-11-20 (title:
"git-workflow-pr: agent files multiple per-layer PRs for one stacked-PR authorization instead of the single trunk PR",
state: OPEN, labels: none).

---

## Summary

Under a single `approved for stacked PR` terminal-stage authorization, the agent filed multiple separate pull requests instead of the one single stacked PR the `git-workflow-pr` card defines — and applied the GitHub-native per-layer stacking shape (each PR's base is the previous layer's branch) that the card's rule 3 explicitly names as the shape to never use. Observed in the consuming repo NewsRx/hermes on 2026-11-20 (session's own PRs #458/#459; same shape from a prior session as PR #455). Developer flagged it as a regression.

## Environment

- opencode version: 2.3.2
- OS: Linux 6.8.0-147-generic (linux x64)
- Terminal: TERM=dumb
- Shell: /bin/bash
- Install/channel: latest
- Active plugins: ./plugins/vacuum-retention.ts
- Deck: michael-conrad/.opencode @ `489c21ef` (main), consumed read-only by NewsRx/hermes
- Consuming repo state: stacked branch chain `feature/449-450-env-discipline-db-tests` (open PR #452, base `dev`) ← `feature/456-db-credential-model-docs` (no PR) ← `feature/457-trunk-based-model`

## Reproduction

1. A consuming session holds a stacked branch chain: issue A's branch carries an open trunk PR; issue B's branch is cut from A's branch; issue C's branch is cut from B's branch.
2. The spec for issue C also mandates a second PR-shaped deliverable (a dev→main topology promotion, R-8/SC-9 of hermes#457).
3. The developer issues the terminal-stage token: `#457 approved for stacked PR`.
4. The agent implements C, squashes per-issue, and files: PR #458 with `head=feature/457-trunk-based-model, base=feature/456-db-credential-model-docs` (per-layer shape; body `Closes #457`), plus PR #459 with `head=dev, base=main` (the promotion) — two PRs for the one authorization scope — while issue B's layer has no PR at all and the session ends asking whether to open it as a third.
5. Prior-session evidence the shape recurs: open PR #455 (`pair-452-guard-lock-followup` → base `feature/449-450-env-discipline-db-tests`) — the same per-layer shape, filed earlier by another agent session.

## Expected Behavior

Per `skills/git-workflow-pr/SKILL.md` rule 3: "A stacked PR is **one PR against the trunk containing one squashed commit per issue ticket** — the body closes every stacked issue. Squash WIP to one commit per issue at PR creation; a stacked branch chain rides in that one PR, **never as one PR per stacked layer**." and "Issues authorized together share that one branch and that one PR — N branches / N PRs for one authorization scope is the violation." The token names one authorization scope (issue #457 through the PR boundary), so the expected output is one PR: head = the stacked chain, base = the trunk, one squashed commit per issue in the scope, body closing every stacked issue.

## Actual Behavior

- PR #458: base is the middle layer's *branch* (`feature/456-db-credential-model-docs`), i.e. one PR per stacked layer — the exact shape rule 3 prohibits ("never as one PR per stacked layer").
- PR #459: a second PR filed within the same authorization scope (the spec-mandated promotion).
- The middle layer (issue #456) ends with no PR, and the session's completion report asks the developer for a third PR authorization — three PR surfaces in play for one scope.
- The behavior is consistent across two independent sessions (PR #455 earlier; PR #458/#459 now), and the repo's open-PR listing now carries both per-layer PRs side by side, so the violating shape sits in plain view as if sanctioned.

## Additional Context

Contributing factors, from the session's own record:

1. **Term collision.** "Stacked PR" is the established name in the wider ecosystem for the per-layer pattern (one PR per layer, base = parent branch). The developer's token "approved for stacked PR" reads as authorizing that pattern to any agent with those priors, while the card defines the term oppositely (one trunk PR carrying the chain). The card states its definition once; nothing at decision time contrasts the two readings or points back at rule 3 when the token arrives.
2. **Repo precedent reinforces the misreading.** A prior session already filed the per-layer shape (PR #455), and it stands unmerged and uncriticized — the violating pattern exists in the consuming repo as if it were the house style. Nothing in the card directs the agent to treat existing per-layer PRs as violations rather than precedent.
3. **No mechanical gate.** The pre-create checklist (rule 2) verifies commits, tests, and verify PASS, but no create-time check enforces "one authorization scope → one PR". The violation was only visible in retrospect, to the developer.
4. **Open question for the card.** Rule 3 says one PR per authorization scope; hermes#457's *approved spec itself* mandates a second PR-shaped artifact (the R-8 dev→main promotion, merged by a human, strictly sequenced before branch retirement). Whether a spec-mandated promotion PR counts inside the same authorization scope (violation) or as a separate spec deliverable (not a stacked-PR layer at all) is not addressed anywhere in the card — the agent resolved it by filing it and flagging the sequencing, but the correct disposition is undefined deck-side.
5. Workarounds: none tried; the developer identified the regression on review.

Suggested deck-side remedies (for triage): a definition-of-stacked-PR pointer in the card's rule 1 or in the authorization-vocabulary entry for `approved for pr`-class tokens; a create-time self-check listing prior open PRs of the same scope before `gh pr create`; an explicit disposition rule for spec-mandated companion PRs (promotion/release shapes); and a precedent note that existing per-layer PRs in consuming repos are violations to remediate, not house style to imitate.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3)
