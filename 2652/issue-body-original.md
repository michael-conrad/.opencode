## Defect

Release PR filing mis-applied the squash mandate with a false blocking reason,
shipping a review surface the deck itself forbids.

Observed 2026-10-21-14:00EDT, session on NewSRX-Tech-LLC/ClinicaltrialAlertsSender:
- while filing release PR [ClinicaltrialAlertsSender#5](https://gitbucket.newsrx.com/gitbucket/NewSRX-Tech-LLC/ClinicaltrialAlertsSender/pull/5), the agent held the branch at 6 atomic commits instead of executing the mandated per-issue squash (2 commits) and disclosed the deviation as a blocked decision:

> "Not per-issue-squashed at PR creation — branch-history rewrite (force-push) awaits explicit developer go."

## The false blocking reason

The floor's destructive-action provision ("force/history-changing git operations — only when the prompt explicitly names the action and its target") was cited to justify NOT squashing. That provision is written for **dispatch scope** (a dispatched sub-agent's authorization is exactly its dispatch prompt) and for uninvited history surgery. Squashing the feature branch to one commit per issue at PR creation is **the deck's own mandated procedure** (git-workflow-pr §3: "Squash WIP to one commit per issue at PR creation"; §5: pointer-only commits forbidden at the review surface — the pointer capture "rides with real changes in the squashed per-issue commit"). The developer's directive ("create a release PR") invokes that procedure; its standard mechanical step does not need a second, prompt-level authorization for the rewrite of a branch the agent created earlier in the same flow.

Result: the agent shipped the review surface violating §5's pointer-only prohibition (a standalone pointer-capture commit visible to review), invented a merge-mechanics alternative ("squash-merge at the human gate") to paper the shape deviation, and stalled a clear next step.

## Expected

Filing the authorized release PR executes the mandated procedure end-to-end: soft-reset squash to one commit per issue (capture + 4 build commits → one commit for #3; 1 commit → #4), `push --force-with-lease` on the agent's own just-created feature branch, then `gb pr create`. The destructive-action gate should not re-arm for standard procedure steps the directive already named the pipeline for.

## Remedy direction (deck reconciliation)

Either (a) floor carve-out: deck-mandated procedure steps invoked by the directive carry their own authorization — the destructive gate governs actions outside any invoked card's named procedure; or (b) PR card text spells out that squash-at-creation includes the branch rewrite and force-with-lease, so the gate and the card no longer collide. Suggested provenance anchors: git-workflow-pr §3/§5 (squash mandate, ride-along invariant), floor.md "Dispatched sub-agent scope" (the provision actually written for agents receiving prompts, not for the runner's own pipeline stage).

*Co-authored with AI: OpenCode (zai-org/GLM-5.3-Flash)*