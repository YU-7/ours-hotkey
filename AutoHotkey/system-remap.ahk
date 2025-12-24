#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)
#Include %A_ScriptDir%\config\system-level.ahk

disableCapsLock(){
    Hotkey "CapsLock", (*) => false
}
; 绑定 Windows 窗口操作
WindowsOprate(){
    ; 组合键要使用前缀模式
    Hotkey "CapsLock & b", (*) => Send("#{Up}")
    Hotkey "CapsLock & x", (*) => Send("!{F4}")
    Hotkey "CapsLock & v", (*) => Send("#{F4}")
    Hotkey "CapsLock & w", (*) => Send("!{Tab}")
    
    
    
}

TaskManger(){
    Hotkey "CapsLock & e", (*) => Send("^!{Tab}")
    Hotkey "e", (*) => Send("{Up}")
    Hotkey "d", (*) => Send("{Down}")
    Hotkey "s", (*) => Send("{Left}")
    Hotkey "f", (*) => Send("{Right}")
    Hotkey "c", (*) => Send("{Delete}")
}
