module editor
fn (mut e Editor) handle_insert_text(key string) {
    mut line := ''
    if e.buffer.len > e.screen.cy {
        line = e.buffer[e.screen.cy]
    }

    if e.screen.cx > line.len {
        e.screen.cx = line.len
    }
    
    line = line[0 .. e.screen.cx] + key + line[e.screen.cx..]
    e.buffer[e.screen.cy] = line
}

fn (mut e Editor) handle_insert(raw u8, key string) {
    if e.buffer.len <= e.screen.cy {
        e.buffer << ""
    }

    match raw {
        27 {
            e.mode = 'normal'
            set_cursor_default()
            e.screen.cx--
        }
        10 {
            e.screen.cy++
            e.buffer.insert(e.screen.cy, '')
            e.screen.cx = 0
            e.normalize_scroll_top()
        }
        8 { // Backspace key
            if e.screen.cx > 0 {
                // Remove the character before the cursor
                mut line := e.buffer[e.screen.cy]
                line = line[..e.screen.cx - 1] + line[e.screen.cx..]
                e.buffer[e.screen.cy] = line
                e.screen.cx--
            } else if e.screen.cy > 0 {
                // Move to the end of the previous line
                e.screen.cy--
                e.screen.cx = e.buffer[e.screen.cy].len
                // Append the current line to the previous line
                e.buffer[e.screen.cy] += e.buffer[e.screen.cy + 1]
                // Remove the current line
                e.buffer.delete(e.screen.cy + 1)
            }
            e.message = "backspace pressed"
        }
        127 {
                e.message = "delete pressed"
                mut line := e.buffer[e.screen.cy]
                if e.screen.cx < line.len {
                    line = line[..e.screen.cx] + line[e.screen.cx + 1..]
                    e.buffer[e.screen.cy] = line
                } else if e.screen.cy < e.buffer.len - 1 {
                    e.buffer[e.screen.cy] += e.buffer[e.screen.cy + 1]
                    e.buffer.delete(e.screen.cy + 1)
                }
                e.message = line
            }
        else {
            e.handle_insert_text(key)
            e.screen.cx++
        }
    }
}


