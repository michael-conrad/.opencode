---
research_question: "Why do specs keep carrying performative byte-exact / toolchain-guarantee SCs, and what governs SC subject matter in the live deck?"
confidence: 0.85
status: resolved
tags:
  - success-criteria
  - verification-instruments
  - false-targets
  - spec-card-gap
  - deck-restructure-loss
created: 2026-11-04
last_updated: 2026-11-04
---

## Summary

Developer-reported defect (2026-11-04 session): SCs keep targeting byte-exact
matches and build-tool guarantees ("if gradle is doing its job") instead of
behavior or content. Research found the defect genus is real and recurring in
both issue stores; the live deck's `spec` card invites it (rule 3 constrains
*how* an SC is checked, never *what* may be checked); the one prior ruling on
numerical false targets (.opencode#2411) retired to `attic/` during the deck
restructure and only ever covered reduction thresholds, not byte-identity
guards; the validation standards name the defect class but never fired on it
in practice; and the `implement` card holds the correct rule for *tests*
(offender classes a/b/c) while nothing equivalent governs *SC authoring*.

Developer's stated rule (2026-11-04): SCs target behavior or content — never
byte-exact matches as such, never what the build system already guarantees.

## Findings

### 1. Defect population

35 tickets in the deck store (`.opencode/.issues/`) carry byte-identical /
byte-exact language; bursts: #2304 (29 hits), #2306 (27), #2251 (22), #2346
(19), #2460 (18), #2458 (14). Still present in recent work: #2660, #2649,
#2665, #2667, #2681. Root store (`.issues/`) is mild (#117, #374, #300).

### 2. Classification — legitimate vs performative (each read in context)

Legitimate: byte-exactness IS the stated requirement, or guards a file the
change itself edits:

- #2346 SC-1b — safety-critical `critical-rules-XXX` blocks preserved during
  condensation of the same file.
- #2304 SC-3 — git enforcement commands untouched by a prose sweep of the
  same file.
- #2660 — "preserved passages byte-identical": preservation is the
  deliverable.
- #2643 — archive-move content preservation (before/after store-tree
  manifest).
- #374 SC-7 (root store) — point-in-time historical records stay untouched.

Performative classes observed:

- Toolchain-guarantee SC: #2097 SC-11 / #300 SC-11 — "TypeScript compiles
  without errors" (`tsc --noEmit`). The compiler's job, not the deliverable's.
- Scope-restatement guard: #2618 SC-4 — `floor.md`/`routing.md` byte-identical
  when the change never touches them; the scoped diff already states this.
- Untouched read-target guard: #2444 — "canonical documents byte-identical
  before/after" for files the change only reads.
- Manufactured RED: #2460 Item 5 — "RED: field-diff check fails against a
  deliberately mutated fixture (test validates its own sensitivity)" —
  mutate-then-unmutate theater.
- Byte-equality as drift control: #2458 SC-3 (six-card identical inlining) —
  explicitly retired by #2618 NREQ-3 as a "retired old-deck mechanism",
  replaced by link integrity.
- Count-threshold targets: #2347 SC-8 and the condensation family — already
  ruled false targets by #2411.

### 3. Validators never fire on it

#2643 `audit/validation.yaml` defends the "byte-identical manifest" shorthand
as "the only capable reading". #2660 `audit/validation.yaml` spends judgment
adjudicating a one-space soft-wrap delta under a byte-exact requirement
("rendering-identical under the churn rule") — the performative cost surfaces
at review time instead of being caught at authoring time.
`skills/spec/references/validation-standards.md` finding 5 (incapable
instrument: "matching a pattern cannot verify that meaning was conveyed") and
finding 7 (trivially-true restatement) name this genus — but in practice
passed these SCs.

### 4. Root cause: subject-matter gap in SC-authoring guidance

- `skills/spec/SKILL.md` rule 3: "behavioral SCs get a runtime verification
  instrument; structural SCs get a fact-decidable check" — constrains how,
  never what. "Fact-decidable" reads as grep/diff/byte-equality: the easiest
  check to make decidable is the wrong one to make meaningful.
- `skills/implement/SKILL.md` rule 7 has the right rule for tests: "Never
  test an artifact the build system already guarantees", with offender
  classes (a) source-content inspection ("does this file contain this
  string"), (b) environment/framework re-read tautologies, (c)
  assertion-shaped placeholders. No equivalent governs SC writing in the
  spec card, so the performative SC is authored upstream and flows into
  plans and tests.
- #2411's false-target rule is dead letter: its anchors
  (`reference/spec-structure-standards.md`,
  `skills/audit/tasks/spec-audit-evaluator.md`) retired to `attic/` in the
  deck restructure; the live deck carries no successor. It never covered
  byte-identity guards — only reduction thresholds.
- Store precedent supplies the mimicry template: the agent reads prior specs
  in the catalogue and copies the byte-identical guard pattern forward.

### 5. Where byte-exactness stays legitimate

Byte-exactness is a valid instrument only where identity/preservation is the
stated requirement itself: guards on sections of a file the same change
edits, point-in-time records, content-preservation moves. It is never a
target, never a scope restatement, never manufactured RED, and never a
substitute for a behavioral or content criterion.

## Gaps

- Long tail not individually read: the classification covers the burst
  tickets and named SCs; the 35-ticket population was not exhaustively read.
- Gradle-worded SC instances not found in either store; the toolchain class
  is evidenced by the tsc instances (#2097, #300) plus the developer's
  phrasing and the implement card's offender class (b).
- Remediation design (where the subject-matter rule anchors: spec card
  rule 3, validation-standards, or both) is deck governance, out of research
  scope.

## Sources

All paths in-repo (`/home/muksihs/git/opencode-config`), read 2026-11-04:
`.opencode/skills/spec/SKILL.md`,
`.opencode/skills/spec/references/validation-standards.md`,
`.opencode/skills/implement/SKILL.md`,
`.opencode/attic/reference/spec-structure-standards.md`,
`.opencode/attic/skills/audit/tasks/spec-audit-evaluator.md`,
`.opencode/CHANGELOG.md` (#2411 entry), named tickets' `spec.md` /
`audit/validation.yaml` in `.opencode/.issues/` and `.issues/`.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
