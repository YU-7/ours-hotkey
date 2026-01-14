use crate::ahk;
use serde::{Deserialize, Serialize};
use std::fs;
use tauri::Manager;

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
        match ahk::start_ahk_script_internal(app, "global-hotkey", manager.inner()) {
            Ok(msg) => println!("自动启动全局热键脚本: {}", msg),
            Err(e) => println!("自动启动全局热键脚本失败: {}", e),
        }
    }

    if config.vim_mode {
        let manager = app.state::<ahk::AhkProcessManager>();
        match ahk::start_ahk_script_internal(app, "vim-mode", manager.inner()) {
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

/// 应用设置配置
#[derive(Debug, Serialize, Deserialize, Default)]
pub struct AppSettings {
    #[serde(rename = "silentStart")]
    pub silent_start: bool,
}

/// 获取应用设置文件路径
fn get_settings_path(app: &tauri::AppHandle) -> Result<std::path::PathBuf, Box<dyn std::error::Error>> {
    let resource_dir = app
        .path()
        .resource_dir()
        .map_err(|e| format!("获取资源目录失败: {}", e))?;
    Ok(resource_dir.join("_up_").join("our-key-config").join("settings.json"))
}

/// 读取应用设置
pub fn read_settings(app: &tauri::AppHandle) -> Result<AppSettings, Box<dyn std::error::Error>> {
    let settings_path = get_settings_path(app)?;
    
    let content = match fs::read_to_string(&settings_path) {
        Ok(content) => content,
        Err(_) => {
            // 如果文件不存在，返回默认值
            return Ok(AppSettings::default());
        }
    };
    
    serde_json::from_str(&content).map_err(|e| format!("解析设置文件失败: {}", e).into())
}

/// 保存应用设置
pub fn save_settings(app: &tauri::AppHandle, settings: &AppSettings) -> Result<(), Box<dyn std::error::Error>> {
    let settings_path = get_settings_path(app)?;
    
    // 确保目录存在
    if let Some(parent) = settings_path.parent() {
        fs::create_dir_all(parent)?;
    }
    
    let content = serde_json::to_string_pretty(settings)?;
    fs::write(&settings_path, content)?;
    
    Ok(())
}
