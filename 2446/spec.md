> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2446/

# [SPEC-FIX] local-issues --labels: comma-separated parsing, malformed rejection, help text

## Intent and Executive Summary

1. **Problem Statement:** `local-issues update --labels` and `local-issues create --labels` accept label tokens via `nargs='*'` with no normalization or validation. A quoted comma-separated string such as `--labels 'a, b'` silently produces a single malformed label `'a, b'` that propagates verbatim into `issue.yaml` and all label output, while help text implies comma-separated input.
2. **Root Cause / Motivation:** The argparse definitions for `--labels` (both subparsers) declare `type=str, nargs='*'` with no splitting, stripping, or emptiness checks, and `cmd_update`/`cmd_create` write labels straight through with no validation. The defect was discovered during spec-audit label updates (`NewsRx/hermes-ingest-pubmed#139`, 2026-09-14); it must be fixed now because the label field feeds the canonical `approved-for-*` authorization record — a malformed label is a corrupted authorization state.
3. **Approach Chosen:** Introduce a pure `_normalize_labels` helper that splits comma-separated tokens, strips whitespace, and drops empties; apply it in both `cmd_update` and `cmd_create` (before `_ensure_needs_approval`); reject any remaining malformed remainder (tokens containing commas or whitespace after normalization) with a fail-fast CLI error before any write or auto-commit; add explicit help text documenting accepted input on both subparsers.
4. **Alternatives Considered & Why Discarded:**
   - Document space-separated usage only (no code change) — discarded: existing callers (spec-audit workflows) already pass comma-separated strings; documenting only moves the failure, and the `approved-for-*` label state stays corruption-prone.
   - Silently normalize without rejecting — discarded: a token that survives normalization but still contains embedded whitespace or commas indicates a caller misunderstanding; silent acceptance violates fail-fast data-integrity rules and hides caller defects.
5. **Key Design Decisions:**
   - Normalization is a pure function with no I/O — tradeoff: one extra indirection vs. testability without issue fixtures.
   - Rejection happens pre-write and pre-auto-commit — tradeoff: caller-visible error instead of silent partial success; issue.yaml never left half-mutated.
   - Backward compatibility: space-separated usage (e.g. `--labels a b`) is unchanged — tradeoff: comma+space forms become normalized rather than rejected, so no existing correct call breaks.
6. **User Intent / Original Prompt:** [BUG] report `.opencode#2446`: help text implies comma-separated input but `nargs='*'` parses space-separated; malformed labels should be rejected rather than silently created. This spec is the SPEC-FIX produced from the bug report via the spec-creation pipeline.

## Not Included

- **`list`/`read-labels` output formatting changes** — display layers render stored labels verbatim; fixing the writers is the root-cause fix, and output changes would alter unrelated consumers.
- **Migration of historically malformed labels in existing `issue.yaml` files** — historical mutation of issue records is out of scope; the fix prevents future malformed writes only.
- **Any change to the `issue.yaml` labels schema** — labels remain a YAML list of strings; only value cleanliness changes.
- **Callers outside `.opencode/tools/local-issues`** — no other callers of `--labels` were found in the tool directory; external repos are out of scope.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A `_normalize_labels` helper exists and, given the repro input tokens `['a, b']`, returns `['a', 'b']` — splitting on commas, stripping whitespace, and dropping empty tokens; given `['needs-approval']` it returns `['needs-approval']` unchanged. | behavioral | Unit test execution against the helper with the repro case and an already-clean case; output inspected by assertion |
| SC-2a | When a label token still contains a comma or whitespace after normalization, `cmd_update` exits with a CLI error before any file write or auto-commit, and the target `issue.yaml` is byte-identical before and after. | behavioral | Unit test asserting error exit and unchanged issue.yaml on malformed remainder, run against a temp issues worktree (never the live worktree) |
| SC-2b | When a label token still contains a comma or whitespace after normalization, `cmd_create` exits with a CLI error before any file write or auto-commit, and no new `issue.yaml` is created. | behavioral | Unit test asserting error exit and no issue.yaml creation on malformed remainder, run against a temp issues worktree (never the live worktree) |
| SC-3a | The `--help` output for the `update` subparser includes help text on `--labels` documenting that comma-separated and space-separated input are accepted and malformed labels are rejected. | string | Parse `update --help` output and assert the `--labels` help string content |
| SC-3b | The `--help` output for the `create` subparser includes help text on `--labels` documenting that comma-separated and space-separated input are accepted and malformed labels are rejected. | string | Parse `create --help` output and assert the `--labels` help string content |

**Same-concern bundling justification (SC-1):** SC-1 asserts a single pure function (`_normalize_labels`) on two inputs — the repro case and the already-clean case exercise the same code path with no branching between distinct targets. Splitting them would produce two SCs verifying one helper's behavior; the bundling is same-concern and atomic per the deck's per-target decomposition rule (each SC targets exactly one symbol, `_normalize_labels`). SC-2a/SC-2b and SC-3a/SC-3b are decomposed because `cmd_update`/`cmd_create` and the two subparser argparse definitions are distinct code targets.

## Requirements

1. R-1. The system SHALL normalize `--labels` input for both `update` and `create` by splitting tokens on commas, stripping whitespace, and dropping empty tokens, under all label-writing invocations.
2. R-2. The system SHALL reject (fail-fast CLI error, exit before any write or auto-commit) any label token that still contains a comma or whitespace after normalization.
3. R-3. The system SHALL document on the `--labels` argument of both subparsers that comma-separated and space-separated input are accepted and that malformed labels are rejected.
4. R-4. The system SHOULD preserve existing space-separated usage (`--labels a b`) unchanged — backward compatibility for current correct callers.
5. R-5. The system SHALL apply normalization before `_ensure_needs_approval` so the canonical first-label ordering invariant holds post-normalization.

## Items

### Item 1 (SC-1): Label normalization helper applied to both entry points

- RED: Unit test asserting `_normalize_labels(['a, b']) == ['a', 'b']` and `_normalize_labels(['needs-approval']) == ['needs-approval']` fails (helper does not exist).
- GREEN: Implement the pure `_normalize_labels` helper and wire it into `cmd_update` and `cmd_create` before label assignment into the issue dict.
- verify: Run the unit tests; confirm `_ensure_needs_approval` still inserts `needs-approval` first post-normalization.
- commit: One commit scoped to `.opencode/tools/local-issues` + test.

### Item 2a (SC-2a): Fail-fast rejection of malformed label remainder in `cmd_update`

- RED: Unit test invoking `update` with an unresolvable malformed label token asserts an error exit and an untouched issue.yaml — fails (currently silently succeeds).
- GREEN: Add pre-write validation in `cmd_update`; raise a CLI error before any mutation or `_auto_commit`.
- verify: Run the unit test against a temp issues worktree; assert issue.yaml byte-identical and no commit created.
- commit: One commit scoped to `.opencode/tools/local-issues` + test.

### Item 2b (SC-2b): Fail-fast rejection of malformed label remainder in `cmd_create`

- RED: Unit test invoking `create` with an unresolvable malformed label token asserts an error exit and no created issue.yaml — fails (currently silently succeeds).
- GREEN: Add pre-write validation in `cmd_create`; raise a CLI error before any mutation or `_auto_commit`.
- verify: Run the unit test against a temp issues worktree; assert no issue.yaml created and no commit created.
- commit: One commit scoped to `.opencode/tools/local-issues` + test.

### Item 3a (SC-3a): Help text for `--labels` on the `update` subparser

- RED: Test parsing `update --help` output asserts a `--labels` help string exists — fails (no per-argument help).
- GREEN: Add a help string to `--labels` on the `update` subparser documenting accepted input formats and rejection behavior.
- verify: Run the help-text test; assert content present on the `update` subparser.
- commit: One commit scoped to `.opencode/tools/local-issues` + test.

### Item 3b (SC-3b): Help text for `--labels` on the `create` subparser

- RED: Test parsing `create --help` output asserts a `--labels` help string exists — fails (no per-argument help).
- GREEN: Add a help string to `--labels` on the `create` subparser documenting accepted input formats and rejection behavior.
- verify: Run the help-text test; assert content present on the `create` subparser.
- commit: One commit scoped to `.opencode/tools/local-issues` + test.

## Dependencies

- **Reference:** `.opencode/tools/local-issues` — Relationship: the single file modified by this fix; must be read before implementation. Status: satisfied (pre-spec inspection read it).
- **Reference:** 090-data-integrity (data validation at system boundaries) — Relationship: the rejection requirement implements the boundary-validation rule; must be followed during implementation. Status: satisfied (guideline exists).
- **Reference:** [BUG] issue `.opencode#2446` — Relationship: source bug report this SPEC-FIX amends. Status: satisfied (exists).

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 (normalization) |
| R-2 | SC-2a, SC-2b | Phase 2 (rejection) |
| R-3 | SC-3a, SC-3b | Phase 3 (help text) |
| R-4 | SC-1, SC-2a, SC-2b | Phase 1, Phase 2 |
| R-5 | SC-1 | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| local-issues parser definitions | code | `.opencode/tools/local-issues` (update/create argparse `--labels` definitions) | Read during pre-spec inspection 2026-09-17 |
| cmd_update / cmd_create / _ensure_needs_approval | code | `.opencode/tools/local-issues` | Read during pre-spec inspection 2026-09-17 |
| Verified repro | live command | `argparse` parse check: `parse_args(['--labels','a, b']).labels == ['a, b']` | Executed 2026-09-17 |
| [BUG] issue | issue | https://github.com/michael-conrad/.opencode/issues/2446 | Read via `gh issue view` 2026-09-17 |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the normalization unit test costs minutes of execution time. Skipping means malformed labels keep crossing the CLI→issue.yaml boundary and corrupt the canonical `approved-for-*` authorization record, surfacing days later in approval-gate checks at 100× fix cost.
- **SC-2a / SC-2b:** Running the rejection unit tests against a temp worktree costs minutes. Skipping means a silently accepted malformed label ships into issue.yaml, and the corruption is discovered only when authorization verification fails downstream — weeks later, at rework cost far exceeding the test.
- **SC-3a / SC-3b:** Parsing the help output costs seconds. Skipping means the next caller repeats the same comma-separated mistake the help text implies is valid — the original defect vector stays open indefinitely.

## Edge Cases

- **Input boundaries:** Empty label token (`--labels ''`) → dropped by normalization; if nothing remains, behavior follows existing empty-labels handling. Whitespace-only tokens (`'  '`) → stripped to empty and dropped. Already-clean tokens (`needs-approval`) → unchanged. Mixed input (`'a, b' 'c'`) → `['a', 'b', 'c']`.
- **State transitions:** Malformed remainder → CLI error exit before issue.yaml write and before `_auto_commit`; no partial state, no auto-commit record. Well-formed input → normalization → `_ensure_needs_approval` (first-label ordering preserved) → write → auto-commit as today.
- **Failure modes:** Normalization helper failure (unexpected exception) → propagate immediately, no write (fail-fast). `_ensure_needs_approval` ordering after normalization → canonical label still inserted first.
- **Concurrency:** Not applicable — single-process CLI; auto-commit semantics unchanged from existing behavior.
- **Recovery:** After a rejection error, the caller corrects the `--labels` argument and re-invokes; no state cleanup is needed because the failed invocation mutated nothing.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-17 | Decomposed compound SCs: SC-2 split into SC-2a (`cmd_update`) and SC-2b (`cmd_create`); SC-3 split into SC-3a (`update` subparser) and SC-3b (`create` subparser); Items 2/3 renumbered to 2a/2b and 3a/3b; Traceability and Cost Frame updated to reference the new SC IDs. SC-1 kept as one SC with a same-concern bundling justification added (single pure helper, two inputs, one code path). | Validation findings (1) compound SCs — per-target atomic decomposition required | spec-creation revise task, validation findings from developer |
| 2026-09-17 | SC-1 evidence type redeclared from `semantic` to `behavioral` in the Success Criteria table and sc-summary.yaml — unit-test-execution verification of runtime helper behavior is behavioral evidence, not semantic. | Validation finding (2) EVIDENCE_TYPE_MISMATCH on SC-1 | spec-creation revise task, validation findings from developer |
