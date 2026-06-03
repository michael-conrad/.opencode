# [SPEC] viewport-editor: Stash/Pop/Swap Test

## Intent

Clean-room validation of viewport-editor clipboard and stash behavior. This spec defines a structured test sequence for the stash/pop/swap mechanism — all operations use the `viewport_editor_clipboard` MCP tool exclusively. No git workflow, no branch creation. The test operates on copies in `./tmp/` to avoid touching production fixture files. The goal is to verify that stash slots correctly store and retrieve clipboard content across multiple viewports in the same session.

## Setup

Copy the three fixture files into `./tmp/stash-test/`:

```bash
mkdir -p ./tmp/stash-test
cp fixtures/dorian-gray.txt fixtures/config.yaml fixtures/example.py ./tmp/stash-test/
```

All subsequent viewports open these copies, not the originals.

## Success Criteria

- [ ] **SC-1:** Copy fixture files to `./tmp/stash-test/`. Open all three copies in viewports with the same `session_id`.
- [ ] **SC-2:** Copy line 1 from dorian-gray.txt to clipboard, stash as `'title'`.
- [ ] **SC-3:** Copy lines 5-6 from config.yaml to clipboard, stash as `'server_config'`.
- [ ] **SC-4:** Copy line 1 from example.py to clipboard, stash as `'module_doc'`.
- [ ] **SC-5:** Pop `'title'` to clipboard, verify via `clipboard:show`, paste into example.py copy at line 10.
- [ ] **SC-6:** Pop `'server_config'` to clipboard, verify via `clipboard:show`, paste into dorian-gray.txt copy at line 50.
- [ ] **SC-7:** Pop `'module_doc'` to clipboard, verify via `clipboard:show`, paste into config.yaml copy at line 1 (pushing existing lines down).
- [ ] **SC-8:** Swap clipboard with `'title'` stash slot, verify via `clipboard:show`, paste swapped content into example.py copy at line 20.
- [ ] **SC-9:** Save all three files. Verify pasted content on disk with `grep`.
- [ ] **SC-10:** List all stashes with `stash-list`. Close all viewports.