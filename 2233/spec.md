> **Full spec and artifacts: [`.opencode/.issues/2233/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2233)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2233/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

**Problem Statement:** The opencode config schema at https://opencode.ai/config.json supports granular bash command permissions via `agent.build.permission.bash` with glob patterns (e.g., `"git push": "ask"`, `"grep *": "allow"`). However, this feature is undocumented in the .opencode repository's own documentation, has no examples in the repo's opencode.jsonc, and has no behavioral enforcement tests. Users cannot discover that they can set permissions for specific bash commands rather than blanket allow/ask/deny.

**Root Cause / Motivation:** The granular bash permission feature was added to the opencode schema but never documented in the .opencode repo. Without documentation, users default to blanket permissions — either overly permissive (allowing dangerous commands) or overly restrictive (blocking legitimate workflow commands). The feature exists but is invisible.

**Approach Chosen:** Create a single documentation file `.opencode/docs/bash-permissions.md` covering syntax, examples, and merging behavior. Add a behavioral enforcement test verifying the agent respects configured patterns.

**Alternatives Considered & Why Discarded:**
- Adding documentation to the opencode.jsonc itself via comments: JSONC comments are not rendered in schema docs and would not be discoverable
- Modifying the opencode.jsonc to include permission fields: The repo's opencode.jsonc is a reference config — adding permissions would change its behavior, not just document it
- Creating multiple doc files: A single file with sections is simpler and avoids fragmentation

**Key Design Decisions:**
- Single doc file with three sections: syntax reference, example snippet, merging behavior
- Behavioral test follows existing patterns in `.opencode/tests-v2/behaviors/`
- Content-verification tests for documentation SCs (grep-based)

**User Intent / Original Prompt:** Document the `agent.build.permission.bash` granular pattern syntax, provide examples, add behavioral enforcement tests, and document permission merging behavior.

## Not Included

- Modifying the repo's opencode.jsonc to include permission fields
- Adding permissions to any other config file
- Modifying the opencode schema or config validation
- Backfilling permissions into existing behavioral tests
- Documentation in the opencode upstream project (only the .opencode submodule repo)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Document the `agent.build.permission.bash` granular pattern syntax in the .opencode repo | `string + semantic` | grep for pattern documentation + sub-agent read |
| SC-2 | Add an example opencode.jsonc snippet showing bash command patterns to the documentation | `string` | grep for example snippet |
| SC-3 | Add behavioral enforcement test verifying the agent respects bash command permission patterns | `behavioral` | `opencode run` with permission config → stderr assertions |
| SC-4 | Document the permission merging behavior (top-level vs agent.build override) | `string + semantic` | grep for merge docs + sub-agent read |

## Requirements

1. The documentation SHALL describe the glob pattern syntax for `agent.build.permission.bash` entries.
2. The documentation SHALL include at least one example opencode.jsonc snippet showing bash command patterns.
3. The behavioral enforcement test SHALL use the `with-test-home` wrapper and `helpers.sh` assertion helpers.
4. The documentation SHALL describe how top-level `permission.bash` and `agent.build.permission.bash` merge.
5. The behavioral enforcement test SHALL verify that a `deny` pattern blocks the agent from running the matched command.
6. The behavioral enforcement test SHALL verify that an `allow` pattern permits the agent to run the matched command.

## Items

1. SC-1: Document bash permission syntax
2. SC-2: Add example opencode.jsonc snippet
3. SC-3: Add behavioral enforcement test
4. SC-4: Document permission merging behavior

## Dependencies

- None — this spec is self-contained

## Traceability

| Requirement | SC | Item |
|-------------|----|------|
| REQ-1 | SC-1 | 1 |
| REQ-2 | SC-2 | 2 |
| REQ-3 | SC-3 | 3 |
| REQ-4 | SC-4 | 4 |
| REQ-5 | SC-3 | 3 |
| REQ-6 | SC-3 | 3 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| opencode config schema | API | https://opencode.ai/config.json | Fetch and inspect PermissionConfig definition |
| Existing behavioral test patterns | Code | `.opencode/tests-v2/behaviors/` | `ls` directory listing |
| Existing test helpers | Code | `.opencode/tests-v2/behaviors/helpers.sh` | Read file |
| with-test-home wrapper | Code | `.opencode/tests-v2/with-test-home` | Read file |

## Enforcement Gate

All four success criteria SHALL pass before this spec is considered complete. No partial delivery is permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the syntax documentation exists costs one grep and one sub-agent read. Skipping means the syntax reference is missing and every downstream consumer (examples, tests, merging docs) builds on an undocumented foundation.
- SC-2: Verifying the example snippet exists costs one grep. Skipping means users have syntax docs but no practical reference — the documentation is incomplete.
- SC-3: Running the behavioral test costs minutes of execution time. Skipping means the behavioral defect ships to production and costs 1000× more to fix.
- SC-4: Verifying the merging docs exist costs one grep and one sub-agent read. Skipping means users apply permissions at the wrong level and the override behavior is discovered through trial and error.

## Edge Cases

- **Empty glob pattern map:** If `permission.bash` is an empty object `{}`, all commands fall through to the blanket permission or default (ask).
- **Overlapping glob patterns:** If two patterns match the same command, the more specific pattern wins. If equally specific, the last one in insertion order applies.
- **No blanket permission set:** If neither top-level nor agent.build has a blanket string permission, the default is `ask`.
- **Pattern with no match:** A command that does not match any glob pattern falls through to the blanket permission or default.
