> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/2322/
>
> **Local artifacts:** `.opencode/.issues/2322/`

## Intent and Executive Summary

BLUF: Fix one broken CLI invocation in `.opencode/skills/writing-plans/tasks/research.md` step 12 so the writing-plans research step stops hard-failing on argument parsing for every plan. The task card passes `solve`-style flags (`--contract-path`, `--output`) to the `plan plan` subcommand, which accepts neither. The correction replaces them with the problem-driven pattern (`--problem` + stdout redirect) evidenced by resolved issue `.opencode#2134`.

## Problem

`.opencode/skills/writing-plans/tasks/research.md` step 12 (line 48) instructs `./.opencode/tools/plan plan --contract-path {issues_prefix}/{N}/dependency-contract.yaml --output {issues_prefix}/{N}/artifacts/plan-output.yaml`, but the `plan plan` subcommand takes a required `--problem <YAML>` and an *optional* `--engine <NAME>` (default `tamer`), and has **NO** `--contract-path` or `--output` flags. Verified live 2026-08-25: `./.opencode/tools/plan plan --help` prints `usage: plan plan [-h] --problem PROBLEM [--engine ENGINE]`. The `--contract-path` flag exists only on the `solve` tool and on `plan state update`, not on `plan plan`. This defect blocks the research step of the writing-plans pipeline for ALL plans (including `.opencode#2320`).

## Documentation Sources

All facts below were verified live on 2026-08-25 in the implementing session.

| # | Source | Verified Fact |
|---|--------|---------------|
| D-1 | `./.opencode/tools/plan plan --help` (live execution) | `usage: plan plan [-h] --problem PROBLEM [--engine ENGINE]`; `--problem/-p` is required ("path to YAML problem file"); `--engine/-e` is optional ("planning engine name (default: tamer)") |
| D-2 | `.opencode/tools/plan` source, function `_action_plan` | Engine default resolves as `args.engine or "tamer"`; success statuses are `SOLVED_SATISFICING` and `SOLVED_OPTIMALLY`; failure statuses (`UNSOLVABLE_PROVEN`, `UNSOLVABLE_INCOMPLETELY`, `TIMEOUT`, `MEMOUT`) exit non-zero via `_die` |
| D-3 | `.opencode/tools/plan` source, `_action_plan` output block | On success, stdout contains a human-readable summary, then a `---` separator, then a YAML document with keys `domain`, `engine`, `status`, `plan_length`, `actions` |
| D-4 | `.opencode#2134` local artifacts: `dependency-contract.yaml`, `artifacts/phase-problem.yaml`, `artifacts/plan-output.yaml` | Fully evidenced identical-pattern precedent: contract phases map to problem fluents/actions/goals; `plan-output.yaml` holds the captured stdout YAML (`status: SOLVED_SATISFICING`) |
| D-5 | `.opencode#2166` local artifacts listing | Uses filename `artifacts/plan-problem.yaml` (not `phase-problem.yaml`) — different artifact naming; NOT cited as an identical-pattern precedent |
| D-6 | `.opencode/skills/writing-plans/tasks/research.md` lines 48 and 60 (read live) | Line 48 is the defective step-12 invocation; line 60 exit criterion reads "`tools/plan plan` returned SOLVED_SATISFICING or SOLVED_OPTIMALLY" — exactly matching the success status names emitted by the live tool (D-2) |

## Definitions

- **`{issues_prefix}`**: Path prefix of an issue's local artifacts directory, resolved by repo entry. In this repository's writing-plans pipeline the affected issues live in the `.opencode` submodule, so `{issues_prefix}/{N}` resolves to `.opencode/.issues/{N}` (e.g., `.opencode/.issues/2320`).
- **`{N}`**: The numeric issue number being planned.
- **`dependency-contract.yaml`**: File at `{issues_prefix}/{N}/dependency-contract.yaml`, extracted from `interface-compatibility.yaml`'s `dependency_contract` section by research.md step 9. Structure (per D-4): top-level keys `variables` (map of `phase_<k>` boolean variables with descriptions), `preconditions` (list of `z3.Implies(phase_later, phase_earlier)` ordering expressions), `phases` (map of `phase_<k>` → `files` + `scs`), and `edges` (list of `{from, to, rationale}` DAG arcs).
- **Phase DAG**: The directed acyclic graph over phases defined by the contract: nodes are the `variables`/`phases` keys; arcs are the `edges` entries, cross-checked against `preconditions`.
- **`phase-problem.yaml`**: Unified-planning problem file consumed by `plan plan`. Top-level keys (per `./.opencode/tools/plan help` and D-4): `domain` (string), optional `types`, optional `objects`, `fluents` (list of `{name}`), `actions` (list of `{name, preconditions?, effects?}` of fluent expressions), `init` (list of fluents TRUE at start), `goals` (list of fluents to satisfy).
- **Corrected invocation**: `./.opencode/tools/plan plan --problem {issues_prefix}/{N}/artifacts/phase-problem.yaml > {issues_prefix}/{N}/artifacts/plan-output.yaml` (stdout redirect captures summary + YAML document per D-3; non-zero exit signals planner failure per D-2).
- **`plan-output.yaml`**: Artifact holding the captured stdout of the corrected invocation. Content: human-readable planning summary, `---` separator, then the YAML result document (`domain`, `engine`, `status`, `plan_length`, `actions`). Downstream consumer: research.md step 13 embeds the planner result into `solve-output.yaml`.

### Dependency-contract → phase-problem mapping

The implementor SHALL construct `phase-problem.yaml` from `dependency-contract.yaml` as follows (mapping evidenced end-to-end by D-4):

1. For each `phase_<k>` key in the contract's `variables`, declare one fluent `- name: phase_<k>` under `fluents`.
2. For each `phase_<k>`, create one action `- name: do-phase-<k>` whose `effects` contain `phase_<k>`.
3. For every ordering constraint requiring `phase_j` before `phase_k` — i.e., each `z3.Implies(phase_k, phase_j)` in `preconditions` and each edge `{from: phase_j, to: phase_k}` in `edges` — add `phase_j` to `do-phase-<k>`'s `preconditions`.
4. Set `init: []` (no phase starts complete) and list every `phase_<k>` fluent under `goals`.
5. Set `domain: issue-{N}-phase-dag`.

## Preconditions

- **P-1**: `{issues_prefix}/{N}/dependency-contract.yaml` exists — produced by research.md steps 9–11 (extraction from `interface-compatibility.yaml`, then `solve model` and `solve check` SAT gates).
- **P-2**: `{issues_prefix}/{N}/artifacts/interface-compatibility.yaml` exists with a non-empty `dependency_contract` section (step 9 fails BLOCKED otherwise).
- **P-3**: The implementor has access to `.opencode/tools/plan`; the unified-planning problem-YAML schema it consumes is defined in this spec (§Definitions) and by `./.opencode/tools/plan help`.

## Scope

- **In scope:** Fix step 12 in `.opencode/skills/writing-plans/tasks/research.md` to use the correct invocation pattern for the `plan plan` subcommand
- **In scope:** Correct the invocation to build a `phase-problem.yaml` from the dependency-contract's phase DAG per the mapping in §Definitions, then run the corrected invocation (§Definitions) capturing stdout to `plan-output.yaml`
- **In scope:** Record the exit-criterion determination: line 60 requires **NO change** — it already states exactly the two success status names the live tool emits (`SOLVED_SATISFICING`, `SOLVED_OPTIMALLY`; D-2, D-6). This is an asserted-no-change determination backed by live verification, not an implementor decision.
- **Out of scope:** Changes to the `solve` tool or its `--contract-path` model
- **Out of scope:** Changes to `plan state update` semantics

## Approach

The task card wrongly applied the `solve` tool's `--contract-path` contract-file model to the `plan` tool. The `plan` tool's `plan plan` subcommand is problem-driven, not contract-driven: it takes a `--problem` YAML file describing the phase DAG (with `--engine` optional, defaulting to `tamer`), and emits the plan to stdout. The corrected pattern — evidenced by resolved issue `.opencode#2134` (`dependency-contract.yaml` → `artifacts/phase-problem.yaml` → `artifacts/plan-output.yaml`, D-4) — is to build a `phase-problem.yaml` from the dependency-contract's phase DAG using the mapping in §Definitions, run the corrected invocation, and capture stdout to `plan-output.yaml`. Issue `.opencode#2166` is deliberately not cited: its artifacts use a different filename (`plan-problem.yaml`, D-5), so its linkage to this exact pattern is not identical.

## Root Cause

The task card conflated two distinct tools with different invocation contracts. `solve` (and `plan state update`) take a `--contract-path` contract file; `plan plan` takes a `--problem` file and emits output to stdout (captured via redirect). Writing `--contract-path` and `--output` on `plan plan` produces an argument-parsing failure, hard-blocking the research step. The defect has been present since the task card's first commit (6581901f, 2026-07-30).

## Impact

- **Risk: research step remains blocked** — Mitigated by fixing the invocation to the verified working pattern (D-1..D-4)
- **Risk: wrong pattern copy-pasted elsewhere** — Mitigated by documenting the correct `plan plan --problem` pattern and the contract→problem mapping in the task card
- **Risk: plan-output.yaml capture semantics ambiguous** — Mitigated by explicitly defining capture (stdout redirect) and content (summary + YAML result document, D-3)
- **Dependencies:** P-1..P-3 above — the dependency contract and interface-compatibility artifact are upstream products of research.md steps 9–11.
- **Call to action:** Review the fix spec, approve for implementation.

## Requirements

R-1. research.md step 12 SHALL invoke `plan plan` problem-driven: `--problem {issues_prefix}/{N}/artifacts/phase-problem.yaml` with stdout redirected to `{issues_prefix}/{N}/artifacts/plan-output.yaml`. The step-12 `plan plan` invocation SHALL NOT reference `--contract-path` or `--output`.

R-2. research.md step 12 SHALL specify how `phase-problem.yaml` is constructed from `dependency-contract.yaml` per the mapping in §Definitions (fluent per contract phase variable; action per phase with preconditions from contract preconditions/edges; empty init; all phase fluents as goals).

R-3. The corrected pattern SHALL execute successfully against the live tool: a `phase-problem.yaml` built per the §Definitions mapping solves with exit code 0 and stdout YAML carrying `status: SOLVED_SATISFICING` or `SOLVED_OPTIMALLY` — the same status names the unchanged exit criterion at line 60 requires.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | research.md step 12 instructs the corrected invocation — `plan plan --problem {issues_prefix}/{N}/artifacts/phase-problem.yaml` with stdout captured to `{issues_prefix}/{N}/artifacts/plan-output.yaml` — and the step-12 `plan plan` line contains no `--contract-path` or `--output` flag | string | `grep -n 'contract-path\|--output' .opencode/skills/writing-plans/tasks/research.md` shows no match within step 12's `plan plan` invocation; `grep -n 'plan plan --problem' .opencode/skills/writing-plans/tasks/research.md` matches inside step 12 |
| SC-2 | research.md step 12 documents the dependency-contract-to-phase-problem construction handoff (building `phase-problem.yaml` from `dependency-contract.yaml` before invoking `plan plan`) | string | `grep -n 'phase-problem.yaml' .opencode/skills/writing-plans/tasks/research.md` matches inside step 12 together with a `dependency-contract` reference establishing the build order |
| SC-3 | A minimal `phase-problem.yaml` constructed per the §Definitions mapping (two-phase linear chain) solves live via the corrected invocation | behavioral | During verification: write the two-phase problem file under `./tmp/`, run `./.opencode/tools/plan plan --problem ./tmp/<file>`, assert exit code 0 and stdout YAML contains `status: SOLVED_SATISFICING` or `status: SOLVED_OPTIMALLY` |

## SC Enforcement Gate

All SCs (SC-1 through SC-3) MUST pass for this spec to be considered complete. A single FAIL blocks the entire spec. Partial implementation is not permitted.

## Traceability

Requirement → SC → Phase:

| Requirement | SC(s) | Phase |
|-------------|-------|-------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 1 |

Root Cause → testing SC:

| Root Cause element | Tested by |
|--------------------|-----------|
| `--contract-path`/`--output` flags applied to the wrong subcommand (tool-model conflation) | SC-1 |
| Missing problem-driven construction guidance in the task card | SC-2 |
| Corrected pattern must execute against the live tool | SC-3 |

Fix Approach element → SC:

| Fix Approach element | Mapped SC(s) |
|----------------------|--------------|
| Build `phase-problem.yaml` from the dependency-contract phase DAG | SC-1, SC-2 |
| Run `plan plan --problem …` capturing stdout to `plan-output.yaml` | SC-1, SC-3 |
| Exit criterion line 60 determination | Asserted no change required (D-2/D-6 factual basis); SC-3 independently confirms the status names line 60 states are the ones the tool emits |

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the corrected invocation costs one grep. Skipping means the defective flags survive undetected and the research step keeps hard-failing on argument parsing for every plan.
- **SC-2:** Verifying the construction handoff is documented costs one grep. Skipping means the next implementor must reverse-engineer the contract→problem mapping from `.opencode#2134` artifacts — or guess and reintroduce a divergent, untested construction.
- **SC-3:** Running the live smoke verification costs one tool invocation on a throwaway file. Skipping means the documented pattern is trusted without proof it executes — the same trust failure that shipped the original defective flags (6581901f).

## Items

### Item 1 (SC-1): Corrected step-12 invocation

- **RED:** Grep research.md step 12 for `--contract-path`/`--output` on the `plan plan` line and for absence of `plan plan --problem` — expect FAIL (defective line still present).
- **GREEN:** Replace step 12's invocation with the corrected invocation (§Definitions), including the stdout redirect to `{issues_prefix}/{N}/artifacts/plan-output.yaml`.
- **verify:** Re-run the SC-1 greps — both must PASS.
- **commit:** `checkpoint(#2322): item-1 — corrected plan plan invocation in research.md step 12`

### Item 2 (SC-2): Construction handoff documented

- **RED:** Grep step 12 for a `phase-problem.yaml` build reference tied to `dependency-contract.yaml` — expect FAIL (handoff undocumented).
- **GREEN:** Add the step-12 build sub-step referencing `dependency-contract.yaml` and the §Definitions mapping (fluent per phase variable, actions from preconditions/edges, empty init, all-phase goals).
- **verify:** Re-run the SC-2 grep — must PASS.
- **commit:** `checkpoint(#2322): item-2 — phase-problem.yaml construction handoff documented`

### Item 3 (SC-3): Live smoke verification

- **RED:** Construct the two-phase example problem per §Definitions under `./tmp/` and run the corrected invocation — expect FAIL while the documented pattern does not exist or does not solve (exit ≠ 0).
- **GREEN:** With Items 1–2 landed, the documented pattern executes: assert exit code 0 and stdout YAML `status` ∈ {SOLVED_SATISFICING, SOLVED_OPTIMALLY}.
- **verify:** Re-run the invocation — PASS; remove the throwaway file from `./tmp/` afterward (behavioral-evidence retention rules excepted).
- **commit:** `checkpoint(#2322): item-3 — live smoke verification of corrected pattern`

## Change Control

- **Date:** 2026-08-25
- **What changed:** Added preamble (Intent and Executive Summary), Documentation Sources, Definitions (placeholders `{issues_prefix}`/`{N}`, artifact schemas, contract→problem mapping, corrected invocation), Preconditions, Requirements, Success Criteria table (SC-1..SC-3), SC Enforcement Gate, Traceability tables, Cost Frame, Items, and this Change Control section. Revised Problem wording (`--engine` stated as optional with default `tamer`, per live CLI D-1). Revised Approach precedent citation to `.opencode#2134` only (removed partially-evidenced `.opencode#2166` citation, D-5). Replaced the Scope bullet's discretionary "if needed" conditional with the asserted-no-change determination for exit-criterion line 60 (factual basis D-2/D-6).
- **Why:** Spec-audit DRAFT verdict — 6 of 11 holistic dimensions FAIL (HOLISTIC-1 Implementability, HOLISTIC-3 Completeness, HOLISTIC-5 Testability, HOLISTIC-6 Escape Hatches, HOLISTIC-7 Provenance, HOLISTIC-10 Traceability) with six bidirectional findings (five SPEC_INCOMPLETE, one SPEC_AMBIGUOUS) recorded in `tmp/issue-2322/artifacts/spec-audit/verdict.yaml` and `judgment.yaml`; the gate-block note additionally required Success Criteria, Requirements, Items, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, and preamble sections before re-audit.
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Spec-audit DRAFT verdict remediation).
- **Constraint honored:** No valid success criterion was weakened or removed — the prior spec version contained zero SCs; all SCs in this revision are additions.
- **Date:** 2026-08-26
- **What changed:** Restricted the Root Cause history claim to the anchored first-commit fact — dropped the unsupported clause "and was carried through later commits unchanged" from the final sentence. No other section touched: Requirements, Success Criteria, Items, Traceability, Cost Frame, Documentation Sources, and all other sections unchanged.
- **Why:** Spec-audit cycle-2 verdict — sole FAIL HOLISTIC-7 Provenance: the diff-range assertion ("carried through later commits unchanged") had no documented verification anywhere in Documentation Sources; only the initial-commit anchor (6581901f, 2026-07-30) is cited. Revision Option B selected per the revise task card's prohibition on analysis/verification steps within this task — Option A (adding a D-7 git-history source) would require live git-history verification that this task does not perform. Finding detail: `tmp/issue-2322/artifacts/spec-audit/verdict.yaml` (HOLISTIC-7, bidirectional finding SPEC_INCOMPLETE).
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Spec-audit cycle-2 remediation).
- **Constraint honored:** No success criterion weakened or removed — SC-1..SC-3 and R-1..R-3 untouched.

---
🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
🤖 Co-authored with AI: OpenCode (x-preview-f-free)
