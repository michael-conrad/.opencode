> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/2322/
>
> **Local artifacts:** `.opencode/.issues/2322/`

## Intent and Executive Summary

- **Problem Statement:** Fix one broken CLI invocation in `.opencode/skills/writing-plans/tasks/research.md` step 12 — the writing-plans research step hard-fails on argument parsing for every plan because the task card passes `solve`-style flags (`--contract-path`, `--output`) to the `plan plan` subcommand, which accepts neither.
- **Root Cause / Motivation:** Tool-model conflation: the task card applied the `solve` tool's `--contract-path` contract-file model to the problem-driven `plan plan` interface. It must be solved now because the defect blocks the research step of the writing-plans pipeline for ALL plans (derivation in §Problem final sentence; D-1, D-8).
- **Approach Chosen:** Replace the defective flags with the problem-driven pattern evidenced by resolved issue `.opencode#2134` (D-4): build `phase-problem.yaml` from the dependency-contract's phase DAG per the mapping in §Definitions, then run the corrected invocation (`--problem` + stdout redirect capturing to `plan-output.yaml`).
- **Alternatives Considered & Why Discarded:** (1) Keep the contract-driven invocation and adapt the `plan` tool to accept `--contract-path`/`--output` — discarded: it accommodates the misapplied invocation instead of fixing the misuse; the subcommand's designed contract is problem-driven (D-1), and tool-surface changes are excluded (see Not Included). (2) Cite resolved issue `.opencode#2166` as the precedent — discarded: its artifacts use a different filename (`plan-problem.yaml`, D-5), so its linkage to this exact pattern is not identical.
- **Key Design Decisions:** (1) The contract→problem construction is fixed in this spec (five numbered mapping steps in §Definitions) — tradeoff: longer spec vs. deterministic implementation with zero implementor inference. (2) Output capture is stdout redirection to `plan-output.yaml` — tradeoff: couples capture to shell semantics vs. matching the tool's stdout-emitting contract (D-3). (3) The step-12 exit criterion is asserted NO-change backed by live verification (D-2, D-6) — tradeoff: smaller diff vs. relying on upstream text staying correct. (4) Precedent citation restricted to `.opencode#2134` — tradeoff: fewer precedents vs. identical-pattern evidence integrity (D-4/D-5).
- **User Intent / Original Prompt:** Session-context recollection at spec creation (no persisted transcript exists — issue comments file empty as of 2026-08-26; D-10): a developer report described the writing-plans research step hard-failing on argument parsing for every plan, in connection with work on `.opencode#2320`. This fix spec was created from that report via the spec-creation pipeline (details in §Problem).

## Problem

`.opencode/skills/writing-plans/tasks/research.md` step 12 instructs `./.opencode/tools/plan plan --contract-path {issues_prefix}/{N}/dependency-contract.yaml --output {issues_prefix}/{N}/artifacts/plan-output.yaml`, but the `plan plan` subcommand takes a required `--problem <YAML>` and an *optional* `--engine <NAME>` (default `tamer`), and has **NO** `--contract-path` or `--output` flags. Verified live 2026-08-25: `./.opencode/tools/plan plan --help` prints `usage: plan plan [-h] --problem PROBLEM [--engine ENGINE]`. The `--contract-path` flag exists only on the `solve` tool and on `plan state update`, not on `plan plan` (full subcommand-surface verification of both tools 2026-08-26; D-7). This defect blocks the research step of the writing-plans pipeline for ALL plans: step 12 sits unconditionally in the task card's mandatory sequential procedure (D-8), and argument parsing rejects the unknown flags with exit code 2 before any planner work executes (D-1).

## Documentation Sources

All facts below were verified live in the implementing sessions — D-1..D-6 on 2026-08-25; D-7..D-10, the D-1 recorded failing invocation, and the D-4 issue-state check on 2026-08-26.

| ID | Source | Type | Location | Verification |
|----|--------|------|----------|--------------|
| D-1 | `plan plan --help` output | API | `.opencode/tools/plan`, subcommand `plan plan` | Live CLI execution |
| D-2 | `plan` tool source, function `_action_plan` | code | `.opencode/tools/plan`, `_action_plan` | Source read |
| D-3 | `plan` tool source, `_action_plan` output block | code | `.opencode/tools/plan`, `_action_plan` output block | Source read |
| D-4 | Resolved issue `.opencode#2134` local artifacts: `dependency-contract.yaml`, `artifacts/phase-problem.yaml`, `artifacts/plan-output.yaml` | doc | `.opencode/.issues/2134/` | Artifact file read; issue state via `gh api repos/michael-conrad/.opencode/issues/2134` → closed (2026-08-26) |
| D-5 | Resolved issue `.opencode#2166` local artifacts listing | doc | `.opencode/.issues/2166/` | Artifact listing read |
| D-6 | `research.md` step 12 invocation and exit criterion | doc | `.opencode/skills/writing-plans/tasks/research.md`, step 12 | File read |
| D-7 | Live CLI help inspection of both tools' complete subcommand surfaces: `./.opencode/tools/solve {check,model,prove,state} --help` and `./.opencode/tools/plan {plan,validate,ground,pddl,discover,help} --help` plus `./.opencode/tools/plan state {init,update,status} --help` | API | `.opencode/tools/solve` (all four subcommands); `.opencode/tools/plan` (all seven subcommands incl. the three `state` sub-subcommands) | Live CLI execution 2026-08-26 |
| D-8 | `research.md` Procedure steps 9–13 and Task Discipline item 1 | doc | `.opencode/skills/writing-plans/tasks/research.md`, steps 9–13 + Task Discipline | File read |
| D-9 | `./.opencode/tools/plan help` output (problem-YAML schema) | API | `.opencode/tools/plan`, subcommand `help` | Live CLI execution 2026-08-26 |
| D-10 | Repo issues-path resolution convention plus local issue-directory inventory (`{2134,2166,2320,2322}`) | doc | `.opencode/AGENTS.md`, "Issues Path Resolution" section; `.opencode/.issues/{2134,2166,2320,2322}/` | File read + directory listing 2026-08-26 |

Verified facts:

- **D-1:** `usage: plan plan [-h] --problem PROBLEM [--engine ENGINE]`; `--problem/-p` is required ("path to YAML problem file"); `--engine/-e` is optional ("planning engine name (default: tamer)"); invoking the subcommand with `--contract-path`/`--output` fails at argument parsing with exit code 2 before any planner work (recorded 2026-08-26)
- **D-2:** Engine default resolves as `args.engine or "tamer"`; success statuses are `SOLVED_SATISFICING` and `SOLVED_OPTIMALLY`; failure statuses (`UNSOLVABLE_PROVEN`, `UNSOLVABLE_INCOMPLETELY`, `TIMEOUT`, `MEMOUT`) exit non-zero via `_die`
- **D-3:** On success, stdout contains a human-readable summary, then a `---` separator, then a YAML document with keys `domain`, `engine`, `status`, `plan_length`, `actions`
- **D-4:** Fully evidenced identical-pattern precedent: contract phases map to problem fluents/actions/goals; `plan-output.yaml` holds the captured stdout YAML (`status: SOLVED_SATISFICING`); issue #2134 state confirmed closed via live API check 2026-08-26
- **D-5:** Uses filename `artifacts/plan-problem.yaml` (not `phase-problem.yaml`) — different artifact naming; NOT cited as an identical-pattern precedent
- **D-6:** The step-12 invocation is the defective call; the step's exit criterion reads "`tools/plan plan` returned SOLVED_SATISFICING or SOLVED_OPTIMALLY" — exactly matching the success status names emitted by the live tool (D-2)
- **D-7:** `--contract-path` appears on all four `solve` subcommands (`check`/`model`/`prove`: required; `state`: optional) and on `plan state update` only (`--contract-path CONTRACT_PATH, -c`, "path to contract YAML for type/domain validation"); it is absent from every other `plan` subcommand, including `plan plan` (which takes only `--problem` and `--engine`)
- **D-8:** Step 9 reads `{issues_prefix}/{N}/artifacts/interface-compatibility.yaml`, extracts its `dependency_contract` section, writes it to `{issues_prefix}/{N}/dependency-contract.yaml`, and returns BLOCKED (`DEPENDENCY_CONTRACT_NOT_FOUND`) when the file or section is missing; step 10 runs `solve model --contract-path … --query sat` and step 11 runs `solve check --contract-path … --state-path {issues_prefix}/{N}/artifacts/state-analysis.yaml`, each blocking on UNSAT; step 12 is the defective invocation (D-6), unconditional within the sequence; step 13 writes `{issues_prefix}/{N}/artifacts/solve-output.yaml` including solve_status, plan_status, SAT/UNSAT per check, and the planner result; Task Discipline item 1 requires every step executed sequentially with none optional
- **D-9:** `plan help` lists exactly seven problem-YAML top-level keys — `domain` (string), optional `types`, optional `objects`, `fluents` (list of `{name}` entries with optional `params`/`type`), `actions` (list of `{name, params, preconditions?, effects?}`), `init` (list of fluents TRUE at start), `goals` (list of fluents to satisfy) — matching the key set and optionality stated in §Definitions
- **D-10:** The Issues Path Resolution table in `.opencode/AGENTS.md` maps the `.opencode` repo path prefix to `.opencode/.issues/{N}/`; live inventory 2026-08-26 confirms `.opencode/.issues/2320/` holds `dependency-contract.yaml` plus pipeline artifacts, `.opencode/.issues/2134/` holds `dependency-contract.yaml` + `artifacts/`, `.opencode/.issues/2166/artifacts/` uses `plan-problem.yaml` (no `phase-problem.yaml`), and `.opencode/.issues/2322/comments.yaml` contains only `comments: []`

## Definitions

- **`{issues_prefix}`**: Path prefix of an issue's local artifacts directory, resolved by repo entry. In this repository's writing-plans pipeline the affected issues live in the `.opencode` submodule, so `{issues_prefix}/{N}` resolves to `.opencode/.issues/{N}` (e.g., `.opencode/.issues/2320`; resolution convention and live inventory: D-10).
- **`{N}`**: The numeric issue number being planned.
- **`dependency-contract.yaml`**: File at `{issues_prefix}/{N}/dependency-contract.yaml`, extracted from `interface-compatibility.yaml`'s `dependency_contract` section by research.md step 9 (D-8). Structure (per D-4): top-level keys `variables` (map of `phase_<k>` boolean variables with descriptions), `preconditions` (list of `z3.Implies(phase_later, phase_earlier)` ordering expressions), `phases` (map of `phase_<k>` → `files` + `scs`), and `edges` (list of `{from, to, rationale}` DAG arcs).
- **Phase DAG**: The directed acyclic graph over phases defined by the contract: nodes are the `variables`/`phases` keys; arcs are the `edges` entries, cross-checked against `preconditions`.
- **`phase-problem.yaml`**: Unified-planning problem file consumed by `plan plan`. Top-level keys (per `./.opencode/tools/plan help` [D-9] and D-4): `domain` (string), optional `types`, optional `objects`, `fluents` (list of `{name}`), `actions` (list of `{name, preconditions?, effects?}` of fluent expressions), `init` (list of fluents TRUE at start), `goals` (list of fluents to satisfy).
- **Corrected invocation**: `./.opencode/tools/plan plan --problem {issues_prefix}/{N}/artifacts/phase-problem.yaml > {issues_prefix}/{N}/artifacts/plan-output.yaml` (raw stdout redirect captures the tool's full stdout — human-readable summary, `---` separator, then the YAML result document per D-3; non-zero exit signals planner failure per D-2).
- **`plan-output.yaml`**: Artifact holding the captured output of the corrected invocation. A raw stdout redirect captures the tool's full stdout — human-readable planning summary, `---` separator, then the YAML result document (D-3); the end-to-end precedent artifact cited as identical-pattern evidence (D-4) holds only the YAML result document itself (`domain`, `engine`, `status`, `plan_length`, `actions`) with no summary or separator, so downstream consumers key on the YAML result-document portion. Downstream consumer: research.md step 13 includes the planner result in `solve-output.yaml` (D-8).

### Dependency-contract → phase-problem mapping

The implementor SHALL construct `phase-problem.yaml` from `dependency-contract.yaml` as follows (mapping evidenced end-to-end by D-4):

1. For each `phase_<k>` key in the contract's `variables`, declare one fluent `- name: phase_<k>` under `fluents`.
2. For each `phase_<k>`, create one action `- name: do-phase-<k>` whose `effects` contain `phase_<k>`.
3. For every ordering constraint requiring `phase_j` before `phase_k` — i.e., each `z3.Implies(phase_k, phase_j)` in `preconditions` and each edge `{from: phase_j, to: phase_k}` in `edges` — add `phase_j` to `do-phase-<k>`'s `preconditions`.
4. Set `init: []` (no phase starts complete) and list every `phase_<k>` fluent under `goals`.
5. Set `domain: issue-{N}-phase-dag`.

## Dependencies

- **P-1**
  - **Reference:** `{issues_prefix}/{N}/dependency-contract.yaml`
  - **Relationship:** Sole structured input to the §Definitions contract→problem mapping consumed by the corrected invocation; without it the phase DAG cannot be constructed. Produced by research.md steps 9–11 (extraction from `interface-compatibility.yaml`, then `solve model` and `solve check` SAT gates; D-8).
  - **Status:** satisfied at step-12 entry time — generated by the immediately preceding pipeline steps on every plan run (every task-card step is mandatory and sequential — D-8); artifact pattern evidenced end-to-end by D-4
- **P-2**
  - **Reference:** `{issues_prefix}/{N}/artifacts/interface-compatibility.yaml`
  - **Relationship:** Upstream source of the `dependency_contract` section extracted at research.md step 9; must exist with a non-empty `dependency_contract` section (step 9 fails BLOCKED otherwise; D-8).
  - **Status:** satisfied at step-12 entry time — same generation chain as P-1; the non-empty-section requirement is enforced upstream by the step-9 BLOCKED gate
- **P-3**
  - **Reference:** `.opencode/tools/plan`
  - **Relationship:** Executes the corrected invocation; the unified-planning problem-YAML schema it consumes is defined in this spec (§Definitions) and by `./.opencode/tools/plan help` (D-9).
  - **Status:** satisfied — live access verified 2026-08-25 by CLI execution (D-1) and source read (D-2)

## Scope

- **In scope:** Fix step 12 in `.opencode/skills/writing-plans/tasks/research.md` to use the correct invocation pattern for the `plan plan` subcommand
- **In scope:** Correct the invocation to build a `phase-problem.yaml` from the dependency-contract's phase DAG per the mapping in §Definitions, then run the corrected invocation (§Definitions) capturing stdout to `plan-output.yaml`
- **In scope:** Record the exit-criterion determination: the step-12 exit criterion requires **NO change** — it already states exactly the two success status names the live tool emits (`SOLVED_SATISFICING`, `SOLVED_OPTIMALLY`; D-2, D-6). This is an asserted-no-change determination backed by live verification, not an implementor decision.

## Not Included

- **Changes to the `solve` tool or its `--contract-path` model** — Rationale: the defect is the writing-plans task card's misuse of solve-style flags, not the `solve` tool itself; correcting the misuse in the task card resolves the failure without touching working tool surfaces.
- **Changes to `plan state update` semantics** — Rationale: the broken surface is exclusively the research.md step-12 `plan plan` invocation (§Problem); altering unrelated subcommand semantics expands blast radius with no bearing on the defect.

## Approach

The task card wrongly applied the `solve` tool's `--contract-path` contract-file model to the `plan` tool. The `plan` tool's `plan plan` subcommand is problem-driven, not contract-driven: it takes a `--problem` YAML file describing the phase DAG (with `--engine` optional, defaulting to `tamer`), and emits the plan to stdout. The corrected pattern — evidenced by resolved issue `.opencode#2134` (`dependency-contract.yaml` → `artifacts/phase-problem.yaml` → `artifacts/plan-output.yaml`, D-4) — is to build a `phase-problem.yaml` from the dependency-contract's phase DAG using the mapping in §Definitions, run the corrected invocation, and capture stdout to `plan-output.yaml`. Issue `.opencode#2166` is deliberately not cited: its artifacts use a different filename (`plan-problem.yaml`, D-5), so its linkage to this exact pattern is not identical.

## Root Cause

The task card conflated two distinct tools with different invocation contracts. `solve` (and `plan state update`) take a `--contract-path` contract file (D-7); `plan plan` takes a `--problem` file and emits output to stdout (captured via redirect). Writing `--contract-path` and `--output` on `plan plan` produces an argument-parsing failure — recorded empirically 2026-08-26 (exit code 2 before any planner work, D-1) — hard-blocking the research step (unconditional task-card step, D-8).

## Impact

- **Risk: research step remains blocked** — Mitigated by fixing the invocation to the verified working pattern (D-1..D-4)
- **Risk: wrong pattern copy-pasted elsewhere** — Mitigated by documenting the correct `plan plan --problem` pattern and the contract→problem mapping in the task card
- **Risk: plan-output.yaml capture semantics ambiguous** — Mitigated by explicitly defining capture (stdout redirect) and content (full stdout per D-3: summary, separator, YAML result document; the cited precedent artifact records the YAML result document alone, D-4)
- **Dependencies:** P-1..P-3 above — the dependency contract and interface-compatibility artifact are upstream products of research.md steps 9–11 (D-8).
- **Call to action:** Review the fix spec, approve for implementation.

## Requirements

R-1. research.md step 12 SHALL invoke `plan plan` problem-driven: `--problem {issues_prefix}/{N}/artifacts/phase-problem.yaml` with stdout redirected to `{issues_prefix}/{N}/artifacts/plan-output.yaml`. The step-12 `plan plan` invocation SHALL NOT reference `--contract-path` or `--output`.

R-2. research.md step 12 SHALL specify how `phase-problem.yaml` is constructed from `dependency-contract.yaml` per the mapping in §Definitions (fluent per contract phase variable; action per phase with preconditions from contract preconditions/edges; empty init; all phase fluents as goals).

R-3. The corrected pattern SHALL execute successfully against the live tool: a `phase-problem.yaml` built per the §Definitions mapping solves with exit code 0 and stdout YAML carrying `status: SOLVED_SATISFICING` or `SOLVED_OPTIMALLY` — the same status names the unchanged step-12 exit criterion requires.

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
| Exit-criterion determination | Asserted no change required (D-2/D-6 factual basis); SC-3 independently confirms the status names the exit criterion states are the ones the tool emits |

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the corrected invocation costs one grep. Skipping means the defective flags survive undetected and the research step keeps hard-failing on argument parsing for every plan.
- **SC-2:** Verifying the construction handoff is documented costs one grep. Skipping means the next implementor must reverse-engineer the contract→problem mapping from `.opencode#2134` artifacts — or guess and reintroduce a divergent, untested construction.
- **SC-3:** Running the live smoke verification costs one tool invocation on a throwaway file. Skipping means the documented pattern is trusted without proof it executes — the identical trust failure that left the defective flags sitting in the current task card (D-6) undetected until live CLI verification (D-1) exposed them.

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
- **Why:** Spec-audit DRAFT verdict — 6 of 11 holistic dimensions FAIL (HOLISTIC-1 Implementability, HOLISTIC-3 Completeness, HOLISTIC-5 Testability, HOLISTIC-6 Escape Hatches, HOLISTIC-7 Provenance, HOLISTIC-10 Traceability) with six bidirectional findings (five SPEC_INCOMPLETE, one SPEC_AMBIGUOUS) recorded in `tmp/issue-2322/artifacts/spec-audit/verdict.yaml` and `judgment.yaml` [judgment.yaml resides at `tmp/issue-2322/artifacts/spec-audit-cycle1/judgment.yaml`]; the gate-block note additionally required Success Criteria, Requirements, Items, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, and preamble sections before re-audit.
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Spec-audit DRAFT verdict remediation).
- **Constraint honored:** No valid success criterion was weakened or removed — the prior spec version contained zero SCs; all SCs in this revision are additions.
- **Date:** 2026-08-26
- **What changed:** Restricted the Root Cause history claim to the anchored first-commit fact — dropped the unsupported clause "and was carried through later commits unchanged" from the final sentence. No other section touched: Requirements, Success Criteria, Items, Traceability, Cost Frame, Documentation Sources, and all other sections unchanged.
- **Why:** Spec-audit cycle-2 verdict — sole FAIL HOLISTIC-7 Provenance: the diff-range assertion ("carried through later commits unchanged") had no documented verification anywhere in Documentation Sources; only the initial-commit anchor (6581901f, 2026-07-30) is cited. Revision Option B selected per the revise task card's prohibition on analysis/verification steps within this task — Option A (adding a D-7 git-history source) would require live git-history verification that this task does not perform. Finding detail: `tmp/issue-2322/artifacts/spec-audit/verdict.yaml` (HOLISTIC-7, bidirectional finding SPEC_INCOMPLETE).
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Spec-audit cycle-2 remediation).
- **Constraint honored:** No success criterion weakened or removed — SC-1..SC-3 and R-1..R-3 untouched.
- **Date:** 2026-08-26
- **What changed:** Deleted the final Root Cause sentence asserting the defect's origin commit ("The defect has been present since the task card's first commit (6581901f, 2026-07-30)."). Root Cause now consists solely of live-verifiable present-state facts — the tool-contract conflation and its argument-parsing failure hard-blocking the research step — each backed by Documentation Sources live verification (D-1, D-2, D-6). No other section touched.
- **Why:** Spec-audit cycle-3 verdict — sole FAIL HOLISTIC-7 Provenance: the first-commit anchor had zero supporting evidence in Documentation Sources (no git-history verification row among D-1..D-6); evaluator classified it FABRICATED under the factual-claim-without-source meta-rule. Revision Option A selected — delete the non-load-bearing anchor (D-1/D-6 establish the defect against current state live) — over adding a D-7 git-history row, which would require an investigation step outside the revise task card's constraints. Finding detail: `tmp/issue-2322/artifacts/spec-audit/verdict.yaml` (HOLISTIC-7 FAIL; bidirectional finding SPEC_INCOMPLETE).
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Spec-audit cycle-3 remediation).
- **Constraint honored:** No valid success criterion weakened or removed — SC-1..SC-3 and R-1..R-3 untouched; Requirements, Success Criteria, Items, Traceability, Cost Frame, Documentation Sources, and all other sections unchanged.
- **Date:** 2026-08-26
- **What changed:** Deleted the Cost Frame SC-3 bullet's origin-attribution clause ("the same trust failure that shipped the original defective flags (6581901f)") and replaced it with the present-state equivalent grounded in live Documentation Sources (D-1, D-6): "the identical trust failure that left the defective flags sitting in the current task card (D-6) undetected until live CLI verification (D-1) exposed them." Exhaustive whole-spec sweep for the 6581901f git-history claim found no other live occurrence: the remaining mentions sit inside the Change Control audit trail (cycle-2/cycle-3 entries quoting previously deleted sentences as revision records, backed by their cited verdict artifacts). No other section touched.
- **Why:** Spec-audit cycle-4 verdict — sole FAIL HOLISTIC-7 Provenance: the Cost Frame SC-3 bullet cited commit 6581901f as origin of the defective flags with zero supporting Documentation Sources row covering git history (D-1..D-6 cover CLI help, tool source facts, precedent inventories, and research.md lines only); the identical claim class was classified FABRICATED and deleted from Root Cause in cycle 3, and this sole occurrence survived. Revision Option A selected — the anchor is non-load-bearing for the cost frame, mirroring the cycle-3 Option A rationale (D-1/D-6 establish the defect against current state live); adding a D-7 git-history row would require an investigation step outside the revise task card constraints (rejected in cycles 2-3 for exactly that reason). Finding detail: `tmp/issue-2322/artifacts/spec-audit/verdict.yaml` (HOLISTIC-7 FAIL).
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Spec-audit cycle-4 remediation).
- **Constraint honored:** No valid success criterion weakened or removed — SC-1..SC-3 and R-1..R-3 untouched; Requirements, Success Criteria, Items, Traceability, Documentation Sources, and all other sections unchanged except the single Cost Frame SC-3 bullet.
- **Date:** 2026-08-26
- **What changed:** Four structural remediations from the spec-audit cycle-5 verdict: (1) restructured P-1..P-3 under the canonical `Dependencies` heading, each entry gaining explicit Reference/Relationship/Status fields; (2) rebuilt the Documentation Sources table into the canonical Source/Type/Location/Verification column set, moving each D-row's verified facts beneath the table — facts preserved verbatim (D-6 restated with stable anchors in place of line numbers); (3) expanded `Intent and Executive Summary` into the six mandated labeled fields — adding Alternatives Considered & Why Discarded, Key Design Decisions, and User Intent / Original Prompt derived from existing §Approach/§Problem content — and added the mandated `Not Included` section with per-exclusion rationales (the two out-of-scope bullets moved there from `Scope`); (4) replaced all six file-path+line-number locators with stable anchors (step numbers / named sections): Problem, D-6, Scope, R-3, Traceability, and this section's cycle-4 entry. No other sections touched: Requirements, Success Criteria table, SC Enforcement Gate, Items, Traceability mappings, and Cost Frame unchanged.
- **Why:** Spec-audit cycle-5 verdict — holistic gate PASS; four narrow criteria FAIL: SC-5 (Dependencies entries lacked Status fields; section title deviated from canonical), SC-11 (Documentation Sources used non-canonical columns), SC-12 (preamble lacked the six mandated fields; `Not Included` section absent), SC-PRESCRIPTIVE-CODE (six path+line-number locators violating Prohibited Content Patterns). Finding detail: `tmp/issue-2322/artifacts/spec-audit/verdict.yaml`.
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Spec-audit cycle-5 remediation).
- **Constraint honored:** No valid success criterion weakened or removed — SC-1..SC-3 and R-1..R-3 untouched; all verification methods, evidence types, and Items TDD cycles unchanged.
- **Date:** 2026-08-26
- **What changed:** Remediated the two HOLISTIC-7 unsupported assertions flagged by spec-audit cycle 6. (1) Added Documentation Sources row D-7 with its verified fact — live 2026-08-26 CLI inspection of both tools' complete subcommand surfaces confirming `--contract-path` appears on all four `solve` subcommands (`check`/`model`/`prove` required; `state` optional) and on `plan state update` only (optional `-c`), absent from every other `plan` subcommand including `plan plan` — and cited D-7 at the §Problem exclusivity sentence and the Root Cause echo; updated the section's verification-date preamble to cover both dates. (2) Deleted the present-tense blocking parentheticals "(including `.opencode#2320`)" from the preamble Root Cause / Motivation bullet and the §Problem final sentence — live `gh api repos/michael-conrad/.opencode/issues/2320` verification 2026-08-26 returned state=closed with zero comments, so no current blocking-state assertion is supportable; the User Intent field retains the historical developer-report framing of that impact. No other sections touched: Definitions, Dependencies, Scope, Not Included, Approach, Impact, Requirements, Success Criteria, SC Enforcement Gate, Traceability, Cost Frame, Items unchanged.
- **Why:** Spec-audit cycle-6 verdict — sole FAIL HOLISTIC-7 Provenance with two unsupported live-body factual assertions: (a) the solve-tool conjunct of the `--contract-path` exclusivity sentence had no Documentation Sources row covering the solve-tool binary; (b) the `.opencode#2320` blocking-impact assertion appeared at three locations with no D-row evidencing that issue's state. Dispatch authorized live self-verification first: claim (a) held under full-surface inspection → revision Option B applied (D-7 added with verification date and method); claim (b) failed against live issue state → Option A applied (asserted issue-state claims deleted). This closes the recurring fabricated-claim class from cycles 3–6. Finding detail: `tmp/issue-2322/artifacts/spec-audit/verdict.yaml` (HOLISTIC-7 FAIL; bidirectional finding SPEC_INCOMPLETE).
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Spec-audit cycle-6 remediation).
- **Constraint honored:** No valid success criterion weakened or removed — SC-1..SC-3 and R-1..R-3 untouched; all evidence types, verification methods, Items TDD cycles, Traceability mappings, and Cost Frame unchanged.
- **Date:** 2026-08-26
- **What changed:** Systematic whole-body claim-inventory remediation from the spec-audit cycle-8 structural diagnostic (four consecutive HOLISTIC-7 Provenance FAILs, cycles 3/4/6/7; exhaustive 26-claim enumeration at `tmp/issue-2322/artifacts/spec-audit-cycle8/structural-defect-report.yaml`), with every claim live-re-verified during this revision. (1) Added Documentation Sources rows D-8 (`research.md` Procedure steps 9–13 process behavior + Task Discipline item 1, file read), D-9 (`plan help` problem-YAML schema output, live CLI execution), D-10 (repo issues-path resolution convention plus local issue-directory inventory including empty `.opencode/.issues/2322/comments.yaml`); extended D-4's Verification to include the #2134 issue-state API check (closed, 2026-08-26) and D-1's facts with an empirically recorded failing invocation of the defective flags (exit code 2). Cited the rows at every previously unbacked claim site: D-8 at §Definitions dependency-contract extraction, plan-output downstream consumer, P-1 production chain, P-1 status universality, P-2 step-9 BLOCKED gate, §Impact upstream-products bullet; D-9 at the §Definitions problem-schema clause and P-3; D-10 at the `{issues_prefix}` definition; derivation citations (D-1/D-8) added to both ALL-plans universality claims (Intent Root Cause bullet, §Problem final sentence). (2) Corrected the §Definitions `plan-output.yaml` content description — raw stdout capture carries summary + separator + YAML document per D-3, while the cited precedent artifact (D-4) holds only the YAML result document — the prior text asserted the former shape while citing the latter as its evidence; aligned the Corrected-invocation capture clause and the §Impact risk-3 mitigation to the same distinction. (3) Reworded User Intent / Original Prompt to an explicitly marked session-context recollection with disclosure that no persisted transcript exists, removing the residual present-tense "blocking `.opencode#2320`" participle (#2320 verified closed with zero comments 2026-08-26). (4) Audit-trail flag dispositions: annotated the cycle-1 entry's `judgment.yaml` citation with its actual location (`spec-audit-cycle1/`); left the cycle-2/3/4 quoted sentences' first-commit anchor (6581901f) untouched as non-load-bearing revision records inside quotation marks backed by their cited verdict artifacts — the inference that this commit introduced the defective flags remains unverified and is deliberately NOT promoted into Documentation Sources.
- **Why:** Spec-audit cycle-8 structural diagnostic — four consecutive HOLISTIC-7 FAILs shared one root cause set: reactive per-section remediation never swept the whole body for checkable assertions; D-6's step-12-only scope structurally excluded all steps 9–11/13 claims; §Definitions/§Dependencies carried pre-discipline legacy process narrative born without sourcing obligations; and no prior cycle cross-checked claim text against the content of cited evidence artifacts (the C-16 contradiction). Dispatch instructed one-pass remediation of the entire enumeration with per-claim live re-verification.
- **Who authorized:** Orchestrator dispatch of the spec-creation `revise` task for issue 2322 (revision_reason: Tier-2 structural remediation following four consecutive HOLISTIC-7 Provenance FAILs).
- **Constraint honored:** No valid success criterion weakened or removed — SC-1..SC-3, R-1..R-3, Items TDD cycles, Traceability mappings, Cost Frame, Scope, Not Included, and SC Enforcement Gate unchanged; revisions confined to the provenance/content-description finding class.

---
🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
🤖 Co-authored with AI: OpenCode (x-preview-f-free)
