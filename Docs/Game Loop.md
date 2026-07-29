# Game Loop

See `Story Bible.md` for the narrative reasoning behind this structure.

## Top-level loop

1. Main Menu
2. **Town** (persistent hub — nothing here is lost on death)
	- Shop for gear (smith/merchant NPC)
	- Talk to townspeople for quests and rumor
	- Consult the map for available cave locations (quick travel)
	- First visit ever: skip straight to the Waking Cave (see below) instead of the shop/map being populated
3. Pick a cave from the map → **Dive**
4. Return to Town with loot / a rescued NPC (or nothing, if the run failed)
5. Repeat from step 2 — new cave nodes unlock as NPCs are rescued and quests are completed

Death or failure inside a cave only ends that dive — you're returned to Town, not reset to the beginning of the game. Anything already banked in Town (gear, rescues, unlocked map nodes) persists.

## Inside a single cave dive

Every cave (including future DLC ones) follows the same fractal shape, per-cave theme/roster/boss is hand-authored, but the room order is procedurally shuffled each dive (reuses the existing Forward/Left/Right navigation picker):

1. Opening beat ([cave_name]_descriptor) — short scene/mission description for this specific cave
2. Navigation begins (Forward, Left, or Right)
3. Shallow rooms — Combat (shadow-tier enemies) or Event (Booby Trap / Treasure Chest)
4. Loop back to 3 randomly, escalating toward deeper/half-real encounters, until the cave's bottom is reached
5. Bottom encounter — boss fight, then either:
	- **The Waking Cave (first dive only):** no one to save — the other prisoners are withered remains. Climb out alone, surface in the Town for the first time.
	- **Every later cave:** an NPC to rescue. Bring them back to Town.
6. Return to Town (step 4 of the top-level loop above)
