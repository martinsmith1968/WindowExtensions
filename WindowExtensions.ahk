#NoEnv  		; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

CoordMode, Mouse, Screen

SetFormat, float, 0.0
SetBatchLines, 10ms 
SetTitleMatchMode, 2

;--------------------------------------------------------------------------------
; Initialisation
AppTitle := "Window Extensions"

;--------------------------------------------------------------------------------
; Setup Tray Menu
Menu, Tray, NoStandard
Menu, Tray, Tip, %AppTitle%

Menu, Tray, Add, Con&figure..., TrayConfigureHandler
try Menu, Tray, Icon, Con&figure..., %A_ScriptFullPath%, 0
Menu, Tray, Add
Menu, Tray, Add, Exit, TrayExitHandler

;--------------------------------------------------------------------------------
; Includes
#Include Lib\Logging.ahk
#Include WindowExtensionsUserConfig.ahk

;--------------------------------------------------------------------------------
; Globals
G_UserConfig := new WindowExtensionsUserConfig()

;--------------------------------------------------------------------------------
; Modules
#include WindowMenu.ahk
#Include WindowHotKeys.ahk
#Include WindowExtensionsUserConfigGui.ahk

return

;--------------------------------------------------------------------------------
TrayExitHandler:
ExitApp

;--------------------------------------------------------------------------------
TrayConfigureHandler:
ShowUserConfig()
return

;--------------------------------------------------------------------------------
; ToDo
; ====
; Include Icons for each menu entry
; User Configuration Dialog
; Support other config value types
; Remove AHK menu entries from Tray Icon
