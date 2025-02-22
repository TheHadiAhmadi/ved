module editor

fn (mut e Editor) handle_insert_text(key string) {
    mut line := ''
    if e.buffer.len > e.screen.cy {
        line = e.buffer[e.screen.cy]
    }
    
    line = line[0 .. e.screen.cx - 1] + key + line[e.screen.cx - 1..]
    e.buffer[e.screen.cy] =line
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
            e.screen.cx = 0
        }
        8 {
            e.screen.cx--
            // line = line[..line.len -1]
            // backspace

        }
        else {
            e.handle_insert_text(key)
            e.screen.cx++
        }
    }
    //
}


