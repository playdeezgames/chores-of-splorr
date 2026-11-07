package chores

import "core:mem"

// The save is the World's bytes behind a small header (World is plain data). A save from
// another build (different version or size) or a damaged one is refused and a new house starts.
SAVE_MAGIC :: u32(0x524f4843) // "CHOR"

Save_Header :: struct {
	magic:   u32,
	version: u32,
	size:    u32,
}

SAVE_SIZE :: size_of(Save_Header) + size_of(World)

save_encode :: proc(w: ^World, buf: []u8) -> int {
	if len(buf) < SAVE_SIZE {
		return 0
	}
	h := Save_Header{SAVE_MAGIC, WORLD_VERSION, u32(size_of(World))}
	mem.copy(raw_data(buf), &h, size_of(h))
	copy := w^
	copy.sfx = {}
	copy.sfx_count = 0
	mem.copy(&buf[size_of(h)], &copy, size_of(World))
	return SAVE_SIZE
}

save_decode :: proc(w: ^World, data: []u8) -> bool {
	if len(data) != SAVE_SIZE {
		return false
	}
	h: Save_Header
	mem.copy(&h, raw_data(data), size_of(h))
	if h.magic != SAVE_MAGIC || h.version != WORLD_VERSION || h.size != u32(size_of(World)) {
		return false
	}
	loaded: World
	mem.copy(&loaded, &data[size_of(h)], size_of(World))
	if !world_valid(&loaded) {
		return false
	}
	w^ = loaded
	return true
}

// Every enum and count in range, and the hero where the world says.
world_valid :: proc(w: ^World) -> bool {
	if w.version != WORLD_VERSION || u8(w.hero_room) > u8(max(Room)) || !in_bounds(w.hero_col, w.hero_row) {
		return false
	}
	if w.inventory_count < 0 || w.inventory_count > INVENTORY_SIZE || w.message_count < 0 || w.message_count > MAX_MESSAGES {
		return false
	}
	for it in w.inventory {
		if u8(it) > u8(max(Item)) {
			return false
		}
	}
	for m in w.messages {
		if u8(m) > u8(max(Message)) {
			return false
		}
	}
	heroes := 0
	for room in Room {
		for col in 0 ..< COLS {
			for row in 0 ..< ROWS {
				c := &w.cells[room][col][row]
				if u8(c.terrain) > u8(max(Terrain)) || u8(c.item) > u8(max(Item)) || u8(c.character) > u8(max(Character)) || u8(c.bunny_item) > u8(max(Item)) {
					return false
				}
				f := c.feature
				if u8(f.kind) > u8(max(Feature_Kind)) || u8(f.state) > u8(max(Machine_State)) || u8(f.item) > u8(max(Item)) || u8(f.sign) > u8(max(Sign_Text)) {
					return false
				}
				if c.teleport.active && (u8(c.teleport.room) > u8(max(Room)) || !in_bounds(i32(c.teleport.col), i32(c.teleport.row))) {
					return false
				}
				if c.character == .Hero {
					heroes += 1
					if room != w.hero_room || i32(col + 1) != w.hero_col || i32(row + 1) != w.hero_row {
						return false
					}
				}
			}
		}
	}
	return heroes == 1
}
