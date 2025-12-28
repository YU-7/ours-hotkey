<script lang="ts">
  import { readJsonFile } from "$lib/file-utils";
  import type { ConfigData } from "../../interface/types";

  interface Props {
    configData?: ConfigData | null;
    configError?: string | null;
    onConfigLoad?: () => void;
  }

  let { configData = $bindable(null), configError = $bindable(null), onConfigLoad }: Props = $props();

  async function loadConfig() {
    try {
      configError = null;
      configData = await readJsonFile("system-level.json");
      onConfigLoad?.();
    } catch (error) {
      console.error("加载配置文件失败:", error);
      configError = error instanceof Error ? error.message : `未知错误：${String(error)}`;
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
    </div>
  {:else}
    <div class="flex justify-center items-center h-64">
      <div class="text-center">
        <p class="text-surface-600-300">正在加载配置文件...</p>
      </div>
    </div>
  {/if}
</div>
