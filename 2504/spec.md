# [SPEC] Vendored formal tooling: z3 + unified-planning via `.tools/` adapters, one state format, progressive skill card

**Repo**: michael-conrad/.opencode · **Scope**: replace `tools/plan` + `tools/solve` with vendored engines and thin adapters · **Remote**: https://github.com/michael-conrad/.opencode/issues/2504

## Problem Statement

The bespoke planning/solving tooling is defective in design, not merely buggy:

1. **Design defect — duplicated concerns.** `tools/plan` (1,029 lines wrapping `unified-planning` + `up-tamer` + `networkx`) and `tools/solve` (478 lines wrapping `z3-solver`) each implement their own `state` subcommand with **different YAML state formats**, and their operational semantics overlap without agreement. The developer's observed failure: "the apps conflict with each other."
2. **Known open defects** (survived the 2026-10-05 sweep as KEEP):
   - #1168 — `solve state init` rejects `--var-name/--var-value`; two-step dance persists (`solve:322`).
   - #1169 — `solve` asserts preconditions as permanent constraints in model queries (`solve:232-234`).
   - #1170 — `plan` defaults `engine = "tamer"` with no kind-based auto-selection (`plan:521/953`).
   - #1171 — `plan` has no fallback when the planner returns `UNSOLVABLE_INCOMPLETELY` (`plan:560`).
3. **Unnecessary bespoke surface.** Live verification (2026-10-05, executed on this machine) shows the operations these tools perform are covered by mature off-the-shelf tooling:
   - **Z3 5.1.0** (MIT; prebuilt `z3-5.1.0-x64-glibc-2.39.zip`) consumes SMT-LIB2 natively: `check-sat`, `get-model`, `get-unsat-core` with `:named` assertions returning clause identifiers — verified end-to-end by execution. Zero solver-logic code is required.
   - **unified-planning 1.3.0** (Apache-2.0; released 2025-12-17; actively maintained) ships its own `up` console CLI with `oneshot-planning`, `plan-validation`, and `compile` (grounding) modes plus PDDL I/O — duplicating most of the bespoke wrapper's plan/validate/ground/pddl subcommands.
   - **VAL** (BSD-3-Clause) provides standalone plan validation (and grounding via `Instantiate`, parsing via `Parser`) with PDDL files as the interchange format.

The deck's progressive-disclosure architecture (#2501) requires that specialized tooling be **routed and loaded on intent**, not always-injected — which is also the fix for the tools' discoverability and usage drift.

## Success Criteria

All SCs verified with real executed output. Behavioral SCs run in the repo (fresh `uv run` invocations); structural SCs are fact-decidable checks.

- **SC-1 — Vendored z3, no solver logic.** `.tools/` contains the vendored z3 binary (5.1.0 or later) with its MIT license notice, and a thin adapter script. The adapter contains **no satisfiability/proof logic** — it only translates YAML contract/state into SMT-LIB2, execs the binary, and surfaces results. Structural: file inventory + the adapter's code contains no solver construction beyond emitting SMT-LIB2 text and parsing solver output.

- **SC-2 — Solver operations via vendored binary (behavioral).** Executed runs demonstrate:
  - `check`: a state violating a contract clause returns `unsat` and `get-unsat-core` names the violated contract clause(s).
  - `model`: a satisfiable query returns `sat` and a usable model (satisfying assignment surfaced in tool output).
  - `prove`: preconditions ∧ invariants ∧ ¬query yields `unsat` (proof of query); a false query yields `sat` (refutation).
  Evidence: actual command transcripts committed as test fixtures under `.opencode/tests-v2/`.

- **SC-3 — Planning via `up` (behavioral).** Plan generation, plan validation, and grounding execute through unified-planning's `up` CLI (pip dependency declared in the adapter; no bespoke planner logic). A sample domain/problem generates a plan; the plan validates against the domain; `compile` grounds a schema. Evidence: executed transcripts.

- **SC-4 — One state format.** Exactly one YAML state schema exists, owned in one place, consumed by both the solver adapter and the planning path. The two current conflicting `state` subcommands are gone. Structural: grep finds a single state-schema definition; behavioral: a state file written by one path round-trips through the other.

- **SC-5 — Progressive skill card.** Exactly one deck card exists for the formal tooling with a two-level intent description (domain-level: "workflow correctness / constraint solving / planning"; implementation-level: named operations). The card body carries **runbook-grade usage content as part of its progressive text** — exact commands per operation, expected outputs (unsat + named unsat-core; sat + model; plan file + validation pass), decision points (when solving vs. planning applies), and a single maintenance line for refreshing the vendored binary. It does not duplicate tool `--help` content verbatim and holds no installation ceremony for the already-vendored binary (installation is SC-1's concern). The card is routed from `routing.md`, not injected by `floor.md`/`prompts/default.txt`. Card authored via the deck-governance admission gate (observed failure + consumer + mechanism + predicate classification). Structural: routing.md entry present; floor.md unchanged in injection surface; card body contains the usage commands.

- **SC-6 — Disposition of the replaced tools.** `tools/plan` and `tools/solve` are `git mv`'d to `attic/tools/`; no live reference to either path remains outside `attic/`, `CHANGELOG.md`, and the issue store. Structural: grep.

- **SC-7 — Defect tickets resolved.** #1168, #1169, #1170, #1171 are each either (a) moot because the defective code is retired, or (b) fixed in the new tooling. Behavioral: for any kept-fixed case, the defect scenario is re-run against the new tooling and passes. Closure of the tickets follows delivered work.

- **SC-8 — License compliance.** Vendored artifacts carry their upstream license notices (z3: MIT; declared pip deps: unified-planning Apache-2.0). No GPL-licensed code is vendored into the repository. Structural: license files present next to vendored binaries; no GPL code copied.

- **SC-9 — Root-agnostic tooling.** The adapter and skill card contain no hardcoded repo names or absolute paths; paths are resolved from the tool's own location or arguments. Structural: grep for root-repo names/absolute paths in new files.

## Requirements

1. **REQ-1**: Create `.tools/` with the vendored z3 binary and the thin SMT-LIB2 adapter supporting `check`, `model`, `prove` operations over YAML contract/state files.
2. **REQ-2**: The adapter generates SMT-LIB2 with `:named` assertions per contract clause so unsat-cores identify violated clauses by name.
3. **REQ-3**: Planning path uses unified-planning's `up` CLI (pip-declared) for oneshot-planning, plan-validation, and compile/grounding; adapter generates domain/problem PDDL from the shared state/problem input.
4. **REQ-4**: Define one shared YAML state schema; single owner; both paths consume it. Migrate or map any state files needed by remaining consumers.
5. **REQ-5**: Author one progressive skill card via deck governance; its body embeds the runbook-grade usage content (commands, expected outputs, decision points, one binary-refresh maintenance line) as part of the card's progressive text — no separate usage documents. Add routing.md entry; do not touch floor.md.
6. **REQ-6**: Retire `tools/plan` and `tools/solve` to `attic/tools/`; sweep live references.
7. **REQ-7**: Close or fix #1168–#1171 per SC-7.
8. **REQ-8**: Include license notices for vendored artifacts; declare pip dependencies in the adapter's PEP 723 header.

## Non-Goals

- **No GPL vendoring** — Fast Downward (GPL-3) stays outside the repository if ever used.
- **No schema-discovery feature parity** — the bespoke "discover action schemas from state transitions" feature is dropped unless a demonstrated consumer requires it (none observed in the sweep).
- **No changes to skildeck** — deck formal analysis is a separate concern, out of scope.
- **No changes to the pipeline stages** — spec → plan → implement → PR remain; this spec only changes the tooling those stages may call.
- **No numeric size targets** — adapter size derives from the translation need (SC-1 bounds it structurally).

## Alternatives Considered

- **cvc5 1.4.1** (BSD) instead of z3 — same vendoring shape; chosen against: z3 verified end-to-end on this machine; cvc5's differentiator (externally checkable CPC proofs) not currently required.
- **OR-Tools CP-SAT** — no SMT-LIB2, no prove operation; would keep a full Python application layer (the defect being removed).
- **pySMT** — dormant stable release (0.9.6, 2024); adds a wrapper layer rather than deleting one.
- **Fast Downward vendored** — GPL-3 boundary risk in a public repo; rejected for vendoring; usable as an external dependency later if needed.
- **Keep-and-patch the existing tools** — rejected: the state-format conflict and duplicated concerns are design defects; patching #1168–#1171 leaves the architecture that produced them.

## Traceability

| Requirement | SCs | Source |
|---|---|---|
| REQ-1, REQ-2 | SC-1, SC-2, SC-8, SC-9 | Developer: "proper … z3 tool set … placed in .tools/"; research: z3 SMT-LIB2 native execution |
| REQ-3 | SC-3 | Research: UP `up` CLI modes; developer: inconsistent/buggy current plan tool |
| REQ-4 | SC-4 | Developer: "the apps conflict with each other" |
| REQ-5 | SC-5 | Developer: "proper progressive skill for usage" |
| REQ-6, REQ-7 | SC-6, SC-7 | Developer: "defective in design"; sweep KEEP tickets #1168–#1171 |
| REQ-8 | SC-8 | License boundary established in research |

> **Full spec and artifacts**: `.opencode/.issues/2504/` — this file is the authoritative spec.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
