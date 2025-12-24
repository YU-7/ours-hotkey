import { enable, disable, isEnabled } from '@tauri-apps/plugin-autostart';

/**
 * 启用开机自动启动
 */
export async function enableAutostart(): Promise<void> {
  try {
    await enable();
    console.log('开机自动启动已启用');
  } catch (error) {
    console.error('启用开机自动启动失败:', error);
    throw error;
  }
}

/**
 * 禁用开机自动启动
 */
export async function disableAutostart(): Promise<void> {
  try {
    await disable();
    console.log('开机自动启动已禁用');
  } catch (error) {
    console.error('禁用开机自动启动失败:', error);
    throw error;
  }
}

/**
 * 检查开机自动启动是否已启用
 * @returns 是否已启用自动启动
 */
export async function checkAutostartStatus(): Promise<boolean> {
  try {
    return await isEnabled();
  } catch (error) {
    console.error('检查开机自动启动状态失败:', error);
    return false;
  }
}

/**
 * 切换开机自动启动状态
 * @returns 切换后的状态
 */
export async function toggleAutostart(): Promise<boolean> {
  try {
    const currentStatus = await checkAutostartStatus();
    if (currentStatus) {
      await disableAutostart();
      return false;
    } else {
      await enableAutostart();
      return true;
    }
  } catch (error) {
    console.error('切换开机自动启动状态失败:', error);
    throw error;
  }
}

