---

## 2026-05-02T23:24:02Z

**michael-conrad**:

## WIP: 2026-05-02

### Current state
- Profile "ProtanomalySafe" created in dconf (`:558ae99e-cab3-40f3-8b28-706a4a21d0cf`)
- All 16 ANSI colors + fg/bg/cursor applied
- Idempotency fixed (now correctly finds existing profile by visible-name)

### Problem
gnome-terminal does **not** pick up dconf-created profiles on the fly. Profile appears in `dconf dump` but gnome-terminal's Preferences UI ignores it until a full application restart. Killing `gnome-terminal-server` nukes all windows (bad approach).

### Script (current working version)

```python
"""Create/update a dedicated 'ProtanomalySafe' gnome-terminal profile — ZERO deep reds."""
import subprocess
import uuid

PREFIX = "/org/gnome/terminal/legacy/profiles:/"
PROFILE_NAME = "ProtanomalySafe"

palette = [
    "rgb(30,30,35)",    # 0
    "rgb(230,150,0)",   # 1    amber
    "rgb(80,220,80)",   # 2    bright lime
    "rgb(220,210,50)",  # 3
    "rgb(70,140,240)",  # 4
    "rgb(180,120,240)", # 5    violet
    "rgb(50,200,210)",  # 6
    "rgb(220,220,220)", # 7
    "rgb(160,160,170)", # 8
    "rgb(255,180,40)",  # 9    bright orange
    "rgb(130,255,130)", # 10
    "rgb(255,240,90)",  # 11
    "rgb(110,170,255)", # 12
    "rgb(220,160,255)", # 13
    "rgb(90,230,240)",  # 14
    "rgb(250,250,250)", # 15
]

def dconf_read(key):
    out = subprocess.run(["dconf", "read", f"{PREFIX}{key}"], capture_output=True, text=True)
    return out.stdout.strip()

def dconf_write(key, value):
    subprocess.run(["dconf", "write", f"{PREFIX}{key}", value], check=True)

def dconf_list():
    out = subprocess.run(["dconf", "list", PREFIX], capture_output=True, text=True)
    return out.stdout.strip().splitlines()

def find_existing_profile():
    for entry in dconf_list():
        if not entry.endswith("/"):
            continue
        profile_id = entry.rstrip("/")
        name = dconf_read(f"{profile_id}/visible-name")
        if name and name.strip("'") == PROFILE_NAME:
            return profile_id
    return None

def get_profile_list():
    raw = dconf_read("list")
    if not raw:
        return []
    return eval(raw)

existing = find_existing_profile()
if existing:
    profile_id = existing
    print(f"Found existing {PROFILE_NAME} profile ({profile_id})")
else:
    profile_id = ":" + str(uuid.uuid4())
    current_list = get_profile_list()
    current_list.append(profile_id)
    list_str = str(current_list)
    dconf_write("list", list_str)
    print(f"Created new profile {PROFILE_NAME} ({profile_id})")

base = f"{profile_id}/"

dconf_write(base + "visible-name", f"'{PROFILE_NAME}'")
dconf_write(base + "palette", str(palette))
dconf_write(base + "foreground-color", "'rgb(220,220,220)'")
dconf_write(base + "background-color", "'rgb(30,30,35)'")
dconf_write(base + "cursor-colors-set", "true")
dconf_write(base + "cursor-foreground-color", "'rgb(30,30,35)'")
dconf_write(base + "cursor-background-color", "'rgb(255,180,40)'")
dconf_write(base + "use-theme-colors", "false")
dconf_write(base + "bold-color-same-as-fg", "false")
dconf_write(base + "bold-color", "'rgb(250,250,250)'")
dconf_write(base + "use-system-font", "false")
dconf_write(base + "font", "'Monospace 10'")

print(f"ProtanomalySafe profile ready. Set as default in gnome-terminal Preferences or run:")
print(f"  dconf write {PREFIX}default '{profile_id}'")
```

### To resume
- Script at `tmp/protanomaly_terminal.py`
- Issue #32 needs approval before implementation
- Key open question: will gnome-terminal pick up the profile after a clean restart, or is there a registration mechanism we're missing?

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
