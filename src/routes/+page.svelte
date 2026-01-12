<script lang="ts">
  import {
    Keyboard,
    Zap,
    Settings,
    Terminal,
    Plus,
    RefreshCw,
  } from "@lucide/svelte";
  import SettingsPage from "$lib/components/Settings.svelte";
  import HotkeysConfig from "$lib/components/HotkeysConfig.svelte";
  import CommandConfig from "$lib/components/CommandConfig.svelte";
  import type { ViewType } from "../interface/types";

  const menuItems = [
    { label: "热键配置", id: "hotkeys" as ViewType, icon: Keyboard, color: "bg-blue-500" },
    { label: "命令配置", id: "commands" as ViewType, icon: Terminal, color: "bg-green-500" },
    { label: "Vim模式", id: "vim" as ViewType, icon: Zap, color: "bg-purple-500" },
    { label: "设置", id: "settings" as ViewType, icon: Settings, color: "bg-gray-500" },
  ];

  let currentView = $state<ViewType>("hotkeys");

  function handleMenuClick(viewId: ViewType) {
    currentView = viewId;
  }
</script>

<div class="min-h-screen bg-gray-100">
  <!-- Header -->
  <header class="bg-white border-b border-gray-200 px-8 py-4">
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 bg-blue-500 rounded-lg flex items-center justify-center">
          <Keyboard class="w-5 h-5 text-white" />
        </div>
        <h1 class="text-xl font-bold text-gray-900">Ours Hotkey</h1>
      </div>
      <div class="flex items-center gap-2">
        <button class="px-3 py-1.5 text-sm text-gray-600 bg-gray-100 hover:bg-gray-200 rounded transition-colors cursor-pointer">
          测试热键
        </button>
        <button class="px-3 py-1.5 text-sm text-gray-600 bg-gray-100 hover:bg-gray-200 rounded transition-colors cursor-pointer">
          重载配置
        </button>
      </div>
    </div>
  </header>

  <div class="flex">
    <!-- Sidebar -->
    <aside class="w-64 bg-white border-r border-gray-200 min-h-[calc(100vh-73px)]">
      <nav class="p-4">
        <div class="space-y-1">
          {#each menuItems as item (item.id)}
            {@const Icon = item.icon}
            <button
              onclick={() => handleMenuClick(item.id)}
              class="w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-colors cursor-pointer {currentView === item.id ? 'bg-blue-50 text-blue-600' : 'text-gray-600 hover:bg-gray-50'}"
            >
              <div class="w-8 h-8 {item.color} rounded-lg flex items-center justify-center">
                <Icon class="w-4 h-4 text-white" />
              </div>
              <span class="font-medium text-sm">{item.label}</span>
            </button>
          {/each}
        </div>
      </nav>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 p-6">
      {#if currentView === "settings"}
        <SettingsPage />
      {:else if currentView === "hotkeys"}
        <HotkeysConfig />
      {:else if currentView === "commands"}
        <CommandConfig />
      {:else if currentView === "vim"}
        <div class="flex items-center justify-center h-full">
          <div class="text-center">
            <div class="w-16 h-16 bg-purple-100 rounded-lg flex items-center justify-center mx-auto mb-4">
              <Zap class="w-8 h-8 text-purple-600" />
            </div>
            <h2 class="text-lg font-semibold text-gray-900 mb-2">Vim模式</h2>
            <p class="text-gray-500 text-sm max-w-sm">Vim风格的键盘导航模式正在开发中...</p>
          </div>
        </div>
      {/if}
    </main>
  </div>
</div>
