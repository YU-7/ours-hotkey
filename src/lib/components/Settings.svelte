<script lang="ts">
  import { onMount } from 'svelte';
  import { checkAutostartStatus, toggleAutostart } from '$lib/autostart';

  let autostartEnabled = $state(false);
  let loading = $state(false);

  onMount(async () => {
    // 加载当前状态
    loading = true;
    try {
      autostartEnabled = await checkAutostartStatus();
    } catch (error) {
      console.error('加载自动启动状态失败:', error);
    } finally {
      loading = false;
    }
  });

  async function handleAutostartToggle() {
    if (loading) return;
    
    loading = true;
    try {
      autostartEnabled = await toggleAutostart();
    } catch (error) {
      console.error('切换自动启动状态失败:', error);
      // 如果失败，恢复之前的状态
      autostartEnabled = await checkAutostartStatus();
    } finally {
      loading = false;
    }
  }
</script>

<div class="p-6 space-y-6">
  <h1 class="text-2xl font-bold">软件设置</h1>
  
  <div class="space-y-4">
    <!-- 开机自动启动设置 -->
    <div class="card p-4">
      <div class="flex items-center justify-between">
        <div class="flex flex-col gap-1">
          <h2 class="text-lg font-semibold">开机自动启动</h2>
          <p class="text-sm text-surface-600-300">
            启用后，应用将在系统启动时自动运行
          </p>
        </div>
        <label class="switch">
          <input
            type="checkbox"
            checked={autostartEnabled}
            disabled={loading}
            onchange={handleAutostartToggle}
          />
          <span class="slider"></span>
        </label>
      </div>
    </div>
  </div>
</div>

<style>
  .switch {
    position: relative;
    display: inline-block;
    width: 50px;
    height: 24px;
  }

  .switch input {
    opacity: 0;
    width: 0;
    height: 0;
  }

  .slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: var(--color-surface-500);
    transition: 0.3s;
    border-radius: 24px;
  }

  .slider:before {
    position: absolute;
    content: "";
    height: 18px;
    width: 18px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: 0.3s;
    border-radius: 50%;
  }

  input:checked + .slider {
    background-color: var(--color-primary-500);
  }

  input:checked + .slider:before {
    transform: translateX(26px);
  }

  input:disabled + .slider {
    opacity: 0.5;
    cursor: not-allowed;
  }
</style>

