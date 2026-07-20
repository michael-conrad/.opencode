> **Full spec and artifacts: `.opencode/.issues/317/`**

## Exec Summary

Scripts with canonical walk-up root detection loops can enter an infinite loop when `.opencode/` is unreachable from the filesystem root. A filesystem-root guard (`if parent == current → fatal error`) must be inserted into all 26 scripts: 2 bash, 12 Python PEP 723 tools, 8 Python PEP 723 impl scripts, and 4 Python scripts.

### Cards (dependency order)
1. **G1: Add root-guard to 2 bash scripts** (`detect-secrets-wrapper.sh`, `ensure-node`)
2. **G2: Add root-guard to 12 Python PEP 723 tools** (`guidelines`, `md`, `py`, `file-exists`, `session-init`, `help`, `jupyter`, `jupyter-start`, `jupyter-stop`, `skildeck`, `plan`, `solve`)
3. **G3: Add root-guard to 8 Python impl scripts** (`guidelines-read`, `guidelines-show`, `guidelines-search`, `guidelines-edit`, `jupyter-start`, `jupyter-stop`, `py-ls`, `py-mkpkg`)
4. **G4: Add root-guard to 4 Python scripts** (`session_context_triggers.py`, `verify_api.py`, `test_pr_idempotency.py`, `regression-91-verify-structure.py`)

### Key Decisions
- **Single-phase, strict dependency order** — all 26 files in one phase with checkpoint commits per group
- **One-step-at-a-time protocol** — each step verified before proceeding to the next

### Risk Callouts
- **26 files must be correctly classified** — misclassification means wrong guard pattern (bash vs Python)
- **Guard pattern consistency** — all 26 files must use the exact canonical form per language

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/317/`.
After creation, `local-issues sync 317` MUST be run and the result committed to create the local `.issues/317/` entry.
The implementation plan will be created in `.issues/317/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/317/`*