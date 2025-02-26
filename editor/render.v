module editor

import term

fn (mut e Editor) render_status_line() {
    term.set_cursor_position(x: 0, y: e.screen.h -1)
    print('\033[48;5;238m')
    lines := e.active_pane.lines()

    mut status_left := e.status_left
    mut status_right := e.status_right

    if e.filename.len > 0 {
        if status_left.len == 0 {
            status_left = " " + e.filename
        }
        if status_right.len == 0 {
            status_right = 'L${e.active_pane.cy}/${lines.len} '
        }
    }

    space_count := e.screen.w - status_left.len - status_right.len

    print(status_left)
    for i in 0 .. space_count {
        print(' ')
    }
    print(status_right)

    print('\033[0m')
}

fn (mut e Editor) render_command_line() {
    term.set_cursor_position(x: 0, y: e.screen.h)
    if e.mode == 'command' {
        set_cursor_bar()
        print(e.command)
        for i in e.command.len .. e.active_pane.w {
            print(' ')
        }

        term.set_cursor_position(x: 1 + e.command.len, y: e.active_pane.h + 2)
    } else {
        print(e.message)
    }
}

fn (mut p Pane) normalize_scroll_top() {
    cursor_offset := p.h / 4
    is_in_upper_screen := p.cy < (p.st + (p.h / 2))
    lines := p.lines()

    if p.h > lines.len {
        return
    }

    // cursor is visible in ~center of active_pane
    if p.cy > p.st + cursor_offset
        && p.cy < p.st + p.h - cursor_offset {
        return
    }

    if is_in_upper_screen && p.cy < p.st + cursor_offset {
        if p.cy > cursor_offset {
            p.st = p.cy - cursor_offset
        } else {
            p.st = 0
        }
    }

    if !is_in_upper_screen && p.cy > (p.h - cursor_offset)
        && p.cy < (lines.len - cursor_offset) {
        p.st = p.cy - p.h + cursor_offset
    } else if p.cy > lines.len - 1 - cursor_offset {
        p.st = lines.len - p.h
    }

    if p.cy > p.st + p.h - cursor_offset {
        if (p.cy - cursor_offset) < (lines.len - p.h + cursor_offset) {
            p.st = p.cy - p.h + cursor_offset
        }
    }
}

pub fn (mut p Pane) render_pane() {
    lines := p.lines()
    if p.visible {
        for line in p.y .. p.y + p.h {
            term.set_cursor_position(x: p.x + 1, y: line + 1)
            if lines.len > line {
                if line == p.cy - p.st {
                    print("\x1b[48;5;238m")
                }
                for ch in p.x .. p.x + p.w {
                    if lines[line + p.st].len > ch - p.x {
                        character := rune(lines[line + p.st][ch - p.x]).str()

                        print(character)
                    } else {
                        print(' ')

                    }
                }
                if line == p.cy - p.st {
                    print("\x1b[0m")
                }
            } else {
                for i in p.x .. p.x + p.w {
                    print(' ')
                }
            }
        }
        width, height := term.get_terminal_size()

        // draw vertical line
        for i in p.y .. p.h {
            term.set_cursor_position(x: 1 + p.x + p.w, y: i + 1)
            print('\x1b[48;5;238m \x1b[0m')
        }
        
        if p.x + p.w < width {
            for i in p.x .. p.x + p.w {
                term.set_cursor_position(x: 1 + i, y: p.y + p.h + 1)
                print('\x1b[48;5;238m \x1b[0m')
            }
        }
    }
    
}

pub fn (mut e Editor) render() {
    mut p := e.active_pane
    p.normalize_scroll_top()
    e.status_right = 'St${p.st}-Cy${p.cy}-H${p.h}-Bl${p.lines().len}'
    e.sidebar.render_pane()
    e.main.render_pane()
    e.terminal.render_pane()

    e.render_status_line()
    e.render_command_line()

    if e.mode != 'command' {
        term.set_cursor_position(
            x: 1 + e.active_pane.x + e.active_pane.cx, 
            y: 1 - e.active_pane.st + e.active_pane.y + e.active_pane.cy
        )
    }
}
