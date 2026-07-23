# Phase 2: analyze.md + retroactive.md + create.md + solve.md

**Skill:** `writing-plans`
**Task:** `create`
**Target:** `writing-plans/tasks/{analyze,retroactive,create,solve}.md`
**SCs:** SC-5, SC-7, SC-8, SC-9
**Depends On:** Phase 1

## Context

- analyze.md: strict entry gate — spec.md must exist (BLOCKED with SPEC_NOT_FOUND), YAML frontmatter approval check, 7 analytical artifacts validation, scope boundary check
- retroactive.md: lenient entry gate — backfill missing artifacts from spec body + codebase inspection
- create.md: reads analysis summary, discovers implementation-pipeline SKILL.md TDT, decomposes SCs into phases, builds dependency DAG, writes plan.md and dependency-contract.yaml
- solve.md: reads dependency contract, runs tools/solve (SAT/UNSAT), runs tools/plan (SOLVED/UNSOLVABLE), writes solve-output.yaml
- Issues prefix: `.opencode/.issues`

## Entry Criteria

- [ ] Phase 1 complete (stubs exist)
- [ ] Implementation-pipeline SKILL.md accessible for TDT discovery

## Procedure

1. Implement analyze.md with strict entry gate
2. Implement retroactive.md with lenient entry gate
3. Implement create.md with pipeline discovery and routing table generation
4. Implement solve.md with tools/solve and tools/plan dispatch
5. Verify each task produces correct result contracts

## Exit Criteria

- [ ] analyze.md blocks with SPEC_NOT_FOUND when spec.md missing
- [ ] analyze.md checks approval from local frontmatter only (no GitHub API)
- [ ] retroactive.md backfills missing artifacts
- [ ] create.md discovers pipeline TDT and produces routing-table plan
- [ ] solve.md runs tools/solve and tools/plan
