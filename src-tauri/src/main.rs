// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    let silent_start = args.iter().any(|arg| arg == "--silent" || arg == "-s");

    ours_hotkey_lib::run(silent_start)
}
