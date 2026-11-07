#+build js
package chores

import "base:runtime"

foreign import host "env"

@(default_calling_convention = "contextless")
foreign host {
	draw_rect :: proc(x, y, w, h: i32, color: u32) ---
	draw_tile :: proc(tile, x, y: i32) ---
	draw_text :: proc(ptr: [^]u8, len: i32, x, y: i32, color: u32) ---
	draw_icon :: proc(icon, x, y, w, h: i32) ---
	play_sfx :: proc(sfx: i32) ---
	// Milliseconds since the epoch: the RNG seed and the machines' animation clock.
	now_ms :: proc() -> f64 ---
	// Saved game (localStorage). storage_get returns the byte length, or -1 for none.
	storage_get :: proc(buf: [^]u8, cap: i32) -> i32 ---
	storage_set :: proc(ptr: [^]u8, len: i32) ---
	// The page keeps the mute setting (its own localStorage key, as the original kept a config file).
	is_muted :: proc() -> bool ---
	toggle_mute :: proc() ---
}

@(private = "file")
world: World
@(private = "file")
dirty: bool
@(private = "file")
last_frame: int = -1
@(private = "file")
save_buf: [SAVE_SIZE]u8
@(private = "file")
draws: [dynamic]Draw

main :: proc() {
	n := storage_get(raw_data(save_buf[:]), len(save_buf))
	if n <= 0 || !save_decode(&world, save_buf[:n]) {
		seed := u64(now_ms())
		new_world(&world, seed ~ 0x5eed_c40e5)
		persist()
	}
	dirty = true
}

// odin.js calls this every animation frame.
@(export)
step :: proc(dt: f64) -> bool {
	context = runtime.default_context()
	frame := int(now_ms() / 125)
	if view_animating(&world) && frame != last_frame {
		dirty = true
	}
	if !dirty {
		return true
	}
	last_frame = frame
	view_draw(&world, is_muted(), frame, &draws)
	for d in draws {
		switch d.kind {
		case .Rect:
			draw_rect(d.x, d.y, d.w, d.h, d.color)
		case .Tile:
			draw_tile(d.tile, d.x, d.y)
		case .Text:
			draw_text(raw_data(d.text), i32(len(d.text)), d.x, d.y, d.color)
		case .Icon:
			draw_icon(d.tile, d.x, d.y, d.w, d.h)
		}
	}
	free_all(context.temp_allocator)
	dirty = false
	return true
}

@(export)
on_key :: proc "c" (key: i32) {
	context = runtime.default_context()
	if key < 0 || key > i32(max(Key)) {
		return
	}
	after(app_key(&world, Key(key)))
}

// Logical screen coordinates (0..479, 0..319).
@(export)
on_tap :: proc "c" (x, y: i32) {
	context = runtime.default_context()
	after(app_tap(&world, x, y))
}

@(private = "file")
after :: proc(o: Outcome) {
	switch o {
	case .None:
	case .Toggle_Mute:
		toggle_mute()
		dirty = true
	case .Changed:
		if !is_muted() {
			for s in world.sfx[:world.sfx_count] {
				play_sfx(i32(s))
			}
		}
		world.sfx_count = 0
		persist()
		dirty = true
	}
}

@(private = "file")
persist :: proc() {
	n := save_encode(&world, save_buf[:])
	if n > 0 {
		storage_set(raw_data(save_buf[:]), i32(n))
	}
}
