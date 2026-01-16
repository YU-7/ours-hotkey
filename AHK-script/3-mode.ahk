#Requires AutoHotkey v2.0

Tip(message, time := -1500) {
  ToolTip(message)
  SetTimer(() => ToolTip(), time)
}

ExtractWaitKey(hotkey) {
  waitKey := Trim(hotkey, " #!^+<>*~$")
  if InStr(waitKey, "&") {
    sp := StrSplit(waitKey, "&")
    waitKey := Trim(sp[2])
  }
  return waitKey
}

class KeymapManager {
  static GlobalKeymap := Keymap("GlobalKeymap")
  static Stack := Array(this.GlobalKeymap)
  static L := { toLock: false, locked: false, show: false, toggle: false }

  static NewKeymap(globalHotkey, name, delay, disableAt) {
    if globalHotkey == "customHotkeys" {
      return this.GlobalKeymap
    }

    winTitle := this.GlobalKeymap.DisabledAt
    if disableAt {
      winTitle := disableAt
    }
    conditionType := winTitle ? 3 : 0
    return this.AddSubKeymap(this.GlobalKeymap, globalHotkey, name, delay, winTitle, conditionType)
  }

  static AddSubKeymap(parent, hk, name := "", delay := 0, winTitle := "", conditionType := 0) {
    waitKey := ExtractWaitKey(hk)
    subKeymap := Keymap(name, waitKey, hk, delay)
    handler(thisHotkey) {
      this.Activate(subKeymap)
      this._postHandler()
    }
    parent.Map(hk, handler, , winTitle, conditionType)
    return subKeymap
  }

  static _handleDelay(keymap) {
    if keymap.delay {
      ih := InputHook("T" keymap.delay)
      ih.KeyOpt("{All}", "E")
      ih.Start()
      while true {
        if !ih.InProgress && ih.EndReason == "Timeout" {
          break
        }
        if !GetKeyState(keymap.WaitKey, "P") || (!ih.InProgress && ih.EndReason != "Timeout") {
          ih.Stop()
          Send("{blind}{" keymap.WaitKey "}{" ih.EndKey "}")
          KeyWait(keymap.WaitKey)
          return true
        }
      }
    }
  }

  static Activate(keymap) {
    if this._handleDelay(keymap) {
      return
    }
    parent := this.Stack[-1]
    locked := this.Stack[1]
    if keymap != locked {
      this.Stack.Push(keymap)
      keymap.Enable(parent)
    }
    startTick := A_TickCount
    keymap.Wait(startTick)
    if keymap != locked {
      this.Stack.Pop()
      keymap.Disable()
    }
  }

  static _postHandler() {
    if this.Stack.Length != 1 || !this.L.toLock {
      return
    }

    if !this.L.locked {
      this.ShowToolTip("Lock " this.L.toLock.Name, this.L.show)
      this._lock()
      if this.L.locked.AfterLocked {
        SetTimer(this.L.locked.AfterLocked, -1)
      }
      return
    }

    if this.L.toLock == this.L.locked {
      this.L.toLock := false
      if !this.L.toggle {
        return
      }
      this.ShowToolTip("Lock: Off", this.L.show)
      this.Unlock()
      return
    }

    if this.L.toLock != this.L.locked {
      this.ShowToolTip("从 " this.L.locked.Name "`n切换到 " this.L.toLock.Name, this.L.show)
      this.Unlock()
      this._lock()
      if this.L.locked.AfterLocked {
        SetTimer(this.L.locked.AfterLocked, -1)
      }
      return
    }

  }

  static SetLockRequest(toLock, toggle, show) {
    this.L.toLock := toLock
    this.L.toggle := toggle
    this.L.show := show
  }

  static ClearLockRequest() {
    KeymapManager.L.toLock := false
  }

  static _lock() {
    if this.L.toLock {
      this.L.toLock.Enable(this.GlobalKeymap)
      this.Stack[1] := this.L.toLock
      this.L.locked := this.L.toLock
      this.L.toLock := false
    }
  }

  static Unlock() {
    if KeymapManager.L.locked {
      KeymapManager.L.locked.Disable()
      KeymapManager.Stack[1] := KeymapManager.GlobalKeymap
      KeymapManager.L.locked := false
    }
  }

  static ShowToolTip(msg, show := true) {
    if !show {
      return
    }
    Tip(msg)
  }

  class ActionList {
    actions := []
    static conditionMap := Map(
      0, _ => true,
      1, winTitle => WinActive(winTitle),
      2, winTitle => WinExist(winTitle),
      3, winTitle => !WinActive(winTitle),
      4, winTitle => !WinExist(winTitle),
    )

    Run() {
      m := KeymapManager.ActionList.conditionMap
      for a in this.actions {
        if !m.Has(a.conditionType) {
          continue
        }
        if a.conditionType == 0 && !IsSet(fn) {
          fn := a.fn
          continue
        }
        if m.Get(a.conditionType)(a.winTitle) {
          fn := a.fn
          break
        }
      }
      if IsSet(fn) {
        fn()
      }
    }

    Add(conditionType, winTitle, fn) {
      this.actions.Push({
        conditionType: conditionType,
        winTitle: winTitle,
        fn: fn,
      })
    }
  }
}


class Keymap {
  __New(name := "", waitKey := "", hotkey := "", delay := 0) {
    this.Name := name
    this.WaitKey := waitKey
    this.Hotkey := hotkey
    this.SinglePressAction := KeymapManager.ActionList()
    this.M := Map()
    this.M.CaseSense := "Off"
    this.ToggleLock := this._lockOrUnlock.Bind(this)
    this.AfterLocked := false
    this.parent := false
    this.toRestore := Array()
    this.delay := delay
  }

  class _Hotkey {
    __New(name, handler, options, winTitle, conditionType) {
      this.name := ExtractWaitKey(name)
      this.rawName := name
      this.handler := handler
      this.options := options
      this.winTitle := winTitle
      this.conditionType := conditionType
      this.enabled := false
    }

    Enable() {
      if this.enabled {
        MsgBox "bug"
      }
      this.hotifContext(this.winTitle, this.conditionType, true)
      Hotkey(this.rawName, this.handler, "On" this.options)
      this.enabled := true
      this.hotifContext(this.winTitle, this.conditionType, false)
    }

    Disable() {
      if !this.enabled {
        MsgBox "bug"
      }
      this.hotifContext(this.winTitle, this.conditionType, true)
      Hotkey(this.rawName, "Off")
      this.enabled := false
      this.hotifContext(this.winTitle, this.conditionType, false)
    }

    hotifContext(winTitle, conditionType, begin) {
      if winTitle == "" || conditionType == 0 {
        HotIf()
      }
      switch conditionType {
        case 1: begin ? HotIfWinactive(winTitle) : HotIfWinactive()
        case 2: begin ? HotIfWinExist(winTitle) : HotIfWinExist()
        case 3: begin ? HotIfWinNotactive(winTitle) : HotIfWinNotactive()
        case 4: begin ? HotIfWinNotExist(winTitle) : HotIfWinNotExist()
        case 5: begin ? HotIf(winTitle) : HotIf()
      }
    }
  }

  Map(hotkeyName, handler, keymapToLock := false, winTitle := "", conditionType := 0, options := "") {
    wrapper := Keymap._wrapHandler(handler, keymapToLock)
    if hotkeyName = "singlePress" {
      this.SinglePressAction.Add(conditionType, winTitle, wrapper.Bind("singlePress"))
      return
    }
    if handler == "handled_in_hot_if" {
      wrapper := hotkeyName
    }

    hk := Keymap._Hotkey(hotkeyName, wrapper, options, winTitle, conditionType)
    if !this.M.Has(hk.name) {
      this.M[hk.name] := Array()
    }
    this.M[hk.name].Push(hk)
  }


  static _wrapHandler(handler, keymapToLock) {
    wrapper(thisHotkey) {
      handler(thisHotkey)
      if !keymapToLock {
        return
      }
      KeymapManager.SetLockRequest(keymapToLock, false, false)

      if KeymapManager.Stack.Length == 1 {
        KeymapManager._postHandler()
      }
    }
    return wrapper
  }

  _lockOrUnlock(thiHotkey) {
    KeymapManager.SetLockRequest(this, true, true)
    if KeymapManager.Stack.Length == 1 {
      KeymapManager._postHandler()
    }
  }

  Wait(startTick) {
    if !InStr(this.Hotkey, "button") {
      KeyWait(this.WaitKey)
      if (A_PriorKey = this.WaitKey && (A_TickCount - startTick < 450)) {
        this.SinglePressAction.Run()
      }
      return
    }
    mouseMoved := false
    thisHotkey := A_ThisHotkey
    CoordMode("Mouse", "Screen")

    MouseGetPos(&x1, &y1)
    while !KeyWait(this.WaitKey, "T0.01") {
      MouseGetPos(&x2, &y2)
      if Abs(x2 - x1) > 10 || Abs(y2 - y1) > 10 {
        mouseMoved := true
        break
      }
      if thisHotkey != A_ThisHotkey {
        KeyWait(this.WaitKey)
        break
      }
    }

    if (thisHotkey = A_ThisHotkey && (A_TickCount - startTick < 450)) {
      if !mouseMoved {
        this.SinglePressAction.Run()
      } else {
        Send("{blind}{" this.WaitKey " Down}")
        KeyWait(this.WaitKey)
        Send("{blind}{" this.WaitKey " Up}")
      }
    }
  }

  Enable(parent := false) {
    if this.parent && parent {
      MsgBox "bug"
    }
    this.parent := parent

    for name in this.M {
      km := parent
      while km {
        if km.DisableHotkey(name) {
          item := { keymap: km, hotkey: name }
          this.toRestore.Push(item)
          break
        }
        km := km.parent
      }
      this.EnableHotkey(name)
    }
  }


  Disable() {
    for name in this.M {
      this.DisableHotkey(name)
    }
    while this.toRestore.Length > 0 {
      item := this.toRestore.Pop()
      item.keymap.EnableHotkey(item.hotkey)
    }
    this.parent := false
  }

  EnableHotkey(name) {
    if !this.M.Has(name) {
      return
    }
    for hk in this.M[name] {
      hk.Enable()
    }
  }

  DisableHotkey(name) {
    hks := this.M.Get(name, false)
    if !hks {
      return
    }
    for hk in hks {
      hk.Disable()
    }
    return hks.Length > 0
  }

  RemapKey(a, b, winTitle := "", conditionType := 0) {
    if b ~= "i)control|ctrl|shift|alt|win" {
      downHandler(thisHotkey) {
        HoldDownModifierKey(b)
      }
      this.Map("*" a, downHandler, , winTitle, conditionType)
      return
    }

    hk := "*" a
    keys := b
    if keys ~= "^\w+$" {
      keys := "{blind}{" b "}"
    }
    this.SendKeys(hk, keys, winTitle, conditionType)
  }

  SendKeys(hk, keys, winTitle := "", conditionType := 0) {
    handler(thisHotkey) {
      Send(keys)
    }
    this.Map(hk, handler, , winTitle, conditionType)
  }

  RemapInHotIf(a, b, winTitle := "", conditionType := 0) {
    h := "handled_in_hot_if"
    if b = "AltTab" || b = "ShiftAltTab" {
      return
    }
    if GetKeyName(ExtractWaitKey(b)) == "" {
      this.Map(a, h, , winTitle, conditionType)
    } else {
      this.Map("*" a, h, , winTitle, conditionType)
      this.Map("*" a " up", h, , winTitle, conditionType)
    }
  }
}

HoldDownModifierKey(modifier) {
  if modifier ~= "i)control|ctrl" {
    Send("{Ctrl Down}")
    KeyWait("LCtrl")
    Send("{Ctrl Up}")
  } else if modifier ~= "i)shift" {
    Send("{Shift Down}")
    KeyWait("LShift")
    Send("{Shift Up}")
  } else if modifier ~= "i)alt" {
    Send("{Alt Down}")
    KeyWait("LAlt")
    Send("{Alt Up}")
  } else if modifier ~= "i)win" {
    Send("{LWin Down}")
    KeyWait("LWin")
    Send("{LWin Up}")
  }
}

NoOperation(thisHotkey) {
}

km10 := KeymapManager.NewKeymap("*3", "3 模式", "", "")
km := km10
km.RemapKey("0", "F10")
km.RemapKey("2", "F2")
km.RemapKey("4", "F4")
km.RemapKey("5", "F5")
km.RemapKey("9", "F9")
km.RemapKey("b", "7")
km.RemapKey("e", "F11")
km.RemapKey("h", "0")
km.RemapKey("i", "5")
km.RemapKey("j", "1")
km.RemapKey("k", "2")
km.RemapKey("l", "3")
km.RemapKey("m", "9")
km.RemapKey("n", "8")
km.RemapKey("o", "6")
km.RemapKey("r", "F12")
km.RemapKey("t", "Volume_Up")
km.RemapKey("u", "4")
km.RemapKey("w", "Volume_Down")
km.RemapKey("space", "F1")
km.Map("singlePress", _ => (Send("{blind}{3}")))
km.Map("*/", km.ToggleLock)
