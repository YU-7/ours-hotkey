use tauri::image::Image;
use tauri::menu::MenuBuilder;
use tauri::tray::TrayIconBuilder;
use tauri::Manager;

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
    // 加载托盘图标 - 使用 Tauri 2.0 的 Image::new 方法
    // 32x32.png 是 32x32 像素的图标
    let icon_bytes = include_bytes!("../icons/32x32.png");
    let icon = Image::new(icon_bytes, 32, 32);

    let tray = TrayIconBuilder::new()
        .icon(icon)
        .menu(tray_menu)
        .tooltip("ours-hotkey")
        .on_menu_event(move |app, event| {
            if event.id.as_ref() == "open_main" {
                if let Some(win) = app.get_webview_window("main") {
                    let _ = win.show();
                    let _ = win.set_focus();
                }
            } else if event.id.as_ref() == "quit_app" {
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
