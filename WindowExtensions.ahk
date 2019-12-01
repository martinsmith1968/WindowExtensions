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
; Setup Menu
Menu, Tray, Tip, %AppTitle%

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

;--------------------------------------------------------------------------------
; ToDo
; ====
; Include Icons for each menu entry
; User Configuration Dialog
; Support other config value types
; Remove AHK menu entries from Tray Icon
