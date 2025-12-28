<script lang="ts">
  import {
    ArrowLeftRightIcon,
    BikeIcon,
    BookIcon,
    HouseIcon,
    TreePalmIcon,
  } from "@lucide/svelte";
  import { Navigation } from "@skeletonlabs/skeleton-svelte";
  import Settings from "$lib/components/Settings.svelte";
  import { readJsonFile } from "$lib/file-utils";
  import type { ViewType, ConfigData } from "../interface/types";

  let configData = $state<ConfigData | null>(null);
  let configError = $state<string | null>(null);

  async function loadConfig() {
    try {
      configError = null;
      configData = await readJsonFile("system-level.json");
    } catch (error) {
      console.error("加载配置文件失败:", error);
      configError = error instanceof Error ? error.message : `未知错误：${String(error)}`;
    }
  }

  const links = [
    { label: "系统级热键", id: "hotkeys" as ViewType, icon: HouseIcon },
    { label: "快捷命令", id: "commands" as ViewType, icon: BookIcon },
    { label: "Vim模式", id: "vim" as ViewType, icon: BikeIcon },
    { label: "软件设置", id: "settings" as ViewType, icon: TreePalmIcon },
  ];

  const buttonClasses = "btn hover:preset-tonal";
  let anchorRail = `${buttonClasses} aspect-square w-full max-w-[84px] flex flex-col items-center gap-0.5`;
  let anchorSidebar = `${buttonClasses} justify-start px-2 w-full`;

  let layoutRail = $state(true);
  let currentView = $state<ViewType>("hotkeys");

  // 页面加载时读取配置文件
  $effect(() => {
    if (currentView === "hotkeys") {
      loadConfig();
    }
  });

  function toggleLayout() {
    layoutRail = !layoutRail;
  }

  function handleNavClick(viewId: ViewType) {
    currentView = viewId;
  }
</script>

<div
  class="w-full h-screen grid grid-cols-[auto_1fr] items-stretch border border-surface-200-800 overflow-hidden"
>
  <!-- --- -->
  <Navigation
    layout={layoutRail ? "rail" : "sidebar"}
    class={layoutRail
      ? "h-full overflow-hidden min-h-0 max-h-full"
      : "grid grid-rows-[1fr_auto] gap-4 h-full overflow-hidden min-h-0 max-h-full"}
    style="max-height: 100%; overflow: hidden;"
  >
    <Navigation.Content class="h-full overflow-hidden flex flex-col min-h-0">
      <Navigation.Header>
        <Navigation.Trigger onclick={toggleLayout}>
          <ArrowLeftRightIcon class={layoutRail ? "size-5" : "size-4"} />
          {#if !layoutRail}<span>Resize</span>{/if}
        </Navigation.Trigger>
      </Navigation.Header>
      <Navigation.Menu class="flex-1 overflow-y-auto min-h-0">
        {#each links as link (link)}
          {@const Icon = link.icon}
          <Navigation.TriggerAnchor
            onclick={() => handleNavClick(link.id)}
            class={currentView === link.id ? "bg-surface-300-700" : ""}
          >
            <Icon class={layoutRail ? "size-5" : "size-4"} />
            <Navigation.TriggerText>{link.label}</Navigation.TriggerText>
          </Navigation.TriggerAnchor>
        {/each}
      </Navigation.Menu>
    </Navigation.Content>
  </Navigation>
  <!-- --- -->
  <div class="overflow-hidden min-h-0 overflow-y-auto">
    {#if currentView === "settings"}
      <Settings />
    {:else if currentView === "hotkeys"}
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
    {:else if currentView === "commands"}
      <div class="flex justify-center items-center h-full p-6">
        <div class="text-center">
          <h2 class="text-xl font-semibold mb-2">快捷命令</h2>
          <p class="text-surface-600-300">功能开发中...</p>
        </div>
      </div>
    {:else if currentView === "vim"}
      <div class="flex justify-center items-center h-full p-6">
        <div class="text-center">
          <h2 class="text-xl font-semibold mb-2">Vim模式</h2>
          <p class="text-surface-600-300">功能开发中...</p>
        </div>
      </div>
    {/if}
  </div>
</div>
