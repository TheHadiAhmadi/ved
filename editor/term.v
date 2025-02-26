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

pub fn getch() int {
	mut buf := [3]u8{}
	C.read(0, &buf[0], 3)
    // Handle Backspace and delete keys 
    if buf[0] == 127 {
        return -8
    }
    if buf[0] == 27 && buf[1] == 91 && buf[2] == 51 {
        return 127
    }
	return buf[0] 
}


fn set_cursor_bar() {
	print('\033[5 q') // Change cursor to a steady bar (|)
}

fn set_cursor_default() {
	print('\033[1 q')
}


fn prepare_terminal() {
	print("\x1b[?1049h")
	unbuffer_stdout()
    enable_raw_mode()
	term.clear()
}

fn reset_terminal() {
	term.show_cursor()
    disable_raw_mode()
	// print('\x1b[?25h')
    print("\033[0 q")
	print("\x1b[?1049l")
}




