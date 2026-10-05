---
name: formal-tooling
description: >-
  Load when workflow correctness needs machine checking — constraint solving,
  satisfiability checks, counterexamples, proofs over contract/state YAML, or
  plan generation, validation, and grounding over PDDL. Runs the vendored z3
  binary (SMT-LIB2) and unified-planning's `up` CLI through the thin
  `tools/formal` adapter. Also load when a check/model/prove/plan/validate/
  ground operation fails unexpectedly, or before first use on a machine where
  the vendored binary has not been installed yet.
license: MIT
<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2504 -->
---

# formal-tooling — vendored z3 + unified-planning via the `tools/formal` adapter

One adapter (`tools/formal`), one vendored engine (z3), one planner CLI
(`up`), one YAML state schema. The adapter contains no solver or planner
logic — it translates YAML to SMT-LIB2 / CLI invocations and parses output.

## Decision point — solving vs planning

- **Solving / proving** (is this state consistent? is this claim derivable?
  what assignment satisfies this?): use `check` / `model` / `prove` — z3 over
  contract + state YAML.
- **Planning** (what sequence of actions reaches the goal?): use `plan` /
  `validate` / `ground` — `up` CLI over PDDL domain/problem.

## Install (first use on a machine)

The binary is vendored at runtime, not committed (`.tools/` is gitignored):

```bash
mkdir -p .tools/z3
gh release download z3-5.1.0 --repo Z3Prover/z3 \
  --pattern "z3-5.1.0-x64-glibc-2.39.zip" --clobber -O /tmp/z3.zip
unzip -o -q /tmp/z3.zip -d /tmp/z3dist
cp /tmp/z3dist/z3-*/bin/z3 /tmp/z3dist/z3-*/bin/libz3.so \
   /tmp/z3dist/z3-*/LICENSE.txt .tools/z3/
chmod +x .tools/z3/z3
.tools/z3/z3 --version   # expect: Z3 version 5.1.0 - 64 bit
```

The adapter falls back to `z3` on PATH if `.tools/z3/z3` is absent.
Python deps (`pyyaml`; `unified-planning` + `up-tamer` for planning) resolve
via the adapter's PEP 723 header under `uv run`.

## Solver operations (z3, SMT-LIB2)

Contract YAML — variables with types (`bool|int|real|string`), clauses as
SMT-LIB2 s-expressions; give a clause an explicit `name:` to see it in
unsat-cores. State YAML — `variables:` with typed literals.

```bash
./.opencode/tools/formal check   --state-path state.yaml --contract-path contract.yaml
./.opencode/tools/formal model   --contract-path contract.yaml --query "<smt-expr>"
./.opencode/tools/formal prove   --contract-path contract.yaml --theorem "<smt-expr>"
```

Expected outputs:

- `check` on a violating state → `UNSAT` + `violated: <clause-name>` lines
  naming the clauses that rule the state out (unsat-cores); exit 1.
- `check` on a satisfying state → `SAT` + assignment lines for the declared
  variables; exit 0.
- `model` on a satisfiable query → `SAT` + a satisfying assignment; on an
  unsatisfiable query → `UNSAT`, exit 1.
- `prove` a true theorem → `VALID` (assumptions ∧ invariants ∧ ¬theorem is
  unsat). A false theorem → `INVALID` + counterexample model, exit 1.

`check` tests the state against assumptions + invariants + postconditions;
`model` and `prove` assume assumptions + invariants only (postconditions are
goals, not givens).

## Planning operations (`up` CLI, unified-planning)

```bash
./.opencode/tools/formal plan     --domain domain.pddl --problem problem.pddl --plan-out plan.txt
./.opencode/tools/formal validate --domain domain.pddl --problem problem.pddl --plan plan.txt
./.opencode/tools/formal ground   --domain domain.pddl --problem problem.pddl --out-prefix grounded
```

Expected outputs:

- `plan` → plan actions printed and written to `plan.txt`
  (`(move depot hub)` style); exit 0.
- `validate` → `status: VALID` for a plan consistent with the domain;
  anything else is a failed validation, exit 1.
- `ground` → `<prefix>-domain.pddl` + `<prefix>-problem.pddl` written.

Engine selection and status handling (including `UNSOLVABLE_INCOMPLETELY`)
belong to `up`; the adapter passes them through.

## Shared state schema (single owner)

One schema, owned in `tools/formal`'s docstring, consumed by solver and
planning paths:

```yaml
variables:
  ready: true            # typed by value
  count: {type: int, value: 3}
```

```bash
./.opencode/tools/formal state init  state.yaml --var ready=true --var count=3
./.opencode/tools/formal state update state.yaml --var count=4
./.opencode/tools/formal state status state.yaml
```

## Maintenance

To refresh the vendored binary, rerun the install block with the new release
tag and version-pinned zip pattern — no other file changes.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
