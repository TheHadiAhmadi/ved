module editor

fn (mut e Editor) handle_visual(raw int, key string) {
    match raw {
        27 {
            e.mode = 'normal'
            print("\033[0 q")
        }
        else {
        }
    }
}


