use sysinfo::System;

#[flutter_rust_bridge::frb(sync)]
pub fn cpu_arch() -> String {
    System::cpu_arch().unwrap()
}
