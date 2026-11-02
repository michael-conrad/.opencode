## Defect (cosmetic)

The two-SC scenario scripts' manifest rewrite block appends per-pass annotations by concatenating the previous manifest with new lines:

```bash
{ cat "$artifact_dir/manifest.yaml" 2>/dev/null || true
  echo "two_turn: true"
  echo "turn2_resumed_home: $test_home"
  [ -n "${SC8_SKIP_TURN2:-}" ] && echo "tail_materialization_pass: true ..."
} > "$artifact_dir/manifest.yaml.tmp" && mv ...
```

Across multi-pass recovery runs this accumulates duplicate keys — `two_turn` / `turn2_resumed_home` / `tail_materialization_pass` repeated once per pass (observed: 9 repetitions in the SC-8 artifact manifest after passes 1-9). YAML parsers take the last duplicate; consumers that read the first, or that validate strictly, get inconsistent behavior. Cosmetic today (all duplicates carry identical values except the free-text `tail_materialization_pass` annotation), but it is a data-hygiene defect in the evidence artifact the clean-room evaluator reads.

## Fix shape (when picked up)

Idempotent append: overwrite the scalar keys (single occurrence) and append only NEW pass annotations to a per-pass list key (e.g. `tail_materialization_passes: [...]`), or grep-guard the echoes.

> Evidence: `tmp/behavioral-evidence-2639-sc8-second-directive-rides-open-pr-GREEN-*/manifest.yaml` (duplicate-key repetitions visible in the tail).

