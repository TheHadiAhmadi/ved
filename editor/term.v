module editor

import term

pub fn enable_raw_mode() {
	mut terminal := C.termios{}
	C.tcgetattr(0, &terminal) // Get current terminal attributes
	terminal.c_lflag &= ~(C.ECHO | C.ICANON) // Disable canonical mode & echo
	C.tcsetattr(0, C.TCSANOW, &terminal) // Apply changes
}

pub fn disable_raw_mode() {
	mut terminal := C.termios{}
	C.tcgetattr(0, &terminal) // Get current terminal attributes
	terminal.c_lflag |= C.ECHO | C.ICANON // Re-enable canonical mode & echo
	C.tcsetattr(0, C.TCSANOW, &terminal) // Apply changes }
}

pub fn getch() u8 {
	mut buf := [1]u8{}
	C.read(0, &buf[0], 1) // Read 1 byte from stdin
	return buf[0] // Convert byte to int
}


fn set_cursor_bar() {
	print('\033[5 q') // Change cursor to a steady bar (|)
}

fn set_cursor_default() {
	print('\033[1 q')
}


fn prepare_terminal() {
	unbuffer_stdout()
    enable_raw_mode()
	print("\x1b[?1049h")
	term.clear()
}

fn reset_terminal() {
	term.show_cursor()
    disable_raw_mode()
	// print('\x1b[?25h')
    print("\033[0 q")
	print("\x1b[?1049l")
}




