import os 

struct SidebarItem {
mut:
    name         string
    is_dir       bool
    is_collapsed bool
    children     []SidebarItem
}

struct Sidebar {
mut:
    items []SidebarItem
    st    int // scroll top
    h     int // height of the sidebar
}

fn ignored(segment string) bool {
    return segment.starts_with('.')
}

fn load_file_tree(path string) SidebarItem {
    entries := os.ls(path) or { panic('failed') }
    
    mut item := SidebarItem{
        name: path,
        is_dir: true,
        is_collapsed: true,
        children: []
    }

    for entry in entries {
        full_path := os.join_path(path, entry)
        if os.is_dir(full_path) && !ignored(entry) {
            child := load_file_tree(full_path)
            item.children << child
        } else if !ignored(entry) {
            item.children << SidebarItem{
                name: entry,
                is_dir: false,
                is_collapsed: false,
                children: []
            }
        }
    }
    return item
}

fn (mut item SidebarItem) toggle_folder() {
    item.is_collapsed = !item.is_collapsed
}

fn scroll_sidebar(mut sidebar Sidebar, direction int) {
    sidebar.st += direction
    // Keep scroll within bounds
    if sidebar.st < 0 {
        sidebar.st = 0
    }
    // if sidebar.st > sidebar.items.len - sidebar.h {
    //     sidebar.st = sidebar.items.len - sidebar.h
   //  }
}

fn print_sidebar(sidebar Sidebar) {
    // Printing only the visible items based on the scroll position
    start := sidebar.st
    end := start + sidebar.h

    for i in start..end {
        if i >= sidebar.items.len {
            break
        }
        item := sidebar.items[i]
        if item.is_dir {
            // Show directories with their toggle state
            print('${if item.is_collapsed { '-' } else { '+' }} ${item.name}\n')
        } else {
            print('  ${item.name}\n')
        }
    }
}

fn main() {
    mut sidebar := Sidebar{
        items: [load_file_tree(".")],
        st: 0,
        h: 10 // Number of items to display at a time
    }
//     print(sidebar.items)
    
    // Sample user interaction (replace this with actual input handling code)
    sidebar.items[0].toggle_folder() // Toggle the top-level folder
    scroll_sidebar(mut sidebar, 1) // Scroll down
    print_sidebar(sidebar) // Print the sidebar
}
