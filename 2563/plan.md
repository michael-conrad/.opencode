<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated plan from approved spec .opencode/.issues/2563/spec.md -->

# Plan — Submodule discipline rule set for deck skill cards

Source spec: `.issues/2563/spec.md` (validated). One item per SC, in spec phase
order. Each item's RED is the spec's verified absent-state assertion; GREEN is
the spec's authored change; verification instruments are structural reads or
the tests-v2 behavioral harness as the spec assigns.

## Phase 1 — Parent-side card edits

### Item 1 (SC-1): Trunk-tip freshness in `git-workflow-branch`
- Deliverable: card text stating the three-element rule — (a) parent trunk
  pulled to remote tip before any work; (b) submodule pointers synced to each
  submodule's remote trunk tip (tracked-branch tip per `.gitmodules`, fetched
  from remote, not the recorded pointer); (c) no branch/no commit when the
  parent has nothing to contribute beyond pointer bumps.
- RED: structural read shows card lacks the unified rule and elements (b), (c),
  and the pre-any-work scope of (a).
- GREEN: author the rule into the card's trunk-freshness/submodules steps.
- verify: structural inspection finds all three elements.
- commit: card edit.

### Item 2 (SC-2): Real-work sequence in `git-workflow-branch`
- Deliverable: ordered sync → feature-branch creation → immediate pointer-only
  capture commit (sanctioned at branch level) → work; amend item 3's blanket
  pointer-only prohibition to the branch-level/review-surface distinction.
- RED: structural read shows no ordered sequence and an unconditional
  pointer-only prohibition that contradicts the sanction.
- GREEN: author the sequence and sanction; amend item 3.
- verify: structural inspection finds the ordered steps and sanction, and no
  contradicting text.
- commit: card edit.

### Item 3 (SC-3): PR-surface clauses in `git-workflow-pr`
- Deliverable: three clauses in the pre-create checklist area — (a) parent PR
  includes pending pointer bumps (bump = checked-out HEAD differs from recorded
  gitlink); (b) pointer-only parent PRs forbidden; (c) release-PR exemption.
- RED: structural read shows none of the three in the checklist area.
- GREEN: add the three clauses.
- verify: structural inspection finds all three.
- commit: card edit.

### Item 4 (SC-4): Commit-card amendment (`git-workflow-commit` #5)
- Deliverable: #5 draws the branch-level vs review-surface line; ride-along
  invariant preserved for the squashed review surface; release-PR exception
  carried.
- RED: structural read shows #5 calls pointer-only commits a defect without the
  distinction.
- GREEN: amend #5.
- verify: structural inspection finds all three properties.
- commit: card edit.

### Item 5 (SC-5): Ordering gate in `git-workflow-pr`
- Deliverable: blocking clause (parent PR creation blocked while any submodule
  PR is pending) plus post-merge re-sync/re-verify requirement (parent PR
  carries the merged submodule trunk tip; verification re-run against the
  composed state before creation).
- RED: structural read shows no submodule-PR-blocking language.
- GREEN: add both.
- verify: structural inspection finds both.
- commit: card edit.

## Phase 2 — Execution boundary and recursion ban

### Item 6 (SC-6): Execution boundary in the implementation-workflow reference
- Deliverable: `.opencode/skills/implement/references/implementation-workflow.md`
  states: in a parent repo with submodules, build/test/verification runs
  through the parent repo's own framework; the agent does not execute a
  submodule's own build tooling directly.
- RED: structural read shows no boundary statement.
- GREEN: add the boundary statement.
- verify: structural inspection.
- commit: reference edit.

### Item 7 (SC-7): `ci-boundary` pointer
- Deliverable: cross-reference line in `ci-boundary` pointing at the
  implementation-workflow reference path (pointer, not restatement).
- RED: structural read shows no cross-reference.
- GREEN: add the pointer line.
- verify: structural inspection finds the cross-reference.
- commit: card edit.

### Item 8 (SC-8): Non-recursive mandate in `ci-boundary`
- Deliverable: mandate enumerating all three forbidden forms: CI checkout with
  `submodules: recursive`; `git clone --recursive`;
  `git submodule update --init --recursive`.
- RED: structural read shows no stance on recursion.
- GREEN: add the mandate.
- verify: structural inspection finds the mandate and the three forms.
- commit: card edit.

## Phase 3 — Remediation and hygiene

### Item 9 (SC-9): Deinit remediation in `git-workflow-branch`
- Deliverable: remediation containing verbatim
  `git submodule foreach git submodule deinit --all --force` (parent repo
  root), the carve-out purpose, the `--force` destruction caveat, and no
  restore path.
- RED: structural read shows no false-modified-status deinit remediation in any
  card.
- GREEN: author the remediation.
- verify: string-match the incantation; inspect purpose, caveat, absence of a
  restore path.
- commit: card edit.

### Item 10 (SC-10): Ticket-state hygiene in `issues`
- Deliverable: rule that a stale ticket state (local mirror diverging from
  remote tracker) is corrected on discovery; remote tracker anchors reality for
  out-of-band changes; the local-authoritative closure ruling (.opencode#2561)
  governs the closure workflow it drives.
- RED: structural read shows sync mechanics but no divergence-correction rule.
- GREEN: author the rule with the closure-ruling boundary.
- verify: structural inspection.
- commit: card edit.

### Item 11 (SC-11): #2306 stale-open correction
- Deliverable: local store mirror of .opencode#2306 matches the remote tracker
  (closed).
- RED: `local-issues read` says open; `gh issue view 2306 -R
  michael-conrad/.opencode --json state` says closed.
- GREEN: correct the local mirror via `local-issues`.
- verify: state comparison matches.
- commit: store mutation (auto-committed by the tool).

## Phase 4 — Governance record and behavioral restoration

### Item 12 (SC-12): Adapted RULE-D behavioral test
- Deliverable: behavioral test(s) under tests-v2, adapted from 2318-sc1..sc3
  (tag `pre-rip`) to the new placement (boundary lives in the
  implementation-workflow reference): in a multi-module checkout, the agent
  runs build/test through the parent repo's own framework and does not execute
  a submodule's own tooling.
- RED: no adapted test exists under tests-v2 (verified 2026-10-10; the
  same-named files under `tests-v2/behaviors/fixtures/setup/` are fixture setup
  scripts, not the scenarios).
- GREEN: adapt and author per `.opencode/tests-v2/AGENTS.md`; run via `opencode
  run` wrapped by `with-test-home` (>=600s bash-tool timeout); evaluate
  exported `session.yaml` by clean-room sub-agent inspection.
- verify: behavioral test passes; no structural substitution.
- commit: test scenario.

### Item 13 (SC-13): Ledger admission record
- Deliverable: deck-debt ledger (.opencode#2534) records this admission —
  evidence base (#2431, #2555, #2467, #2306, #2318, #2496, #2469,
  opencode-config#255, opencode-config#372, .opencode#2440/#2489) and the
  placement decisions.
- RED: ledger carries no submodule entries.
- GREEN: record the admission via `local-issues`.
- verify: ledger inspection.
- commit: ledger update via `local-issues`.

## Dependency notes

Items are independent card edits in spec order; Item 12 depends on Item 6 (the
boundary text the test verifies); Item 11 and 13 are store mutations. The
branch-level sanction (Item 2) must land with Item 4's commit-card amendment
consistent in both cards — no card may contradict the sanction.

<!-- 🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash) -->
