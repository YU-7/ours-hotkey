<script lang="ts">
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

  async function checkCommand(input: string): Promise<boolean> {
    const inputLower = input.toLowerCase().trim();
    console.log("checkCommand 检查输入:", input, "->", inputLower);

    for (const [commandName, commandData] of Object.entries(commands)) {
      if (commandData.isEnabled) {
        const commandKey = commandData.key.toLowerCase();

        console.log("检查命令:", commandName, "key:", commandKey);

        // 检查输入是否匹配命令的 key
        if (inputLower === commandKey) {
          console.log("✅ 启用命令:", {
            name: commandName,
            key: commandData.key,
            ahkCommand: commandData.AHKcommand,
            isEnabled: commandData.isEnabled,
          });

          // 执行 AHK 命令
          try {
            const result = await invoke("run_ahk_command", {
              scriptName: "command",
              arguments: [commandData.AHKcommand],
            });
            console.log("命令执行成功:", commandData.AHKcommand, result);
          } catch (err) {
            console.error("命令执行失败:", err);
          }

          // 匹配成功后关闭页面
          const webview = getCurrentWebviewWindow();
          await webview.close();
          return true;
        }
      }
    }
    console.log("没有匹配的命令，关闭页面");
    return false;
  }

  async function handleBlur() {
    // 输入框失去焦点时不直接关闭，让窗口级别的 blur 事件处理
    console.log("输入框失去焦点");
  }

  async function handleWindowBlur() {
    // 先清除定时器
    if (debounceTimer) {
      clearTimeout(debounceTimer);
      debounceTimer = undefined;
    }

    // 检查是否有命令需要执行
    if (commandInput.trim().length >= 1) {
      await checkCommand(commandInput);
    } else {
      // 没有命令时直接关闭页面
      const webview = getCurrentWebviewWindow();
      await webview.close();
    }
  }

  async function handleKeydown(event: KeyboardEvent) {
    if (event.key === "Escape") {
      console.log("按 Escape 关闭");
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
          console.log("定时器触发，执行命令检查...");
          // 至少输入一个字符才检查
          await checkCommand(commandInput);
        }
      }, 250); // 250ms 延迟
    }
  }

  let inputElement: HTMLInputElement | undefined = $state();

  onMount(async () => {
    await loadCommands();

    // 窗口打开时设置焦点
    const webview = getCurrentWebviewWindow();
    await webview.setFocus();

    // 确保输入框获得焦点
    setTimeout(() => {
      inputElement?.focus();
    }, 100);
  });
</script>

<svelte:window on:keydown={handleKeydown} on:blur={handleWindowBlur} />

<div class="w-screen h-screen bg-black/60 backdrop-blur-sm flex items-center justify-center p-8">
  <div class="w-full max-w-md">
    <!-- Search Box -->
    <div class="bg-white rounded-xl shadow-2xl overflow-hidden">
      <div class="px-6 py-4">
        <div class="flex items-center space-x-3">
          <div class="w-5 h-5 text-gray-400">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
          </div>
          <!-- svelte-ignore a11y_autofocus -->
          <input
            bind:value={commandInput}
            bind:this={inputElement}
            type="text"
            placeholder="输入命令或搜索..."
            class="flex-1 text-lg text-gray-900 placeholder-gray-500 focus:outline-none bg-transparent"
            autofocus
            onblur={handleBlur}
          />
        </div>
      </div>

      <!-- Footer -->
      <div class="px-6 py-3 bg-gray-50 border-t border-gray-200">
        <div class="flex items-center justify-between text-xs text-gray-500">
          <span>输入命令并按回车执行</span>
          <span>ESC 关闭</span>
        </div>
      </div>
    </div>

    <!-- Quick Commands Hint -->
    {#if Object.keys(commands).length > 0}
      <div class="mt-4 text-center">
        <p class="text-white/80 text-sm">
          支持 {Object.values(commands).filter(cmd => cmd.isEnabled).length} 个命令
        </p>
      </div>
    {/if}
  </div>
</div>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    background: transparent !important;
  }
</style>
