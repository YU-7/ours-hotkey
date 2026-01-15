## 修复 CapsLock 快捷键无法打开 command 页面的问题

### 问题原因
1. 全局快捷键插件 `tauri_plugin_global_shortcut` 未初始化
2. 异步函数 `open_command_window` 在同步上下文中调用未正确处理
3. 错误被忽略，无法调试问题
4. CapsLock 键可能不被完全支持

### 修复步骤
1. 在 `tauri::Builder::default()` 中添加 `.plugin(tauri_plugin_global_shortcut::init())`
2. 使用 `tauri::async_runtime::spawn` 来异步执行 `open_command_window`
3. 添加错误日志输出，便于调试
4. 添加调试日志确认快捷键触发状态
5. 如果 CapsLock 仍不工作，建议使用其他组合键（如 Ctrl+Space）作为替代方案