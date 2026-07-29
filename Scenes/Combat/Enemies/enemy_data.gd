extends Resource
class_name EnemyData

## EnemyData — a Resource describing one enemy variant.
## Each variant lives in Scenes/Combat/Enemies/*.tres so you can tune stats
## in the inspector without editing code.

## Human-readable name shown in combat.
@export var display_name: String = "Unknown"

## Short flavor blurb, shown once when the encounter starts.
@export_multiline var flavor: String = ""

## Sprite + presentation
@export var texture: Texture2D
@export var sprite_scale: Vector2 = Vector2(0.35, 0.42)   # matches existing scene scale
@export var modulate: Color = Color(1, 1, 1, 1)           # tint for visual variety

## Combat stats
@export var max_hp: int = 100
@export var atk_min: int = 8
@export var atk_max: int = 14

## Elemental resistances. Multipliers applied to incoming damage of that type.
##   > 1.0 = weak (takes more)
##   < 1.0 = resistant
##   = 0.0 = immune
## Types the player can deal: "Fire", "Ice", "Lightning", "Acid", "Light",
## and generic card types like "SevenDiamond", "ThreeHearts", etc.
@export var resistances: Dictionary = {}

## Special-move behavior — one of:
##   ""             — no special, just plain attacks
##   "double_hit"   — every 3rd turn, attacks twice
##   "regen"        — heals 8 hp at the end of every enemy turn if not dead
##   "armor_up"     — every 3rd turn, halves incoming damage for next round
##   "life_drain"   — 25% chance per turn to also heal for half the damage dealt
##   "crit"         — 20% chance to double its attack roll
##   "corrode"      — applies a debuff that adds +5 damage to next enemy hit
@export var special_pattern: String = ""
