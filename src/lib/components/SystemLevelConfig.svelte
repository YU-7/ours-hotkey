<script lang="ts">
    import type { ConfigData } from '../../interface/types';
    import { ArrowRight, Maximize2, Minimize2, X, Activity } from '@lucide/svelte';

    interface Props {
        configData: ConfigData;
    }

    let { configData }: Props = $props();
</script>

<div class="space-y-4">
    <!-- Windows 窗口操作 -->
    <div class="bg-white border border-gray-200 rounded-lg p-4">
        <div class="flex items-center gap-2 mb-3">
            <Maximize2 class="w-4 h-4 text-blue-600" />
            <h3 class="text-sm font-semibold text-gray-900">窗口操作</h3>
        </div>
        <div class="space-y-2">
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span class="text-sm font-medium text-gray-900">最大化窗口</span>
                <div class="flex items-center gap-2">
                    <span class="text-xs text-gray-500">{configData.Windows.Max.Oringin}</span>
                    <ArrowRight class="w-3 h-3 text-gray-400" />
                    <span class="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs rounded font-mono"
                        >{configData.Windows.Max.Remap}</span
                    >
                </div>
            </div>
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span class="text-sm font-medium text-gray-900">最小化窗口</span>
                <div class="flex items-center gap-2">
                    <span class="text-xs text-gray-500">{configData.Windows.Min.Oringin}</span>
                    <ArrowRight class="w-3 h-3 text-gray-400" />
                    <span class="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs rounded font-mono"
                        >{configData.Windows.Min.Remap}</span
                    >
                </div>
            </div>
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span class="text-sm font-medium text-gray-900">关闭窗口</span>
                <div class="flex items-center gap-2">
                    <span class="text-xs text-gray-500">{configData.Windows.Close.Oringin}</span>
                    <ArrowRight class="w-3 h-3 text-gray-400" />
                    <span class="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs rounded font-mono"
                        >{configData.Windows.Close.Remap}</span
                    >
                </div>
            </div>
        </div>
    </div>

    <!-- 任务管理器 -->
    <div class="bg-white border border-gray-200 rounded-lg p-4">
        <div class="flex items-center gap-2 mb-3">
            <Activity class="w-4 h-4 text-green-600" />
            <h3 class="text-sm font-semibold text-gray-900">任务管理器</h3>
        </div>
        <div class="space-y-3">
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span class="text-sm font-medium text-gray-900">打开任务管理器</span>
                <div class="flex items-center gap-2">
                    <span class="text-xs text-gray-500">{configData.TaskManger.Open.Oringin}</span>
                    <ArrowRight class="w-3 h-3 text-gray-400" />
                    <span class="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs rounded font-mono"
                        >{configData.TaskManger.Open.Remap}</span
                    >
                </div>
            </div>

            <div class="p-3 bg-gray-50 rounded-lg">
                <h4 class="text-xs font-semibold text-gray-700 mb-2">方向控制</h4>
                <div class="grid grid-cols-2 gap-2 text-xs">
                    <div class="flex justify-between items-center">
                        <span class="text-gray-600">上移:</span>
                        <span class="px-2 py-0.5 bg-green-100 text-green-700 rounded font-mono"
                            >{configData.TaskManger.Direction.Up}</span
                        >
                    </div>
                    <div class="flex justify-between items-center">
                        <span class="text-gray-600">下移:</span>
                        <span class="px-2 py-0.5 bg-green-100 text-green-700 rounded font-mono"
                            >{configData.TaskManger.Direction.Down}</span
                        >
                    </div>
                    <div class="flex justify-between items-center">
                        <span class="text-gray-600">左移:</span>
                        <span class="px-2 py-0.5 bg-green-100 text-green-700 rounded font-mono"
                            >{configData.TaskManger.Direction.Left}</span
                        >
                    </div>
                    <div class="flex justify-between items-center">
                        <span class="text-gray-600">右移:</span>
                        <span class="px-2 py-0.5 bg-green-100 text-green-700 rounded font-mono"
                            >{configData.TaskManger.Direction.Right}</span
                        >
                    </div>
                    <div class="flex justify-between items-center">
                        <span class="text-gray-600">关闭:</span>
                        <span class="px-2 py-0.5 bg-green-100 text-green-700 rounded font-mono"
                            >{configData.TaskManger.Direction.Close}</span
                        >
                    </div>
                    <div class="flex justify-between items-center">
                        <span class="text-gray-600">确认:</span>
                        <span class="px-2 py-0.5 bg-green-100 text-green-700 rounded font-mono"
                            >{configData.TaskManger.Direction.Enter}</span
                        >
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
