module editor

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
        'v' {
            e.mode = 'visual'
        }
        'j' {
            if e.screen.cy < e.buffer.len && e.screen.cy < e.screen.h {
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
        'O' {
            // add new line to buffer
        }
        'o' {
            // add new line to buffer
        }
        ':' {
            e.mode = 'command'
            e.command = ":"
            // term.set_cursor_position(x: 0, y: e.screen.h -1)
        }
        'q' {
            e.quit = true
        }
        else { }
    }
}

