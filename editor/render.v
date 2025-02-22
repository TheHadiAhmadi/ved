module editor

import term

fn (mut e Editor) render_status_line()
{
    term.set_cursor_position(x: 0, y: e.screen.h - 1)
    print('\033[48;5;238m')

    if e.filename.len > 0 {
        e.status_left = e.filename

        e.status_right = 'L${e.screen.cy}/${e.buffer.len}'
    }

    space_count := e.screen.w - e.status_left.len - e.status_right.len

    print(e.status_left)
    for i in 0..space_count {
        print(' ')
    }
    print(e.status_right)

    print('\033[0m')
}

fn (mut e Editor) render_command_line()
{
    term.set_cursor_position(x: 0, y: e.screen.h)
    if e.mode == 'command' {
        set_cursor_bar()
        print(e.command)
        term.set_cursor_position(x: 1 + e.command.len, y: e.screen.h)
    } else {
        print(e.message)
    }
}

pub fn (mut e Editor) render() {
    for line in e.screen.st .. e.screen.st + e.screen.h - 1 {
        term.set_cursor_position(x: 0, y: line - e.screen.st)
        if line < e.buffer.len {
            print(e.buffer[line])
        } else {
            print("~")
        }
    }

    e.render_status_line()
    e.render_command_line()

    if e.mode != 'command' {
        term.set_cursor_position(x: e.screen.cx, y: e.screen.cy)
    }
}


