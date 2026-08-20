> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2303/

**Problem**

The `.opencode/tools/plan` tool (PEP 723 script) fails to resolve its dependencies when `uv run --script` selects CPython 3.14, because the `up-tamer>=1.1.0` requirement cannot be satisfied under 3.14 (pytamer has no cp314 wheels).

**Root Cause**

The PEP 723 header declares `requires-python = "~=3.12"`. The `~=3.12` constraint permits CPython 3.14, but `pytamer` only publishes wheels for `cp36m..cp312`. The `up-tamer>=1.1.0` requirement therefore becomes unsatisfiable under 3.14, producing the resolution error. The defect is the loose upper bound on `requires-python`, not the `up-tamer`/`pytamer` dependency itself.

**Scope**

- Tighten the `requires-python` constraint in `.opencode/tools/plan` from `~=3.12` to the exact constraint `>=3.12,<3.14` so uv selects a Python version with available pytamer wheels. This is the sole deterministic requirement.
- Add a usage note documenting `UV_PYTHON=3.12` as an optional workaround for environments that do not adopt the tightened constraint.
- Verify the tool still resolves and executes under Python 3.12.

**Out of scope:**

- Building new pytamer wheels for cp314 (upstream dependency, not this repo).
- Changing the underlying `up-tamer`/`pytamer` dependency resolution logic.

**Approach**

The PEP 723 header currently declares `requires-python = "~=3.12"` with dependencies `unified-planning>=1.3.0`, `pyyaml>=6.0`, `networkx>=3.0`, `up-tamer>=1.1.0`. The `~=3.12` constraint permits CPython 3.14, but `pytamer` only publishes wheels for `cp36m..cp312`, so `up-tamer>=1.1.0` is unsatisfiable under 3.14. Tightening the `requires-python` constraint to the exact value `>=3.12,<3.14` ensures uv selects a compatible interpreter. The minimal fix is a one-line change to the PEP 723 header plus a usage note for the `UV_PYTHON` workaround.

**Impact**

- Risk: tightening the constraint could affect environments pinned to 3.13+; mitigation: all current usage targets 3.12, and the `UV_PYTHON=3.12` override covers edge cases.
- Dependency: `.opencode/tools/plan` is invoked via `uv run --script`; the fix must not break the bash guard at the top of the file.
- Call to action: apply the `requires-python` constraint change and add a usage note documenting `UV_PYTHON=3.12` as the workaround.

Error for reference: "No solution found when resolving script dependencies: Because pytamer==0.1.17 has no wheels with a matching Python ABI tag (e.g., cp314) and up-tamer==1.1.0 depends on pytamer==0.1.17, we can conclude that up-tamer==1.1.0 cannot be used."

**Requirements**

- R-1. The `requires-python` constraint in the PEP 723 header of `.opencode/tools/plan` SHALL be changed from `~=3.12` to the exact value `>=3.12,<3.14`, excluding CPython 3.14, so uv selects a Python version with available pytamer wheels.
- R-2. Invoking `.opencode/tools/plan` via `uv run --script` under a CPython 3.12 interpreter SHALL complete dependency resolution and execution with exit code 0 and without the pytamer resolution error.
- R-3. The fix SHALL be confined to the PEP 723 header of `.opencode/tools/plan` and an accompanying usage note; it SHALL NOT modify `up-tamer`/`pytamer` dependency resolution logic or build cp314 wheels.

**Success Criteria**

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The `requires-python` constraint in the PEP 723 header of `.opencode/tools/plan` SHALL be set to the exact value `>=3.12,<3.14`, excluding CPython 3.14, so uv selects a Python version with available pytamer wheels. | structural | Inspect the `# requires-python` line in `.opencode/tools/plan` and confirm its value is exactly `>=3.12,<3.14`. | `.opencode/tools/plan` (code) |
| SC-2 | Invoking `.opencode/tools/plan` via `uv run --script` under a CPython 3.12 interpreter SHALL complete dependency resolution and execution with exit code 0 and no pytamer resolution error in output. | behavioral | Run `.opencode/tools/plan` via `uv run --script` under CPython 3.12; assert exit code is 0 and the "No solution found when resolving script dependencies" / `up-tamer` resolution error is absent from output. | `.opencode/tools/plan` (code) |

**Cost Frame**

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the constraint value costs one read of the `# requires-python` line in `.opencode/tools/plan`. Skipping means a constraint that still permits 3.14 ships unchanged, so the resolution failure recurs in every fresh 3.14 environment — a defect discovered after deploy instead of at commit.
- SC-2: Running the behavioral invocation under CPython 3.12 costs minutes of execution time. Skipping means the constraint change ships without proof that it resolves under 3.12, so a resolution regression ships to production and costs exponentially more to fix than the skipped test.

**Documentation Sources**

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| plan tool PEP 723 header | code | `.opencode/tools/plan` | read — confirmed `requires-python = "~=3.12"` currently permits CPython 3.14 |
| Resolution error message | code/output | issue #2303 body | recorded from the live `uv run --script` resolution failure |

**Change Control**

- **Date:** 2026-08-19
- **What:** Added a Success Criteria section with an SC table (SC-1, SC-2) derived from the existing Scope and Approach. No requirements, scope, or approach content changed.
- **Why:** The writing-plans analyze gate returned BLOCKED with `NO_SUCCESS_CRITERIA` because the spec body lacked a Success Criteria section.
- **Who authorized:** spec-creation `revise` pipeline dispatch (issue #2303).

- **Date:** 2026-08-19
- **What:** Conformance/rigor correction. Added the Documentation Sources column to the SC table; added a Requirements section (R-1..R-3) with SHALL language; added a Cost Frame section with dark-prose-007 statements per SC; made SC-1 deterministic by pinning the exact constraint `>=3.12,<3.14` (removed the `e.g.` escape hatch); made SC-2 deterministic by defining the pass/fail condition (exit code 0 and absence of the pytamer resolution error, replacing the vague adverb "successfully"); removed the parallel "or document UV_PYTHON" escape hatch from Scope so the tightened constraint is the sole deterministic requirement, retaining `UV_PYTHON=3.12` only as an optional usage note.
- **Why:** Structural validation returned FAIL on the SC table Documentation Sources column, missing dark-prose-007 cost frames per SC, missing Requirements section with SHALL language, determinism violations (SC-1 `e.g.` escape hatch, SC-2 "successfully" without a threshold), and the Escape-Hatches dimension. Technical substance (root cause: pytamer has no cp314 wheels; fix: tighten requires-python) unchanged.
- **Who authorized:** spec-creation `revise` pipeline dispatch (issue #2303).

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
