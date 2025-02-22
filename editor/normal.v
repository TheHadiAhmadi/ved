module editor

fn isalpha(s string) bool {
    return (s >= 'a' && s <= 'z') || (s >= 'A' && s <= 'Z') || (s >= '0' && s <= '9') || (s == '_')

}

fn (mut e Editor) handle_normal(raw u8, key string) {
	match key {
		'a' {
			e.mode = 'insert'
			e.screen.cx++
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
                e.buffer.delete(e.screen.cy)
            } else {
                e.handle_normal(raw2, key2)
            }
        }
        'g' {
            raw2 := getch()
            key2 := rune(raw2).str()

            if key2 == 'g' {
                e.screen.cy = 0
            } else {
                e.handle_normal(raw2, key2)
            }

        }
		'x' {
            if e.buffer[e.screen.cy].len > 0 && e.screen.cx < e.buffer[e.screen.cy].len {
                e.buffer[e.screen.cy] = e.buffer[e.screen.cy][0..e.screen.cx] +
                    e.buffer[e.screen.cy][e.screen.cx + 1..]
                if e.screen.cx == e.buffer[e.screen.cy].len {
                    e.screen.cx = e.buffer[e.screen.cy].len - 1
                }
            }
		}
		'X' {
            if e.buffer[e.screen.cy].len > 1 && e.screen.cx > 0 {
                e.buffer[e.screen.cy] = e.buffer[e.screen.cy][0..e.screen.cx - 1] +
                    e.buffer[e.screen.cy][e.screen.cx..]
                e.screen.cx--
            }
		}
		'^' {
			e.screen.cx = 0
		}
		'$' {
			e.screen.cx = e.buffer[e.screen.cy].len
		}
        'w' {

            // next word
        }
        'b' {
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
			if e.screen.cy < e.buffer.len - 1 {
				e.screen.cy++
			}
		}
		'k' {
			if e.screen.cy > 0 {
				e.screen.cy--
			}
		}
		'l' {
			if e.screen.cx < e.screen.w {
				e.screen.cx++
			}
		}
		'h' {
			if e.screen.cx > 0 {
				e.screen.cx--
			}
		}
		'G' {
			e.screen.cy = e.buffer.len - 1
		}
		'O' {
			// add new line to buffer
			e.mode = 'insert'
			set_cursor_bar()
			e.buffer.insert(e.screen.cy, '')
		}
		'o' {
			// add new line to buffer
			e.mode = 'insert'
			set_cursor_bar()
			e.buffer.insert(e.screen.cy + 1, '')
            e.screen.cy++
		}
		':' {
			e.mode = 'command'
			e.command = ':'
			// term.set_cursor_position(x: 0, y: e.screen.h -1)
		}
		'q' {
			e.quit = true
		}
		else {}
	}
}
