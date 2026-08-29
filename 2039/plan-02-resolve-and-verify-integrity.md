# Phase 2 — Resolve Special-Case References + Verify TDT Integrity

**Concern:** Ensure no Trigger Dispatch Table or Invocation references a non-existent task card. Resolve the two special-case dangling references (`multimodal-dispatch/route` and `issue-operations-core/push-artifacts`) such that no dangling reference remains (SC-4), then verify deck-wide TDT-reference integrity (SC-3). This phase maps the single CONCERN-2 boundary.

**Files:**
- `.opencode/skills/multimodal-dispatch/SKILL.md` — remove the stale `route` TDT row + Invocation; reroute the `"route" / "route task" / "dispatch to model"` triggers to `dispatch`
- `.opencode/skills/issue-operations-core/SKILL.md` — ensure the core TDT row for `push-artifacts` references the (now-created) core card
- `.opencode/skills/issue-operations-core/tasks/push-artifacts.md` — finalize as a thin core dispatcher that resolves `github.platform` and routes to the platform sub-skill, capturing the returned `artifact_url` for the `spec-creation/tasks/reconcile-push.md` consumer
- `.opencode/skills/**/SKILL.md` (verification only — no modification expected)

**SCs:** SC-4, SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the 10 task card files exist (including the `push-artifacts` scaffold and the `route` decision target)
- Phase 1 VbC passed
- Deliverables are already present in the working tree; this phase verifies and finalizes the two resolutions and the deck-wide integrity gate

**Exit Conditions:**
- `multimodal-dispatch/SKILL.md` has no dangling `route` TDT row or Invocation; the `route` triggers route to `dispatch`
- `issue-operations-core/SKILL.md` TDT row for `push-artifacts` references an existing card
- `issue-operations-core/tasks/push-artifacts.md` is a thin core dispatcher routing by `github.platform` and returning `artifact_url`
- Cross-referencing every TDT and Invocation against the filesystem finds no reference to a non-existent task card
- SC-4 and SC-3 verified PASS

---

- [ ] 19. **Pre-regression (**sub-agent**).** Execute the `pre-regression` step: run regression test patterns to establish the baseline for the SC-4 string-evidence verification. **→ establishes baseline before RED**

- [ ] 20. **Pre-regression verify (**clean-room**).** Execute the `pre-regression-verify` step: verify the pre-regression results. **→ baseline verified**

- [ ] 21. **RED — SC-4 (item 4) (**clean-room**).** Execute the `red` task from test-driven-development: write a failing enforcement test asserting that the `route` TDT row + Invocation in `multimodal-dispatch/SKILL.md` either reference an existing card or are removed, and that the `push-artifacts` core card routes correctly. The test FAILS because the dangling references remain. **→ SC-4**

- [ ] 22. **GREEN — SC-4 (item 4) (**clean-room**).** Execute the `green` task from test-driven-development: apply the two resolutions so the RED test passes —
  - remove the stale `route` TDT row + Invocation in `multimodal-dispatch/SKILL.md` and reroute the `"route" / "route task" / "dispatch to model"` triggers to `dispatch`; and
  - finalize `issue-operations-core/tasks/push-artifacts.md` as a thin core dispatcher that resolves `github.platform` and routes to the platform sub-skill, capturing the returned `artifact_url` for `spec-creation/tasks/reconcile-push.md`. **→ SC-4**

- [ ] 23. **Post-regression (**clean-room**).** Execute the `post-regression` step after the GREEN phase. **→ post-GREEN regression clean**

- [ ] 24. **Verify — SC-4 (item 4) (**clean-room**).** Execute the `verify` task from verification-before-completion: verify the `route` and `push-artifacts` TDT rows/Invocation reference an existing card or are removed, with no dangling reference remaining. **→ SC-4**

- [ ] 25. **Commit — SC-4 (**inline**).** Orchestrator stages and commits the two special-case resolutions with their enforcement test as one atomic slice. **→ SC-4 committed**

- [ ] 26. **Pre-regression (**sub-agent**).** Execute the `pre-regression` step: run regression test patterns to establish the baseline for the SC-3 string-evidence verification. **→ establishes baseline before RED**

- [ ] 27. **Pre-regression verify (**clean-room**).** Execute the `pre-regression-verify` step: verify the pre-regression results. **→ baseline verified**

- [ ] 28. **RED — SC-3 (item 5) (**clean-room**).** Execute the `red` task from test-driven-development: write a failing enforcement test that cross-references all TDTs and Invocations in `.opencode/skills/**/SKILL.md` against the task card files on disk, asserting no TDT references a non-existent task card. The test FAILS while any dangling reference remains. **→ SC-3**

- [ ] 29. **GREEN — SC-3 (item 5) (**clean-room**).** Execute the `green` task from test-driven-development: reconcile any remaining dangling references surfaced by the RED test (expected to be none after the SC-4 resolutions) so the RED test passes. **→ SC-3**

- [ ] 30. **Post-regression (**clean-room**).** Execute the `post-regression` step after the GREEN phase. **→ post-GREEN regression clean**

- [ ] 31. **Verify — SC-3 (item 5) (**clean-room**).** Execute the `verify` task from verification-before-completion: cross-reference all TDTs against the filesystem and confirm no TDT references a non-existent task card. **→ SC-3**

- [ ] 32. **Commit — SC-3 (**inline**).** Orchestrator stages and commits the integrity gate (and any reconciliation) with its enforcement test as one atomic slice. **→ SC-3 committed**

#### Phase 2 VbC

- [ ] 33. **VbC (**clean-room**).** Verify SC-4 and SC-3 PASS against the present deliverables: `multimodal-dispatch/SKILL.md` carries no dangling `route` reference (triggers route to `dispatch`), `issue-operations-core/tasks/push-artifacts.md` is a thin core dispatcher routing by `github.platform` with no dangling reference, and cross-referencing all TDTs and Invocations in `.opencode/skills/**/SKILL.md` against the filesystem finds no reference to a non-existent task card. Any non-clean verdict coerces to FAIL per the reference card's Coercion Rules. **→ SC-4, SC-3**

**Concern transition:** Leaving the TDT Reference Integrity concern → entering post-implementation gates (structural checks, audit, review-prep, PR creation, completion).
