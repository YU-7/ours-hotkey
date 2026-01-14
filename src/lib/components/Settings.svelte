<script lang="ts">
  import { onMount } from "svelte";
  import { checkAutostartStatus, toggleAutostart, getSilentStartStatus, setSilentStart } from "$lib/auto-start";
  import { getAppDataDir, ensureAppDataDir } from "$lib/file-utils";
  import { revealItemInDir } from "@tauri-apps/plugin-opener";
  import { invoke } from "@tauri-apps/api/core";
  import { Power, Folder, Terminal, Loader2, AlertCircle, ExternalLink, Moon } from "@lucide/svelte";

  let autostartEnabled = $state(false);
  let silentStartEnabled = $state(false);
  let loading = $state(false);
  let appDataPath = $state<string>("");
  let errorMessage = $state<string>("");

  onMount(async () => {
    loading = true;
    errorMessage = "";
    try {
      autostartEnabled = await checkAutostartStatus();
      silentStartEnabled = await getSilentStartStatus();
      appDataPath = await getAppDataDir();

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
      autostartEnabled = await toggleAutostart(silentStartEnabled);
    } catch (error) {
      console.error("切换自动启动状态失败:", error);
      autostartEnabled = await checkAutostartStatus();
    } finally {
      loading = false;
    }
  }

  async function handleSilentStartToggle() {
    if (loading) return;

    loading = true;
    try {
      silentStartEnabled = !silentStartEnabled;
      await setSilentStart(silentStartEnabled);
      // 如果自动启动已启用，重新启用以应用静默启动参数
      if (autostartEnabled) {
        await toggleAutostart(silentStartEnabled);
        autostartEnabled = true;
      }
    } catch (error) {
      console.error("切换静默启动状态失败:", error);
      silentStartEnabled = await getSilentStartStatus();
    } finally {
      loading = false;
    }
  }

  async function openAppDataFolder() {
    if (!appDataPath) return;

    try {
      await ensureAppDataDir();
      await revealItemInDir(appDataPath);
    } catch (error) {
      console.error("打开文件夹失败:", error);
      errorMessage = `打开文件夹失败: ${error instanceof Error ? error.message : String(error)}`;
      setTimeout(() => {
        errorMessage = "";
      }, 3000);
    }
  }

  async function openCommandWindow() {
    try {
      const result = await invoke("open_command_window");
      console.log("命令窗口已打开:", result);
    } catch (error) {
      console.error("打开命令窗口失败:", error);
      errorMessage = `打开命令窗口失败: ${error instanceof Error ? error.message : String(error)}`;
      setTimeout(() => {
        errorMessage = "";
      }, 3000);
    }
  }
</script>

<div class="space-y-4">
  <div>
    <h2 class="text-lg font-bold text-gray-900">软件设置</h2>
    <p class="text-sm text-gray-500">管理应用配置和首选项</p>
  </div>

  <div class="space-y-3">
    <!-- 开机自动启动设置 -->
    <div class="bg-white border border-gray-200 rounded-lg p-4">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 bg-blue-100 rounded-lg flex items-center justify-center">
            <Power class="w-4 h-4 text-blue-600" />
          </div>
          <div>
            <h3 class="text-sm font-semibold text-gray-900">开机自动启动</h3>
            <p class="text-xs text-gray-500">启用后，应用将在系统启动时自动运行</p>
          </div>
        </div>
        <label class="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            class="sr-only peer"
            checked={autostartEnabled}
            disabled={loading}
            onchange={handleAutostartToggle}
          />
          <div class="w-10 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-blue-500 {loading ? 'opacity-50 cursor-not-allowed' : ''}"></div>
        </label>
      </div>
    </div>

    <!-- 静默启动设置 -->
    <div class="bg-white border border-gray-200 rounded-lg p-4 ml-4">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 bg-indigo-100 rounded-lg flex items-center justify-center">
            <Moon class="w-4 h-4 text-indigo-600" />
          </div>
          <div>
            <h3 class="text-sm font-semibold text-gray-900">静默启动</h3>
            <p class="text-xs text-gray-500">启用后，开机启动时不显示主窗口</p>
          </div>
        </div>
        <label class="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            class="sr-only peer"
            checked={silentStartEnabled}
            disabled={loading || !autostartEnabled}
            onchange={handleSilentStartToggle}
          />
          <div class="w-10 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-indigo-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-indigo-500 {loading || !autostartEnabled ? 'opacity-50 cursor-not-allowed' : ''}"></div>
        </label>
      </div>
    </div>

    <!-- 应用数据目录 -->
    <div class="bg-white border border-gray-200 rounded-lg p-4">
      <div class="flex items-start gap-3">
        <div class="w-9 h-9 bg-gray-100 rounded-lg flex items-center justify-center flex-shrink-0">
          <Folder class="w-4 h-4 text-gray-600" />
        </div>
        <div class="flex-1 min-w-0">
          <h3 class="text-sm font-semibold text-gray-900">应用数据目录</h3>
          <p class="text-xs text-gray-500 mt-0.5">应用的配置和数据文件存储位置</p>
          
          {#if errorMessage}
            <div class="mt-2 p-2 bg-red-50 border border-red-200 rounded text-xs text-red-700 flex items-center gap-1.5">
              <AlertCircle class="w-3.5 h-3.5" />
              {errorMessage}
            </div>
          {/if}
          
          {#if appDataPath}
            <div class="flex items-center gap-2 mt-2">
              <code class="text-xs bg-gray-100 text-gray-700 px-2 py-1.5 rounded flex-1 break-all font-mono">
                {appDataPath}
              </code>
              <button
                class="px-2.5 py-1.5 text-xs text-gray-600 bg-gray-100 hover:bg-gray-200 rounded transition-colors cursor-pointer flex items-center gap-1"
                onclick={openAppDataFolder}
                disabled={loading || !appDataPath}
              >
                <ExternalLink class="w-3.5 h-3.5" />
                打开
              </button>
            </div>
          {:else if loading}
            <div class="flex items-center gap-2 mt-2 text-xs text-gray-500">
              <Loader2 class="w-3.5 h-3.5 animate-spin" />
              加载中...
            </div>
          {:else}
            <p class="text-xs text-gray-500 mt-2">无法获取应用数据目录路径</p>
          {/if}
        </div>
      </div>
    </div>

    <!-- 测试命令窗口 -->
    <div class="bg-white border border-gray-200 rounded-lg p-4">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 bg-purple-100 rounded-lg flex items-center justify-center">
            <Terminal class="w-4 h-4 text-purple-600" />
          </div>
          <div>
            <h3 class="text-sm font-semibold text-gray-900">测试功能</h3>
            <p class="text-xs text-gray-500">测试无边框命令窗口功能</p>
          </div>
        </div>
        <button
          class="px-3 py-1.5 text-xs text-white bg-purple-500 hover:bg-purple-600 rounded transition-colors cursor-pointer"
          onclick={openCommandWindow}
          disabled={loading}
        >
          打开命令窗口
        </button>
      </div>
    </div>
  </div>
</div>
