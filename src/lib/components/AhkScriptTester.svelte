<script lang="ts">
    import { invoke } from '@tauri-apps/api/core';
    import { Switch } from '@skeletonlabs/skeleton-svelte';
    import { Play, Square, RefreshCw, FileText, AlertCircle, CheckCircle } from '@lucide/svelte';

    let ahkStatus = $state<string>('');
    let isRunningAhk = $state(false);
    let pathTestResult = $state<string>('');
    let runningScripts = $state<string>('');

    let scriptStatuses = $state<Record<string, boolean>>({
        'global-hotkey': false,
        'vim-mode': false,
        'config/system-level': false,
    });

    async function toggleAhkScript(scriptName: string) {
        try {
            isRunningAhk = true;
            const isRunning = scriptStatuses[scriptName];

            if (isRunning) {
                ahkStatus = `正在停止 ${scriptName}.ahk...`;
                const result = await invoke<string>('stop_ahk_script', { scriptName });
                ahkStatus = result;
                scriptStatuses[scriptName] = false;
            } else {
                ahkStatus = `正在启动 ${scriptName}.ahk...`;
                const result = await invoke<string>('run_ahk_script', { scriptName });
                ahkStatus = result;
                scriptStatuses[scriptName] = true;
            }

            await updateScriptStatuses();
        } catch (error) {
            console.error('切换 AHK 脚本失败:', error);
            ahkStatus = `操作失败: ${error instanceof Error ? error.message : String(error)}`;
            await updateScriptStatuses();
        } finally {
            isRunningAhk = false;
        }
    }

    async function testAhkPaths() {
        try {
            pathTestResult = '正在测试路径...';
            const result = await invoke<string>('test_ahk_paths');
            pathTestResult = result;
        } catch (error) {
            console.error('测试路径失败:', error);
            pathTestResult = `测试失败: ${error instanceof Error ? error.message : String(error)}`;
        }
    }

    async function stopAllAhkScripts() {
        try {
            ahkStatus = '正在停止所有 AHK 脚本...';
            const result = await invoke<string>('stop_all_ahk_scripts');
            ahkStatus = result;
            await listRunningScripts();
            await updateScriptStatuses();
        } catch (error) {
            console.error('停止所有 AHK 脚本失败:', error);
            ahkStatus = `停止失败: ${error instanceof Error ? error.message : String(error)}`;
        }
    }

    async function listRunningScripts() {
        try {
            runningScripts = await invoke<string>('list_running_scripts');
        } catch (error) {
            console.error('获取运行脚本列表失败:', error);
            runningScripts = `获取失败: ${error instanceof Error ? error.message : String(error)}`;
        }
    }

    async function updateScriptStatuses() {
        try {
            const runningScriptsList = await invoke<string>('list_running_scripts');
            scriptStatuses['global-hotkey'] = false;
            scriptStatuses['vim-mode'] = false;
            scriptStatuses['config/system-level'] = false;

            if (!runningScriptsList.includes('No AHK scripts are currently running')) {
                const lines = runningScriptsList.split('\n');
                for (const line of lines) {
                    if (line.includes('- global-hotkey')) {
                        scriptStatuses['global-hotkey'] = true;
                    }
                    if (line.includes('- vim-mode')) {
                        scriptStatuses['vim-mode'] = true;
                    }
                    if (line.includes('- config/system-level')) {
                        scriptStatuses['config/system-level'] = true;
                    }
                }
            }
        } catch (error) {
            console.error('更新脚本状态失败:', error);
        }
    }

    $effect(() => {
        updateScriptStatuses();
    });
</script>

<div class="bg-white border border-gray-200 rounded-lg p-4">
    <h3 class="text-base font-semibold text-gray-900 mb-3">AHK 脚本测试</h3>
    <div class="space-y-3">
        <!-- 脚本开关 -->
        <div class="space-y-2">
            <div class="flex flex-wrap gap-4">
                <Switch
                    checked={scriptStatuses['global-hotkey']}
                    disabled={isRunningAhk}
                    onCheckedChange={() => toggleAhkScript('global-hotkey')}
                >
                    <Switch.Control>
                        {#if isRunningAhk}
                            <div
                                class="w-4 h-4 border-2 border-gray-300 border-t-blue-500 rounded-full animate-spin"
                            ></div>
                        {:else}
                            <Switch.Thumb />
                        {/if}
                    </Switch.Control>
                    <Switch.Label class="text-sm text-gray-700">全局热键脚本</Switch.Label>
                    <Switch.HiddenInput />
                </Switch>

                <Switch
                    checked={scriptStatuses['vim-mode']}
                    disabled={isRunningAhk}
                    onCheckedChange={() => toggleAhkScript('vim-mode')}
                >
                    <Switch.Control>
                        {#if isRunningAhk}
                            <div
                                class="w-4 h-4 border-2 border-gray-300 border-t-blue-500 rounded-full animate-spin"
                            ></div>
                        {:else}
                            <Switch.Thumb />
                        {/if}
                    </Switch.Control>
                    <Switch.Label class="text-sm text-gray-700">Vim 模式脚本</Switch.Label>
                    <Switch.HiddenInput />
                </Switch>

                <Switch
                    checked={scriptStatuses['config/system-level']}
                    disabled={isRunningAhk}
                    onCheckedChange={() => toggleAhkScript('config/system-level')}
                >
                    <Switch.Control>
                        {#if isRunningAhk}
                            <div
                                class="w-4 h-4 border-2 border-gray-300 border-t-blue-500 rounded-full animate-spin"
                            ></div>
                        {:else}
                            <Switch.Thumb />
                        {/if}
                    </Switch.Control>
                    <Switch.Label class="text-sm text-gray-700">系统级配置脚本</Switch.Label>
                    <Switch.HiddenInput />
                </Switch>
            </div>
        </div>

        <!-- 操作按钮 -->
        <div class="flex flex-wrap gap-2 pt-2">
            <button
                class="px-3 py-1.5 text-xs text-gray-600 bg-gray-100 hover:bg-gray-200 rounded transition-colors cursor-pointer flex items-center gap-1"
                onclick={testAhkPaths}
            >
                <RefreshCw class="w-3.5 h-3.5" />
                测试路径
            </button>
            <button
                class="px-3 py-1.5 text-xs text-white bg-orange-500 hover:bg-orange-600 rounded transition-colors cursor-pointer flex items-center gap-1"
                onclick={stopAllAhkScripts}
            >
                <Square class="w-3.5 h-3.5" />
                停止所有脚本
            </button>
            <button
                class="px-3 py-1.5 text-xs text-white bg-blue-500 hover:bg-blue-600 rounded transition-colors cursor-pointer flex items-center gap-1"
                onclick={listRunningScripts}
            >
                <FileText class="w-3.5 h-3.5" />
                查看运行脚本
            </button>
        </div>

        <!-- 状态显示 -->
        {#if ahkStatus}
            <div
                class="p-3 rounded-lg text-xs {ahkStatus.includes('失败') ||
                ahkStatus.includes('❌')
                    ? 'bg-red-50 border border-red-200 text-red-700'
                    : 'bg-green-50 border border-green-200 text-green-700'}"
            >
                <div class="flex items-center gap-2">
                    {#if ahkStatus.includes('失败') || ahkStatus.includes('❌')}
                        <AlertCircle class="w-3.5 h-3.5 flex-shrink-0" />
                    {:else}
                        <CheckCircle class="w-3.5 h-3.5 flex-shrink-0" />
                    {/if}
                    <span>{ahkStatus}</span>
                </div>
            </div>
        {/if}

        {#if runningScripts}
            <div class="p-3 bg-blue-50 border border-blue-200 rounded-lg">
                <pre
                    class="whitespace-pre-wrap text-xs text-blue-700 font-mono">{runningScripts}</pre>
            </div>
        {/if}

        {#if pathTestResult}
            <div class="p-3 bg-blue-50 border border-blue-200 rounded-lg">
                <pre
                    class="whitespace-pre-wrap text-xs text-blue-700 font-mono">{pathTestResult}</pre>
            </div>
        {/if}
    </div>
</div>
