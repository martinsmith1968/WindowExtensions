#Include Lib\Logging.ahk
#Include Lib\WindowObjects.ahk
#Include Lib\StringUtils.ahk
#Include Lib\ArrayUtils.ahk
#Include Lib\MathUtils.ahk
#Include Lib\MenuFunctions.ahk
#Include Lib\WindowFunctions.ahk
#Include Lib\WindowPositions.ahk
#Include Lib\DesktopIcons.ahk
#Include Lib\ListViewSelector.ahk
#Include WindowExtensionsUserConfig.ahk

;--------------------------------------------------------------------------------
; Globals
IconLibrary := []
WindowMenuName :=
G_SelectableWindowPositions := []

;--------------------------------------------------------------------------------
; Initialisation
WindowMenu_OnInit()
{
	global WindowMenuName
	
	WindowMenuName := "WindowMenu"
	BuildIconLibrary()
}

;--------------------------------------------------------------------------------
; OnStartup
WindowMenu_OnStartup()
{
	BuildWindowMenu()
}

;--------------------------------------------------------------------------------
; OnExit
WindowMenu_OnExit()
{
	RestoreRollupWindows()		; This line will unroll any rolled up windows if the script exits for any reason:
}

;--------------------------------------------------------------------------------
; Build Menu
BuildWindowMenu()
{
	global G_UserConfig
	global G_MonitorCount
	global G_MenuTitle
	global IconLibraryFileName
	global MenuLocationWindowMenu
	global WindowMenuName
	
	menuIndex := 0
	
	desktopSize := GetDesktopSize()

	try Menu, %WindowMenuName%, DeleteAll
	
	menuIndex := AddMenuItem(WindowMenuName, G_MenuTitle, "NullHandler", menuIndex)
	Menu, %WindowMenuName%, Icon, %G_MenuTitle%, Shell32.dll, 20

	; Standard Window Sizes
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "&Optimum Size", "OptimumSizeHandler", IconLibraryFileName, GetIconLibraryIndex("MOVESIZE_COMMON_OPTIMUM"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Su&b-Optimum Size", "SubOptimumSizeHandler", IconLibraryFileName, GetIconLibraryIndex("MOVESIZE_COMMON_SUBOPTIMUM"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "M&edium Size", "MediumSizeHandler", IconLibraryFileName, GetIconLibraryIndex("MOVESIZE_COMMON_MEDIUM"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Sma&ll Size", "SmallSizeHandler", IconLibraryFileName, GetIconLibraryIndex("MOVESIZE_COMMON_SMALL"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "T&iny Size", "TinySizeHandler", IconLibraryFileName, GetIconLibraryIndex("MOVESIZE_COMMON_TINY"), menuIndex)

	; Move to known columns of the Screen
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "&Left Column", "MoveColumnLeftHandler", IconLibraryFileName, GetIconLibraryIndex("MOVESIZE_COLUMN_LEFT"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Ce&ntre Column", "MoveColumnCentreHandler", IconLibraryFileName, GetIconLibraryIndex("MOVESIZE_COLUMN_CENTRE"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "&Right Column", "MoveColumnRightHandler", IconLibraryFileName, GetIconLibraryIndex("MOVESIZE_COLUMN_RIGHT"), menuIndex)

	; Multi-Monitor spanning
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "&Fit Current Monitor", "SpanCurrentMonitorHandler", IconLibraryFileName, GetIconLibraryIndex("MONITOR_FIT"), menuIndex)
	if (G_MonitorCount > 1)
	{
		menuIndex := AddMenuItemWithIcon(WindowMenuName, "Span &Monitor Width", "SpanMonitorWidthHandler", IconLibraryFileName, GetIconLibraryIndex("MONITOR_SPAN_WIDTH"), menuIndex)
		menuIndex := AddMenuItemWithIcon(WindowMenuName, "Span &Monitor Height", "SpanMonitorHeightHandler", IconLibraryFileName, GetIconLibraryIndex("MONITOR_SPAN_HEIGHT"), menuIndex)
		menuIndex := AddMenuItemWithIcon(WindowMenuName, "Span &All Monitors", "SpanAllMonitorsHandler", IconLibraryFileName, GetIconLibraryIndex("MONITOR_SPAN_ALL"), menuIndex)
	}

	; Window Positions
	if (ContainsFlag(G_UserConfig.MenuControl_WindowPositionsMenuLocation, MenuLocationWindowMenu))
	{
		menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)

		saveTitle := "Save Window &Positions (" . desktopSize.DimensionsText . ")"
		menuIndex := AddMenuItemWithIcon(WindowMenuName, saveTitle, "SaveWindowPositionsHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_SAVE"), menuIndex)

		restoreTitle := "Restore Window &Positions (" . desktopSize.DimensionsText . ")"
		menuIndex := AddMenuItemWithIcon(WindowMenuName, restoreTitle, "RestoreWindowPositionsHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_RESTORE"), menuIndex)

		restoreEnabled := HasSavedWindowPositionFile(desktopSize)
		EnableMenuItem(WindowMenuName, restoreTitle, restoreEnabled)

		if (HasMultipleSavedWindowPositionFiles(desktopSize))
		{
			restoreTitle := "Restore Window &Positions (" . desktopSize.DimensionsText . ")..."
			
			menuIndex := AddMenuItemWithIcon(WindowMenuName, restoreTitle, "RestoreMultipleWindowPositionsHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_RESTORE"), menuIndex)
		}
	}

	; Move to Corners
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Move &Centre", "CentreHandler", IconLibraryFileName, GetIconLibraryIndex("MOVE_CENTRE"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Move &Top Left", "MoveTopLeftHandler", IconLibraryFileName, GetIconLibraryIndex("MOVE_CORNER_TOPLEFT"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Move &Top Right", "MoveTopRightHandler", IconLibraryFileName, GetIconLibraryIndex("MOVE_CORNER_TOPRIGHT"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Move &Bottom Left", "MoveBottomLeftHandler", IconLibraryFileName, GetIconLibraryIndex("MOVE_CORNER_BOTTOMLEFT"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Move &Bottom Right", "MoveBottomRightHandler", IconLibraryFileName, GetIconLibraryIndex("MOVE_CORNER_BOTTOMRIGHT"), menuIndex)

	; Rollup
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Roll&up", "RollupHandler", IconLibraryFileName, GetIconLibraryIndex("SIZE_COMMON_ROLLUP"), menuIndex)

	; Topmost handling
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Set Top&Most On", "TopmostSetHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_ZORDER_TOPMOSTON"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Set Top&Most Off", "TopmostUnsetHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_ZORDER_TOPMOSTOFF"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "&Toggle TopMost", "TopmostToggleHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_ZORDER_TOPMOSTTOGGLE"), menuIndex)

	; Transparency
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Set Transparency &75%", "TransparencySet75Handler", IconLibraryFileName, GetIconLibraryIndex("POSITION_TRANSPARENCY75"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Set Transparency &50%", "TransparencySet50Handler", IconLibraryFileName, GetIconLibraryIndex("POSITION_TRANSPARENCY50"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Set Transparency &25%", "TransparencySet25Handler", IconLibraryFileName, GetIconLibraryIndex("POSITION_TRANSPARENCY25"), menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Set Transparency &0%", "TransparencySet0Handler", IconLibraryFileName, GetIconLibraryIndex("POSITION_TRANSPARENCY0"), menuIndex)

	; Send to back
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItemWithIcon(WindowMenuName, "Send to Bac&k", "SendToBackHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_ZORDER_SENDTOBACK"), menuIndex)

	; Desktop Icons
	if (ContainsFlag(G_UserConfig.MenuControl_DesktopIconsMenuLocation, MenuLocationWindowMenu))
	{
		menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)

		saveTitle := "Save &Desktop Icons (" . desktopSize.DimensionsText . ")"
		menuIndex := AddMenuItemWithIcon(WindowMenuName, saveTitle, "SaveDesktopIconsHandler", IconLibraryFileName, GetIconLibraryIndex("DESKTOPICONS_SAVE"), menuIndex)

		restoreTitle := "Restore &Desktop Icons (" . desktopSize.DimensionsText . ")"
		menuIndex := AddMenuItemWithIcon(WindowMenuName, restoreTitle, "RestoreDesktopIconsHandler", IconLibraryFileName, GetIconLibraryIndex("DESKTOPICONS_RESTORE"), menuIndex)

		restoreEnabled := HasSavedDesktopIconsFile(desktopSize)
		EnableMenuItem(WindowMenuName, restoreTitle, restoreEnabled)
	}

	; Cancel menu
	menuIndex := AddMenuItemSeparator(WindowMenuName, menuIndex)
	menuIndex := AddMenuItem(WindowMenuName, "&Cancel", "NullHandler", menuIndex)
}

;--------------------------------------------------------------------------------
; Build Icon Library
BuildIconLibrary()
{
	global IconLibrary
	
	IconLibrary := []
	IconLibrary.push("MONITOR_FIT")
	IconLibrary.push("MOVESIZE_COLUMN_CENTRE")
	IconLibrary.push("MOVESIZE_COLUMN_LEFT")
	IconLibrary.push("MOVESIZE_COLUMN_RIGHT")
	IconLibrary.push("MOVESIZE_COMMON_MEDIUM")
	IconLibrary.push("MOVESIZE_COMMON_OPTIMUM")
	IconLibrary.push("MOVESIZE_COMMON_SMALL")
	IconLibrary.push("MOVESIZE_COMMON_SUBOPTIMUM")
	IconLibrary.push("MOVESIZE_COMMON_TINY")
	IconLibrary.push("MOVE_CENTRE")
	IconLibrary.push("MOVE_CORNER_BOTTOMLEFT")
	IconLibrary.push("MOVE_CORNER_BOTTOMRIGHT")
	IconLibrary.push("MOVE_CORNER_TOPLEFT")
	IconLibrary.push("MOVE_CORNER_TOPRIGHT")
	IconLibrary.push("POSITION_TRANSPARENCY0")
	IconLibrary.push("POSITION_TRANSPARENCY25")
	IconLibrary.push("POSITION_TRANSPARENCY50")
	IconLibrary.push("POSITION_TRANSPARENCY75")
	IconLibrary.push("POSITION_ZORDER_SENDTOBACK")
	IconLibrary.push("POSITION_ZORDER_TOPMOSTOFF")
	IconLibrary.push("POSITION_ZORDER_TOPMOSTON")
	IconLibrary.push("POSITION_ZORDER_TOPMOSTTOGGLE")
	IconLibrary.push("SIZE_COMMON_ROLLUP")
	IconLibrary.push("MONITOR_SPAN_ALL")
	IconLibrary.push("MONITOR_SPAN_HEIGHT")
	IconLibrary.push("MONITOR_SPAN_WIDTH")
	IconLibrary.push("POSITION_RESTORE")
	IconLibrary.push("POSITION_SAVE")
	IconLibrary.push("DESKTOPICONS_RESTORE")
	IconLibrary.push("DESKTOPICONS_SAVE")
}

;--------------------------------------------------------------------------------
; GetIconIndex - Find the array index of a named icon
GetIconLibraryIndex(iconName)
{
	global IconLibrary
	
	return IndexOf(IconLibrary, iconName)
}


;--------------------------------------------------------------------------------
; Menu Handlers
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
OptimumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.General_CascadeGutterSize * 1))
return

SubOptimumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.General_CascadeGutterSize * 2))
return

MediumSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.General_CascadeGutterSize * 3))
return

SmallSizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.General_CascadeGutterSize * 4))
return

TinySizeHandler:
SetWindowByGutter(G_ActiveWindow, (G_UserConfig.General_CascadeGutterSize * 5))
return

;--------------------------------------------------------------------------------
MoveColumnLeftHandler:
SetWindowByColumn(G_ActiveWindow, 1, 3, G_UserConfig.General_ColumnGutterSize)
return

MoveColumnCentreHandler:
SetWindowByColumn(G_ActiveWindow, 2, 3, G_UserConfig.General_ColumnGutterSize)
return

MoveColumnRightHandler:
SetWindowByColumn(G_ActiveWindow, 3, 3, G_UserConfig.General_ColumnGutterSize)
return

;--------------------------------------------------------------------------------
SpanCurrentMonitorHandler:
monitor := new Monitor(G_ActiveWindow.MonitorIndex)
monitorWorkArea := monitor.WorkArea
SetWindowSpanMonitors(G_ActiveWindow, monitorWorkArea.Left, monitorWorkArea.Top, monitorWorkArea.Right, monitorWorkArea.Bottom, G_UserConfig.General_SpanMonitorGutterSize)
return

SpanMonitorWidthHandler:
monitor := new Monitor(G_ActiveWindow.MonitorIndex)
monitorWorkArea := monitor.WorkArea
SetWindowSpanMonitors(G_ActiveWindow, "", monitorWorkArea.Top, "", monitorWorkArea.Bottom, G_UserConfig.General_SpanMonitorGutterSize)
return

SpanMonitorHeightHandler:
monitor := new Monitor(G_ActiveWindow.MonitorIndex)
monitorWorkArea := monitor.WorkArea
SetWindowSpanMonitors(G_ActiveWindow, monitorWorkArea.Left, "", monitorWorkArea.Right, "", G_UserConfig.General_SpanMonitorGutterSize)
return

SpanAllMonitorsHandler:
SetWindowSpanMonitors(G_ActiveWindow, "", "", "", "", G_UserConfig.General_SpanMonitorGutterSize)
return

;--------------------------------------------------------------------------------
SaveWindowPositionsHandler:
SaveWindowPositions(G_UserConfig.WindowPositions_IncludeOffScreenWindows, true)
return

RestoreWindowPositionsHandler:
RestoreWindowPositions(GetLatestWindowPositionsDataFileName(GetDesktopSize()), G_UserConfig.WindowPositions_IncludeOffScreenWindows)
return

RestoreMultipleWindowPositionsHandler:
RestoreWindowPositionsFromFile(GetDesktopSize())
return

;--------------------------------------------------------------------------------
CentreHandler:
SetWindowToCentre(G_ActiveWindow)
return

MoveTopLeftHandler:
SetWindowByGrid(G_ActiveWindow, 1, 1, 2, 2, G_UserConfig.General_GridGutterSize)
return

MoveTopRightHandler:
SetWindowByGrid(G_ActiveWindow, 1, 2, 2, 2, G_UserConfig.General_GridGutterSize)
return

MoveBottomLeftHandler:
SetWindowByGrid(G_ActiveWindow, 2, 1, 2, 2, G_UserConfig.General_GridGutterSize)
return

MoveBottomRightHandler:
SetWindowByGrid(G_ActiveWindow, 2, 2, 2, 2, G_UserConfig.General_GridGutterSize)
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
SaveDesktopIcons(true)
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
; ShowMenu - Show the Window Control Menu
ShowMenu(theWindow)
{
	global G_MenuTitle
	global WindowMenuName
	
	BuildWindowMenu()
	
	; Build Window Details
	newMenuTitle := theWindow.Title . " (" . theWindow.ProcessName . ") [" . theWindow.Left . ", " . theWindow.Top . ", " . theWindow.Width . ", " . theWindow.Height . "]"

	; Change Menu MainTitle
	if (newMenuTitle <> G_MenuTitle)
	{
		G_MenuTitle := newMenuTitle
		Menu, %WindowMenuName%, Rename, 1&,  %G_MenuTitle%
	}
	
	processPath := theWindow.ProcessPath

	try Menu, %WindowMenuName%, Icon, 1&, %processPath%, 0
	
	; Enable / Disable as appropriate
	enableTopMostOff := IsWindowTopMost(theWindow.WindowHandle)
	enableTopMostOn := !enableTopMostOff
	
	EnableMenuItem(WindowMenuName, "Set Top&Most On", enableTopMostOn)
	EnableMenuItem(WindowMenuName, "Set Top&Most Off", enableTopMostOff)

	; Show Popup Menu
	Menu, %WindowMenuName%, Show
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
