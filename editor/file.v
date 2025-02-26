module editor

import os

fn (mut e Editor) load_file(filename string) {
    if !os.exists(filename) {
        println('No file found.')
        e.filename = filename
        e.main.buffer = []
        return
    }

    lines := os.read_lines(filename) or { panic('failed to read file') }
    e.main.buffer = lines.map(fn (line string) string {
        mut result := ''
        for character in line {
            if rune(character) ==  `\t` {
                result += '    '
            } else {
                result += rune(character).str()
            }
        }
        return result
    })
    e.active_pane = &e.main

    e.filename = filename
}

fn (mut e Editor) save_file() {
    if e.filename.len == 0 {
        e.message = ":w <filename>"
        return
    }

    mut file := os.create(e.filename) or { panic('Failed to create file') }
    defer { file.close() }

    for line in e.buffer {
        // convert 4 spaces to tab
        modified_line := line.replace('    ', '\t')
        file.writeln(modified_line) or { panic('Failed to write to file') }
    }
}
