#Include Lib\Logging.ahk
#Include Lib\WindowObjects.ahk
#Include Lib\StringUtils.ahk
#Include Lib\ArrayUtils.ahk
#Include Lib\WindowFunctions.ahk
#Include Lib\WindowPositions.ahk
#Include Lib\DesktopIcons.ahk

;--------------------------------------------------------------------------------
; System Information
SysGet, G_CaptionHeight, 4 ; SM_CYCAPTION
SysGet, G_BorderHeight, 5 ; SM_CXBORDER
SysGet, G_MenuDropAlignment, 40 ; SM_MENUDROPALIGNMENT
SysGet, G_MonitorCount, MonitorCount
SysGet, G_PrimaryMonitorIndex, MonitorPrimary

G_CaptionHitHeight := G_CaptionHeight + (G_BorderHeight * 2)
G_LeftAlignedMenus := (G_MenuDropAlignment = 0)

LogText("G_CaptionHeight: " G_CaptionHeight)
LogText("G_BorderHeight: " G_BorderHeight)
LogText("G_MonitorCount: " G_MonitorCount)
LogText("G_PrimaryMonitorIndex: " G_PrimaryMonitorIndex)
LogText("G_CaptionHitHeight: " G_CaptionHitHeight)
LogText("G_LeftAlignedMenus: " G_LeftAlignedMenus)

;--------------------------------------------------------------------------------
; Initialisation
G_ActiveWindow :=
G_CurrentMouse :=
G_MenuTitle := AppTitle
G_SaveWindowPositionsMenuTitle := ""
G_RestoreWindowPositionsMenuTitle := ""
G_SaveDesktopIconsMenuTitle := ""
G_RestoreDesktopIconsMenuTitle := ""

SplitPath A_ScriptFullPath, , ScriptFilePath, , ScriptFileNameNoExt
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
; Build Menu
menuIndex := 0

Menu, WindowMenu, Add, %G_MenuTitle%, NullHandler
menuIndex += 1
Menu, WindowMenu, Icon, %G_MenuTitle%, Shell32.dll, 20
menuIndex += 1

; Standard Window Sizes
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("&Optimum Size", "OptimumSizeHandler", "MOVESIZE_COMMON_OPTIMUM", menuIndex)
menuIndex := AddWindowMenuItem("Su&b-Optimum Size", "SubOptimumSizeHandler", "MOVESIZE_COMMON_SUBOPTIMUM", menuIndex)
menuIndex := AddWindowMenuItem("M&edium Size", "MediumSizeHandler", "MOVESIZE_COMMON_MEDIUM", menuIndex)
menuIndex := AddWindowMenuItem("Sma&ll Size", "SmallSizeHandler", "MOVESIZE_COMMON_SMALL", menuIndex)
menuIndex := AddWindowMenuItem("T&iny Size", "TinySizeHandler", "MOVESIZE_COMMON_TINY", menuIndex)

; Move to known columns of the Screen
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("&Left Column", "MoveColumnLeftHandler", "MOVESIZE_COLUMN_LEFT", menuIndex)
menuIndex := AddWindowMenuItem("Ce&ntre Column", "MoveColumnCentreHandler", "MOVESIZE_COLUMN_CENTRE", menuIndex)
menuIndex := AddWindowMenuItem("&Right Column", "MoveColumnRightHandler", "MOVESIZE_COLUMN_RIGHT", menuIndex)

; Multi-Monitor spanning
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("&Fit Current Monitor", "SpanCurrentMonitorHandler", "MOVESIZE_SPAN_CURRENT", menuIndex)
if (G_MonitorCount > 1)
{
    menuIndex := AddWindowMenuItem("Span &Monitor Width", "SpanMonitorWidthHandler", "MOVESIZE_SPAN_WIDTH", menuIndex)
    menuIndex := AddWindowMenuItem("Span &Monitor Height", "SpanMonitorHeightHandler", "MOVESIZE_SPAN_HEIGHT", menuIndex)
    menuIndex := AddWindowMenuItem("Span &All Monitors", "SpanAllMonitorsHandler", "MOVESIZE_SPAN_ALL", menuIndex)
}

; Window Positions
menuIndex := AddWindowMenuItem("", "", "", menuIndex)

G_SaveWindowPositionsMenuTitle := "Save Window &Positions"
menuIndex := AddWindowMenuItem(G_SaveWindowPositionsMenuTitle, "SaveWindowPositionsHandler", "POSITION_SAVE", menuIndex)

G_RestoreWindowPositionsMenuTitle := "Restore Window &Positions"
menuIndex := AddWindowMenuItem(G_RestoreWindowPositionsMenuTitle, "RestoreWindowPositionsHandler", "POSITION_RESTORE", menuIndex)

; Move to Corners
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("Move &Centre", "CentreHandler", "MOVE_CENTRE", menuIndex)
menuIndex := AddWindowMenuItem("Move &Top Left", "MoveTopLeftHandler", "MOVE_CORNER_TOPLEFT", menuIndex)
menuIndex := AddWindowMenuItem("Move &Top Right", "MoveTopRightHandler", "MOVE_CORNER_TOPRIGHT", menuIndex)
menuIndex := AddWindowMenuItem("Move &Bottom Left", "MoveBottomLeftHandler", "MOVE_CORNER_BOTTOMLEFT", menuIndex)
menuIndex := AddWindowMenuItem("Move &Bottom Right", "MoveBottomRightHandler", "MOVE_CORNER_BOTTOMRIGHT", menuIndex)

; Rollup
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("Roll&up", "RollupHandler", "SIZE_COMMON_ROLLUP", menuIndex)

; Topmost handling
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("Set Top&Most On", "TopmostSetHandler", "POSITION_ZORDER_TOPMOSTON", menuIndex)
menuIndex := AddWindowMenuItem("Set Top&Most Off", "TopmostUnsetHandler", "POSITION_ZORDER_TOPMOSTOFF", menuIndex)
menuIndex := AddWindowMenuItem("&Toggle TopMost", "TopmostToggleHandler", "POSITION_ZORDER_TOPMOSTTOGGLE", menuIndex)

; Transparency
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("Set Transparency &75%", "TransparencySet75Handler", "POSITION_TRANSPARENCY75", menuIndex)
menuIndex := AddWindowMenuItem("Set Transparency &50%", "TransparencySet50Handler", "POSITION_TRANSPARENCY50", menuIndex)
menuIndex := AddWindowMenuItem("Set Transparency &25%", "TransparencySet25Handler", "POSITION_TRANSPARENCY25", menuIndex)
menuIndex := AddWindowMenuItem("Set Transparency &0%", "TransparencySet0Handler", "POSITION_TRANSPARENCY0", menuIndex)

; Send to back
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("Send to Bac&k", "SendToBackHandler", "POSITION_ZORDER_SENDTOBACK", menuIndex)

; Window Positions
menuIndex := AddWindowMenuItem("", "", "", menuIndex)

G_SaveDesktopIconsMenuTitle := "Save &Desktop Icons"
menuIndex := AddWindowMenuItem(G_SaveDesktopIconsMenuTitle, "SaveDesktopIconsHandler", "DESKTOP_ICONS_SAVE", menuIndex)

G_RestoreDesktopIconsMenuTitle := "Restore &Desktop Icons"
menuIndex := AddWindowMenuItem(G_RestoreDesktopIconsMenuTitle, "RestoreDesktopIconsHandler", "DESKTOP_ICONS_RESTORE", menuIndex)

; Cancel menu
menuIndex := AddWindowMenuItem("", "", "", menuIndex)
menuIndex := AddWindowMenuItem("&Cancel", "NullHandler", "", menuIndex)

; This line will unroll any rolled up windows if the script exits
; for any reason:
OnExit, ExitSub

return  ; End of script's auto-execute section.

ExitSub:
RestoreRollupWindows()
ExitApp  ; Must do this for the OnExit subroutine to actually Exit the script.


;--------------------------------------------------------------------------------
; Menu Handlers
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
OptimumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.GutterSize * 1))
return

SubOptimumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.GutterSize * 2))
return

MediumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.GutterSize * 3))
return

SmallSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.GutterSize * 4))
return

TinySizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.GutterSize * 5))
return

;--------------------------------------------------------------------------------
MoveColumnLeftHandler:
SetWindowByColumn(G_ActiveWindow, 1, 3, G_UserConfig.ColumnGutterSize)
return

MoveColumnCentreHandler:
SetWindowByColumn(G_ActiveWindow, 2, 3, G_UserConfig.ColumnGutterSize)
return

MoveColumnRightHandler:
SetWindowByColumn(G_ActiveWindow, 3, 3, G_UserConfig.ColumnGutterSize)
return

;--------------------------------------------------------------------------------
SpanCurrentMonitorHandler:
monitor := new Monitor(G_ActiveWindow.MonitorIndex)
monitorWorkArea := monitor.WorkArea
SetWindowSpanMonitors(G_ActiveWindow, monitorWorkArea.Left, monitorWorkArea.Top, monitorWorkArea.Right, monitorWorkArea.Bottom, G_UserConfig.SpanMonitorGutterSize)
return

SpanMonitorWidthHandler:
monitor := new Monitor(G_ActiveWindow.MonitorIndex)
monitorWorkArea := monitor.WorkArea
SetWindowSpanMonitors(G_ActiveWindow, "", monitorWorkArea.Top, "", monitorWorkArea.Bottom, G_UserConfig.SpanMonitorGutterSize)
return

SpanMonitorHeightHandler:
monitor := new Monitor(G_ActiveWindow.MonitorIndex)
monitorWorkArea := monitor.WorkArea
SetWindowSpanMonitors(G_ActiveWindow, monitorWorkArea.Left, "", monitorWorkArea.Right, "", G_UserConfig.SpanMonitorGutterSize)
return

SpanAllMonitorsHandler:
SetWindowSpanMonitors(G_ActiveWindow, "", "", "", "", G_UserConfig.SpanMonitorGutterSize)
return

;--------------------------------------------------------------------------------
SaveWindowPositionsHandler:
SaveWindowPositions()
return

RestoreWindowPositionsHandler:
RestoreWindowPositions()
return

;--------------------------------------------------------------------------------
CentreHandler:
SetWindowToCentre(G_ActiveWindow)
return

MoveTopLeftHandler:
SetWindowByGrid(G_ActiveWindow, 1, 1, 2, 2, G_UserConfig.GridGutterSize)
return

MoveTopRightHandler:
SetWindowByGrid(G_ActiveWindow, 1, 2, 2, 2, G_UserConfig.GridGutterSize)
return

MoveBottomLeftHandler:
SetWindowByGrid(G_ActiveWindow, 2, 1, 2, 2, G_UserConfig.GridGutterSize)
return

MoveBottomRightHandler:
SetWindowByGrid(G_ActiveWindow, 2, 2, 2, 2, G_UserConfig.GridGutterSize)
return

;--------------------------------------------------------------------------------
RollupHandler:
RollupToggleWindow(G_ActiveWindow, G_CaptionHitHeight)
return

;--------------------------------------------------------------------------------
TopmostSetHandler:
SetWindowTop(G_ActiveWindow, 1)
return

TopmostUnsetHandler:
SetWindowTop(G_ActiveWindow, 0)
return

TopmostToggleHandler:
SetWindowTop(G_ActiveWindow, -1)
return

;--------------------------------------------------------------------------------
TransparencySet75Handler:
SetWindowTransparency(G_ActiveWindow, 64)
return

TransparencySet50Handler:
SetWindowTransparency(G_ActiveWindow, 128)
return

TransparencySet25Handler:
SetWindowTransparency(G_ActiveWindow, 192)
return

TransparencySet0Handler:
SetWindowTransparency(G_ActiveWindow, 255)
return

;--------------------------------------------------------------------------------
SaveDesktopIconsHandler:
SaveDesktopIcons()
return

RestoreDesktopIconsHandler:
RestoreDesktopIcons()
return

;--------------------------------------------------------------------------------
SendToBackHandler:
SendWindowToBack(G_ActiveWindow)
return

;--------------------------------------------------------------------------------
NullHandler:
return

;--------------------------------------------------------------------------------
; AddWindowMenuItem - Add a Menu Item to the main Window Menu
AddWindowMenuItem(text, handler, iconName, menuIndex := 0)
{
	global WindowMenu
	global IconLibraryFileName
	
	If (text = "")
	{
		Menu, WindowMenu, Add
	}
	else
	{
		Menu, WindowMenu, Add, %text%, %handler%
		
		iconIndex := GetIconIndex(iconName)
		if (iconIndex > 0)
		{
			Menu, WindowMenu, Icon, %text%,  %IconLibraryFileName%, %iconIndex%
		}
	}
	
	return menuIndex + 1
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
	global G_MenuTitle
	global G_SaveWindowPositionsMenuTitle
	global G_RestoreWindowPositionsMenuTitle
	global G_SaveDesktopIconsMenuTitle
	global G_RestoreDesktopIconsMenuTitle
	
	; Build Window Details
	newMenuTitle := theWindow.Title . " (" . theWindow.ProcessName . ") [" . theWindow.Left . ", " . theWindow.Top . ", " . theWindow.Width . ", " . theWindow.Height . "]"

	processPath := theWindow.ProcessPath

	; Change Menu MainTitle
	if (newMenuTitle <> G_MenuTitle)
	{
		G_MenuTitle := newMenuTitle
		Menu, WindowMenu, Rename, 1&,  %G_MenuTitle%
	}
	
	; Configure Window Positions Menu
	desktopSize := GetDesktopSize()
	
	title := "Save Window &Positions (" . desktopSize.DimensionsText . ")"
	if (title <> G_SaveWindowPositionsMenuTitle)
	{
		Menu, WindowMenu, Rename, %G_SaveWindowPositionsMenuTitle%, %title%
		G_SaveWindowPositionsMenuTitle := title
		LogText("G_SaveWindowPositionsMenuTitle: " . G_SaveWindowPositionsMenuTitle)
	}
	
	title := "Restore Window &Positions (" . desktopSize.DimensionsText . ")"
	if (title <> G_RestoreWindowPositionsMenuTitle)
	{
		Menu, WindowMenu, Rename, %G_RestoreWindowPositionsMenuTitle%, %title%
		G_RestoreWindowPositionsMenuTitle := title
		LogText("G_RestoreWindowPositionsMenuTitle: " . G_RestoreWindowPositionsMenuTitle)
	}
	
	title := "Save &Desktop Icons (" . desktopSize.DimensionsText . ")"
	if (title <> G_SaveDesktopIconsMenuTitle)
	{
		Menu, WindowMenu, Rename, %G_SaveDesktopIconsMenuTitle%, %title%
		G_SaveDesktopIconsMenuTitle := title
		LogText("G_SaveDesktopIconsMenuTitle: " . G_SaveDesktopIconsMenuTitle)
	}
	
	title := "Restore &Desktop Icons (" . desktopSize.DimensionsText . ")"
	if (title <> G_RestoreDesktopIconsMenuTitle)
	{
		Menu, WindowMenu, Rename, %G_RestoreDesktopIconsMenuTitle%, %title%
		G_RestoreDesktopIconsMenuTitle := title
		LogText("G_RestoreDesktopIconsMenuTitle: " . G_RestoreDesktopIconsMenuTitle)
	}
	
	If (HasSavedWindowPositionFile(desktopSize))
	{
		Menu, WindowMenu, Enable, %G_RestoreWindowPositionsMenuTitle%
	}
	else
	{
		Menu, WindowMenu, Disable, %G_RestoreWindowPositionsMenuTitle%
	}
	
	If (HasSavedDesktopIconsFile(desktopSize))
	{
		Menu, WindowMenu, Enable, %G_RestoreDesktopIconsMenuTitle%
	}
	else
	{
		Menu, WindowMenu, Disable, %G_RestoreDesktopIconsMenuTitle%
	}
	
	try
	{
		Menu, WindowMenu, Icon, 1&, %processPath%, 0
	}
	catch e
	{
	}
	
	; Enable / Disable as appropriate
	if (IsWindowTopMost(theWindow.WindowHandle))
	{
		Menu, WindowMenu, Disable, Set Top&Most On
		Menu, WindowMenu, Enable, Set Top&Most Off
	}
	else
	{
		Menu, WindowMenu, Enable, Set Top&Most On
		Menu, WindowMenu, Disable, Set Top&Most Off
	}
	
	; Show Popup Menu
	Menu, WindowMenu, Show
}

;--------------------------------------------------------------------------------
; WindowsKey+W
#w::
	; Get Active Window
	WinGet, theWindow, ID, A
	MouseGetPos, mouseX, mouseY

	G_ActiveWindow := New Window(theWindow)
	G_CurrentMouse := New Coordinate(mouseX, mouseY)

	ShowMenu(G_ActiveWindow)
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
