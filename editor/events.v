module editor

fn (mut e Editor) validate() {
    if e.buffer.len == 0 {
        e.buffer << ''

    }
    if e.active_pane.cy < 0 {
        e.active_pane.cy = 0
    }

    if e.active_pane.cx < 0 {
        e.active_pane.cx = 0
    }

    if e.active_pane.cy >= e.buffer.len {
        e.active_pane.cy = e.buffer.len
    }
    // validate
    if e.active_pane.cx > e.buffer[e.active_pane.cy].len {
         e.active_pane.cx = e.buffer[e.active_pane.cy].len
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


