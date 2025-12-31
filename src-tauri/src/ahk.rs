use std::collections::HashMap;
use std::path::PathBuf;
use std::process::{Child, Command};
use std::sync::Mutex;
use tauri::{AppHandle, Manager, State};

// 用于管理运行中的 AHK 进程
pub struct AhkProcessManager(pub Mutex<HashMap<String, Child>>);

/// 内部函数：启动 AHK 脚本（不作为 tauri command 导出）
pub fn start_ahk_script_internal(app: &AppHandle, script_name: &str, manager: &AhkProcessManager) -> Result<String, String> {
    let ahk_path = get_ahk_executable_path(app)?;
    let script_path = get_script_path(app, script_name)?;

    if !script_path.exists() {
        return Err(format!("AHK script '{}' not found at {:?}", script_name, script_path));
    }

    // 检查脚本是否已经在运行并启动
    let mut processes = manager.0.lock().unwrap();
    if processes.contains_key(script_name) {
        return Err(format!("AHK script '{}' is already running", script_name));
    }

    // 在后台启动 AutoHotkey 脚本，不阻塞主进程
    let child = Command::new(&ahk_path)
        .arg(&script_path)
        .spawn()
        .map_err(|e| format!("Failed to start AHK script: {}", e))?;

    let pid = child.id();
    processes.insert(script_name.to_string(), child);

    Ok(format!("AHK script '{}' started successfully (PID: {})", script_name, pid))
}

#[tauri::command]
pub fn run_ahk_script(app: AppHandle, script_name: String, manager: State<'_, AhkProcessManager>) -> Result<String, String> {
    let manager_ref = manager.inner();
    start_ahk_script_internal(&app, &script_name, manager_ref)
}

#[tauri::command]
pub fn stop_ahk_script(script_name: String, manager: State<'_, AhkProcessManager>) -> Result<String, String> {
    let mut processes = manager.0.lock().unwrap();

    if let Some(mut child) = processes.remove(&script_name) {
        match child.kill() {
            Ok(_) => Ok(format!("AHK script '{}' stopped successfully", script_name)),
            Err(e) => Err(format!("Failed to stop AHK script '{}': {}", script_name, e)),
        }
    } else {
        Err(format!("AHK script '{}' is not running", script_name))
    }
}

#[tauri::command]
pub fn stop_all_ahk_scripts(manager: State<'_, AhkProcessManager>) -> Result<String, String> {
    let mut processes = manager.0.lock().unwrap();
    let count = processes.len();

    let mut stopped_count = 0;
    for (_script_name, mut child) in processes.drain() {
        if child.kill().is_ok() {
            stopped_count += 1;
        }
    }

    Ok(format!("Stopped {} out of {} AHK scripts", stopped_count, count))
}

#[tauri::command]
pub fn list_running_scripts(manager: State<'_, AhkProcessManager>) -> Result<String, String> {
    let processes = manager.0.lock().unwrap();
    if processes.is_empty() {
        return Ok("No AHK scripts are currently running".to_string());
    }

    let mut result = "Running AHK scripts:\n".to_string();
    for (script_name, child) in processes.iter() {
        result.push_str(&format!("- {} (PID: {})\n", script_name, child.id()));
    }

    Ok(result)
}

fn get_ahk_executable_path(app: &AppHandle) -> Result<PathBuf, String> {
    // 获取Tauri资源目录路径
    let resource_dir = app.path().resource_dir()
        .map_err(|e| format!("获取资源目录失败: {}", e))?
        .join("_up_"); // 无论开发还是生产模式，资源都在 _up_ 子目录中

    let exe_name = if cfg!(target_arch = "x86_64") {
        "AutoHotkey64.exe"
    } else {
        "AutoHotkey32.exe"
    };

    let ahk_path = resource_dir.join("AutoHotkey").join(exe_name);

    if !ahk_path.exists() {
        return Err(format!("AHK可执行文件不存在: {} (资源目录: {})", ahk_path.display(), resource_dir.display()));
    }

    Ok(ahk_path)
}

fn get_script_path(app: &AppHandle, script_name: &str) -> Result<PathBuf, String> {
    // 获取Tauri资源目录路径
    let resource_dir = app.path().resource_dir()
        .map_err(|e| format!("获取资源目录失败: {}", e))?
        .join("_up_"); // 无论开发还是生产模式，资源都在 _up_ 子目录中

    let script_path = resource_dir.join("AHK-script").join(format!("{}.ahk", script_name));
    Ok(script_path)
}

#[tauri::command]
pub fn test_ahk_paths(app: AppHandle) -> Result<String, String> {
    // 获取Tauri资源目录路径
    let resource_dir = app.path().resource_dir()
        .map_err(|e| format!("获取资源目录失败: {}", e))?
        .join("_up_"); // 无论开发还是生产模式，资源都在 _up_ 子目录中

    let exe_name = if cfg!(target_arch = "x86_64") {
        "AutoHotkey64.exe"
    } else {
        "AutoHotkey32.exe"
    };

    let ahk_path = resource_dir.join("AutoHotkey").join(exe_name);
    let script_path = resource_dir.join("AHK-script/global-hotkey.ahk");

    let mut result = format!("Resource dir: {:?}\n", resource_dir);
    result.push_str(&format!("AHK exe exists: {}\n", ahk_path.exists()));
    result.push_str(&format!("AHK exe path: {:?}\n", ahk_path));
    result.push_str(&format!("Script exists: {}\n", script_path.exists()));
    result.push_str(&format!("Script path: {:?}\n", script_path));

    Ok(result)
}
