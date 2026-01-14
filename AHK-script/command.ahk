#Requires AutoHotkey v2.0
#SingleInstance Force

; & ".\AutoHotkey\AutoHotkey64.exe" ".\AHK-script\command.ahk" calc
global userStartMenuFile := A_AppData "\Microsoft\Windows\Start Menu"
; 打开 Windows 自带的计算器
OpenCalculator() {
    Run "calc.exe"
}
OpenFileExplorer() {
    Run "explorer.exe"
}
OpenTaskManager() {
    Run "taskmgr.exe"
}
OpenBluetoothSettings() {
    ; 使用ms-settings URI打开蓝牙设置页面
    Run "ms-settings:bluetooth"
}
OpenWifiSettings() {
    ; 使用ms-settings URI打开WiFi设置页面
    Run "ms-settings:network-wifi"
}
OpenDownloads() {
    ; 打开下载目录
    downloadsPath := EnvGet("USERPROFILE") . "\Downloads"
    Run downloadsPath
}
OpenVolumeSettings() {
    ; 使用ms-settings URI打开音量设置页面
    Run "ms-settings:apps-volume"
}
OpenRecycleBin() {
    ; 打开垃圾回收站
    Run "explorer.exe shell:RecycleBinFolder"
}

; 重启系统
RebootSystem() {
    ; 使用 shutdown 命令重启系统
    Run "shutdown.exe /r /t 0"
}

; 关闭系统
ShutdownSystem() {
    ; 使用 shutdown 命令关闭系统
    Run "shutdown.exe /s /t 0"
}

; 以管理员权限运行 Command Prompt 快捷方式
OpenTerminal() {
    ; Command Prompt 快捷方式的完整路径
    cmdShortcutPath := A_AppData "\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk"
    err := ""  ; 初始化变量以避免linter警告
    try {
        ; 无法使用RunAsAdmin函数
        Run cmdShortcutPath
    } catch Error as err {
        RunAsAdmin("cmd.exe")
    }
}

; 以管理员权限运行程序的辅助函数
RunAsAdmin(program) {
    ; 使用 ShellExecute 以管理员权限运行程序
    result := DllCall("shell32\ShellExecuteW", "Ptr", 0, "Str", "runas", "Str", program, "Ptr", 0, "Ptr", 0, "Int", 1)

    ; 检查执行结果
    if (result <= 32) {
        ; 获取详细错误信息
        errorCode := A_LastError
        errorMsg := GetErrorMessage(errorCode)

        ; 抛出详细错误信息
        throw Error("运行程序失败: " program "`n错误代码: " errorCode "`n错误信息: " errorMsg "`nShellExecute返回值: " result, -1)
    }
}

; 获取系统错误信息的辅助函数
GetErrorMessage(errorCode) {
    ; 预定义常见错误信息
    errorMessages := Map(
        2, "文件未找到",
        3, "路径未找到",
        5, "拒绝访问",
        8, "内存不足",
        29, "写入错误",
        32, "共享冲突",
        33, "锁定冲突"
    )

    return errorMessages.Has(errorCode) ? errorMessages[errorCode] : "未知错误"
}


main() {
    ; 检查命令行参数
    functionName := A_Args[1]

    ; 创建函数映射
    functionMap := Map(
        "calculator", OpenCalculator,
        "calc", OpenCalculator,
        "explorer", OpenFileExplorer,
        "file", OpenFileExplorer,
        "taskmgr", OpenTaskManager,
        "task", OpenTaskManager,
        "terminal", OpenTerminal,
        "cmd", OpenTerminal,
        "bluetooth", OpenBluetoothSettings,
        "bt", OpenBluetoothSettings,
        "wifi", OpenWifiSettings,
        "network", OpenWifiSettings,
        "downloads", OpenDownloads,
        "download", OpenDownloads,
        "volume", OpenVolumeSettings,
        "sound", OpenVolumeSettings,
        "recycle", OpenRecycleBin,
        "bin", OpenRecycleBin,
        "rb", RebootSystem,
        "reboot", RebootSystem,
        "sd", ShutdownSystem,
        "shutdown", ShutdownSystem
    )

    ; 调用对应的函数
    if functionMap.Has(functionName) {
        functionMap[functionName]()
    } 
}


main()