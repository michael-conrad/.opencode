# .opencode#2643 — legacy-format warning fires permanently on removable open/closed residue — offer a remediation affordance

## Problem

Every `local-issues` invocation reaches the legacy-format residue check except `doctor`/`validate-yaml` (source: `main()` gates `_check_legacy_formats` at the dispatch, ~lines 2665–2669), and the check prints for a store carrying legacy residue — `open/`, `closed/`, or `{N}-slug` directories — "Warning: Legacy issue directory format detected in .issues/. ... AI agent must inspect and remediate manually."

Filing evidence (hermes-ingest-pubmed, filed 2026-10-19): the warning fired on every create/read/close/sync call while store `.issues/open/` held three contentless legacy stub records (`003-sub-15-phase-1-ingest-stream`, `004-sub-15-phase-2-ingest-qoc`, `005-sub-15-phase-3-ingest-db` — YAML metadata only, empty bodies, `github_issue: null`, superseded long ago by #15's closed current-format record) plus an empty `closed/`; `doctor` reported HEALTHY throughout (its health markers cover branch/worktree state, not residue). The warning was therefore permanent, non-actionable noise: it repeated on every invocation while the tool offered no mechanic to act on the residue it detected — remediation required a hand-rolled git operation against the store's `issues-data` worktree (git rm of `open/` contents, rmdir of `closed/`, commit + push).

Root causes:

1. **Detector without an actor.** The residue check detects and instructs manual remediation of state the tool itself owns — the tool already drives the store's git operations (mutation commands auto-commit and push the `issues-data` branch through `_auto_commit`, ~line 1168).
2. **Unstructured manual path.** Each warning repetition directs an agent into bespoke git against an orphan-branch worktree — the exact hazard the deck's store tooling exists to remove; the tool also already owns the safe primitives for such work (`_parse_number` semantics with C6 duplicate-guard honoring legacy `{N}-slug` collision twins, and the sanctioned unflagged `_legacy/` archive name).

Developer's stated requirements (the filing): (1) the tool should offer a remediation affordance for the residue it detects; (2) fallback floor: at minimum, the warning should not repeat on every invocation for a store whose current-format records are all healthy.

## Scope

One change surface: `.opencode/tools/local-issues` — a new mutation command in the tool's existing command family, reusing the tool's residue predicates (`_check_legacy_formats` condition set), `_parse_number` semantics, the sanctioned `_legacy/` archive location, and the standing mutation contract (`_auto_commit` commit + push; worktree bootstrap-and-fail-fatal discipline). No new third-party dependencies; no deck/card content, no remote-tracker API surface, no CI, no other tool behavior beyond the preserved-constraint guard (R-3) and the warning text's directive (R-6).

## Requirements

- **R-1.** The tool SHALL provide a `remediate-legacy` mutation command that, in the store the invocation targets (the tool's standing store-resolution semantics — the CWD-relative `.issues/` directory), removes residue items it verifies removability of, and the legacy scaffolding directories (`open/`, `closed/`, `{N}-slug` directories) once emptied. A residue item is verifiable removability when the record carries no content beyond its YAML metadata block (empty spec/body content) and its `github_issue` field is `null` (it tracks no remote issue) — the removal then loses no store content. The operation is recorded by a commit on the `issues-data` branch through the tool's standing mutation contract (auto-commit + push on an active worktree; fail-fatal rather than plain-file mutation when worktree establishment fails).
- **R-2.** The `remediate-legacy` command SHALL preserve — never remove — every residue item whose removability verification fails (content-bearing or remote-referencing), by moving the item's directory intact (byte-identical content) under the store's `_legacy/` archive directory.
- **R-3.** The legacy-format warning's firing behavior SHALL be preserved: it fires exactly when the store carries residue per the existing predicates and is silent on conforming stores and on `_legacy/`; the change SHALL introduce no warning-suppression state (no sentinel, timestamp, or repeat-counting file) — repetition until the residue is remediated is the preserved signal (#2548 C5's muting-sentinel lesson).
- **R-4.** After a successful `remediate-legacy` run over a residue store (removals and/or archive-moves recorded), subsequent `local-issues` invocations against that store emit no legacy-format warning — the filing's fallback floor, delivered through removal of the residue rather than muting of the warning.
- **R-5.** The `remediate-legacy` command SHALL support `--dry-run`: it reports, for every residue item, the action it would take (remove / preserve-by-move, with the reason) and mutates nothing — no store path change, no commit.
- **R-6.** The legacy-format warning's text SHALL name the tool's `remediate-legacy` command as the remediation path — the directive in the warning resolves to the tool's own affordance at every occurrence.

## Impact

- **Consumers:** every agent operating a local issue store — the deck ships `local-issues` to every mount; root and submodule repos' store workflows (create/read/close/sync sequences currently print the warning on residue-bearing stores).
- **Risk:** the removal path is destructive on store data — mitigated by verify-first routing (R-1's removability check), preserved-by-archive for anything failing it (R-2), a preview mode (R-5), and the recorded commit as the rollback path (SC-1).
- **Blast radius:** one source file (`.opencode/tools/local-issues`) — a new command, the reuse of existing predicates/primitives, and R-6's warning-text directive; no remote-tracker API usage, no deck/card content, no build configuration; no new third-party dependencies (argparse/stdlib/yaml, already in the script's surface).

## Success criteria

- **SC-1** (behavioral — R-1, R-2). Fixture store carrying a mixed-outcome residue set — items the run routes differently in one invocation: `open/` holding contentless stub records (`003-…`/`004-…`/`005-…` — YAML metadata only, empty bodies, `github_issue: null`) plus an empty `closed/`, a top-level contentless `{N}-slug` residue record (`006-old-design/` — same contentless profile), a contentless collision twin (`003-stub-of-3/` — head digits parsing to 3, beside an existing current-format `3/` record), and a contentless but REMOTE-REFERENCING record (`008-open-tickets/` — empty body, `github_issue` set: removability fails on the reference conjunct). Instrument: against the fixture, first assert a pre-remediation invocation of another command (e.g. `read`) emits the legacy-format warning — the preserve-guard's behavioral half — then run `remediate-legacy`; assert, per item: (a) every contentless unreferenced item and both legacy directories are removed while the colliding current-format record `3/` is untouched, (b) the remote-referencing item exists intact at `_legacy/` (before/after store-tree manifest, byte-identical) — the run's different routing decisions for different items in one invocation are asserted per item, (c) the `issues-data` branch's log records the remediation commit, (d) a post-run tool invocation against the same store emits no legacy-format warning. The recorded commit is the rollback path for the removal.
- **SC-2** (behavioral — R-2, R-4). Fixture store whose residue includes records failing removability in each shape: a content-bearing record under `open/` and a top-level content-bearing `{N}-slug` record (each with non-empty body content, or `github_issue` set). Instrument: run `remediate-legacy`; assert both records' directories exist intact at `_legacy/` (a before/after store-tree manifest shows the content preserved byte-identical), no record content is deleted anywhere in the store, and a post-run tool invocation emits no legacy-format warning (the archive location is unflagged).
- **SC-3** (behavioral — R-5). Instrument: run `remediate-legacy --dry-run` against a residue fixture; assert the report itemizes remove/preserve-by-move per residue item with the reason, a before/after store-tree manifest comparison shows no path change, and the `issues-data` branch's log shows no new commit (the manifest alone cannot witness commit activity — the log check SC-1 uses for the same question).
- **SC-4** (structural — R-3, R-6). Instrument: source inspection of the `main()` warning gate and `_check_legacy_formats` — firing predicates unchanged (fires iff `open/`/`closed/`/`{N}-slug` present; `_legacy/` and conforming stores silent), warning text names `remediate-legacy`, and no persistent suppression state is introduced anywhere in the change.
- **SC-5** (behavioral — R-1's precondition clause). Instrument: run `remediate-legacy` where worktree establishment fails (fixture: a non-git directory carrying a residue-shaped `.issues/`); assert non-zero exit with a remediation message, and a before/after store-tree manifest comparison shows no store mutation.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | residue removal, recorded commit, post-run silence | behavioral | fixture run + `issues-data` log + re-invocation stderr |
| SC-2 | preservation guard, intact `_legacy/` archive, post-run silence | behavioral | fixture run + path/content comparison + re-invocation stderr |
| SC-3 | dry-run itemization, zero mutation | behavioral | fixture run + before/after store-tree manifest + `issues-data` log (no new commit) |
| SC-4 | firing predicates preserved; warning names the affordance; no suppression state | structural | source inspection |
| SC-5 | fail-fatal on worktree-establishment failure, no mutation | behavioral | fixture run + exit status + before/after store-tree manifest |

## Out of scope

- **Warning dampening or auto-suppression machinery** (the filing's fallback clause treated as a design candidate, declined): any muting path — sentinels, timestamps, repeat-counting — can silence a store whose defect is live, the documented failure of the once-only `.legacy-warned` sentinel removed by #2548 C5; the clause is delivered through R-4 (repetition ends by removal of the residue, not by muting of the signal).
- **Auto-migration of legacy records into current-format records** (the filing's other design example, declined): the observed residue had nothing to migrate (contentless stubs); migrating content-bearing legacy records requires explicit supersession and collision-twin judgment (#2548 C5's explicit content comparison) — agent judgment, not a tool heuristic; such records are preserved in `_legacy/` for the agent to act on.
- **`doctor`/`validate-yaml` shape changes** — the filing's `doctor --remediate-legacy` example is declined on the tool's read-only-command discipline (both commands mutate nothing by design; `doctor` additionally takes no flags); a standalone mutation-command shape follows the codebase's existing mutation family.
- Deck/card content, remote-tracker API behavior, other tool commands' behavior.

## Approach

A standalone `remediate-legacy` command in the tool's mutation family: detection reuses the residue predicates `_check_legacy_formats` already defines (single-sourced conditions — the command cannot disagree with the warning); per-residue-item removability verification (contentless + `github_issue: null`) routes each item to removal or to preserved-by-move under `_legacy/` (never deletion); `--dry-run` previews the routing; the operation records through the standing mutation contract. This supersedes #1309's non-goals ("No automated migration command … agent remediates manually; no removal of existing legacy directories — tool warns, agent fixes") deliberately: that posture predated #2548's store-safety primitives, and this ticket's observed evidence — the hand-rolled git repair of contentless stubs — is the friction the tool-level affordance removes. #2627's firing-only-on-genuine-deviation bound is preserved by R-3. Edge cases covered: residue spread across `open/`, `closed/`, and top-level `{N}-slug` records in one store is remediated in one run (SC-1/SC-2 instruments each combine shapes); a contentless collision twin beside an existing current-format record (e.g. `003-slug` beside `3/`) is removable — nothing is lost by its removal (R-1's verification decides, `_parse_number` semantics resolve the number); `--dry-run` against a residue-free store is a no-op reporting nothing to do; a non-worktree store fails fatally without mutation (SC-5) — bootstrapping rides the tool's standing first-mutation auto-init discipline.

## Traceability

| Artifact | Source |
|---|---|
| R-1, SC-1 | filing's primary ask (remediation affordance, verified contentless/unreferenced removal with recorded commit — the observed manual repair, tool-owned) |
| R-2, SC-2 | the removal path's safety (filing: affordance "verifies the legacy records are contentless/unreferenced"); safety family: destructive operations with preservation + rollback paths |
| R-3, SC-4 | #2548 C5's sentinel lesson (source docstring, ~2622–2627); #2627's deviation-only firing bound |
| R-4, SC-1(d), SC-2 (closing silence assert) | the filing's fallback floor (warning no longer repeats once the residue is gone) |
| R-5, SC-3 | safety family: destructive operations carry a preview path; the recorded commit carries the rollback |
| R-6, SC-4 | the filing's non-actionable-noise complaint — the warning's manual-remediation directive becomes resolvable by the tool it names |
| Root causes 1–2 | R-1 (the matched actor, structured and recorded) — covered by SC-1/SC-2/SC-3 |

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)