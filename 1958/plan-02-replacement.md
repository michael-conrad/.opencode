# Phase 2 — Replace All Non-Conforming References

**Goal:** Convert every non-conforming cross-reference to the canonical `Load [descriptive text](relative/path.md)` form.

**Concern:** Replacement (guidelines, skills, tasks, default.txt)
**SCs:** SC-2, SC-3, SC-4, SC-5, SC-6, SC-7
**Dependencies:** Phase 1 complete

## Steps

### 2.1 Update 000-critical-rules.md

- [ ] Replace `Read [Text](path)` with `Load [Text](path)` in the cross-reference rule
- [ ] Replace any `See [Text](path)` with `Load [Text](path)`
- [ ] Replace any bare `§N` or `§Name` with inline `Load [descriptive text](path)` links
- [ ] SC-2: grep verify `Load [Text]` present

### 2.2 Update all SKILL.md files

- [ ] For each `.opencode/skills/*/SKILL.md`:
  - [ ] Replace `See [text](path)` → `Load [text](path)`
  - [ ] Replace `Read [text](path)` → `Load [text](path)`
  - [ ] Replace bare `§N` → inline `Load [descriptive text](path)`
  - [ ] Replace bare `§Name` → inline `Load [descriptive text](path)`
  - [ ] Remove resolution table + admonition patterns
  - [ ] Replace non-linked text references (`See file.md`, `See SKILLNAME skill`) → inline `Load [text](path)`
- [ ] SC-3: grep verify zero `See [` or `Read [` in any SKILL.md
- [ ] SC-5: grep verify zero `§` in any SKILL.md
- [ ] SC-6: grep verify zero resolution table patterns in any SKILL.md
- [ ] SC-7: grep verify zero non-linked text references in any SKILL.md

### 2.3 Update all guideline files

- [ ] For each `.opencode/guidelines/*.md`:
  - [ ] Replace `See [text](path)` → `Load [text](path)`
  - [ ] Replace `Read [text](path)` → `Load [text](path)`
  - [ ] Replace bare `§N` → inline `Load [descriptive text](path)`
  - [ ] Replace bare `§Name` → inline `Load [descriptive text](path)`
  - [ ] Replace non-linked text references → inline `Load [text](path)`
- [ ] SC-4: grep verify zero `See [` or `Read [` in any guideline

### 2.4 Update all task files

- [ ] For each `.opencode/skills/*/tasks/*.md`:
  - [ ] Replace `See [text](path)` → `Load [text](path)`
  - [ ] Replace `Read [text](path)` → `Load [text](path)`
  - [ ] Replace bare `§N` → inline `Load [descriptive text](path)`
  - [ ] Replace bare `§Name` → inline `Load [descriptive text](path)`
  - [ ] Replace non-linked text references → inline `Load [text](path)`

### 2.5 Update default.txt

- [ ] Update `.opencode/prompts/default.txt` to use `Load [text](path)` in any cross-reference directives

### 2.6 Update scripts

- [ ] Update `.opencode/scripts/*.py` if any cross-references found in docstrings

### 2.7 Verification sweep

- [ ] Run all grep-based SC verifications:
  - [ ] SC-2: `grep 'Load \[Text\]' .opencode/guidelines/000-critical-rules.md`
  - [ ] SC-3: `grep -r 'See \[' .opencode/skills/*/SKILL.md` — zero matches
  - [ ] SC-3: `grep -r 'Read \[' .opencode/skills/*/SKILL.md` — zero matches
  - [ ] SC-4: `grep -r 'See \[' .opencode/guidelines/*.md` — zero matches
  - [ ] SC-4: `grep -r 'Read \[' .opencode/guidelines/*.md` — zero matches
  - [ ] SC-5: `grep -r '§' .opencode/skills/*/SKILL.md` — zero matches
  - [ ] SC-6: `grep -r '| Reference | File |' .opencode/skills/*/SKILL.md` — zero matches
  - [ ] SC-7: `grep -rn 'See [A-Z]' .opencode/skills/*/SKILL.md` — zero matches
- [ ] Manual spot-check of 5 random SKILL.md files for edge cases

## Exit Criteria

- [ ] All non-conforming references replaced with canonical `Load [text](path)` form
- [ ] All grep-based SC verifications pass
- [ ] Manual spot-check of 5 random SKILL.md files passes
