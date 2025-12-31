// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/

use std::collections::HashMap;
use std::sync::Mutex;
use serde::{Deserialize, Serialize};
use std::fs;
use tauri::Manager;

mod ahk;

#[derive(Debug, Serialize, Deserialize)]
struct AhkConfig {
    #[serde(rename = "global-hotkey")]
    global_hotkey: bool,
    #[serde(rename = "vimMode")]
    vim_mode: bool,
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_fs::init())
        .setup(|app| {
            #[cfg(desktop)]
            {
                use tauri_plugin_autostart::MacosLauncher;
                #[cfg(target_os = "macos")]
                {
                    app.handle().plugin(tauri_plugin_autostart::init(
                        MacosLauncher::LaunchAgent,
                        None, // 可以在这里传递启动参数，例如: Some(vec!["--flag1", "--flag2"])
                    ))?;
                }
                #[cfg(not(target_os = "macos"))]
                {
                    // Windows 和 Linux 平台
                    // 在非 macOS 平台上，第一个参数会被忽略，但仍需要提供
                    app.handle().plugin(tauri_plugin_autostart::init(
                        MacosLauncher::LaunchAgent, // 在 Windows/Linux 上会被忽略
                        None, // 可以在这里传递启动参数，例如: Some(vec!["--flag1", "--flag2"])
                    ))?;
                }

                // 读取配置文件并自动启动脚本
                auto_start_scripts(&app.handle())?;
            }
            Ok(())
        })
        .manage(ahk::AhkProcessManager(Mutex::new(HashMap::new())))
        .invoke_handler(tauri::generate_handler![
            ahk::run_ahk_script,
            ahk::stop_ahk_script,
            ahk::stop_all_ahk_scripts,
            ahk::list_running_scripts,
            ahk::test_ahk_paths
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

/// 读取配置文件并自动启动相应的 AHK 脚本
fn auto_start_scripts(app: &tauri::AppHandle) -> Result<(), Box<dyn std::error::Error>> {
    // 获取资源目录路径
    let resource_dir = app.path().resource_dir()
        .map_err(|e| format!("获取资源目录失败: {}", e))?
        .join("_up_");

    // 配置文件路径
    let config_path = resource_dir.join("our-key-config").join("enable-ahk.json");

    // 读取配置文件
    let config_content = match fs::read_to_string(&config_path) {
        Ok(content) => content,
        Err(e) => {
            println!("无法读取配置文件 {:?}: {}，跳过自动启动", config_path, e);
            return Ok(()); // 如果无法读取配置文件，静默跳过
        }
    };

    // 解析配置文件
    let config: AhkConfig = match serde_json::from_str(&config_content) {
        Ok(config) => config,
        Err(e) => {
            println!("解析配置文件失败: {}，跳过自动启动", e);
            return Ok(()); // 如果解析失败，静默跳过
        }
    };

    println!("读取到配置文件: global-hotkey={}, vimMode={}", config.global_hotkey, config.vim_mode);

    // 根据配置启动脚本
    if config.global_hotkey {
        let manager = app.state::<ahk::AhkProcessManager>();
        match ahk::start_ahk_script_internal(app, "global-hotkey", &manager) {
            Ok(msg) => println!("自动启动全局热键脚本: {}", msg),
            Err(e) => println!("自动启动全局热键脚本失败: {}", e),
        }
    }

    if config.vim_mode {
        let manager = app.state::<ahk::AhkProcessManager>();
        match ahk::start_ahk_script_internal(app, "vim-mode", &manager) {
            Ok(msg) => println!("自动启动 Vim 模式脚本: {}", msg),
            Err(e) => println!("自动启动 Vim 模式脚本失败: {}", e),
        }
    }

    Ok(())
}
