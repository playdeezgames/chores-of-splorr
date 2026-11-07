package chores

import "core:fmt"
import "core:strings"

// The original's screen: 480 by 320 logical pixels (shown at 960 by 640), 12-pixel tiles.
SCREEN_W :: 480
SCREEN_H :: 320
TILE :: 12
BOARD_X :: 90
BOARD_Y :: 10
INVENTORY_X :: 21
INVENTORY_Y :: 262
INVENTORY_COLS :: 4
PANEL_X :: 435 // centre of the right-hand labels
GLYPH_W :: 6 // DINOBYTE
GLYPH_H :: 8
LINE_H :: 9
MESSAGE_W :: 300
MESSAGE_CHARS :: 48
CLOSE_HINT :: "<SPACE> or tap to close."

// Tile numbers are the original's (1-based, 16 to a row of the 192 by 192 sheet).
TILE_FLOOR :: 1
TILE_WALL :: 2
TILE_HERO :: 3
TILE_OPEN_DOOR :: 5
TILE_CLOSED_DOOR :: 6
TILE_DUST_BUNNY :: 11
INTENSITY_TILE_START :: 245 // + intensity gives the digit

Icon :: enum u8 {
	Speaker,
	Speaker_Off,
	Restart,
}

MUTE_RECT :: [4]i32{0, 0, 32, 32}
RESTART_RECT :: [4]i32{0, 64, 32, 32}

Draw_Kind :: enum u8 {
	Tile,
	Rect,
	Text,
	Icon,
}

Draw :: struct {
	kind:       Draw_Kind,
	tile:       i32, // tile number, or Icon
	x, y, w, h: i32,
	color:      u32, // 0xRRGGBB
	text:       string,
}

COLOR_BACKGROUND :: 0x000000
COLOR_TEXT :: 0xffffff
COLOR_MESSAGE_BOX :: 0xefddf2 // the original's box colour (0.937, 0.867, 0.949)
COLOR_MESSAGE_TEXT :: 0x000000

terrain_tile :: proc(t: Terrain) -> i32 {
	switch t {
	case .Floor:
		return TILE_FLOOR
	case .Wall:
		return TILE_WALL
	case .Open_Door:
		return TILE_OPEN_DOOR
	case .Closed_Door:
		return TILE_CLOSED_DOOR
	}
	return 0
}

item_tile :: proc(it: Item) -> i32 {
	switch it {
	case .None:
		return 0
	case .Key:
		return 4
	case .Broom:
		return 8
	case .Dirty_Dish:
		return 13
	case .Clean_Dish:
		return 14
	case .Laundry_Basket:
		return 18
	case .Soiled_Shirt:
		return 19
	case .Washed_Shirt:
		return 20
	case .Dry_Shirt:
		return 21
	case .Folded_Shirt:
		return 22
	case .Soap:
		return 23
	}
	return 0
}

// frame: animation frame for running machines (the page advances it a few times a second).
feature_tile :: proc(f: Feature, frame: int) -> i32 {
	switch f.kind {
	case .None:
		return 0
	case .Dirt_Pile:
		return 7
	case .Dust_Bin:
		return 9
	case .Sign:
		return 10
	case .Dish_Washer:
		return 12
	case .Cupboard, .Wardrobe:
		return 15
	case .Soap_Dispenser:
		return 17
	case .Folding_Table:
		return 24
	case .Washing_Machine:
		if f.state == .Washing {
			return 35 + i32(frame % 4)
		}
		return f.intensity > 0 ? 34 : 33
	case .Dryer:
		#partial switch f.state {
		case .Drying:
			return 51 + i32(frame % 4)
		case .Dry:
			return 50
		}
		return 49
	}
	return 0
}

cell_x :: proc(col: i32) -> i32 {return BOARD_X + (col - 1) * TILE}
cell_y :: proc(row: i32) -> i32 {return BOARD_Y + (ROWS - row) * TILE}

@(private = "file")
tile_at :: proc(out: ^[dynamic]Draw, tile, x, y: i32) {
	if tile != 0 {
		append(out, Draw{kind = .Tile, tile = tile, x = x, y = y, w = TILE, h = TILE})
	}
}

@(private = "file")
text_at :: proc(out: ^[dynamic]Draw, s: string, x, y: i32, color: u32) {
	append(out, Draw{kind = .Text, text = s, x = x, y = y, color = color})
}

@(private = "file")
centered :: proc(out: ^[dynamic]Draw, s: string, cx, y: i32, color: u32) {
	text_at(out, s, cx - i32(len(s)) * GLYPH_W / 2, y, color)
}

// Breaks the message into lines of at most MESSAGE_CHARS, at spaces; blank lines are kept.
wrap_lines :: proc(text: string, allocator := context.temp_allocator) -> [dynamic]string {
	lines := make([dynamic]string, allocator)
	for raw in strings.split_lines(text, allocator) {
		line := strings.trim_right_space(raw)
		for len(line) > MESSAGE_CHARS {
			cut := strings.last_index_byte(line[:MESSAGE_CHARS + 1], ' ')
			if cut <= 0 {
				cut = MESSAGE_CHARS
			}
			append(&lines, line[:cut])
			line = strings.trim_left_space(line[cut:])
		}
		append(&lines, line)
	}
	return lines
}

// The original added "<SPACE> to close." to every message (the welcome had it written in).
message_text :: proc(m: Message, allocator := context.temp_allocator) -> string {
	return strings.concatenate({MESSAGE_TEXT[m], "\n\n", CLOSE_HINT}, allocator)
}

message_rect :: proc(line_count: int) -> [4]i32 {
	h := i32(line_count) * LINE_H + 16
	return {(SCREEN_W - MESSAGE_W) / 2, (SCREEN_H - h) / 2, MESSAGE_W, h}
}

// Builds the whole screen. Strings are in the temp allocator.
view_draw :: proc(w: ^World, muted: bool, frame: int, out: ^[dynamic]Draw) {
	clear(out)
	append(out, Draw{kind = .Rect, x = 0, y = 0, w = SCREEN_W, h = SCREEN_H, color = COLOR_BACKGROUND})

	// The room, in the original's layer order: terrain, item, feature, character, intensity.
	room := w.hero_room
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			c := cell(w, room, col, row)
			x, y := cell_x(col), cell_y(row)
			tile_at(out, terrain_tile(c.terrain), x, y)
			tile_at(out, item_tile(c.item), x, y)
			tile_at(out, feature_tile(c.feature, frame), x, y)
			switch c.character {
			case .None:
			case .Hero:
				tile_at(out, TILE_HERO, x, y)
			case .Dust_Bunny:
				tile_at(out, TILE_DUST_BUNNY, x, y)
			}
			if c.feature.kind != .None && c.feature.intensity > 1 && c.feature.intensity <= 9 {
				tile_at(out, INTENSITY_TILE_START + i32(c.feature.intensity), x, y)
			}
		}
	}

	// Inventory: 4 by 4, filled from the bottom-left, left to right, upwards.
	for i in i32(0) ..< w.inventory_count {
		x := INVENTORY_X + (i % INVENTORY_COLS) * TILE
		y := INVENTORY_Y + (3 - i / INVENTORY_COLS) * TILE
		tile_at(out, item_tile(w.inventory[i]), x, y)
	}

	// Labels
	centered(out, "Move:", PANEL_X, 26, COLOR_TEXT)
	centered(out, "ARROWS", PANEL_X, 36, COLOR_TEXT)
	centered(out, "WASD", PANEL_X, 46, COLOR_TEXT)
	centered(out, "ZQSD", PANEL_X, 56, COLOR_TEXT)
	centered(out, fmt.tprintf("Score: %d", w.score), PANEL_X, 282, COLOR_TEXT)
	centered(out, fmt.tprintf("Moves: %d", w.moves), PANEL_X, 298, COLOR_TEXT)

	// Buttons
	m := MUTE_RECT
	append(out, Draw{kind = .Icon, tile = i32(muted ? Icon.Speaker_Off : Icon.Speaker), x = m[0], y = m[1], w = m[2], h = m[3]})
	r := RESTART_RECT
	append(out, Draw{kind = .Icon, tile = i32(Icon.Restart), x = r[0], y = r[1], w = r[2], h = r[3]})

	// The message box, over everything
	if msg := current_message(w); msg != .None {
		lines := wrap_lines(message_text(msg))
		box := message_rect(len(lines))
		append(out, Draw{kind = .Rect, x = box[0], y = box[1], w = box[2], h = box[3], color = COLOR_MESSAGE_BOX})
		for line, i in lines {
			centered(out, line, SCREEN_W / 2, box[1] + 8 + i32(i) * LINE_H, COLOR_MESSAGE_TEXT)
		}
	}
}

// Anything animating (a running machine in this room) needs frames redrawn.
view_animating :: proc(w: ^World) -> bool {
	for col in i32(1) ..= COLS {
		for row in i32(1) ..= ROWS {
			f := cell(w, w.hero_room, col, row).feature
			if (f.kind == .Washing_Machine && f.state == .Washing) || (f.kind == .Dryer && f.state == .Drying) {
				return true
			}
		}
	}
	return false
}
