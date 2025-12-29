#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)  ; 确保工作目录是脚本所在目录
#include %A_ScriptDir%\system-remap.ahk
#include %A_ScriptDir%\vim-mode.ahk
; 确保脚本持续运行，以便能够接收窗口消息
Persistent

; 摇杆和扳机键控制使用轮询控制
; disableCapsLock()
; WindowsOprate()
; TaskManger()
InitVimMode()
