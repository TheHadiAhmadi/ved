module editor

fn isalpha(s string) bool {
    return (s >= 'a' && s <= 'z') || (s >= 'A' && s <= 'Z') || (s >= '0' && s <= '9') || (s == '_')

}

fn (mut e Editor) handle_normal(raw u8, key string) {
	match key {
		'a' {
			e.mode = 'insert'
			e.active_pane.cx++
			set_cursor_bar()
		}
		'i' {
			e.mode = 'insert'
			set_cursor_bar()
		}
        'd' {
            raw2 := getch()
            key2 := rune(raw2).str()

            if key2 == 'd' {
                e.buffer.delete(e.active_pane.cy)
            } else {
                e.handle_normal(raw2, key2)
            }
        }
        'H' {
            e.active_pane = &e.sidebar
            raw2 := getch()
            key2 := rune(raw2).str()

            if key2 == 'H' {
                e.sidebar.w-=2
                e.main.w+=2
                e.main.x-=2
            } else {
                // e.handle_normal(raw2, key2)
            }
        }
        'L' {
            e.active_pane = &e.main
            raw2 := getch()
            key2 := rune(raw2).str()

            if key2 == 'L' {
                e.sidebar.w+=2
                e.main.w-=2
                e.main.x+=2
            } else {
                // e.handle_normal(raw2, key2)
            }
        }
        'g' {
            raw2 := getch()
            key2 := rune(raw2).str()

            if key2 == 'g' {
                e.active_pane.cy = 0
                e.normalize_scroll_top()
            } else {
                e.handle_normal(raw2, key2)
            }

        }
		'x' {
            if e.buffer[e.active_pane.cy].len > 0 && e.active_pane.cx < e.buffer[e.active_pane.cy].len {
                e.buffer[e.active_pane.cy] = e.buffer[e.active_pane.cy][0..e.active_pane.cx] +
                    e.buffer[e.active_pane.cy][e.active_pane.cx + 1..]
                if e.active_pane.cx == e.buffer[e.active_pane.cy].len {
                    e.active_pane.cx = e.buffer[e.active_pane.cy].len - 1
                }
            }
		}
		'X' {
            if e.buffer[e.active_pane.cy].len > 1 && e.active_pane.cx > 0 {
                e.buffer[e.active_pane.cy] = e.buffer[e.active_pane.cy][0..e.active_pane.cx - 1] +
                    e.buffer[e.active_pane.cy][e.active_pane.cx..]
                e.active_pane.cx--
            }
		}
		'^' {
			e.active_pane.cx = 0
		}
		'$' {
			e.active_pane.cx = e.buffer[e.active_pane.cy].len
		}
        'w' {

            e.normalize_scroll_top()
            // next word
        }
        'b' {
            e.normalize_scroll_top()
            // previous word
        }
		'v' {
			e.mode = 'visual'
		}
		'u' {
			// undo
		}
		'r' {
			// replace
		}
		'j' {
			if e.active_pane.cy < e.buffer.len - 1 {
				e.active_pane.cy++
                e.normalize_scroll_top()
			}
		}
		'k' {
			if e.active_pane.cy > 0 {
				e.active_pane.cy--
                e.normalize_scroll_top()
			}
		}
		'l' {
			if e.active_pane.cx < e.active_pane.w {
				e.active_pane.cx++
			}
		}
		'h' {
			if e.active_pane.cx > 0 {
				e.active_pane.cx--
			}
		}
		'G' {
			e.active_pane.cy = e.buffer.len - 1
            e.normalize_scroll_top()
		}
		'O' {
			// add new line to buffer
			e.mode = 'insert'
			set_cursor_bar()
			e.buffer.insert(e.active_pane.cy, '')
            e.normalize_scroll_top()
		}
		'o' {
			// add new line to buffer
			e.mode = 'insert'
			set_cursor_bar()
			e.buffer.insert(e.active_pane.cy + 1, '')
            e.active_pane.cy++
            e.normalize_scroll_top()
		}
		':' {
			e.mode = 'command'
			e.command = ':'
			// term.set_cursor_position(x: 0, y: e.active_pane.h -1)
		}
		'q' {
			e.quit = true
		}
		else {}
	}
}
