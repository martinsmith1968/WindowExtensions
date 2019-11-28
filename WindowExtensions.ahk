#NoEnv  		; Recommended for performance and compatibility with future AutoHotkey releases.
; #NoTrayIcon
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

;--------------------------------------------------------------------------------
; Modules
#include WindowMenu.ahk
#Include WindowHotKeys.ahk

;--------------------------------------------------------------------------------
; ToDo
; User Configuration (Gutter Size, etc)
; Toast Notifications

