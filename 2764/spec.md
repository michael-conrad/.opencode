<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, filed 2026-11-20 at the developer's direction
     ("file spec", chat session 2026-11-20) after explore-stage discussion;
     design finalized by the developer's directive of 2026-11-20. -->

# [SPEC] Pre-triage freshness: pull all session-enumerated repos to remote trunk tip and confirm submodule status before any triage

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | Triage — spec-state triage, content remediation, and verification — renders its verdicts against whatever local checkout state the session happens to hold. A verdict dated today can be evidence about bitrot: a spec or bug report judged "still real" against a stale trunk may already be fixed on trunk; one judged "moot" may be judged against a stale reading; content-remediation decisions can target text trunk has already moved past. |
| 2 | **Root Cause / Motivation** | The deck's trunk-tip freshness discipline covers the implementation / branch / PR surfaces (.opencode#2563) and the release-promoter card covers the release-composition moment, but no card covers the triage moment: the issues card's triage paths (closure triage, work-entry conversion) state no freshness precondition, so a self-triggered triage can fire mid-session on a stale tree and produce a dated-but-stale verdict. |
| 3 | **Approach Chosen** | Add a mandatory pre-triage freshness gate to the issues card's triage paths: before any triage runs, the agent pulls every session-enumerated repo (root + registered submodules, per session-init's `#2544` strict discovery) to its remote trunk tip and runs `git submodule status` to confirm the submodule checkouts sit at the registered pointers of that tip (each submodule checkout synced to its own remote trunk tip, per the existing #2563 trunk-tip ruling). The verdict is then rendered against the fresh state. |
| 4 | **Alternatives Considered & Why Discarded** | (1) Read-only freshness verification — fetch, compare, halt or caveat on drift, without mutating local trees — discarded: the developer's directive states pulling to remote trunk tip is the mandate, not observation. (2) A general pre-analysis freshness gate covering spec authoring, verify reviews, and audits as well as triage — discarded: the developer narrowed the change to triage ("triage is for spec state and content remediation and verification. narrow to triage."). (3) Mechanical enforcement inside the `local-issues` tool — discarded: the gate targets the source repos the triage assesses, not the issue store; the owning surface is the triage mandate prose in the issues card, reusing mechanics the deck already sanctions. |
| 5 | **Key Design Decisions** | (1) The gate is a mutating sync, and that is the point: triage's evidence must be dated to fresh trunk, so the pull is part of the triage instrument, not a convenience — reusing the release-promoter's existing pull-to-tip pattern generalized to the triage moment (developer-stated 2026-11-20). (2) The target set is exactly the session-init enumerated repo set — a fixed set from session context, so no ambiguous-scope halt applies. (3) "Up to date" means each submodule's remote trunk tip per the #2563 ruling, never the possibly-stale recorded pointer — syncing to the recorded pointer reproduces the bitrot the gate exists to remove. (4) The gate binds every triage trigger surface, including the self-triggering paths: the developer's directive defines triage's mandate to include the pull, so a self-triggered triage runs the gate without a separate developer utterance. |
| 6 | **User Intent / Original Prompt** | "a triage should trigger a pull of all repos and `git submodule status` listed repos to remote trunk tip before doing the triage so that the triage is not performed using bitrot. brainstorm a holistic fix spec." (2026-11-20). "triage is for spec state and content remediation and verification. narrow to triage. yes, pulling to remote trunk tip is the mandate before running the triage to see if the spec/bug report/etc is not now moot, that it references a real issue that needs addressing, etc." (2026-11-20). "file spec" (2026-11-20). |

## 2. Not Included

- **Plan/implementation/PR-surface freshness** — owned by .opencode#2563's rule set in `git-workflow-branch` / `git-workflow-pr`; this spec touches only the triage moment.
- **Release-composition sync** — owned by the `release-promoter` card; already carries the pull-to-tip pattern this spec generalizes.
- **Issue-store worktree sync** — the issues card's own `init`/`sync` session-start sequence already owns `issues-data` currency.
- **A mechanical fetch-failure taxonomy** — no new disposition tree; a failed pull is a cannot-continue state handled by the floor's existing report-with-evidence-and-halt rule.

## 3. Requirements

- **R-1:** Before any triage runs — closure triage and work-entry conversion triage — the agent SHALL pull every session-enumerated repo to its remote trunk tip.
- **R-2:** The pre-triage gate SHALL run `git submodule status` over the registered submodules and sync each submodule checkout to its own remote trunk tip (the #2563 definition of up to date — never the possibly-stale recorded pointer). Where the pulled parent tip's registered gitlink differs from a submodule's remote trunk tip — the sanctioned pointer-drift state — the trunk-tip checkout governs the triage's reading and the drift is recorded in the verdict's grounds rather than resolved by the gate (pointer resolution rides with real parent-repo changes per the deck's existing pointer discipline, outside the triage moment).
- **R-3:** The triage verdict SHALL be rendered against the post-sync state, and the verdict's recorded grounds SHALL state the freshness gate ran.
- **R-4:** The gate's target set SHALL be exactly the session-init enumerated repo set (root plus registered submodules) — no more, no less.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The issues card's triage sections (closure triage §5, work-entry conversion) carry the pre-triage freshness-gate mandate naming the pull-to-remote-trunk-tip step and the `git submodule status` confirmation step | structural | Read of `.opencode/skills/issues/SKILL.md` confirming the gate clause is present in both triage paths |
| SC-2 | A session running a triage performs the freshness sync (pull of each enumerated repo to remote trunk tip, then `git submodule status`) before rendering the triage verdict | behavioral | tests-v2 behavioral scenario: the session's tool-call timeline shows the pull and submodule-status calls preceding the triage verdict action |
| SC-3 | The gate clause names the session-init enumerated repo set as its target-set source | structural | Read of the gate clause confirming it binds the target set to session-init's enumeration |
| SC-4 | The recorded triage verdict grounds state that the freshness gate ran | behavioral | tests-v2 behavioral scenario: the session's recorded verdict grounds carry the freshness statement |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| session-init repo/submodule enumeration (.opencode#2544 strict discovery) | The gate consumes the tool's enumerated repo set as its fixed target set | satisfied |
| .opencode#2563 trunk-tip freshness ruling | The gate reuses its definition of "up to date" (submodule's remote trunk tip, never the recorded pointer) | satisfied |
| tests-v2 behavioral harness | SC-2 and SC-4 verify through behavioral scenarios under the harness | satisfied |
| release-promoter pull-to-tip pattern | Precedent the gate generalizes; no code dependency | satisfied |

## 6. Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1, SC-2 |
| R-2 | SC-1, SC-2 |
| R-3 | SC-4 |
| R-4 | SC-3 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Developer statements of 2026-11-20 (this session) | Session record | Chat, explore-stage discussion | Quoted verbatim in field 6 |
| `skills/issues/SKILL.md` triage paths | Deck card | `.opencode/skills/issues/SKILL.md` §5, work-entry conversion clause | Read, 2026-11-20 |
| `tools/session-init` repo/submodule enumeration | Code | `.opencode/tools/session-init` (`_registered_submodule_paths`) | Read/grep, 2026-11-20 |
| `skills/release-promoter` pull-to-tip precedent | Deck card | `.opencode/skills/release-promoter/` operating protocol | Read, 2026-11-20 |
| .opencode#2563 spec (trunk-tip freshness) | Store spec | `.issues/2563/spec.md` | Read, 2026-11-20 |
| .opencode#1994 spec (plan-preamble submodule sync) | Store spec | `.issues/1994/spec.md` | Read, 2026-11-20 — distinct surface (plan preamble), no overlap |

## 8. Cost Frame

- **SC-1:** a Read of the issues card — seconds; skipping it risks shipping a triage clause that exists on only one of the two triage paths.
- **SC-2:** one behavioral scenario run under the tests-v2 harness — minutes of harness time; skipping it leaves the gate unverifiable at runtime, and bitrot verdicts cost triage loops that re-litigate stale evidence.
- **SC-3:** a Read of the clause — seconds; skipping it risks an unbounded or ambiguous target set, the exact scope failure the floor's target-entity rule guards.
- **SC-4:** carried by the same scenario as SC-2 — marginal; skipping it leaves verdict records with no dated freshness anchor, the original defect restated.

## 9. Edge Cases

- **Condition:** a repo in the enumerated set has no submodules. **Expected behavior:** `git submodule status` output is empty; the gate's submodule step is vacuously satisfied and the pull step still runs.
- **Condition:** local trunk already equals remote trunk tip (no drift). **Expected behavior:** the pull is a no-op fast-forward; the gate completes without changes and the verdict records freshness.
- **Condition:** the pulled parent tip's registered gitlink differs from a submodule's remote trunk tip (the sanctioned pointer-drift state). **Expected behavior:** the submodule checkout is synced to its remote trunk tip per the #2563 ruling and the triage reads that state; the drift is recorded in the verdict grounds; the gate never resolves it by committing a pointer bump (that rides with real parent-repo changes outside the triage moment).
- **Condition:** the pull fails (network or auth). **Expected behavior:** the floor's existing cannot-continue rule applies — report with evidence and halt the triage; no new disposition tree is introduced.
- **Condition:** the session's working tree holds uncommitted in-progress work. **Expected behavior:** the gate is part of triage's mandate and runs as directed; git's own pull semantics govern conflicts — this spec introduces no parallel preservation mechanism.

## 10. Completion gate

Every success criterion passes before the deliverable is complete; partial implementation is not permitted.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
