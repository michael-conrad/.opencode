# Phase 6 Dispatch Evidence — Template Generator Guard (#2339, SC-6)

## Commit
- `64dcb55d` checkpoint(#2339): item-6 — template generator emits guard

## Files Changed
- `skills/skill-creator/scripts/init_skill.py` — added Pre-Flight Guard section to SKILL_TEMPLATE
- `tests-v2/test-2339-sc6-template-generator-guard.sh` — SC-6 content-verification test

## RED → GREEN
- RED: generated card lacked guard marker; test failed 5/6 assertions.
- GREEN: all 6 assertions PASS (`bash tests-v2/test-2339-sc6-template-generator-guard.sh` → exit 0).

## Pre-Existing Bug Fixed (Required for SC-6)
The template used `SKILL_TEMPLATE.format()` but contained single-brace placeholders
that are not format keys, causing `KeyError` on every generation:
- Line 54: `{field1, field2}` → escaped to `{{field1, field2}}`
- Line 67: `skill({name: "{skill_name}"})` → escaped to `skill({{name: "{skill_name}"}})`
- New guard line uses `{{name: "..."}}` escaping.

The generator was previously unrunnable; SC-6's evidence method ("generate a card
from the template") required this fix.

## Verification
- Ran generator on a throwaway skill; guard section renders correctly before routing metadata.
- Braces resolve correctly (single braces in output, no double-brace leak).
- Guard marker `ORCHESTRATOR_ONLY_SKILL_CARD` present in generated SKILL.md.
