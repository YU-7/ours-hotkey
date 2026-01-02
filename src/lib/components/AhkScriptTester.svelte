<script lang="ts">
  import { invoke } from "@tauri-apps/api/core";
  import { Switch } from "@skeletonlabs/skeleton-svelte";

  let ahkStatus = $state<string>("");
  let isRunningAhk = $state(false);
  let pathTestResult = $state<string>("");
  let runningScripts = $state<string>("");

  let scriptStatuses = $state<Record<string, boolean>>({
    "global-hotkey": false,
    "vim-mode": false,
    "config/system-level": false
  });

  async function toggleAhkScript(scriptName: string) {
    try {
      isRunningAhk = true;
      const isRunning = scriptStatuses[scriptName];

      if (isRunning) {
        ahkStatus = `正在停止 ${scriptName}.ahk...`;
        const result = await invoke<string>("stop_ahk_script", { scriptName });
        ahkStatus = result;
        scriptStatuses[scriptName] = false;
      } else {
        ahkStatus = `正在启动 ${scriptName}.ahk...`;
        const result = await invoke<string>("run_ahk_script", { scriptName });
        ahkStatus = result;
        scriptStatuses[scriptName] = true;
      }

      await updateScriptStatuses();
    } catch (error) {
      console.error("切换 AHK 脚本失败:", error);
      ahkStatus = `❌ 操作失败: ${error instanceof Error ? error.message : String(error)}`;
      await updateScriptStatuses();
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

  async function stopAllAhkScripts() {
    try {
      ahkStatus = "正在停止所有 AHK 脚本...";
      const result = await invoke<string>("stop_all_ahk_scripts");
      ahkStatus = result;
      await listRunningScripts();
      await updateScriptStatuses();
    } catch (error) {
      console.error("停止所有 AHK 脚本失败:", error);
      ahkStatus = `❌ 停止失败: ${error instanceof Error ? error.message : String(error)}`;
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

  async function updateScriptStatuses() {
    try {
      const runningScriptsList = await invoke<string>("list_running_scripts");
      scriptStatuses["global-hotkey"] = false;
      scriptStatuses["vim-mode"] = false;
      scriptStatuses["config/system-level"] = false;

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

  $effect(() => {
    updateScriptStatuses();
  });
</script>

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
