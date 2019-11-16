#include Lib\TrayIcon.ahk

;--------------------------------------------------------------------------------
; ! {Alt}
; + {Shift}
; ^ {Ctrl}
; # {LWin} {RWin}
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Shift+Escape - Minimize Active window
+Esc::
LogText("Executing Shift+Escape:")
WinMinimize , A
return

;--------------------------------------------------------------------------------
; Win+\ - Invoke Desktop Tray Launcher Menu
#\::
LogText("Executing Win+\: for DesktopTrayLauncher.exe")
TrayIcon_Button("DesktopTrayLauncher.exe")
return

;--------------------------------------------------------------------------------
; Firefox
#If WinActive("ahk_exe firefox.exe")
    ; F9 - Hide images
    F9::
		LogText("Executing F9: firefox.exe")
        Send !t
        Sleep, 100
        Send w w {Enter} i m
        return
#if

;--------------------------------------------------------------------------------
; Notepad++
#If WinActive("ahk_exe notepad++.exe")
    ; Ctrl+F4 = Ctrl+W - Close current file
    ^F4::
		LogText("Executing Ctrl+F4: notepad++.exe")
		Send ^w
		return
#if

;--------------------------------------------------------------------------------
; Opera
#If WinActive("ahk_exe opera.exe")
    ; F12 = Ctrl-Shirt-C - Open Debug Inspector
    F12::
		LogText("Executing F12: opera.exe")
		Send ^+I
		return
#if
