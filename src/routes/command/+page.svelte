<script lang="ts">
    import { getCurrentWebviewWindow } from '@tauri-apps/api/webviewWindow';
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

    let commandInput = $state('');
    let commands = $state<CommandData>({});
    let debounceTimer: number | undefined;
    let inputElement: HTMLInputElement | undefined = $state();

    async function loadCommands() {
        try {
            const data = await invoke<CommandData>('get_command_config');
            commands = data;
        } catch (err) {
            console.error('加载命令配置失败:', err);
        }
    }

    async function checkCommand(input: string): Promise<boolean> {
        const inputLower = input.toLowerCase().trim();
        console.log('checkCommand 检查输入:', input, '->', inputLower);

        for (const [commandName, commandData] of Object.entries(commands)) {
            if (commandData.isEnabled) {
                const commandKey = commandData.key.toLowerCase();

                console.log('检查命令:', commandName, 'key:', commandKey);

                // 检查输入是否匹配命令的 key
                if (inputLower === commandKey) {
                    console.log('✅ 启用命令:', {
                        name: commandName,
                        key: commandData.key,
                        ahkCommand: commandData.AHKcommand,
                        isEnabled: commandData.isEnabled,
                    });

                    // 执行 AHK 命令
                    try {
                        const result = await invoke('run_ahk_command', {
                            scriptName: 'command',
                            arguments: [commandData.AHKcommand],
                        });
                        console.log('命令执行成功:', commandData.AHKcommand, result);
                    } catch (err) {
                        console.error('命令执行失败:', err);
                    }

                    // 匹配成功后关闭页面
                    const webview = getCurrentWebviewWindow();
                    await webview.close();
                    return true;
                }
            }
        }
        console.log('没有匹配的命令，关闭页面');
        return false;
    }

    async function handleBlur() {
        // 输入框失去焦点时不直接关闭，让窗口级别的 blur 事件处理
        console.log('输入框失去焦点');
    }

    async function handleWindowBlur() {
        // 先清除定时器
        if (debounceTimer) {
            clearTimeout(debounceTimer);
            debounceTimer = undefined;
        }

        // 检查是否有命令需要执行
        if (commandInput.trim().length >= 1) {
            await checkCommand(commandInput);
        } else {
            // 没有命令时直接关闭页面
            const webview = getCurrentWebviewWindow();
            await webview.close();
        }
    }

    async function handleKeydown(event: KeyboardEvent) {
        if (event.key === 'Escape') {
            console.log('按 Escape 关闭');
            const webview = getCurrentWebviewWindow();
            await webview.close();
        } else {
            // 清除之前的定时器
            if (debounceTimer) {
                clearTimeout(debounceTimer);
            }

            // 设置新的定时器，延迟执行命令检查
            debounceTimer = setTimeout(async () => {
                if (commandInput.trim().length >= 1) {
                    console.log('定时器触发，执行命令检查...');
                    // 至少输入一个字符才检查
                    await checkCommand(commandInput);
                }
            }, 250); // 250ms 延迟
        }
    }

    onMount(async () => {
        await loadCommands();

        // 窗口打开时设置焦点
        const webview = getCurrentWebviewWindow();
        await webview.setFocus();

        // 确保输入框获得焦点
        setTimeout(() => {
            inputElement?.focus();
        }, 100);
    });
</script>

<svelte:window on:keydown={handleKeydown} on:blur={handleWindowBlur} />

<div class="w-screen h-screen bg-black flex items-center justify-center">
    <div class="w-full h-96 rounded-lg overflow-hidden shadow-lg">
        <!-- Search Box -->
        <div class="search-box">
            <input
                bind:value={commandInput}
                bind:this={inputElement}
                type="text"
                placeholder="输入命令并按回车执行..."
                class="invisible-input"
                autofocus
                onblur={handleBlur}
            />

            <div class="typing-container">
                <div class="typing-display">
                    {#each commandInput.split('') as char, index}
                        <span class="typing-char" style="--delay: {index * 0.08}s">{char}</span>
                    {/each}
                    {#if commandInput.length === 0}
                        <span class="typing-placeholder">输入命令...</span>
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    :global(body) {
        margin: 0;
        padding: 0;
        overflow: hidden;
    }

    .search-box {
        width: 100%;
        height: 100%;
        background: linear-gradient(
            to bottom,
            rgba(255, 255, 255, 1) 0%,
            rgba(255, 255, 255, 0.95) 60%,
            rgba(255, 255, 255, 0.85) 80%,
            rgba(255, 255, 255, 0.7) 100%
        );
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border-radius: 0.75rem;
        overflow: hidden;
        border: 1px solid rgba(255, 255, 255, 0.3);
        box-shadow: 
            0 4px 6px -1px rgba(0, 0, 0, 0.1),
            0 2px 4px -1px rgba(0, 0, 0, 0.06),
            0 0 20px rgba(255, 255, 255, 0.3),
            inset 0 1px 0 rgba(255, 255, 255, 0.6);
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .invisible-input {
        position: absolute;
        opacity: 0;
        width: 1px;
        height: 1px;
        padding: 0;
        border: none;
        outline: none;
        pointer-events: none;
    }

    .typing-container {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 2rem 1rem;
        min-height: 8rem;
    }

    .typing-display {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.25rem;
        flex-wrap: wrap;
    }

    .typing-char {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 4rem;
        height: 4rem;
        font-size: 2.67rem;
        font-weight: 500;
        color: #3b82f6;
        border: 3px solid #3b82f6;
        border-radius: 0.5rem;
        opacity: 0;
        transform: scale(0.8);
        animation: charAppear 0.3s ease-out forwards;
        animation-delay: var(--delay);
    }

    @keyframes charAppear {
        0% {
            opacity: 0;
            transform: scale(0.8);
        }
        50% {
            opacity: 0.6;
            transform: scale(1.1);
        }
        100% {
            opacity: 1;
            transform: scale(1);
        }
    }

    .typing-placeholder {
        font-size: 0.875rem;
        color: #9ca3af;
        font-weight: 400;
    }
</style>
