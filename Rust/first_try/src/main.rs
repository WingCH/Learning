// https://askeing.github.io/rust-book/getting-started.html
/*
two ways to execute the function
1. cargo build && ./target/debug/hello_world
2. cargo run
 */
fn main() {
    let a = true;

    let _y = change_truth(a);
    println!("{}", a);
    println!("{}", _y);
}

fn change_truth(x: bool) -> bool {
    !x
}