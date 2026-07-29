extends Node

# =============================================================================
# Deck configuration
# =============================================================================
const MIN_DECK_SIZE := 3
const MAX_DECK_SIZE := 6

# Base deck — always dealt in on top of whichever elemental cards the player
# has selected above. 52 cards total, none of them elemental.
const STARTING_DECK_ATTACK_COUNT := 10
const STARTING_DECK_DEFEND_COUNT := 8
const STARTING_DECK_NORMAL_COUNT := 34

# Which cards the player has selected for their deck.
var card_states := {
	"LightningOne":  true,
	"LightningTwo":  false,
	"FireOne":       true,
	"IceOne":        false,
	"AcidOne":       true,
	"AcidTwo":       false,
	"LightOne":      false,
	"LightTwo":      true,
	"IceTwo":        false,
	"SevenDiamond":  true,
	"ThreeHearts":   true,
	"EightClubs":    false,
	"FiveDiamond":   false,
	"AceDiamond":    false,
}

# =============================================================================
# Persistent player state (survives scene changes)
# =============================================================================
const PLAYER_MAX_HEALTH := 100
var player_health: int = PLAYER_MAX_HEALTH

# =============================================================================
# Progression — escape the dungeon after visiting N rooms.
# =============================================================================
const ROOMS_TO_ESCAPE := 15
var rooms_visited: int = 0


func reset_run() -> void:
	## Call at the start of a new run (from Opening Sceen or Main Menu -> Start).
	player_health = PLAYER_MAX_HEALTH
	rooms_visited = 0


func count_selected_cards() -> int:
	var n := 0
	for k in card_states:
		if card_states[k]:
			n += 1
	return n
