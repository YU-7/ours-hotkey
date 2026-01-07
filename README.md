# Ours Hotkey - 热键管理工具

基于 Tauri + SvelteKit + TypeScript 构建的热键管理工具。

## 功能特性

- 🖥️ 系统级热键配置
- ⌨️ Vim 模式支持
- ⚡ 快捷命令执行
- 🎨 无边框命令窗口
- 🔧 自动启动设置

## 新增功能：无边框命令窗口

### 功能说明
- 创建一个居中的无边框命令窗口
- 支持透明背景和模糊效果
- 窗口始终置顶，不显示在任务栏
- 支持键盘快捷键操作（Esc 关闭，Enter 执行）

### 如何测试
1. 启动应用
2. 进入"软件设置"页面
3. 点击"打开命令窗口"按钮
4. 在弹出的窗口中输入命令并按 Enter 执行，或按 Esc 关闭

### 命令行模式
你也可以通过环境变量直接启动命令窗口：
```bash
# 直接启动命令窗口
COMMAND_MODE=1 pnpm tauri dev

# 或构建后运行
COMMAND_MODE=1 ./src-tauri/target/debug/ours-hotkey.exe
```

### 技术实现
- 使用 Tauri 的 `decorations: false` 移除窗口边框
- 设置 `transparent: true` 实现透明背景
- 通过 `alwaysOnTop: true` 保持窗口置顶
- 使用 `skipTaskbar: true` 隐藏任务栏图标

## 开发环境设置

### 推荐 IDE 配置

[VS Code](https://code.visualstudio.com/) + [Svelte](https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode) + [Tauri](https://marketplace.visualstudio.com/items?itemName=tauri-apps.tauri-vscode) + [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer).

### 运行项目

```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev

# 构建应用
pnpm build

# 运行 Tauri 应用
pnpm tauri dev
```
