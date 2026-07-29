# Story Bible

This is the narrative and structural design reference for Allegory Cave. It supersedes the "wake up in a cold dark room, escape" framing in the original GDD (`README.md`) — see that file's Game World Fiction section for the updated short version.

## Premise

You wake up chained in a cave, facing a wall, watching shadows move across it. You break free, fight your way up through what turns out to be one cave among many, and surface into a Roman-ish seaside port town. You try to tell people what you saw down there. They don't believe you — you're the person raving about monsters in a hole in the ground.

That disbelief is the point, not a detour from it. Plato's allegory isn't really about escaping a cave — it's about what happens *after*: the freed prisoner comes back to tell the others, and they don't believe him, maybe mock or attack him for it. This game keeps that beat alive across the whole run instead of spending it once at the end.

## Structure: town hub + repeatable cave dives

The game is not one long dungeon. It's a persistent **town** connected to a growing set of **caves** you dive into one at a time.

- **Town** is the hub. Nothing here is permadeath. Gear you've bought, people you've rescued, and cave locations you've unlocked all persist for good.
- **Caves** are the runs. Buried-Bornes-flavored: brutal RNG, cursed rewards, real risk of failure. Dying or failing in a cave only costs that attempt — you're kicked back to town, not back to zero.

This means a new cave — including future DLC content — is just "author a roster, a boss, and a rescue payoff," not a new engine. The loop is designed to keep growing indefinitely.

## The fractal: every cave is its own small allegory

Rather than spending the "chains → climb → light" escalation once on the whole game, every individual cave dive repeats it at a smaller scale:

1. **Shallow — Shadows.** Enemies here are indistinct, puppet-like — projections rather than real things. (This is where the existing enemy roster — Slime, Spark Wisp, Acid Ooze, Blood Slime, Shade, Frost Blob, Blob Cube, Elder Cube — lives, reflavored as shadow-things rather than standalone monsters. They're already built from two reused/tinted sprites, which reads as "shadow puppet" for free.)
2. **Deeper — half-real things.** Tougher, stranger remixes of the same roster, or new threats specific to that cave's theme.
3. **Bottom.** Something's waiting here — usually a person to rescue, guarded by whatever "true form" the shallow shadows were standing in for.

That third beat is the payoff of each dive, and it's the thing that makes every cave feel like a complete story instead of a stretch of the same loop.

## The Waking Cave (the first dive — no rescue)

Your first cave is special: it ends at rock bottom with no one to save. The other prisoners chained down there are gone — withered, only remains left. You climb out alone.

This is deliberate. It sets the emotional floor for the whole game (you were too late, once) and it's *why* every cave after this one needs a fresh person to rescue rather than reusing the same NPCs — the stakes reset each time because the last group didn't make it.

## The Town

A Roman-ish seaside port. Classical dressing gives natural NPC/shop archetypes without much invention:

- A smith or merchant for gear.
- A temple, forum, or philosopher figure for lore, rumor, and pointed skepticism about your story.
- Dockside characters as gossip and quest sources.

**The disbelief beat plays out here first.** You tell people about the cave, the chains, the monsters. They think you're unwell. One NPC eventually offers the way back in: maybe you misremembered where the entrance was. You're handed a map. The Waking Cave stays on it — a permanent, repeatable/farmable early location — and a new cave node appears.

**Quests and new caves both come from talking to townspeople.** The map/cartographer role is a strong candidate to be the *first* rescued NPC (from the second cave) — the person who hands you future destinations is someone you personally saved, tying "who gives you work" directly to "who you saved."

## Rescued NPCs

Every cave past the first ends with someone to bring home. Rescuing them:

- Adds them to town permanently — the town visibly grows with every cleared cave, a cheap and legible progress signal.
- Gives them a shop, service, or **a magic ability tied to a card archetype they teach you** (see Combat below) — a favor-for-a-favor reward that doubles as your card-unlock gate.
- Optionally, hands you a fragment of a larger mystery: why these caves exist, who built them, why people end up chained in them. No single NPC needs to explain the whole thing — it's meant to accumulate slowly across many caves (including future DLC ones) rather than resolve all at once.

## Combat: fists first, cards as borrowed power

- **Basic Attack** and **Basic Defend** are always available, free, modest — this is just *you*, no deck required. A brand-new run can fight with nothing else.
- **Cards cost Focus**, a small resource (2–3, refilling each turn). They hit harder or apply elemental/special effects, but are gated by both Focus and hand/deck size — real tension between spending on a trash fight or hoarding for the cave's boss.
- **Cards evolve as you rescue people.** The plain playing-card-named cards already built (Ace of Diamonds, Three of Hearts, etc.) are your *starting, untaught* deck. Rescued NPCs teach you the elemental archetypes (Fire/Ice/Acid/Light/Lightning), which replace or upgrade those starting cards. Your deck's growth becomes a direct, visible readout of how many people you've saved — combat complexity scales with narrative progress instead of being front-loaded into one big deck on day one.

## Tone

Buried Bornes over Slay the Spire: rewards can be cursed, RNG can turn on you, the cave is actively hostile rather than neutral set-dressing. Keep a thread of dark comedy in it — the town's polite disbelief, the gap between what you've seen and what you can prove, the possibility that even proof doesn't fully convince anyone.

## Long-tail hooks (not committed to yet)

- No mandatory final ending. The structure is built to keep extending as long as new cave nodes get added.
- Keep "it's caves all the way down" — the surface being just the mouth of a bigger cave — in reserve as a rare deep-cave secret or a late payoff of the rescued-NPC mystery thread, rather than forcing it as a final act. Revisit once enough mystery fragments exist to land it.
