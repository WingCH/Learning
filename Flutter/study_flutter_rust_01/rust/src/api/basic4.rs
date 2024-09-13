#[flutter_rust_bridge::frb(sync)]
pub fn add(x: i32, y: i32) -> i32 {
    x + y
}