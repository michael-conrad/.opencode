# SPEC: GitBucket label/body REST deviations documented; post-create remote-body reconciliation routes in place (never comments)

## 1. Intent and executive summary

**Problem Statement.** Two rules-bearing gaps exist in the live deck around GitBucket-backed issue stores. First, the live `.opencode/skills/gb-cli/SKILL.md` documents the label-route deviation set incompletely and the issue-body edit route not at all: the card carries the plain-issue `PATCH .../issues/{n}` → 404 state-mutation gap and the working object-form PUT label route (rule 4, evidenced 2026-11-18), but an agent following GitHub-standard patterns still has no documentation for the label forms that silently destroy all existing labels (raw-array body) or are rejected with HTTP 500 (object-form POST), no read-back-after-write guidance, and no pointer from the body-route gap to the working `gb issue edit` fallback. Second, the issues/spec filing flow names no correction route for the filed remote body: the number-dependent artifacts pointer (`tree/issues-data/{N}`) is unknowable pre-create, and GitBucket assigns numbers from its internal sequence while skipping consumed numbers (observed 2026-11-20: predicted 17, assigned 20), so the filed pointer can be unresolvable — and agents have routed the correction and its spec-content reconciliation into tracker comments — the violation the deck's self-containment rules prohibit (spec card rule 6, self-containment normative; issues card §3, "Spec and plan corrections always edit the artifact in place — never route to comments"; originating record `.opencode#2522`).

**Root Cause / Motivation.** The pre-rip deck carried the working routes — attic `issue-operations-core/tasks/body-edit.md:170` documents `gb issue edit <number> ... --body` — and the `.opencode#2490` deck rewrite dropped that guidance from the live gb-cli card. The moot closure of `.opencode#2331` at the time judged the filed defect gone because the defective old-format cards were removed, but the rewrite never re-carried the required guidance either. An agent that has not read a documented route cannot attempt it: in the observed 2026-11-20 failure, the agent — with gb-cli rule 7 (attempt-first) already live — generalized its label-route 404 into a fabricated "GitBucket body edit is unavailable" claim and routed its spec corrections into two tracker comments, while `gb issue edit <N> --body` completed successfully through the web fallback moments later (verbatim trail mirrored in `.opencode/.issues/2761/`). Attempt-first stops fabricated evidence; it presumes the agent knows which command exists. Documentation is what names the command.

**Approach Chosen.** Documentation-only. Restore the deviation and safe-pattern documentation in the live gb-cli card, and name the post-create reconciliation route — in-place platform-native issue-body edit, never comments — in the live issues card's creation/reconciliation flow. No gb CLI source changes, no GitBucket server changes.

**Alternatives Considered & Why Discarded.**
- Rely on gb-cli rule 7's attempt-first rule alone — rejected: the 2026-11-20 regression occurred with rule 7 already live in the deck; rule 7 prevents unfounded conclusions but does not name the working command, and the failure ran anyway.
- Modify the gb CLI to support GitBucket REST `PATCH` — rejected: external dependency, out of the original `.opencode#2331` (2026-10-05) scope ruling.
- Adopt a comment-based convention for pointer-miss corrections — rejected: violates the comment gate and the self-containment rules of `.opencode#2522`, and splits spec content across the body and comments.

**Key Design Decisions.**
- Labels mutate exclusively via object-form PUT (`{"labels": [...]}`) through the `gb api` passthrough, with read-back after every mutation. Tradeoff: one sanctioned form instead of enumerating forms agents may otherwise try; the web fallback's label editing is evidenced failing (2026-10-05, tomcat-0002.newsrx.com).
- Body edits use the native `gb issue edit <N> -b/--body` command whose web fallback is an agent-runnable, non-interactive success path under stored token credentials; REST `PATCH` is not relied on anywhere for GitBucket body edits (404 evidenced on both observed instances).
- The reconciliation route is stated once in the issues card's flow with references at the other named sites (single sourcing); GitBucket fallback specifics live only in the gb-cli card.

**User Intent / Original Prompt.**
- 2026-10-05, record `.opencode#2331` (filing agent byline `opencode/x-preview-f-free`): "The `gb-cli` and `gitbucket-api` platform skill decks omit two GitBucket REST deviations from GitHub-standard behavior." Scope: "Document both deviations (payload-form table, exact HTTP outcomes, severity) in `.opencode/skills/gb-cli/SKILL.md` and `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`"; "Document the safe patterns below wherever GitBucket label/body mutation is described"; "Add readback-after-write guidance for any GitBucket label mutation."
- 2026-11-20, record `.opencode#2761`: "The gb-cli card does not document the issue body-edit route (`gb issue edit` — title/body/labels/assignees) for GitBucket, and the issues/spec flow gives the agent no post-create reconciliation path after the body's number-dependent artifacts pointer misses the assigned number." Expected behavior: "The issues/spec flow routes post-create reconciliation (pointer-miss body fixes, spec-correction reconciliation) through **in-place** `gb issue edit --body` — never comments."
- Routed requirement: the 2026-11-20 report was triaged 2026-11-20 and its requirement routed into this record in place per the spec card's search-before-filing mandate; its report text is mirrored at `.opencode/.issues/2761/`. The historical second documentation target named by the 2026-10-05 scope (`.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`) exists in the live deck only under `attic/`; live-card targets are named in R-1 through R-3 below.

## 2. Not Included

- gb CLI binary/source changes — external dependency; the CLI's web fallback is the sanctioned surface.
- GitBucket server-side changes.
- Re-examining `.opencode#2257`'s local-test-instance label findings.
- gh-cli card content changes — the GitHub-native routes are unchanged (the issues-card route wording in R-4 is platform-neutral and covers GitHub without a gh-cli edit).
- Anything beyond documentation (deck cards only; no tool or server code).
- The historical `issue-operations/platforms/gitbucket-api` card — not a live-deck path; not retro-converted.

## 3. Requirements

- **R-1** The gb-cli card SHALL complete its label-route deviation set for the outcomes its rule 4 does not yet carry: object-form POST (`{"labels": [...]}`) rejected with HTTP 500; raw-array body (`["label-a", ...]`) silently wiping all existing labels; and read-back-after-write guidance for every GitBucket label mutation — with the already-documented object-form PUT route (rule 4, via the `gb api` passthrough) carried as the sanctioned form these deviations complete.
- **R-2** The gb-cli card SHALL extend its documented `PATCH .../issues/{n}` → 404 gap to the body case and name the working route: `gb issue edit <N>` with `-t/--title`/`-b/--body` is the sanctioned body-edit route whose web fallback ("REST issue edit is unavailable on this GitBucket instance; using web fallback") is an agent-runnable, non-interactive success path under stored token credentials.
- **R-3** The gb-cli card SHALL NOT present `gb issue edit`'s label/assignee flags as a working label-mutation path; labels mutate per R-1 (label editing via the web fallback is evidenced failing 2026-10-05 and remains an attempt-first subject per gb-cli rule 7 on instances without evidence).
- **R-4** The issues card's creation/reconciliation flow SHALL route post-create remote-body reconciliation — both an unresolvable artifacts-pointer correction and post-filing spec-body reconciliation — through the platform's native in-place issue-body edit (`gh issue edit` / `gb issue edit --body`), never through comments, with the route stated once at the flow's owner section and referenced at the pointer-mandate site and the mirror-repair site.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | The live `.opencode/skills/gb-cli/SKILL.md` contains the R-1 deviation documentation: the object-POST → HTTP 500 statement, the raw-array wipe hazard, and read-back-after-write guidance, present as card content at the rule carrying GitBucket label mutation. | structural | `grep -n` the card file for each content element (a `500`-rejection statement, the raw-array wipe hazard, read-back wording); every element hits, misses enumerated |
| SC-2 | The live `.opencode/skills/gb-cli/SKILL.md` contains the R-2 body-route documentation: `gb issue edit` named as the sanctioned body (and title) edit route, the documented PATCH-404 gap extended to the body case, and the web-fallback wording presented as the agent-runnable success path. | structural | `grep -n` the card for `gb issue edit`, the body-case PATCH-404 wording, and the web-fallback wording; all three hit |
| SC-3 | The live `.opencode/skills/gb-cli/SKILL.md` nowhere presents `gb issue edit`'s label/assignee flags as a working label-mutation path. | structural | `grep -n` the card for label-flag capability claims (`--add-label`, `add-assignee` capability wording); every hit is within the R-1/R-3 deviation statement or absent |
| SC-4 | The live `.opencode/skills/issues/SKILL.md` routes post-create remote-body reconciliation through an in-place native issue-body edit and states corrections never route through comments, with the statement present at the flow's owner section and referenced at the pointer-mandate site and the mirror-repair site. | structural | `grep -n` the issues card at the creation-rule and mirror-repair regions for the route naming (`issue edit`, in-place wording, comments prohibition); all named sites hit |
| SC-5 | An agent run following the documented flow corrects a pointer-miss filed remote body in place — exactly one issue-body edit on a GitBucket-backed store whose tracker-assigned number differs from the predicted number — and posts zero tracker comment writes carrying correction or spec-reconciliation content. | behavioral | `opencode run` behavioral scenario (tests-v2 harness with a provisioned GitBucket container): file an issue whose internal-sequence number skips the predicted value, then exercise the documented reconciliation; assert one in-place body edit and zero comment writes |

## 5. Dependencies

| Reference | Relationship | Status |
|---|---|---|
| gb-cli rule 7 (attempt-first) | The documented routes compose with rule 7; rule 7 itself is unchanged by this work. | Satisfied (in the live card) |
| Remote-body-format reference (`.opencode/skills/spec/references/remote-body-format.md`) | Owns the artifacts-pointer mandate R-4's repair route fixes; the reference itself is unchanged. | Satisfied (exists in the live deck) |
| gb CLI web fallback capability | External dependency the documentation describes; evidenced working for body edits. | Satisfied (evidenced 2026-11-20; 2026-10-05) |

## 6. Traceability

| Requirement | SCs |
|---|---|
| R-1 | SC-1 |
| R-2 | SC-2 |
| R-3 | SC-3 |
| R-4 | SC-4, SC-5 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| `.opencode#2331` original record | issue-store record | `.opencode/.issues/2331/` (issue.yaml body) and this record's git history | read 2026-11-20; local and remote bodies byte-faithful at write time |
| `.opencode#2761` record | issue-store record (mirror of remote) | `.opencode/.issues/2761/` | fetched from the remote tracker 2026-11-20 |
| `gb issue edit` help text and success trail | verbatim session transcript | quoted in the `.opencode#2761` record | dated transcript 2026-11-20 ~14:52 EST (gitbucket.newsrx.com, jwktl-newsrx#20); not re-executed in this session (no GitBucket instance here) |
| Pre-rip body-edit guidance | deck attic file | `.opencode/attic/skills/issue-operations-core/tasks/body-edit.md:170` | read 2026-11-20 |
| Live gb-cli card | deck file | `.opencode/skills/gb-cli/SKILL.md` | read 2026-11-20; no `gb issue edit` occurrence (absence verified) |
| Live issues card | deck file | `.opencode/skills/issues/SKILL.md` | read 2026-11-20; pointer mandate, comment gate, and mirror-repair wording confirmed in place |
| Label-route PUT evidence | live evidence cited in the gb-cli card | gb-cli rule 4, dated 2026-11-18 (NewSRX-Tech-LLC/CrossrefAbstracts#78) | cited, not re-executed in this session |

## 8. Cost Frame

- SC-1..SC-4: text checks cost seconds each; skipping leaves silently destructive label guidance absent and undocumented dead ends that stall mid-flight flows (each observed instance produced tracker cleanup and reconciliation work).
- SC-5: a harness scenario costs one run plus a provisioned GitBucket container; skipping risks re-manifestation of the flow defect, already observed once after its governing rules existed.

## 9. Edge Cases

| Condition | Expected behavior |
|---|---|
| GitBucket instance variation (different deployments show different REST availability) | The card's deviation statements carry their dated instance evidence; un-evidenced sibling endpoints remain attempt-first subjects under gb-cli rule 7 — the documentation states the evidenced position, never a blanket platform denial |
| `gb issue edit` label flags used on an instance without label-fallback evidence | The agent attempts the flags and reports only the evidenced result (rule 7); label state restoration, if needed, routes through the R-1 object-form PUT path |
| Non-interactive shells (no tty) | The web fallback completes non-interactively under stored token credentials (evidenced 2026-11-06 for PR edits; 2026-11-20 for issue edits); the card's wording never presents the fallback as a developer handoff |
| GitHub-side filings (no numbers skipped) | R-4's route is platform-neutral; the pointer-miss class remains GitBucket-structural, and the route wording covers GitHub's native `gh issue edit` without change |
| Concurrent local label state (local `issue.yaml` canonical while remote labels are mutated) | Read-back-after-write (R-1) keeps the agent's view of remote label state true before any dependent step |

## 10. Completion gate

Every success criterion passes before the deliverable is complete; partial implementation is not permitted.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
