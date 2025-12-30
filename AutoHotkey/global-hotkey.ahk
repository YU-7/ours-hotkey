#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)
#Include %A_ScriptDir%\config\system-level.ahk
Persistent
; 禁用 CapsLock 键，还是能够触发的，但是被ahk拦截下来了，你可以看见capslook的灯很快亮了一下
CapsLock:: return

; 绑定 Windows 窗口操作
WindowsOprate() {
    ; 组合键要使用前缀模式
    Hotkey "CapsLock & q", (*) => WinMaximize("A")
    Hotkey "CapsLock & b", (*) => WinMinimize("A")
    Hotkey "CapsLock & x", (*) => WinClose("A")
    Hotkey "CapsLock & v", (*) => Send("#{F4}")
    Hotkey "CapsLock & w", (*) => Send("!{Tab}")
}

; 检测是否处于任务视图中
IsInTaskView() {
    ; 任务视图可能的类名
    taskViewClasses := ["MultitaskingViewFrame", "Windows.UI.Core.CoreWindow",
        "XamlExplorerHostIslandWindow", "TaskSwitcherWnd"]

    try {
        className := WinGetClass("A")
        for class in taskViewClasses {
            if (className = class) {
                return true
            }
        }
        return false

    } catch {
        FileAppend("Error: Failed to get window class`n", "*")
        return false
    }

}

taskManagerInit() {
    ; 实时检测当前是否在任务视图中并执行相应操作
    global mv_up := (*) => Send("{Up}")
    global mv_down := (*) => Send("{Down}")
    global mv_left := (*) => Send("{Left}")
    global mv_right := (*) => Send("{Right}")
    global mv_delete := (*) => Send("{Delete}")
    Hotkey "CapsLock & e", (*) => Send("^!{Tab}")
    ; 设置定时器，每100毫秒检测一次任务视图状态
    ; （无法采用检测esc或是enter键的方式来退出，因为这两个键位本来的功能会被占用，而且鼠标退出的情况也会被忽略）
    SetTimer checkTaskViewState, 100
}

checkTaskViewState() {
    if (IsInTaskView()) {
        enableTaskManagerRemap()
    } else {
        disableTaskManagerRemap()
    }
}
enableTaskManagerRemap() {
    Hotkey("e", mv_up, "On")
    Hotkey("d", mv_down, "On")
    Hotkey("s", mv_left, "On")
    Hotkey("f", mv_right, "On")
    Hotkey("c", mv_delete, "On")
}
disableTaskManagerRemap() {
    Hotkey("e", mv_up, "Off")
    Hotkey("d", mv_down, "Off")
    Hotkey("s", mv_left, "Off")
    Hotkey("f", mv_right, "Off")
    Hotkey("c", mv_delete, "Off")
}
initGlobalHotkey() {
    WindowsOprate()
    taskManagerInit()
}

initGlobalHotkey()