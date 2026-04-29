# Task: create-fragment

## Purpose

Create new fragment master from existing content in skills. This task extracts duplicated content that appears across multiple skill files into a single master fragment that can be synchronized to all destinations.

## Why Fragments Exist

When the same content block appears in multiple skill files (for example, the same critical rule appearing in several SKILL.md files), maintaining consistency across all copies is error-prone. Fragments solve this by:
- Creating a single master copy in `.opencode/.guidelines/`
- Tracking all destinations where the content appears
- Enabling one-command synchronization via `sync-fragment`
- Detecting drift via `check-drift`

## Entry Criteria

- Duplicate content identified in skills (at least 2 destinations)
- Fragment ID is unique in the registry (no collisions)
- Content location in skill file identified (exact line range)

## Procedure

### Step 1: Extract Content from Source

1. **Identify duplicate content** in one or more skill files:
   ```bash
   # Find content in skill files
   grep -n "## Critical Rule" .opencode/skills/some-skill/SKILL.md
   ```

2. **Read the exact content** from the source file using the `read` tool

3. **Determine line range:**
   - Start: Section header or marker line
   - End: End of content block (before next section header)

4. **Verify duplication:** Confirm the same (or near-identical) content appears in at least one other destination. Fragments for single-destination content are unnecessary.

### Step 2: Create Fragment Master File

1. Create file in `.opencode/.guidelines/`:
   ```bash
   touch .opencode/.guidelines/fragment-id.md
   ```

2. Write content with fragment metadata comment at the end:
   ```markdown
   # Fragment: Fragment Name

   [Content block extracted from skill]

   <!--
   Fragment ID: fragment-id
   Estimated words: NNN
   Type: text-block
   Sync status: synchronized
   -->
   ```

3. Content should be self-contained — no project-specific context, no references to other skill-specific files. If content requires context, add a brief introduction.

### Step 3: Calculate Hash

```bash
sha256sum .opencode/.guidelines/fragment-id.md
```

Record the hash in the registry. This hash is the authoritative fingerprint for the content — any change to the master file will produce a different hash.

### Step 4: Update Registry

Add entry to `.opencode/.guidelines/registry.yaml`:

```yaml
fragments:
  - id: fragment-id
    master:
      path: .opencode/.guidelines/fragment-id.md
      hash: sha256:abc123...
      last_modified: YYYY-MM-DDTHH:MM:SSZ
      lines: NN
    content:
      type: text-block
      estimated_words: NNN
      description: Fragment description
    destinations:
      - path: .opencode/skills/some-skill/SKILL.md
        hash: sha256:abc123...
        line_range:
          start: N
          end: N
        verified_date: YYYY-MM-DDTHH:MM:SSZ
    sync_status: synchronized
    last_sync: YYYY-MM-DDTHH:MM:SSZ
    notes: Fragment notes
```

Each destination has its own `line_range` specifying where the content was extracted from.

### Step 5: Verify Entry

1. Read registry: `cat .opencode/.guidelines/registry.yaml`
2. Verify fragment appears in fragments list
3. Verify hash matches actual file: `sha256sum .opencode/.guidelines/fragment-id.md`
4. Verify all destinations are listed with correct line ranges

### Step 6: Initial Sync

After creating the fragment, optionally run `sync-fragment` to replace destination content with the master copy. This ensures all destinations start with identical content.

## Exit Criteria

- Fragment master file created in `.opencode/.guidelines/`
- Registry updated with entry including hash, destinations, and metadata
- Hash calculated and recorded
- Line ranges documented for all destinations
- Content is self-contained (no project-specific references)

## Edge Cases

### Multiple Destinations

If fragment appears in multiple skills:

1. Add ALL destinations to registry entry (not just one)
2. Each destination has its own `line_range`
3. Verify each destination has the same content (or near-identical)
4. Minor differences are acceptable — the master becomes the canonical version

### Fragment Already Exists

If fragment ID already in registry:

1. STOP - do not create duplicate
2. Ask user: "Fragment with ID '{id}' already exists. Choose a different ID or update the existing fragment."
3. If updating, use `update-fragment` task instead
4. Never overwrite an existing fragment without explicit confirmation

### Source Content Not Self-Contained

If extracted content references skill-specific context:

1. Add a brief introduction that provides necessary context
2. Mark any project-specific parts clearly
3. Consider whether the content is truly "core" — if it requires project context to be useful, it may not be a good fragment candidate