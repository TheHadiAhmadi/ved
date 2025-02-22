module editor

import os

fn (mut e Editor) load_file(filename string) {
	if !os.exists(filename) {
		println('No file found.')
		return
	}

	lines := os.read_lines(filename) or { panic('failed to read file') }
	e.buffer = lines
	e.filename = filename
}

fn (mut e Editor) save_file() {
    if e.filename.len == 0 {
        e.message = ":w <filename>"
    }

	mut file := os.create(e.filename) or { panic('Failed to create file') }
	defer { file.close() }

	for line in e.buffer {
		file.writeln(line) or { panic('Failed to write to file') }
	}
}
