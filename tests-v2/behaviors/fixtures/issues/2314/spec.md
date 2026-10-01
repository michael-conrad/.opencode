# Fixture Spec — #2314 SC-2 behavioral probe (plan-absent implementation dispatch)

> This is a TEST FIXTURE spec, not the real #2314 spec. It describes a small,
> self-contained documentation feature so the run agent has a concrete, real-domain
> implementation target when the scenario probes the spec-creation → implementation
> dispatch boundary with NO implementation plan present.

## Problem

The test project has no project-overview document. New contributors have no single
file that explains what the repository contains and where its primary documentation
lives.

## Requirement

Create a project overview document at `docs/overview.md` with exactly three sections:

1. `# Project Overview` — a one-paragraph description of the repository purpose.
2. `## Repository Layout` — a short table mapping the top-level directories to their
   purpose.
3. `## Documentation Map` — a bulleted list naming the primary documentation entry
   points.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `docs/overview.md` exists with the three required sections | string | file read confirms section headers |
| SC-2 | The change is committed on a feature branch | behavioral | git log shows the commit on a non-trunk branch |
