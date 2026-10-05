# Implementation Plan — .opencode#2504

**Spec**: `.opencode/.issues/2504/spec.md` · **Branch**: `feature/2504-vendored-formal-tooling` (stacked on `feature/2505-approved-for-pr-phases`) · **Base tip**: 57c0db21

One item per SC; dependency-ordered; each instrument is an executable check.

## P-1 — SC-1 + SC-8 (foundation: vendored z3 + license)

- **Deliverable**: `.tools/z3/` containing the vendored z3 5.1.0 prebuilt linux-x64 binary and its MIT `LICENSE.txt` (from the release zip).
- **RED**: `ls .tools/z3/` fails — no vendored binary exists today.
- **GREEN**: install `z3-5.1.0-x64-glibc-2.39.zip` (Z3Prover/z3 release) into `.tools/z3/` — **`.tools/` is gitignored and NOT committed** (developer directive); the skill card's runbook carries the install instructions agents execute on demand. The committed deliverable is the card's install/refresh runbook text.
- **Instrument**: `.tools/z3/z3 --version` prints `Z3 5.1.0`; `LICENSE.txt` present; `git check-ignore .tools/z3/z3` confirms exclusion from version control.

## P-2 — SC-4 + SC-9 (shared state schema, single owner)

- **Deliverable**: `tools/formal` (committed uv script — deviation from the spec's `.tools/` path recorded: the developer directed that nothing under gitignored `.tools/` is committed, so the versioned adapter lives beside the other agent tools and resolves the vendored binary under `.tools/` from its own location) with `state init/update/status` subcommands; schema documented in the card body; no repo names/absolute paths in the code.
- **RED**: `grep -c "def _action_state" tools/plan tools/solve` → 2 definitions with 2 conflicting formats; `tools/formal` does not exist.
- **GREEN**: single schema in `tools/formal`: `variables` (name → typed value or `{type: ...}` decl), one `state` subcommand location; `init` accepts `--var name=value` (resolves #1168's two-step defect); paths resolved from the script's own location/args.
- **Instrument**: `grep -rn "def _action_state\|state_sub" tools/` finds exactly one definition; `tools/formal state init --var phase_a=true` writes the file in one step.

## P-3 — SC-1 + SC-2 (solver adapter: check/model/prove via vendored binary)

- **Deliverable**: `tools/formal` (PEP 723 uv script, deps only `pyyaml`) with `check`, `model`, `prove` subcommands that translate YAML contract/state into SMT-LIB2 with `:named` assertions (one per clause), exec the vendored binary at `.tools/z3/z3`, parse stdout. Contract clause syntax is SMT-LIB2 s-expressions (e.g. `(=> a b)`); no z3 Python bindings, no satisfiability logic — translation + subprocess + parsing only.
- **RED**: `./tools/formal check --state s.yaml --contract c.yaml` → file not found.
- **GREEN**: implement translation; exec `z3 -in -model` with an SMT-LIB2 script on stdin; parse `sat`/`unsat`, `(get-unsat-core)` names, `(get-model)` assignments; surface in output.
- **Instrument** (behavioral transcripts committed under `tests-v2/`):
  - `check`: state violating a named clause → `unsat` + core names the clause.
  - `model`: satisfiable query → `sat` + assignment lines.
  - `prove`: true theorem → `VALID` (unsat of pre ∧ inv ∧ ¬q); false theorem → `INVALID` (sat).

## P-4 — SC-3 (planning via `up`)

- **Deliverable**: `tools/formal plan|validate|ground` subcommands that generate PDDL domain/problem from the shared YAML input and invoke unified-planning's `up` CLI (`uv run --with unified-planning up ...` per PEP 723 dependency declared in the script); no bespoke planner logic.
- **RED**: `./tools/formal plan --domain d.pddl --problem p.pddl` → unsupported subcommand.
- **GREEN**: implement via `up oneshot-planning`, `up plan-validation`, `up compile --mode grounding`; print the plan and validation verdict.
- **Instrument**: executed run on a sample `blocks`-style domain/problem: plan file printed, validation returns valid, grounding succeeds; transcript committed.

## P-5 — SC-5 (progressive skill card + routing)

- **Deliverable**: `skills/formal-tooling/SKILL.md` — deck-authored card, admission gate satisfied (#2504 spec: observed failure = the design defect + session conflict; consumer = agent routing solving/planning work; mechanism = routing.md entry; predicate = intent-decidable; root-agnostic; replaces `tools/plan`/`tools/solve` usage knowledge). Body carries runbook-grade usage: exact commands per operation, expected outputs (unsat + named core; sat + model; plan + validation pass), decision point (solving vs planning), one maintenance line (how to refresh the vendored binary). Frontmatter `name`, `description` (two-level intent), `license`; provenance line.
- **RED**: `ls skills/formal-tooling` fails; `routing.md` has no entry.
- **GREEN**: author card; add routing.md row; floor.md untouched.
- **Instrument**: `grep "formal-tooling" routing.md` → 1 entry; `grep -c "approved\|loading" floor.md` unchanged injection surface (floor.md diff vs stacked base touches only the #2505 vocabulary line); card body contains the commands.

## P-6 — SC-6 + SC-7 (disposition + defect tickets)

- **Deliverable**: `git mv tools/plan tools/solve → attic/tools/`; sweep live references; close #1168, #1169, #1170, #1171 as moot-by-replacement (defective code retired; replacement semantics fix the defects: #1168 via `state init --var`, #1169 via prove asserting only pre∧inv as assumptions — postconditions not asserted, #1170/#1171 moot — `up` CLI owns engine selection and status handling).
- **RED**: `tools/plan` and `tools/solve` present with live references.
- **GREEN**: move + sweep; ticket closures ride post-merge per closure policy — record resolution rationale in the issue store now.
- **Instrument**: `grep -rn "tools/plan\|tools/solve" --exclude-dir=attic --exclude-dir=.issues --exclude-dir=node_modules --exclude-dir=tests-v2 .` → empty; `git ls-files attic/tools/` shows both.

## P-7 — verify pass + PR

- Full SC sweep with executed transcripts; PR per issue (#2505 first, #2504 stacked on top); halt for human merge.

## Traceability

P-1→SC-1,8 · P-2→SC-4,9 · P-3→SC-1,2 · P-4→SC-3 · P-5→SC-5 · P-6→SC-6,7 · P-7→all
