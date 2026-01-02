use crate::ahk;
use serde::{Deserialize, Serialize};
use std::fs;
use tauri::Manager;

/// 设置应用退出时的清理工作
pub fn setup_exit_cleanup(app: &tauri::AppHandle) -> Result<(), Box<dyn std::error::Error>> {
    // 获取应用主窗口
    let main_window = app
        .get_webview_window("main")
        .ok_or_else(|| "Main window not found".to_string())?;

    let app_handle = app.clone();
    let cleanup_done = std::sync::atomic::AtomicBool::new(false);

    // 监听窗口关闭事件
    main_window.clone().on_window_event(move |event| {
        match event {
            tauri::WindowEvent::CloseRequested { .. } => {
                // 使用原子标志确保清理只执行一次
                if cleanup_done.swap(true, std::sync::atomic::Ordering::SeqCst) {
                    return; // 已经执行过清理，直接返回
                }

                println!("应用退出请求，关闭所有AHK脚本...");

                // 停止所有AHK脚本
                let manager = app_handle.state::<ahk::AhkProcessManager>();
                let mut processes = manager.0.lock().unwrap();
                let count = processes.len();

                let mut stopped_count = 0;
                for (_script_name, mut child) in processes.drain() {
                    if child.kill().is_ok() {
                        stopped_count += 1;
                    }
                }

                println!("已停止 {} 个AHK脚本中的 {} 个", count, stopped_count);

                // 不阻止关闭，让Tauri自然处理
                // 不手动调用 close() 避免触发新的 CloseRequested 事件
            }
            _ => {}
        }
    });

    Ok(())
}

/// 读取配置文件并自动启动相应的 AHK 脚本
pub fn auto_start_scripts(app: &tauri::AppHandle) -> Result<(), Box<dyn std::error::Error>> {
    // 获取资源目录路径
    let resource_dir = app
        .path()
        .resource_dir()
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

    println!(
        "读取到配置文件: global-hotkey={}, vimMode={}",
        config.global_hotkey, config.vim_mode
    );

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

#[derive(Debug, Serialize, Deserialize)]
struct AhkConfig {
    #[serde(rename = "global-hotkey")]
    global_hotkey: bool,
    #[serde(rename = "vimMode")]
    vim_mode: bool,
}
