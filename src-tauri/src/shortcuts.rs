use tauri_plugin_global_shortcut::{Code, GlobalShortcutExt, Shortcut, ShortcutState};

use crate::ahk;

pub fn register_global_shortcuts(app: &tauri::App) -> Result<(), Box<dyn std::error::Error>> {
    let capslock_shortcut = Shortcut::new(None, Code::CapsLock);
    let app_handle = app.handle().clone();
    
    app.handle().plugin(
        tauri_plugin_global_shortcut::Builder::new().with_handler(move |_app, shortcut, event| {
            println!("Shortcut triggered: {:?}", shortcut);
            if shortcut == &capslock_shortcut {
                match event.state() {
                    ShortcutState::Pressed => {
                        println!("CapsLock Pressed! Opening command window...");
                        let handle = app_handle.clone();
                        tauri::async_runtime::spawn(async move {
                            match ahk::open_command_window(handle).await {
                                Ok(msg) => println!("Command window: {}", msg),
                                Err(e) => eprintln!("Failed to open command window: {}", e),
                            }
                        });
                    }
                    ShortcutState::Released => {
                        println!("CapsLock Released!");
                    }
                }
            }
        })
        .build(),
    )?;

    match app.global_shortcut().register(capslock_shortcut) {
        Ok(_) => println!("CapsLock shortcut registered successfully"),
        Err(e) => eprintln!("Failed to register CapsLock shortcut: {}", e),
    };

    Ok(())
}
