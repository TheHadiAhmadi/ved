module editor

import os
import term

struct Screen {
mut:
	w  int
	h  int
}

struct Pane {
mut:
	x     int
	y     int
	w     int
	h     int
	lines []string
	cx    int
	cy    int
	st    int
}

struct Editor {
mut:
	buffer       []string
	sidebar      Pane
	terminal     Pane
	main         Pane
	active_pane  &Pane
	screen       Screen
	mode         string
	filename     string
	command      string
	message      string
	status_left  string
	status_right string
	quit         bool
}

fn (mut e Editor) quit() {
	e.quit = true
	reset_terminal()
}

fn load_file_tree() []string {
	return ['line 1 of sidebar', 'line 2 of sidebar']
}

pub fn initialize() {
	prepare_terminal()
	defer {
		reset_terminal()
	}

	sidebar_width := 30
	terminal_height := 10
	status_height := 2

	width, height := term.get_terminal_size()
	mut sidebar := Pane{0, 0, sidebar_width, height - status_height, [], 0, 0, 0}
	mut main := Pane{sidebar_width, 0, width - sidebar_width, height - status_height - terminal_height, [], 0, 0, 0}
	mut terminal := Pane{sidebar_width, height - status_height - terminal_height, width - sidebar_width, terminal_height, [], 0, 0, 0}
	sidebar.lines = load_file_tree()

	mut e := Editor{
		main:        main
		sidebar:     sidebar
		terminal:    terminal
		active_pane: &main
	}
	e.quit = false
	e.mode = 'normal'
	e.screen = Screen{width, height}

	e.render()
	e.loop()
}
