# Spec: .opencode#2584 — Ceremony containment on developer-directed edits

Provenance: developer directive 2026-10-12 in-session ("treat excess ceremony as
an immediate defect signal that needs fixing; add an SC or spec and implement to
reinforce this if needed"), issued while supervising `.opencode#2554` behavioral
runs. Observed failure: three behavioral runs on the same model
(qwen3.8:27b-256k-gguf4, artifacts preserved under `tmp/2554/artifacts/` in the
working checkout) show developer-directed single-edit tasks triggering pipeline
and admission machinery the instruction already satisfies:

1. RED baseline `2554-sc6-write-side-binding` (pinned dc69525c): one-paragraph
   CONTRIBUTING.md task → work gate, implement card, implementation-workflow
   read, programming-principles load, submodule-remote investigation, unrelated
   issue-spec read (`.issues/100/spec.md`), real-remote `git ls-remote` — ~19
   minutes before the write.
2. `2554-sc9-substantive-edit-converts` attempt 3 (post-remediation HEAD): a
   developer-directed card edit (add rule 6 to the correspondence card) →
   skill-creator admission gate applied to the instruction itself; issue-store
   search, unrelated fixture issue-spec reads, git-history and changelog
   archaeology for "observed failure" evidence, ending in a deliberation that
   halts for direction — no edit in ~35 minutes.
3. Counter-evidence: `2554-sc7-no-pedantry` classified the same task shape as
   the work card's short path and completed with mild ceremony — the short path
   exists; agents undertrigger it.

## Problem

Two deck surfaces collide for developer-directed edits: the work card's
short path (developer's request is the spec) and skill-creator's admission
gate (every deck edit passes the gate). Nothing tells the agent that a
developer-directed edit carries its own observed-failure evidence and
authorization — the gate runs at instruction-execution time as if the edit
were a proposal, and the agent either performs archaeology to invent evidence
or halts for direction. Ceremony is not merely slow: it diverts inference from
the task, manufactures scope creep (elaboration beyond the requested change),
and converts direct orders into approval-seeking.

## Decisions (developer-stated unless noted)

1. **Immediate defect signal.** Excess ceremony in a behavioral run or live
   session is a defect, recorded and remediated — never tolerated as
   thoroughness.
2. **Deck wording fix, not new enforcement machinery.** The fix is wording in
   the two colliding surfaces; no scripts, no new gates.
3. **Developer-instruction carve-out.** A developer-directed edit carries its
   own observed-failure evidence and authorization; the admission gate governs
   agent-proposed deck content, not instruction execution. The gate still
   applies to the *content* of what is written (its standards hold), but the
   proposal-time evidence hunt is not repeated at execution time.
4. **Short-path reinforcement.** The work card's short path is stated as the
   default for single-file, developer-specified changes; pipeline machinery
   beyond the short path requires a reason visible in the work record.

## Fix shape

| Artifact | Change |
|---|---|
| `skills/skill-creator/SKILL.md` | Admission gate gains the developer-instruction carve-out: developer-directed edits carry their own evidence and authorization; the gate's standards bind the written content, the proposal-time evidence hunt does not re-run at execution time. |
| `skills/work/SKILL.md` | Short-path paragraph reinforced: single-file, developer-specified changes take the short path by default; deviation requires a stated reason. |
| `tests-v2/behaviors/` | Two new behavioral scenarios (artifact-only generators) with clean-room evaluation: (a) developer-directed single-file deck edit completes without admission archaeology and without halting for direction; (b) the short path is taken for a developer-specified single-file change. |

Untouched: floor.md, routing.md, all other cards.

## Success criteria

### SC-1 (structural) — scope containment

The change touches only `skills/skill-creator/SKILL.md`,
`skills/work/SKILL.md`, and new `tests-v2/behaviors/2584-sc*.sh` scripts
(+ fixtures).

- **Verify:** `git diff --stat` for the change shows exactly those paths.

### SC-2 (structural) — carve-out present

`skills/skill-creator/SKILL.md` states that developer-directed edits carry
their own observed-failure evidence and authorization, and that the gate's
standards bind the written content while the proposal-time evidence hunt does
not re-run at instruction-execution time.

- **Verify:** read the card; both statements present.

### SC-3 (structural) — short-path reinforcement present

`skills/work/SKILL.md` states the short path is the default for single-file,
developer-specified changes and deviations require a stated reason.

- **Verify:** read the card; both statements present.

### SC-4 (behavioral) — developer-directed card edit completes without ceremony halt

An agent given a developer-directed single-rule card edit performs the edit
without admission archaeology and without halting for direction.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run with
  the card-edit fixture; clean-room evaluation of `session.yaml` confirms the
  edit lands without a halt-for-direction or an evidence hunt.

### SC-5 (behavioral) — short path taken for developer-specified single-file change

An agent given a developer-specified single-file change takes the short path.

- **Verify:** two-SC pattern — behavioral run; clean-room evaluation confirms
  no full-pipeline machinery beyond the short path.

## Out of scope

- Scripted ceremony detection or token budgets — intent-decidable; judgment
  decides.
- Changes to the admission gate's standards themselves — the gate's content
  requirements hold; only the execution-time application changes.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
