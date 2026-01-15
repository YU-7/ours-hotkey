## 改用环境变量方案（更兼容）

### 修改内容

1. **修改** **`tauri.conf.json`**

   * 移除刚才添加的 `cli` 配置

2. **修改** **`lib.rs`**

   * 使用 `std::env::var("OURSHOTKEY_COMMAND")` 检查环境变量

   * 使用方式：`$env:OURSHOTKEY_COMMAND=1; pnpm tauri dev`

