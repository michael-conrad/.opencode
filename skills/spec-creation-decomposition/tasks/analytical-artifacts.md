# Task: analytical-artifacts

## Purpose

Generate 7 analytical artifacts from a completed spec body. Each artifact is a YAML file stored at `.issues/{N}/artifacts/{name}.yaml`.

## Entry Criteria

- Completed spec body at `.issues/{N}/spec.md`
- Spec body includes all required sections (SC table, preamble, compliance blocks)
- All Step 1 sub-artifacts exist (sc-summary.yaml, verification-consistency-contract.yaml, lifecycle.yaml, spec-to-plan-handoff.yaml, revision-re-entry-contract.yaml)

## Input Artifacts

This sub-agent reads from `.issues/{N}/spec.md` and prior artifacts in `.issues/{N}/artifacts/`.

## Procedure

Generate all 7 artifacts sequentially — each artifact may inform the next. Write each to `.issues/{N}/artifacts/{name}.yaml`.

- [ ] 1. Generate `blast-radius.yaml` — Analyze the spec body and identify affected components and ripple effects per phase. Schema:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    blast_radius:
      phases:
        - phase: <phase_name>
          affected_components:
            - component: <component_name>
              impact: <direct|indirect>
              description: <how this component is affected>
              ripple_effects:
                - <downstream component or behavior affected>
          risk_level: <low|medium|high>
    ```

    **Evidence type:** `semantic` — sub-agent reads spec body and produces analytical judgment.

- [ ] 2. Generate `concern-map.yaml` — Analyze the spec body and identify concern boundaries and separation per phase. Schema:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    concern_map:
      phases:
        - phase: <phase_name>
          primary_concern: <single concern statement>
          boundaries:
            - <what is in scope for this concern>
            - <what is out of scope for this concern>
          separation_rationale: <why this concern is isolated from others>
    ```

    **Evidence type:** `semantic` — sub-agent reads spec body and produces analytical judgment.

- [ ] 3. Generate `code-path-inventory.yaml` — Analyze the spec body and identify code paths touched by each phase. Schema:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    code_path_inventory:
      phases:
        - phase: <phase_name>
          files:
            - path: <file_path>
              reason: <why this file is affected>
              changes: <summary of expected changes>
          new_files:
            - path: <file_path>
              purpose: <what the new file does>
    ```

    **Evidence type:** `semantic` — sub-agent reads spec body and spec-to-plan-handoff.yaml for file references.

- [ ] 4. Generate `cross-cutting-matrix.yaml` — Analyze the spec body and identify cross-cutting concerns matrix. Schema:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    cross_cutting_matrix:
      concerns:
        - concern: <concern_name>
          affects_phases: [<phase_names>]
          description: <how this concern cuts across phases>
          coordination_required: <true|false>
    ```

    **Evidence type:** `semantic` — sub-agent reads spec body and concern-map.yaml for phase boundaries.

- [ ] 5. Generate `interface-compatibility.yaml` — Analyze the spec body and identify interface compatibility analysis. Schema:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    interface_compatibility:
      interfaces:
        - name: <interface_name>
          status: <unchanged|modified|new|removed>
          compatibility: <backward_compatible|breaking_change|internal_only>
          consumers:
            - <consumer_component>
    ```

    **Evidence type:** `semantic` — sub-agent reads spec body and concern-map.yaml for interface boundaries.

- [ ] 6. Generate `state-analysis.yaml` — Analyze the spec body and identify state transitions and invariants. Schema:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    state_analysis:
      phases:
        - phase: <phase_name>
          states:
            - name: <state_name>
              entry_conditions: <what must be true to enter this state>
              exit_conditions: <what must be true to leave this state>
              invariants: <what must always be true in this state>
    ```

    **Evidence type:** `semantic` — sub-agent reads spec body and interface-compatibility.yaml for interface state.

- [ ] 7. Generate `testability-assessment.yaml` — Analyze the spec body and assess testability of each SC. Schema:

    ```yaml
    spec: {browser_url}/{owner}/{repo}/issues/{N}
    generated_at: <YYYY-MM-DDTHH:MM:SSZ>
    testability_assessment:
      scs:
        - id: <SC_ID>
          testable: <true|false|partial>
          test_type: <behavioral|semantic|string|structural>
          verification_command: <executable command or NONE>
          blockers:
            - <reason if not testable>
    ```

    **Evidence type:** `semantic` — sub-agent reads spec body and code-path-inventory.yaml for code paths.

## Result Contract

| Field | Value |
|-------|-------|
| `status` | `DONE` \| `BLOCKED` |
| `finding_summary` | `"Generated 7 analytical artifacts for spec #N"` |
| `artifact_path` | `.issues/{N}/artifacts/` |
| `blocker_reason` | `<why if BLOCKED>` |
