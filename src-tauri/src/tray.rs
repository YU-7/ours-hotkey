use tauri::menu::MenuBuilder;
use tauri::tray::TrayIconBuilder;
use tauri::Manager;
use tauri_plugin_log::log::{debug, info};

/// 创建托盘菜单
pub fn create_tray_menu<R: tauri::Runtime>(
    app: &tauri::AppHandle<R>,
) -> Result<tauri::menu::Menu<R>, tauri::Error> {
    let tray_menu = MenuBuilder::new(app)
        .text("open_main", "打开主页面")
        .separator()
        .text("quit_app", "关闭程序")
        .build()?;

    Ok(tray_menu)
}

/// 创建系统托盘
pub fn create_system_tray<R: tauri::Runtime>(
    app: &tauri::AppHandle<R>,
    tray_menu: &tauri::menu::Menu<R>,
) -> Result<tauri::tray::TrayIcon<R>, tauri::Error> {
    let tray = TrayIconBuilder::new()
        .icon(app.default_window_icon().unwrap().clone())
        .menu(tray_menu)
        .tooltip("ours-hotkey")
        .on_menu_event(move |app, event| {
            if event.id.as_ref() == "open_main" {
                if let Some(win) = app.get_webview_window("main") {
                    let _ = win.show();
                    let _ = win.set_focus();
                }
            } else if event.id.as_ref() == "quit_app" {
                // 退出应用前关闭所有AHK脚本
                info!("应用退出请求，关闭所有AHK脚本...");

                // 停止所有AHK脚本
                if let Some(manager) = app.try_state::<crate::ahk::AhkProcessManager>() {
                    let mut processes = manager.inner().lock();
                    let count = processes.len();

                    let mut stopped_count = 0;
                    for (_script_name, mut child) in processes.drain() {
                        if child.kill().is_ok() {
                            stopped_count += 1;
                        }
                    }

                    println!("已停止 {} 个AHK脚本中的 {} 个", count, stopped_count);
                } else {
                    println!("无法获取AHK进程管理器");
                }

                app.exit(0);
            }
        })
        .build(app)?;

    Ok(tray)
}

/// 设置系统托盘
pub fn setup_tray<R: tauri::Runtime>(app: &tauri::AppHandle<R>) -> Result<(), tauri::Error> {
    let tray_menu = create_tray_menu(app)?;
    let _tray = create_system_tray(app, &tray_menu)?;
    Ok(())
}
