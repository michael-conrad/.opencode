# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-9 structural co-location and config-placement checks)

"""SC-9 structural checks: co-location contract and hardening-default placement.

Tier: smoke (fast fact checks; runs in the default suite).

- the registered `ragsync` command routes through the wrapper and still names
  `--config .opencode/ragsync-config.yaml` (R-8's co-location contract);
- every hardening default lives in the wrapper-owned co-located hardening
  config, never in `ragsync-config.yaml` — upstream ragsync validates its own
  YAML with pydantic `extra="forbid"` (an added key crashes the server), so
  the parse check asserts the schema's top-level keys only;
- the service doc documents the assembled hardened path.
"""

from __future__ import annotations

import json
from pathlib import Path

import yaml

from tests.test_ragsync_launch.ragsync_fixture import (
    DECK_ROOT,
    registered_ragsync_command,
)

HARDENING_PATH = DECK_ROOT / "ragsync-hardening.yaml"
RAGSYNC_CONFIG_PATH = DECK_ROOT / "ragsync-config.yaml"
DOC_PATH = DECK_ROOT / "docs" / "ragsync-service.md"

HARDENING_KEYS = (
    "reap_deadline_seconds",
    "memory_ceiling_bytes",
    "thread_cap",
    "admission_min_free_bytes",
    "idle_timeout_seconds",
    "idle_poll_seconds",
    "heavy_window_seconds",
    "lock_wait_seconds",
    "lock_name",
    "runtime_dir",
)


def test_registered_command_routes_through_wrapper_and_names_colocated_config() -> None:
    command = registered_ragsync_command()
    assert any(arg.endswith("ragsync-launch.py") for arg in command), (
        f"registered command does not route through the hardening wrapper: {command}"
    )
    for i, arg in enumerate(command):
        if arg == "--config":
            assert command[i + 1] == ".opencode/ragsync-config.yaml", (
                f"registered --config argument left the co-located config: {command[i + 1]}"
            )
            break
    else:
        raise AssertionError(f"registered command names no --config argument: {command}")


def test_hardening_defaults_live_in_wrapper_owned_config() -> None:
    setting = yaml.safe_load(HARDENING_PATH.read_text(encoding="utf-8"))
    missing = [key for key in HARDENING_KEYS if key not in setting]
    assert not missing, f"hardening config lacks recorded defaults: {missing}"


def test_ragsync_config_carries_no_hardening_keys() -> None:
    data = yaml.safe_load(RAGSYNC_CONFIG_PATH.read_text(encoding="utf-8"))
    allowed = {"defaults", "sources"}
    unknown = set(data) - allowed
    assert not unknown, (
        f"ragsync-config.yaml carries non-schema keys {unknown} — upstream AppConfig "
        f"validates extra='forbid' and would crash the server at startup"
    )
    assert data.get("sources"), "ragsync-config.yaml must keep at least one corpus source"


def test_service_doc_documents_the_hardened_path() -> None:
    doc = DOC_PATH.read_text(encoding="utf-8")
    for needle in (
        "ragsync-launch.py",
        "ragsync-hardening.yaml",
        "admission_min_free_bytes",
        "heavyweight slot",
    ):
        assert needle in doc, f"service doc does not document {needle!r}"
