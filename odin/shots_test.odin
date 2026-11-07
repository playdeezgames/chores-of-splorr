#+build !js
package chores

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"

// Dumps the draw commands of a few real game states to build/shots/*.txt, for
// tools/make_shots.sh to render into the itch.io screenshots. Runs with the other tests.
dump_shot :: proc(w: ^World, name: string, frame := 0) {
	draws: [dynamic]Draw
	defer delete(draws)
	view_draw(w, false, frame, &draws)
	b := strings.builder_make()
	defer strings.builder_destroy(&b)
	for d in draws {
		switch d.kind {
		case .Rect:
			fmt.sbprintf(&b, "R %d %d %d %d %06x\n", d.x, d.y, d.w, d.h, d.color)
		case .Tile:
			fmt.sbprintf(&b, "T %d %d %d\n", d.tile, d.x, d.y)
		case .Icon:
			fmt.sbprintf(&b, "I %d %d %d %d %d\n", d.tile, d.x, d.y, d.w, d.h)
		case .Text:
			fmt.sbprintf(&b, "S %d %d %06x %s\n", d.x, d.y, d.color, d.text)
		}
	}
	os.make_directory("build/shots")
	path := fmt.tprintf("build/shots/%s.txt", name)
	_ = os.write_entire_file(path, transmute([]u8)strings.to_string(b))
	free_all(context.temp_allocator)
}

@(test)
test_dump_shots :: proc(t: ^testing.T) {
	w := new(World)
	defer free(w)

	// The cover's source (tools/make_cover.py): the first room as you find it.
	new_world(w, 20250121)
	close_all(w)
	dump_shot(w, "cover")

	// 1: the welcome
	new_world(w, 20250121)
	dump_shot(w, "1-welcome")

	// 2: sweeping, a few piles pushed together, one dust bunny loose
	close_all(w)
	move_left(w) // the broom
	close_all(w)
	for _ in 0 ..< 3 {move_up(w)}
	for _ in 0 ..< 4 {move_right(w)}
	for _ in 0 ..< 6 {move_down(w)}
	for _ in 0 ..< 3 {move_left(w)}
	close_all(w)
	clear_room_of(w, .Sweeping, .Dirt_Pile)
	cell(w, .Sweeping, 6, 9).feature = {kind = .Dirt_Pile, intensity = 4}
	cell(w, .Sweeping, 17, 18).feature = {kind = .Dirt_Pile, intensity = 7}
	cell(w, .Sweeping, 8, 20).feature = {kind = .Dirt_Pile, intensity = 1}
	cell(w, .Sweeping, 19, 6).feature = {kind = .Dirt_Pile, intensity = 2}
	cell(w, .Sweeping, 9, 9).feature = {kind = .Dirt_Pile, intensity = 9}
	cell(w, .Sweeping, 10, 9).feature = {kind = .Dirt_Pile, intensity = 3}
	step_into(w, .Sweeping, 10, 9, -1, 0) // 9 + 3: a dust bunny
	close_all(w)
	put_hero(w, .Sweeping, 15, 12)
	move_up(w)
	move_up(w)
	dump_shot(w, "2-sweeping")

	// 3: the dust bunny's arrival
	cell(w, .Sweeping, 12, 15).feature = {kind = .Dirt_Pile, intensity = 6}
	cell(w, .Sweeping, 13, 15).feature = {kind = .Dirt_Pile, intensity = 5}
	step_into(w, .Sweeping, 13, 15, -1, 0)
	dump_shot(w, "3-dust-bunny")
	close_all(w)

	// 4: dishes, carrying a few
	clear_room_of(w, .Sweeping, .Dirt_Pile)
	cell(w, .Sweeping, COLS - 1, CENTER_Y).item = .None
	add_item(w, .Key)
	step_into(w, .Sweeping, COLS, CENTER_Y, 1, 0)
	move_right(w)
	got := 0
	for col in i32(2) ..< COLS {
		for row in i32(2) ..< ROWS {
			if got < 5 && cell(w, .Dishes, col, row).item == .Dirty_Dish {
				if grab(w, .Dishes, col, row) {got += 1}
			}
		}
	}
	push_feature(w, .Dishes, .Dish_Washer)
	push_feature(w, .Dishes, .Dish_Washer)
	put_hero(w, .Dishes, 18, 6)
	w.score = 60
	dump_shot(w, "4-dishes")

	// 5: laundry, the washer running and the dryer full
	remove_item(w, .Broom)
	for has_item(w, .Dirty_Dish) {remove_item(w, .Dirty_Dish)}
	for has_item(w, .Clean_Dish) {remove_item(w, .Clean_Dish)}
	put_hero(w, .Laundry, CENTER_X, 2)
	grab(w, .Laundry, CENTER_X, CENTER_Y)
	got = 0
	for col in i32(2) ..< COLS {
		for row in i32(2) ..< ROWS {
			if got < 7 && cell(w, .Laundry, col, row).item == .Soiled_Shirt {
				if grab(w, .Laundry, col, row) {got += 1}
			}
		}
	}
	push_feature(w, .Laundry, .Washing_Machine)
	push_feature(w, .Laundry, .Soap_Dispenser)
	push_feature(w, .Laundry, .Washing_Machine)
	for _ in 0 ..< 2 {
		if c, r, ok := find_feature(w, .Laundry, .Dryer); ok {
			cell(w, .Laundry, c, r).feature.intensity = 6
			cell(w, .Laundry, c, r).feature.state = .Drying
			cell(w, .Laundry, c, r).feature.timer = 12
		}
	}
	for _ in 0 ..< 3 {grab_any_shirt(w)}
	put_hero(w, .Laundry, 6, 5)
	w.score = 310
	w.moves = 1288
	dump_shot(w, "5-laundry", 2)

	// 6: done
	put_hero(w, .Last, CENTER_X, CENTER_Y - 1)
	w.score = 510
	w.moves = 2417
	for w.inventory_count > 0 {remove_item(w, w.inventory[0])}
	add_item(w, .Laundry_Basket)
	add_item(w, .Soap)
	move_up(w)
	dump_shot(w, "6-done")
}

grab_any_shirt :: proc(w: ^World) {
	for col in i32(2) ..< COLS {
		for row in i32(2) ..< ROWS {
			if cell(w, .Laundry, col, row).item == .Soiled_Shirt && grab(w, .Laundry, col, row) {
				return
			}
		}
	}
}
