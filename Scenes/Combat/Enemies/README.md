# Enemies

Each `.tres` file in this folder defines one enemy variant. Drop a new one in and it will automatically show up in the random-encounter pool — no code changes required.

## Roster

| File | Name | HP | ATK | Notes |
|---|---|---:|---|---|
| `slime.tres` | Slime | 55 | 5–9 | Weak fire res, resists acid. The starter. |
| `spark_wisp.tres` | Spark Wisp | 45 | 9–16 | Fragile glass cannon. 20% crit chance. Immune to Lightning. |
| `acid_ooze.tres` | Acid Ooze | 75 | 7–12 | Immune to Acid. Corrodes armor: next hit does +5 damage. |
| `blood_slime.tres` | Blood Slime | 95 | 8–13 | 25% chance to heal for half damage dealt. Weak to acid. |
| `shade.tres` | Shade | 85 | 10–15 | 2.5× damage from Light. Also has life drain. |
| `frost_blob.tres` | Frost Blob | 110 | 6–10 | Immune to Ice, 2× fire damage. Regenerates 8 hp/turn. |
| `blob_cube.tres` | Blob Cube | 130 | 10–16 | Every 3rd turn, halves next incoming damage. |
| `elder_cube.tres` | Elder Cube | 180 | 11–17 | Every 3rd turn attacks twice. Late-game threat. |

## Difficulty gating

`Enemy._pick_variant()` filters the pool by `max_hp <= 55 + (Global.rooms_visited * 10)`. So early rooms only see Slimes/Wisps; later rooms unlock Elder Cubes.

## Adding a new enemy

1. Copy any existing `.tres` file and rename it.
2. In Godot, open it in the inspector and set:
   - `display_name`, `flavor` (shown in combat log)
   - `texture`, `sprite_scale`, `modulate` (visual)
   - `max_hp`, `atk_min`, `atk_max`
   - `resistances` — dict of `"ElementName": multiplier`
   - `special_pattern` — one of the keys handled in `Enemy.gd::roll_attack()`
3. Save. Done. It's in the pool.

## Special patterns

| Pattern | Behavior |
|---|---|
| `""` | Plain attacks. |
| `double_hit` | Every 3rd turn, attacks twice in a row. |
| `regen` | Heals 8 hp at the end of every turn (capped at max). |
| `armor_up` | Every 3rd turn braces — sacrifices half its attack, halves next incoming damage. |
| `life_drain` | 25% chance per attack to also heal for half the damage dealt. |
| `crit` | 20% chance to double the attack roll. |
| `corrode` | Adds a +5 damage buff to its **next** attack. |
