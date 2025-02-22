module editor

fn (mut e Editor) validate() {
    if e.buffer.len == 0 {
        e.buffer << ''

    }
    if e.screen.cy < 0 {
        e.screen.cy = 0
    }

    if e.screen.cx < 0 {
        e.screen.cx = 0
    }

    if e.screen.cy >= e.buffer.len {
        e.screen.cy = e.buffer.len
    }
    // validate
    if e.screen.cx > e.buffer[e.screen.cy].len {
        e.screen.cx = e.buffer[e.screen.cy].len
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


