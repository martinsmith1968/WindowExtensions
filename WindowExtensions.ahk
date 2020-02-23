#NoEnv          ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Screen
SetFormat, float, 0.0
SetBatchLines, 10ms 
SetTitleMatchMode, 2

;--------------------------------------------------------------------------------
; Application Details
AppName        := "WindowExtensions"
AppTitle       := "Window Extensions"
AppDescription := "Window Extensions Menu and HotKeys"
AppCopyright   := "Copyright © 2020 Martin Smith"
AppNotes       := "Concise and consistent control over Window Positions. Right-click right half of Window Caption bar to invoke, or hit WinKey-W"
AppURL         := "https://github.com/martinsmith1968/WindowExtensions"
AppVersion     := "1.6.7.0"

;--------------------------------------------------------------------------------
; Includes
#Include Lib\Logging.ahk
LogInit()

;--------------------------------------------------------------------------------
; System Information
SysGet, G_CaptionHeight, 4      ; SM_CYCAPTION
SysGet, G_BorderHeight, 5       ; SM_CXBORDER
SysGet, G_MenuDropAlignment, 40 ; SM_MENUDROPALIGNMENT
SysGet, G_MonitorCount, MonitorCount
SysGet, G_PrimaryMonitorIndex, MonitorPrimary

SplitPath A_ScriptFullPath, , ScriptFilePath, , ScriptFileNameNoExt
IconLibraryFileName := ScriptFilePath . "\" . ScriptFileNameNoExt . ".icl"

G_CaptionHitHeight := G_CaptionHeight + (G_BorderHeight * 2)
G_LeftAlignedMenus := (G_MenuDropAlignment = 0)

LogText("G_CaptionHeight: " G_CaptionHeight)
LogText("G_BorderHeight: " G_BorderHeight)
LogText("G_MonitorCount: " G_MonitorCount)
LogText("G_PrimaryMonitorIndex: " G_PrimaryMonitorIndex)
LogText("G_CaptionHitHeight: " G_CaptionHitHeight)
LogText("G_LeftAlignedMenus: " G_LeftAlignedMenus)

;--------------------------------------------------------------------------------
; Globals Declarations
G_UserConfig :=
G_ActiveWindow :=
G_CurrentMouse :=
G_MenuTitle := AppTitle

OnExit, ExitHandler

;--------------------------------------------------------------------------------
; Auto-Execute section
OnInit()        ; Perform module initialisation - not reliant on other modules or globals
InitGlobals()   ; 
OnStartup()     ; Perform module startup - may rely on other modules Init

return          ; End of script's auto-execute section.


;--------------------------------------------------------------------------------
; Exit Handler
ExitHandler:
LogText("Raising OnExit...")
OnExit()
LogText("Exiting...")
; Must do this for the OnExit subroutine to actually Exit the script.
ExitApp

;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Modules
#Include TrayMenu.ahk
#include WindowMenu.ahk
#Include WindowHotKeys.ahk
#Include WindowExtensionsUserConfigGui.ahk
#Include AboutGui.ahk

;--------------------------------------------------------------------------------
; Initialise global variables once everything else initialised
InitGlobals()
{
    global G_UserConfig
    
    G_UserConfig := new WindowExtensionsUserConfig()
}

;--------------------------------------------------------------------------------
; Module initialisation
OnInit()
{
    WindowExtensionsUserConfig_OnInit()
    WindowPositions_OnInit()
    DesktopIcons_OnInit()
    WindowMenu_OnInit()
    TrayMenu_OnInit()
}

;--------------------------------------------------------------------------------
; OnStartup event
OnStartup()
{
    WindowExtensionsUserConfig_OnStartup()
    WindowMenu_OnStartup()
    TrayMenu_OnStartup()
}

;--------------------------------------------------------------------------------
; OnExit event
OnExit()
{
    WindowMenu_OnExit()
}

;--------------------------------------------------------------------------------
; OnUserConfigUpdated event
OnUserConfigUpdated()
{
    BuildWindowMenu()
    BuildTrayMenu()
    WindowExtensionsUserConfig_OnConfigUpdated()
}
