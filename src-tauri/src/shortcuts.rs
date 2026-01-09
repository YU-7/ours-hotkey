use tauri_plugin_global_shortcut::{Code, GlobalShortcutExt, Shortcut, ShortcutState};

use crate::ahk;

pub fn register_global_shortcuts(app: &tauri::App) -> Result<(), Box<dyn std::error::Error>> {
    let f24_shortcut = Shortcut::new(None, Code::F24);
    let app_handle = app.handle().clone();
    
    app.handle().plugin(
        tauri_plugin_global_shortcut::Builder::new().with_handler(move |_app, shortcut, event| {
            println!("Shortcut triggered: {:?}", shortcut);
            if shortcut == &f24_shortcut {
                match event.state() {
                    ShortcutState::Pressed => {
                        println!("F24 Pressed! Opening command window...");
                        let handle = app_handle.clone();
                        tauri::async_runtime::spawn(async move {
                            match ahk::open_command_window(handle).await {
                                Ok(msg) => println!("Command window: {}", msg),
                                Err(e) => eprintln!("Failed to open command window: {}", e),
                            }
                        });
                    }
                    ShortcutState::Released => {
                        println!("F24 Released!");
                    }
                }
            }
        })
        .build(),
    )?;

    match app.global_shortcut().register(f24_shortcut) {
        Ok(_) => println!("F24 shortcut registered successfully"),
        Err(e) => eprintln!("Failed to register F24 shortcut: {}", e),
    };

    Ok(())
}
