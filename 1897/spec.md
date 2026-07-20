## Problem

A drift audit of #1709 (Release PR workflow bypass fix) confirmed 9 of 10 phases structurally complete, but Phase 10 (behavioral tests) has 2 of 3 scripts missing. The `release-pr-dispatch.sh` test exists, but `version-discovery.sh` and `release-tagging.sh` were never created.

Additionally, a secondary gap was found in the parent repo (`michael-conrad/opencode-config`): the `AGENTS.md` Reference Files table at `/AGENTS.md:11-15` lists `.opencode/AGENTS.md`, `.opencode/.issues/AGENTS.md`, and `.issues/AGENTS.md` but is missing reference lines for `.opencode/skills/version-manager/` and `.opencode/skills/release-promoter/`.

## Root Cause

#1709 Phase 10 implementation documented the behavioral test templates and marked 1 of 3 as completed (`release-pr-dispatch.sh`). The remaining 2 scripts (`version-discovery.sh` and `release-tagging.sh`) were left as `❌ NOT DONE` in the SC table and never completed. The parent `AGENTS.md` was never updated when the skills were created in Phases 5 and 6.

## Scope

### Gap 1: Missing behavioral tests (`.opencode` repo — Phase 10 gap)

- `.opencode/tests/behaviors/version-discovery.sh` — does not exist
- `.opencode/tests/behaviors/release-tagging.sh` — does not exist

### Gap 2: Missing AGENTS.md reference lines (parent repo — documentation drift)

- `AGENTS.md` Reference Files table at michael-conrad/opencode-config is missing entries for `.opencode/skills/version-manager/` and `.opencode/skills/release-promoter/`

## Behavioral Test Templates

The test templates were defined in the #1709 spec body Phase 10 section. Per the current `tests/behaviors/AGENTS.md` artifact-only generator paradigm (scripts call `behavior_run` and exit 0; evaluation is the orchestrator's job), the templates have been updated to match the convention used by `release-pr-dispatch.sh`.

### `version-discovery.sh`

```bash
#!/bin/bash
# Behavioral test: version-discovery
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-23: version-manager discovers versions in multiple file formats

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="version-discovery"
SCENARIO_PROMPT="discover version strings in the project"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
```

### `release-tagging.sh`

```bash
#!/bin/bash
# Behavioral test: release-tagging
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-24: release-promoter creates annotated tag with v prefix

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="release-tagging"
SCENARIO_PROMPT="tag and create a release for v1.2.3"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
```

## AGENTS.md Reference Lines

The parent repo `AGENTS.md` Reference Files table needs these entries added:

```
| `.opencode/skills/version-manager/` | Version string discovery and semver bumping: discover, bump tasks |
| `.opencode/skills/release-promoter/` | Git tag creation and GitHub Release promotion: tag, create-release tasks |
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/tests/behaviors/version-discovery.sh` exists with artifact-only generator pattern (behavior_run + exit 0) | `structural` | File exists |
| SC-2 | `.opencode/tests/behaviors/release-tagging.sh` exists with artifact-only generator pattern (behavior_run + exit 0) | `structural` | File exists |
| SC-3 | Behavioral test for version-discovery produces artifacts when run: manifest.yaml, stdout.log, stderr.log, exit_code, session.yaml | `behavioral` | `bash .opencode/tests/behaviors/version-discovery.sh` — verify artifact directory is well-formed |
| SC-4 | Behavioral test for release-tagging produces artifacts when run: manifest.yaml, stdout.log, stderr.log, exit_code, session.yaml | `behavioral` | `bash .opencode/tests/behaviors/release-tagging.sh` — verify artifact directory is well-formed |
| SC-5 | Parent repo `AGENTS.md` Reference Files table includes entries for `.opencode/skills/version-manager/` and `.opencode/skills/release-promoter/` | `string` | grep for `version-manager` and `release-promoter` in parent AGENTS.md |

## Related Issues

- #1709 (parent spec — release PR workflow bypass fix, Phases 1-10)
- #1708 (bug report — original symptom of release PR dispatch gap)

## Change Control

| Date | Change |
|------|--------|
| 2026-07-11 | Initial SPEC-FIX — closes Phase 10 behavioral test gap and parent AGENTS.md reference gap |
