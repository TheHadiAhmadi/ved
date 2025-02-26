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
    name  string
	x     int
	y     int
	w     int
	h     int
	buffer []string
    visible bool
	cx    int
	cy    int
	st    int
}

struct Editor {
mut:
	buffer       []string
    file_tree    SidebarItem
    file_tree_map    map[string]SidebarItem
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

struct SidebarItem {
mut: 
    is_dir bool
    name string
    path string
    is_collapsed bool
    is_root bool
    children []&SidebarItem
}

struct Sidebar {
mut: 
    root &SidebarItem
}

fn load_file_tree(path string) SidebarItem {
     mut item := SidebarItem{
        is_dir: os.is_dir(path)
        name: os.base(path)
        path: path
        is_collapsed: true
        is_root: false
        children: []
    }

    if item.is_dir {
        entries := os.ls(path) or { return item }
        for entry in entries {
            full_path := os.join_path(path, entry)
            if os.is_dir(full_path) {
                child_item := load_file_tree(full_path)
                item.children << &child_item
            }
        }
        for entry in entries {
            full_path := os.join_path(path, entry)
            if !os.is_dir(full_path) {
                child_item := load_file_tree(full_path)
                item.children << &child_item
            }
        }
    }

    return item
}

fn (mut e Editor) quit() {
	e.quit = true
	reset_terminal()
}

fn (mut e Editor) hide_terminal() {
    e.terminal.visible = false
    e.main.h = e.main.h + e.terminal.h + 1
    e.active_pane = &e.main
}

fn (mut e Editor) show_terminal() {
    e.terminal.visible = true
    e.main.h = e.main.h - e.terminal.h - 1 
    e.active_pane = &e.terminal
}

fn (mut e Editor) toggle_terminal() {
    if e.terminal.visible {
        e.hide_terminal()
    } else {
        e.show_terminal()
    }
}

fn (mut e Editor) hide_sidebar() {
    e.sidebar.visible = false
    e.main.x = 0
    e.main.w = e.screen.w
    e.terminal.x = 0
    e.terminal.w = e.screen.w
    e.active_pane = &e.main
}

fn (mut e Editor) show_sidebar() {
    e.sidebar.visible = true
    e.main.x = e.sidebar.w + 1 
    e.main.w = e.screen.w - e.main.x
    e.terminal.x = e.sidebar.w + 1 
    e.terminal.w = e.screen.w - e.terminal.x
    e.active_pane = &e.sidebar
}

fn (mut e Editor) toggle_sidebar() {
    if e.sidebar.visible {
        e.hide_sidebar()
    } else {
        e.show_sidebar()
    }
}

fn render_file_tree(item &SidebarItem) []string {
    mut result := []string{}
    render_file_tree_recursive(item, 0, "", mut result)
    return result
}

fn render_file_tree_recursive(item &SidebarItem, depth int, prefix string, mut result []string) {
    // Create the indentation based on the depth
    indent := '  '.repeat(depth)

    // Add the current item to the result
    file_path := prefix + item.name
    if !item.is_root {
        result << '${indent}${if item.is_dir { if item.is_collapsed { '+ ' } else {'- '} } else {'* '}}${item.name}${if item.is_dir { '/' } else { '' }}                                            ${file_path}'
    }

    // If the item is a directory and not collapsed, render its children
    if item.is_dir {
        if !item.is_collapsed || item.is_root {
            for child in item.children {
                render_file_tree_recursive(child, depth + 1, prefix + item.name + "/", mut result)
            }
        }
    }
}

fn (mut e Editor) map_file_tree(file_tree &SidebarItem) {
    unsafe {
        e.file_tree_map[file_tree.path] = file_tree
    }
    for child in file_tree.children {
        e.map_file_tree(child)
    }
}

fn (mut e Editor) toggle_folder(mut i SidebarItem) {
    if i.is_dir {
        if i.is_collapsed {
            i.is_collapsed = false
        } else {
            i.is_collapsed = true
        }
    }
    e.sidebar.buffer = render_file_tree(e.file_tree)
}

fn (mut p Pane) lines() []string {
    return p.buffer
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
	mut sidebar := Pane{"sidebar", 0, 0, sidebar_width, height - status_height, [], false, 0, 0, 0}
	mut main := Pane{"main", 0, 0, width, height - status_height, [], true, 0, 0, 0}
	mut terminal := Pane{"terminal", 0, height - status_height - terminal_height, width, terminal_height, [], false, 0, 0, 0}

    mut file_tree := load_file_tree(".")
    file_tree.is_root = true

	mut e := Editor{
		main:        &main
		sidebar:     &sidebar
		terminal:    &terminal
		active_pane: &main
        file_tree:   file_tree
	}

    e.sidebar.buffer = render_file_tree(e.file_tree)
    e.map_file_tree(&file_tree)
    e.show_sidebar()

    e.message = "Load sidebar"

	e.quit = false
	e.mode = 'normal'
	e.screen = Screen{width, height}

	e.render()
	e.loop()
}
