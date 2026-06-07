# Card Catalogue — #854 Reference Card Architecture + Spec Output Structure

status: plan
scope: coordination-plan
dependencies: [#848, #853, #849, #850, #1060, #1061, #1062, #1063, #1064]

---

## Layer 0: Reference Cards

### Card: #848 — 255-distribution-shifting reference card

| Field | Value |
|-------|-------|
| Status | `approved-for-implementation` |
| Phase | 1 |
| PR branch | `phase/854/1-foundation` |
| SC count | 12 |
| Key files | `guidelines/255-distribution-shifting-reference.md` |
| Depends on | None |

### Card: #853 — 257-procedural-discipline reference card

| Field | Value |
|-------|-------|
| Status | `approved-for-implementation` |
| Phase | 1 |
| PR branch | `phase/854/1-foundation` |
| SC count | 16 |
| Key files | `guidelines/257-procedural-discipline-reference.md` |
| Depends on | None |

---

## Layer 1: Policy

### Card: #849 — mandatory co-application policy

| Field | Value |
|-------|-------|
| Status | `approved-for-implementation` |
| Phase | 1 |
| PR branch | `phase/854/1-foundation` |
| SC count | 13 |
| Key files | `guidelines/080-code-standards.md`, `guidelines/250-dark-prose-reference.md`, `guidelines/255-distribution-shifting-reference.md`, `guidelines/257-procedural-discipline-reference.md`, `guidelines/000-critical-rules.md`, `AGENTS.md` |
| Depends on | [#848, #853] |

---

## Layer 2: Enforcement Style + Spec Output Structure

### Card: #850 — enforcement-text-style injection (narrowed coordination parent)

| Field | Value |
|-------|-------|
| Status | open (spec) |
| Phase | 2 |
| PR branch | shared with #1060 (Phase 2) |
| SC count | TBD per implementation spec |
| Key files | `skills/spec-creation/tasks/write.md`, `skills/approval-gate/`, `skills/adversarial-audit/` |
| Depends on | [#849] |

### Card: #1060 — spec structure expansion

| Field | Value |
|-------|-------|
| Status | open (spec) |
| Phase | 2 |
| PR branch | `phase/854/2-structure` |
| SC count | 12 |
| Key files | `skills/spec-creation/tasks/write.md` |
| Depends on | [#850] |

---

## Layer 3: Artifact Infrastructure

### Card: #1061 — artifact infrastructure

| Field | Value |
|-------|-------|
| Status | open (spec) |
| Phase | 3 |
| PR branch | `phase/854/3-artifacts` |
| SC count | 10 |
| Key files | `skills/spec-creation/`, `skills/writing-plans/`, `skills/skill-creator/` (sc-summary.yaml, solve contracts, lifecycle.yaml) |
| Depends on | [#1060] |

---

## Layer 4: Boundary Gates

### Card: #1062 — handoff gates

| Field | Value |
|-------|-------|
| Status | open (spec) |
| Phase | 4 |
| PR branch | `phase/854/4-boundaries` |
| SC count | 7 |
| Key files | `skills/spec-creation/`, `skills/writing-plans/`, `skills/implementation-pipeline/` |
| Depends on | [#1061] |

---

## Layer 5: Pipeline + Plan Enforcement

### Card: #1063 — pipeline enforcement gates

| Field | Value |
|-------|-------|
| Status | open (spec) |
| Phase | 5 |
| PR branch | `phase/854/5-enforcement` |
| SC count | 6 |
| Key files | `skills/implementation-pipeline/` (14-step pipeline tasks) |
| Depends on | [#1062] |

### Card: #1064 — writing-plans consumer awareness

| Field | Value |
|-------|-------|
| Status | open (spec) |
| Phase | 5 |
| PR branch | `phase/854/5-enforcement` |
| SC count | 7 |
| Key files | `skills/writing-plans/tasks/create/plan-structure.md`, `skills/writing-plans/tasks/create/create-and-validate.md` |
| Depends on | [#1062] |
| Peers with | [#1063] |

---

## Phase Summary

| Phase | Branch | Issues | SC Total | PR Status |
|-------|--------|--------|----------|-----------|
| 1 — Foundation | `phase/854/1-foundation` | #848, #853, #849 | 41 | Not created |
| 2 — Structure | `phase/854/2-structure` | #850, #1060 | ~12 | Not created |
| 3 — Artifacts | `phase/854/3-artifacts` | #1061 | 10 | Not created |
| 4 — Boundaries | `phase/854/4-boundaries` | #1062 | 7 | Not created |
| 5 — Enforcement | `phase/854/5-enforcement` | #1063, #1064 | 13 | Not created |

## Dependency Chain

```
Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4 ──→ Phase 5
```

No Phase N+1 PR may be created until Phase N's PR is merged. Stacked PR discipline: one branch per phase, one commit per issue within that branch.

## Key Cross-Cutting Decisions

| DEC-ID | Decision | Rationale |
|--------|----------|-----------|
| DEC-001 | Phase boundary = PR merge boundary | Prevents building on unreviewed code; each phase independently reviewable |
| DEC-002 | Stacked PR: one branch per phase, one commit per issue | Single-issue commits within phase branch; squashed at PR merge |
| DEC-003 | No behavioral enforcement tests in this plan | Deferred to per-spec implementation; plan-level SCs are structural only |
| DEC-004 | #1063 and #1064 are peers (parallelizable within Phase 5) | Both depend only on #1062, no mutual dependency; same PR branch |
| DEC-005 | #850 shared with #1060 in Phase 2 PR | Narrowed #850 scope fits same branch; both modify spec-creation artifacts |