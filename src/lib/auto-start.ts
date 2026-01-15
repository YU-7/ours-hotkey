import { enable, disable, isEnabled } from '@tauri-apps/plugin-autostart';
import { invoke } from '@tauri-apps/api/core';

/**
 * 自定义错误类，提供更丰富的错误信息
 */
export class AutostartError extends Error {
    constructor(
        message: string,
        public readonly cause?: unknown
    ) {
        super(message);
        this.name = 'AutostartError';
    }
}

/**
 * 静默启动参数常量，避免魔法字符串
 */
const SILENT_START_ARGS = Object.freeze(['--silent']);

/**
 * 启用开机自动启动
 * @param silentStart 是否静默启动（启动时不显示窗口）
 */
export async function enableAutostart(silentStart: boolean = false): Promise<void> {
    try {
        // 根据静默启动参数决定是否传递额外参数
        // 注意：enable 函数不接受 args 参数，静默启动通常需要其他方式处理
        await enable();
        console.log(`开机自动启动已启用${silentStart ? '（静默模式）' : ''}`);
    } catch (error) {
        console.error('启用开机自动启动失败:', error);
        throw new AutostartError('启用开机自动启动失败', error);
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
        throw new AutostartError('禁用开机自动启动失败', error);
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
        // 返回 false 而不是抛出错误，避免中断程序流程
        return false;
    }
}

/**
 * 获取静默启动状态
 * @returns 是否启用静默启动
 */
export async function getSilentStartStatus(): Promise<boolean> {
    try {
        return (await invoke('get_silent_start_status')) as boolean;
    } catch (error) {
        console.error('获取静默启动状态失败:', error);
        return false;
    }
}

/**
 * 设置静默启动状态
 * @param enabled 是否启用静默启动
 */
export async function setSilentStart(enabled: boolean): Promise<void> {
    try {
        await invoke('set_silent_start', { enabled });
        console.log(`静默启动已${enabled ? '启用' : '禁用'}`);
    } catch (error) {
        console.error('设置静默启动状态失败:', error);
        throw new AutostartError('设置静默启动状态失败', error);
    }
}

/**
 * 切换开机自动启动状态
 * @param silentStart 是否静默启动
 * @returns 切换后的状态
 */
export async function toggleAutostart(silentStart: boolean = false): Promise<boolean> {
    try {
        const currentStatus = await checkAutostartStatus();
        if (currentStatus) {
            await disableAutostart();
            return false;
        } else {
            await enableAutostart(silentStart);
            return true;
        }
    } catch (error) {
        console.error('切换开机自动启动状态失败:', error);
        throw new AutostartError('切换开机自动启动状态失败', error);
    }
}
