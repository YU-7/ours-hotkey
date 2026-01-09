<script lang="ts">
  import { invoke } from '@tauri-apps/api/core';
  import { onMount } from 'svelte';

  interface CommandConfig {
    isEnabled: boolean;
    key: string;
    AHKcommand: string;
  }

  interface CommandData {
    [key: string]: CommandConfig;
  }

  let commands = $state<CommandData>({});
  let loading = $state(true);
  let error = $state<string | null>(null);

  async function loadCommands() {
    try {
      loading = true;
      error = null;
      const data = await invoke<CommandData>('get_command_config');
      commands = data;
    } catch (err) {
      error = err as string;
      console.error('加载命令配置失败:', err);
    } finally {
      loading = false;
    }
  }

  async function toggleCommand(commandName: string, isEnabled: boolean) {
    try {
      await invoke('update_command_config', { commandName, isEnabled });
      commands[commandName].isEnabled = isEnabled;
    } catch (err) {
      console.error('更新命令配置失败:', err);
      error = err as string;
    }
  }

  onMount(() => {
    loadCommands();
  });
</script>

<div class="p-6">
  <div class="max-w-4xl mx-auto">
    <h1 class="text-2xl font-bold mb-6">快捷命令配置</h1>

    {#if loading}
      <div class="flex justify-center items-center h-64">
        <div class="text-surface-600-300">加载中...</div>
      </div>
    {:else if error}
      <div class="bg-red-500/10 border border-red-500 text-red-500 p-4 rounded-lg">
        <p>加载失败: {error}</p>
        <button onclick={loadCommands} class="mt-2 px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600">
          重试
        </button>
      </div>
    {:else}
      <div class="space-y-4">
        {#each Object.entries(commands) as [name, config] (name)}
          <div class="bg-surface-100-900 border border-surface-200-800 rounded-lg p-4 flex items-center justify-between hover:bg-surface-200-800 transition-colors">
            <div class="flex-1">
              <h3 class="font-semibold text-lg">{name}</h3>
              <p class="text-sm text-surface-600-300 mt-1">
                快捷键: <span class="font-mono bg-surface-200-800 px-2 py-1 rounded">{config.key}</span>
              </p>
              <p class="text-sm text-surface-600-300 mt-1">
                AHK 命令: <span class="font-mono text-xs bg-surface-200-800 px-2 py-1 rounded">{config.AHKcommand}</span>
              </p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                class="sr-only peer"
                checked={config.isEnabled}
                onchange={(e) => toggleCommand(name, (e.target as HTMLInputElement).checked)}
              />
              <div class="w-11 h-6 bg-surface-300-700 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-surface-300-700 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
            </label>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>
