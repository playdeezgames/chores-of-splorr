# Quirks of the original, and what the port did with them

The original is the Defold/Lua game in `ChoresOfSPLORR/` (GlamJam 2025, January 2025). The rule for ports (the user's, November 5, 2026): **fix quirks as we go and log them here**, keep the voice and the deliberate design. Each entry says what the original did and what the port does.

## Fixed

1. **The last KEY could fail to appear.** When the 25th folded shirt went into the WARDROBE, the original tried to drop the KEY on one random cell and gave up silently if that cell was taken (a shirt, a feature, you). Then there was no key and no way out of the laundry room. The port keeps picking random cells until one is free, as it already did for the shirts and dishes.
2. **Messages overwrote each other.** Every message went straight into the one message box, so when one step raised two (picking up a SOILED SHIRT with WET and DRY SHIRTS in the basket says both "only soiled the WET SHIRTS" and "only soiled the DRY SHIRTS"), only the last was seen. The port queues them: closing one shows the next.
3. **The machines flickered.** The running WASHING MACHINE and DRYER advanced their animation every frame (60 times a second). The port runs the same four frames at 8 a second.
4. **A full inventory refused things without saying why.** Walking into an item with 16 things carried only played the fail sound. The port also shows the original's own "Yer inventory is full!".
5. **Counts above 9.** A DRYER can hold more than nine shirts (load it twice from the washer), and the original then drew a tile past the end of the digit row. The port shows the count for 2 to 9, as the original did, and nothing above that.

## Added

- **Saving.** The original kept only the mute setting. The port saves the house to the browser's local storage after every step and picks up where you left off. Restart (the arrow icon) still starts a new house at once, as in the original.
- **Phones and mice:** a tap or click on the room takes one step towards it (along the longer direction). A tap anywhere closes a message (the original took a click on the box). The mute and restart icons work as before.
- **Keys:** Enter and Escape close a message as well as Space, and M mutes. The movement keys are the original's: arrows, WASD, and Z and Q for AZERTY keyboards; holding one walks.
- The close hint reads "<SPACE> or tap to close." instead of "<SPACE> to close.".

## Removed

- The Defold debugger hook and the HTML5 fullscreen button. The Defold project stays in `ChoresOfSPLORR/` as the specification.

## Kept on purpose

- Every message's text, word for word (including "WASHING_MACHINE" with the underscore, and the DISH WASHER that looks like a WASHING MACHINE).
- The house: SWEEPING, DISHES, LAUNDRY and the last room, each 25 by 25 with the doors where they were. 25 piles of DIRT with the KEY hidden in one, 25 DIRTY DISHES, 25 SOILED SHIRTS, all scattered at random.
- Sweeping: with the BROOM you push DIRT ahead of you and drag the pile behind you when you step away. Piles merge up to 9; past 9 they become a DUST BUNNY, which hops to a random spot each time you move, leaving one DIRT behind, until its dirt is spent (and whatever it swallowed is in its last pile). Walking away from DIRT without the BROOM plays the "no sweep" sound.
- 10 points per DIRT in the DUST BIN, per DISH in the CUPBOARD and per SHIRT in the WARDROBE (510 for a clean house).
- Laundry: the LAUNDRY BASKET is needed for shirts; more than 9 shirts in the WASHING MACHINE blows it up and throws them about the room; SOAP after the shirts, one SOAP per customer; the machines run for 20 of your moves in their room (they stop when you leave). Mixing shirts in the basket spoils them: soiled soils everything, wet wets the dry and folded ones.
- The KEYs that "magically appear", the CUPBOARD and WARDROBE sharing a tile, the BROOM staying in your inventory forever, and the ending: a sign saying "Tomorrow, you can do them again!" and nothing else.
- The sound effects, pitched at random between 0.9 and 1.1 each time, and the art (the game's own 12 by 12 tile sheet, drawn at the original's 480 by 320, doubled).
