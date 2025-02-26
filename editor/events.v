module editor

fn (mut e Editor) validate() {
    if e.main.buffer.len == 0 {
        e.main.buffer << ''
    }

    if e.main.cy < 0 {
        e.main.cy = 0
    }

    if e.main.cx < 0 {
        e.main.cx = 0
    }

    if e.main.cy >= e.main.buffer.len {
        e.main.cy = e.main.buffer.len
    }
    // validate
    if e.main.cx > e.main.buffer[e.main.cy].len {
         e.main.cx = e.main.buffer[e.main.cy].len
    }
}

pub fn (mut e Editor) loop() {
	for {
        if e.quit {
            break
        }

        raw := getch()
        key := rune(raw).str()

        if e.mode == 'insert' {
            e.handle_insert(raw, key)
        } else if e.mode == 'visual' {
            e.handle_visual(raw, key)
        } else if e.mode == 'command' {
            e.handle_command(raw, key)
        } else if e.mode == 'normal' {
            e.handle_normal(raw, key)
        }
        e.validate()
        e.render()
	}
}


