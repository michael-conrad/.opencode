# Phase 1: Central Cross-Reference File + Sync Headers

**SCs:** SC-26, SC-27, SC-28
**Dependencies:** None

## Steps

1. Create `.opencode/reference/holistic-dimensions.yaml` with:
   - Canonical 11 spec dimension definitions (id, name, question, checks)
   - Canonical 11 plan dimension definitions (id, name, question, checks)
   - Cross-reference table with all 9 consumer locations:
     - `audit_gates`: spec-audit.md, writing-plans/create.md, writing-plans/update.md, plan-fidelity.md, implementation-pipeline/pre-flight.md
     - `producer_self_checks`: spec-creation/create.md, spec-creation/completion.md, writing-plans/create.md, writing-plans/completion.md
   - Each entry has: file, section, dimensions, last_verified

2. Add sync header comment `<!-- Dimensions synced from .opencode/reference/holistic-dimensions.yaml -->` to all 9 consumer files

3. Verify sync headers present with `grep -r "Dimensions synced from" .opencode/skills/`

## Verification

- SC-26: `grep` for cross-reference table in holistic-dimensions.yaml listing all consumer files
- SC-27: `grep` for sync header comment in each consumer file
- SC-28: `grep` for all 9 file paths in cross-reference table
