"""
DESCRIPTION: Shared extraction library for yaml+symbolic v2.0 (tasks, decomposition, gates, evidence_artifacts).
Backward compatible with v1.0. Loaded by skildeck-extract, skildeck-gates, and other skildeck tools.
"""

import re
from dataclasses import dataclass, field, asdict
from pathlib import Path

SCHEMA_V1 = "1.0"
SCHEMA_V2 = "2.0"
FENCE_PATTERN = re.compile(r"```yaml\+symbolic\n(.*?)```", re.DOTALL)

REQUIRED_RULE_FIELDS = {"id", "title", "actions"}
REQUIRED_SM_FIELDS = {"id", "states", "start_state", "transitions"}
REQUIRED_TASK_FIELDS = {"id", "skill", "preconditions", "postconditions"}
REQUIRED_DECOMP_FIELDS = {"type", "skill", "task"}
REQUIRED_GATE_FIELDS = {"id", "condition"}
REQUIRED_EVIDENCE_FIELDS = {"name", "type", "verification"}


@dataclass
class Rule:
    id: str
    title: str
    conditions_all: list[str] = field(default_factory=list)
    conditions_any: list[str] = field(default_factory=list)
    actions: list[str] = field(default_factory=list)
    conflicts_with: list[str] = field(default_factory=list)
    requires: list[str] = field(default_factory=list)
    triggers: list[str] = field(default_factory=list)
    source: str = ""
    raw_conditions: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class Transition:
    from_state: str
    to_state: str
    guard: str = ""
    action: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class StateMachine:
    id: str
    states: list[str] = field(default_factory=list)
    start_state: str = ""
    transitions: list[Transition] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "states": self.states,
            "start_state": self.start_state,
            "transitions": [t.to_dict() for t in self.transitions],
        }


@dataclass
class Task:
    id: str
    skill: str
    preconditions: list[str] = field(default_factory=list)
    postconditions: list[str] = field(default_factory=list)
    mandatory: bool = True
    bypass_violation: str = ""
    source: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class DecompositionEntry:
    type: str
    skill: str
    task: str
    mandatory: bool = True
    bypass_violation: str = ""
    source: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class Gate:
    id: str
    condition: str
    on_fail: str = ""
    critical_violation: bool = False
    source: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class EvidenceArtifact:
    name: str
    type: str
    verification: str
    source: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class ExtractResult:
    rules: list[Rule] = field(default_factory=list)
    state_machines: list[StateMachine] = field(default_factory=list)
    tasks: list[Task] = field(default_factory=list)
    decomposition: list[DecompositionEntry] = field(default_factory=list)
    gates: list[Gate] = field(default_factory=list)
    evidence_artifacts: list[EvidenceArtifact] = field(default_factory=list)
    files_scanned: int = 0
    blocks_found: int = 0
    warnings: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            "rules": [r.to_dict() for r in self.rules],
            "state_machines": [sm.to_dict() for sm in self.state_machines],
            "tasks": [t.to_dict() for t in self.tasks],
            "decomposition": [d.to_dict() for d in self.decomposition],
            "gates": [g.to_dict() for g in self.gates],
            "evidence_artifacts": [ea.to_dict() for ea in self.evidence_artifacts],
            "files_scanned": self.files_scanned,
            "blocks_found": self.blocks_found,
            "warnings": self.warnings,
        }


def _parse_rule(raw: dict, warnings: list[str], source_file: str) -> Rule | None:
    missing = REQUIRED_RULE_FIELDS - set(raw.keys())
    if missing:
        warnings.append(
            f"{source_file}: rule missing required fields {missing}: {raw.get('id', '?')}"
        )
        return None
    conds = raw.get("conditions", {})
    if isinstance(conds, dict):
        conditions_all = (
            conds.get("all", []) if isinstance(conds.get("all", []), list) else []
        )
        conditions_any = (
            conds.get("any", []) if isinstance(conds.get("any", []), list) else []
        )
    else:
        conditions_all = []
        conditions_any = []
    return Rule(
        id=str(raw["id"]),
        title=str(raw["title"]),
        conditions_all=[str(c) for c in conditions_all],
        conditions_any=[str(c) for c in conditions_any],
        actions=[str(a) for a in raw.get("actions", [])],
        conflicts_with=[str(c) for c in raw.get("conflicts_with", [])],
        requires=[str(r) for r in raw.get("requires", [])],
        triggers=[str(t) for t in raw.get("triggers", [])],
        source=str(raw.get("source", "")),
    )


def _parse_state_machine(
    raw: dict, warnings: list[str], source_file: str
) -> StateMachine | None:
    missing = REQUIRED_SM_FIELDS - set(raw.keys())
    if missing:
        warnings.append(
            f"{source_file}: state_machine missing required fields {missing}: {raw.get('id', '?')}"
        )
        return None
    transitions = []
    for t in raw.get("transitions", []):
        if isinstance(t, dict) and "from" in t and "to" in t:
            transitions.append(
                Transition(
                    from_state=str(t["from"]),
                    to_state=str(t["to"]),
                    guard=str(t.get("guard", "")),
                    action=str(t.get("action", "")),
                )
            )
        else:
            warnings.append(
                f"{source_file}: malformed transition in SM {raw['id']}: {t}"
            )
    return StateMachine(
        id=str(raw["id"]),
        states=[str(s) for s in raw.get("states", [])],
        start_state=str(raw.get("start_state", "")),
        transitions=transitions,
    )


def _parse_task(raw: dict, warnings: list[str], source_file: str) -> Task | None:
    missing = REQUIRED_TASK_FIELDS - set(raw.keys())
    if missing:
        warnings.append(
            f"{source_file}: task missing required fields {missing}: {raw.get('id', '?')}"
        )
        return None
    return Task(
        id=str(raw["id"]),
        skill=str(raw["skill"]),
        preconditions=[str(c) for c in raw.get("preconditions", [])],
        postconditions=[str(c) for c in raw.get("postconditions", [])],
        mandatory=bool(raw.get("mandatory", True)),
        bypass_violation=str(raw.get("bypass_violation", "")),
        source=source_file,
    )


def _parse_decomposition(
    raw: dict, warnings: list[str], source_file: str
) -> DecompositionEntry | None:
    missing = REQUIRED_DECOMP_FIELDS - set(raw.keys())
    if missing:
        warnings.append(
            f"{source_file}: decomposition missing required fields {missing}"
        )
        return None
    return DecompositionEntry(
        type=str(raw["type"]),
        skill=str(raw["skill"]),
        task=str(raw["task"]),
        mandatory=bool(raw.get("mandatory", True)),
        bypass_violation=str(raw.get("bypass_violation", "")),
        source=source_file,
    )


def _parse_gate(raw: dict, warnings: list[str], source_file: str) -> Gate | None:
    missing = REQUIRED_GATE_FIELDS - set(raw.keys())
    if missing:
        warnings.append(
            f"{source_file}: gate missing required fields {missing}: {raw.get('id', '?')}"
        )
        return None
    return Gate(
        id=str(raw["id"]),
        condition=str(raw["condition"]),
        on_fail=str(raw.get("on_fail", "")),
        critical_violation=bool(raw.get("critical_violation", False)),
        source=source_file,
    )


def _parse_evidence_artifact(
    raw: dict, warnings: list[str], source_file: str
) -> EvidenceArtifact | None:
    missing = REQUIRED_EVIDENCE_FIELDS - set(raw.keys())
    if missing:
        warnings.append(
            f"{source_file}: evidence_artifact missing required fields {missing}: {raw.get('name', '?')}"
        )
        return None
    return EvidenceArtifact(
        name=str(raw["name"]),
        type=str(raw["type"]),
        verification=str(raw["verification"]),
        source=source_file,
    )


def extract_yaml_blocks(scan_dir: Path, verbose: bool = False) -> ExtractResult:
    import yaml

    result = ExtractResult()
    md_files = sorted(scan_dir.rglob("*.md"))
    result.files_scanned = len(md_files)

    for md_file in md_files:
        rel = md_file.relative_to(scan_dir)
        try:
            text = md_file.read_text()
        except Exception as e:
            result.warnings.append(f"{rel}: cannot read: {e}")
            continue

        for match in FENCE_PATTERN.finditer(text):
            result.blocks_found += 1
            yaml_text = match.group(1)
            try:
                data = yaml.safe_load(yaml_text)
            except yaml.YAMLError as e:
                result.warnings.append(f"{rel}: YAML parse error: {e}")
                continue
            if not isinstance(data, dict):
                result.warnings.append(
                    f"{rel}: expected dict, got {type(data).__name__}"
                )
                continue

            sv = data.get("schema_version", "")
            if sv not in (SCHEMA_V1, SCHEMA_V2):
                result.warnings.append(
                    f"{rel}: schema_version {sv!r} != '1.0' or '2.0', skipping"
                )
                continue

            source_label = str(rel)

            for rule_raw in data.get("rules", []):
                if isinstance(rule_raw, dict):
                    rule = _parse_rule(rule_raw, result.warnings, source_label)
                    if rule:
                        result.rules.append(rule)

            for sm_raw in data.get("state_machines", []):
                if isinstance(sm_raw, dict):
                    sm = _parse_state_machine(sm_raw, result.warnings, source_label)
                    if sm:
                        result.state_machines.append(sm)

            if sv == SCHEMA_V2:
                for task_raw in data.get("tasks", []):
                    if isinstance(task_raw, dict):
                        task = _parse_task(task_raw, result.warnings, source_label)
                        if task:
                            result.tasks.append(task)

                for decomp_raw in data.get("decomposition", []):
                    if isinstance(decomp_raw, dict):
                        decomp = _parse_decomposition(
                            decomp_raw, result.warnings, source_label
                        )
                        if decomp:
                            result.decomposition.append(decomp)

                for gate_raw in data.get("gates", []):
                    if isinstance(gate_raw, dict):
                        gate = _parse_gate(gate_raw, result.warnings, source_label)
                        if gate:
                            result.gates.append(gate)

                for ea_raw in data.get("evidence_artifacts", []):
                    if isinstance(ea_raw, dict):
                        ea = _parse_evidence_artifact(
                            ea_raw, result.warnings, source_label
                        )
                        if ea:
                            result.evidence_artifacts.append(ea)

            last_updated = data.get("last_updated", "")
            if verbose and last_updated:
                print(f"  last_updated: {last_updated}", file=__import__("sys").stderr)

    return result
