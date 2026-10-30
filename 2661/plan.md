<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [PLAN] Recomposition protocol — .opencode#2661

Sources: `.opencode/.issues/2661/spec.md` (validated PASS, 2026-10-29, zero
findings at re-review 2). One item per SC; items trace to the spec's SCs
(SC-ID carried on each item); no padding items. Validation-standards check:
every SC is structural (assert-by-read) or the SC-9 behavioral dispatch —
no criterion reinterprets its instrument; no BLOCKED.

The protocol's trigger wording defers to the peer sibling `.opencode#2660`
(the loop rule whose Recompose outcome this protocol executes around) by
issue reference, per the spec's provenance; the implementation names it as
the spec names it ("the loop rule's Recompose outcome") and does not
restate, amend, or depend on that rule's internal mechanics.

## Items

### Item 1 — SC-1: the recomposition protocol in the `issues` card

- **Deliverable:** `skills/issues/SKILL.md` §4 (Relationships) carries the
  recomposition protocol with its three named elements: the trigger (the
  loop rule's Recompose outcome), part creation as issues registered as
  sub-issues of the recomposed issue via the `local-issues` tool's `link`,
  and standalone part specs recording their seam sides.
- **RED:** Read `skills/issues/SKILL.md` §4 — the section carries only the
  single hierarchy sentence; no trigger, no part/sub-issue registration via
  `link`, no standalone-part-spec element. Assertion fails.
- **GREEN:** Add the protocol to §4 — trigger, split mechanics (one issue
  per part artifact, registered via `.opencode/tools/local-issues`'s
  `link`), and the standalone part-spec element.

### Item 2 — SC-2: the umbrella rule

- **Deliverable:** inside the protocol, the umbrella statement: the
  recomposed issue's spec records the parts, the seams between them, and
  the re-evaluation's grounds; redistributed content is deleted in the same
  action; no superseded-content pointers.
- **RED:** Read the protocol text — no umbrella rule; assertion fails.
- **GREEN:** Add the umbrella statement with the three recorded elements
  and the same-action-deletion clause.

### Item 3 — SC-3: the void-on-split

- **Deliverable:** the void stated in two surfaces — the protocol (issues
  card) and `skills/work/SKILL.md` rule 2 (Authorization check): carried
  implementation/PR authorization is void at recomposition, work already
  delivered under a then-valid authorization stays delivered, and the
  parts' further implementation/PR work awaits the authorization the
  developer states after the notification; the spec-phase case has nothing
  to void; the work card's check names the void and routes to the protocol.
- **RED:** Read the protocol and `skills/work/SKILL.md` rule 2 — neither
  carries the void, the delivery carve-out, or the parts-await clause.
  Assertion fails.
- **GREEN:** Add the void clause to the protocol and a sentence to the
  work card's rule 2 naming the recomposition void with the route to the
  protocol.

### Item 4 — SC-4: plan supersession in the `plan` card

- **Deliverable:** `skills/plan/SKILL.md` carries the supersession rule: a
  plan derived from the pre-split spec is superseded at recomposition; new
  plans derive from the parts' specs; delivered items keep their delivered
  state, and plan state never migrates to the parts.
- **RED:** Read `skills/plan/SKILL.md` — no supersession-at-recomposition
  rule. Assertion fails.
- **GREEN:** Add the supersession rule with its two consequences.

### Item 5 — SC-5: the notification

- **Deliverable:** inside the protocol, the notification clause: a
  stakeholder comment on the recomposed issue per the comment gate,
  carrying the recomposed issue's and each part's issue and artifacts URLs
  plus the authorization consequence; chat accompanies and does not
  replace.
- **RED:** Read the protocol text — no notification clause. Assertion
  fails.
- **GREEN:** Add the notification clause.

### Item 6 — SC-6: the review shape by deferral

- **Deliverable:** inside the protocol, the review-shape clause deferring
  to `skills/git-workflow-pr/SKILL.md` §3 — issues authorized together
  share one branch and one PR carrying one squashed commit per part; a part
  never opens its own branch or PR outside the authorization scope that
  names it; the protocol states no second PR rule.
- **RED:** Read the protocol against `git-workflow-pr/SKILL.md` §3 — §3
  governs but the protocol does not defer to it nor state the part-level
  reading. Assertion fails.
- **GREEN:** Add the deferral clause, stated consistently with §3's
  wording (verified against the live §3 text).

### Item 7 — SC-7: the closure order

- **Deliverable:** inside the protocol, the closure order: parts close
  first, each by its own delivered work or triage verdict per the issues
  card's closure rule (§5); the recomposed issue closes only after every
  part has closed, as a verdict-backed closure whose record states the
  redistribution; the hierarchy sentence carries this order.
- **RED:** Read the protocol and §4's hierarchy sentence — no closure
  order stated. Assertion fails.
- **GREEN:** Add the closure-order element, bound to the hierarchy
  sentence.

### Item 8 — SC-8: no thresholds

- **Deliverable:** the protocol text carries no numeral bounding a part
  count and no size metric.
- **RED:** Read the protocol after items 1–7 — check every sentence for a
  part-count numeral or a size metric. (A numeral may enter incidentally
  in the other items' edits; this item is the scrub-and-assert gate.)
- **GREEN:** Remove any numeral bound or size metric found; assert
  absence.

### Item 9 — SC-9: behavioral fixture dispatch

- **Deliverable:** a Tier-1 clean-room behavioral dispatch per the
  `behavioral-testing` card: a sub-agent with no prior context applies the
  amended protocol to the fixture scenario — an over-fat issue holding an
  approved spec with implementation in progress — and its persisted
  dispatch evidence (prompt and stated plan of record) carries the four
  element groups the SC names: parts created as issues registered as
  sub-issues via `local-issues link`; the umbrella spec recording
  parts/seams/grounds with redistribution in the same action; the
  authorization void with delivered work standing and parts awaiting
  stated authorization; the stakeholder comment carrying the recomposed
  and parts URLs.
- **RED:** Dispatch the sub-agent against the amended cards — no prior
  evidence record exists; the dispatch's persisted evidence is the
  artifact produced.
- **GREEN:** The evidence file at
  `.opencode/.issues/2661/audit/tier1-dispatch-SC9-<date>.yaml`, modeled
  on `.opencode/.issues/2582/audit/tier1-dispatch-SC15-20261013.yaml`,
  records the prompt, the sub-agent's stated actions, and the
  judge's element assertion, judged from the sub-agent's output only.
- **Instrument:** the dispatch runs after Items 1–8 are in place; the
  behavioral test writes no production store record and performs no real
  split — the fixture scenario is hypothetical and the sub-agent states
  its actions without executing store mutations.

## Dependency order

Item 1 establishes the protocol body; items 2–7 add or complete elements
of it (each asserts its own element, so order within 2–7 is independent but
each follows 1); item 8 scrubs the composed text; item 9 dispatches on the
final text. Sequence: 1 → {2,3,4} → {5,6,7} → 8 → 9.

## Verification instruments

Items 1–8: file-read assertions against the amended card texts (each item's
instrument is stated in its RED/GREEN). Item 9: the persisted dispatch
evidence file, judged per the `behavioral-testing` card's Tier-1 contract.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)