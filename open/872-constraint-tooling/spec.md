## Problem

The existing `sym-*` tools (`conflicts`, `flow`, `states`, `complete`, `drift`, `analyze`, etc.) at `.opencode/tools/impl/sym-*` are functional but **dead** — the AI agent never discovers or dispatches them because no guideline provides trigger keywords for their use. They are also hidden behind a single `symbolic` dispatcher whose name evokes "symbolic math" or "symbolic execution" — neither of which matches what the tools actually do.

They also use `sympy` as the SAT engine. SymPy is boolean-only (`satisfiable`) — it cannot express integer resource bounds, real-valued timing constraints, quantified invariants, or bitvector protocol constraints that emerge when AI agents write entire applications from specs. Z3 handles all of these. The existing tools need to be migrated to Z3 for a unified engine.

Beyond that: specs and plans today encode success criteria and interdependencies in prose tables only. There is no machine-readable constraint block scoped to each issue. No tool can verify coverage, detect cross-SC contradictions, or validate phase sequencing against dependencies. Every session requires the agent to re-encode the same constraints by hand.

This spec addresses all three layers.

## Design

### Two Dispatchers for Two Families

Two separate dispatch points, two clear semantic mappings, zero confusion about which handles which task:

**`rules`** — Operates on `yaml+symbolic` rule blocks embedded in guideline `.md` files and spec/plan constraint blocks. Static analysis of rules, states, and dependencies.

| Action | What It Does |
|--------|-------------|
| `rules conflicts` | Detect contradictory rule conditions (HALT vs PROCEED overlap) |
| `rules flow` | Trace activation flow through rule chains |
| `rules states` | State machine extraction from rule blocks |
| `rules complete` | Coverage/entailment checks — do all states have rules? |
| `rules drift` | Detect spec drift between rule blocks and implementation |
| `rules analyze` | Full structural analysis of rule blocks |
| `rules extract` | Extract yaml+symbolic blocks from .md files |
| `rules extract-dot` | Extract DOT graph representation |
| `rules report` | Generate HTML+SVG analysis report |
| `rules guards` | Guard condition analysis |
| `rules triggers` | Trigger pattern analysis |
| `rules enforcement` | Enforcement gate coverage checks |
| `rules decomposition` | Rule block decomposition analysis |
| `rules exhaustive` | Exhaustive pairwise SAT contradiction analysis |

**`solve`** — Operates on agent-written YAML constraint files in `./tmp/` or `.issues/`. General-purpose SAT/UNSAT for spec validation, dependency checking, deadlock detection.

| Action | What It Does |
|--------|-------------|
| `solve` | Z3 constraint solving from YAML constraint files — SAT/UNSAT with model or unsat core |

The agent's mental model:
- "I see a contradiction in these guidelines" → `rules conflicts`
- "I need to verify my component dependencies are consistent" → `solve --file`

### Artifact Layout: `.issues/` Issue Directories

Each issue already has a directory under `.issues/` (e.g., `.issues/open/872-constraint-tooling/`). The constraint block lives in its own file alongside the prose spec:

```
.issues/
  artifacts/
    global-constraints.yaml      # project-wide invariants, auto-loaded on every solve
  open/
    872-constraint-tooling/
      spec.md                    # prose — clean, readable
      constraints.yaml           # yaml+symbolic block — machine-readable
      comments.md
      state.md
```

**Issue-specific constraints** go in the issue's `constraints.yaml`. The `spec.md` stays clean prose — no bloat.

**Project-wide constraints** go in `.issues/artifacts/global-constraints.yaml`. These are invariants that cross all specs (e.g., "exactly one input handler", "GPU state always synchronized"). The solver auto-loads this file for every `solve` run unless `--no-global` is passed. This catches cross-spec contradictions at spec time, not at integration time.

Constraints with `scope: global` in an issue's `constraints.yaml` are extracted into `global-constraints.yaml` automatically by the toolset — the agent never manages that file manually.

### Solver I/O: `./tmp/` for Session Execution

The solver reads from a temp copy and writes results to `./tmp/`:

```
Agent extracts: ./tmp/solve-<N>.yaml        # from .issues/.../constraints.yaml
Solver reads:   ./tmp/solve-<N>.yaml
Solver writes:  ./tmp/solve-<N>.out          # natural language + structured YAML
Agent reads:    ./tmp/solve-<N>.out
```

The source of truth is always the `constraints.yaml` in the issue directory. The `./tmp/` copies are ephemeral working copies — cleanable after the session.

### I/O Discipline

- **File-only inputs.** No inline constraint flags.
- **YAML input format.** `pyyaml` declared at script level in PEP 723 dependencies — zero project dep changes.
- **File output.** Natural language verdict first (prose the LLM reads directly), structured data (model assignments, unsat core labels) as YAML after `---`.
- **No human-facing output.** Only the LLM reads this. One channel, natural language.
- **Exit codes:** 0 = SAT, 1 = UNSAT, 2 = timeout/error.

### Example Workflow

```bash
# 1. Agent extracts constraints from issue directory to temp
cp .issues/open/872-constraint-tooling/constraints.yaml ./tmp/solve-872.yaml

# 2. Solve (auto-loads global-constraints.yaml + issue constraints)
./.opencode/tools/solve --file ./tmp/solve-872.yaml

# 3. Read result
cat ./tmp/solve-872.out
```

```yaml
# .tmp/solve-872.out
status: SAT
---
SAT. All constraints satisfiable. Model:
  turn_p1: true
  player_alive: true
  can_act: true
```

### Universal `yaml+symbolic` Constraint Schema

Extend the existing `yaml+symbolic` rule-block format to support a richer ontology applicable to any domain — games, APIs, CI/CD, data pipelines, greenfield, brownfield, any language/platform.

Core primitives that recur across all domains:

| Primitive | Description | Example |
|-----------|-------------|---------|
| Entities | Systems, modules, components, services that exist | RenderSystem, AuthMiddleware, BuildPipeline |
| States | Valid states each entity can occupy | idle, active, blocked, error |
| Transitions | Valid state changes with pre/postconditions | idle to active requires(initialized) |
| Dependencies | Ordering, initialization, ownership | CombatSystem depends_on TurnManager |
| Resources | Shared resources with mutual exclusion | InputBuffer, GPUContext, DatabaseConnection |
| Invariants | Properties that must always hold | ExactlyOne(active_turn) |
| Timing | Sequence constraints, deadlines, durations | CombatPhase before ResolutionPhase |

As constraints grow beyond boolean logic (integer resource bounds, real-valued timing, quantified invariants, bitvector protocols), the schema adds new primitives. Z3 handles all of them — no engine swap needed.

### Engine: Z3

Z3 is the sole solver engine behind `solve`. Microsoft Research, most feature-rich Python SMT bindings, actively maintained. Covers boolean logic (current scope), integer/real arithmetic, bitvectors, arrays, quantifiers, floating-point, strings (future scope). `z3-solver` installed via PEP 723 script dependencies — no project-level changes.

All existing `sym-*` scripts currently use `sympy` for boolean SAT. They will be migrated to Z3 and renamed to `rules-*` scripts under a `rules` dispatcher.

Research confirms no viable alternative covers the same growth path:
- SymPy: boolean only — blocking for future integer/timing/quantifier constraints
- PySAT (`python-sat`): boolean only — same limitation
- PySMT: abstraction layer over multiple solvers — adds complexity, still needs Z3 binary
- CVC5: viable but fewer resources, less community, smaller Python ecosystem
- Yices: viable but Z3 dominates in Python maintenance and community support

### Two Extraction Modes for Generating Constraint Blocks

Both modes produce the same output: a `constraints.yaml` in the issue's `.issues/` directory. The agent chooses the mode based on context, never presenting a pop-quiz.

**Mode A — Autonomous (conversation + code inspection):** Agent listens to the conversation, inspects the codebase, and infers the formal constraints without asking questions. The constraint block appears in `constraints.yaml` alongside `spec.md`. The developer reviews and corrects it.

**Mode B — Guided (structured refinement):** Agent says something like "From what you described, I'm seeing three timing constraints and one resource conflict. Let me lay out what I've inferred so you can correct me:" then presents the draft constraints in conversation. The developer amends naturally. The agent writes the final version to `constraints.yaml`.

### Single Guideline Covers Both Dispatchers

One guideline file covers both `rules` and `solve`. The guideline provides trigger keywords for each:

- `rules conflicts` — "contradictory guidelines", "rule conflict", "HALT vs PROCEED"
- `rules flow` — "activation chain", "rule propagation"
- `rules states` — "state machine extraction", "state transitions"
- `rules analyze` — "analyze rule blocks"
- `rules complete` — "coverage check", "entailment"
- `rules drift` — "detect drift"
- `rules extract` — "extract symbolic rules"
- `rules report` — "generate report"
- `rules triggers` — "trigger analysis"
- `solve` — "constraint solving", "SAT", "UNSAT", "consistency check", "dependency validation", "deadlock", "interdependency"

This is mandatory: without the guideline, both tool families are dead. The guideline ships in the same commit as the migration and new `solve` tool.

### Future: Pipeline Integration

| Stage | What Happens |
|-------|-------------|
| 1 | Agent writes spec + `constraints.yaml` (Mode A or B) in `.issues/open/<issue>/` |
| 2 | `solve --file <issue>/constraints.yaml` validates internal consistency (auto-loads `global-constraints.yaml`) |
| 3 | `rules conflicts` across all issue constraint files detects cross-spec contradictions |
| 4 | Agent generates code from verified spec |
| 5 | Spec revision results in re-solve to check downstream consumer breakage |

## Phases

### Phase 1: Engine migration + `rules` dispatcher + `solve` tool + guideline (single commit)
- Item: Migrate existing `sym-*` implementations from `sympy` to `z3-solver` — `sym-conflicts`, `sym-exhaustive`, and any other scripts using `sympy`
- Item: Rename `sym-*` scripts to `rules-*` (e.g., `sym-conflicts` → `rules-conflicts`, `sym-flow` → `rules-flow`)
- Item: Create `rules` dispatcher at `.opencode/tools/rules` (PEP 723, replaces `symbolic` dispatcher)
- Item: Create standalone `solve` tool at `.opencode/tools/solve` (PEP 723, `z3-solver` + `pyyaml>=6.0`)
- Item: Implement `solve --file <yaml>` for YAML constraint input with Z3 expression parsing
- Item: Implement `solve --no-global` flag to skip auto-loading `global-constraints.yaml`
- Item: Implement `solve --timeout <ms>` (default 30000) and timeout handling
- Item: Implement `solve --track-unsat` for unsat core tracking; output natural-language verdict + structured YAML after `---`
- Item: Implement exit codes (0=SAT, 1=UNSAT, 2=timeout/error) and error handling
- Item: Add `OPENCODE_TOOLS_DISPATCHER=1` guard to `rules` (inherits existing `symbolic` pattern)
- Item: Remove `symbolic` dispatcher entirely — no compatibility redirect, no backwards compatibility
- Item: Create `.opencode/guidelines/092-spec-reasoning-tools.md` with trigger patterns covering both `rules` and `solve`
- Item: Add `092-` entry to `.opencode/guidelines/INDEX.md`
- Item: Document the `.issues/` artifact layout and `global-constraints.yaml` auto-extraction from `scope: global` constraints
- Item: Create initial empty `.issues/artifacts/global-constraints.yaml`

### Phase 2: Universal yaml+symbolic constraint schema + skill integration (future)
- Item: Define the primitive ontology (entities, states, transitions, dependencies, resources, invariants, timing) as a formal schema
- Item: Extend spec and plan templates to include `constraints.yaml` alongside `spec.md`
- Item: Update `brainstorming` to produce `constraints.yaml` during Mode A (autonomous) and Mode B (guided) extraction
- Item: Update `spec-creation` to create `constraints.yaml` in the issue's `.issues/` directory alongside `spec.md`, with initial empty constraint block
- Item: Update `writing-plans` to update `constraints.yaml` with plan-level phase interdependencies and item ordering constraints
- Item: Update `issue-operations` to treat `constraints.yaml` as local-only — never synced to `remote.md` or GitHub
- Item: Update `rules conflicts`, `rules analyze`, and other `rules` actions to consume spec constraint blocks (not just guideline rule blocks)
- Item: Update `verification-before-completion/tasks/structural-verify.md` to read `constraints.yaml` from the issue directory alongside existing `yaml+symbolic` block extraction
- Item: Update `verification-before-completion/tasks/verify.md` to verify constraint satisfaction as part of the SC verification pipeline
- Item: Update `approval-gate/tasks/pre-impl/build-dependency-graph.md` to incorporate `constraints.yaml` dependency and conflict data
- Item: Update `adversarial-audit/tasks/concern-separation.md` to validate constraint consistency during phase dependency checks
- Item: Create behavioral enforcement tests that verify the agent dispatches `solve --file` when constraint checking is triggered
- Item: Create spec-to-code traceability — generated code must reference which constraints it satisfies

## Requirements

### Functional

| ID | Requirement |
|----|-------------|
| FR-1 | Existing `sym-*` scripts migrated from `sympy` to `z3-solver` and renamed to `rules-*` |
| FR-2 | `rules` dispatcher at `.opencode/tools/rules` replaces `symbolic` dispatcher, routes to `rules-*` scripts |
| FR-3 | Standalone `solve` tool at `.opencode/tools/solve` with PEP 723 header, dependencies: `["z3-solver", "pyyaml>=6.0"]` |
| FR-4 | `solve` accepts only `--file <yaml>` input — no inline constraint flags |
| FR-5 | YAML input supports named constraints with Z3 Boolean expressions, optional `track_unsat`, `timeout_ms`, and `scope` fields |
| FR-6 | `solve` output written to an artifact file named by stripping `.yaml` from input and appending `.out` |
| FR-7 | `solve` output contains natural-language verdict prose followed by `---` and structured YAML (status, model assignments, unsat core) |
| FR-8 | Exit codes: 0=SAT, 1=UNSAT, 2=timeout/error |
| FR-9 | `solve` auto-loads `.issues/artifacts/global-constraints.yaml` unless `--no-global` passed |
| FR-10 | Constraints with `scope: global` in issue `constraints.yaml` are extracted into `global-constraints.yaml` by the toolset |
| FR-11 | `OPENCODE_TOOLS_DISPATCHER=1` guard on both `rules` and `solve` |
| FR-12 | Guideline at `.opencode/guidelines/092-spec-reasoning-tools.md` covers both `rules` and `solve` with distinct trigger patterns |
| FR-13 | Two extraction modes: autonomous (conversation + code inspection) and guided (structured refinement — never pop-quiz) |
| FR-14 | INDEX.md has `092-` entry for the new guideline |
| FR-15 | `structural-verify.md` reads `constraints.yaml` from issue directory |
| FR-16 | `verify.md` checks constraint satisfaction as part of SC verification |
| FR-17 | `build-dependency-graph.md` incorporates `constraints.yaml` data |
| FR-18 | `concern-separation.md` validates constraint consistency during phase checks |

### Non-Functional

| ID | Requirement |
|----|-------------|
| NFR-1 | Scripts are self-contained — no project-level dep changes |
| NFR-2 | Stateless — every invocation starts fresh Z3 context |
| NFR-3 | Guideline follows existing `.opencode/guidelines/` format with trigger-on frontmatter |

### Constraints

1. PEP 723 self-contained script pattern (bash guard + `/// script` header) is mandatory
2. Z3 (`z3-solver`) is the sole solver engine behind both `rules` and `solve` — no `sympy`, no CVC5, no PySAT fallback
3. `rules` dispatcher and `solve` tool are the only two routing entry points
4. All dependencies declared only in PEP 723 script headers — zero additions to `pyproject.toml`
5. Guideline, engine migration, and both tools ship in the same commit — no dead tooling
6. The `.issues/` directory is the canonical source for constraint files — `./tmp/` is ephemeral working copies only
7. `.issues/artifacts/global-constraints.yaml` is git-tracked and managed by the toolset, never manually edited
8. No backwards compatibility with `symbolic` dispatcher or `sym-*` script names — clean removal, no redirects
9. No agent-facing text sweep needed — `symbolic` was never referenced in any skill card, guideline, or task file outside the implementation scripts

### Out of Scope

- General-purpose SMT-LIB 2 parser
- Persistent solver state or incremental solving (push/pop) across invocations
- Daemon or socket-based solver server
- Optimization (maximize/minimize) — SAT/UNSAT decision only
- Schema definition for Phase 2 universal constraint blocks (deferred)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | All existing `sym-*` scripts migrated from `sympy` to `z3-solver` and renamed to `rules-*` | behavioral |
| SC-2 | `rules` dispatcher exists at `.opencode/tools/rules` routing to `rules-*` scripts; `symbolic` dispatcher removed | structural |
| SC-3 | `solve` tool exists at `.opencode/tools/solve` with PEP 723 header and `z3-solver`+`pyyaml` dependencies | structural |
| SC-4 | SAT input file produces exit code 0; output file contains `status: SAT` + natural language + model assignments | behavioral |
| SC-5 | UNSAT input file with `track_unsat: true` produces exit code 1; output file contains `status: UNSAT` + natural language + unsat core | behavioral |
| SC-6 | `--timeout 1` on long-running constraint returns exit code 2 | behavioral |
| SC-7 | Direct invocation of `rules` or `solve` impl scripts (without dispatcher) fails with error | behavioral |
| SC-8 | `solve` auto-loads `.issues/artifacts/global-constraints.yaml`; `--no-global` skips it | behavioral |
| SC-9 | Guideline exists at `.opencode/guidelines/092-spec-reasoning-tools.md` with trigger patterns for both `rules` and `solve` | structural |
| SC-10 | INDEX.md has `092-` entry | structural |
| SC-11 | Solver parses multi-constraint YAML input with conjunction and evaluates correctly | behavioral |
| SC-12 | `rules conflicts` produces same results on Z3 as `sym-conflicts` did on sympy for existing guideline rule blocks (regression guard) | behavioral |
| SC-13 | Agent can use both `rules` and `solve` after loading the guideline — verified by behavioral test | behavioral |
