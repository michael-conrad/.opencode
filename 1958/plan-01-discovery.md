# Phase 1 — Discovery and Inventory

**Goal:** Scan every file in `.opencode/` and classify every cross-reference by its current form. Output a structured inventory YAML.

**Concern:** Discovery
**SCs:** SC-1
**Dependencies:** Phase 0 complete
**Dispatch:** Clean-room sub-agent

## Items

### Item 1.1 — Scan and classify all cross-references

- [ ] Scan all `.opencode/guidelines/*.md` files for cross-reference patterns
- [ ] Scan all `.opencode/skills/*/SKILL.md` files for cross-reference patterns
- [ ] Scan all `.opencode/skills/*/tasks/*.md` files for cross-reference patterns
- [ ] Scan `.opencode/prompts/default.txt` for cross-reference patterns
- [ ] Scan `.opencode/scripts/*.py` for cross-reference patterns in docstrings
- [ ] Classify each reference by form: `See [text](path)`, `Read [text](path)`, `§N`, `§Name`, non-linked text, resolution table, already-correct `Load [text](path)`
- [ ] Record file path, line number, matched text, and classification for each reference
- [ ] Aggregate all findings into `.opencode/.issues/1958/data/cross-reference-inventory.yaml`
- [ ] Include summary counts per form category

## Exit Criteria

- [ ] All files in `.opencode/` scanned
- [ ] Inventory YAML produced at `.opencode/.issues/1958/data/cross-reference-inventory.yaml`
- [ ] Summary counts per form category available
