# Phase 1 — Discovery and Inventory

**Goal:** Scan every file in `.opencode/` and classify every cross-reference by its current form. Output a structured inventory YAML.

**Concern:** Discovery
**SCs:** SC-1
**Dependencies:** None

## Steps

### 1.1 Scan guideline files

- [ ] Scan all `.opencode/guidelines/*.md` files for cross-reference patterns
- [ ] Classify each reference by form: `See [text](path)`, `Read [text](path)`, `§N`, `§Name`, non-linked text, resolution table, already-correct `Load [text](path)`
- [ ] Record file path, line number, matched text, and classification for each reference

### 1.2 Scan SKILL.md files

- [ ] Scan all `.opencode/skills/*/SKILL.md` files for cross-reference patterns
- [ ] Same classification as 1.1
- [ ] Record file path, line number, matched text, and classification

### 1.3 Scan task files

- [ ] Scan all `.opencode/skills/*/tasks/*.md` files for cross-reference patterns
- [ ] Same classification as 1.1
- [ ] Record file path, line number, matched text, and classification

### 1.4 Scan default.txt and scripts

- [ ] Scan `.opencode/prompts/default.txt` for cross-reference patterns
- [ ] Scan `.opencode/scripts/*.py` for cross-reference patterns in docstrings
- [ ] Same classification as 1.1

### 1.5 Produce inventory YAML

- [ ] Aggregate all findings into `.opencode/.issues/1958/data/cross-reference-inventory.yaml`
- [ ] Structure: per-file entries with per-reference details
- [ ] Include summary counts per form category

## Exit Criteria

- [ ] All files in `.opencode/` scanned
- [ ] Inventory YAML produced at `.opencode/.issues/1958/data/cross-reference-inventory.yaml`
- [ ] Summary counts per form category available
