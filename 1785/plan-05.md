# Phase 5 — Structural changes

- **Concern:** Update `audit/SKILL.md` §Blind Dispatch to document `audit_phase` as optional field (SC-17) + rename all stale `adversarial-audit` references to `audit` across 5 files (SC-18)
- **Files:**
  - `.opencode/skills/audit/SKILL.md` — update §Blind Dispatch
  - `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml` — rename `adversarial-audit` → `audit`
  - `.opencode/.guidelines/registry.yaml` — update paths
  - `.opencode/CHANGELOG.md` — update reference
  - `.opencode/README.md` — update reference
  - `.opencode/docs/adversarial-audit-sc6959-verification.md` — rename to `audit-sc6959-verification.md` + update content
- **SCs:** SC-17, SC-18
- **Dependencies:** None
- **Entry conditions:** Phase 4 complete
- **Exit conditions:** Blind Dispatch updated, all stale references renamed, grep returns 0 matches for `adversarial-audit`

## Step-by-step

- [ ] 40. **RED: SC-17 grep check (**inline**).** Run `grep "No.*audit_phase" .opencode/skills/audit/SKILL.md`. Confirm it returns a match (the current "No `audit_phase` field" text). **→ SC-17**
- [ ] 41. **GREEN: Update audit/SKILL.md §Blind Dispatch (**sub-agent**).** Read `.opencode/skills/audit/SKILL.md` §Blind Dispatch section. Replace the current text with the updated version documenting `audit_phase` as optional. The diff:
  ```
  - Dispatch contracts carry exactly 2 fields: `spec_local_dir` and `artifact_evidence_dir`. No `audit_phase` field.
  + Dispatch contracts carry:
  +   - `spec_local_dir` (required) — path to spec directory
  +   - `artifact_evidence_dir` (required) — path to evidence artifacts directory
  +   - `audit_phase` (optional) — pipeline phase identifier for phase-aware audit tasks
  ```
  Verify with `grep "No.*audit_phase" .opencode/skills/audit/SKILL.md` returns 0 matches. **→ SC-17**
- [ ] 42. **RED: SC-18 stale reference grep (**inline**).** Run `grep -r "adversarial-audit" .opencode/ --include="*.md" --include="*.yaml" --include="*.yml"`. Confirm matches exist in the 5 target files. **→ SC-18**
- [ ] 43. **GREEN: Rename pipeline-state-machine.yaml (**sub-agent**).** Read `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`. Replace all 4 occurrences of `adversarial-audit` with `audit`. **→ SC-18**
- [ ] 44. **GREEN: Rename registry.yaml (**sub-agent**).** Read `.opencode/.guidelines/registry.yaml`. Replace both `adversarial-audit` path references with `audit`. **→ SC-18**
- [ ] 45. **GREEN: Rename CHANGELOG.md reference (**sub-agent**).** Read `.opencode/CHANGELOG.md`. Replace the single `adversarial-audit` reference with `audit`. **→ SC-18**
- [ ] 46. **GREEN: Rename README.md reference (**sub-agent**).** Read `.opencode/README.md`. Replace the single `adversarial-audit` reference with `audit`. **→ SC-18**
- [ ] 47. **GREEN: Rename doc file (**sub-agent**).** Rename `.opencode/docs/adversarial-audit-sc6959-verification.md` to `.opencode/docs/audit-sc6959-verification.md`. Read the file content and replace all `adversarial-audit` references with `audit`. **→ SC-18**
- [ ] 48. **Verify SC-18 (**inline**).** Run `grep -r "adversarial-audit" .opencode/ --include="*.md" --include="*.yaml" --include="*.yml"`. Confirm 0 matches. **→ SC-18**
- [ ] 49. **Checkpoint commit (**inline**).** `git add .opencode/skills/audit/SKILL.md .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml .opencode/.guidelines/registry.yaml .opencode/CHANGELOG.md .opencode/README.md .opencode/docs/audit-sc6959-verification.md .opencode/docs/adversarial-audit-sc6959-verification.md && git commit -m "Phase 5: Structural changes — Blind Dispatch update + stale adversarial-audit rename (SC-17, SC-18)"`. Create checkpoint tag `michael-conrad/checkpoint/1785/phase-5-opencode`. **→ SC-all**

#### Phase 5 VbC

- [ ] **VbC (**clean-room**).** Verify `audit/SKILL.md` §Blind Dispatch documents `audit_phase` as optional. Run `grep -r "adversarial-audit" .opencode/ --include="*.md" --include="*.yaml" --include="*.yml"` and confirm 0 matches. Verify renamed doc file exists at new path. **→ SC-17, SC-18**

**Concern transition:** Leaving structural changes → entering auto-invocation. Phase 6 depends on Phase 1 test infrastructure pattern.
