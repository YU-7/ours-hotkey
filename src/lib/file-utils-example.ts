/**
 * 使用示例：如何在 Svelte 组件中使用文件工具函数
 * 
 * 在 Svelte 组件中：
 * 
 * <script lang="ts">
 *   import { onMount } from 'svelte';
 *   import { readJsonFile, writeJsonFile, fileExists } from '$lib/file-utils';
 * 
 *   interface Config {
 *     theme: string;
 *     language: string;
 *   }
 * 
 *   let config: Config | null = null;
 * 
 *   onMount(async () => {
 *     // 读取配置文件
 *     config = await readJsonFile<Config>('config.json');
 *     
 *     // 如果文件不存在，创建默认配置
 *     if (!config) {
 *       config = {
 *         theme: 'dark',
 *         language: 'zh-CN'
 *       };
 *       await writeJsonFile('config.json', config);
 *     }
 *   });
 * 
 *   async function saveConfig() {
 *     if (config) {
 *       await writeJsonFile('config.json', config);
 *     }
 *   }
 * </script>
 */

