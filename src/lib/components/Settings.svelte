<script lang="ts">
  import { onMount } from "svelte";
  import { checkAutostartStatus, toggleAutostart } from "$lib/autostart";
  import { getAppDataDir, ensureAppDataDir } from "$lib/file-utils";
  import { revealItemInDir } from "@tauri-apps/plugin-opener";

  let autostartEnabled = $state(false);
  let loading = $state(false);
  let appDataPath = $state<string>("");
  let errorMessage = $state<string>("");

  onMount(async () => {
    // 加载当前状态
    loading = true;
    errorMessage = "";
    try {
      autostartEnabled = await checkAutostartStatus();
      appDataPath = await getAppDataDir();

      // 确保应用数据目录存在
      if (appDataPath) {
        await ensureAppDataDir();
        console.log("应用数据目录已准备:", appDataPath);
      }
    } catch (error) {
      console.error("加载状态失败:", error);
      errorMessage = `加载失败: ${error instanceof Error ? error.message : String(error)}`;
    } finally {
      loading = false;
    }
  });

  async function handleAutostartToggle() {
    if (loading) return;

    loading = true;
    try {
      autostartEnabled = await toggleAutostart();
    } catch (error) {
      console.error("切换自动启动状态失败:", error);
      // 如果失败，恢复之前的状态
      autostartEnabled = await checkAutostartStatus();
    } finally {
      loading = false;
    }
  }

  async function openAppDataFolder() {
    if (!appDataPath) return;

    try {
      // 确保目录存在
      await ensureAppDataDir();

      // 在文件管理器中显示文件夹
      // revealItemInDir 用于在文件管理器中显示指定的文件或文件夹
      await revealItemInDir(appDataPath);
    } catch (error) {
      console.error("打开文件夹失败:", error);
      errorMessage = `打开文件夹失败: ${error instanceof Error ? error.message : String(error)}`;
      // 3秒后清除错误消息
      setTimeout(() => {
        errorMessage = "";
      }, 3000);
    }
  }
</script>

<div class="p-6 space-y-6">
  <h1 class="text-2xl font-bold">软件设置</h1>

  <div class="space-y-4">
    <!-- 开机自动启动设置 -->
    <div class="card p-4">
      <div class="flex items-center justify-between">
        <div class="flex flex-col gap-1">
          <h2 class="text-lg font-semibold">开机自动启动</h2>
          <p class="text-sm text-surface-600-300">
            启用后，应用将在系统启动时自动运行
          </p>
        </div>
        <label class="switch">
          <input
            type="checkbox"
            checked={autostartEnabled}
            disabled={loading}
            onchange={handleAutostartToggle}
          />
          <span class="slider"></span>
        </label>
      </div>
    </div>

    <!-- 应用数据目录 -->
    <div class="card p-4">
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-semibold">应用数据目录</h2>
        <p class="text-sm text-surface-600-300">应用的配置和数据文件存储位置</p>
        {#if errorMessage}
          <div class="mt-2 p-2 bg-error-500/20 text-error-500 text-xs rounded">
            {errorMessage}
          </div>
        {/if}
        {#if appDataPath}
          <div class="flex flex-col gap-2 mt-2">
            <div class="flex items-center gap-2">
              <code
                class="text-xs bg-surface-200-800 px-2 py-1 rounded flex-1 break-all"
              >
                {appDataPath}
              </code>
              <button
                class="btn btn-sm"
                onclick={openAppDataFolder}
                disabled={loading || !appDataPath}
              >
                打开文件夹
              </button>
            </div>
          </div>
        {:else if loading}
          <p class="text-sm text-surface-500-400">加载中...</p>
        {:else}
          <p class="text-sm text-surface-500-400">无法获取应用数据目录路径</p>
        {/if}
      </div>
    </div>
  </div>
</div>

<style>
  .switch {
    position: relative;
    display: inline-block;
    width: 50px;
    height: 24px;
  }

  .switch input {
    opacity: 0;
    width: 0;
    height: 0;
  }

  .slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: var(--color-surface-500);
    transition: 0.3s;
    border-radius: 24px;
  }

  .slider:before {
    position: absolute;
    content: "";
    height: 18px;
    width: 18px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: 0.3s;
    border-radius: 50%;
  }

  input:checked + .slider {
    background-color: var(--color-primary-500);
  }

  input:checked + .slider:before {
    transform: translateX(26px);
  }

  input:disabled + .slider {
    opacity: 0.5;
    cursor: not-allowed;
  }
</style>
