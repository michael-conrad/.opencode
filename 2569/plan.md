# Plan — Math MCP deny-by-default + dedicated math-ops subagent (.opencode#2569)

Spec: `.opencode/.issues/2569/spec.md`. Authorization: terminal-stage
(`approved for pr`, 2026-10-10) — carries the item through plan, implement, and
the PR boundary; merge remains human-only.

## Reference-currency remediations applied to the spec before planning

1. **Subagent directory path.** Spec Final-state item 2 and SC-5 name
   `.opencode/agent/math-ops.md`; the live deck's subagent directory is
   `.opencode/agents/` (existing cards: `email-ops.md`, `vision-agent.md`,
   `visual-design-agent.md`). All path references in this plan use the live
   path `.opencode/agents/math-ops.md`; the spec file was corrected in place
   (synced commit `c49ef8f0`). A card outside `agents/` would not be loaded as
   a subagent at all, so the live path is the only self-consistent reading of
   the spec.

## SC validation (against spec/references/validation-standards.md)

All seven criteria PASS. Judgment notes:

- **SC-7**'s "documented `opencode.db` query protocol" resolves concretely:
  first assistant message of a main-agent (parentless) session, filtered to
  providerID `huggingface` + modelID `zai-org/GLM-5.3-Flash`, `tokens.input`
  from the message JSON, median across sessions. Reproduced against the live
  db on 2026-10-10: n=128 first-turn records for that model since 2026-03,
  median **21,937** — the spec's ~22.0K baseline. Spec threshold: the
  post-change fresh-session measurement must be ≤ 21,000.
- **SC-7 intervening-change note.** #2572 (gmail deny, merged 2026-10-10
  03:57 UTC) already removed ~3.3K tokens from first-turn sessions — post-gmail
  fresh sessions on the trunk measure 18,694 / 18,703 (n=2, median 18,698).
  The spec-literal ≤ 21,000 threshold is therefore weak evidence of the math
  change's own contribution: it would pass even without this change. The SC-7
  item below records both the spec-literal check AND a like-for-like marginal
  delta (pre-math trunk fresh-session median vs post-math fresh-session
  median, A/B control per the #2568 review convention) so the reduction is
  attributed to the math rule itself. A marginal delta < 1,000 is surfaced at
  verify, never buried.
- **SC-1 / SC-2 evidence environment.** The math MCP server
  (`mcp-mathematics`) is defined only in the developer's global config
  (`~/.config/opencode/opencode.jsonc`), never in the deck config and never in
  the harness's seeded env (`seed_model_config` generates model + models
  only). Injecting it into the seeded test config is a forbidden isolation
  bypass (observed regression #2538). Consequences, mirroring #2568's
  findings: SC-1's harness evidence is vacuous in isolation (no math server
  exists in the test env, so tool absence is attributable to the missing
  server, not the deny rule); SC-2 is not producible in-harness. The generic
  mechanism was source-verified in #2568 (flat deny rules remove matched
  tools from the model toolset — `Permission.disabled` → `resolveTools`;
  agent frontmatter rules merge after config rules, so the subagent's allow
  is the last matching rule and wins with no permission prompt) and applies
  identically to `math_*`: the rule-matching code is tool-family-generic.
  Pre-merge behavioral evidence for SC-1/SC-2/SC-7 is produced at the
  installed binary (ruleset resolution + probe sessions, disclosed) per the
  #2568 review convention; production confirmation closes post-merge.

## Items

### Item 1 — SC-4 (structural): deck config deny rule

- **Deliverable:** `.opencode/opencode.jsonc`'s `permission` block gains
  `"math_*": "deny"` alongside the existing `"gmail_*": "deny"`. No `mcp`
  entry is added, removed, or modified (out-of-scope constraint).
- **RED:** config inspection of current `main` shows the permission block
  holds only `"gmail_*": "deny"`; the math tools are reachable in every
  main-agent session (observable directly: the live session toolset carries
  the `math_*` family).
- **GREEN:** add the rule.
- **Instrument:** direct config inspection of the implementation diff.
- **Note:** the syntax and mechanism are proven by #2568 in this same file
  and in the same opencode source paths — no further schema research needed.

### Item 2 — SC-5 (structural): math-ops subagent card

- **Deliverable:** `.opencode/agents/math-ops.md` with frontmatter
  `mode: subagent`; description ≤ 30 words containing the trigger vocabulary
  (math, calculate, statistics, conversion, matrix, number theory); explicit
  permission entry `"math_*": "allow"` (the MCP-tool default of `ask` is
  never relied upon).
- **RED:** the file does not exist; no subagent can hold a `math_*` allow.
- **GREEN:** create the card.
- **Instrument:** file inspection plus description word count.

### Item 3 — SC-6 (structural): card body tool-handling instructions + scope boundary

- **Deliverable:** the card body (authored with Item 2, same file) carries
  the math tool-handling instructions (the `math_*` tool family: expression
  and batch calculation, statistics, unit conversion, natural-language
  conversion, matrix operations, number theory, session variables, function
  listing, history) and the scope boundary: the card serves explicit
  math-MCP work; everyday arithmetic is native (bash/python) and must not be
  dispatched here; if the math tools are unavailable in the environment, the
  card reports that instead of approximating with other tools or installing
  anything (#2571 lesson).
- **RED:** new file — N/A as a standing behavior; the boundary text is
  verified present.
- **GREEN:** authored with Item 2.
- **Instrument:** file inspection of the card body.

### Item 4 — SC-1 (behavioral): main-agent toolset excludes math_*

- **RED:** a fresh main-agent session under the deck config exposes tools
  whose names start with `math_` (current behavior, observable in the live
  session toolset).
- **GREEN:** after Item 1, a fresh main-agent session's toolset contains no
  `math_*` tools.
- **Instrument:** session toolset inspection. In-harness evidence is vacuous
  in isolation (no math server in the seeded env); honest pre-merge evidence
  is ruleset resolution at the installed binary (`opencode debug config` /
  `debug agent` — the deny resolves as the main agent's last rule) plus the
  #2568 mechanism verification; production confirmation post-merge.

### Item 5 — SC-2 (behavioral): math-ops session computes without a permission stall

- **RED:** no `math-ops` subagent exists to dispatch to.
- **GREEN:** after Items 2–3, a session dispatched to `math-ops` has
  `math_*` tools available and completes a calculation (for example
  `math_calculate_expression`) with no ask/permission stall.
- **Instrument:** behavioral run; the transcript shows the tool call
  succeeding with no permission part. Not producible in the isolated harness
  env (no math MCP); pre-merge evidence per the #2568 review pattern (probe
  at the installed binary: dispatched child session, zero permission parts,
  tool-level response — not a permission error); production confirmation
  post-merge.

### Item 6 — SC-3 (behavioral): explicit math work routes to math-ops

- **RED:** a math-work request to the main agent does not dispatch to
  `math-ops` (the agent does not exist pre-change).
- **GREEN:** after Item 2, a developer request for explicit math-tool work
  (for example "use the math MCP to compute X") produces a transcript
  showing a task dispatch naming `math-ops`.
- **Instrument:** tests-v2 harness scenario
  `2569-sc3-math-intent-dispatch.sh` (artifact-only generator, prompt names
  the math MCP explicitly — real-domain task per §11) + clean-room
  evaluation per the two-SC pattern (§6a).

### Item 7 — SC-7 (behavioral): first-turn token reduction

- **RED:** first-turn `tokens.input` for a minimal-prompt main-agent session
  on `huggingface/zai-org/GLM-5.3-Flash` sits at the spec baseline (median
  21,937, n=128, reproduced from the live db per the documented protocol);
  the post-gmail trunk already measures ~18.7K (n=2, median 18,698).
- **GREEN:** after Items 1–3, a fresh minimal-prompt main-agent session
  measures ≤ 21,000 first-turn `tokens.input` (spec-literal: ≥ 1,000 below
  the ~22.0K baseline), and the like-for-like marginal delta vs the pre-math
  trunk level (post-gmail, A/B control with the deny overridden) is
  ≥ 1,000 tokens, attributing the reduction to the math rule itself.
- **Instrument:** the `opencode.db` query protocol — first assistant message
  of the fresh session, same model profile as the baseline.

## Dependency order

Item 1 → Item 4 (toolset change before toolset evidence). Items 2–3 → Items
5, 6 (the dispatch target must exist). Items 4–7 run only after their
supporting structural items are in place; Item 7 measures the landed deck and
runs last.

## Execution constraints

- **No governed deck edits in scope.** This change touches no
  `skills/`, `guidelines/`, `floor.md`, or `routing.md` file — the agent card
  lives in `.opencode/agents/`, outside the floor's deck-governance line
  (#2568 precedent: only its `skills/` edits were governed).
- Item 6 executes under the behavioral-testing card — the tests-v2 harness
  provisions the run, the run is supervised on the 60-second poll cycle, and
  a clean-room evaluator judges the artifacts; never an ad-hoc `opencode
  run`. Items 4/5/7 pre-merge evidence (where produced outside the harness)
  follows the #2568 disclosed-review convention; production confirmation for
  SC-1/SC-2 closes post-merge.
- All file changes happen in the `.opencode` submodule on feature branch
  `2569-math-deny-math-ops` created per git-workflow-branch before the first
  modification. The parent repo carries only the submodule pointer, which
  rides with the next real parent-repo change per pointer discipline.
- `reference-integrity` runs before committing any agent-facing markdown
  change.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
