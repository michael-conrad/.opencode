#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "~=3.12"
# dependencies = ["pyyaml>=6.0"]
# ///
"""
DESCRIPTION: Schema v2.0 validation for yaml+symbolic blocks. Supports tasks, decomposition, gates, evidence_artifacts, and sub_agent_dispatch sections.
Usage: python .opencode/tools/impl/skildeck/schema_v2.py [ Options ]
"""

from __future__ import annotations

import os
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
REQUIRED_SUB_AGENT_DISPATCH_FIELDS = {"type", "isolation", "bypass_violation"}


def find_skills_dir(tool_path: Path) -> Path:
    """
    Find skills directory by walking up tree from tool location.
    
    Works for: standalone dirs, submodules, copied folders, any deployment.
    No git required. No hardcoded paths.
    """
    # 1. Discovery: walk up until finding skills/
    for parent in [tool_path.parent] + list(tool_path.parents):
        candidate = parent / "skills"
        if candidate.exists() and candidate.is_dir():
            return candidate
    
    # 2. Environment override (explicit user control for edge cases)
    if os.environ.get("SKILDECK_SKILLS_DIR"):
        env_path = Path(os.environ["SKILDECK_SKILLS_DIR"])
        if env_path.exists():
            return env_path
    
    raise RuntimeError(
        f"Cannot find skills/ directory. Searched up from {tool_path}. "
        f"Set SKILDECK_SKILLS_DIR env var to override."
    )


def scan_skills(skills_dir: Path) -> list:
    """
    Scan skills directory and extract yaml+symbolic rules from SKILL.md files.
    
    Returns fresh data on every call. No cache. No registry. No regeneration.
    """
    import yaml
    
    all_rules = []
    
    for skill_subdir in sorted(skills_dir.iterdir()):
        if not skill_subdir.is_dir():
            continue
        
        skill_file = skill_subdir / "SKILL.md"
        if not skill_file.exists():
            continue
        
        content = skill_file.read_text()
        rules = extract_rules_from_markdown(content, skill_subdir.name)
        all_rules.extend(rules)
    
    return all_rules


def extract_rules_from_markdown(content: str, skill_name: str) -> list:
    """Extract yaml+symbolic blocks from markdown content."""
    import yaml
    
    rules = []
    matches = FENCE_PATTERN.findall(content)
    for match in matches:
        try:
            data = yaml.safe_load(match)
            if data and "rules" in data:
                for rule in data["rules"]:
                    rule["_skill_name"] = skill_name
                    rules.append(rule)
        except Exception:
            pass
    return rules


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
class SubAgentDispatchEntry:
    type: str
    isolation: str = "clean-room"
    must_receive: list[str] = field(default_factory=list)
    must_not_receive: list[str] = field(default_factory=list)
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
class ValidationError:
    path: str
    message: str
    severity: str = "error"

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class SchemaValidationResult:
    schema_version: str = ""
    valid: bool = False
    errors: list[ValidationError] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    rules_count: int = 0
    state_machines_count: int = 0
    tasks_count: int = 0
    decomposition_count: int = 0
    sub_agent_dispatch_count: int = 0
    gates_count: int = 0
    evidence_artifacts_count: int = 0

    def to_dict(self) -> dict:
        return asdict(self)


def _validate_rule(
    raw: dict, errors: list[ValidationError], source: str
) -> dict | None:
    missing = REQUIRED_RULE_FIELDS - set(raw.keys())
    if missing:
        errors.append(
            ValidationError(
                path=f"{source}/rules/{raw.get('id', '?')}",
                message=f"missing required fields: {missing}",
            )
        )
        return None
    return raw


def _validate_state_machine(
    raw: dict, errors: list[ValidationError], source: str
) -> dict | None:
    missing = REQUIRED_SM_FIELDS - set(raw.keys())
    if missing:
        errors.append(
            ValidationError(
                path=f"{source}/state_machines/{raw.get('id', '?')}",
                message=f"missing required fields: {missing}",
            )
        )
        return None
    return raw


def _validate_task(
    raw: dict, errors: list[ValidationError], source: str
) -> Task | None:
    missing = REQUIRED_TASK_FIELDS - set(raw.keys())
    if missing:
        errors.append(
            ValidationError(
                path=f"{source}/tasks/{raw.get('id', '?')}",
                message=f"missing required fields: {missing}",
            )
        )
        return None
    return Task(
        id=str(raw["id"]),
        skill=str(raw["skill"]),
        preconditions=[str(c) for c in raw.get("preconditions", [])],
        postconditions=[str(c) for c in raw.get("postconditions", [])],
        mandatory=bool(raw.get("mandatory", True)),
        bypass_violation=str(raw.get("bypass_violation", "")),
        source=source,
    )


def _validate_decomposition(
    entry: dict, errors: list[ValidationError], source: str
) -> DecompositionEntry | None:
    missing = REQUIRED_DECOMP_FIELDS - set(entry.keys())
    if missing:
        errors.append(
            ValidationError(
                path=f"{source}/decomposition",
                message=f"decomposition entry missing required fields: {missing}",
                severity="error",
            )
        )
        return None
    return DecompositionEntry(
        type=entry.get("type", ""),
        skill=entry.get("skill", ""),
        task=entry.get("task", ""),
        mandatory=entry.get("mandatory", True),
        bypass_violation=entry.get("bypass_violation", ""),
        source=source,
    )


def _validate_sub_agent_dispatch(
    entry: dict, errors: list[ValidationError], source: str
) -> SubAgentDispatchEntry | None:
    missing = REQUIRED_SUB_AGENT_DISPATCH_FIELDS - set(entry.keys())
    if missing:
        errors.append(
            ValidationError(
                path=f"{source}/sub_agent_dispatch",
                message=f"sub_agent_dispatch entry missing required fields: {missing}",
                severity="error",
            )
        )
        return None
    return SubAgentDispatchEntry(
        type=entry.get("type", ""),
        isolation=entry.get("isolation", "clean-room"),
        must_receive=entry.get("must_receive", []),
        must_not_receive=entry.get("must_not_receive", []),
        mandatory=entry.get("mandatory", True),
        bypass_violation=entry.get("bypass_violation", ""),
        source=source,
    )


def _validate_gate(
    raw: dict, errors: list[ValidationError], source: str
) -> Gate | None:
    missing = REQUIRED_GATE_FIELDS - set(raw.keys())
    if missing:
        errors.append(
            ValidationError(
                path=f"{source}/gates/{raw.get('id', '?')}",
                message=f"missing required fields: {missing}",
            )
        )
        return None
    return Gate(
        id=str(raw["id"]),
        condition=str(raw["condition"]),
        on_fail=str(raw.get("on_fail", "")),
        critical_violation=bool(raw.get("critical_violation", False)),
        source=source,
    )


def _validate_evidence_artifact(
    raw: dict, errors: list[ValidationError], source: str
) -> EvidenceArtifact | None:
    missing = REQUIRED_EVIDENCE_FIELDS - set(raw.keys())
    if missing:
        errors.append(
            ValidationError(
                path=f"{source}/evidence_artifacts/{raw.get('name', '?')}",
                message=f"missing required fields: {missing}",
            )
        )
        return None
    return EvidenceArtifact(
        name=str(raw["name"]),
        type=str(raw["type"]),
        verification=str(raw["verification"]),
        source=source,
    )


def validate_schema(data: dict, source: str = "") -> SchemaValidationResult:
    """Validate a parsed yaml+symbolic block against schema v1.0 or v2.0."""

    result = SchemaValidationResult()

    sv = data.get("schema_version", "")
    result.schema_version = str(sv)

    if sv not in (SCHEMA_V1, SCHEMA_V2):
        result.errors.append(
            ValidationError(
                path=f"{source}/schema_version",
                message=f"unsupported schema_version: {sv!r} (expected '1.0' or '2.0')",
            )
        )
        return result

    if sv == SCHEMA_V1:
        result.valid = True
        for rule_raw in data.get("rules", []):
            if isinstance(rule_raw, dict):
                _validate_rule(rule_raw, result.errors, source)
                result.rules_count += 1
        for sm_raw in data.get("state_machines", []):
            if isinstance(sm_raw, dict):
                _validate_state_machine(sm_raw, result.errors, source)
                result.state_machines_count += 1
        return result

    tasks: list[Task] = []
    decomposition: list[DecompositionEntry] = []
    sub_agent_dispatch: list[SubAgentDispatchEntry] = []
    gates: list[Gate] = []
    evidence_artifacts: list[EvidenceArtifact] = []

    for rule_raw in data.get("rules", []):
        if isinstance(rule_raw, dict):
            _validate_rule(rule_raw, result.errors, source)
            result.rules_count += 1

    for sm_raw in data.get("state_machines", []):
        if isinstance(sm_raw, dict):
            _validate_state_machine(sm_raw, result.errors, source)
            result.state_machines_count += 1

    for task_raw in data.get("tasks", []):
        if isinstance(task_raw, dict):
            t = _validate_task(task_raw, result.errors, source)
            if t:
                tasks.append(t)
            result.tasks_count += 1

    for decomp_raw in data.get("decomposition", []):
        if isinstance(decomp_raw, dict):
            d = _validate_decomposition(decomp_raw, result.errors, source)
            if d:
                decomposition.append(d)
            result.decomposition_count += 1

    for sad_raw in data.get("sub_agent_dispatch", []):
        if isinstance(sad_raw, dict):
            sad = _validate_sub_agent_dispatch(sad_raw, result.errors, source)
            if sad:
                sub_agent_dispatch.append(sad)
            result.sub_agent_dispatch_count += 1

    for gate_raw in data.get("gates", []):
        if isinstance(gate_raw, dict):
            g = _validate_gate(gate_raw, result.errors, source)
            if g:
                gates.append(g)
            result.gates_count += 1

    for ea_raw in data.get("evidence_artifacts", []):
        if isinstance(ea_raw, dict):
            ea = _validate_evidence_artifact(ea_raw, result.errors, source)
            if ea:
                evidence_artifacts.append(ea)
            result.evidence_artifacts_count += 1

    result.valid = len(result.errors) == 0
    return result
