module editor

fn (mut e Editor) handle_visual(raw u8, key string) {
    match raw {
        27 {
            e.mode = 'normal'
            print("\033[0 q")
        }
        else {
        }
    }
}


