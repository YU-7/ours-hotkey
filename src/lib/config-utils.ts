import { invoke } from "@tauri-apps/api/core";
import type { ConfigData } from "../interface/types";

/**
 * 从后端读取系统级配置文件
 * @returns Promise<ConfigData> - 解析后的配置数据
 * @throws Error - 当读取或解析失败时抛出错误
 */
export async function readConfigFile(): Promise<ConfigData> {
  try {
    const result = await invoke<string>("read_config_file");
    return JSON.parse(result) as ConfigData;
  } catch (error) {
    if (error instanceof Error) {
      // 检查是否是 Tauri 命令错误
      if (error.message.includes("读取配置文件失败")) {
        throw new Error(`配置文件读取失败：${error.message}。请检查 config/system-level.json 文件是否存在。`);
      } else if (error.message.includes("获取当前目录失败")) {
        throw new Error("应用程序初始化失败：无法获取应用路径。");
      } else if (error.message.includes("无法确定项目根目录")) {
        throw new Error("应用程序路径解析失败：无法确定项目目录位置。");
      } else {
        throw new Error(`加载失败：${error.message}`);
      }
    } else {
      // 处理非 Error 类型的异常
      throw new Error(`未知错误：${String(error)}`);
    }
  }
}

/**
 * 验证配置文件数据的结构是否正确
 * @param data - 要验证的数据
 * @returns boolean - 数据结构是否有效
 */
export function validateConfigData(data: any): data is ConfigData {
  if (!data || typeof data !== 'object') {
    return false;
  }

  // 检查 Windows 配置
  if (!data.Windows || typeof data.Windows !== 'object') {
    return false;
  }

  const windows = data.Windows;
  if (!windows.Max || !windows.Min || !windows.Close) {
    return false;
  }

  // 检查每个窗口操作都有 Origin 和 Remap
  for (const action of ['Max', 'Min', 'Close']) {
    if (!windows[action].Oringin || !windows[action].Remap) {
      return false;
    }
  }

  // 检查 TaskManger 配置
  if (!data.TaskManger || typeof data.TaskManger !== 'object') {
    return false;
  }

  const taskManager = data.TaskManger;
  if (!taskManager.Open || !taskManager.Direction) {
    return false;
  }

  // 检查方向控制配置
  const direction = taskManager.Direction;
  const requiredDirections = ['Up', 'Down', 'Left', 'Right', 'Close', 'Enter'];

  for (const dir of requiredDirections) {
    if (!direction[dir]) {
      return false;
    }
  }

  return true;
}

/**
 * 获取配置数据的缓存版本（如果有的话）
 * 这个函数可以在需要时实现本地缓存
 */
export class ConfigCache {
  private static instance: ConfigCache;
  private cache: ConfigData | null = null;
  private lastFetchTime: number = 0;
  private readonly CACHE_DURATION = 5 * 60 * 1000; // 5分钟缓存

  static getInstance(): ConfigCache {
    if (!ConfigCache.instance) {
      ConfigCache.instance = new ConfigCache();
    }
    return ConfigCache.instance;
  }

  async getConfig(forceRefresh = false): Promise<ConfigData> {
    const now = Date.now();

    // 如果缓存存在且未过期，且不强制刷新，则返回缓存
    if (
      this.cache &&
      !forceRefresh &&
      (now - this.lastFetchTime) < this.CACHE_DURATION
    ) {
      return this.cache;
    }

    // 重新获取配置
    this.cache = await readConfigFile();
    this.lastFetchTime = now;

    return this.cache;
  }

  clearCache(): void {
    this.cache = null;
    this.lastFetchTime = 0;
  }

  isCacheValid(): boolean {
    const now = Date.now();
    return this.cache !== null && (now - this.lastFetchTime) < this.CACHE_DURATION;
  }
}

// 导出单例实例
export const configCache = ConfigCache.getInstance();
