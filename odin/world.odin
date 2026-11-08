package chores

// The rules of Chores of SPLORR!!, ported from the Defold/Lua original (ChoresOfSPLORR/world, in git history at e85bf85).
// Pure: no platform imports. Coordinates are 1-based with row 1 at the BOTTOM, as in the
// original's tilemaps, so the room layouts and directions read the same as the Lua.
// Everything in World is plain data (no pointers or slices), so a save is its bytes.

COLS :: 25
ROWS :: 25
CENTER_X :: (1 + COLS) / 2 // 13
CENTER_Y :: (1 + ROWS) / 2 // 13
INVENTORY_SIZE :: 16
ROOM_COUNT :: 4
MAX_MESSAGES :: 8
MAX_SFX :: 32

DIRT_PILE_MAXIMUM_INTENSITY :: 9
DIRT_PILE_SCORE_MULTIPLIER :: 10
WASHING_MACHINE_MAXIMUM_INTENSITY :: 9
MACHINE_TIMER :: 20
TOTAL_DIRT :: 25
TOTAL_DISHES :: 25
TOTAL_CLOTHES :: 25

Room :: enum u8 {
	Sweeping,
	Dishes,
	Laundry,
	Last,
}

Terrain :: enum u8 {
	Floor,
	Wall,
	Open_Door,
	Closed_Door,
}

Item :: enum u8 {
	None,
	Key,
	Broom,
	Dirty_Dish,
	Clean_Dish,
	Laundry_Basket,
	Soiled_Shirt,
	Washed_Shirt,
	Dry_Shirt,
	Folded_Shirt,
	Soap,
}

Feature_Kind :: enum u8 {
	None,
	Dirt_Pile,
	Dust_Bin,
	Sign,
	Dish_Washer,
	Cupboard,
	Wardrobe,
	Washing_Machine,
	Soap_Dispenser,
	Folding_Table,
	Dryer,
}

Machine_State :: enum u8 {
	Loading,
	Washing,
	Clean,
	Drying,
	Dry,
}

Sign_Text :: enum u8 {
	None,
	Sweeping,
	Dishes,
	Last,
}

// A feature lives in exactly one cell, so it is stored in the cell and moved by copying.
// intensity: dirt in a pile, or shirts in a machine. remaining: dishes or clothes still to put away.
Feature :: struct {
	kind:      Feature_Kind,
	state:     Machine_State,
	item:      Item, // the KEY hidden in a dirt pile
	sign:      Sign_Text,
	intensity: i16,
	timer:     i16,
	remaining: i16,
}

Character :: enum u8 {
	None,
	Hero,
	Dust_Bunny,
}

Teleport :: struct {
	active:   bool,
	room:     Room,
	col, row: u8,
}

Cell :: struct {
	terrain:         Terrain,
	locked:          bool, // the one lock type: a KEY opens it, and both are used up
	item:            Item,
	character:       Character,
	bunny_item:      Item,
	bunny_intensity: i16,
	feature:         Feature,
	teleport:        Teleport,
}

Sfx :: enum u8 {
	None,
	Bump,
	Locked,
	Unlock,
	Step,
	Pick_Up_Key,
	Pick_Up_Broom,
	Sweep,
	No_Sweep,
	Dust_Bunny_Summon,
	Dust_Bunny_Teleport,
	Generic_Fail,
	Dust_Bin,
	Sign,
	Dust_Into_Bin,
	Dish_Washer,
	Cupboard,
	Dirty_Dish,
	Wardrobe,
	Washing_Machine,
	Soap_Dispenser,
	Folding_Table,
	Pick_Up_Laundry_Basket,
	Dryer,
}

Message :: enum u8 {
	None,
	Welcome,
	Locked,
	Key_Found,
	Broom_Found,
	Inventory_Full,
	Dirt_Pile,
	Dust_Bunny_Summoned,
	Dust_Bin,
	Sign_Sweeping,
	Sign_Dishes,
	Sign_Last,
	Dish_Washer,
	Cupboard,
	Last_Dish,
	Laundry_Basket_Needed,
	Soiled_Wet,
	Soiled_Dry,
	Soiled_Folded,
	Washer_Info,
	Washer_Busy,
	Washer_Exploded,
	Washer_Soap_First,
	Wet_Into_Soiled,
	Wet_Into_Dry,
	Wet_Into_Folded,
	Need_Basket,
	Dryer_Info,
	Dryer_Busy,
	Dry_Into_Wet,
	Dry_Into_Soiled,
	Folding_Table,
	Soap_One_Per_Customer,
	Soap_Given,
	Wardrobe,
	Last_Shirt,
}

// The original's text, word for word. Every message but the welcome gets the close hint added.
MESSAGE_TEXT := [Message]string {
	.None                  = "",
	.Welcome               = "Welcome to Chores of SPLORR!!\n\nA Production of TheGrumpyGameDev\nFor GlamJam 2025\n\n(with \"help\" from his malcontents and\nne'er-do-wells that watch him stream)\n\nYou have a set of tasks in yer house.\nThey are thankless chores!\nThe first of yer tasks is sweeping.\nGrab a broom, and get to it!",
	.Locked                = "The DOOR is LOCKED.\n\nYou need a KEY.",
	.Key_Found             = "You have found a KEY.\n\nProlly it opens a DOOR.",
	.Broom_Found           = "You have a BROOM.\n\nI wonder what it's for?",
	.Inventory_Full        = "Yer inventory is full!",
	.Dirt_Pile             = "This is a pile of DIRT.\n\nYou can use a BROOM to sweep it towards a DUST BIN.",
	.Dust_Bunny_Summoned   = "You piled the DIRT too high...\n\n...and summoned a dread DUST BUNNY!",
	.Dust_Bin              = "This is the DUST BIN.\n\nYou push DIRT in here.",
	.Sign_Sweeping         = "This is a sign. Yer reading it.\n\nYou might also try interacting with other objects.",
	.Sign_Dishes           = "Who left all of these DIRTY DISHES on the floor?\n\nWhy aren't there any TABLES in this room?\n\nSo many questions....",
	.Sign_Last             = "You have completed yer tasks!\n\nGood job!\n\nTomorrow, you can do them again!",
	.Dish_Washer           = "This is a DISH WASHER.\n\n(Yes, I know it looks like a WASHING MACHINE.)\n\nYou use this to make a DIRTY DISH into a CLEAN DISH.",
	.Cupboard              = "This is a CUPBOARD.\n\nYou use this to store CLEAN DISHES.",
	.Last_Dish             = "As you put away the last DISH,\n\na KEY magically appears.\n\nWTH?",
	.Laundry_Basket_Needed = "When dealing with laundry,\n\ntis best to use a LAUNDRY BASKET.",
	.Soiled_Wet            = "Putting SOILED SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith WET SHIRTS\n\nonly soiled the WET SHIRTS.",
	.Soiled_Dry            = "Putting SOILED SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith DRY SHIRTS\n\nonly soiled the DRY SHIRTS.",
	.Soiled_Folded         = "Putting SOILED SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith FOLDED SHIRTS\n\nonly soiled the FOLDED SHIRTS.",
	.Washer_Info           = "This is a WASHING MACHINE.\n\nIt converts SOILED SHIRTS into clean WET SHIRTS,\n\nwith the help of SOAP.",
	.Washer_Busy           = "The WASHING MACHINE is busy\n\nmaking SOILED SHIRTS into clean WET SHIRTS.",
	.Washer_Exploded       = "You have overloaded the WASHING_MACHINE!\n\nAs a result, it has exploded, \n\nthrowing SOILED SHIRTS all about the room.",
	.Washer_Soap_First     = "It is best to add SOILED SHIRTS prior to adding SOAP.",
	.Wet_Into_Soiled       = "Putting WET SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith SOILED SHIRTS\n\nmade the WET SHIRTS soiled.",
	.Wet_Into_Dry          = "Putting WET SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith DRY SHIRTS\n\nmade the DRY SHIRTS wet.",
	.Wet_Into_Folded       = "Putting WET SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith FOLDED SHIRTS\n\nmade the FOLDED SHIRTS wet.",
	.Need_Basket           = "You need a LAUNDRY BASKET!",
	.Dryer_Info            = "This is a DRYER.\n\nIt takes WET CLOTHES\n\nand turns them into DRY CLOTHES.",
	.Dryer_Busy            = "The DRYER is busy turning\n\nWET CLOTHES into DRY CLOTHES.",
	.Dry_Into_Wet          = "Putting DRY SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith WET SHIRTS\n\nmade the DRY SHIRTS wet.",
	.Dry_Into_Soiled       = "Putting DRY SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith SOILED SHIRTS\n\nmade the DRY SHIRTS soiled.",
	.Folding_Table         = "This is a FOLDING TABLE\n\nyou use it to turn DRY SHIRTS\n\ninto FOLDED SHIRTS.",
	.Soap_One_Per_Customer = "Sorry, one SOAP per customer.\n\n(How does it know?)",
	.Soap_Given            = "The SOAP DISPENSER gives you SOAP.",
	.Wardrobe              = "This is a WARDROBE\n\n(it doesn't lead to NARNIA)\n\nyou put FOLDED SHIRTS in here.",
	.Last_Shirt            = "With all of the CLOTHES\n\nin the WARDROBE,\n\nanother magical KEY appears!\n\nSeriously, what the?",
}

WORLD_VERSION :: 1

World :: struct {
	version:         u32,
	rng:             Rng,
	cells:           [Room][COLS][ROWS]Cell,
	hero_room:       Room,
	hero_col:        i32,
	hero_row:        i32,
	inventory:       [INVENTORY_SIZE]Item,
	inventory_count: i32,
	moves:           i32,
	score:           i32,
	// Messages wait in a queue; the first one is on screen and blocks movement until closed.
	messages:        [MAX_MESSAGES]Message,
	message_count:   i32,
	// Sound effects raised by the last action, for the page to play (not part of the game state).
	sfx:             [MAX_SFX]Sfx,
	sfx_count:       i32,
}

Interaction :: enum u8 {
	Push,
	Pull,
}

Interact_Context :: struct {
	room:        Room,
	col, row:    i32,
	delta_col:   i32,
	delta_row:   i32,
	interaction: Interaction,
}

// ---------------------------------------------------------------- basics

in_bounds :: proc(col, row: i32) -> bool {
	return col >= 1 && col <= COLS && row >= 1 && row <= ROWS
}

// A cell; outside the room it is a scratch wall cell, so the rules never index out of range.
cell :: proc(w: ^World, room: Room, col, row: i32) -> ^Cell {
	@(static) outside: Cell
	if !in_bounds(col, row) {
		outside = Cell {
			terrain = .Wall,
		}
		return &outside
	}
	return &w.cells[room][col - 1][row - 1]
}

passable :: proc(t: Terrain) -> bool {
	return t == .Floor || t == .Open_Door
}

play :: proc(w: ^World, s: Sfx) {
	if s == .None || w.sfx_count >= MAX_SFX {
		return
	}
	w.sfx[w.sfx_count] = s
	w.sfx_count += 1
}

show_message :: proc(w: ^World, m: Message) {
	if m == .None || w.message_count >= MAX_MESSAGES {
		return
	}
	w.messages[w.message_count] = m
	w.message_count += 1
}

current_message :: proc(w: ^World) -> Message {
	return w.message_count > 0 ? w.messages[0] : .None
}

close_message :: proc(w: ^World) {
	if w.message_count == 0 {
		return
	}
	for i in 1 ..< w.message_count {
		w.messages[i - 1] = w.messages[i]
	}
	w.message_count -= 1
	w.messages[w.message_count] = .None
}

// ---------------------------------------------------------------- inventory (an ordered list, like the Lua table)

has_item :: proc(w: ^World, it: Item) -> bool {
	for i in 0 ..< w.inventory_count {
		if w.inventory[i] == it {
			return true
		}
	}
	return false
}

count_item :: proc(w: ^World, it: Item) -> int {
	n := 0
	for i in 0 ..< w.inventory_count {
		if w.inventory[i] == it {
			n += 1
		}
	}
	return n
}

add_item :: proc(w: ^World, it: Item) -> bool {
	if w.inventory_count >= INVENTORY_SIZE {
		return false
	}
	w.inventory[w.inventory_count] = it
	w.inventory_count += 1
	return true
}

// Removes the first item of the type, keeping the others in order.
remove_item :: proc(w: ^World, it: Item) -> bool {
	for i in 0 ..< w.inventory_count {
		if w.inventory[i] == it {
			for j in i + 1 ..< w.inventory_count {
				w.inventory[j - 1] = w.inventory[j]
			}
			w.inventory_count -= 1
			w.inventory[w.inventory_count] = .None
			return true
		}
	}
	return false
}

// Each one is taken out and a new one put at the end, as characters/utility.lua does.
convert_items :: proc(w: ^World, from, to: Item) {
	for has_item(w, from) {
		remove_item(w, from)
		add_item(w, to)
	}
}

inventory_space :: proc(w: ^World) -> i32 {
	return INVENTORY_SIZE - w.inventory_count
}

// ---------------------------------------------------------------- descriptors

terrain_step_sfx :: proc(t: Terrain) -> Sfx {
	return passable(t) ? .Step : .None
}

terrain_bump_sfx :: proc(t: Terrain) -> Sfx {
	return passable(t) ? .None : .Bump
}

item_pickup_sfx :: proc(it: Item) -> Sfx {
	#partial switch it {
	case .Key:
		return .Pick_Up_Key
	case .Broom:
		return .Pick_Up_Broom
	case .Dirty_Dish:
		return .Dirty_Dish
	case .Laundry_Basket:
		return .Pick_Up_Laundry_Basket
	}
	return .None
}

item_pickup_message :: proc(it: Item) -> Message {
	#partial switch it {
	case .Key:
		return .Key_Found
	case .Broom:
		return .Broom_Found
	}
	return .None
}

feature_success_sfx :: proc(k: Feature_Kind) -> Sfx {
	switch k {
	case .None:
		return .None
	case .Dirt_Pile:
		return .Sweep
	case .Dust_Bin:
		return .Dust_Bin
	case .Sign:
		return .Sign
	case .Dish_Washer:
		return .Dish_Washer
	case .Cupboard:
		return .Cupboard
	case .Wardrobe:
		return .Wardrobe
	case .Washing_Machine:
		return .Washing_Machine
	case .Soap_Dispenser:
		return .Soap_Dispenser
	case .Folding_Table:
		return .Folding_Table
	case .Dryer:
		return .Dryer
	}
	return .None
}

feature_failure_sfx :: proc(k: Feature_Kind) -> Sfx {
	return k == .Dirt_Pile ? .No_Sweep : .None
}

// ---------------------------------------------------------------- setting up the house

new_world :: proc(w: ^World, seed: u64) {
	w^ = {}
	w.version = WORLD_VERSION
	rng_seed(&w.rng, seed)
	init_sweeping(w)
	init_dishes(w)
	init_laundry(w)
	init_last(w)
	show_message(w, .Welcome)
}

// A restart builds a new house; the welcome is not shown again (as in the original).
restart :: proc(w: ^World) {
	seed := rng_next(&w.rng)
	new_world(w, seed)
	w.message_count = 0
	w.messages = {}
}

@(private = "file")
walled_room :: proc(w: ^World, room: Room) {
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			c := cell(w, room, col, row)
			c.terrain = .Floor
			if col == 1 || row == 1 || col == COLS || row == ROWS {
				c.terrain = .Wall
			}
		}
	}
}

@(private = "file")
locked_door :: proc(w: ^World, room: Room, col, row: i32) {
	c := cell(w, room, col, row)
	c.terrain = .Closed_Door
	c.locked = true
}

@(private = "file")
link :: proc(w: ^World, room: Room, col, row: i32, to: Room, to_col, to_row: i32) {
	cell(w, room, col, row).teleport = Teleport{true, to, u8(to_col), u8(to_row)}
}

@(private = "file")
put_feature :: proc(w: ^World, room: Room, col, row: i32, f: Feature) {
	cell(w, room, col, row).feature = f
}

// A cell a random placement may use: passable and empty.
@(private = "file")
free_cell :: proc(w: ^World, room: Room, col, row: i32) -> bool {
	c := cell(w, room, col, row)
	return passable(c.terrain) && c.item == .None && c.character == .None && c.feature.kind == .None
}

// rooms/utility.lua place_items: random cells away from the walls until count are placed.
place_items :: proc(w: ^World, room: Room, it: Item, count: int) {
	left := count
	for left > 0 {
		col := i32(rng_range(&w.rng, 2, COLS - 1))
		row := i32(rng_range(&w.rng, 2, ROWS - 1))
		if free_cell(w, room, col, row) {
			cell(w, room, col, row).item = it
			left -= 1
		}
	}
}

@(private = "file")
init_sweeping :: proc(w: ^World) {
	room := Room.Sweeping
	walled_room(w, room)
	locked_door(w, room, COLS, CENTER_Y)
	cell(w, room, CENTER_X - 1, CENTER_Y).item = .Broom
	put_feature(w, room, COLS - 1, ROWS - 1, {kind = .Dust_Bin})
	put_feature(w, room, CENTER_X + 1, CENTER_Y, {kind = .Sign, sign = .Sweeping})

	cell(w, room, CENTER_X, CENTER_Y).character = .Hero
	w.hero_room, w.hero_col, w.hero_row = room, CENTER_X, CENTER_Y

	// place_features: anywhere in the room (the walls are refused), intensity 1 each.
	piles: [TOTAL_DIRT][2]i32
	placed := 0
	for placed < TOTAL_DIRT {
		col := i32(rng_range(&w.rng, 1, COLS))
		row := i32(rng_range(&w.rng, 1, ROWS))
		if free_cell(w, room, col, row) {
			put_feature(w, room, col, row, {kind = .Dirt_Pile, intensity = 1})
			piles[placed] = {col, row}
			placed += 1
		}
	}
	// The KEY hides in one of them.
	k := piles[rng_range(&w.rng, 0, TOTAL_DIRT - 1)]
	cell(w, room, k[0], k[1]).feature.item = .Key
}

@(private = "file")
init_dishes :: proc(w: ^World) {
	room := Room.Dishes
	walled_room(w, room)
	locked_door(w, room, CENTER_X, ROWS)
	cell(w, room, 1, CENTER_Y).terrain = .Open_Door
	link(w, .Sweeping, COLS, CENTER_Y, room, 2, CENTER_Y)
	link(w, room, 1, CENTER_Y, .Sweeping, COLS - 1, CENTER_Y)
	put_feature(w, room, COLS - 1, 2, {kind = .Dish_Washer})
	put_feature(w, room, 2, ROWS - 1, {kind = .Cupboard, remaining = TOTAL_DISHES})
	put_feature(w, room, 3, CENTER_Y, {kind = .Sign, sign = .Dishes})
	place_items(w, room, .Dirty_Dish, TOTAL_DISHES)
}

@(private = "file")
init_laundry :: proc(w: ^World) {
	room := Room.Laundry
	walled_room(w, room)
	locked_door(w, room, 1, CENTER_Y)
	cell(w, room, CENTER_X, 1).terrain = .Open_Door
	link(w, .Dishes, CENTER_X, ROWS, room, CENTER_X, 2)
	link(w, room, CENTER_X, 1, .Dishes, CENTER_X, ROWS - 1)
	put_feature(w, room, 2, 2, {kind = .Washing_Machine, state = .Loading})
	put_feature(w, room, 2, 3, {kind = .Dryer, state = .Loading})
	put_feature(w, room, COLS - 1, ROWS - 1, {kind = .Wardrobe, remaining = TOTAL_CLOTHES})
	put_feature(w, room, 2, ROWS - 1, {kind = .Folding_Table})
	put_feature(w, room, COLS - 1, 2, {kind = .Soap_Dispenser})
	cell(w, room, CENTER_X, CENTER_Y).item = .Laundry_Basket
	place_items(w, room, .Soiled_Shirt, TOTAL_CLOTHES)
}

@(private = "file")
init_last :: proc(w: ^World) {
	room := Room.Last
	walled_room(w, room)
	cell(w, room, COLS, CENTER_Y).terrain = .Open_Door
	link(w, .Laundry, 1, CENTER_Y, room, COLS - 1, CENTER_Y)
	link(w, room, COLS, CENTER_Y, .Laundry, 2, CENTER_Y)
	put_feature(w, room, CENTER_X, CENTER_Y, {kind = .Sign, sign = .Last})
}

// ---------------------------------------------------------------- moving the avatar (world/avatar.lua)

move_up :: proc(w: ^World) {move_avatar(w, 0, 1)}
move_down :: proc(w: ^World) {move_avatar(w, 0, -1)}
move_left :: proc(w: ^World) {move_avatar(w, -1, 0)}
move_right :: proc(w: ^World) {move_avatar(w, 1, 0)}

move_avatar :: proc(w: ^World, dc, dr: i32) {
	if w.message_count > 0 {
		return // a message is up: movement waits until it is closed
	}
	room, col, row := w.hero_room, w.hero_col, w.hero_row
	nc, nr := col + dc, row + dr
	pc, pr := col - dc, row - dr
	next := cell(w, room, nc, nr)

	// Rules regarding terrain
	if !passable(next.terrain) {
		if next.locked {
			if !has_item(w, .Key) {
				show_message(w, .Locked)
				play(w, .Locked)
				return
			}
			remove_item(w, .Key)
			next.terrain = .Open_Door
			next.locked = false
			play(w, .Unlock)
			return
		}
		play(w, terrain_bump_sfx(next.terrain))
		return
	}
	terrain := next.terrain

	// Rules regarding items
	if next.item != .None {
		if hero_can_pick_up(w, next.item) {
			it := next.item
			play(w, item_pickup_sfx(it))
			next.item = .None
			add_item(w, it)
			show_message(w, item_pickup_message(it))
		} else {
			play(w, .Generic_Fail)
		}
		return
	}

	// Rules regarding PUSH interactions with features
	if next.feature.kind != .None {
		ctx := Interact_Context{room, nc, nr, dc, dr, .Push}
		kind := next.feature.kind
		if !feature_can_interact(w, ctx) {
			play(w, feature_failure_sfx(kind))
			return
		}
		feature_interact(w, ctx)
		play(w, feature_success_sfx(kind))
		return
	}

	// Rules regarding other characters
	if next.character != .None {
		return
	}

	// Rules regarding teleportation
	to_room, to_col, to_row := room, nc, nr
	if next.teleport.active {
		to_room, to_col, to_row = next.teleport.room, i32(next.teleport.col), i32(next.teleport.row)
	}

	// Actually move
	play(w, terrain_step_sfx(terrain))
	w.moves += 1
	cell(w, room, col, row).character = .None
	cell(w, to_room, to_col, to_row).character = .Hero
	w.hero_room, w.hero_col, w.hero_row = to_room, to_col, to_row

	// Rules regarding PULL interactions with features (what was behind you, in the room you left)
	prev := cell(w, room, pc, pr)
	if prev.feature.kind != .None {
		ctx := Interact_Context{room, pc, pr, dc, dr, .Pull}
		kind := prev.feature.kind
		if !feature_can_interact(w, ctx) {
			play(w, feature_failure_sfx(kind))
		} else {
			feature_interact(w, ctx)
			play(w, feature_success_sfx(kind))
		}
	}

	// Other characters in the room you left take their turn, then its features
	move_dust_bunnies(w, room)
	tick_machines(w, room)
}

// characters/HERO.lua
hero_can_pick_up :: proc(w: ^World, it: Item) -> bool {
	if w.inventory_count >= INVENTORY_SIZE {
		// The original refused with only a fail sound (QUIRKS.md); the message is its own text.
		show_message(w, .Inventory_Full)
		return false
	}
	if it == .Soiled_Shirt {
		if !has_item(w, .Laundry_Basket) {
			show_message(w, .Laundry_Basket_Needed)
			return false
		}
		if has_item(w, .Washed_Shirt) {
			convert_items(w, .Washed_Shirt, .Soiled_Shirt)
			show_message(w, .Soiled_Wet)
		}
		if has_item(w, .Dry_Shirt) {
			convert_items(w, .Dry_Shirt, .Soiled_Shirt)
			show_message(w, .Soiled_Dry)
		}
		if has_item(w, .Folded_Shirt) {
			convert_items(w, .Folded_Shirt, .Soiled_Shirt)
			show_message(w, .Soiled_Folded)
		}
	}
	return true
}

// characters/DUST_BUNNY.lua: each turn a bunny leaves a pile of 1 dirt where it was and hops to
// a random empty floor cell, until its dirt is spent; the last pile gets whatever it carried.
move_dust_bunnies :: proc(w: ^World, room: Room) {
	bunnies: [COLS * ROWS][2]i32
	n := 0
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			if cell(w, room, col, row).character == .Dust_Bunny {
				bunnies[n] = {col, row}
				n += 1
			}
		}
	}
	for b in bunnies[:n] {
		c := cell(w, room, b[0], b[1])
		if c.character != .Dust_Bunny {
			continue
		}
		intensity := c.bunny_intensity - 1
		item := c.bunny_item
		c.character = .None
		c.bunny_intensity = 0
		c.bunny_item = .None
		c.feature = Feature {
			kind      = .Dirt_Pile,
			intensity = 1,
		}
		if intensity == 0 && item != .None {
			c.feature.item = item
		}
		if intensity > 0 {
			for {
				col := i32(rng_range(&w.rng, 1, COLS))
				row := i32(rng_range(&w.rng, 1, ROWS))
				t := cell(w, room, col, row)
				if t.terrain == .Floor && t.character == .None && t.feature.kind == .None && t.item == .None {
					t.character = .Dust_Bunny
					t.bunny_intensity = intensity
					t.bunny_item = item
					break
				}
			}
		}
		play(w, .Dust_Bunny_Teleport)
	}
}

// The washing machine and dryer count down one turn each time you move in their room.
tick_machines :: proc(w: ^World, room: Room) {
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			f := &cell(w, room, col, row).feature
			if f.kind == .Washing_Machine && f.state == .Washing {
				f.timer -= 1
				if f.timer == 0 {
					f.state = .Clean
				}
			} else if f.kind == .Dryer && f.state == .Drying {
				f.timer -= 1
				if f.timer == 0 {
					f.state = .Dry
				}
			}
		}
	}
}

// ---------------------------------------------------------------- features (world/features/*.lua)

feature_can_interact :: proc(w: ^World, ctx: Interact_Context) -> bool {
	f := &cell(w, ctx.room, ctx.col, ctx.row).feature
	push := ctx.interaction == .Push
	switch f.kind {
	case .None:
		return false
	case .Dirt_Pile:
		if !has_item(w, .Broom) {
			if push {
				show_message(w, .Dirt_Pile)
			}
			return false
		}
		n := cell(w, ctx.room, ctx.col + ctx.delta_col, ctx.row + ctx.delta_row)
		if n.terrain != .Floor {
			return false
		}
		return n.feature.kind == .None || n.feature.kind == .Dirt_Pile || n.feature.kind == .Dust_Bin
	case .Dust_Bin, .Sign, .Dish_Washer, .Cupboard, .Wardrobe:
		return push
	case .Soap_Dispenser:
		if !push {
			return false
		}
		if has_item(w, .Soap) {
			show_message(w, .Soap_One_Per_Customer)
			return false
		}
		return true
	case .Folding_Table:
		if !push {
			return false
		}
		if has_item(w, .Dry_Shirt) {
			return true
		}
		show_message(w, .Folding_Table)
		return false
	case .Washing_Machine:
		if !push {
			return false
		}
		#partial switch f.state {
		case .Loading:
			if has_item(w, .Soiled_Shirt) || has_item(w, .Soap) {
				return true
			}
			show_message(w, .Washer_Info)
			return false
		case .Washing:
			show_message(w, .Washer_Busy)
			return false
		case .Clean:
			return can_unload(w)
		}
		return true
	case .Dryer:
		if !push {
			return false
		}
		#partial switch f.state {
		case .Loading:
			if has_item(w, .Washed_Shirt) {
				return true
			}
			show_message(w, .Dryer_Info)
			return false
		case .Drying:
			show_message(w, .Dryer_Busy)
			return false
		case .Dry:
			return can_unload(w)
		}
		return false
	}
	return false
}

@(private = "file")
can_unload :: proc(w: ^World) -> bool {
	if inventory_space(w) <= 0 {
		show_message(w, .Inventory_Full)
		return false
	}
	if !has_item(w, .Laundry_Basket) {
		show_message(w, .Need_Basket)
		return false
	}
	return true
}

feature_interact :: proc(w: ^World, ctx: Interact_Context) {
	here := cell(w, ctx.room, ctx.col, ctx.row)
	f := &here.feature
	switch f.kind {
	case .None:
	case .Dirt_Pile:
		sweep_dirt(w, ctx)
	case .Dust_Bin:
		show_message(w, .Dust_Bin)
	case .Sign:
		switch f.sign {
		case .None:
		case .Sweeping:
			show_message(w, .Sign_Sweeping)
		case .Dishes:
			show_message(w, .Sign_Dishes)
		case .Last:
			show_message(w, .Sign_Last)
		}
	case .Dish_Washer:
		if has_item(w, .Dirty_Dish) {
			remove_item(w, .Dirty_Dish)
			add_item(w, .Clean_Dish)
		} else {
			show_message(w, .Dish_Washer)
		}
	case .Cupboard:
		if has_item(w, .Clean_Dish) {
			remove_item(w, .Clean_Dish)
			w.score += 10
			f.remaining -= 1
			if f.remaining < 1 {
				cell(w, w.hero_room, COLS - 1, ROWS - 1).item = .Key
				show_message(w, .Last_Dish)
			}
		} else {
			show_message(w, .Cupboard)
		}
	case .Wardrobe:
		if has_item(w, .Folded_Shirt) {
			remove_item(w, .Folded_Shirt)
			w.score += 10
			f.remaining -= 1
			if f.remaining == 0 {
				// The original tried one random cell and gave up if it was taken (QUIRKS.md).
				place_items(w, w.hero_room, .Key, 1)
				show_message(w, .Last_Shirt)
			}
			return
		}
		show_message(w, .Wardrobe)
	case .Soap_Dispenser:
		add_item(w, .Soap)
		show_message(w, .Soap_Given)
	case .Folding_Table:
		remove_item(w, .Dry_Shirt)
		add_item(w, .Folded_Shirt)
	case .Washing_Machine:
		washing_machine(w, f)
	case .Dryer:
		dryer(w, f)
	}
}

// features/DIRT_PILE.lua: move the pile one cell; it merges with a pile there, summons a dust
// bunny past 9, or scores 10 per dirt in a dust bin. A hidden item stays where the pile was.
@(private = "file")
sweep_dirt :: proc(w: ^World, ctx: Interact_Context) {
	here := cell(w, ctx.room, ctx.col, ctx.row)
	pile := here.feature
	here.feature = {}
	if pile.item != .None {
		here.item = pile.item
		pile.item = .None
	}
	n := cell(w, ctx.room, ctx.col + ctx.delta_col, ctx.row + ctx.delta_row)
	#partial switch n.feature.kind {
	case .None:
		n.feature = pile
	case .Dirt_Pile:
		total := n.feature.intensity + pile.intensity
		if total <= DIRT_PILE_MAXIMUM_INTENSITY {
			n.feature.intensity = total
		} else {
			carried := n.feature.item
			n.feature = {}
			n.character = .Dust_Bunny
			n.bunny_intensity = total
			n.bunny_item = carried
			show_message(w, .Dust_Bunny_Summoned)
			play(w, .Dust_Bunny_Summon)
		}
	case .Dust_Bin:
		w.score += DIRT_PILE_SCORE_MULTIPLIER * i32(pile.intensity)
		play(w, .Dust_Into_Bin)
	}
}

@(private = "file")
washing_machine :: proc(w: ^World, f: ^Feature) {
	#partial switch f.state {
	case .Loading:
		if has_item(w, .Soiled_Shirt) {
			for remove_item(w, .Soiled_Shirt) {
				f.intensity += 1
				if f.intensity > WASHING_MACHINE_MAXIMUM_INTENSITY {
					place_items(w, w.hero_room, .Soiled_Shirt, int(f.intensity))
					show_message(w, .Washer_Exploded)
					f.intensity = 0
					return
				}
			}
			return
		}
		if has_item(w, .Soap) {
			if f.intensity == 0 {
				show_message(w, .Washer_Soap_First)
				return
			}
			remove_item(w, .Soap)
			f.state = .Washing
			f.timer = MACHINE_TIMER
		}
	case .Clean:
		take := min(i32(f.intensity), inventory_space(w))
		has_soiled := has_item(w, .Soiled_Shirt)
		has_dry := has_item(w, .Dry_Shirt)
		has_folded := has_item(w, .Folded_Shirt)
		for _ in 0 ..< take {
			f.intensity -= 1
			add_item(w, has_soiled ? .Soiled_Shirt : .Washed_Shirt)
		}
		if has_soiled {
			show_message(w, .Wet_Into_Soiled)
		} else if has_dry {
			show_message(w, .Wet_Into_Dry)
			convert_items(w, .Dry_Shirt, .Washed_Shirt)
		} else if has_folded {
			show_message(w, .Wet_Into_Folded)
			convert_items(w, .Folded_Shirt, .Washed_Shirt)
		}
		if f.intensity == 0 {
			f.state = .Loading
		}
	}
}

@(private = "file")
dryer :: proc(w: ^World, f: ^Feature) {
	#partial switch f.state {
	case .Loading:
		added := 0
		for remove_item(w, .Washed_Shirt) {
			f.intensity += 1
			added += 1
		}
		if added > 0 {
			f.state = .Drying
			f.timer = MACHINE_TIMER
		}
	case .Dry:
		take := min(i32(f.intensity), inventory_space(w))
		has_soiled := has_item(w, .Soiled_Shirt)
		has_wet := has_item(w, .Washed_Shirt)
		for _ in 0 ..< take {
			f.intensity -= 1
			it := Item.Dry_Shirt
			if has_soiled {
				it = .Soiled_Shirt
			} else if has_wet {
				it = .Washed_Shirt
			}
			add_item(w, it)
		}
		if has_wet {
			show_message(w, .Dry_Into_Wet)
		} else if has_soiled {
			show_message(w, .Dry_Into_Soiled)
		}
		if f.intensity == 0 {
			f.state = .Loading
		}
	}
}

// True once the hero has walked into the last room (the sign there says the tasks are done).
tasks_done :: proc(w: ^World) -> bool {
	return w.hero_room == .Last
}
