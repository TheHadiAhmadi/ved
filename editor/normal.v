module editor

fn isalpha(s string) bool {
    return (s >= 'a' && s <= 'z') || (s >= 'A' && s <= 'Z') || (s >= '0' && s <= '9') || (s == '_')
}

fn (mut e Editor) handle_normal_sidebar(raw int, key string) {
    file_name := e.sidebar.lines()[e.sidebar.cy][20..].trim(' ')

    mut item := e.file_tree_map[file_name]

    if key == ' ' {
        raw2 := getch()
        key2 := rune(raw2).str()

        if key2 == 'd' {
            e.hide_sidebar()
        } else {
            e.handle_normal_sidebar(raw2, key2)
        }

    }

    if key == 'j' {
        if e.sidebar.cy < e.sidebar.lines().len - 1 {
            e.sidebar.cy++
        }
    }
    if key == 'k' {
        if e.sidebar.cy > 0 {
            e.sidebar.cy--
        }
    }
    if raw == 10 {
        if item.is_dir {
            e.toggle_folder(mut item)
            e.message = "Toggle folder + " item.path
        } else {
            e.load_file(item.path)
        }

    }
    else if raw == 2 {
        e.toggle_sidebar()
    }

}


fn (mut e Editor) handle_normal_main(raw int, key string) {
	match key {
		'a' {
			e.mode = 'insert'
			e.main.cx++
			set_cursor_bar()
		}
		't' {
			e.toggle_sidebar()
		}
		' ' {
            raw2 := getch()
            key2 := rune(raw2).str()

            if key2 == 'd' {
                if e.active_pane.name == 'sidebar' {
                    e.hide_sidebar()
                    panic(e.sidebar)
                } else if e.sidebar.visible {
                    e.active_pane = &e.sidebar
                } else {
                    e.show_sidebar()
                }
            } else {
                e.handle_normal_main(raw2, key2)
            }
		}
		'i' {
			e.mode = 'insert'
			set_cursor_bar()
		}
        'd' {
            raw2 := getch()
            key2 := rune(raw2).str()

            if key2 == 'd' {
                e.main.buffer.delete(e.main.cy)
            } else {
                e.handle_normal(raw2, key2)
            }
        }
        //'H' {
        //    raw2 := getch()
        //    key2 := rune(raw2).str()

        //    if e.sidebar.w > 2 && key2 == 'H' {
        //        e.sidebar.w-=2
        //        e.main.w+=2
        //        e.main.x-=2
        //    } else {
        //        // e.handle_normal(raw2, key2)
        //    }
       // }
        //'L' {
        //    raw2 := getch()
        //    key2 := rune(raw2).str()

        //    if e.main.w > 2 && key2 == 'L' {
        //        e.sidebar.w+=2
        //        e.main.w-=2
        //        e.main.x+=2
        //    } else {
                // e.handle_normal(raw2, key2)
        //    }
        //}
        'g' {
            raw2 := getch()
            key2 := rune(raw2).str()

            if key2 == 'g' {
                e.main.cy = 0
            } else {
                e.handle_normal(raw2, key2)
            }

        }
		'x' {
            if e.active_pane.buffer[e.active_pane.cy].len > 0 && e.active_pane.cx < e.active_pane.buffer[e.active_pane.cy].len {
                e.active_pane.buffer[e.active_pane.cy] = e.active_pane.buffer[e.active_pane.cy][0..e.active_pane.cx] +
                    e.active_pane.buffer[e.active_pane.cy][e.active_pane.cx + 1..]
                if e.active_pane.cx == e.active_pane.buffer[e.active_pane.cy].len {
                    e.active_pane.cx = e.active_pane.buffer[e.active_pane.cy].len - 1
                }
            }
		}
		'X' {
            if e.active_pane.buffer[e.active_pane.cy].len > 1 && e.active_pane.cx > 0 {
                e.active_pane.buffer[e.active_pane.cy] = e.active_pane.buffer[e.active_pane.cy][0..e.active_pane.cx - 1] +
                    e.active_pane.buffer[e.active_pane.cy][e.active_pane.cx..]
                e.active_pane.cx--
            }
		}
		'^' {
			e.active_pane.cx = 0
		}
		'$' {
			e.active_pane.cx = e.active_pane.buffer[e.active_pane.cy].len
		}
        'w' {

            // next word
        }
        'b' {
            // previous word
        }
		'v' {
			e.mode = 'visual'
		}
		'u' {
			// undo
		}
		'r' {
			// replace
		}
		'j' {
			if e.main.cy < e.main.buffer.len - 1 {
				e.main.cy++
                // e.main.render_pane()
			}
		}
		'k' {
			if e.main.cy > 0 {
				e.main.cy--
                e.main.render_pane()
			}
		}
		'l' {
			if e.main.cx < e.main.w {
				e.main.cx++
                e.main.render_pane()
			}
		}
		'h' {
			if e.main.cx > 0 {
				e.main.cx--
                e.main.render_pane()
			}
		}
		'G' {
			e.main.cy = e.main.buffer.len - 1
		}
		'O' {
			// add new line to main.buffer
			e.mode = 'insert'
			set_cursor_bar()
			e.main.buffer.insert(e.main.cy, '')
		}
		'o' {
			// add new line to main.buffer
			e.mode = 'insert'
			set_cursor_bar()
			e.main.buffer.insert(e.main.cy + 1, '')
            e.main.cy++
		}
		':' {
			e.mode = 'command'
			e.command = ':'
			// term.set_cursor_position(x: 0, y: e.main.h -1)
		}
		'q' {
			e.quit = true
		}
		else {

            if raw == 10 {
                e.toggle_terminal()
            }
            else if raw == 2 {
                e.toggle_sidebar()
            }
        }
	}

}

fn (mut e Editor) handle_normal_terminal(raw int, key string) {
    if raw == 10 {
        e.toggle_terminal()
    }

    else if raw == 2 {
        e.toggle_sidebar()
    }

}

fn (mut e Editor) handle_normal(raw int, key string) {

    if e.active_pane.name == 'main' {
        e.handle_normal_main(raw, key)
    } else if e.active_pane.name == 'terminal' {
        e.handle_normal_terminal(raw, key)
    } else if e.active_pane.name == 'sidebar' {
        e.handle_normal_sidebar(raw, key)
    }
}
