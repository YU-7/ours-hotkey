import { readTextFile, writeTextFile, exists, createDir } from '@tauri-apps/plugin-fs';
import { appDataDir } from '@tauri-apps/api/path';

/**
 * 从应用数据目录读取 JSON 文件
 * @param filename JSON 文件名（例如: "config.json"）
 * @returns 解析后的 JSON 对象
 */
export async function readJsonFile<T = any>(filename: string): Promise<T | null> {
  try {
    // 获取应用数据目录路径
    const appDataPath = await appDataDir();
    
    // 构建完整文件路径（确保路径以 / 结尾）
    const normalizedPath = appDataPath.endsWith('/') || appDataPath.endsWith('\\') 
      ? appDataPath 
      : `${appDataPath}/`;
    const filePath = `${normalizedPath}${filename}`;
    
    // 检查文件是否存在
    const fileExists = await exists(filePath);
    if (!fileExists) {
      console.warn(`文件不存在: ${filePath}`);
      return null;
    }
    
    // 读取文件内容
    const content = await readTextFile(filePath);
    
    // 解析 JSON
    return JSON.parse(content) as T;
  } catch (error) {
    console.error(`读取 JSON 文件失败 (${filename}):`, error);
    throw error;
  }
}

/**
 * 写入 JSON 文件到应用数据目录
 * @param filename JSON 文件名（例如: "config.json"）
 * @param data 要写入的数据对象
 */
export async function writeJsonFile<T = any>(filename: string, data: T): Promise<void> {
  try {
    // 获取应用数据目录路径
    const appDataPath = await appDataDir();
    
    // 确保目录存在
    const dirExists = await exists(appDataPath);
    if (!dirExists) {
      await createDir(appDataPath, { recursive: true });
    }
    
    // 构建完整文件路径（确保路径以 / 结尾）
    const normalizedPath = appDataPath.endsWith('/') || appDataPath.endsWith('\\') 
      ? appDataPath 
      : `${appDataPath}/`;
    const filePath = `${normalizedPath}${filename}`;
    
    // 将数据转换为 JSON 字符串
    const content = JSON.stringify(data, null, 2);
    
    // 写入文件
    await writeTextFile(filePath, content);
  } catch (error) {
    console.error(`写入 JSON 文件失败 (${filename}):`, error);
    throw error;
  }
}

/**
 * 检查应用数据目录中的文件是否存在
 * @param filename 文件名
 * @returns 文件是否存在
 */
export async function fileExists(filename: string): Promise<boolean> {
  try {
    const appDataPath = await appDataDir();
    const normalizedPath = appDataPath.endsWith('/') || appDataPath.endsWith('\\') 
      ? appDataPath 
      : `${appDataPath}/`;
    const filePath = `${normalizedPath}${filename}`;
    return await exists(filePath);
  } catch (error) {
    console.error(`检查文件是否存在失败 (${filename}):`, error);
    return false;
  }
}

/**
 * 获取应用数据目录路径
 * @returns 应用数据目录的完整路径
 */
export async function getAppDataDir(): Promise<string> {
  return await appDataDir();
}

