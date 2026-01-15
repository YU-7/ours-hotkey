use crate::ahk;
use serde::{Deserialize, Serialize};
use std::fs;
use tauri::Manager;
use tauri_plugin_log::log::{error, info, warn};

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
            warn!("无法读取配置文件 {:?}: {}，跳过自动启动", config_path, e);
            return Ok(()); // 如果无法读取配置文件，静默跳过
        }
    };

    // 解析配置文件
    let config: AhkConfig = match serde_json::from_str(&config_content) {
        Ok(config) => config,
        Err(e) => {
            warn!("解析配置文件失败: {}，跳过自动启动", e);
            return Ok(()); // 如果解析失败，静默跳过
        }
    };

    info!(
        "读取到配置文件: global-hotkey={}, vimMode={}",
        config.global_hotkey, config.vim_mode
    );

    // 根据配置启动脚本
    if config.global_hotkey {
        let manager = app.state::<ahk::AhkProcessManager>();
        match ahk::start_ahk_script_internal(app, "global-hotkey", manager.inner()) {
            Ok(msg) => info!("自动启动全局热键脚本: {}", msg),
            Err(e) => error!("自动启动全局热键脚本失败: {}", e),
        }
    }

    if config.vim_mode {
        let manager = app.state::<ahk::AhkProcessManager>();
        match ahk::start_ahk_script_internal(app, "vim-mode", manager.inner()) {
            Ok(msg) => info!("自动启动 Vim 模式脚本: {}", msg),
            Err(e) => error!("自动启动 Vim 模式脚本失败: {}", e),
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
