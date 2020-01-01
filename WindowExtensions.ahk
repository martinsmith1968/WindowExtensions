#NoEnv  		; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Screen
SetFormat, float, 0.0
SetBatchLines, 10ms 
SetTitleMatchMode, 2

;--------------------------------------------------------------------------------
; Initialisation
AppName        := "WindowExtensions"
AppTitle       := "Window Extensions"
AppDescription := "Window Extensions Menu and HotKeys"
AppNotes       := "Concise and consistent control over Window Positions. Right-click right half of Window Caption bar to invoke, or hit WinKey-W"
AppURL         := "https://github.com/martinsmith1968/WindowExtensions"
AppVersion     := "1.4.2.0"

;--------------------------------------------------------------------------------
; Setup Tray Menu
Menu, Tray, NoStandard
Menu, Tray, Tip, %AppTitle%

Menu, Tray, Add, Con&figure..., TrayConfigureHandler
try Menu, Tray, Icon, Con&figure..., %A_ScriptFullPath%, 0
Menu, Tray, Add
Menu, Tray, Add, &About..., TrayAboutHandler
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
#Include AboutGui.ahk

return

;--------------------------------------------------------------------------------
TrayExitHandler:
ExitApp

;--------------------------------------------------------------------------------
TrayAboutHandler:
ShowAbout()
return

;--------------------------------------------------------------------------------
TrayConfigureHandler:
ShowUserConfig()
return
