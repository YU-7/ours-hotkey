// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/

use std::collections::HashMap;
use std::sync::Mutex;
use tauri::Manager;

mod ahk;
mod hooks;
mod shortcuts;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_single_instance::init(|app, _args, _cwd| {
            // 当用户尝试打开第二个实例时，聚焦到已存在的窗口
            let _ = app
                .get_webview_window("main")
                .expect("no main window")
                .set_focus();
        }))
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
                hooks::auto_start_scripts(&app.handle())?;
                // 注册应用退出时的清理钩子
                hooks::setup_exit_cleanup(app.handle())?;

                // 注册全局快捷键
                shortcuts::register_global_shortcuts(app)?;
            }
            Ok(())
        })
        .manage(ahk::AhkProcessManager(Mutex::new(HashMap::new())))
        .invoke_handler(tauri::generate_handler![
            ahk::run_ahk_script,
            ahk::stop_ahk_script,
            ahk::stop_all_ahk_scripts,
            ahk::list_running_scripts,
            ahk::test_ahk_paths,
            ahk::open_command_window,
            ahk::get_command_config,
            ahk::update_command_config
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
