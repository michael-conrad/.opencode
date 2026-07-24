---
plan_schema_version: "1.0"
issue: 2101
title: "Upgrade viewport-editor from v0.3.4 to v0.5.0"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 1
---

# Implementation Plan — #2101 — Upgrade viewport-editor to v0.5.0

**Goal:** Bump the viewport-editor MCP server version pin from `v0.3.4` to `v0.5.0` in `.opencode/opencode.jsonc`.

**Architecture:** Single-line string replacement in a JSONC config file. No structural changes, no dependency changes, no behavioral changes.

**Files:**
- `.opencode/opencode.jsonc`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Version pin bump | `test-driven-development` | `green` | `.opencode/opencode.jsonc` line 133 | SC-1, SC-2, SC-3 | — |

---

## Phase Details

### Phase 1 — Version Pin Bump

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/opencode.jsonc` line 133 |
| SCs | SC-1, SC-2, SC-3 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/opencode.jsonc
old_value: "viewport-editor@v0.3.4"
new_value: "viewport-editor@v0.5.0"
sc_ids:
  - SC-1: "opencode.jsonc references viewport-editor@v0.5.0"
  - SC-2: "No remaining references to v0.3.4 outside changelog/history"
  - SC-3: "uvx can resolve the new version"
```

---

## Pre-Implementation

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec #2101 is approved and the version string `v0.3.4` exists at the expected location in `.opencode/opencode.jsonc`. **→ pre-flight**
- [ ] 2. **Baseline check (**clean-room**).** Run `grep 'viewport-editor@v0.3.4' .opencode/opencode.jsonc` to confirm the current state. **→ pre-flight**

---

## Phase 1 — Version Pin Bump

**Concern:** Update the viewport-editor version string.

**Files:**
- `.opencode/opencode.jsonc`

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** None

**Entry Conditions:**
- Coherence gate passed: spec approved, target string confirmed present
- Baseline check passed: current version confirmed

**Exit Conditions:**
- `.opencode/opencode.jsonc` references `viewport-editor@v0.5.0`
- No remaining references to `viewport-editor@v0.3.4` in the repo
- `uvx` can resolve the new version

---

- [ ] 3. **GREEN (**sub-agent**).** Replace `v0.3.4` with `v0.5.0` in `.opencode/opencode.jsonc`. **→ SC-1, SC-2**
- [ ] 4. **GREEN doublecheck (**clean-room**).** Run `grep 'viewport-editor@v0.5.0' .opencode/opencode.jsonc` to confirm the new version is present. Run `grep -r 'viewport-editor@v0.3.4' .opencode/` to confirm no stale references remain. **→ SC-1, SC-2**
- [ ] 5. **Structural check (**inline**).** Run `uvx --from git+https://github.com/michael-conrad/viewport-editor@v0.5.0 --help` to verify the new version resolves. **→ SC-3**
- [ ] 6. **Checkpoint commit (**inline**).** Commit the version bump.

#### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify all 3 SCs: SC-1 (grep for v0.5.0), SC-2 (grep for v0.3.4 returns no matches outside changelog), SC-3 (uvx --help exits 0). **→ SC-1, SC-2, SC-3**

---

## Post-Implementation

- [ ] 8. **Structural checks (**sub-agent**).** Run lint/format checks on modified files. **→ post-flight**
- [ ] 9. **Audit (**sub-agent**).** Dispatch verification-audit for the version bump. **→ post-flight**
- [ ] 10. **Cross-validate (**clean-room**).** Verify audit findings against evidence artifacts. **→ post-flight**
- [ ] 11. **Review prep (**sub-agent**).** Prepare PR with summary of the change. **→ post-flight**
- [ ] 12. **Create PR (**sub-agent**).** Create pull request for the feature branch. **→ post-flight**
- [ ] 13. **Completion (**sub-agent**).** Report summary with PR URL. **→ post-flight**

---

## Exit Criteria

- [ ] C1. `.opencode/opencode.jsonc` references `viewport-editor@v0.5.0`
- [ ] C2. No remaining references to `viewport-editor@v0.3.4` in the repo
- [ ] C3. `uvx --from git+https://github.com/michael-conrad/viewport-editor@v0.5.0 --help` exits successfully
