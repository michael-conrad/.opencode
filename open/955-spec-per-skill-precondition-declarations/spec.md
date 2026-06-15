---
remote_issue: 955
remote_url: "https://github.com/michael-conrad/.opencode/issues/955"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

> **Scope revision: `.opencode#1222` (Enforcement-Gated Contract Schema) defines the standardized hand-off contract format that replaces the need for per-skill custom contract.yaml files. The standardized schema covers all pipeline stages with mandatory `gate_result`, `verifier_identity`, and `artifact_hash` fields. Per-skill contract.yaml files are no longer needed — skill-specific fields (e.g., preconditions referencing skill concepts) may remain as optional extensions but are no longer the primary contract format.**

## Parent

#954 (Skill Task File Inventory — Frugal Contract + Solve Gate Integration)

## Problem

The Z3 constraint model in #954 identified a critical ownership gap: neither #951 (solve contract/state integration) nor #954 (skill inventory) explicitly produces per-skill `contract.yaml` files. The `solve check` gate requires a contract file with preconditions and postconditions — without it, the gate is semantically empty.

| Spec | Says | Status |
|------|------|--------|
| #951 | "Contract shape/content per skill deferred to per-skill authors" | Defers |
| #954 Phase 1 | "Classification audit" — no explicit contract output | Doesn't claim it |

**Result:** No spec claimed ownership of producing the 36 `contract.yaml` files.

## Resolution via #1222

The standardized hand-off contract schema (`.opencode#1222` Part 1) replaces this. The contract format is now defined once, not per-skill. Any remaining per-skill preconditions (e.g., `spec_approved == True` for verification skills) may be expressed as optional extension fields in the standardized contract's `routing` section or as separate lightweight pre/post files — but the primary hand-off contract is the standardized schema.

## Remaining Scope

- Optional per-skill precondition files may be defined for skills whose dispatch preconditions cannot be expressed in the standardized schema's `routing` fields
- These files are NOT full `contract.yaml` — they are simple condition declarations (1-3 preconditions max)
- Integration with the solve tool's pre-dispatch gate (`#1222` Part 2) ensures these conditions are checked

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Standardized contract schema (per #1222) used for all pipeline stage transitions | `string` | grep for #1222 schema in pipeline SKILL.md |
| SC-2 | Per-skill precondition files (if any) are ≤3 conditions and reference skill concepts only | `string` | grep condition count in each skill precondition file |
| SC-3 | Solve tool's pre-dispatch gate accepts standardized contract format | `behavioral` | opencode-cli run with standardized contract → gate PASS |
| SC-4 | No full contract.yaml files created per skill (standardized schema replaces them) | `structural` | glob for skills/*/contract.yaml → 0 matches |

🤖 OpenCode (deepseek-v4-flash)