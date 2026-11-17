# Spec: CSV deduplication tool — remove duplicate rows by key columns, preserve first-occurrence order, report removed count

(PREPARED DRAFT — not yet a store artifact. The `local-issues` tool is in its fail-fatal state in this workspace: `.issues/` holds a standalone seeded repo but the workspace root is not a git repository, so the issues-data worktree cannot be established. This file is the `spec.md` payload for `probe-home#3`, to be written via the tool flow only — `local-issues create --number probe-home#3` first, never a plain-file write.)

## 1. Intent and Executive Summary

- **Problem Statement:** This project provides no CSV deduplication capability — nothing exists here that takes a CSV file plus a set of key columns and removes duplicate rows. (Verified: the workspace tree contains no project source as of 2026-11-16 — a directory listing of the workspace root shows only the `.issues/` store, the `.opencode/` configuration checkout, `.git/` stub hooks, and `AGENTS.md`.)
- **Root Cause / Motivation:** The capability is absent from the project today (verified 2026-11-16, as recorded under Problem Statement); this is a new-tool request, not a defect fix in an existing component. The stakeholder has now requested it with three stated requirements (R1–R3, recorded 2026-11-16), which fixes the work's scope now.
- **Approach Chosen:** A standalone CSV-deduplication utility: it reads the given CSV file, treats the supplied key-column set as row identity, removes every row whose key-column values repeat those of an earlier row (R-1), emits rows in the order their first occurrences appear in the input (R-2), and reports the number of rows removed (R-3).
- **Alternatives Considered & Why Discarded:**
  - Whole-row comparison as the duplicate key — discarded: R-1 fixes row identity to the given key-column set, so whole-row matching cannot treat rows differing in non-key columns as duplicates of each other.
  - Keep-last retention (dropping the first occurrence, keeping the last) — discarded: R-2 mandates that first-occurrence order is preserved, which fixes keep-first semantics.
  - Leaving the removed-row count to the user to infer by diffing input and output row counts — discarded: R-3 mandates that the tool itself reports how many rows were removed.
  - Normalized or fuzzy key matching (case-folding, whitespace trimming) — discarded: the stated requirements define duplicates solely through the key-column values as given; normalization would add an equivalence rule nobody requested.
- **Key Design Decisions:** Duplicate identity is exact equality of the key-column value tuple (tradeoff: no normalization — key values must match exactly to merge); retention is keep-first in original file order (tradeoff: no reordering pass); the removed-row count is reported as an explicit result of the run (tradeoff: one verifiable value rather than a count the operator must reconstruct). The output delivery channel — rewritten input file, new file, or stdout — is left to the plan; every requirement constrains the emitted result, not the channel.
- **User Intent / Original Prompt:** "We need a CSV deduplication tool. R1: given a CSV file and a set of key columns, it removes duplicate rows. R2: it preserves the first occurrence order. R3: it reports how many rows were removed." (stakeholder request, relayed for recording; recorded 2026-11-16)

## 2. Not Included

- Key-value normalization before duplicate comparison — excluded: duplicates are defined by the key-column values as given; normalization would be a new product decision.
- Removal detail beyond the count (itemized per-duplicate audit) — excluded: R-3 fixes the report as a count; itemized reporting is undemanded.
- Any non-CSV tabular input format — excluded: the request names a CSV file.

## 3. Requirements

- R-1. Given a CSV file and a set of key columns, the tool SHALL remove every row whose key-column values equal those of an earlier row, regardless of the rows' other column values.
- R-2. The tool SHALL preserve first-occurrence order: for every key-column tuple present in the input, the row retained is the input's first row carrying that tuple, and the emitted rows keep the input's relative order.
- R-3. The tool SHALL report how many rows were removed, i.e. the input row count minus the count of retained rows.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | No key-column tuple appears more than once in the emitted result — each row beyond a key tuple's first occurrence is removed. | behavioral | Executed test: run the tool on a fixture CSV (including same-key pairs that differ in non-key columns); parse the emitted CSV; assert every key tuple occurs at most once. |
| SC-2 | Every distinct key-column tuple present in the input is retained in the emitted result — no tuple's whole group is lost. | behavioral | Executed test: same fixture run; parse the emitted CSV; assert the set of emitted key tuples equals the set of input key tuples. |
| SC-3 | The emitted row sequence equals the input row sequence filtered deterministically to each key tuple's first occurrence — the retained row per tuple is the input's first, and relative input order is otherwise unchanged. | behavioral | Executed test: for a fixture CSV with first occurrences interleaved between other rows, compare the emitted sequence against the expected sequence derived from the fixture by first-occurrence filtering. |
| SC-4 | The tool reports the number of rows removed, and for fixtures with N input rows and T distinct key tuples the reported number equals N − T, including the value 0 when the fixture has no duplicates. | behavioral | Executed test: run the tool on fixtures with known N and T (one fixture without duplicates); compare the reported count to the N − T value computed from the fixture. |

## 5. Dependencies

None — the tool is greenfield work inside this repository; no in-repo prerequisite exists (the workspace tree is verified to contain no project source as of 2026-11-16, per the Problem Statement's check).

## 6. Traceability

| Requirement | Success criteria |
|---|---|
| R-1 | SC-1, SC-2 |
| R-2 | SC-2, SC-3 |
| R-3 | SC-4 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| Stakeholder requirements R1–R3 (quoted verbatim in the intent preamble) | conversation record | The recording request relaying the stakeholder's statement, 2026-11-16 | Quoted verbatim and dated in the spec's provenance field |
| Workspace carries no existing CSV-dedup capability and no source tree | repository state | This repository's working tree | Directory listing executed 2026-11-16 (only `.git/` stub, `.issues/`, `.opencode/`, `AGENTS.md`) |

## 8. Cost Frame

- SC-1, SC-2, SC-3: verification costs one executed run per fixture plus a parsed comparison — cheap and deterministic. Skipping it ships a tool that silently deletes rows or scrambles row order — errors that are silent at run time and irreversible once the original file is discarded (data-loss class).
- SC-4: verification costs reading the reported number per run and comparing it to a computed value. Skipping it leaves a wrong removal count undetected — the operator would misstate how much data the run changed.

## 9. Edge Cases

- **Condition:** input CSV with no duplicate key tuples. **Expected behavior:** the emitted result equals the input; the reported removed count is 0. **Resolution:** covered by the SC-2/SC-3/SC-4 instrument fixtures.
- **Condition:** all input rows share one key tuple. **Expected behavior:** exactly one row is emitted (the first); the reported count is N − 1. **Resolution:** covered by the SC-1/SC-3/SC-4 instrument fixtures.
- **Condition:** duplicate rows separated by unrelated rows (non-adjacent duplicates). **Expected behavior:** later duplicates are removed wherever they appear; first-occurrence order holds across the interleaving. **Resolution:** covered by the SC-1/SC-3 instrument fixtures, which interleave first occurrences.
- **Condition:** same key tuple with differing non-key column values. **Expected behavior:** still duplicates — identity is the key tuple only; the first row is kept and later rows removed. **Resolution:** covered by the SC-1/SC-3 instrument fixtures.
- **Condition:** input CSV containing only a header row. **Expected behavior:** zero data rows emitted; reported count 0. **Resolution:** covered by the SC-4 instrument fixture set.
- **Condition:** input that does not parse as CSV. **Expected behavior:** unspecified by the stated requirements — the tool is defined on CSV files. **Resolution:** no requirement demanded; the plan stage may fix error behavior without widening this spec.
- **Condition:** empty key-column set supplied. **Expected behavior:** outside the specified input space — the request defines the tool's inputs as a CSV file plus a set of key columns. **Resolution:** precondition recorded here; no stated requirement fixes a behavior for it.

## 10. Completion gate

Every success criterion in section 4 passes before the deliverable is complete; partial implementation is not permitted.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
