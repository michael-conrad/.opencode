<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored; plan for michael-conrad/.opencode#2681, derived from .opencode/.issues/2681/spec.md -->

# Plan — Issues-data hygiene: repair in place, not ticketed (.opencode#2681)

Spec: `.opencode/.issues/2681/spec.md`. Every item traces to a spec SC; no extras.

## Item 1 — Store repair (SC-1, SC-2 → R-1)

- **Deliverable:** all 273 invalid-YAML files in the `.opencode/.issues` store
  parse-valid; `local-issues validate-yaml` (cwd = `.opencode`) exits 0 with
  zero `invalid-yaml` lines. Changes ride the store's `issues-data` branch via
  the store's tooling (`local-issues` + its sync), never the feature branch.
- **Baseline (RED):** executed `./tools/local-issues validate-yaml` from the
  `.opencode` root — exit 1, 273 `invalid-yaml` lines
  (population classes: ScannerError 175, ParserError 70, ReaderError 17,
  ComposerError 11; verified 2026-10-28).
- **GREEN:** per-file minimal validity repair, one of:
  (a) quote/escape the specific invalid token; (b) de-duplicate YAML keys by
  keeping the last occurrence when values are identical or the last is a
  supersede; (c) replace ANSI/control-character debris (engine/terminal dumps
  saved as `.yaml`) with a minimal valid representation of the preserved
  content; (d) wrap malformed legacy tab-indented prose as a YAML block scalar
  preserving the original text. Each ambiguous choice (validity admits more
  than one reading) is logged to `.opencode/.issues/2681/research/repair-log.md`
  (file, chosen reading, ground) **before** the store sync.
- **Instrument:** re-run the validator (exit 0, zero lines); the hygiene
  commits' diff reviewed against the repair log (fresh-context review, SC-2).

## Item 2 — Record reconciliation (SC-7 → R-4)

- **Deliverable:** #2681 title, labels, body identical across the GitHub
  tracker and the local store; body states the corrected fact base
  (273-file store population; the filing's 2-file counting named as
  non-reproducible damage, not output); remote body ends with a resolvable
  artifacts pointer to `.opencode/.issues/2681/`; `spec.md` remains
  store-authoritative; `needs-approval` label removed (repair class is
  authorization-free).
- **Instrument:** read-back of both surfaces; `gh issue view` + local
  `local-issues read` comparison.

## Item 3 — Deck rule text: remediation-first clause (SC-3 → R-2)

- **Deliverable:** `skills/git-workflow-pr/SKILL.md` (pre-create checklist b)
  and `skills/implement/references/implementation-workflow.md` (suite-green
  gate row) each carry the issues-data remediation-first clause: a failure
  whose remedy is issue-store hygiene is repaired in place in the same
  session by the producing agent; implementation-remedy failures keep the
  filed-fix-issue route. Deck edits pass the `skill-creator` admission gate.
- **RED:** `grep` on both paths finds no "issue-store hygiene" /
  remediation-first clause; dependent contract suites (SC-9) still green.
- **Instrument:** grep + read-back on both files confirming actor, class, and
  boundary; admission-gate run per `skill-creator`.

## Item 4 — Floor issues-data exception (SC-4 → R-3)

- **Deliverable:** `floor.md` scope doctrine names the exception — store-guided
  operations on the `issues-data` branch via the store's tooling are
  agent-owned workspace maintenance, outside the read-only default and the
  dispatch scope-bound, no scope-bearing token; bounded to issue-store data.
  Floor edit retains whole-card writing-discipline conformance (#2664/#2665).
- **RED:** `floor.md` contains no "issues-data" exception text.
- **Instrument:** grep + read-back; the floor's full normative prose re-read
  for tone/conformance after the edit.

## Item 5 — Behavioral scenarios (SC-5, SC-6 → R-5)

- **Deliverable:** under `tests-v2/behaviors/`: scenario (a) reproduces the
  observed failure — PR-prep session with a `validate-yaml` exit-1 gate → the
  agent repairs the store in place and files no disposition ticket; scenario
  (b) the boundary — an implementation-remedy failure still routes to a filed
  disposition and blocks the gate. RED/GREEN per the `behavioral-testing`
  card through the harness (`with-test-home` + `behavior_run`, clean-room
  evaluation).
- **RED:** scenario (a) fails against un-amended surfaces (agent tickets
  instead of repairs); scenario (b) fails if the carve-out is written so broad
  it swallows implementation-remedy failures.
- **Instrument:** harness-executed scenarios; artifact + clean-room eval
  captured under `tests-v2/output/`.

## Item 6 — Dependent structural suites (SC-9)

- **Deliverable:** `tests-v2/test-cleanroom-eval-contract.sh`,
  `tests-v2/test-skill-deck-completeness.sh`, `tests-v2/test-trunk-hook.sh`
  all green after the rule-text changes.
- **Instrument:** executed scripts, captured output.

## Item 7 — No-mechanism check (SC-8)

- **Deliverable:** none (verification-only). The change's file list vs base
  tip adds/modifies nothing under `tools/`, `hooks/`, `plugins/`, and no
  script outside the `tests-v2/` scenario set.
- **Instrument:** `git diff --stat` against base tip a9c65ec46, path-filtered.

## Order

1 → 2 → 3 → 4 → 5 → 6 → 7. Items 1–4 are structural, sequenced so this
change's own PR checklist meets a genuinely green `validate-yaml` gate before
verification; item 5 is behavioral RED/GREEN after the surfaces it tests are
amended; item 6 re-validates dependent contracts last; item 7 closes.