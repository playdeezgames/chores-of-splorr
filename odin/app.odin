package chores

// Input, kept apart from the platform so tests can drive it.
// Keys are mapped by the page: arrows, WASD and ZQSD move; Space, Enter or Escape close a message.
Key :: enum i32 {
	None  = 0,
	Up    = 1,
	Down  = 2,
	Left  = 3,
	Right = 4,
	Close = 5,
	Mute  = 6,
}

Outcome :: enum u8 {
	None,
	Changed,
	Toggle_Mute,
}

app_key :: proc(w: ^World, key: Key) -> Outcome {
	w.sfx_count = 0
	if w.message_count > 0 {
		if key == .Close {
			close_message(w)
			return .Changed
		}
		return key == .Mute ? .Toggle_Mute : .None
	}
	switch key {
	case .None, .Close:
		return .None
	case .Up:
		move_up(w)
	case .Down:
		move_down(w)
	case .Left:
		move_left(w)
	case .Right:
		move_right(w)
	case .Mute:
		return .Toggle_Mute
	}
	return .Changed
}

@(private = "file")
inside :: proc(r: [4]i32, x, y: i32) -> bool {
	return x >= r[0] && x < r[0] + r[2] && y >= r[1] && y < r[1] + r[3]
}

// A click or tap at logical screen coordinates (0..479, 0..319).
// The buttons work as in the original; a tap on the room steps once towards it (new for phones).
app_tap :: proc(w: ^World, x, y: i32) -> Outcome {
	w.sfx_count = 0
	if w.message_count > 0 {
		close_message(w)
		return .Changed
	}
	if inside(MUTE_RECT, x, y) {
		return .Toggle_Mute
	}
	if inside(RESTART_RECT, x, y) {
		restart(w)
		return .Changed
	}
	if x < BOARD_X || x >= BOARD_X + COLS * TILE || y < BOARD_Y || y >= BOARD_Y + ROWS * TILE {
		return .None
	}
	col := (x - BOARD_X) / TILE + 1
	row := ROWS - (y - BOARD_Y) / TILE
	dc, dr := col - w.hero_col, row - w.hero_row
	if dc == 0 && dr == 0 {
		return .None
	}
	if abs(dc) >= abs(dr) {
		move_avatar(w, dc > 0 ? 1 : -1, 0)
	} else {
		move_avatar(w, 0, dr > 0 ? 1 : -1)
	}
	return .Changed
}
