<script lang="ts">
  import { getCurrentWebviewWindow } from '@tauri-apps/api/webviewWindow';

  let commandInput = $state('');

  async function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      const webview = getCurrentWebviewWindow();
      await webview.close();
    } else if (event.key === 'Enter') {
      // 处理命令执行逻辑
      console.log('执行命令:', commandInput);
      // 这里可以添加命令处理逻辑
    }
  }
</script>

<svelte:window on:keydown={handleKeydown} />

<div class="w-screen h-screen bg-black/50 backdrop-blur-sm flex items-center justify-center">
  <!-- svelte-ignore a11y_autofocus -->
  <input
    bind:value={commandInput}
    type="text"
    placeholder="输入命令..."
    class="px-4 py-2 bg-white/90 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent shadow-lg text-center min-w-80"
    autofocus
  />
</div>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    background: transparent !important;
  }
</style>
