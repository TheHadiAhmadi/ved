module editor

import term

fn (mut e Editor) render_status_line() {
    term.set_cursor_position(x: 0, y: e.active_pane.h + 1)
    print('\033[48;5;238m')

    mut status_left := e.status_left
    mut status_right := e.status_right

    if e.filename.len > 0 {
        if status_left.len == 0 {
            status_left = " " + e.filename
        }
        if status_right.len == 0 {
            status_right = 'L${e.active_pane.cy}/${e.buffer.len} '
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
    term.set_cursor_position(x: 0, y: e.active_pane.h + 2)
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

fn (mut e Editor) normalize_scroll_top() {
    cursor_offset := e.active_pane.h / 4
    is_in_upper_screen := e.active_pane.cy < (e.active_pane.st + (e.active_pane.h / 2))

    if e.active_pane.h > e.buffer.len {
        return
    }

    // cursor is visible in ~center of active_pane
    if e.active_pane.cy > e.active_pane.st + cursor_offset
        && e.active_pane.cy < e.active_pane.st + e.active_pane.h - cursor_offset {
        return
    }

    if is_in_upper_screen && e.active_pane.cy < e.active_pane.st + cursor_offset {
        if e.active_pane.cy > cursor_offset {
            e.active_pane.st = e.active_pane.cy - cursor_offset
        } else {
            e.active_pane.st = 0
        }
    }

    if !is_in_upper_screen && e.active_pane.cy > (e.active_pane.h - cursor_offset)
        && e.active_pane.cy < (e.buffer.len - cursor_offset) {
        e.active_pane.st = e.active_pane.cy - e.active_pane.h + cursor_offset
    } else if e.active_pane.cy > e.buffer.len - 1 - cursor_offset {
        e.active_pane.st = e.buffer.len - e.active_pane.h
    }

    if e.active_pane.cy > e.active_pane.st + e.active_pane.h - cursor_offset {
        if (e.active_pane.cy - cursor_offset) < (e.buffer.len - e.active_pane.h + cursor_offset) {
            e.active_pane.st = e.active_pane.cy - e.active_pane.h + cursor_offset
        }
    }
    e.status_right = 'St${e.active_pane.st}-Cy${e.active_pane.cy}-H${e.active_pane.h}-Bl${e.buffer.len}'
}

pub fn (mut p Pane) render_pane() {
    for line in p.y .. p.y + p.h {
        term.set_cursor_position(x: p.x + 1, y: line + 1)
        if p.lines.len > line {
            for ch in p.x .. p.x + p.w {
                if p.lines[line + p.st].len > ch - p.x {
                    character := rune(p.lines[line + p.st][ch - p.x]).str()

                    print(character)
                } else {
                    print(' ')

                }
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

pub fn (mut e Editor) render() {

    // e.normalize_scroll_top()
    term.clear()
//     for line in e.active_pane.st .. e.active_pane.st + e.active_pane.h {
        // term.set_cursor_position(x: 1, y: line - e.active_pane.st + 1)
        // if line < e.buffer.len {
            // print(e.buffer[line])
            // for j in e.buffer[line].len .. e.active_pane.w {
                // print(' ')
            // }
        // } else {
          //   print('~')
        // }
    // }
    e.sidebar.render_pane()
    e.main.render_pane()
    e.terminal.render_pane()

    e.render_status_line()
    e.render_command_line()

     term.set_cursor_position(x: e.active_pane.x + e.active_pane.cx, y: e.active_pane.y + e.active_pane.cy)

    // if e.mode != 'command' {
        
      //   mut x := if e.buffer.len > e.active_pane.cy && e.active_pane.cx >= e.buffer[e.active_pane.cy].len { e.buffer[e.active_pane.cy].len + 1 } else { e.active_pane.cx + 1}
      //   term.set_cursor_position(x: x, y: e.active_pane.cy - e.active_pane.st + 1)
    // }
}
