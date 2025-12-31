<script lang="ts">
  import { readJsonFile } from "$lib/file-utils";
  import { invoke } from "@tauri-apps/api/core";
  import type { ConfigData } from "../../interface/types";
  import { Switch } from "@skeletonlabs/skeleton-svelte";

  interface Props {
    configData?: ConfigData | null;
    configError?: string | null;
    onConfigLoad?: () => void;
  }

  let { configData = $bindable(null), configError = $bindable(null), onConfigLoad }: Props = $props();

  let ahkStatus = $state<string>("");
  let isRunningAhk = $state(false);
  let pathTestResult = $state<string>("");
  let runningScripts = $state<string>("");

  // 脚本运行状态跟踪
  let scriptStatuses = $state<Record<string, boolean>>({
    "global-hotkey": false,
    "vim-mode": false,
    "config/system-level": false
  });

  async function loadConfig() {
    try {
      configError = null;
      configData = await readJsonFile("system-level.json");
      await updateScriptStatuses(); // 更新脚本运行状态
      onConfigLoad?.();
    } catch (error) {
      console.error("加载配置文件失败:", error);
      configError = error instanceof Error ? error.message : `未知错误：${String(error)}`;
    }
  }

  async function runAhkScript(scriptName: string) {
    try {
      isRunningAhk = true;
      ahkStatus = `正在运行 ${scriptName}.ahk...`;
      const result = await invoke<string>("run_ahk_script", { scriptName });
      ahkStatus = result;
      scriptStatuses[scriptName] = true;
      await updateScriptStatuses(); // 更新状态
    } catch (error) {
      console.error("运行 AHK 脚本失败:", error);
      ahkStatus = `❌ 运行失败: ${error instanceof Error ? error.message : String(error)}`;
    } finally {
      isRunningAhk = false;
    }
  }

  async function testAhkPaths() {
    try {
      pathTestResult = "正在测试路径...";
      const result = await invoke<string>("test_ahk_paths");
      pathTestResult = result;
    } catch (error) {
      console.error("测试路径失败:", error);
      pathTestResult = `❌ 测试失败: ${error instanceof Error ? error.message : String(error)}`;
    }
  }

  async function stopAhkScript(scriptName: string) {
    try {
      ahkStatus = `正在停止 ${scriptName}.ahk...`;
      const result = await invoke<string>("stop_ahk_script", { scriptName });
      ahkStatus = result;
      scriptStatuses[scriptName] = false;
      await updateScriptStatuses(); // 更新状态
    } catch (error) {
      console.error("停止 AHK 脚本失败:", error);
      ahkStatus = `❌ 停止失败: ${error instanceof Error ? error.message : String(error)}`;
    }
  }

  async function stopAllAhkScripts() {
    try {
      ahkStatus = "正在停止所有 AHK 脚本...";
      const result = await invoke<string>("stop_all_ahk_scripts");
      ahkStatus = result;
      await listRunningScripts(); // 更新运行脚本列表
      await updateScriptStatuses(); // 更新状态
    } catch (error) {
      console.error("停止所有 AHK 脚本失败:", error);
      ahkStatus = `❌ 停止失败: ${error instanceof Error ? error.message : String(error)}`;
    }
  }

  // 切换脚本运行状态
  async function toggleAhkScript(scriptName: string) {
    try {
      isRunningAhk = true;
      const isRunning = scriptStatuses[scriptName];

      if (isRunning) {
        // 停止脚本
        ahkStatus = `正在停止 ${scriptName}.ahk...`;
        const result = await invoke<string>("stop_ahk_script", { scriptName });
        ahkStatus = result;
        scriptStatuses[scriptName] = false;
      } else {
        // 启动脚本
        ahkStatus = `正在启动 ${scriptName}.ahk...`;
        const result = await invoke<string>("run_ahk_script", { scriptName });
        ahkStatus = result;
        scriptStatuses[scriptName] = true;
      }

      await updateScriptStatuses(); // 重新检查状态以确保准确性
    } catch (error) {
      console.error("切换 AHK 脚本失败:", error);
      ahkStatus = `❌ 操作失败: ${error instanceof Error ? error.message : String(error)}`;
      await updateScriptStatuses(); // 出错时也更新状态
    } finally {
      isRunningAhk = false;
    }
  }

  async function listRunningScripts() {
    try {
      runningScripts = await invoke<string>("list_running_scripts");
    } catch (error) {
      console.error("获取运行脚本列表失败:", error);
      runningScripts = `❌ 获取失败: ${error instanceof Error ? error.message : String(error)}`;
    }
  }

  // 更新脚本运行状态
  async function updateScriptStatuses() {
    try {
      const runningScriptsList = await invoke<string>("list_running_scripts");
      // 重置所有状态
      scriptStatuses["global-hotkey"] = false;
      scriptStatuses["vim-mode"] = false;
      scriptStatuses["config/system-level"] = false;

      // 根据运行列表更新状态
      if (!runningScriptsList.includes("No AHK scripts are currently running")) {
        const lines = runningScriptsList.split('\n');
        for (const line of lines) {
          if (line.includes('- global-hotkey')) {
            scriptStatuses["global-hotkey"] = true;
          }
          if (line.includes('- vim-mode')) {
            scriptStatuses["vim-mode"] = true;
          }
          if (line.includes('- config/system-level')) {
            scriptStatuses["config/system-level"] = true;
          }
        }
      }
    } catch (error) {
      console.error("更新脚本状态失败:", error);
    }
  }

  // 组件挂载时自动加载配置
  $effect(() => {
    loadConfig();
  });
</script>

<div class="p-6">
  <h2 class="text-xl font-semibold mb-4">系统级热键配置</h2>

  {#if configError}
    <div class="alert alert-error">
      <span>❌ 加载配置文件失败: {configError}</span>
    </div>
  {:else if configData}
    <div class="space-y-6">
      <!-- Windows 窗口操作 -->
      <div class="card p-4">
        <h3 class="text-lg font-medium mb-3">窗口操作</h3>
        <div class="grid gap-3">
          <div class="flex items-center justify-between p-3 bg-surface-100-800 rounded">
            <span class="font-medium">最大化窗口</span>
            <div class="flex items-center gap-2">
              <span class="text-sm text-surface-600-300">原始: {configData.Windows.Max.Oringin}</span>
              <span class="text-sm">→</span>
              <span class="badge badge-primary">{configData.Windows.Max.Remap}</span>
            </div>
          </div>
          <div class="flex items-center justify-between p-3 bg-surface-100-800 rounded">
            <span class="font-medium">最小化窗口</span>
            <div class="flex items-center gap-2">
              <span class="text-sm text-surface-600-300">原始: {configData.Windows.Min.Oringin}</span>
              <span class="text-sm">→</span>
              <span class="badge badge-primary">{configData.Windows.Min.Remap}</span>
            </div>
          </div>
          <div class="flex items-center justify-between p-3 bg-surface-100-800 rounded">
            <span class="font-medium">关闭窗口</span>
            <div class="flex items-center gap-2">
              <span class="text-sm text-surface-600-300">原始: {configData.Windows.Close.Oringin}</span>
              <span class="text-sm">→</span>
              <span class="badge badge-primary">{configData.Windows.Close.Remap}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 任务管理器 -->
      <div class="card p-4">
        <h3 class="text-lg font-medium mb-3">任务管理器</h3>
        <div class="space-y-3">
          <div class="flex items-center justify-between p-3 bg-surface-100-800 rounded">
            <span class="font-medium">打开任务管理器</span>
            <div class="flex items-center gap-2">
              <span class="text-sm text-surface-600-300">原始: {configData.TaskManger.Open.Oringin}</span>
              <span class="text-sm">→</span>
              <span class="badge badge-primary">{configData.TaskManger.Open.Remap}</span>
            </div>
          </div>

          <div class="p-3 bg-surface-100-800 rounded">
            <h4 class="font-medium mb-2">方向控制</h4>
            <div class="grid grid-cols-2 gap-2 text-sm">
              <div class="flex justify-between">
                <span>上移:</span>
                <span class="badge badge-secondary">{configData.TaskManger.Direction.Up}</span>
              </div>
              <div class="flex justify-between">
                <span>下移:</span>
                <span class="badge badge-secondary">{configData.TaskManger.Direction.Down}</span>
              </div>
              <div class="flex justify-between">
                <span>左移:</span>
                <span class="badge badge-secondary">{configData.TaskManger.Direction.Left}</span>
              </div>
              <div class="flex justify-between">
                <span>右移:</span>
                <span class="badge badge-secondary">{configData.TaskManger.Direction.Right}</span>
              </div>
              <div class="flex justify-between">
                <span>关闭:</span>
                <span class="badge badge-secondary">{configData.TaskManger.Direction.Close}</span>
              </div>
              <div class="flex justify-between">
                <span>确认:</span>
                <span class="badge badge-secondary">{configData.TaskManger.Direction.Enter}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- AHK 脚本测试区域 -->
      <div class="card p-4">
        <h3 class="text-lg font-medium mb-3">AHK 脚本测试</h3>
        <div class="space-y-3">
          <div class="space-y-2">
            <div class="flex gap-2 flex-wrap">
              <Switch
                checked={scriptStatuses['global-hotkey']}
                disabled={isRunningAhk}
                onCheckedChange={() => toggleAhkScript("global-hotkey")}
              >
                <Switch.Control>
                  {#if isRunningAhk}
                    <span class="loading loading-spinner loading-sm"></span>
                  {:else}
                    <Switch.Thumb />
                  {/if}
                </Switch.Control>
                <Switch.Label>全局热键脚本</Switch.Label>
                <Switch.HiddenInput />
              </Switch>

              <Switch
                checked={scriptStatuses['vim-mode']}
                disabled={isRunningAhk}
                onCheckedChange={() => toggleAhkScript("vim-mode")}
              >
                <Switch.Control>
                  {#if isRunningAhk}
                    <span class="loading loading-spinner loading-sm"></span>
                  {:else}
                    <Switch.Thumb />
                  {/if}
                </Switch.Control>
                <Switch.Label>Vim 模式脚本</Switch.Label>
                <Switch.HiddenInput />
              </Switch>

              <Switch
                checked={scriptStatuses['config/system-level']}
                disabled={isRunningAhk}
                onCheckedChange={() => toggleAhkScript("config/system-level")}
              >
                <Switch.Control>
                  {#if isRunningAhk}
                    <span class="loading loading-spinner loading-sm"></span>
                  {:else}
                    <Switch.Thumb />
                  {/if}
                </Switch.Control>
                <Switch.Label>系统级配置脚本</Switch.Label>
                <Switch.HiddenInput />
              </Switch>
            </div>
          </div>
          <div class="mt-4 flex gap-2 flex-wrap">
            <button
              class="btn btn-ghost btn-sm"
              onclick={testAhkPaths}
            >
              测试路径
            </button>
            <button
              class="btn btn-warning btn-sm"
              onclick={stopAllAhkScripts}
            >
              停止所有脚本
            </button>
            <button
              class="btn btn-info btn-sm"
              onclick={listRunningScripts}
            >
              查看运行脚本
            </button>
          </div>
          {#if ahkStatus}
            <div class="alert {ahkStatus.includes('❌') ? 'alert-error' : 'alert-success'}">
              <span>{ahkStatus}</span>
            </div>
          {/if}
          {#if runningScripts}
            <div class="alert alert-info">
              <pre class="whitespace-pre-wrap text-sm">{runningScripts}</pre>
            </div>
          {/if}
          {#if pathTestResult}
            <div class="alert alert-info">
              <pre class="whitespace-pre-wrap text-sm">{pathTestResult}</pre>
            </div>
          {/if}
        </div>
      </div>
    </div>
  {:else}
    <div class="flex justify-center items-center h-64">
      <div class="text-center">
        <p class="text-surface-600-300">正在加载配置文件...</p>
      </div>
    </div>
  {/if}
</div>
