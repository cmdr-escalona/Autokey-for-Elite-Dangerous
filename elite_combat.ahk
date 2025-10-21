#Requires AutoHotkey v1.1.33+
#InstallKeybdHook

; ==============================================================================
; === ADMINISTRATOR AUTO-ELEVATION BLOCK ===
; ==============================================================================
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

; ==============================================================================
; === FUNCTION DEFINITIONS ===
; ==============================================================================
; Releases every keyboard modifier to guarantee a clean state.
ReleaseAllModifiers() {
    static modifiers := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
    for index, modifier in modifiers
        SendInput {%modifier% up}
}

; Verifies a single modifier and releases it if it is logically pressed but
; physically not being held, preventing stuck modifiers.
CheckAndReleaseModifier(modifier) {
    if (!GetKeyState(modifier, "P") && GetKeyState(modifier))
        SendInput {%modifier% up}
}

; Emits a single key event using the more reliable SendInput backend.
SendKey_Secure(key) {
    SendInput %key%
}

; Plays a sequence of keys, holding each press long enough for the game to react.
; Optional per-call overrides allow different timings for specific macros.
SendKeyEvents(keys, holdMs := 1, interDelayMs := 1) {
    if (!IsObject(keys))
        return
    lastIndex := keys.MaxIndex()
    for index, key in keys
    {
        SendKey_Secure("{" . key . " down}")
        Sleep, %holdMs%
        SendKey_Secure("{" . key . " up}")
        if (index < lastIndex)
            Sleep, %interDelayMs%
    }
}

; Starts a guard timer that frees stuck modifiers while the mode is active.
StartModifierGuard() {
    global modifierGuardActive
    if (modifierGuardActive)
        return
    modifierGuardActive := true
    SetTimer, MonitorModifiers, 50
}

; Stops the modifier guard timer and clears its active flag.
StopModifierGuard() {
    global modifierGuardActive
    if (!modifierGuardActive)
        return
    modifierGuardActive := false
    SetTimer, MonitorModifiers, Off
}

; Refreshes the on-screen indicator showing the current combat mode status.
UpdateGuiState() {
    static TheHwnd
    Gui, CustomTip:Destroy
    if (!keySwapActive)
        return
    Gui, CustomTip:New, +AlwaysOnTop -Caption +ToolWindow +HwndTheHwnd
    Gui, CustomTip:Color, FF0000
    Gui, CustomTip:Font, s10 cFFFFFF Bold, Verdana
    Gui, CustomTip:Margin, 10, 5
    Gui, CustomTip:Add, Text, Center, COMBAT MODE
    Gui, CustomTip:Show, NoActivate AutoSize
    WinGetPos,,, GuiWidth, GuiHeight, ahk_id %TheHwnd%
    TipX := A_ScreenWidth - GuiWidth - 10
    TipY := 10
    Gui, CustomTip:Show, NoActivate X%TipX% Y%TipY%
}

; ==============================================================================
; === AUTO-EXECUTE SECTION (INITIAL CONFIGURATION) ===
; ==============================================================================
#SingleInstance force
SendMode Input
SetKeyDelay, 1, 0

; --- Global Control Variables ---
global keySwapActive := false
global F4SeqRunning := false
global modifierGuardActive := false

OnExit, CleanupAndExit
return ; End of the auto-execute section

; ==============================================================================
; === HOTKEYS AND LABELS ===
; ==============================================================================

; --- MAIN TOGGLE (COMBAT MODE) ---
`::
    keySwapActive := !keySwapActive
    if (keySwapActive) {
        StartModifierGuard()
    } else {
        StopModifierGuard()
        ReleaseAllModifiers()
    }
    UpdateGuiState()
return

; --- COMBAT HOTKEY BLOCK ---
#If keySwapActive and WinActive("ahk_exe EliteDangerous64.exe")

*F::SendKeyEvents(["Down","Left","Up","Up","Up"])
*R::SendKey_Secure("{Y}")
*LAlt::SendKeyEvents(["Down","Up","Up","Right","Right"])
*/::SendKeyEvents(["Down","Left","Left","Right","Right"])
*5::SendKeyEvents(["L","Home"], 100, 45)

*Tab::
    SendKey_Secure("{Tab down}")
    SendKey_Secure("{MButton down}")
    SendKey_Secure("{MButton up}")
    SendKey_Secure("{Tab up}")
return

*RButton::SendKeyEvents(["Down","Up","Right","Right","Right","RButton"])
*XButton1::SendKeyEvents(["Down","Up","Left","Left","Left"])
*XButton2::SendKeyEvents(["Down","Up","Right","Right","Right"])

#If ; End of the combat context block.

; --- F4 SEQUENCE ACTING AS PAUSE (RELIABLE SEND METHOD) ---
$*F4::
    if (WinActive("ahk_exe EliteDangerous64.exe") && keySwapActive)
    {
        if (F4SeqRunning)
            return
        F4SeqRunning := true

        SendInput {F4 down}
        Sleep 50
        SendInput {F4 up}

        SetTimer, F4_Seq_Step2, -2000
    }
    else
    {
        SendInput {F4 down}
        Sleep 50
        SendInput {F4 up}
    }
return

; --- Timer: first F5 ---
F4_Seq_Step2:
    SendInput {F5 down}
    Sleep 50
    SendInput {F5 up}
    SetTimer, F4_Seq_Step3, -4000
return

; --- Timer: second F5 and cleanup ---
F4_Seq_Step3:
    SendInput {F5 down}
    Sleep 50
    SendInput {F5 up}

    ReleaseAllModifiers()
    F4SeqRunning := false
return

; --- Modifier monitor to prevent focus lock-ups ---
MonitorModifiers:
    if (!keySwapActive || !WinActive("ahk_exe EliteDangerous64.exe"))
    {
        ReleaseAllModifiers()
        return
    }
    CheckAndReleaseModifier("LAlt")
    CheckAndReleaseModifier("RAlt")
    CheckAndReleaseModifier("LShift")
    CheckAndReleaseModifier("RShift")
    CheckAndReleaseModifier("LCtrl")
    CheckAndReleaseModifier("RCtrl")
    CheckAndReleaseModifier("LWin")
    CheckAndReleaseModifier("RWin")
return

; --- CLEAN EXIT ROUTINE ---
CleanupAndExit:
    StopModifierGuard()
    ReleaseAllModifiers()
    Gui, CustomTip:Destroy
    ExitApp
return