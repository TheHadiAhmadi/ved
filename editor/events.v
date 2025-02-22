module editor

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
        e.render()
	}
}


