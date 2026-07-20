## Problem Statement

The current spec-driven development workflow assumes a single spec document per feature. This works for small, single-phase features but breaks down for multi-phase projects. The result is a monolithic spec that:

1. **Exceeds effective agent context** — Research shows AI agent performance degrades significantly as context grows, even within theoretical limits (LeanSpec, Databricks, Berkeley Function-Calling Leaderboard). A 246-line spec forces the agent to hold Phase 1 scaffolding details while implementing Phase 3 touch input logic.

2. **Couples cross-phase success criteria** — SCs that span multiple phases (e.g., SC-3 maps to Phase 2 AND Phase 3) mean no phase can be independently verified or shipped. A change in Phase 3 retroactively affects Phase 4 verification.

3. **Mixes vision with implementation** — Project goals, architecture diagrams, port numbers, and Godot API calls live in the same document. These have different change frequencies and different consumers. The vision rarely changes; implementation details change every phase.

4. **Creates wasted spec work** — All phases are written upfront, but assumptions change during implementation. Phase 3 spec work done before Phase 1 merges is frequently invalidated by real learnings.

### Evidence from Downstream

Issue #1 in the downstream project (catacomb-paws) is a concrete example: 246 lines, 4 phases, 14 SCs, with cross-phase SC coupling (SC-3 → Phase 2+3, SC-4 → Phase 3+4). The spec embeds specific Godot API calls, port numbers, and message formats — making it an "implementation sketch called a spec" (SDD Anti-patterns #12).

## Proposed Solution: Three-Layer Spec Hierarchy

### Layer 1: Project Charter (1-2 pages, stable)

A lightweight vision document capturing only what is invariant across all phases:

```
docs/charters/<project-name>.md
├── Problem Statement (2-3 sentences)
├── Goals (what success looks like)
├── Non-Goals (explicitly out of scope)
├── Constraints (technology, platform, environment)
├── Architecture Overview (one diagram, 3 paragraphs max)
└── Phase Map (list of phases with one-line descriptions)
```

**No SCs. No implementation details. No decision ledger. No risk tables.** This document is rarely revised — it is the north star, not the construction blueprint.

**Sources:** Spec Kit "constitution" concept, IBM vision document methodology, DSPI `architecture.md` pattern.

### Layer 2: Phase Specs (one per phase, <80 lines, created on-demand)

Each phase gets its own spec, created when that phase is about to begin. Each phase spec is independently verifiable:

```
docs/specs/phase-<NN>-<name>.md
├── SCs (all verifiable within this phase — no cross-phase SCs)
├── Verification plan (per SC)
├── Decision ledger (phase-scoped decisions only)
├── Risk traceability (phase-scoped risks only)
└── Edge cases (phase-scoped only)
```

**Key rules:**
- **No SC spans multiple phases.** If an SC requires Phase 2 and Phase 3, split it into SC-3a (Phase 2) and SC-3b (Phase 3).
- **Each phase spec is <80 lines.** Small enough for an agent to hold in context without pollution.
- **Phase specs are created on-demand**, not all upfront. Phase 2 spec is written after Phase 1 merges, incorporating learnings.

**Sources:** LeanSpec "partitioning" strategy, DSPI per-ticket `specs.md`, Augment Code "task breakdown" pattern, SDD Anti-patterns #2 "Big Spec Up Front."

### Layer 3: Implementation Plans (one per phase spec)

Standard task breakdown, scoped to one phase. Each task is 30min-3hrs, atomic, independently testable.

**Sources:** Spec Kit tasks, DSPI `*task.md`, every SDD framework.

### The Flow

```
Project Charter (stable, rarely changes)
    │
    ├── Phase 1 Spec → Plan → Implement → Merge → Verify
    │       (learnings feed back into Phase 2 spec)
    ├── Phase 2 Spec → Plan → Implement → Merge → Verify
    │       (learnings feed back into Phase 3 spec)
    ├── Phase 3 Spec → Plan → Implement → Merge → Verify
    └── Phase 4 Spec → Plan → Implement → Merge → Verify
```

## Research Support

### SDD Anti-patterns (Lopez-Dona, 2026)

| Anti-pattern | Description | Relevance |
|---|---|---|
| **#2 Big Spec Up Front** | "If your spec needs more than one screen, you are describing two features that should be separated" | Directly describes the monolithic spec problem |
| **#12 Generated spec as pseudocode** | "If your spec mentions function signatures, class names, or payload structures, delete them. A good spec survives two different implementations." | Issue #1 embeds Godot API calls — would not survive a framework switch |
| **#13 Fusing user story + spec** | "The user story answers what the user wants. The spec answers what observable guarantees the system must meet. They are not the same thing." | Charter (what/why) vs Phase Spec (observable guarantees) separation |

### Context Engineering (LeanSpec, 2026)

> "AI performance degrades significantly as context grows, even when you are nowhere near the limit. More context = more confusion = lower accuracy."

Four strategies recommended:
1. **Partitioning** — Split and load selectively (maps to Phase Specs)
2. **Compaction** — Remove redundancy (maps to Charter being stable)
3. **Compression** — Summarize what is done (maps to completed phases being archived)
4. **Isolation** — Separate unrelated concerns (maps to independent phase specs)

### Spec-Driven Development (BCMS Guide, 2026)

> "The spec is the source of truth — but specs should be scoped to independently shippable units, not entire projects."

### Augment Code SDD Guide (2026)

> "Spec weight proportional to the cost of the change if it goes wrong. Trivial bug fixes do not deserve a spec; big features do."

The three-layer hierarchy naturally scales spec weight: Charter is lightweight, Phase Specs are moderate, Implementation Plans are detailed.

### Spec Kit Workshop Best Practices (2026)

> "Keep tasks atomic. One task, one job. If a task is > 3 hours, break it down."

Applied at the spec level: if a spec describes more than one independently shippable phase, break it into phase specs.

## Concrete Example: How Issue #1 Would Be Restructured

### Current (Monolithic — 246 lines)

Single `spec.md` with:
- Project goals, non-goals, constraints
- Architecture diagram, communication flow
- Decision ledger (DEC-1 through DEC-10)
- Risk traceability table (RISK-1 through RISK-6)
- 4 phases with cross-phase SCs (SC-3 → Phase 2+3, SC-4 → Phase 3+4)
- Implementation details: port numbers, Godot API calls, message formats

### Proposed (Three-Layer)

**Layer 1: `docs/charters/phone-controller.md`** (~40 lines)
- Problem statement, goals, non-goals
- Constraints (all-Godot stack, LAN-only, Godot 4.7)
- Architecture overview (one diagram)
- Phase map: 4 phases with one-line descriptions
- No SCs, no decisions, no risks

**Layer 2: `docs/specs/phase-01-scaffolding.md`** (~50 lines)
- SC-1: Two isolated Godot 4.7 projects exist
- SC-2: MCP plugin installed and enabled
- SC-10: MCP server entries configured
- SC-11: AGENTS.md documents port assignments
- All SCs verifiable within Phase 1

**Layer 2: `docs/specs/phase-02-host.md`** (~70 lines)
- SC-3a: WebSocket server accepts connections (Phase 2 only)
- SC-5: QR code displayed with HTTP URL
- SC-6: HTTP server serves with COOP/COEP headers
- SC-7: Dynamic port selection
- SC-9a: Ping/pong keepalive (Phase 2 only)
- All SCs verifiable within Phase 2

**Layer 2: `docs/specs/phase-03-client.md`** (~60 lines)
- SC-3b: Client connects and exchanges JSON messages (Phase 3 only)
- SC-4a: Touch pad sends relative deltas (Phase 3 only)
- SC-8a: Client GUID generation and persistence (Phase 3 only)
- SC-9b: Client responds to ping (Phase 3 only)
- All SCs verifiable within Phase 3

**Layer 2: `docs/specs/phase-04-integration.md`** (~50 lines)
- SC-4b: Host applies deltas as movement (Phase 4 only)
- SC-8b: Host restores state on reconnection (Phase 4 only)
- SC-12: Full POC test plan passes
- All SCs verifiable within Phase 4

## Changes Required in Upstream Workflows

### 1. spec-creation skill

Add a new task for creating Project Charters (Layer 1), distinct from Phase Specs (Layer 2). The charter template should be minimal — problem, goals, non-goals, constraints, architecture overview, phase map. No SCs, no decision ledger, no risk tables.

The existing spec-creation flow should be modified to detect when a spec describes multiple independently shippable phases and suggest splitting into a charter + phase specs.

### 2. writing-plans skill

Plans should be scoped to a single phase spec, not a multi-phase charter. The plan references the phase spec's SCs, not the charter's goals.

### 3. approval-gate skill

Authorization scope should support phase-level granularity: "approved Phase 1" vs "approved Phase 2." The `for_implementation` scope should bind to a specific phase, not the entire project.

### 4. issue-operations skill

Sub-issue structure should reflect the phase hierarchy: Charter (parent) → Phase Specs (children) → Implementation Plans (grandchildren). Each phase spec gets its own sub-issue under the charter.

### 5. spec-creation-validation skill

Add a "monolith detection" check: if a spec exceeds ~80 lines or describes multiple independently shippable phases, flag it for decomposition into a charter + phase specs.

### 6. spec-creation-decomposition skill

Add a "phase independence" analysis: for each proposed phase, verify that its SCs do not depend on deliverables from other phases. Cross-phase SCs must be split into per-phase sub-SCs.

## Suppositions

1. **Phase specs are cheaper to revise than monolithic specs.** A 50-line phase spec can be rewritten in minutes when assumptions change. A 246-line monolithic spec requires coordinated revision across all sections.

2. **Phase-level authorization reduces risk.** Approving "Phase 1 only" is safer than approving all 4 phases upfront. If Phase 1 reveals a fundamental flaw, no Phase 2-4 spec work was wasted.

3. **Cross-phase SC coupling is always a design smell.** If an SC truly requires two phases, it should be split into sub-SCs — one per phase — each independently verifiable. The integration SC (Phase 4) verifies the composition.

4. **The charter is the "constitution" for the project.** It should change only when the project's fundamental scope or constraints change. Implementation discoveries should update phase specs, not the charter.

5. **Phase specs created on-demand produce better specs.** The Phase 2 spec written after Phase 1 merges incorporates real knowledge about what works and what doesn't. The Phase 2 spec written upfront is based on guesses.

## Non-Goals

- This spec does NOT propose changing the existing single-phase spec workflow. For small, single-phase features, the current approach works fine.
- This spec does NOT propose a specific file format or template for charters. The upstream should define the canonical template.
- This spec does NOT propose changing the verification-before-completion or audit workflows. Those operate on phase specs the same way they operate on current specs.

## References

1. **SDD Anti-patterns** (Lopez-Dona, 2026) — https://jmlopezdona.github.io/ai-coding-agents-sdd/11-anti-patterns/
   - Anti-pattern #2: Big Spec Up Front
   - Anti-pattern #12: Generated spec as pseudocode
   - Anti-pattern #13: Fusing user story and spec

2. **Why Your AI Agent Gets Dumber with Large Specs** (LeanSpec, 2026) — https://www.lean-spec.dev/blog/ai-agent-performance
   - Context engineering: partitioning, compaction, compression, isolation
   - Databricks long-context performance degradation research
   - Berkeley Function-Calling Leaderboard

3. **Spec-Driven Development: The Definitive 2026 Guide** (BCMS) — https://thebcms.com/blog/spec-driven-development
   - Four-phase SDD lifecycle
   - EARS notation for acceptance criteria

4. **What Is Spec-Driven Development?** (Augment Code, 2026) — https://www.augmentcode.com/guides/what-is-spec-driven-development
   - Six-element spec framework
   - Spec weight proportional to risk
   - Adversarial agent pattern

5. **Spec Kit Workshop: Best Practices** (2026) — https://roelantd.github.io/spec-kit-workshop/07-best-practices
   - Atomic tasks, consistent sizing
   - Phase-by-phase validation

6. **SDD Anti-patterns** (SDD Planner) — https://sddplanner.com/spec-driven-design-anti-patterns/
   - Anti-pattern #8: Mixing PRD and spec

7. **DSPI: Design-Specify-Plan-Implement** (dev.to) — https://dev.to/jhagerer/spec-driven-development-based-on-dspi-design-specify-plan-implement-dm2
   - Per-ticket folder structure with separate files per concern

8. **The Art of Software Decomposition** (aspiecoder.com, 2025) — https://aspiecoder.com/2025/02/20/the-art-of-software-decomposition-building-complex-systems-piece-by-piece/
   - Functional decomposition, high cohesion, low coupling

9. **SDD Technical Deep Dive** (Rushi, 2026) — https://www.rushis.com/spec-driven-development-sdd-a-technical-deep-dive-into-the-methodologies-reshaping-ai-assisted-engineering/
   - SDD maturity spectrum: Spec-First → Spec-Anchored → Spec-as-Source
   - Framework comparison (Spec-Kit, OpenSpec, BMAD, Kiro, Tessl)

10. **Downstream example** — Issue #1 in catacomb-paws: 246-line monolithic spec with 4 phases, 14 SCs, cross-phase coupling. Concrete demonstration of the anti-pattern.

## AI Co-Authored Byline

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
