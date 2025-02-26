module editor

fn (mut e Editor) handle_insert_text(key string) {
	mut line := ''
	if e.buffer.len > e.active_pane.cy {
		line = e.buffer[e.active_pane.cy]
	}

	if e.active_pane.cx > line.len {
		e.active_pane.cx = line.len
	}

	line = line[0..e.active_pane.cx] + key + line[e.active_pane.cx..]
	e.buffer[e.active_pane.cy] = line
}

fn (mut e Editor) handle_insert(raw int, key string) {
	if e.buffer.len <= e.active_pane.cy {
		e.buffer << ''
	}

	match raw {
		27 {
			e.mode = 'normal'
			set_cursor_default()
			e.active_pane.cx--
		}
		10 {
			e.main.buffer.insert(e.main.cy + 1, e.main.buffer[e.main.cy][e.main.cx..])
			e.main.buffer[e.main.cy] = e.main.buffer[e.main.cy][0..e.main.cx]
			e.main.cy++
			e.main.cx = 0
		}
		2 {
			e.toggle_sidebar()
		}
		// 10 {
		//    e.toggle_terminal()
		//}
		-8 { // Backspace key
			if e.active_pane.cx > 0 {
				// Remove the character before the cursor
				mut line := e.buffer[e.active_pane.cy]
				line = line[..e.active_pane.cx - 1] + line[e.active_pane.cx..]
				e.buffer[e.active_pane.cy] = line
				e.active_pane.cx--
			} else if e.active_pane.cy > 0 {
				// Move to the end of the previous line
				e.active_pane.cy--
				e.active_pane.cx = e.buffer[e.active_pane.cy].len
				// Append the current line to the previous line
				e.buffer[e.active_pane.cy] += e.buffer[e.active_pane.cy + 1]
				// Remove the current line
				e.buffer.delete(e.active_pane.cy + 1)
			}
		}
		127 {
			mut line := e.buffer[e.active_pane.cy]
			if e.active_pane.cx < line.len {
				line = line[..e.active_pane.cx] + line[e.active_pane.cx + 1..]
				e.buffer[e.active_pane.cy] = line
			} else if e.active_pane.cy < e.buffer.len - 1 {
				e.buffer[e.active_pane.cy] += e.buffer[e.active_pane.cy + 1]
				e.buffer.delete(e.active_pane.cy + 1)
			}
			e.message = line
		}
		else {
			e.handle_insert_text(key)
			e.active_pane.cx++
		}
	}
}
