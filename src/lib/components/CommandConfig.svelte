<script lang="ts">
    import { invoke } from '@tauri-apps/api/core';
    import { onMount } from 'svelte';
    import { Terminal, Play, Square, Settings, Plus, AlertCircle, Loader2 } from '@lucide/svelte';

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

<div class="flex flex-col h-full min-h-0">
    <!-- Header -->
    <div class="flex-shrink-0">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-lg font-bold text-gray-900">快捷命令配置</h2>
                <p class="text-sm text-gray-500">管理自定义命令和快捷方式</p>
            </div>
            <button
                class="px-3 py-1.5 bg-green-500 text-white text-sm rounded hover:bg-green-600 transition-colors cursor-pointer flex items-center gap-1.5"
            >
                <Plus class="w-4 h-4" />
                <span>添加命令</span>
            </button>
        </div>
    </div>

    <!-- Content with scroll -->
    <div
        class="flex-1 overflow-y-auto pr-2 -mr-2 mt-4 space-y-3 scrollbar-thin scrollbar-thumb-gray-300 scrollbar-track-transparent min-h-0"
    >
        {#if loading}
            <div class="flex items-center justify-center py-12">
                <div class="text-center">
                    <div
                        class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center mx-auto mb-3"
                    >
                        <Loader2 class="w-5 h-5 text-green-600 animate-spin" />
                    </div>
                    <p class="text-sm text-gray-500">正在加载命令配置...</p>
                </div>
            </div>
        {:else if error}
            <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                <div class="flex items-start gap-3">
                    <div
                        class="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center flex-shrink-0"
                    >
                        <AlertCircle class="w-4 h-4 text-red-600" />
                    </div>
                    <div class="flex-1">
                        <h3 class="text-sm font-medium text-red-800">加载失败</h3>
                        <p class="text-xs text-red-700 mt-1">{error}</p>
                        <button
                            onclick={loadCommands}
                            class="mt-2 px-3 py-1.5 bg-red-500 text-white text-xs rounded hover:bg-red-600 transition-colors cursor-pointer"
                        >
                            重试
                        </button>
                    </div>
                </div>
            </div>
        {:else}
            {#each Object.entries(commands) as [name, config] (name)}
                <div
                    class="bg-white border border-gray-200 rounded-lg p-4 transition-colors hover:bg-gray-50 flex-shrink-0"
                >
                    <div class="flex items-start justify-between gap-4">
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-2 mb-2">
                                <div
                                    class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center flex-shrink-0"
                                >
                                    <Terminal class="w-4 h-4 text-green-600" />
                                </div>
                                <div class="min-w-0">
                                    <h3 class="text-sm font-semibold text-gray-900 truncate">
                                        {name}
                                    </h3>
                                    <div class="flex items-center gap-2 mt-0.5">
                                        <kbd
                                            class="px-1.5 py-0.5 bg-gray-100 text-gray-700 text-xs rounded font-mono"
                                            >{config.key}</kbd
                                        >
                                        <span class="text-xs text-gray-500">AHK命令</span>
                                    </div>
                                </div>
                            </div>

                            <div
                                class="bg-gray-100 rounded p-2 font-mono text-xs text-gray-700 break-all"
                            >
                                {config.AHKcommand}
                            </div>

                            <div class="flex items-center justify-between mt-3">
                                <div class="flex items-center gap-1.5 text-xs">
                                    {#if config.isEnabled}
                                        <Play class="w-3.5 h-3.5 text-green-600" />
                                        <span class="text-green-600">已启用</span>
                                    {:else}
                                        <Square class="w-3.5 h-3.5 text-gray-400" />
                                        <span class="text-gray-500">已禁用</span>
                                    {/if}
                                </div>

                                <div class="flex items-center gap-2">
                                    <button
                                        class="p-1.5 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded transition-colors cursor-pointer"
                                    >
                                        <Settings class="w-4 h-4" />
                                    </button>

                                    <label class="relative inline-flex items-center cursor-pointer">
                                        <input
                                            type="checkbox"
                                            class="sr-only peer"
                                            checked={config.isEnabled}
                                            onchange={(e) =>
                                                toggleCommand(
                                                    name,
                                                    (e.target as HTMLInputElement).checked
                                                )}
                                        />
                                        <div
                                            class="w-10 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-green-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-green-500"
                                        ></div>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            {/each}
        {/if}
    </div>
</div>

<style>
    /* 自定义滚动条样式 */
    .scrollbar-thin::-webkit-scrollbar {
        width: 6px;
        height: 6px;
    }

    .scrollbar-thin::-webkit-scrollbar-track {
        background: transparent;
    }

    .scrollbar-thin::-webkit-scrollbar-thumb {
        background-color: #d1d5db;
        border-radius: 3px;
    }

    .scrollbar-thin::-webkit-scrollbar-thumb:hover {
        background-color: #9ca3af;
    }

    .scrollbar-thin {
        scrollbar-width: thin;
        scrollbar-color: #d1d5db transparent;
    }
</style>
