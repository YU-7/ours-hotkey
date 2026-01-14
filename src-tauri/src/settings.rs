use serde::{Deserialize, Serialize};
use std::fs;
use tauri::Manager;

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

/// 获取静默启动状态
#[tauri::command]
pub fn get_silent_start_status(app: tauri::AppHandle) -> Result<bool, String> {
    read_settings(&app)
        .map(|settings| settings.silent_start)
        .map_err(|e| e.to_string())
}

/// 设置静默启动状态
#[tauri::command]
pub fn set_silent_start(app: tauri::AppHandle, enabled: bool) -> Result<(), String> {
    let mut settings = read_settings(&app).map_err(|e| e.to_string())?;
    settings.silent_start = enabled;
    save_settings(&app, &settings).map_err(|e| e.to_string())?;
    Ok(())
}
