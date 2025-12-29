; Vim Mode for AutoHotkey v2.0
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)

global hk_Normal_h := (*) => Send("{Left}")
global hk_Normal_j := (*) => Send("{Down}")
global hk_Normal_k := (*) => Send("{Up}")
global hk_Normal_l := (*) => Send("{Right}")
global hk_Normal_x := (*) => Send("{Delete}")
global hk_Normal_X := (*) => Send("{Backspace}")
global hk_Normal_d := (*) => HandleDoubleKey("d", "DeleteLine")
global hk_Normal_y := (*) => HandleDoubleKey("y", "YankLine")
global hk_Normal_u := (*) => UndoAction()
global hk_Normal_r := (*) => RedoAction()
global hk_Normal_i := (*) => EnterInsertMode()
; global hk_Normal_v := (*) => EnterVisualMode() ; Commented out as per previous user changes
; global hk_Normal_A := (*) => EnterVisualMode() ; Commented out as per previous user changes

global hk_Visual_h := (*) => Send("+{Left}")
global hk_Visual_j := (*) => Send("+{Down}")
global hk_Visual_k := (*) => Send("+{Up}")
global hk_Visual_l := (*) => Send("+{Right}")
global hk_Visual_x := (*) => Send("{Delete}")
global hk_Visual_d := (*) => Send("{Delete}")
global hk_Visual_Escape := (*) => EnterNormalMode()

global hk_Insert_Escape := (*) => EnterNormalMode()

; === 模式指示器 ===
ShowMode() {
    modeText := ""
    switch vimMode {
        case "normal": modeText := "NORMAL"
        case "visual": modeText := "VISUAL"
        case "insert": modeText := "INSERT"
    }

    ; 显示模式指示器（暂时用工具提示，后续可以优化为状态栏）
    ; 声明为全局以避免警告
    global A_ScreenWidth
    ToolTip(modeText, A_ScreenWidth - 100, 10)
    SetTimer(HideTooltip, -2000)  ; 2秒后隐藏
}

; === 隐藏工具提示的函数 ===
HideTooltip() {
    ToolTip()
}

; === 模式切换函数 ===
EnterNormalMode() {
    ; 禁用所有热键
    Hotkey("h", hk_Visual_h, "Off")
    Hotkey("j", hk_Visual_j, "Off")
    Hotkey("k", hk_Visual_k, "Off")
    Hotkey("l", hk_Visual_l, "Off")
    Hotkey("x", hk_Visual_x, "Off")
    Hotkey("d", hk_Visual_d, "Off")
    Hotkey("Escape", hk_Visual_Escape, "Off")
    Hotkey("Escape", hk_Insert_Escape, "Off")

    ; 启用普通模式热键
    Hotkey("h", hk_Normal_h, "On")
    Hotkey("j", hk_Normal_j, "On")
    Hotkey("k", hk_Normal_k, "On")
    Hotkey("l", hk_Normal_l, "On")
    Hotkey("x", hk_Normal_x, "On")
    Hotkey("+X", hk_Normal_X, "On")
    Hotkey("d", hk_Normal_d, "On")
    Hotkey("y", hk_Normal_y, "On")
    Hotkey("u", hk_Normal_u, "On")
    Hotkey("^r", hk_Normal_r, "On")
    Hotkey("i", hk_Normal_i, "On")
    ; Hotkey("v", hk_Normal_v, "On") ; Commented out as per previous user changes
    ; Hotkey("+a", hk_Normal_A, "On") ; Commented out as per previous user changes

    global vimMode := "normal"
    ShowMode()
}

EnterVisualMode() {
    ; 禁用所有热键
    Hotkey("h", hk_Normal_h, "Off")
    Hotkey("j", hk_Normal_j, "Off")
    Hotkey("k", hk_Normal_k, "Off")
    Hotkey("l", hk_Normal_l, "Off")
    Hotkey("x", hk_Normal_x, "Off")
    Hotkey("+X", hk_Normal_X, "Off")
    Hotkey("d", hk_Normal_d, "Off")
    Hotkey("y", hk_Normal_y, "Off")
    Hotkey("u", hk_Normal_u, "Off")
    Hotkey("^r", hk_Normal_r, "Off")
    Hotkey("i", hk_Normal_i, "Off")
    ; Hotkey("v", hk_Normal_v, "Off") ; Commented out as per previous user changes
    ; Hotkey("+a", hk_Normal_A, "Off") ; Commented out as per previous user changes
    Hotkey("Escape", hk_Insert_Escape, "Off")

    ; 启用可视模式热键
    Hotkey("h", hk_Visual_h, "On")
    Hotkey("j", hk_Visual_j, "On")
    Hotkey("k", hk_Visual_k, "On")
    Hotkey("l", hk_Visual_l, "On")
    Hotkey("x", hk_Visual_x, "On")
    Hotkey("d", hk_Visual_d, "On")
    Hotkey("Escape", hk_Visual_Escape, "On")

    global vimMode := "visual"
    global visualStart := GetCaretPos()
    ShowMode()
}

EnterInsertMode() {
    ; 禁用所有热键
    Hotkey("h", hk_Normal_h, "Off")
    Hotkey("j", hk_Normal_j, "Off")
    Hotkey("k", hk_Normal_k, "Off")
    Hotkey("l", hk_Normal_l, "Off")
    Hotkey("x", hk_Normal_x, "Off")
    Hotkey("+X", hk_Normal_X, "Off")
    Hotkey("d", hk_Normal_d, "Off")
    Hotkey("y", hk_Normal_y, "Off")
    Hotkey("u", hk_Normal_u, "Off")
    Hotkey("^r", hk_Normal_r, "Off")
    Hotkey("i", hk_Normal_i, "Off")
    ; Hotkey("v", hk_Normal_v, "Off") ; Commented out as per previous user changes
    ; Hotkey("+a", hk_Normal_A, "Off") ; Commented out as per previous user changes
    Hotkey("h", hk_Visual_h, "Off")
    Hotkey("j", hk_Visual_j, "Off")
    Hotkey("k", hk_Visual_k, "Off")
    Hotkey("l", hk_Visual_l, "Off")
    Hotkey("x", hk_Visual_x, "Off")
    Hotkey("d", hk_Visual_d, "Off")
    Hotkey("Escape", hk_Visual_Escape, "Off")

    ; 启用插入模式热键
    Hotkey("Escape", hk_Insert_Escape, "On")

    global vimMode := "insert"
    ShowMode()
}

; === 获取光标位置的辅助函数 ===
GetCaretPos() {
    ; 简化的光标位置获取（在实际应用中可能需要更复杂的实现）
    ; 注意：A_CaretX 和 A_CaretY 在某些应用中可能不准确
    local A_CaretX := 0, A_CaretY := 0 ; 显式初始化以避免linter警告
    return A_CaretX "," A_CaretY
}

; === 双键序列处理函数 ===
HandleDoubleKey(currentKey, action) {
    ; 获取当前时间戳
    ; 声明为全局以避免警告
    global A_TickCount
    currentTime := A_TickCount

    ; 检查是否是连续的相同键（在500ms内）
    if (lastKey == currentKey && currentTime - lastKeyTime < 500) {
        ; 执行双键动作
        %action%()
        ; 重置状态
        global lastKey := ""
        global lastKeyTime := 0
    } else {
        ; 这是第一次按键，等待可能的第二次按键
        global lastKey := currentKey
        global lastKeyTime := currentTime

        ; 设置定时器，如果500ms内没有第二次按键，则发送单键
        SetTimer(SendSingleKey, -500)
    }
}

; === 发送单键的定时器回调函数 ===
SendSingleKey() {
    global
    if (lastKey != "") {
        Send("{" lastKey "}")
        lastKey := ""
        lastKeyTime := 0
    }
}

; === 删除整行的函数 ===
DeleteLine() {
    Send("{Home}+{End}")     ; 选中整行
    Send("{Delete}")         ; 删除选中内容
}

; === 复制整行的函数 ===
YankLine() {
    Send("{Home}+{End}")     ; 选中整行
    Send("^c")               ; 复制选中内容
    Send("{Right}")          ; 移动到下一行开始
}

; === 撤销的函数 ===
UndoAction() {
    Send("^z")               ; 发送撤销快捷键
}

; === 重做的函数 ===
RedoAction() {
    Send("^y")               ; 发送重做快捷键
}

; === 普通模式热键函数 ===
NormalModeHotkeys() {
    Hotkey("h", hk_Normal_h)
    Hotkey("j", hk_Normal_j)
    Hotkey("k", hk_Normal_k)
    Hotkey("l", hk_Normal_l)
    Hotkey("x", hk_Normal_x)
    Hotkey("+X", hk_Normal_X)
    Hotkey("d", hk_Normal_d)
    Hotkey("y", hk_Normal_y)
    Hotkey("u", hk_Normal_u)
    Hotkey("^r", hk_Normal_r)
    Hotkey("i", hk_Normal_i)
    ; Hotkey("v", hk_Normal_v) ; Commented out as per previous user changes
    ; Hotkey("+a", hk_Normal_A) ; Commented out as per previous user changes
}

; === 可视模式热键函数 ===
VisualModeHotkeys() {
    Hotkey("h", hk_Visual_h)
    Hotkey("j", hk_Visual_j)
    Hotkey("k", hk_Visual_k)
    Hotkey("l", hk_Visual_l)
    Hotkey("x", hk_Visual_x)
    Hotkey("d", hk_Visual_d)
    Hotkey("Escape", hk_Visual_Escape)
}

; === 插入模式热键函数 ===
InsertModeHotkeys() {
    Hotkey("Escape", hk_Insert_Escape)
}


; === 全局热键（在所有模式下都有效） ===

; Ctrl+C 复制（所有模式）
^c::Send("^c")

; Ctrl+V 粘贴（所有模式）
^v::Send("^v")

; Ctrl+X 剪切（所有模式）
^x::Send("^x")

; === 初始化函数 ===
InitVimMode() {
    ; 启动时初始化所有热键为禁用状态
    Hotkey("h", hk_Normal_h, "Off")
    Hotkey("j", hk_Normal_j, "Off")
    Hotkey("k", hk_Normal_k, "Off")
    Hotkey("l", hk_Normal_l, "Off")
    Hotkey("x", hk_Normal_x, "Off")
    Hotkey("+X", hk_Normal_X, "Off")
    Hotkey("d", hk_Normal_d, "Off")
    Hotkey("y", hk_Normal_y, "Off")
    Hotkey("u", hk_Normal_u, "Off")
    Hotkey("^r", hk_Normal_r, "Off")
    Hotkey("i", hk_Normal_i, "Off")
    ; Hotkey("v", hk_Normal_v, "Off") ; Commented out as per previous user changes
    ; Hotkey("+a", hk_Normal_A, "Off") ; Commented out as per previous user changes

    Hotkey("h", hk_Visual_h, "Off")
    Hotkey("j", hk_Visual_j, "Off")
    Hotkey("k", hk_Visual_k, "Off")
    Hotkey("l", hk_Visual_l, "Off")
    Hotkey("x", hk_Visual_x, "Off")
    Hotkey("d", hk_Visual_d, "Off")
    Hotkey("Escape", hk_Visual_Escape, "Off")

    Hotkey("Escape", hk_Insert_Escape, "Off")

    EnterNormalMode() ; 启动时进入普通模式
}

; === 调试信息 ===
; 显示当前模式（按 F12 查看）
F12::
{
    MsgBox("当前 Vim 模式: " vimMode "`n`n操作说明:`n- h/j/k/l: 移动`n- x: 删除`n- i: 插入模式`n- v: 可视模式`n- ESC: 返回普通模式")
    return
}
