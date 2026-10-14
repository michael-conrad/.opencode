number: 2599
title: "Retire the skildeck validate action (stale dispatch-table validator)"
---

# Plan — .opencode#2599

Source: `.opencode/.issues/2599/spec.md` (validated spec, consumed as-is —
every SC is fact-decidable with a runnable instrument; no defective criteria
found). All paths submodule-relative (`.opencode/` root).

## Item 1 — SC-1: remove every `validate` occurrence from the dispatcher

- **Deliverable:** `tools/skildeck` — delete the `"validate": "skildeck-validate"` ACTIONS entry, the `validate` token in the docstring Actions line, the validating claim in the docstring description sentence ("Lint and validate skill and guideline files." → "Lint skill and guideline files."), and the `skildeck validate` usage example.
- **RED:** `grep -n "validate" tools/skildeck` — currently matches the ACTIONS entry, the Actions line, the description sentence, and the example (4 sites); the assertion "no occurrence of the validate action in the dispatcher" fails for that reason.
- **GREEN:** the edits above; no other byte changes.
- **Instrument:** `grep -nE '\bvalidate\b' tools/skildeck` returns 0 matches (note: `verify-acceptance`/`verify-issue` do not contain the word `validate`).

## Item 2 — SC-2: delete `skildeck-validate`

- **Deliverable:** `tools/impl/skildeck/skildeck-validate` removed via `git rm`.
- **RED:** file-existence check on the path currently returns exists.
- **GREEN:** deletion; content remains recoverable in git history.
- **Instrument:** `test ! -e tools/impl/skildeck/skildeck-validate`.

## Item 3 — SC-3: no live consumer remains

- **Deliverable:** none (verification item; remediate any match found outside `.issues/` by editing its source file in this cycle).
- **RED:** working-tree search `rg -n 'skildeck-validate|skildeck validate'` over the submodule excluding `.issues/` — currently matches the dispatcher and the script (removed by items 1–2).
- **GREEN:** items 1–2 leave zero matches outside `.issues/`.
- **Instrument:** `rg -n 'skildeck-validate|skildeck validate' --glob '!.issues/**' --glob '!.git/**'` → 0 matches.

## Item 4 — SC-4: retired action fails closed

- **Deliverable:** none (behavioral verification of items 1–2).
- **RED:** before items 1–2, `./.opencode/tools/skildeck validate` exits 0 and runs the validator — the failing assertion is that it exits non-zero with the unknown-action error.
- **GREEN:** post-change run exits non-zero; stderr names available actions.
- **Instrument:** `./.opencode/tools/skildeck validate; echo $?` → non-zero exit, error names `lint, verify-acceptance, verify-issue`.

## Item 5 — SC-5: lint still clean

- **Deliverable:** none (behavioral verification of preserved state).
- **Instrument:** `./.opencode/tools/skildeck lint` → 0 findings, exit 0.

## Item 6 — SC-6: ACTIONS declares exactly the surviving actions

- **Deliverable:** none (structural verification of item 1).
- **Instrument:** read the ACTIONS mapping — exactly `lint`, `verify-acceptance`, `verify-issue`; `test -x` on each of the three scripts under `tools/impl/skildeck/`.

## Order & dependencies

Items 1→2 (both remove the action's surfaces), then 3–6 are verifications over the post-1/2 state; 4's RED is observed pre-change (the live validate run at baseline), its GREEN after. One commit per item is collapsed here: items 1–2 are one atomic change (SC-1 and SC-2 describe a single removal from two surfaces); the commit carries both. Verification items 3–6 run post-commit and require no further commits unless remediation is needed.

## Suite-green note

The submodule's test suite / structural checks (lint, behavior fixtures) run post-implementation per the workflow reference; per the spec's Not-Included, `tests-v2/test-skill-deck-completeness.sh` exercises `skildeck lint` only and must stay green.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
