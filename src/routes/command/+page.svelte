<script lang="ts">
  import { getCurrentWebviewWindow } from "@tauri-apps/api/webviewWindow";
  import { invoke } from "@tauri-apps/api/core";
  import { onMount } from "svelte";

  let commandInput = $state("");
  let commands = $state<
    Record<string, { isEnabled: boolean; key: string; AHKcommand: string }>
  >({});

  interface CommandConfig {
    isEnabled: boolean;
    key: string;
    AHKcommand: string;
  }

  interface CommandData {
    [key: string]: CommandConfig;
  }

  async function loadCommands() {
    try {
      const data = await invoke<CommandData>("get_command_config");
      commands = data;
    } catch (err) {
      console.error("加载命令配置失败:", err);
    }
  }

  async function checkCommand(input: string): Promise<void> {
    const inputLower = input.toLowerCase().trim();

    for (const [commandName, commandData] of Object.entries(commands)) {
      if (commandData.isEnabled) {
        const commandKey = commandData.key.toLowerCase();

        // 检查输入是否匹配命令的 key
        if (
          inputLower === commandKey ||
          inputLower === commandName.toLowerCase()
        ) {
          console.log("✅ 启用命令:", {
            name: commandName,
            key: commandData.key,
            ahkCommand: commandData.AHKcommand,
            isEnabled: commandData.isEnabled,
          });
          // 匹配成功后关闭页面
          const webview = getCurrentWebviewWindow();
          await webview.close();
          return;
        }
      }
    }
  }

  async function handleBlur() {
    // 输入框失去焦点时关闭页面
    const webview = getCurrentWebviewWindow();
    await webview.close();
  }
  import { getCurrentWebviewWindow } from "@tauri-apps/api/webviewWindow";
  import { invoke } from "@tauri-apps/api/core";
  import { onMount } from "svelte";

  let commandInput = $state("");
  let commands = $state<
    Record<string, { isEnabled: boolean; key: string; AHKcommand: string }>
  >({});
  let debounceTimer: number | undefined;

  interface CommandConfig {
    isEnabled: boolean;
    key: string;
    AHKcommand: string;
  }

  interface CommandData {
    [key: string]: CommandConfig;
  }

  async function loadCommands() {
    try {
      const data = await invoke<CommandData>("get_command_config");
      commands = data;
    } catch (err) {
      console.error("加载命令配置失败:", err);
    }
  }

  async function checkCommand(input: string): Promise<void> {
    const inputLower = input.toLowerCase().trim();

    for (const [commandName, commandData] of Object.entries(commands)) {
      if (commandData.isEnabled) {
        const commandKey = commandData.key.toLowerCase();

        // 检查输入是否匹配命令的 key
        if (
          inputLower === commandKey ||
          inputLower === commandName.toLowerCase()
        ) {
          console.log("✅ 启用命令:", {
            name: commandName,
            key: commandData.key,
            ahkCommand: commandData.AHKcommand,
            isEnabled: commandData.isEnabled,
          });
          // 匹配成功后关闭页面
          const webview = getCurrentWebviewWindow();
          await webview.close();
          return;
        }
      }
    }
  }

  async function handleBlur() {
    // 输入框失去焦点时关闭页面
    const webview = getCurrentWebviewWindow();
    await webview.close();
  }

  async function handleKeydown(event: KeyboardEvent) {
    if (event.key === "Escape") {
      const webview = getCurrentWebviewWindow();
      await webview.close();
    } else {
      // 清除之前的定时器
      if (debounceTimer) {
        clearTimeout(debounceTimer);
      }

      // 设置新的定时器，延迟执行命令检查
      debounceTimer = setTimeout(async () => {
        if (commandInput.trim().length >= 1) {
          // 至少输入一个字符才检查
          await checkCommand(commandInput);
        }
      }, 200); // 200ms 延迟
    }
  }

  let inputElement: HTMLInputElement | undefined = $state();

  onMount(async () => {
    await loadCommands();
    // 确保输入框获得焦点
    setTimeout(() => {
      inputElement?.focus();
    }, 100);
  });
</script>

<svelte:window on:keydown={handleKeydown} />

<div
  class="w-screen h-screen bg-black/50 backdrop-blur-sm flex items-center justify-center"
>
  <!-- svelte-ignore a11y_autofocus -->
  <input
    bind:value={commandInput}
    bind:this={inputElement}
    type="text"
    placeholder="输入命令..."
    class="px-4 py-2 bg-white/90 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent shadow-lg text-center min-w-80"
    autofocus
    onblur={handleBlur}
  />
</div>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    background: transparent !important;
  }
</style>
