# gdmcp Command Workflows

## Diagnose editor state

```bash
.tools/gdmcp/bin/gdmcp --json doctor
.tools/gdmcp/bin/gdmcp --json editor state
.tools/gdmcp/bin/gdmcp --json scenes current
.tools/gdmcp/bin/gdmcp --json debug logs --level Error --limit 50
```

## Resolve names to paths

```bash
.tools/gdmcp/bin/gdmcp --json nodes resolve Player
.tools/gdmcp/bin/gdmcp --json scenes resolve Main
.tools/gdmcp/bin/gdmcp --json scripts resolve player
.tools/gdmcp/bin/gdmcp --json resources resolve icon
```

## Inspect a scene

```bash
.tools/gdmcp/bin/gdmcp --json scenes tree --depth 4
.tools/gdmcp/bin/gdmcp --json nodes get /root/Main/Player --fields position,visible
```

## Inspect a script

```bash
.tools/gdmcp/bin/gdmcp --json scripts list --limit 50
.tools/gdmcp/bin/gdmcp --json scripts read res://scripts/player.gd --lines 1:200
```

## Create a script

```bash
.tools/gdmcp/bin/gdmcp --json scripts create res://scripts/enemy.gd --script-type GDScript
```

## Inspect a resource

```bash
.tools/gdmcp/bin/gdmcp --json resources get res://player.tres
.tools/gdmcp/bin/gdmcp --json resources get res://player.tres --fields resource_path,resource_name
```

## Modify a node property

```bash
.tools/gdmcp/bin/gdmcp --json nodes properties set /root/Main/Player --property speed --value 300
```

## Move or rename a node

```bash
.tools/gdmcp/bin/gdmcp --json nodes move /root/Main/Enemy --new-parent /root/World
.tools/gdmcp/bin/gdmcp --json nodes rename /root/Main/Enemy --new-name Boss
```

## Replace a script explicitly

```bash
.tools/gdmcp/bin/gdmcp --json scripts replace res://scripts/player.gd \
  --content-file ./player.gd \
  --apply
```

## Inspect a running game

```bash
.tools/gdmcp/bin/gdmcp --json runtime info
.tools/gdmcp/bin/gdmcp --json runtime tree --depth 4
.tools/gdmcp/bin/gdmcp --json runtime nodes get /root/Main/Player
```

## Inspect logs progressively

```bash
.tools/gdmcp/bin/gdmcp --json debug logs --limit 50
.tools/gdmcp/bin/gdmcp --json debug logs --limit 50 --cursor 50
.tools/gdmcp/bin/gdmcp --json debug logs --limit 100 --out ./logs.json
```

## Discover an advanced runtime tool

```bash
.tools/gdmcp/bin/gdmcp --json tools search "runtime shader parameter" --limit 5
.tools/gdmcp/bin/gdmcp --json tools schema set_runtime_shader_parameter
.tools/gdmcp/bin/gdmcp --json tool-call set_runtime_shader_parameter \
  --args-file ./shader-request.json \
  --allow-open-world
```

## Preview and apply a batch

```bash
.tools/gdmcp/bin/gdmcp --json batch preview ./operations.json
.tools/gdmcp/bin/gdmcp --json batch apply ./operations.json --apply
```

Batch operations use registered tool names with JSON object arguments. They are
validated before the first request, then executed sequentially and are not
atomic; a later failure does not roll back earlier operations.
