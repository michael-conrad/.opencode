<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [REPAIR] Store records carrying the GitBucket closing-keyword findings — #2615 work record and the prior research card

Resolves `.opencode#2659`.

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | Two records in the `.opencode` issue store carry findings about the GitBucket closing-keyword question that are wrong, or wrong in a way that misleads a reader who follows them. **`.issues/2615/plan.md`** (item 1 of its "Empirical steps" section, lines 11–14) records the #2615 implementation's empirical step and its conclusion — *"PR body carried `Closes #1`; merge via API returned 200; issue stayed `state: open`. Outcome: GitBucket has no closing-keyword auto-close → cleanup class."* The record names no command, and its recorded outcome — HTTP 200 with the issue still open — is produced both by a close and by a merge into a non-default branch, so it does not discriminate between them; the record establishes no platform fact, yet a platform fact was concluded from it and written forward (it fed the false clause in `git-workflow-pr` §4 that `.opencode#2658` corrects). **`.issues/research-cards/gitbucket-closing-keyword-auto-close.md`** reaches the correct finding from a 12-case matrix with source corroboration, but carries three false or defective statements and one misattributed mechanism: it states the GitBucket API v3 "has no PR create/merge endpoint" (both exist and work — measured, artifact §6); it names `master` as the harness test repository's default branch (the measured default is `main` — `"default_branch":"main"` from the repo API, artifact §6); it directs the reader to merge "through the GitBucket web form" on that false premise, steering away from the API v3 path the rest of the deck's tooling uses; and its source-corroboration row attributes the cross-repo form's non-closure to the repository-scoping lookup in `IssuesService.closeIssuesFromMessage` — that lookup governs the **bare** form, while a qualified reference is rejected earlier, by the parser, because the pattern requires whitespace immediately before `#` (measured with a discriminating probe — artifact §1). |
| 2 | **Root Cause / Motivation** | (a) The #2615 empirical step was executed but its outcome was recorded without the operation that produced it; the outcome is nondiscriminating, and the record concluded a platform fact from it anyway. An indeterminate record cannot establish a platform fact (artifact §2). (b) The research card was authored in a prior session whose conclusion was right but whose four supporting statements were not; it was left uncommitted in the issues worktree and entered the store as a ride-along in the `.opencode#2658` creation commit (`fcf67465`) without the scrutiny its publication carries. (c) No store-side corrective record exists: the record defects were re-verified live on 2026-10-30 triage — both records still carry every defective clause, and neither has been touched since filing (`fcf67465` and `80c7ad97c` respectively are their latest commits). |
| 3 | **Approach Chosen** | Correct both records in place on the store's `issues-data` branch. The plan record states its own epistemic flaw and the corrected platform finding. The research card retains its finding and its 12-case empirical matrix — both correct — and is corrected in the four enumerated respects; the false API-v3 claim, the wrong default-branch name, the web-form directive, and the misattributed mechanism are removed rather than hedged. The card's provenance states its true authorship history. No card under `skills/` is touched: the deck-side correction is the separate spec `.opencode#2658`, and the two are separated because they land on different repository surfaces — the store's `issues-data` branch against the deck's trunk — and because a record's factual accuracy is a different concern from normative card prose. |
| 4 | **Key Design Decisions** | (1) **Repair in place, never rewrite** — the card's finding and matrix are correct and verified; a four-clause correction preserves the empirical content a rewrite would discard. (2) **The plan record self-discloses** — R-1 has the record state its own indeterminacy rather than silently replacing the outcome, so a reader tracing the #2615 implementation's reasoning sees where it fell short. (3) **Correction by measurement, not by deletion of prose alone** — the corrected statements carry the measured facts (`main`, the API v3 routes, the parser-level rejection) so the records end up self-sufficient on the platform question. (4) **Store-local only** — neither record is ever mirrored to the remote tracker, so the repair's blast radius is the `issues-data` branch alone. (5) **Provenance from git history, not recollection** — R-4's facts (`fcf67465`, 2026-10-23) are asserted from the store's own log and from artifact §6, both verified this session. |
| 5 | **User Intent / Original Prompt** | Filed 2026-10-23 as `[REPAIR]` — the store-record counterpart of the same-session deck-side correction `.opencode#2658`, per its own Scope statement (different repository surfaces; record accuracy vs normative card prose). Current session: the developer dispatched triage (verdict: valid, open, actionable — every defective clause re-verified live, no landing since filing) and then directed the triage findings revised into this spec; a store folder previously carried no `spec.md` while its remote body advertised the artifacts URL, and the body's structured summary (Problem/Scope/R-1–R-4/Impact) is the direct source of §§2–3 here. |

## 2. Scope

### 2.1 Affected surfaces

| Surface | Change |
|---|---|
| `.opencode/.issues/2615/plan.md` | Item 1 of the "Empirical steps" section corrected in place per R-1 |
| `.opencode/.issues/research-cards/gitbucket-closing-keyword-auto-close.md` | Four corrections in place per R-2; three false statements removed per R-3; provenance per R-4 |

Both edits land on the store's `issues-data` branch (via the store's own tooling and `sync`), never on the deck's trunk.

### 2.2 Surfaces deliberately untouched

- **Deck cards** — `skills/` is `.opencode#2658`'s surface; the false clause in `git-workflow-pr` §4 ("GitBucket has no closing-keyword auto-close — cleanup performs closure there", still live as of this session) is corrected there, not here.
- **The remote tracker** — the two records are store-local and are never mirrored to GitHub; the issue's remote body carries its own structured summary and needs no edit from this repair.
- **`.opencode#2615`'s ticket state** — the ticket was closed `completed` on 2026-10-15 and stays closed; repairing its work record's factual content is not a ticket-state change.
- **The #2658 measurement** — no re-measurement, no re-derivation; `.opencode#2658`'s research artifact is this repair's instrument, cited from.
- **GitBucket itself, the harness, tests-v2, and any other store record** — untouched; no new gate, workflow, or test.

### 2.3 Impact

Consumers: agents reading the store's records to establish GitBucket's platform behaviour — both records are cited destinations for exactly that question (the research card is a top-level `research-cards/` entry; the #2615 record is the provenance anchor `.opencode#2658`'s spec points at); and the deck-governance record of how the platform fact was established. The false clause in `git-workflow-pr` §4 that the #2615 record helped produce is corrected by `.opencode#2658`; this repair removes the two store records that would otherwise re-derive it.

Blast radius: two store records, no card, no code, no test surface, no runtime behaviour change of any kind.

## 3. Requirements

- **R-1** — The `.issues/2615/plan.md` record SHALL state that it recorded an outcome (HTTP 200, issue still open) without recording the operation that produced it; that the recorded outcome does not discriminate between a close and a merge into a non-default branch; and that it therefore establishes no platform fact — together with the corrected platform finding: GitBucket closes the same-repo `Closes #N` when the pull request is merged into the repository's default branch (measured on GitBucket 4.48.0; `.opencode#2658` artifact §1).
- **R-2** — The research card SHALL retain its finding and its 12-case empirical matrix, both of which are correct, and SHALL be corrected in four respects: (a) the API-v3 endpoint claim; (b) the default-branch name; (c) the web-form directive, replaced with the API v3 path the card then acknowledges exists; (d) the source-corroboration row's mechanism for the cross-repo form, which the parser rejects before the lookup is reached.
- **R-3** — Neither record SHALL retain a statement that the GitBucket API v3 lacks a pull-request create or merge endpoint, that the harness test repository's default branch is `master`, or that the cross-repo form's non-closure is a repository-scoping effect.
- **R-4** — The research card's provenance SHALL state that it was written by a prior session on 2026-10-23 and entered the store in commit `fcf67465` ("auto: create #.opencode#2658"), rather than implying it was authored as part of the #2615 implementation.

## 4. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The plan record's empirical-step item states the outcome was recorded without the producing operation, that the outcome does not discriminate between a close and a non-default-branch merge, that it therefore establishes no platform fact, and states the corrected platform finding (same-repo form closes at default-branch merge) | structural | Full read of `.opencode/.issues/2615/plan.md`; assert the four statements are present and that the concluding clause "*Outcome: GitBucket has no closing-keyword auto-close → cleanup class.*" is absent from the record |
| SC-2 | The research card retains its finding and 12-case matrix in substance and carries all four corrections: the API v3 create and merge endpoints stated as existing and working; `main` as the harness test repository's default branch; a reproduce section directing to the API v3 path with no web-form premise; a source-corroboration row that states the parser-level rejection for the qualified form (whitespace immediately before `#`) while retaining the repository-scoping lookup as the bare-form mechanism | structural | Full read of `.opencode/.issues/research-cards/gitbucket-closing-keyword-auto-close.md`; assert the finding and matrix are preserved and the four corrections are each present |
| SC-3 | Neither record retains any of the three false statements: that the GitBucket API v3 lacks a PR create or merge endpoint, that the harness test repository's default branch is `master`, or that the cross-repo form's non-closure is produced by the repository-scoping lookup | structural | Full read of both records; assert each of the three statements is absent — the `master` check is scoped to the harness default-branch claim, not to the bare string (upstream-repo references to `gitbucket/gitbucket @ master` are legitimate and are not defects) |
| SC-4 | The research card's provenance states the prior-session authorship dated 2026-10-23 and the store-entry commit `fcf67465`, and no statement attributes the card's authorship to the #2615 implementation | structural | Full read of the card's provenance surfaces (SPDX/provenance header and any authorship statement); assert both facts are present and the implied-#2615-authorship is absent |

**Traceability.** SC-1↔R-1, SC-2↔R-2, SC-3↔R-3, SC-4↔R-4 — one criterion per requirement, none orphaned, no requirement untested.

**Causal sufficiency.** Every requirement answers to a root cause stated in §1.2: R-1 to the nondiscriminating outcome that concluded a platform fact; R-2 and R-3 to the four defective clauses in the card; R-4 to the card's unscrutinized entry into the store. The retained matrix (R-2's first clause) and the store-local-only boundary (§2.2) preserve what measurement already validated, so no corrected record loses verified content.

## 5. Out of Scope

- `skills/` and every deck surface — corrected by `.opencode#2658`.
- The remote tracker's bodies for #2615 and for this issue — the records and the card live only in the store.
- `.opencode#2615`'s ticket state.
- Re-measurement or re-derivation of the GitBucket behaviour — `.opencode#2658`'s research artifact is the instrument.
- Any change to GitBucket, the harness, tests-v2, or any other store record.
- Any new gate, workflow, or test.

## 6. Evidence and its location

The measurement lives in `.opencode#2658`'s research artifact — [closing-keyword-measurement.md](../2658/research/closing-keyword-measurement.md) — not in this spec: §1 carries the GitBucket 4.48.0 behaviour matrix and the source reading including the parser-vs-lookup mechanism (the discriminating probe that shows a qualified reference is rejected by the parser before the lookup is reached); §2 reproduces the #2615 probe's recorded outcome by an operation the record did not name, establishing the record's indeterminacy; §6 reconciles this spec's two target records and carries the two measured corrections (API v3 endpoints; `"default_branch":"main"`). This spec cites it; it does not restate it.

The basis for the two record defects is the records themselves, quoted so the spec stands alone:

| Record | The current, defective text |
|---|---|
| `.issues/2615/plan.md` (lines 11–14) | *"PR body carried `Closes #1`; merge via API returned 200; issue stayed `state: open`. **Outcome: GitBucket has no closing-keyword auto-close → cleanup class.**"* |
| Research card (line 25) | *"Empirical matrix (all cases: base branch = repo default branch = `master`)"* |
| Research card (line 55) | *"`closeIssuesFromMessage` → ... same repository only, so a qualified `owner/repo#N` never resolves"* |
| Research card (lines 98–100) | *"the merge must go through the GitBucket web form (the API v3 has no PR create/merge endpoint)"* |

Store history facts, verified this session from the store's own log: the research card's only commit is `fcf67465` (message "auto: create #.opencode#2658"); the plan record's last commit is `80c7ad97c` ("2615: plan + empirical outcomes"); no repair has landed on either since this issue's filing on 2026-10-23 — triage on 2026-10-30 re-verified every quoted clause live.

## 7. Provenance

- Spec: `.opencode/.issues/2659/spec.md`.
- Remote issue: https://github.com/michael-conrad/.opencode/issues/2659
- Deck-side companion spec (the `skills/` surface): `.opencode#2658` — `.opencode/.issues/2658/spec.md`.
- Measurement artifact: `.opencode/.issues/2658/research/closing-keyword-measurement.md`.
- Repaired records: `.opencode/.issues/2615/plan.md`; `.opencode/.issues/research-cards/gitbucket-closing-keyword-auto-close.md`.
- Store-entry commit for the research card: `fcf67465` (2026-10-23); last commit on the plan record: `80c7ad97c` (2026-10-14 era).
- Deck claim the #2615 record fed: `skills/git-workflow-pr/SKILL.md` §4 — corrected by `.opencode#2658`.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)