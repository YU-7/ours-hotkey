<script lang="ts">
  import { readJsonFile } from "$lib/file-utils";
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

<div class="p-6">
  <h2 class="text-xl font-semibold mb-4">系统级热键配置</h2>

  {#if configError}
    <div class="alert alert-error">
      <span>❌ 加载配置文件失败: {configError}</span>
    </div>
  {:else if configData}
    <!-- <SystemLevelConfig {configData} /> -->
    <AhkScriptTester />
  {:else}
    <div class="flex justify-center items-center h-64">
      <div class="text-center">
        <p class="text-surface-600-300">正在加载配置文件...</p>
      </div>
    </div>
  {/if}
</div>
