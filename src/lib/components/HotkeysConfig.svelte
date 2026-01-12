<script lang="ts">
  import { readJsonFile } from "$lib/file-utils";
  import { Keyboard, Plus, Loader2, AlertCircle } from "@lucide/svelte";
  import type { ConfigData } from "../../interface/types";
  import AhkScriptTester from "./AhkScriptTester.svelte";
  import SystemLevelConfig from "./SystemLevelConfig.svelte";

  interface Props {
    configData?: ConfigData | null;
    configError?: string | null;
    onConfigLoad?: () => void;
  }

  let {
    configData = $bindable(null),
    configError = $bindable(null),
    onConfigLoad,
  }: Props = $props();

  async function loadConfig() {
    try {
      configError = null;
      configData = await readJsonFile("system-level.json");
      onConfigLoad?.();
    } catch (error) {
      console.error("加载配置文件失败:", error);
      configError =
        error instanceof Error ? error.message : `未知错误：${String(error)}`;
    }
  }

  $effect(() => {
    loadConfig();
  });
</script>

<div class="space-y-4">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-lg font-bold text-gray-900">系统级热键配置</h2>
      <p class="text-sm text-gray-500">管理全局热键和系统级快捷方式</p>
    </div>
    <button class="px-3 py-1.5 bg-blue-500 text-white text-sm rounded hover:bg-blue-600 transition-colors cursor-pointer flex items-center gap-1.5">
      <Plus class="w-4 h-4" />
      新建热键
    </button>
  </div>

  <!-- Content -->
  {#if configError}
    <div class="bg-red-50 border border-red-200 rounded-lg p-4">
      <div class="flex items-start gap-3">
        <div class="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center flex-shrink-0">
          <AlertCircle class="w-4 h-4 text-red-600" />
        </div>
        <div>
          <h3 class="text-sm font-medium text-red-800">配置加载失败</h3>
          <p class="text-xs text-red-700 mt-1">{configError}</p>
        </div>
      </div>
    </div>
  {:else if configData}
    <AhkScriptTester />
  {:else}
    <div class="flex items-center justify-center py-12">
      <div class="text-center">
        <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-3">
          <Loader2 class="w-5 h-5 text-blue-600 animate-spin" />
        </div>
        <p class="text-sm text-gray-500">正在加载配置文件...</p>
      </div>
    </div>
  {/if}
</div>
