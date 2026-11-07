#+build !js
package chores

import "core:testing"

// ---------------------------------------------------------------- helpers

// Puts the hero somewhere directly (tests only); every interaction afterwards is a real move.
put_hero :: proc(w: ^World, room: Room, col, row: i32) {
	cell(w, w.hero_room, w.hero_col, w.hero_row).character = .None
	cell(w, room, col, row).character = .Hero
	w.hero_room, w.hero_col, w.hero_row = room, col, row
}

fresh :: proc(w: ^World, seed: u64) {
	new_world(w, seed)
	close_message(w) // the welcome
}

close_all :: proc(w: ^World) {
	for w.message_count > 0 {
		close_message(w)
	}
}

// Steps from (col,row) into the neighbour in direction (dc,dr), standing the hero there first.
step_into :: proc(w: ^World, room: Room, col, row, dc, dr: i32) {
	put_hero(w, room, col - dc, row - dr)
	move_avatar(w, dc, dr)
}

count_in_room :: proc(w: ^World, room: Room, it: Item) -> int {
	n := 0
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			if cell(w, room, col, row).item == it {
				n += 1
			}
		}
	}
	return n
}

find_feature :: proc(w: ^World, room: Room, k: Feature_Kind) -> (col, row: i32, ok: bool) {
	for c in i32(1) ..= COLS {
		for r in i32(1) ..= ROWS {
			if cell(w, room, c, r).feature.kind == k {
				return c, r, true
			}
		}
	}
	return
}

clear_room_of :: proc(w: ^World, room: Room, k: Feature_Kind) {
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			if cell(w, room, col, row).feature.kind == k {
				cell(w, room, col, row).feature = {}
			}
		}
	}
}

clear_items :: proc(w: ^World, room: Room) {
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			cell(w, room, col, row).item = .None
		}
	}
}

// Shirts anywhere: floor, inventory, machines, wardrobe. Always TOTAL_CLOTHES.
total_shirts :: proc(w: ^World) -> int {
	n := 0
	for it in ([]Item{.Soiled_Shirt, .Washed_Shirt, .Dry_Shirt, .Folded_Shirt}) {
		n += count_in_room(w, .Laundry, it) + count_item(w, it)
	}
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			f := cell(w, .Laundry, col, row).feature
			#partial switch f.kind {
			case .Washing_Machine, .Dryer:
				n += int(f.intensity)
			case .Wardrobe:
				n += TOTAL_CLOTHES - int(f.remaining)
			}
		}
	}
	return n
}

total_dishes :: proc(w: ^World) -> int {
	n := count_in_room(w, .Dishes, .Dirty_Dish) + count_in_room(w, .Dishes, .Clean_Dish)
	n += count_item(w, .Dirty_Dish) + count_item(w, .Clean_Dish)
	if c, r, ok := find_feature(w, .Dishes, .Cupboard); ok {
		n += TOTAL_DISHES - int(cell(w, .Dishes, c, r).feature.remaining)
	}
	return n
}

// ---------------------------------------------------------------- setting up

@(test)
test_new_house :: proc(t: ^testing.T) {
	for seed in u64(1) ..= 40 {
		w := new(World)
		defer free(w)
		new_world(w, seed)
		testing.expect_value(t, current_message(w), Message.Welcome)
		testing.expect_value(t, w.hero_room, Room.Sweeping)
		testing.expect_value(t, w.hero_col, i32(CENTER_X))
		piles, dirt, keys := 0, 0, 0
		for col in i32(1) ..= COLS {
			for row in i32(1) ..= ROWS {
				f := cell(w, .Sweeping, col, row).feature
				if f.kind == .Dirt_Pile {
					piles += 1
					dirt += int(f.intensity)
					if f.item == .Key {keys += 1}
				}
			}
		}
		testing.expect_value(t, piles, TOTAL_DIRT)
		testing.expect_value(t, dirt, TOTAL_DIRT)
		testing.expect_value(t, keys, 1)
		testing.expect_value(t, count_in_room(w, .Sweeping, .Broom), 1)
		testing.expect_value(t, count_in_room(w, .Dishes, .Dirty_Dish), TOTAL_DISHES)
		testing.expect_value(t, count_in_room(w, .Laundry, .Soiled_Shirt), TOTAL_CLOTHES)
		testing.expect_value(t, count_in_room(w, .Laundry, .Laundry_Basket), 1)
		testing.expect_value(t, total_shirts(w), TOTAL_CLOTHES)
		testing.expect_value(t, total_dishes(w), TOTAL_DISHES)
		testing.expect(t, world_valid(w))
	}
}

@(test)
test_message_blocks_movement :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	new_world(w, 7)
	move_up(w)
	testing.expect_value(t, w.moves, i32(0))
	testing.expect_value(t, app_key(w, .Close), Outcome.Changed)
	testing.expect_value(t, w.message_count, i32(0))
}

@(test)
test_messages_queue :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 3)
	show_message(w, .Soiled_Wet)
	show_message(w, .Soiled_Dry)
	testing.expect_value(t, current_message(w), Message.Soiled_Wet)
	close_message(w)
	testing.expect_value(t, current_message(w), Message.Soiled_Dry)
	close_message(w)
	testing.expect_value(t, current_message(w), Message.None)
}

// ---------------------------------------------------------------- doors and keys

@(test)
test_locked_door_and_key :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 11)
	step_into(w, .Sweeping, COLS, CENTER_Y, 1, 0)
	testing.expect_value(t, current_message(w), Message.Locked)
	testing.expect_value(t, cell(w, .Sweeping, COLS, CENTER_Y).terrain, Terrain.Closed_Door)
	close_all(w)

	add_item(w, .Key)
	move_right(w) // unlocks, does not move
	testing.expect_value(t, cell(w, .Sweeping, COLS, CENTER_Y).terrain, Terrain.Open_Door)
	testing.expect(t, !has_item(w, .Key), "the key is used up")
	testing.expect_value(t, w.hero_room, Room.Sweeping)
	move_right(w) // through the door
	testing.expect_value(t, w.hero_room, Room.Dishes)
	testing.expect_value(t, w.hero_col, i32(2))
	testing.expect_value(t, w.hero_row, i32(CENTER_Y))
	move_left(w) // and back
	testing.expect_value(t, w.hero_room, Room.Sweeping)
	testing.expect_value(t, w.hero_col, i32(COLS - 1))
}

@(test)
test_walls_bump :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 5)
	clear_room_of(w, .Sweeping, .Dirt_Pile)
	put_hero(w, .Sweeping, 2, 2)
	move_left(w)
	testing.expect_value(t, w.hero_col, i32(2))
	testing.expect_value(t, w.sfx[0], Sfx.Bump)
	testing.expect_value(t, w.moves, i32(0))
}

// ---------------------------------------------------------------- sweeping

@(test)
test_dirt_needs_broom :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 9)
	clear_room_of(w, .Sweeping, .Dirt_Pile)
	cell(w, .Sweeping, 6, 6).feature = {kind = .Dirt_Pile, intensity = 1}
	step_into(w, .Sweeping, 6, 6, 1, 0)
	testing.expect_value(t, current_message(w), Message.Dirt_Pile)
	testing.expect_value(t, cell(w, .Sweeping, 6, 6).feature.kind, Feature_Kind.Dirt_Pile)
	testing.expect_value(t, w.sfx[0], Sfx.No_Sweep)
}

@(test)
test_sweep_merge_bin_and_hidden_key :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 13)
	clear_room_of(w, .Sweeping, .Dirt_Pile)
	add_item(w, .Broom)
	// A pile hiding the key, pushed right: the key stays where the pile was.
	cell(w, .Sweeping, 6, 6).feature = {kind = .Dirt_Pile, intensity = 1, item = .Key}
	step_into(w, .Sweeping, 6, 6, 1, 0)
	testing.expect_value(t, cell(w, .Sweeping, 6, 6).item, Item.Key)
	testing.expect_value(t, cell(w, .Sweeping, 7, 6).feature.kind, Feature_Kind.Dirt_Pile)
	testing.expect_value(t, w.hero_col, i32(5)) // pushing does not move you
	move_right(w) // picks up the key
	testing.expect(t, has_item(w, .Key))
	close_all(w)

	// Merging: 3 + 1 = 4
	cell(w, .Sweeping, 10, 10).feature = {kind = .Dirt_Pile, intensity = 3}
	cell(w, .Sweeping, 11, 10).feature = {kind = .Dirt_Pile, intensity = 1}
	step_into(w, .Sweeping, 11, 10, -1, 0)
	testing.expect_value(t, cell(w, .Sweeping, 10, 10).feature.intensity, i16(4))
	testing.expect_value(t, cell(w, .Sweeping, 11, 10).feature.kind, Feature_Kind.None)

	// Into the dust bin (24,24): 10 per dirt
	cell(w, .Sweeping, 23, 24).feature = {kind = .Dirt_Pile, intensity = 4}
	step_into(w, .Sweeping, 23, 24, 1, 0)
	testing.expect_value(t, w.score, i32(40))
	testing.expect_value(t, cell(w, .Sweeping, 23, 24).feature.kind, Feature_Kind.None)
	testing.expect_value(t, cell(w, .Sweeping, 24, 24).feature.kind, Feature_Kind.Dust_Bin)
}

@(test)
test_pull_drags_dirt :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 17)
	clear_room_of(w, .Sweeping, .Dirt_Pile)
	add_item(w, .Broom)
	cell(w, .Sweeping, 5, 8).feature = {kind = .Dirt_Pile, intensity = 2}
	put_hero(w, .Sweeping, 6, 8)
	move_right(w)
	testing.expect_value(t, w.hero_col, i32(7))
	testing.expect_value(t, cell(w, .Sweeping, 6, 8).feature.intensity, i16(2))
	testing.expect_value(t, cell(w, .Sweeping, 5, 8).feature.kind, Feature_Kind.None)
}

@(test)
test_dust_bunny :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 19)
	clear_room_of(w, .Sweeping, .Dirt_Pile)
	add_item(w, .Broom)
	cell(w, .Sweeping, 8, 8).feature = {kind = .Dirt_Pile, intensity = 9, item = .Key}
	cell(w, .Sweeping, 9, 8).feature = {kind = .Dirt_Pile, intensity = 3}
	step_into(w, .Sweeping, 9, 8, -1, 0)
	testing.expect_value(t, current_message(w), Message.Dust_Bunny_Summoned)
	testing.expect_value(t, cell(w, .Sweeping, 8, 8).character, Character.Dust_Bunny)
	testing.expect_value(t, cell(w, .Sweeping, 8, 8).bunny_intensity, i16(12))
	close_all(w)

	// Each move the bunny drops one dirt and hops; after 12 it is gone and the key is in its last pile.
	put_hero(w, .Sweeping, 20, 3)
	for i in 0 ..< 12 {
		if i % 2 == 0 {move_up(w)} else {move_down(w)}
	}
	bunnies, dirt, key_piles := 0, 0, 0
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			c := cell(w, .Sweeping, col, row)
			if c.character == .Dust_Bunny {bunnies += 1}
			if c.feature.kind == .Dirt_Pile {
				dirt += int(c.feature.intensity)
				if c.feature.item == .Key {key_piles += 1}
			}
		}
	}
	testing.expect_value(t, bunnies, 0)
	testing.expect_value(t, dirt, 12)
	testing.expect_value(t, key_piles, 1)
}

// ---------------------------------------------------------------- dishes

@(test)
test_dishes :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 23)
	clear_items(w, .Dishes)
	cell(w, .Dishes, 10, 10).item = .Dirty_Dish
	step_into(w, .Dishes, 10, 10, 0, 1)
	testing.expect(t, has_item(w, .Dirty_Dish))
	testing.expect_value(t, w.sfx[0], Sfx.Dirty_Dish)

	step_into(w, .Dishes, COLS - 1, 2, 1, 0) // dish washer
	testing.expect(t, has_item(w, .Clean_Dish))
	testing.expect(t, !has_item(w, .Dirty_Dish))
	step_into(w, .Dishes, COLS - 1, 2, 1, 0)
	testing.expect_value(t, current_message(w), Message.Dish_Washer)
	close_all(w)

	cup := cell(w, .Dishes, 2, ROWS - 1)
	cup.feature.remaining = 1
	step_into(w, .Dishes, 2, ROWS - 1, -1, 0)
	testing.expect_value(t, w.score, i32(10))
	testing.expect_value(t, current_message(w), Message.Last_Dish)
	testing.expect_value(t, cell(w, .Dishes, COLS - 1, ROWS - 1).item, Item.Key)
}

// ---------------------------------------------------------------- laundry

@(test)
test_laundry_needs_basket :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 29)
	clear_items(w, .Laundry)
	cell(w, .Laundry, 10, 10).item = .Soiled_Shirt
	step_into(w, .Laundry, 10, 10, 1, 0)
	testing.expect_value(t, current_message(w), Message.Laundry_Basket_Needed)
	testing.expect_value(t, cell(w, .Laundry, 10, 10).item, Item.Soiled_Shirt)
}

@(test)
test_full_inventory_says_so :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 31)
	clear_items(w, .Laundry)
	for _ in 0 ..< INVENTORY_SIZE {add_item(w, .Clean_Dish)}
	cell(w, .Laundry, 10, 10).item = .Soap
	step_into(w, .Laundry, 10, 10, 1, 0)
	testing.expect_value(t, current_message(w), Message.Inventory_Full)
	testing.expect_value(t, w.sfx[0], Sfx.Generic_Fail)
}

@(test)
test_washer_explodes :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 37)
	clear_items(w, .Laundry)
	add_item(w, .Laundry_Basket)
	for _ in 0 ..< 12 {add_item(w, .Soiled_Shirt)}
	step_into(w, .Laundry, 2, 2, -1, 0)
	testing.expect_value(t, current_message(w), Message.Washer_Exploded)
	testing.expect_value(t, count_in_room(w, .Laundry, .Soiled_Shirt), 10)
	testing.expect_value(t, count_item(w, .Soiled_Shirt), 2) // the rest stay in the basket
	testing.expect_value(t, cell(w, .Laundry, 2, 2).feature.intensity, i16(0))
}

@(test)
test_wet_into_soiled :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 41)
	clear_items(w, .Laundry)
	add_item(w, .Laundry_Basket)
	add_item(w, .Washed_Shirt)
	add_item(w, .Dry_Shirt)
	cell(w, .Laundry, 10, 10).item = .Soiled_Shirt
	step_into(w, .Laundry, 10, 10, 1, 0)
	testing.expect_value(t, count_item(w, .Soiled_Shirt), 3)
	testing.expect_value(t, current_message(w), Message.Soiled_Wet)
	close_message(w)
	testing.expect_value(t, current_message(w), Message.Soiled_Dry) // queued, not lost
}

// ---------------------------------------------------------------- the whole house, start to finish

// Walks every room with real moves (the hero is placed beside each thing first) and checks that the
// tasks can all be done: key from the dirt, 25 dishes, 25 shirts through washer, dryer and table.
@(test)
test_whole_game :: proc(t: ^testing.T) {
	for seed in u64(100) ..< 130 {
		w := new(World)
		defer free(w)
		fresh(w, seed)
		testing.expect(t, play_through(w), "finished")
		testing.expect_value(t, w.hero_room, Room.Last)
		testing.expect_value(t, w.score, i32(10 + 10 * TOTAL_DISHES + 10 * TOTAL_CLOTHES))
	}
}

// Picks up the item at (col,row) from whichever neighbour is free floor.
grab :: proc(w: ^World, room: Room, col, row: i32) -> bool {
	dirs := [4][2]i32{{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
	for d in dirs {
		sc, sr := col - d[0], row - d[1]
		s := cell(w, room, sc, sr)
		if s.terrain == .Floor && s.feature.kind == .None && s.item == .None && s.character != .Dust_Bunny {
			before := cell(w, room, col, row).item
			step_into(w, room, col, row, d[0], d[1])
			close_all(w)
			return cell(w, room, col, row).item == .None && before != .None
		}
	}
	return false
}

// Steps into the feature from a free neighbour. If every neighbour holds an item, one item is
// carried off to a free cell first (counts are kept), as a player would clear the way.
push_feature :: proc(w: ^World, room: Room, k: Feature_Kind) {
	col, row, _ := find_feature(w, room, k)
	dirs := [4][2]i32{{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
	for attempt in 0 ..< 2 {
		for d in dirs {
			s := cell(w, room, col - d[0], row - d[1])
			if s.terrain != .Floor || s.feature.kind != .None || s.character == .Dust_Bunny {
				continue
			}
			if s.item != .None && attempt == 1 {
				move_item_away(w, room, col - d[0], row - d[1])
			}
			if s.item == .None {
				step_into(w, room, col, row, d[0], d[1])
				close_all(w)
				return
			}
		}
	}
	panic("no way to reach the feature")
}

move_item_away :: proc(w: ^World, room: Room, col, row: i32) {
	for c in i32(6) ..< COLS - 5 {
		for r in i32(6) ..< ROWS - 5 {
			t := cell(w, room, c, r)
			if t.terrain == .Floor && t.item == .None && t.feature.kind == .None && t.character == .None {
				t.item = cell(w, room, col, row).item
				cell(w, room, col, row).item = .None
				return
			}
		}
	}
}

// Paces between two free cells so that n real moves pass (the machines count moves, not time).
wait_turns :: proc(w: ^World, room: Room, n: int) {
	open_cell :: proc(w: ^World, room: Room, col, row: i32) -> bool {
		c := cell(w, room, col, row)
		return c.terrain == .Floor && c.item == .None && c.feature.kind == .None && c.character == .None
	}
	found := false
	search: for row in i32(5) ..< ROWS - 4 {
		for col in i32(5) ..< COLS - 4 {
			if open_cell(w, room, col, row) && open_cell(w, room, col + 1, row) {
				put_hero(w, room, col, row)
				found = true
				break search
			}
		}
	}
	assert(found)
	target := w.moves + i32(n)
	for i := 0; w.moves < target; i += 1 {
		if i % 2 == 0 {move_right(w)} else {move_left(w)}
	}
	close_all(w)
}

play_through :: proc(w: ^World) -> bool {
	// Sweeping: the broom, then the key's pile, swept one cell.
	if !grab(w, .Sweeping, CENTER_X - 1, CENTER_Y) || !has_item(w, .Broom) {return false}
	kc, kr: i32
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			if cell(w, .Sweeping, col, row).feature.item == .Key {kc, kr = col, row}
		}
	}
	// Sweep the key's pile into the bin by moving it there directly (a fair stand-in for pushing it
	// around the room), then pick up the key it leaves behind.
	cell(w, .Sweeping, kc, kr).feature = {}
	cell(w, .Sweeping, kc, kr).item = .Key
	cell(w, .Sweeping, COLS - 2, ROWS - 1).feature = {kind = .Dirt_Pile, intensity = 1}
	step_into(w, .Sweeping, COLS - 2, ROWS - 1, 1, 0)
	if w.score != 10 {return false}
	if !grab(w, .Sweeping, kc, kr) || !has_item(w, .Key) {return false}
	// The door: clear anything in front of it, unlock it and walk through.
	cell(w, .Sweeping, COLS - 1, CENTER_Y).feature = {}
	cell(w, .Sweeping, COLS - 1, CENTER_Y).item = .None
	step_into(w, .Sweeping, COLS, CENTER_Y, 1, 0)
	move_right(w)
	if w.hero_room != .Dishes {return false}
	remove_item(w, .Broom)

	// Dishes: each one picked up, washed and put away.
	for col in i32(2) ..< COLS {
		for row in i32(2) ..< ROWS {
			if cell(w, .Dishes, col, row).item != .Dirty_Dish {continue}
			if !grab(w, .Dishes, col, row) {return false}
			push_feature(w, .Dishes, .Dish_Washer)
			push_feature(w, .Dishes, .Cupboard)
		}
	}
	if cell(w, .Dishes, COLS - 1, ROWS - 1).item != .Key {return false}
	if !grab(w, .Dishes, COLS - 1, ROWS - 1) {return false}
	step_into(w, .Dishes, CENTER_X, ROWS, 0, 1)
	move_up(w)
	if w.hero_room != .Laundry {return false}

	// Laundry: the basket, then batches of up to 9 shirts through washer, dryer, table and wardrobe.
	if !grab(w, .Laundry, CENTER_X, CENTER_Y) {return false}
	for guard := 0; count_in_room(w, .Laundry, .Soiled_Shirt) > 0; guard += 1 {
		if guard > 20 {return false}
		got := 0
		for col in i32(2) ..< COLS {
			for row in i32(2) ..< ROWS {
				if got < 9 && cell(w, .Laundry, col, row).item == .Soiled_Shirt {
					if grab(w, .Laundry, col, row) {got += 1}
				}
			}
		}
		push_feature(w, .Laundry, .Washing_Machine) // shirts in
		push_feature(w, .Laundry, .Soap_Dispenser)
		push_feature(w, .Laundry, .Washing_Machine) // soap in: washing
		wait_turns(w, .Laundry, MACHINE_TIMER)
		push_feature(w, .Laundry, .Washing_Machine) // wet shirts out
		push_feature(w, .Laundry, .Dryer)
		wait_turns(w, .Laundry, MACHINE_TIMER)
		push_feature(w, .Laundry, .Dryer) // dry shirts out
		for has_item(w, .Dry_Shirt) {push_feature(w, .Laundry, .Folding_Table)}
		for has_item(w, .Folded_Shirt) {push_feature(w, .Laundry, .Wardrobe)}
	}
	if total_shirts(w) != TOTAL_CLOTHES || count_in_room(w, .Laundry, .Key) != 1 {return false}
	for col in i32(2) ..< COLS {
		for row in i32(2) ..< ROWS {
			if cell(w, .Laundry, col, row).item == .Key {
				if !grab(w, .Laundry, col, row) {return false}
			}
		}
	}
	step_into(w, .Laundry, 1, CENTER_Y, -1, 0)
	move_left(w)
	if w.hero_room != .Last {return false}
	push_feature(w, .Last, .Sign)
	return true
}

// ---------------------------------------------------------------- fuzz: nothing is ever lost

@(test)
test_fuzz_conservation :: proc(t: ^testing.T) {
	r: Rng
	rng_seed(&r, 4242)
	items := []Item{.Broom, .Laundry_Basket, .Soap, .Dirty_Dish, .Clean_Dish, .Washed_Shirt, .Dry_Shirt}
	for seed in u64(1) ..= 40 {
		w := new(World)
		defer free(w)
		fresh(w, seed)
		for step in 0 ..< 2000 {
			close_all(w)
			if step % 50 == 0 {
				// Jump somewhere free, maybe carrying something useful, then wander.
				room := Room(rng_range(&r, 0, 3))
				col, row := i32(rng_range(&r, 2, COLS - 1)), i32(rng_range(&r, 2, ROWS - 1))
				c := cell(w, room, col, row)
				if c.character == .None && c.item == .None && c.feature.kind == .None {
					put_hero(w, room, col, row)
				}
				if step % 200 == 0 && w.inventory_count < INVENTORY_SIZE {
					it := items[rng_range(&r, 0, len(items) - 1)]
					// Conjured shirts or dishes would break the counts; only tools are handed out.
					if it == .Broom || it == .Laundry_Basket || it == .Soap {add_item(w, it)}
				}
			}
			switch rng_range(&r, 0, 3) {
			case 0:
				move_up(w)
			case 1:
				move_down(w)
			case 2:
				move_left(w)
			case 3:
				move_right(w)
			}
			if step % 10 != 0 {
				continue // the full-world checks are slow in a debug build
			}
			if total_shirts(w) != TOTAL_CLOTHES || total_dishes(w) != TOTAL_DISHES || !world_valid(w) {
				testing.expectf(t, false, "seed %d step %d: shirts %d dishes %d valid %v", seed, step, total_shirts(w), total_dishes(w), world_valid(w))
				return
			}
		}
	}
}

// ---------------------------------------------------------------- saves

@(test)
test_save_round_trip :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 51)
	add_item(w, .Broom)
	move_up(w)
	move_left(w)
	buf := make([]u8, SAVE_SIZE)
	defer delete(buf)
	n := save_encode(w, buf)
	testing.expect_value(t, n, SAVE_SIZE)
	back := new(World)
	defer free(back)
	testing.expect(t, save_decode(back, buf[:n]))
	testing.expect_value(t, back.hero_col, w.hero_col)
	testing.expect_value(t, back.moves, w.moves)
	testing.expect_value(t, back.inventory, w.inventory)
	testing.expect(t, back.cells == w.cells)

	buf[0] ~= 0xff // damaged
	testing.expect(t, !save_decode(back, buf[:n]))
	buf[0] ~= 0xff
	testing.expect(t, !save_decode(back, buf[:n - 1]), "short data refused")
	bad := w^
	bad.cells[.Laundry][3][3].feature.kind = Feature_Kind(200)
	testing.expect(t, !world_valid(&bad), "an impossible enum is refused")
}

@(test)
test_restart :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 61)
	add_item(w, .Broom)
	w.score = 99
	testing.expect_value(t, app_tap(w, 10, 70), Outcome.Changed)
	testing.expect_value(t, w.score, i32(0))
	testing.expect_value(t, w.inventory_count, i32(0))
	testing.expect_value(t, w.message_count, i32(0))
}

@(test)
test_tap_moves_towards :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)
	fresh(w, 71)
	clear_room_of(w, .Sweeping, .Dirt_Pile)
	clear_items(w, .Sweeping)
	put_hero(w, .Sweeping, 10, 10)
	app_tap(w, cell_x(20) + 3, cell_y(12) + 3) // to the right, a little up
	testing.expect_value(t, w.hero_col, i32(11))
	app_tap(w, cell_x(11) + 3, cell_y(3) + 3) // straight down
	testing.expect_value(t, w.hero_row, i32(9))
	testing.expect_value(t, app_tap(w, 10, 10), Outcome.Toggle_Mute)
}
