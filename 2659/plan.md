<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan — .opencode#2659 store-record repairs (GitBucket closing-keyword findings)

Spec: `.opencode/.issues/2659/spec.md` (validated PASS 2026-10-30, zero findings).
Measurement instrument: `.opencode/.issues/2658/research/closing-keyword-measurement.md` (§1, §2, §6).
All SCs structural — full-record reads plus targeted greps are the verification
instruments. Surfaces: `.issues/2615/plan.md`; `.issues/research-cards/gitbucket-closing-keyword-auto-close.md`
— both on the store's `issues-data` branch only.

## Item 1 — `.issues/2615/plan.md` empirical-step correction (SC-1 ← R-1)

**Deliverable.** Item 1 of the "Empirical steps" section (lines 11–14) is
rewritten in place to state: the outcome (HTTP 200, issue still `state: open`)
was recorded without the operation that produced it; the recorded outcome does
not discriminate between a close and a merge into a non-default branch; it
therefore establishes no platform fact; and the corrected platform finding —
GitBucket closes the same-repo `Closes #N` when the PR is merged into the
repository's default branch (GitBucket 4.48.0; `.opencode#2658` artifact §1).

**RED.** `grep -c 'Outcome: GitBucket has no closing-keyword auto-close' .issues/2615/plan.md`
returns ≥ 1, and the record contains no statement of the operation's absence —
the defective clause stands and the self-disclosure is missing.

**GREEN.** Replace the concluding clause with the epistemic self-disclosure and
the corrected finding (per spec R-1, citing the measurement artifact). Item 2
of the section and the rest of the record are untouched.

**Instrument.** Full read of `.issues/2615/plan.md`: the four R-1 statements
present, each grounded to the artifact; `grep -c 'Outcome: GitBucket has no
closing-keyword auto-close'` returns 0.

## Item 2 — research-card corrections (SC-2, SC-3, SC-4 ← R-2/R-3/R-4)

**Deliverable.** `.issues/research-cards/gitbucket-closing-keyword-auto-close.md`
retains its finding (§Finding) and 12-case empirical matrix in substance, and
carries four corrections in place:

a. **API-v3 claim (R-2a, R-3).** The "Consequences/Reproduce" text no longer
   claims the API v3 lacks PR create/merge endpoints; the reproduce section
   directs through the API v3 path (`POST /api/v3/repos/{owner}/{repo}/pulls`,
   `PUT /api/v3/repos/{owner}/{repo}/pulls/{n}/merge` — measured `{"merged":true}`,
   artifact §6), with no web-form premise.
b. **Default branch (R-2b, R-3).** The matrix header and any other
   default-branch statement name `main` (measured `"default_branch":"main"`,
   artifact §6), not `master`. The bare string `master` in upstream-source
   references (`gitbucket/gitbucket @ master`) is legitimate and untouched
   (SC-3 scoping).
c. **Cross-repo mechanism (R-2d, R-3).** The source-corroboration row states
   that a qualified `owner/repo#N` is rejected by the parser before the lookup
   (pattern requires whitespace immediately before `#` — discriminating probe,
   artifact §1); the repository-scoping lookup in `closeIssuesFromMessage`
   governs the bare form. Retains the row's correct conclusion (cross-repo
   form does not close).
d. **Provenance (R-4).** Provenance surfaces state the card was written by a
   prior session on 2026-10-23 and entered the store in commit `fcf67465`
   ("auto: create #.opencode#2658"); no statement attributes authorship to the
   #2615 implementation.

**RED.** Full read of the card against the spec §6 defect table: line 25
carries `master` as the default branch; line 55 attributes cross-repo
non-closure to the lookup; lines 98–100 carry the web-form directive and the
false endpoint claim; provenance (lines 3–4) carries no prior-session/fcf67465
statement. Each assertion fails today.

**GREEN.** In-place edits per (a)–(d), preserving the finding, matrix rows 1–12,
the colon boundary, the GitHub contrast section, the cross-repo-no-record note,
the consequences section, references, and confidence.

**Instrument.** Full read of the card: finding and 12-case matrix retained;
four corrections present; `grep -n 'master'` matches only upstream-source
references; `grep -cn 'no PR create/merge\|web form\|= `master`'` returns no
defect match; provenance carries `fcf67465` and the 2026-10-23 prior-session
authorship.

## Dependency order

Item 1 and Item 2 are independent — run in either order; both are store-record
edits on `issues-data`.

## Verification (post-implementation)

- SC-1..SC-4 instruments above, executed this session with captured output.
- Fresh-context `verify` PASS against `.opencode/.issues/2659/spec.md`.
- Store commits land on `issues-data` via sync; no deck-trunk surface touched.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)