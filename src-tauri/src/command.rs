use std::path::PathBuf;
use std::process::Command;
use tauri::{AppHandle, Manager};

/// 获取 AHK 可执行文件路径
fn get_ahk_executable_path(app: &AppHandle) -> Result<PathBuf, String> {
    let resource_dir = app
        .path()
        .resource_dir()
        .map_err(|e| format!("获取资源目录失败: {}", e))?
        .join("_up_");

    let exe_name = if cfg!(target_arch = "x86_64") {
        "AutoHotkey64.exe"
    } else {
        "AutoHotkey32.exe"
    };

    let ahk_path = resource_dir.join("AutoHotkey").join(exe_name);

    if !ahk_path.exists() {
        return Err(format!("AHK可执行文件不存在: {}", ahk_path.display()));
    }

    Ok(ahk_path)
}

/// 获取 command.ahk 脚本路径
fn get_command_script_path(app: &AppHandle) -> Result<PathBuf, String> {
    let resource_dir = app
        .path()
        .resource_dir()
        .map_err(|e| format!("获取资源目录失败: {}", e))?
        .join("_up_");

    let script_path = resource_dir.join("AHK-script").join("command.ahk");

    if !script_path.exists() {
        return Err(format!("command.ahk 脚本不存在: {}", script_path.display()));
    }

    Ok(script_path)
}

/// 运行 command.ahk 脚本（带参数）
///
/// # Arguments
/// * `app` - Tauri 应用句柄
/// * `command_type` - 要执行的命令类型
///
/// # Returns
/// 成功返回执行结果消息，失败返回错误信息
#[tauri::command]
pub fn run_command(app: AppHandle, command_type: String) -> Result<String, String> {
    let ahk_path = get_ahk_executable_path(&app)?;
    let script_path = get_command_script_path(&app)?;

    // 构建命令
    let output = Command::new(&ahk_path)
        .arg(&script_path)
        .arg(&command_type)
        .output()
        .map_err(|e| format!("执行命令失败: {}", e))?;

    if output.status.success() {
        Ok(format!("命令 '{}' 执行成功", command_type))
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr);
        Err(format!(
            "命令 '{}' 执行失败: {}",
            command_type,
            if stderr.is_empty() {
                "未知错误".to_string()
            } else {
                stderr.to_string()
            }
        ))
    }
}

/// 直接运行 AHK 脚本（不通过进程管理器，适用于一次性命令）
#[tauri::command]
pub fn run_ahk_command(
    app: AppHandle,
    script_name: String,
    arguments: Vec<String>,
) -> Result<String, String> {
    let ahk_path = get_ahk_executable_path(&app)?;

    let resource_dir = app
        .path()
        .resource_dir()
        .map_err(|e| format!("获取资源目录失败: {}", e))?
        .join("_up_");

    let script_path = resource_dir
        .join("AHK-script")
        .join(format!("{}.ahk", script_name));

    if !script_path.exists() {
        return Err(format!(
            "AHK脚本 '{}' 不存在: {}",
            script_name,
            script_path.display()
        ));
    }

    // 构建命令参数
    let mut cmd = Command::new(&ahk_path);
    cmd.arg(&script_path);
    for arg in arguments {
        cmd.arg(arg);
    }

    // 异步执行，不等待结果
    let mut child = cmd.spawn().map_err(|e| format!("启动脚本失败: {}", e))?;

    let pid = child.id();

    // 等待一小段时间检查是否启动成功
    std::thread::sleep(std::time::Duration::from_millis(100));

    match child.try_wait() {
        Ok(Some(status)) => {
            if status.success() {
                Ok(format!("脚本 '{}' 执行完成 (PID: {})", script_name, pid))
            } else {
                Err(format!(
                    "脚本 '{}' 执行失败 (PID: {}, 退出码: {:?})",
                    script_name,
                    pid,
                    status.code()
                ))
            }
        }
        Ok(None) => {
            // 进程仍在运行，视为启动成功
            Ok(format!("脚本 '{}' 已启动 (PID: {})", script_name, pid))
        }
        Err(e) => Err(format!("检查进程状态失败: {}", e)),
    }
}
