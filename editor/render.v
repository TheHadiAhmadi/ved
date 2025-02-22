module editor

import term

fn (mut e Editor) render_status_line() {
    term.set_cursor_position(x: 0, y: e.screen.h + 1)
    print('\033[48;5;238m')

    mut status_left := e.status_left
    mut status_right := e.status_right

    if e.filename.len > 0 {
        if status_left.len == 0 {
            status_left = " " + e.filename
        }
        if status_right.len == 0 {
            status_right = 'L${e.screen.cy}/${e.buffer.len} '
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
    term.set_cursor_position(x: 0, y: e.screen.h + 2)
    if e.mode == 'command' {
        set_cursor_bar()
        print(e.command)
        term.set_cursor_position(x: 1 + e.command.len, y: e.screen.h + 2)
    } else {
        print(e.message)
    }
}

fn (mut e Editor) normalize_scroll_top() {
    cursor_offset := e.screen.h / 4
    is_in_upper_screen := e.screen.cy < (e.screen.st + (e.screen.h / 2))

    if e.screen.h > e.buffer.len {
        return
    }

    // cursor is visible in ~center of screen
    if e.screen.cy > e.screen.st + cursor_offset
        && e.screen.cy < e.screen.st + e.screen.h - cursor_offset {
        return
    }

    if is_in_upper_screen && e.screen.cy < e.screen.st + cursor_offset {
        if e.screen.cy > cursor_offset {
            e.screen.st = e.screen.cy - cursor_offset
        } else {
            e.screen.st = 0
        }
    }

    if !is_in_upper_screen && e.screen.cy > (e.screen.h - cursor_offset)
        && e.screen.cy < (e.buffer.len - cursor_offset) {
        e.screen.st = e.screen.cy - e.screen.h + cursor_offset
    } else if e.screen.cy > e.buffer.len - 1 - cursor_offset {
        e.screen.st = e.buffer.len - e.screen.h
    }

    if e.screen.cy > e.screen.st + e.screen.h - cursor_offset {
        if (e.screen.cy - cursor_offset) < (e.buffer.len - e.screen.h + cursor_offset) {
            e.screen.st = e.screen.cy - e.screen.h + cursor_offset
        }
    }
    e.status_right = 'St${e.screen.st}-Cy${e.screen.cy}-H${e.screen.h}-Bl${e.buffer.len}'
}

pub fn (mut e Editor) render() {
    e.normalize_scroll_top()
        term.clear()
    for line in e.screen.st .. e.screen.st + e.screen.h {
        term.set_cursor_position(x: 1, y: line - e.screen.st + 1)
        if line < e.buffer.len {
            print(e.buffer[line])
            for j in e.buffer[line].len .. e.screen.w {
                print(' ')
            }
        } else {
            print('%')
        }
    }

    e.render_status_line()
    e.render_command_line()

    if e.mode != 'command' {
        term.set_cursor_position(x: e.screen.cx + 1, y: e.screen.cy - e.screen.st + 1)
    }
}
