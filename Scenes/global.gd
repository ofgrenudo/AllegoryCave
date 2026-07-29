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

# Elemental "taught" cards — per the story, these are unlocked by rescuing an
# NPC in a later cave. The first cave (Waking Cave) has no one left to teach
# you one, so none of these should start active or be earnable yet.
const ELEMENTAL_CARD_NAMES := [
	"LightningOne", "LightningTwo",
	"FireOne",
	"IceOne", "IceTwo",
	"AcidOne", "AcidTwo",
	"LightOne", "LightTwo",
]

# Card face art for the Deck Manager inventory screen, keyed the same as
# card_owned/card_states.
const CARD_TEXTURES := {
	"LightningOne": "res://Media/Cards/magic/Untitled_Artwork-1.png",
	"LightningTwo": "res://Media/Cards/magic/Untitled_Artwork-2.png",
	"FireOne":      "res://Media/Cards/magic/Untitled_Artwork-3.png",
	"IceOne":       "res://Media/Cards/magic/Untitled_Artwork-4.png",
	"AcidOne":      "res://Media/Cards/magic/Untitled_Artwork-5.png",
	"AcidTwo":      "res://Media/Cards/magic/Untitled_Artwork-6.png",
	"LightOne":     "res://Media/Cards/magic/Untitled_Artwork-7.png",
	"LightTwo":     "res://Media/Cards/magic/Untitled_Artwork-8.png",
	"IceTwo":       "res://Media/Cards/magic/Untitled_Artwork-9.png",
	"SevenDiamond": "res://Media/Cards/normal/Untitled_Artwork-1.png",
	"ThreeHearts":  "res://Media/Cards/normal/Untitled_Artwork-3.png",
	"EightClubs":   "res://Media/Cards/normal/Untitled_Artwork-4.png",
	"FiveDiamond":  "res://Media/Cards/normal/Untitled_Artwork-5.png",
	"AceDiamond":   "res://Media/Cards/normal/Untitled_Artwork-6.png",
}

# Cards the player currently owns/has unlocked. The Deck Manager only ever
# shows cards from this inventory — a card not owned yet (e.g. an elemental
# one not yet taught by an NPC) simply doesn't appear until earned. All the
# plain playing-card-named cards are yours from the start (per the Story
# Bible: "mundane, untaught" cards you already have); elemental cards are
# unowned until an NPC teaches you one.
var card_owned := {
	"LightningOne":  false,
	"LightningTwo":  false,
	"FireOne":       false,
	"IceOne":        false,
	"AcidOne":       false,
	"AcidTwo":       false,
	"LightOne":      false,
	"LightTwo":      false,
	"IceTwo":        false,
	"SevenDiamond":  true,
	"ThreeHearts":   true,
	"EightClubs":    true,
	"FiveDiamond":   true,
	"AceDiamond":    true,
}

# Which OWNED cards the player has selected to bring into their deck.
var card_states := {
	"LightningOne":  false,
	"LightningTwo":  false,
	"FireOne":       false,
	"IceOne":        false,
	"AcidOne":       false,
	"AcidTwo":       false,
	"LightOne":      false,
	"LightTwo":      false,
	"IceTwo":        false,
	"SevenDiamond":  true,
	"ThreeHearts":   true,
	"EightClubs":    true,
	"FiveDiamond":   true,
	"AceDiamond":    true,
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
