#NoEnv  		; Recommended for performance and compatibility with future AutoHotkey releases.
; #NoTrayIcon
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

CoordMode, Mouse, Screen

SetFormat, float, 0.0
SetBatchLines, 10ms 
SetTitleMatchMode, 2

#Include Logging.ahk
#Include Classes.ahk
#Include StringUtils.ahk
#Include ArrayUtils.ahk
#Include WindowFunctions.ahk

;--------------------------------------------------------------------------------
; Initialisation
SplitPath A_ScriptFullPath, , ScriptFilePath, , ScriptFileNameNoExt

; Initialise Log
LogFileSuffix := ""
IfNotEqual, A_IsCompiled, 1
{
	LogFileSuffix := ".Debug"
}

LogFile := A_Temp . "\" . ScriptFileNameNoExt . LogFileSuffix . ".log"
LogStart()

;--------------------------------------------------------------------------------
; System Information
SysGet, G_CaptionHeight, 4 ; SM_CYCAPTION
SysGet, G_BorderHeight, 5 ; SM_CXBORDER
SysGet, G_MenuDropAlignment, 40 ; SM_MENUDROPALIGNMENT
SysGet, G_MonitorCount, MonitorCount
SysGet, G_PrimaryMonitorIndex, MonitorPrimary

G_CaptionHitHeight := G_CaptionHeight + (G_BorderHeight * 2)
G_LeftAlignedMenus := (G_MenuDropAlignment = 0)

G_CascadeGutterSize := 30
G_ColumnGutterSize := 0
G_GridGutterSize := 0
G_SpanMonitorGutterSize := 0

LogText("G_CaptionHeight: " G_CaptionHeight)
LogText("G_BorderHeight: " G_BorderHeight)
LogText("G_CaptionHitHeight: " G_CaptionHitHeight)
LogText("G_MonitorCount: " G_MonitorCount)
LogText("G_PrimaryMonitorIndex: " G_PrimaryMonitorIndex)

;--------------------------------------------------------------------------------
; Initialisation
G_RollupList := Object()

G_ActiveWindow :=
G_CurrentMouse :=

IconLibraryFileName := ScriptFilePath . "\" . ScriptFileNameNoExt . ".icl"

IconIndexes := Object()
IconIndexes.Insert("MOVESIZE_COLUMN_CENTRE")
IconIndexes.Insert("MOVESIZE_COLUMN_LEFT")
IconIndexes.Insert("MOVESIZE_COLUMN_RIGHT")
IconIndexes.Insert("MOVESIZE_COMMON_MEDIUM")
IconIndexes.Insert("MOVESIZE_COMMON_OPTIMUM")
IconIndexes.Insert("MOVESIZE_COMMON_SMALL")
IconIndexes.Insert("MOVESIZE_COMMON_SUBOPTIMUM")
IconIndexes.Insert("MOVESIZE_COMMON_TINY")
IconIndexes.Insert("MOVE_CENTRE")
IconIndexes.Insert("MOVE_CORNER_BOTTOMLEFT")
IconIndexes.Insert("MOVE_CORNER_BOTTOMRIGHT")
IconIndexes.Insert("MOVE_CORNER_TOPLEFT")
IconIndexes.Insert("MOVE_CORNER_TOPRIGHT")
IconIndexes.Insert("POSITION_TRANSPARENCY0")
IconIndexes.Insert("POSITION_TRANSPARENCY25")
IconIndexes.Insert("POSITION_TRANSPARENCY50")
IconIndexes.Insert("POSITION_TRANSPARENCY75")
IconIndexes.Insert("POSITION_ZORDER_SENDTOBACK")
IconIndexes.Insert("POSITION_ZORDER_TOPMOSTOFF")
IconIndexes.Insert("POSITION_ZORDER_TOPMOSTON")
IconIndexes.Insert("POSITION_ZORDER_TOPMOSTTOGGLE")
IconIndexes.Insert("SIZE_COMMON_ROLLUP")

;--------------------------------------------------------------------------------
; Setup Menu
Menu, Tray, Tip, Window Menu

MenuTitle = Window Menu

;--------------------------------------------------------------------------------
; Build Menu
Menu, WindowMenu, Add, %MenuTitle%, NullHandler
Menu, WindowMenu, Icon, %MenuTitle%, Shell32.dll, 20

; Standard Window Sizes
Menu, WindowMenu, Add
AddWindowMenuItem("&Fit Monitor", "FitMonitorSizeHandler", "MOVESIZE_COMMON_OPTIMUM")
AddWindowMenuItem("&Optimum Size", "OptimumSizeHandler", "MOVESIZE_COMMON_OPTIMUM")
AddWindowMenuItem("Su&b-Optimum Size", "SubOptimumSizeHandler", "MOVESIZE_COMMON_SUBOPTIMUM")
AddWindowMenuItem("M&edium Size", "MediumSizeHandler", "MOVESIZE_COMMON_MEDIUM")
AddWindowMenuItem("Sma&ll Size", "SmallSizeHandler", "MOVESIZE_COMMON_SMALL")
AddWindowMenuItem("T&iny Size", "TinySizeHandler", "MOVESIZE_COMMON_TINY")

; Rollup
Menu, WindowMenu, Add
AddWindowMenuItem("Roll&up", "RollupHandler", "SIZE_COMMON_ROLLUP")

; Move to known columns of the Screen
Menu, WindowMenu, Add
AddWindowMenuItem("&Left Column", "MoveColumnLeftHandler", "MOVESIZE_COLUMN_LEFT")
AddWindowMenuItem("Ce&ntre Column", "MoveColumnCentreHandler", "MOVESIZE_COLUMN_CENTRE")
AddWindowMenuItem("&Right Column", "MoveColumnRightHandler", "MOVESIZE_COLUMN_RIGHT")

; Multi-Monitor spanning
if (G_MonitorCount > 1)
{
    Menu, WindowMenu, Add
    AddWindowMenuItem("S&pan Monitor Width", "SpanMonitorWidthHandler", "MOVESIZE_SPAN_WIDTH")
    AddWindowMenuItem("S&pan Monitor Height", "SpanMonitorHeightHandler", "MOVESIZE_SPAN_HEIGHT")
    AddWindowMenuItem("S&pan All Monitors", "SpanAllMonitors", "MOVESIZE_SPAN_ALL")
}

; Move to Corners
Menu, WindowMenu, Add
AddWindowMenuItem("Move &Centre", "CentreHandler", "MOVE_CENTRE")
AddWindowMenuItem("Move &Top Left", "MoveTopLeftHandler", "MOVE_CORNER_TOPLEFT")
AddWindowMenuItem("Move &Top Right", "MoveTopRightHandler", "MOVE_CORNER_TOPRIGHT")
AddWindowMenuItem("Move &Bottom Left", "MoveBottomLeftHandler", "MOVE_CORNER_BOTTOMLEFT")
AddWindowMenuItem("Move &Bottom Right", "MoveBottomRightHandler", "MOVE_CORNER_BOTTOMRIGHT")

; Topmost handling
Menu, WindowMenu, Add
AddWindowMenuItem("Set TopMost O&n", "TopHandlerSet", "POSITION_ZORDER_TOPMOSTON")
AddWindowMenuItem("Set TopMost O&ff", "TopHandlerUnset", "POSITION_ZORDER_TOPMOSTOFF")
AddWindowMenuItem("&Toggle TopMost", "TopHandlerToggle", "POSITION_ZORDER_TOPMOSTTOGGLE")

; Transparency
Menu, WindowMenu, Add
AddWindowMenuItem("Set Transparency &75%", "TransparencySet75", "POSITION_TRANSPARENCY75")
AddWindowMenuItem("Set Transparency &50%", "TransparencySet50", "POSITION_TRANSPARENCY50")
AddWindowMenuItem("Set Transparency &25%", "TransparencySet25", "POSITION_TRANSPARENCY25")
AddWindowMenuItem("Set Transparency &0%", "TransparencySet0", "POSITION_TRANSPARENCY0")

; Send to back
Menu, WindowMenu, Add
AddWindowMenuItem("Send to Bac&k", "SendToBackHandler", "POSITION_ZORDER_SENDTOBACK")

; Cancel menu
Menu, WindowMenu, Add
Menu, WindowMenu, Add, &Cancel, NullHandler

; This line will unroll any rolled up windows if the script exits
; for any reason:
OnExit, ExitSub

return  ; End of script's auto-execute section.

ExitSub:
RestoreRollupWindows()
ExitApp  ; Must do this for the OnExit subroutine to actually Exit the script.


;--------------------------------------------------------------------------------
; LABELS - Handlers
;--------------------------------------------------------------------------------

FitMonitorSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_CascadeGutterSize * 0))
return

OptimumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_CascadeGutterSize * 1))
return

SubOptimumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_CascadeGutterSize * 2))
return

MediumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_CascadeGutterSize * 3))
return

SmallSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_CascadeGutterSize * 3))
return

TinySizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_CascadeGutterSize * 5))
return

;---------------------------------------
SpanMonitorWidthHandler:
monitor := new Monitor(G_ActiveWindow.MonitorIndex)
monitorWorkArea := monitor.WorkArea

SetWindowSpanMonitors(G_ActiveWindow, "", monitorWorkArea.Top, "", monitorWorkArea.Bottom, G_SpanMonitorGutterSize)
return

;---------------------------------------
SpanMonitorHeightHandler:
monitor := new Monitor(G_ActiveWindow.MonitorIndex)
monitorWorkArea := monitor.WorkArea

SetWindowSpanMonitors(G_ActiveWindow, monitorWorkArea.Left, "", monitorWorkArea.Right, "", G_SpanMonitorGutterSize)
return

;---------------------------------------
SpanAllMonitors:
SetWindowSpanMonitors(G_ActiveWindow, "", "", "", "", G_SpanMonitorGutterSize)
return

CentreHandler:
SetWindowToCentre(G_ActiveWindow)
return

MoveTopLeftHandler:
SetWindowByGrid(G_ActiveWindow, 1, 1, 2, 2, G_GridGutterSize)
return

MoveTopRightHandler:
SetWindowByGrid(G_ActiveWindow, 1, 2, 2, 2, G_GridGutterSize)
return

MoveBottomLeftHandler:
SetWindowByGrid(G_ActiveWindow, 2, 1, 2, 2, G_GridGutterSize)
return

MoveBottomRightHandler:
SetWindowByGrid(G_ActiveWindow, 2, 2, 2, 2, G_GridGutterSize)
return

MoveColumnLeftHandler:
SetWindowByColumn(G_ActiveWindow, 1, 3, G_ColumnGutterSize)
return

MoveColumnCentreHandler:
SetWindowByColumn(G_ActiveWindow, 2, 3, G_ColumnGutterSize)
return

MoveColumnRightHandler:
SetWindowByColumn(G_ActiveWindow, 3, 3, G_ColumnGutterSize)
return

TopHandlerSet:
SetWindowTop(G_ActiveWindow, 1)
return

TopHandlerUnset:
SetWindowTop(G_ActiveWindow, 0)
return

TopHandlerToggle:
SetWindowTop(G_ActiveWindow, -1)
return

TransparencySet75:
SetWindowTransparency(G_ActiveWindow, 64)
return

TransparencySet50:
SetWindowTransparency(G_ActiveWindow, 128)
return

TransparencySet25:
SetWindowTransparency(G_ActiveWindow, 192)
return

TransparencySet0:
SetWindowTransparency(G_ActiveWindow, 255)
return

SendToBackHandler:
windowHandle := G_ActiveWindow.WindowHandle
WinSet, Bottom, , ahk_id %windowHandle%`
return

RollupHandler:
RollupToggleWindow(G_ActiveWindow)
return

NullHandler:
return

;--------------------------------------------------------------------------------
; AddWindowMenuItem - Add a Menu Item to the main Window Menu
AddWindowMenuItem(text, handler, iconName)
{
	global WindowMenu
	global IconLibraryFileName
	
	Menu, WindowMenu, Add, %text%, %handler%
	
	iconIndex := GetIconIndex(iconName)
	if (iconIndex > 0)
	{
		Menu, WindowMenu, Icon, %text%,  %IconLibraryFileName%, %iconIndex%
	}
}

;--------------------------------------------------------------------------------
; GetIconIndex - Find the array index of a named icon
GetIconIndex(iconName)
{
	global IconIndexes
	
	for index, element in IconIndexes
	{
		If (element = iconName)
		{
			return index
		}
	}
	
	return 0
}

;--------------------------------------------------------------------------------
; ShowMenu - Show the Window Control Menu
ShowMenu(theWindow)
{
	global MenuTitle
	
	; Build Window Details
	newMenuTitle := theWindow.Title . " (" . theWindow.ProcessName . ") [" . theWindow.Left . ", " . theWindow.Top . ", " . theWindow.Width . ", " . theWindow.Height . "]"

	processPath := theWindow.ProcessPath

	; Change Menu
	if (newMenuTitle <> MenuTitle)
	{
		MenuTitle := newMenuTitle
		Menu, WindowMenu, Rename, 1&,  %MenuTitle%
	}
	Menu, WindowMenu, Icon, 1&, %processPath%, 0
	
	; Enable / Disable as appropriate
	if (IsWindowTopMost(theWindow.WindowHandle))
	{
		Menu, WindowMenu, Disable, Set TopMost O&n
		Menu, WindowMenu, Enable, Set TopMost O&ff
	}
	else
	{
		Menu, WindowMenu, Enable, Set TopMost O&n
		Menu, WindowMenu, Disable, Set TopMost O&ff
	}
	
	; Show Popup Menu
	Menu, WindowMenu, Show
}

;--------------------------------------------------------------------------------
; RollupToggleWindow - Roll up a window to just its title bar
RollupToggleWindow(theWindow)
{
	global G_RollupList
	global G_CaptionHitHeight
	
	windowHandle := theWindow.WindowHandle
	
	for ruWindowId, ruHeight in G_RollupList
	{
		IfEqual, ruWindowId, %windowHandle%
		{
			WinMove, ahk_id %windowHandle%,,,,, %ruHeight%
			G_RollupList.Delete(windowHandle)
			return
		}
	}

	WinGetPos,,,, wsHeight, ahk_id %windowHandle%
	G_RollupList[windowHandle] := wsHeight

	WinMove, ahk_id %windowHandle%,,,,, %G_CaptionHitHeight%
}

;--------------------------------------------------------------------------------
; RollupWindow - Roll up a window to just its title bar
RestoreRollupWindows()
{
	global G_RollupList
	
	Loop, Parse, G_RollupList, |
	{
		if A_LoopField =  ; First field in list is normally blank.
			continue      ; So skip it.
		StringTrimRight, ws_Height, ws_Window%A_LoopField%, 0
		WinMove, ahk_id %A_LoopField%,,,,, %ws_Height%
	}
}

;--------------------------------------------------------------------------------
; WindowsKey+W
#w::
; Get Active Window
WinGet, theWindow, ID, A

activeWindow := New Window(theWindow)

ShowMenu(activeWindow)
return

;--------------------------------------------------------------------------------
; RightMouseButton
$~Rbutton::
; Get MousePos and Active Window
MouseGetPos, mouseX, mouseY, theWindow

G_ActiveWindow := New Window(theWindow)
G_CurrentMouse := New Coordinate(mouseX, mouseY)

LogText("G_ActiveWindow: " . G_ActiveWindow.Description)
LogText("G_CurrentMouse: " . G_CurrentMouse.Description)

; Get Mouse Monitor
currentMouseMonitor := New Monitor(G_CurrentMouse.MonitorIndex)
LogText("currentMouseMonitor: " . currentMouseMonitor.Description)
LogText("currentMouseMonitor.WorkArea: " . currentMouseMonitor.WorkArea.Description)

if (!G_CurrentMouse.IsInRectangle(currentMouseMonitor.WorkArea))
{
    LogText("Outside Monitor Area: " . currentMouseMonitor.WorkArea.Description)
    return
}

hitArea := G_ActiveWindow.GetHitArea(G_CaptionHeight)
if (!G_currentMouse.IsInRectangle(hitArea))
{
    LogText("Outside Window Hit Area: " . hitArea.Description)
    return
}

title := G_ActiveWindow.Title
description := G_ActiveWindow.Description

ShowMenu(G_ActiveWindow)

return
