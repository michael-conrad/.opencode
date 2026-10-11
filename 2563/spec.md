<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated; evidence base: .opencode#2431, #2555, #2467, #2306, #2318, #2496, #372, #2469; opencode-config#255, #2440, #2489 -->

# [SPEC] Submodule discipline rule set for deck skill cards

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | Agents developing in parent repos with submodules repeatedly ship bitrot: PRs are cut against stale submodule pointers; recursive/nested submodule checkouts move nested HEADs and incorporate bitrot into products; agents execute a submodule's own build tooling directly instead of the parent repo's framework; and stale ticket state feeds the developer wrong facts that become bad instructions to the agent. Every failure class has a recorded incident (Documentation Sources). |
| 2 | **Root Cause / Motivation** | The #2490 rip-and-replace retired the pre-rip guidelines that carried these rules (e.g. "NEVER use --recursive with any git submodule command"; the root-repo-only tooling rule) and the surviving cards never re-admitted them: `git-workflow-branch` has a pointer-rides-alongside note and a parent-trunk freshness check (item 2) but no submodule-pointer trunk-tip freshness or capture-commit sequence; `git-workflow-pr`'s pre-create checklist has no pointer-inclusion, pointer-only-PR, or submodule-PR-ordering language; `ci-boundary` mandates pinned submodule checkout but takes no stance on recursion; `git-workflow-commit` #5 calls pointer-only commits a defect without distinguishing branch-level capture commits from review-surface commits; `issues` has sync mechanics but no state-divergence correction rule; the implementation-workflow reference has no execution boundary. |
| 3 | **Approach Chosen** | Re-admit the rule set scoped into the existing skill cards (no new card, no floor.md or routing.md changes): trunk-tip freshness, real-work sequence, and deinit remediation in `git-workflow-branch`; PR-surface and ordering-gate clauses in `git-workflow-pr`; the branch-level/review-surface amendment in `git-workflow-commit`; the non-recursive checkout mandate in `ci-boundary`; the agent-execution boundary in the implementation-workflow reference with a pointer line in `ci-boundary`; ticket-state hygiene in `issues`. Restore the execution-behavior RULE-D test adapted to the new placement under the tests-v2 harness. Correct the stale local mirror of #2306 as the hygiene rule's first application. Record the admission in the deck-debt ledger. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Re-inject RULE-D into the always-injected surface (floor.md / canonical AGENTS.md, as pre-rip) — discarded: surface discipline forbids re-injecting work-scoped directives into the always-loaded floor. (b) A new standalone skill card for the rule set — discarded: fails the admission gate's net-zero test; the affected cards are already routed and already loaded at the failure moments. (c) Restoring the pre-rip mid-work pointer-freshness gate — discarded: recorded as unsatisfiable (freshness is legitimately false mid-development; a gate asserting pointer-equals-live-tip fails after any legitimate tip movement); the new rules are a start-of-work sync action plus fact-decidable PR checks, not a resurrected gate. (d) Mechanical enforcement scripts (hooks/lint) for the new rules — discarded: the rules are intent-decidable in operation; static checks on intent-decidable rules are the deck's founding defect; the existing pre-commit hook was verified this session to place no constraint on the capture-commit sequence. (e) Restoring all five pre-rip RULE-D behavioral tests verbatim — discarded: two of them verify the retired Tier classification (HALT framing, developer-authorization carve-out) that no longer exists in the live deck; only the execution-behavior tests are re-admitted. |
| 5 | **Key Design Decisions** | (1) "Up-to-date" means the submodule's remote trunk tip — the tracked-branch tip per `.gitmodules`, fetched from the remote — not the recorded pointer; syncing to the recorded pointer reproduces possibly-stale state, which is the bitrot trap itself. (2) The pointer committed is the one the parent developed against: the start-of-work capture guarantees a non-bitrot baseline, and the ordering gate plus post-merge re-sync guarantee the PR never references unmerged submodule state. (3) The ordering gate is strict: any pending submodule PR blocks any parent PR creation, including unrelated changes — the accepted serialization cost of zero-bitrot PRs (developer-stated). (4) Pointer-only commits are sanctioned at branch level as capture commits and forbidden as standalone PRs, with release PRs exempt because their changelog/version/tag-prep content is real content; the squash-at-PR convention folds the capture commit into the per-issue commit, preserving the ride-along invariant at the review surface. (5) The deinit incantation is the session-verified form `git submodule foreach git submodule deinit --all --force` — the unadorned form exits 128 on modern git (bare `deinit` requires `--all` or a pathspec), making it a complete no-op; `--force` destroys nested uncommitted content by design, safe under the no-recursion rule because agents never legitimately write nested worktrees. (6) Ticket-state correction direction: the remote tracker anchors reality for changes made remotely (e.g. #2306's closure); the local store's authority per .opencode#2561 governs the closure workflow it drives — the two govern different moments and do not collide. (7) False-modified trigger conditions, verified empirically: divergent nested state (dirty worktree or moved HEAD) produces the phantom parent status; mere initialization of clean nested submodules does not on git 2.43.0. |
| 6 | **User Intent / Original Prompt** | "brainstorm: we need appropriate anti-bitrot anti-cargo culting use modern up-to-date coding practices admonishments added to the appropriate skill cards. pointers must be brought up-to-date before doing any implementation work and always always always included in any root repo PRs, release or otherwise. additional admonishment which needs adding is to never do a recursive checkout and that a 'git submodule foreach git submodule deinit --force' may need to be run to ensure clean submodules don't show up as falsely modified in the root repository." Refined in-session by the developer: up-to-date = remote trunk tip; the synced pointer is what gets committed because it is what the root repo developed against; no parent PR for only pointer bumps unless a release PR has been requested; submodules are simply no recursion; the capture-commit sequence applies only when the parent has something to actually commit beyond pointer bumps; parent PR creation blocks while submodule PRs are pending; the corrected incantation is `git submodule foreach git submodule deinit --all --force`; RULE-D is re-admitted scoped into the appropriate skill cards; stale ticket states are always corrected to prevent the developer providing bad instructions to the agent; SCs added as needed to fix discovered defects; the rule set is complete. |

## 2. Not Included

- **Behavioral enforcement tests for the new prose rules beyond RULE-D restoration** — the item's scope is card admonishments plus discovered-defect fixes; the pre-rip enforcement-test mandate that generated #2318's five-test suite was retired with its guideline.
- **Changes to `floor.md` or `routing.md`** — every rule is card-scoped; the existing routing entries already route to the affected cards at the failure moments.
- **Changes to `release-promoter`** — it already carries the sanctioned pattern (build/test at gitlink-pinned SHAs from the root, `git submodule update --init --depth 1`, never `--recursive`); consistent with this rule set, no edit needed.
- **Hook changes** — the surviving pre-commit hook is trunk-protection plus store-path reference gating; verified this session to place no constraint on pointer-only capture commits on feature branches.
- **Deinit execution in repos without nested-submodule divergence** — R-7 is a documented remediation procedure, not a standing cleanup task; this parent repo has no nested submodules, and its current ` M .opencode` state is pointer drift awaiting the next real parent-repo change, not false modification.
- **Mechanical enforcement scripts for the new rules** — see Alternative (d).
- **Restoring the #2318 HALT-framing and carve-out behavioral tests** — they verify the retired Tier classification model; see Alternative (e).

## 3. Success Criteria

Each SC is a single atomic, independently verifiable claim. Evidence types are classified by the change's nature: card text, store state, and reference resolution are structural (fact-decidable file/state facts); agent build/test behavior is behavioral (runtime effect, verified through the tests-v2 harness).

### Phase 1 — Parent-side card edits

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `git-workflow-branch` states the trunk-tip freshness rule with all three elements: (a) the parent trunk pulled to its remote tip before any work; (b) submodule pointers synced to each submodule's remote trunk tip (the tracked-branch tip per `.gitmodules`, fetched from the remote — not the recorded pointer); (c) no branch and no commit when the parent has nothing to contribute beyond pointer bumps. | structural | Inspect the card text for the three elements; each must be present and unambiguous |
| SC-2 | `git-workflow-branch` states the real-work sequence in the fixed order — sync first, then feature-branch creation, then an immediate pointer-capture commit explicitly sanctioned as pointer-only at branch level, then work. | structural | Inspect the card text for the four ordered steps and the branch-level sanction; no card text contradicts the sanction |
| SC-3 | `git-workflow-pr` states all three PR-surface clauses: (a) a parent-repo PR includes pending submodule pointer bumps (a bump exists when the submodule's checked-out HEAD differs from the recorded gitlink); (b) a parent-repo PR consisting only of pointer bumps is forbidden; (c) release PRs are exempt because their changelog/version/tag-prep content is the real content. | structural | Inspect the card's pre-create checklist area for the three clauses |
| SC-4 | `git-workflow-commit` #5 is amended to draw the branch-level vs review-surface line: pointer-only capture commits are sanctioned on feature branches; pointer-only commits are forbidden at the review surface except as release PRs; the ride-along invariant (pointer rides with real changes in the same commit) is preserved for the squashed review surface. | structural | Inspect the amended #5 text for all three properties |
| SC-5 | `git-workflow-pr` states the ordering gate: parent-repo PR creation is blocked while any submodule PR is pending (filed and unmerged on the submodule's tracker); after the submodule PRs merge, the parent PR carries the pointer to the merged submodule trunk tip, re-synced with the parent's verification re-run against the composed state before creation. | structural | Inspect the card for both the blocking clause and the post-merge re-sync/re-verify requirement |

### Phase 2 — Execution boundary and recursion ban

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-6 | The implementation-workflow reference (`.opencode/skills/implement/references/implementation-workflow.md`) states the execution boundary: in a parent repo with submodules, build/test/verification runs through the parent repo's own framework, and the agent does not execute a submodule's own build tooling directly. | structural | Inspect the reference text for the boundary statement |
| SC-7 | `ci-boundary` cross-references the agent-execution boundary in the implementation-workflow reference — a pointer, not a restatement. | structural | Inspect `ci-boundary` for the cross-reference to the reference path |
| SC-8 | `ci-boundary` states the non-recursive checkout mandate enumerating all three forms: CI checkout configured with `submodules: recursive`, `git clone --recursive`, and `git submodule update --init --recursive`. | structural | Inspect the card text for the mandate and the three enumerated forms |

### Phase 3 — Remediation and hygiene

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-9 | `git-workflow-branch` states the deinit remediation containing, verbatim, the incantation `git submodule foreach git submodule deinit --all --force` run from the parent repo root, the caveat that `--force` destroys uncommitted content in nested submodule worktrees (safe under the no-recursion rule), and the restore path `git submodule update --init --recursive`. | structural | String-match the incantation; inspect for the caveat and the restore path |
| SC-10 | `issues` states the ticket-state hygiene rule: a stale ticket state — the local store mirror's record diverging from the remote tracker's state — is corrected on discovery, with the remote tracker anchoring reality for changes made outside the local workflow and the local-authoritative closure ruling (.opencode#2561) governing the closure workflow it drives. | structural | Inspect the card text for the rule and the boundary against the closure ruling |
| SC-11 | The local store mirror of .opencode#2306 carries the same state as the remote tracker (closed), correcting the stale-open divergence recorded 2026-10-09. | structural | Compare the local record's status (`local-issues read`) against `gh issue view 2306 -R michael-conrad/.opencode --json state` |

### Phase 4 — Governance record and behavioral restoration

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-12 | Adapted RULE-D behavioral enforcement test(s) exist under the tests-v2 harness and pass: in a multi-module checkout, the agent runs build/test through the parent repo's own framework and does not execute a submodule's own tooling. | behavioral | Behavioral enforcement test via `opencode run` wrapped by `with-test-home` (>=600s bash-tool timeout); evaluation of the exported `session.yaml` via clean-room sub-agent inspection per `.opencode/tests-v2/AGENTS.md`, adapted from 2318-sc1..sc3; no structural substitution |
| SC-13 | The deck-debt ledger issue records this admission: the evidence base (#2431, #2555, #2467, #2306, #2318, #2496, #372, #2469, opencode-config#255, #2440/#2489) and the placement decisions. | structural | Inspect the ledger issue's body/comments for the admission entry |

### Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1 through SC-11 and SC-13: each is a read of an edited card or a store-vs-remote comparison — one read call each. Skipping one means a rule ships to every consumer repo with a hole the next incident pays for.
- SC-12: minutes of bounded behavioral execution. Skipping it means the re-admitted execution boundary ships without enforcement evidence — the exact loss the rip inflicted on #2318.

## 4. Requirements

- R-1. Before any work in a repo containing submodules, the agent SHALL sync the parent repo's trunk to its remote tip and SHALL sync each submodule's pointer to that submodule's remote trunk tip (the tracked-branch tip per `.gitmodules`, fetched from the remote); when the parent has nothing to contribute beyond pointer bumps, this SHALL NOT create a branch or a commit.
- R-2. When the parent repo has real content beyond pointer bumps, the agent SHALL sync before branch creation, SHALL create the feature branch, SHALL immediately commit the updated pointers as a pointer-only capture commit, and only then SHALL commence work.
- R-3. A parent-repo PR SHALL include pending submodule pointer bumps; a parent-repo PR consisting only of pointer bumps SHALL NOT be created; a release PR SHALL be exempt from the pointer-only prohibition because its changelog, version, and tag-prep content is the real content.
- R-4. Parent-repo PR creation SHALL be blocked while any submodule PR is pending; after the submodule PRs merge, the parent PR SHALL carry the pointer to the merged submodule trunk tip, re-synced with the parent's verification re-run against the composed state before creation.
- R-5. In a parent repo with submodules, the agent SHALL run build, test, and verification through the parent repo's own build framework and SHALL NOT execute a submodule's own build tooling directly.
- R-6. The agent SHALL NOT perform a recursive submodule checkout in any form: CI checkout configured with `submodules: recursive`, `git clone --recursive`, or `git submodule update --init --recursive`.
- R-7. False-modified submodule status caused by divergent nested submodule state SHALL be remediated with `git submodule foreach git submodule deinit --all --force` run from the parent repo root.
- R-8. A stale ticket state — the local store mirror's record diverging from the remote tracker's state — SHALL be corrected on discovery, reconciling both sides to the true state.
- R-9. The deck-debt ledger SHALL record this admission's evidence base and placement decisions.

## 5. Phases and Items

Per-SC item enumeration; each SC maps to exactly one item. RED states were verified against the live deck on 2026-10-09.

### Phase 1 — Parent-side card edits

#### Item 1 (SC-1): Trunk-tip freshness in `git-workflow-branch`
- RED: structural check asserts the card lacks the unified three-element trunk-tip freshness rule: item 2 already carries element (a)'s branching-time form (trunk verified and rebased before branching — re-verified 2026-10-10), so the absent content is the pre-any-work freshness scope of (a), element (b) submodule-pointer-to-remote-trunk-tip, element (c) the no-branch/no-commit clause, and the unified three-element statement — verified absent on 2026-10-09.
- GREEN: author the rule into the card's trunk-freshness/submodules steps.
- verify: structural inspection finds all three elements.
- commit: card edit.

#### Item 2 (SC-2): Real-work sequence in `git-workflow-branch`
- RED: structural check asserts the card lacks the ordered sync → branch → capture-commit → work sequence and carries no branch-level pointer-only sanction — item 3 currently prohibits pointer-only commits unconditionally, so the sanction cannot coexist with that text unamended (re-verified 2026-10-10).
- GREEN: author the sequence and the sanction, amending item 3's blanket prohibition to the branch-level/review-surface distinction (mirroring SC-4's commit-card amendment).
- verify: structural inspection finds the ordered steps and the sanction, and finds no card text contradicting the sanction.
- commit: card edit.

#### Item 3 (SC-3): PR-surface clauses in `git-workflow-pr`
- RED: structural check asserts the pre-create checklist carries no pointer-inclusion, pointer-only-prohibition, or release-exemption language — verified absent.
- GREEN: add the three clauses to the pre-create checklist.
- verify: structural inspection finds all three clauses.
- commit: card edit.

#### Item 4 (SC-4): Commit-card amendment
- RED: structural check asserts #5 calls pointer-only commits a defect without the branch-level/review-surface distinction.
- GREEN: amend #5.
- verify: structural inspection finds the three properties.
- commit: card edit.

#### Item 5 (SC-5): Ordering gate in `git-workflow-pr`
- RED: structural check asserts the card carries no submodule-PR-blocking language.
- GREEN: add the ordering gate and the post-merge re-sync/re-verify requirement.
- verify: structural inspection finds both.
- commit: card edit.

### Phase 2 — Execution boundary and recursion ban

#### Item 6 (SC-6): Execution boundary in the implementation-workflow reference
- RED: structural check asserts the reference carries no submodule-execution boundary — verified absent.
- GREEN: add the boundary statement.
- verify: structural inspection finds the boundary statement.
- commit: reference edit.

#### Item 7 (SC-7): `ci-boundary` pointer
- RED: structural check asserts no cross-reference from `ci-boundary` to the implementation-workflow reference.
- GREEN: add the pointer line.
- verify: structural inspection finds the cross-reference.
- commit: card edit.

#### Item 8 (SC-8): Non-recursive mandate in `ci-boundary`
- RED: structural check asserts the card takes no stance on recursive checkout — verified absent.
- GREEN: add the mandate enumerating the three forms.
- verify: structural inspection finds the mandate and the three forms.
- commit: card edit.

### Phase 3 — Remediation and hygiene

#### Item 9 (SC-9): Deinit remediation in `git-workflow-branch`
- RED: structural check asserts no false-modified-status deinit remediation exists in any card (verified 2026-10-09); the only `deinit` occurrence in the live deck is the wiki-operations migration reference's `git submodule deinit <wiki-path>` step — a wiki-path removal procedure, not a status remediation (verified 2026-10-10).
- GREEN: author the remediation with the verbatim incantation, the destruction caveat, and the restore path.
- verify: string-match plus inspection.
- commit: card edit.

#### Item 10 (SC-10): Ticket-state hygiene in `issues`
- RED: structural check asserts the card has sync mechanics but no state-divergence correction rule — verified.
- GREEN: author the rule with the closure-ruling boundary.
- verify: structural inspection.
- commit: card edit.

#### Item 11 (SC-11): #2306 stale-open correction
- RED: the local mirror says open while the remote tracker says closed (recorded by evidence research 2026-10-09).
- GREEN: correct the local mirror to the remote state via `local-issues`.
- verify: state comparison matches.
- commit: store mutation (auto-committed by the tool).

### Phase 4 — Governance record and behavioral restoration

#### Item 12 (SC-12): Adapted RULE-D behavioral test
- RED: no adapted test exists under tests-v2 (2318-sc1..sc3 exist only at tag `pre-rip`).
- GREEN: adapt the scenario to the new placement (the boundary lives in the implementation-workflow reference) and author it per the tests-v2 harness.
- verify: the behavioral test passes via `session.yaml` clean-room sub-agent inspection.
- commit: test scenario.

#### Item 13 (SC-13): Ledger admission record
- RED: the deck-debt ledger carries no submodule entries — verified.
- GREEN: record the admission (evidence base and placement decisions).
- verify: ledger inspection.
- commit: ledger update via `local-issues`.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/skills/git-workflow-branch/SKILL.md` | carries R-1, R-2, R-7 | Satisfied (present) |
| `.opencode/skills/git-workflow-commit/SKILL.md` | carries the R-3 amendment | Satisfied (present) |
| `.opencode/skills/git-workflow-pr/SKILL.md` | carries R-3, R-4 | Satisfied (present) |
| `.opencode/skills/ci-boundary/SKILL.md` | carries R-6 and the SC-7 pointer | Satisfied (present) |
| `.opencode/skills/implement/references/implementation-workflow.md` | carries R-5 | Satisfied (present, verified 2026-10-09) |
| `.opencode/skills/issues/SKILL.md` | carries R-8 | Satisfied (present) |
| `.opencode/tests-v2/AGENTS.md` | behavioral harness contract presupposed by SC-12 | Satisfied (present) |
| Tag `pre-rip` in the `.opencode` repo | source for the 2318-sc1..sc3 adaptation | Satisfied (present) |
| `local-issues` tool | store mutations for SC-11, SC-13 | Satisfied (present) |
| Deck-debt ledger (.opencode#2534) | receives the SC-13 admission record | Satisfied (present) |
| Session experiment 2026-10-09 (git 2.43.0, super→sub→nested scaffold) | established the verified deinit incantation, its failure modes, and the false-modification trigger conditions | Satisfied (executed; outputs recorded in session) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3, SC-4 | Phase 1 |
| R-4 | SC-5 | Phase 1 |
| R-5 | SC-6, SC-7, SC-12 | Phase 2, Phase 4 |
| R-6 | SC-8 | Phase 2 |
| R-7 | SC-9 | Phase 3 |
| R-8 | SC-10, SC-11 | Phase 3 |
| R-9 | SC-13 | Phase 4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| .opencode#2431 | incident (stale pointers, "Butter #304") | github.com/michael-conrad/.opencode/issues/2431 | Read during evidence research 2026-10-09 |
| .opencode#2555 | incident (open regression 2026-10-07) | github.com/michael-conrad/.opencode/issues/2555 | Read during evidence research 2026-10-09 |
| .opencode#2467 | incident + developer directive (nested checkout) | github.com/michael-conrad/.opencode/issues/2467 | Read during evidence research 2026-10-09 |
| .opencode#2306 | incident (second recursion violation) + stale store state | github.com/michael-conrad/.opencode/issues/2306; local mirror `.opencode/.issues/2306/` | Read during evidence research 2026-10-09 |
| .opencode#2318 | pre-rip rule + behavioral tests | github.com/michael-conrad/.opencode/issues/2318; spec at `.opencode/.issues/2318/spec.md`; tests at tag `pre-rip` | Read during evidence research 2026-10-09 |
| .opencode#2496 | incident (ci-boundary origin) | github.com/michael-conrad/.opencode/issues/2496 | Read during evidence research 2026-10-09; its dangling "tracked in opencode-config#116" citation (remote #116 is an unrelated spec) was re-attributed from the card to this record at validation and remediated as store hygiene — the card itself never carried it |
| .opencode#372, #2469 | misapplication family (unscoped test-framework mandates) | github.com/michael-conrad/.opencode/issues/372, 2469; parent `.issues/372/` | Read during evidence research 2026-10-09 |
| opencode-config#255 | pre-work ordering defect | github.com/michael-conrad/opencode-config/issues/255 | Read during evidence research 2026-10-09 |
| opencode-config#2440, .opencode#2489 | freshness-gate removal history | issue records | Read during evidence research 2026-10-09 |
| Affected cards (six) | current-state verification | paths in Dependencies | Read 2026-10-09 — RED states verified |
| Deinit incantation experiment | empirical evidence | sandbox scaffold, git 2.43.0 | Executed 2026-10-09; outputs recorded in session |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Edge Cases

### Input boundaries

- **Condition:** The parent trunk tip equals the recorded submodule pointer — no submodule movement since the last parent change.
- **Expected behavior:** The sync is a no-op; no capture commit exists; the sequence proceeds.
- **Resolution:** R-1's no-branch/no-commit clause and R-3's pending-bump definition (a bump exists when the checked-out HEAD differs from the recorded gitlink).

- **Condition:** A parent hotfix is needed while an unrelated submodule PR is pending.
- **Expected behavior:** Parent PR creation blocks until the submodule PR merges; the hotfix waits.
- **Resolution:** R-4 is strict by developer decision — the serialization cost is the accepted price of zero-bitrot PRs.

### State transitions

- **Condition:** The submodule's remote trunk tip advances mid-work, after the capture commit.
- **Expected behavior:** The parent does not chase the tip mid-work; the PR carries the pointer the parent developed against — unless a submodule PR from this cycle merges, in which case R-4's post-merge re-sync applies before PR creation.
- **Resolution:** Distinguishes the freshness action (start of work) from the freshness gate the deck removed (opencode-config#2440, .opencode#2489); no mid-work freshness gate is reinstated.

- **Condition:** The submodule's trunk tip is red on its own CI.
- **Expected behavior:** The tip is post-gate by the submodule's own pipeline (ci-boundary's execution-isolation rules); a red tip reaching the parent surfaces through the parent's own suite, which gates the PR.
- **Resolution:** The failure-isolation rule and R-1 interlock: "remote trunk tip" means the submodule's gated trunk.

### Failure modes

- **Condition:** The false-modified state trains an agent to dismiss ` M .opencode` as phantom when it is a real pointer change.
- **Expected behavior:** The deinit remediation restores status trustworthiness; status is re-read before any commit decision when the state is ambiguous.
- **Resolution:** R-7's remediation run precedes commit decisions under ambiguity.

- **Condition:** `deinit --force` executes while nested worktrees hold uncommitted content.
- **Expected behavior:** The content is destroyed.
- **Resolution:** Safe by design under R-6 — agents never legitimately write nested worktrees; the caveat is mandatory card text (SC-9).

### Concurrency

- **Condition:** Two open parent PRs both carry pointer bumps.
- **Expected behavior:** Merge order determines the surviving pointer; the outlasted PR re-syncs before its merge.
- **Resolution:** Standard PR contention; R-4's post-merge re-sync covers the ordering.

### Recovery

- **Condition:** Nested submodule worktrees are needed again after deinit.
- **Expected behavior:** `git submodule update --init --recursive` restores them from the recorded SHAs.
- **Resolution:** Mandatory card text (SC-9).

---
<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
