# Implementation Plan — [.opencode#1588](https://github.com/michael-conrad/.opencode/issues/1588) — Gap-fill dispatch routing

**Goal:** Route `"approved for PR"` through gap-fill cascade directly to `writing-plans --task create`, skipping the `screen-issue` gate that blocks the pipeline.

**Architecture:** Three sequential items in a single phase. Item 1 (SC-5) adds gap-fill path routing to `verify-authorization.md`. Item 2 (SC-6) adds gap-fill-path entry to `auto-dispatch-table.md`. Item 3 (SC-4) runs the behavioral test to confirm the full pipeline works.

**Files:**
- `.opencode/skills/approval-gate/tasks/verify-authorization.md` — gap-fill path routing
- `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md` — gap-fill path entry
- `.opencode/tests/behaviors/gap-fill-dispatch.sh` — behavioral enforcement test (exists)

> **Compliance requirement:** This plan is a MANDATORY gate. Every step MUST be executed in order. Skipping, combining, or reordering steps produces defective deliverables that must be discarded.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|-------------|------------|
| 1 | Gap-fill path routing | Skip screen-issue when gap-fill applies | SC-5, SC-6, SC-4 | None | 1–10 |

## Phase 1 — Gap-fill path routing

**Concern:** The `verify-authorization` pipeline routes through `screen-issue` (Step 5) before reaching auto-dispatch (Step 6). When gap-fill applies (scope >= `for_plan`), screen-issue is meaningless — there's nothing to screen. The agent gets stuck in a re-task loop and never reaches `writing-plans --task create`.

**Files:** `.opencode/skills/approval-gate/tasks/verify-authorization.md`, `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md`

**SCs:** SC-5 (verify-authorization gap-fill path), SC-6 (auto-dispatch-table gap-fill path), SC-4 (behavioral test)

**Entry conditions:** Authorization scope `for_pr`, spec approved, plan written.

**Exit conditions:** Gap-fill path routing added, behavioral test PASSES.

### Item 1: SC-5 — verify-authorization gap-fill path

- [ ] 1. **Edit verify-authorization.md (**sub-agent**).** Add gap-fill path routing to `.opencode/skills/approval-gate/tasks/verify-authorization.md`. When `authorization_scope >= for_plan` and gap-fill actions include `auto_create_plan`, skip Step 5 (screen-issue) and route directly to Step 6 (auto-dispatch). **→ SC-5**

### Item 2: SC-6 — auto-dispatch-table gap-fill path

- [ ] 2. **Edit auto-dispatch-table.md (**sub-agent**).** Add `gap-fill-path` entry to `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md` Path Routing section. The gap-fill path skips screen-issue and pre-implementation-analysis. **→ SC-6**

### Item 3: SC-4 — Behavioral test (GREEN)

- [ ] 3. **GREEN doublecheck (**inline**).** Run the behavioral test with the submodule pinned to the feature branch commit. Verify the agent dispatches to `writing-plans --task create` (not stuck in screen-issue). Capture stderr to `./tmp/behavioral-evidence-1588/green-pass.log`.

### Global Post-Steps

- [ ] 4. **Content-verification (**inline**).** Grep for gap-fill path routing in verify-authorization.md and auto-dispatch-table.md.
- [ ] 5. **Collect evidence (**inline**).** Copy artifacts to `.opencode/.issues/1588/artifacts/`.
- [ ] 6. **Review-prep (**inline**).** Run `git-workflow --task review-prep`. Prepare PR body.
- [ ] 7. **Create PR (**inline**).** Create PR from `feature/1588-gap-fill-dispatch` → `dev`.

#### VbC

- [ ] 8. **VbC (**clean-room**).** Verify:
  - SC-5: verify-authorization.md has gap-fill path routing that skips screen-issue
  - SC-6: auto-dispatch-table.md has gap-fill-path entry
  - SC-4: Behavioral test PASSES — agent dispatches to writing-plans --task create

## Exit Criteria

- [ ] C1: verify-authorization.md routes gap-fill scopes past screen-issue
- [ ] C2: auto-dispatch-table.md has gap-fill-path entry
- [ ] C3: Behavioral test PASSES with dispatch to writing-plans --task create
- [ ] C4: PR created from feature branch
