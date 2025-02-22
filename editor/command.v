module editor 

fn (mut e Editor) handle_command(raw u8, key string) {
    match raw {
        27 {
            e.mode = 'normal'
            set_cursor_default()
        }
        10 {
            e.mode = 'normal'
            set_cursor_default()

            if e.command.starts_with(':e ') {
                filename := e.command.split(' ')[1]
                e.load_file(filename)
            }

            if e.command.starts_with(':w ') {
                e.filename = e.command.split(' ')[1]
                e.save_file()
            }

            if e.command == ':w' {
                e.save_file()
            }

            if e.command == ':wq' {
                e.save_file()
                e.quit()
            }


            if e.command == ':q' {
                e.quit()
            }

            // run command
        }
        8 {
           panic("BACKSPACED")
           e.status_left = "Edita asdf"
            if e.command == ':' {
                e.mode = 'normal'
                set_cursor_default()
            }
            if e.command.len > 1 {
                e.command = e.command[0..e.command.len - 1]
            }
        }
        else {
            e.command += key
        }
    }
}


