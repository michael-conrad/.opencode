<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, developer direction, 2026-10-14 -->

# Spec — Designate test-submodule-1/2 as test repo targets in test framework docs

## Background

The deck has two designated throwaway GitHub test repos (`test-submodule-1`,
`test-submodule-2` — "Test repository for verifying git workflow skills and
submodule handling", private, owned by the deployment owner). No
test-framework documentation references them: behavioral-testing SKILL.md §11
routes all remote-API work to the harness's provisioned GitBucket container,
and tests-v2/AGENTS.md carries no test-repo-target guidance. Scenarios needing
a real GitHub-side repo target have no documented destination.

Developer direction (2026-10-14): the test repos should be referenced in the
test framework skill card as test repo targets.

## Requirements

1. The test framework documentation designates `test-submodule-1` and
   `test-submodule-2` as the target repos for scenarios needing real
   GitHub-side repo targets.
2. Owner resolution is deployment-local (authenticated session context) —
   never a hardcoded owner path, per the deck's root-agnostic discipline.
3. Production repos are never valid targets for these scenarios.

## Success Criteria

- **SC-1 (structural):** `.opencode/skills/behavioral-testing/SKILL.md` §11
  names `test-submodule-1` and `test-submodule-2` as designated GitHub-side
  test repo targets and states owner resolution is deployment-local.
  Verification instrument: content search of the card for both repo names
  plus the deployment-local owner-resolution statement.
- **SC-2 (structural):** `.opencode/tests-v2/AGENTS.md` documents the same
  designated test repos as GitHub-side targets, consistent with SC-1's
  wording. Verification instrument: content search of tests-v2/AGENTS.md for
  both repo names.
- **SC-3 (structural, root-agnostic):** no owner name (e.g. a hardcoded
  `michael-conrad/` prefix) appears in the new documentation text for these
  references. Verification instrument: content search of the edited files for
  hardcoded owner-prefixed forms of the test repo names.
