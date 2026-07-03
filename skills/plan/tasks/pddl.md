# Task: pddl

## Purpose

Convert between the internal YAML problem representation and standard PDDL (Planning Domain Definition Language). Enables interop with external planning tools and PDDL-based workflows.

## Entry Criteria

- YAML problem file (to-pddl) or directory with `domain.pddl`/`problem.pddl` (from-pddl)

## Procedure

### Step 1: YAML to PDDL

```bash
./.opencode/tools/plan pddl --direction to-pddl --input <problem.yaml>
```

To write output to a directory (creates `domain.pddl` and `problem.pddl`):

```bash
./.opencode/tools/plan pddl --direction to-pddl --input <problem.yaml> --output <dir>
```

### Step 2: PDDL to YAML

```bash
./.opencode/tools/plan pddl --direction from-pddl --input <dir-with-domain-and-problem-pddl>
```

### Limitations

PDDL round-trips (YAML → PDDL → YAML) may lose structural information. Complex PDDL constructs including quantified expressions, conditional effects, and type hierarchies may not survive a round-trip. Verify the converted output before using it downstream.

## Exit Criteria

- Conversion succeeds with exit code 0
- For to-pddl: domain.pddl and problem.pddl are valid PDDL syntax
- For from-pddl: output YAML validates against the problem schema