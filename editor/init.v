module editor

import term

struct Screen {
mut: 
    cx int
    cy int
    w int
    h int
    st int
}

struct Editor {
mut:
    buffer []string
    screen Screen
    mode string
    filename string
    command string
    message string
    status_left string
    status_right string
    quit bool
}

fn (mut e Editor) quit() {
    e.quit = true
    reset_terminal()
}

pub fn initialize() {
    prepare_terminal()
	defer {
        reset_terminal()
	}

	width, height := term.get_terminal_size()
    mut e := Editor{}
    e.quit = false
    e.mode = 'normal'
    e.screen = Screen{0, 0, width, height - 2, 0}

    e.render()
    e.loop()
}

