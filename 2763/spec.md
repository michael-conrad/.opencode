# SPEC: local-issues validate-yaml findings carry the repo qualifier on store-relative paths

## 1. Intent and executive summary

**Problem Statement.** `local-issues validate-yaml` prints findings as store-relative paths (observed verbatim: `20/artifacts/pre-spec-inspection.yaml`) with no repo qualifier in the output. Multiple stores exist per workspace (session-init registers `.issues/` for the root and `.opencode/.issues/` for the submodule), and their `{N}/` folders can hold identical relative paths, so an agent reading a finding cannot resolve which store owns the named file. The consumer of these findings — the issues card §7 repair workflow, which seeds per-file repair dispatches and re-verifies with a full `validate-yaml` sweep — can act on the wrong store's file or sweep-verify the wrong store's cleanup.

**Root Cause / Motivation.** The tool's finding emission formats paths relative to each store root without composing the owning repository's qualified identity into the output. The defect surfaces only where a consumer holds more than one store, so single-store exercise never exposed it. Observed 2026-11-20 during the `.opencode#2761` triage session, which ran hygiene sweeps across both registered stores.

**Approach Chosen.** Compose the store registry's qualifier into each finding's path at emission time. Detection logic (which findings the validator emits) is unchanged.

**Alternatives Considered & Why Discarded.**
- Prefix output with a per-repo header block instead of qualifying each finding — rejected: findings are consumed per-line by dispatch tooling; per-line qualification survives cropping, sorting, and tail-truncated views (the sweep-completeness rule reads full output).
- Include the absolute path — rejected: absolute paths are environment-bound; the store registry's qualifier is the stable identity agents key on everywhere else in the deck (`repo#N` qualified-name discipline).

**Key Design Decisions.**
- The qualifier is the store registry's identity (the same qualified names `local-issues` already emits for repos), not a new token.
- Per-line qualification (each finding self-identifies), making output robust to any pagination or truncation of the findings list.

**User Intent / Original Prompt.**
- 2026-11-20, record `.opencode#2761` (developer-filed session report), "Additional Context": "Secondary observation from the same workflow (separate candidate issue): `local-issues validate-yaml` prints findings as store-relative paths (`20/artifacts/pre-spec-inspection.yaml`) that are ambiguous across repos when different stores hold identical relative paths — the output names no repo qualifier."
- Filing provenance: this requirement was reported inside `.opencode#2761`, classified 2026-11-20 triage as its own requirement class (no matching existing spec found — store/remote search on `validate-yaml` findings, path qualification, and related tooling-output classes), and filed here per the issues card's work-entry conversion (remote-first number reservation).

## 2. Not Included

- Detection-logic changes — which findings `validate-yaml` emits is unchanged; only path presentation changes, so detector behavior is out of this finding's cause.
- Output reformatting of other `local-issues` verbs — no stated failure implicates any other verb's output; this finding names only the validate-yaml emission path.
- Record-content changes to any store — the requirement is presentation-only; record content is the hygiene workflows' surface and is not the defect's cause.
- The host-maps conf and the stores' path-resolution semantics — the dependency row shows the conf carries no store data, and resolving paths to the store root is the behavior that produces the findings; only their presentation is defective.

## 3. Requirements

- **R-1** — `local-issues validate-yaml` SHALL present every finding's file path qualified with its owning repository's identity (the store registry's qualifier), such that no run's output presents a finding whose owning repository cannot be determined from that output line alone, and findings from two stores holding identical store-relative paths are distinguishable when their runs' outputs are read together.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | In per-store `validate-yaml` runs over two stores that each hold a defective file at the same relative path (e.g. `20/artifacts/pre-spec-inspection.yaml`) — exercised through both the unscoped sweep and the scoped single-issue invocation (`--number`) — every emitted finding in each run names its repository from the output line alone, and the two stores' outputs present the identical-path pair under distinct qualifiers | behavioral | Shell repro: seed a malformed YAML file at an identical relative path in each registered store, run `local-issues validate-yaml` per store in both modes (the unscoped sweep and the scoped `--number` form on the seeded path), parse each run's findings, and assert per-line repo qualification plus distinct qualifiers for the identical-path pair across the two stores' outputs — no run mode emits an unqualified finding; clean up seeded artifacts afterward |

## 5. Dependencies

| Reference | Relationship | Status |
|---|---|---|
| Store registry (session-init `path`/`owner`/`repo` mapping; the tool's own repo-discovery qualifier emission) | Supplies the qualifier composed into findings — the qualifier is the tool's repo identity (e.g. `opencode-config`, `.opencode`), not the host-maps conf, which is a host→browser-base table carrying no store data | Satisfied (exists) |
| Issues card §7 repair workflow | Consumer contract: findings seed per-file repair dispatches and the re-verification sweep | Satisfied (card wording in place) |

## 6. Traceability

| Requirement | SCs |
|---|---|
| R-1 | SC-1 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| `.opencode#2761` record | issue-store record (mirror of remote) | `.opencode/.issues/2761/` | fetched from the remote tracker 2026-11-20; report's Additional Context quoted verbatim |
| `local-issues validate-yaml` output shape | tool behavior | `.opencode/tools/local-issues` | observed 2026-11-20 in the triage session's hygiene sweep (store-relative finding path) |
| Session-init store registry | runtime data | session-init output (`path`/`owner`/`repo`/`issues:` per entry) | present in session-init output 2026-11-20 |

## 8. Cost Frame

- SC-1: a seeded two-store repro costs minutes; skipping leaves the repair-dispatch surface resolving to the wrong store — an observed-class hazard already reachable from both registered stores.

## 9. Edge Cases

| Condition | Expected behavior |
|---|---|
| One run per store (`validate-yaml` walks one registered store per invocation) | Every line in each run's output self-identifies its repository; the identical-path pair across the two stores' outputs resolves distinctly |
| Single-store run (one repo visible) | Output carries the qualifier unchanged — no format fork between single- and multi-store runs |
| Scoped single-issue run (`--number`) — the tool's second finding-emission site | The scoped branch's findings carry the same per-line qualification; no emission site ships unqualified |
| Truncation/tail views of findings (large sweeps) | Per-line qualification survives cropping; no header-block dependency |

## 10. Completion gate

Every success criterion passes before the deliverable is complete; partial implementation is not permitted.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
