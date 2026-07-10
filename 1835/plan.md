# Implementation Plan — [#1835](https://github.com/michael-conrad/.opencode/issues/1835) — Restore Analytical Depth to Spec-Creation Pipeline

**Goal:** Add 7 new analytical task files, deepen 6 existing task files, fix pipeline ordering and SKILL.md metadata, update 4 downstream skills (spec-audit, writing-plans, verification-before-completion, brainstorming) and their SKILL.md files with analytical artifact requirements.

**Architecture:** Holistic fix across 4 parts (A-D) covering spec-creation internals, downstream consumers, and SKILL.md prose enforcement. All enforcement uses task file procedural steps and SKILL.md prose — no YAML symbolic rules.

**Files:** 35+ files across `.opencode/skills/spec-creation/tasks/`, `.opencode/skills/audit/tasks/`, `.opencode/skills/writing-plans/tasks/`, `.opencode/skills/verification-before-completion/tasks/`, `.opencode/skills/brainstorming/tasks/`, and their SKILL.md files.

> **⚠️ COMPLIANCE REQUIREMENT:** This plan is a structured guide. Every step MUST be executed in order. Each step produces a specific deliverable. Do NOT skip steps, combine steps, or reorder steps. If a step cannot be completed, HALT and report the blocker. Do NOT proceed past a blocked step.

> **⚠️ ONE STEP AT A TIME:** Execute exactly one step at a time. After completing a step, report what was done and wait before proceeding. Do NOT batch multiple steps into a single response. Each step is an atomic unit.

> **⚠️ STEP STATUS:** Each step has a status marker: `⬜ Not Started`, `🔄 In Progress`, `✅ Complete`, `❌ Blocked`. Update the marker as you work.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Global Pre-Phase | Setup, pre-flight, coherence | SC-22 | none | 1-5 |
| 2 | Part A1 — Create 7 New Analytical Task Files | New task files for spec-creation | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-21 | Phase 1 | 6-12 |
| 3 | Part A2 — Deepen 6 Existing Task Files | Deepen requirements, decompose, risk, pipeline-readiness-gate, traceability, change-control | SC-8, SC-9, SC-10, SC-11, SC-12, SC-13 | Phase 2 | 13-18 |
| 4 | Part A3+A4 — Pipeline Ordering + SKILL.md Metadata | Fix operating-protocol.md pipeline ordering and SKILL.md metadata | SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20 | Phase 3 | 19-25 |
| 5 | Part B1 — spec-audit Changes | Add analytical artifact validation to spec-audit | SC-23, SC-24, SC-25 | Phase 4 | 26-28 |
| 6 | Part B2 — writing-plans Changes | Update research, structure, validate, write, create; add artifact-validation | SC-26, SC-27, SC-28, SC-29, SC-30, SC-31 | Phase 5 | 29-35 |
| 7 | Part B3 — verification-before-completion Changes | Add coverage gates, component types, evidence collection, operating protocol | SC-32, SC-33, SC-34, SC-35 | Phase 6 | 36-39 |
| 8 | Part B4 — brainstorming Changes | Add checklist items, artifact production, completion criteria, handoff | SC-36, SC-37, SC-38, SC-39 | Phase 7 | 40-43 |
| 9 | Part C1-C4 — SKILL.md Prose + Trigger Dispatch Table | Update audit, writing-plans, verification-before-completion, brainstorming SKILL.md | SC-40, SC-41, SC-42, SC-43, SC-44, SC-45, SC-46, SC-47, SC-48, SC-49, SC-50, SC-51, SC-52 | Phase 8 | 44-55 |
| 10 | Global Post-Phase | Audit, cross-validate, review prep, completion | All | Phase 9 | 56-65 |

> **⚠️ COMPLIANCE REQUIREMENT:** This plan is a structured guide. Every step MUST be executed in order. Each step produces a specific deliverable. Do NOT skip steps, combine steps, or reorder steps. If a step cannot be completed, HALT and report the blocker. Do NOT proceed past a blocked step.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If a step fails verification, do NOT proceed. Diagnose the root cause, fix the issue, re-verify, and only then proceed. If re-verification also fails, HALT and report the blocker with both failure artifacts. Do NOT reclassify FAIL as PASS. Do NOT soft-pass with "functionally equivalent."

## Exit Criteria

- [ ] C1: All 7 new analytical task files exist with correct methodology
- [ ] C2: All 6 deepened task files include spec-required additions
- [ ] C3: operating-protocol.md has correct pipeline ordering with no numbering gaps
- [ ] C4: spec-creation SKILL.md has no duplicate trigger entries and includes all 7 new tasks
- [ ] C5: spec-audit.md includes 7 new SC criteria and validation steps
- [ ] C6: writing-plans task files consume analytical artifacts
- [ ] C7: verification-before-completion task files include analytical artifact gates
- [ ] C8: brainstorming task files include preliminary analytical artifact production
- [ ] C9: All 4 downstream SKILL.md files have updated Overview, Mandatory Task Discipline, and Trigger Dispatch Table
- [ ] C10: No YAML symbolic rules added to any SKILL.md
- [ ] C11: All validation checks pass (validate, audit-fidelity, audit-concern)
- [ ] C12: Plan artifacts committed to feature branch

## Self-Review Evidence

This plan was created from the approved spec #1835. The spec has 52 SCs across 4 parts (A-D) and 35+ affected files. The plan uses a 10-phase three-tier structure: 1 global pre-phase, 8 per-file RED/GREEN phases, 1 global post-phase. All implementation-pipeline gate steps are enumerated in the phase structure. Step numbering is globally sequential across all phases. Phase exit criteria for behavioral SCs include both behavior_run artifact generation and behavioral-test-evaluation clean-room dispatch steps.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
