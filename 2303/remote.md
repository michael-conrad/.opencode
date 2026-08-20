---
remote_issue: 2303
remote_url: "https://github.com/michael-conrad/.opencode/issues/2303"
last_sync: 2026-08-20T02:35:48Z
source: github
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2303/

**Problem**

The `.opencode/tools/plan` tool (PEP 723 script) fails to resolve its dependencies when `uv run --script` selects CPython 3.14, because the `up-tamer>=1.1.0` requirement cannot be satisfied under 3.14 (pytamer has no cp314 wheels).

**Scope**

- Tighten the `requires-python` constraint in `.opencode/tools/plan` from `~=3.12` to `~=3.12,<3.14` (or `>=3.12,<3.14`) so uv selects a Python version with available pytamer wheels.
- Or document the `UV_PYTHON=3.12` workaround requirement.
- Verify the tool still runs under Python 3.12.

**Out of scope:**
- Building new pytamer wheels for cp314 (upstream dependency, not this repo).
- Changing the underlying `up-tamer`/`pytamer` dependency resolution logic.

**Approach**

The PEP 723 header currently declares `requires-python = "~=3.12"` with dependencies `unified-planning>=1.3.0`, `pyyaml>=6.0`, `networkx>=3.0`, `up-tamer>=1.1.0`. The `~=3.12` constraint permits CPython 3.14, but `pytamer` only publishes wheels for `cp36m..cp312`. The `up-tamer>=1.1.0` requirement therefore becomes unsatisfiable under 3.14, producing the resolution error. Tightening the requires-python constraint (or documenting `UV_PYTHON=3.12`) ensures uv selects a compatible interpreter. The minimal fix is a one-line change to the PEP 723 header plus a doc note for the workaround.

**Impact**

- Risk: tightening the constraint could affect environments pinned to 3.13+; mitigation: all current usage targets 3.12, and the `UV_PYTHON` override covers edge cases.
- Dependency: `.opencode/tools/plan` is invoked via `uv run --script`; the fix must not break the bash guard at the top of the file.
- Call to action: apply the requires-python constraint change and add a usage note documenting `UV_PYTHON=3.12` as the workaround.

Error for reference: "No solution found when resolving script dependencies: Because pytamer==0.1.17 has no wheels with a matching Python ABI tag (e.g., cp314) and up-tamer==1.1.0 depends on pytamer==0.1.17, we can conclude that up-tamer==1.1.0 cannot be used."

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
