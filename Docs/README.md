# Docs

This directory is intended to contain all of my thoughts and reasonings when building the game. The rest of this document will be dedicated to the Game Design Document.

## Allegory Cave

This game is a dungeon-diving card game with a persistent town hub between runs. This game was created for the [Card Deck Jam](https://itch.io/jam/card-deck-jam). The Card Deck Jam is a 5 day jam, with the theme of Building. Building can be in terms of Building a Deck, or Building a Building.

- Concept Statement : Dungeon Crawling Card Game about diving into caves, rescuing who you find, and trying to convince a town that any of it really happened.
- Genere : RPG
- Target Audience : Mature

See `Story Bible.md` for full narrative design and `Game Loop.md` for the current structural loop.

### Product Design

- Player Experience & POV : First Person, Turn Based Dungeon Crawler, with a third-person Town hub between dives.
- Visual and Audio Style : Vector Art ; Audio Style is Undecided.
- Game World Fiction : You wake up chained in a cave, watching shadows on a wall. You break free, fight your way to the surface, and find a seaside town — where nobody believes what you're describing. They hand you a map anyway, insisting you must have misremembered the entrance. You go back in, again and again, each cave holding someone new to save.
- Monetization : Free to Play.
- Platform Support, Technology : Desktop, Web Browser

### Detailed Game System Design

- Core Loops : Town hub (persistent, no permadeath) for shopping/quests/map selection, feeding into cave dives (permadeath-flavored runs) navigated with directional prompts (Left, Right, Forward). Each movement can trigger an event (combat or reward). See `Game Loop.md` for the full loop.
- Objectives and Progression : Survive each dive, rescue whoever's at the bottom (except the first cave, which has no one left to save), and grow the town. New cave locations unlock through town quests/dialogue rather than all being available at once.
- Game Systems : Random encounters and random enemy generation per cave (hand-authored roster/boss, procedurally shuffled room order). The player navigates via UI, fights using a mix of always-free basic actions (Attack/Defend) and Focus-costed cards, and manages town-side shopping/quests/map selection between dives.
- Interactivity : Interactivitiy will be handeled by mouse click, or keyboard / controller input for accessibility.