/**
 * 应用中使用的类型定义
 */

export type ViewType = 'hotkeys' | 'commands' | 'vim' | 'settings';

/**
 * 系统级热键配置文件数据结构
 */
export interface ConfigData {
    Windows: {
        Max: { Oringin: string; Remap: string };
        Min: { Oringin: string; Remap: string };
        Close: { Oringin: string; Remap: string };
    };
    TaskManger: {
        Open: { Oringin: string; Remap: string };
        Direction: {
            Up: string;
            Down: string;
            Left: string;
            Right: string;
            Close: string;
            Enter: string;
        };
    };
}
