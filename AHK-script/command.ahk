#Requires AutoHotkey v2.0
#SingleInstance Force

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
        ; 根据函数名调用相应函数
        switch functionName {
            case "calculator", "calc":
                OpenCalculator()
            case "explorer", "file":
                OpenFileExplorer()
            case "taskmgr", "task":
                OpenTaskManager()
            case "terminal", "cmd":
                OpenTerminal()
            case "bluetooth", "bt":
                OpenBluetoothSettings()
            case "wifi", "network":
                OpenWifiSettings()
            case "downloads", "download":
                OpenDownloads()
            case "volume", "sound":
                OpenVolumeSettings()
            case "recycle", "bin":
                OpenRecycleBin()
            default:
                ShowHelp()
        
    }
}

ShowHelp() {
    helpText := "
    (
AutoHotkey 快捷工具

用法: command.ahk <命令>

可用命令:
  calculator, calc    - 打开计算器
  explorer, file      - 打开文件资源管理器
  taskmgr, task       - 打开任务管理器
  terminal, cmd       - 打开命令提示符
  bluetooth, bt       - 打开蓝牙设置
  wifi, network       - 打开WiFi设置
  downloads, download - 打开下载目录
  volume, sound       - 打开音量设置
  recycle, bin        - 打开回收站

示例:
  command.ahk calculator
  command.ahk wifi
  command.ahk downloads
    )"

    MsgBox helpText, "帮助信息", 0x40
}

main()