# Phase 2 — Replace All Non-Conforming References (Per-Item TDD)

**Goal:** Convert every non-conforming cross-reference to the canonical `Load [descriptive text](relative/path.md)` form. Each item follows the TDD cycle: RED (behavioral test fails) → GREEN (edit files) → REFACTOR → COMMIT.

**Concern:** Replacement
**SCs:** SC-2 through SC-7
**Dependencies:** Phase 1 complete
**Dispatch:** `implementation-pipeline` — each item is a separate pipeline stage

**Evidence type note:** SC-2 through SC-7 are auto-uplifted from `string` to `behavioral` per [critical-rules-BEH-EV]. Changing cross-reference patterns IS a runtime-behavioral change — it affects how agents interpret and act on cross-references. Each item requires a behavioral enforcement test (RED) before the edit (GREEN).

## Items

### Item 2.1 — Update 000-critical-rules.md

**SCs:** SC-2
**Files:** `.opencode/guidelines/000-critical-rules.md`

**RED:**
- [ ] Write behavioral enforcement test: send agent a prompt with `Read [Text](path)`, verify agent does NOT follow the old pattern (test fails because agent still sees old text)
- [ ] Confirm test FAILS

**GREEN:**
- [ ] Replace `Read [Text](path)` with `Load [Text](path)` in the cross-reference rule
- [ ] Replace any `See [Text](path)` with `Load [Text](path)`
- [ ] Replace any bare `§N` or `§Name` with inline `Load [descriptive text](path)` links

**REFACTOR:**
- [ ] Run behavioral test — confirm PASS
- [ ] Run grep verification: `grep 'Load \[Text\]' .opencode/guidelines/000-critical-rules.md` — at least 1 match

**COMMIT:**
- [ ] Commit: `git add .opencode/guidelines/000-critical-rules.md .opencode/tests-v2/behaviors/ && git commit -m "item-2.1: update 000-critical-rules.md to Load[Text](path)"`

---

### Item 2.2 — Update all SKILL.md files (verb replacement)

**SCs:** SC-3
**Files:** All `.opencode/skills/*/SKILL.md`

**RED:**
- [ ] Write behavioral enforcement test: send agent a prompt referencing a SKILL.md with `See [file]`, verify agent does NOT follow the old pattern
- [ ] Confirm test FAILS

**GREEN:**
- [ ] For each SKILL.md with `See [text](path)` or `Read [text](path)`:
  - [ ] Replace `See [text](path)` → `Load [text](path)`
  - [ ] Replace `Read [text](path)` → `Load [text](path)`

**REFACTOR:**
- [ ] Run behavioral test — confirm PASS
- [ ] Run grep verification: `grep -r 'See \[' .opencode/skills/*/SKILL.md` — zero matches
- [ ] Run grep verification: `grep -r 'Read \[' .opencode/skills/*/SKILL.md` — zero matches

**COMMIT:**
- [ ] Commit: `git add .opencode/skills/ .opencode/tests-v2/behaviors/ && git commit -m "item-2.2: replace See/Read with Load in all SKILL.md"`

---

### Item 2.3 — Update all guideline files (verb replacement)

**SCs:** SC-4
**Files:** All `.opencode/guidelines/*.md`

**RED:**
- [ ] Write behavioral enforcement test: send agent a prompt referencing a guideline with `See [file]`, verify agent does NOT follow the old pattern
- [ ] Confirm test FAILS

**GREEN:**
- [ ] For each guideline with `See [text](path)` or `Read [text](path)`:
  - [ ] Replace `See [text](path)` → `Load [text](path)`
  - [ ] Replace `Read [text](path)` → `Load [text](path)`

**REFACTOR:**
- [ ] Run behavioral test — confirm PASS
- [ ] Run grep verification: `grep -r 'See \[' .opencode/guidelines/*.md` — zero matches
- [ ] Run grep verification: `grep -r 'Read \[' .opencode/guidelines/*.md` — zero matches

**COMMIT:**
- [ ] Commit: `git add .opencode/guidelines/ .opencode/tests-v2/behaviors/ && git commit -m "item-2.3: replace See/Read with Load in all guidelines"`

---

### Item 2.4 — Remove bare §N and §Name references from SKILL.md

**SCs:** SC-5
**Files:** All `.opencode/skills/*/SKILL.md`

**RED:**
- [ ] Write behavioral enforcement test: send agent a prompt with a `§N` reference, verify agent does NOT follow the old pattern
- [ ] Confirm test FAILS

**GREEN:**
- [ ] For each SKILL.md with bare `§N` or `§Name`:
  - [ ] Replace with inline `Load [descriptive text](path)` link
  - [ ] Path determined from context or resolution table content

**REFACTOR:**
- [ ] Run behavioral test — confirm PASS
- [ ] Run grep verification: `grep -r '§' .opencode/skills/*/SKILL.md` — zero matches

**COMMIT:**
- [ ] Commit: `git add .opencode/skills/ .opencode/tests-v2/behaviors/ && git commit -m "item-2.4: remove bare section references from SKILL.md"`

---

### Item 2.5 — Remove resolution table patterns from SKILL.md

**SCs:** SC-6
**Files:** All `.opencode/skills/*/SKILL.md`

**RED:**
- [ ] Write behavioral enforcement test: send agent a prompt with a resolution table + admonition, verify agent does NOT follow the old pattern
- [ ] Confirm test FAILS

**GREEN:**
- [ ] For each SKILL.md with resolution table + admonition:
  - [ ] Remove the resolution table
  - [ ] Remove the admonition
  - [ ] Ensure all references from the table are now inline `Load [text](path)` links in the body

**REFACTOR:**
- [ ] Run behavioral test — confirm PASS
- [ ] Run grep verification: `grep -r '| Reference | File |' .opencode/skills/*/SKILL.md` — zero matches

**COMMIT:**
- [ ] Commit: `git add .opencode/skills/ .opencode/tests-v2/behaviors/ && git commit -m "item-2.5: remove resolution table patterns from SKILL.md"`

---

### Item 2.6 — Remove non-linked text references from SKILL.md

**SCs:** SC-7
**Files:** All `.opencode/skills/*/SKILL.md`

**RED:**
- [ ] Write behavioral enforcement test: send agent a prompt with a non-linked `See file.md` reference, verify agent does NOT follow the old pattern
- [ ] Confirm test FAILS

**GREEN:**
- [ ] For each SKILL.md with non-linked text references (`See file.md`, `See SKILLNAME skill`):
  - [ ] Replace with inline `Load [descriptive text](path)` link
  - [ ] Path determined from context

**REFACTOR:**
- [ ] Run behavioral test — confirm PASS
- [ ] Run grep verification: `grep -rn 'See [A-Z]' .opencode/skills/*/SKILL.md` — zero matches

**COMMIT:**
- [ ] Commit: `git add .opencode/skills/ .opencode/tests-v2/behaviors/ && git commit -m "item-2.6: remove non-linked text references from SKILL.md"`

---

### Item 2.7 — Update task files

**SCs:** (covered by SC-3/SC-5/SC-7 for task files)
**Files:** All `.opencode/skills/*/tasks/*.md`

**GREEN:**
- [ ] For each task file with non-conforming references:
  - [ ] Replace `See [text](path)` → `Load [text](path)`
  - [ ] Replace `Read [text](path)` → `Load [text](path)`
  - [ ] Replace bare `§N` → inline `Load [descriptive text](path)`
  - [ ] Replace bare `§Name` → inline `Load [descriptive text](path)`
  - [ ] Replace non-linked text references → inline `Load [text](path)`

**REFACTOR:**
- [ ] Run grep verification: `grep -r 'See \[' .opencode/skills/*/tasks/*.md` — zero matches
- [ ] Run grep verification: `grep -r 'Read \[' .opencode/skills/*/tasks/*.md` — zero matches

**COMMIT:**
- [ ] Commit: `git add .opencode/skills/ && git commit -m "item-2.7: update task files to Load[text](path)"`

---

### Item 2.8 — Update default.txt and scripts

**Files:** `.opencode/prompts/default.txt`, `.opencode/scripts/*.py`

**GREEN:**
- [ ] Update `.opencode/prompts/default.txt` to use `Load [text](path)` in any cross-reference directives
- [ ] Update `.opencode/scripts/*.py` if any cross-references found in docstrings

**REFACTOR:**
- [ ] Run grep verification: no `See [` or `Read [` in updated files

**COMMIT:**
- [ ] Commit: `git add .opencode/prompts/ .opencode/scripts/ && git commit -m "item-2.8: update default.txt and scripts to Load[text](path)"`

---

### Item 2.9 — Final verification sweep

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
- [ ] Run all behavioral enforcement tests — confirm all PASS

## Exit Criteria

- [ ] All items through complete TDD cycle (RED → GREEN → REFACTOR → COMMIT)
- [ ] All behavioral enforcement tests PASS
- [ ] All grep-based SC verifications PASS
- [ ] Manual spot-check of 5 random SKILL.md files passes
