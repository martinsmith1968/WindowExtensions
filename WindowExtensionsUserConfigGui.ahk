#Include Lib/StringUtils.ahk
#Include Lib/ArrayUtils.ahk
#Include WindowExtensionsUserConfig.ahk

;--------------------------------------------------------------------------------
; Config Gui Values
general_cascadeGutterSize := 0
general_columnGutterSize := 0
general_gridGutterSize := 0
general_spanMonitorGutterSize := 0
startup_restoreWindowPositions := false
startup_restoreDesktopIcons := false
menuControl_windowPositionsMenuLocation := 0
menuControl_desktopIconsMenuLocation := 0
menuControl_desktopIconsMenuLocationChoice := 0
menuControl_windowPositionsMenuLocationChoice := 0
windowPositions_NumberOfFilesToKeep := 20
windowPositions_IncludeOffScreenWindows := false
windowPositions_AutoSave := false
windowPositions_AutoSaveIntervalLabel := ""
windowPositions_AutoSaveIntervalEdit := 5
windowPositions_AutoSaveIntervalMinutes := 5
windowPositions_AutoSaveNotify := false
desktopIcons_NumberOfFilesToKeep := 20

;--------------------------------------------------------------------------------
; LoadConfigGuiValues - Populate gui variables with values from User Config
LoadConfigGuiValues(userConfig)
{
	global general_cascadeGutterSize
	global general_columnGutterSize
	global general_gridGutterSize
	global general_spanMonitorGutterSize
	global startup_restoreWindowPositions
	global startup_restoreDesktopIcons
	global menuControl_windowPositionsMenuLocation
	global menuControl_windowPositionsMenuLocationChoice
	global menuControl_desktopIconsMenuLocation
	global menuControl_desktopIconsMenuLocationChoice
	global windowPositions_IncludeOffScreenWindows
	global windowPositions_AutoSave
	global windowPositions_AutoSaveIntervalLabel
	global windowPositions_AutoSaveIntervalEdit
	global windowPositions_AutoSaveIntervalMinutes
	global windowPositions_AutoSaveNotify
	
	global MenuLocationValues
	global MenuLocationItems

	if (!userConfig)
		return

	general_cascadeGutterSize                     := userConfig.General_CascadeGutterSize
	general_columnGutterSize                      := userConfig.General_ColumnGutterSize
	general_gridGutterSize                        := userConfig.General_GridGutterSize
	general_spanMonitorGutterSize                 := userConfig.General_SpanMonitorGutterSize
	startup_restoreWindowPositions                := userConfig.Startup_RestoreWindowPositions ? 1 : 0
	startup_restoreDesktopIcons                   := userConfig.Startup_RestoreDesktopIcons ? 1 : 0
	menuControl_windowPositionsMenuLocation       := userConfig.MenuControl_WindowPositionsMenuLocation
	menuControl_windowPositionsMenuLocationChoice := IndexOf(MenuLocationValues, menuControl_windowPositionsMenuLocation)
	menuControl_desktopIconsMenuLocation          := userConfig.MenuControl_DesktopIconsMenuLocation
	menuControl_desktopIconsMenuLocationChoice    := IndexOf(MenuLocationValues, menuControl_desktopIconsMenuLocation)
	windowPositions_AutoSave                      := userConfig.WindowPositions_AutoSave
	windowPositions_AutoSaveIntervalMinutes       := userConfig.WindowPositions_AutoSaveIntervalMinutes
	windowPositions_AutoSaveNotify                := userConfig.WindowPositions_AutoSaveNotify
	windowPositions_IncludeOffScreenWindows       := userConfig.WindowPositions_IncludeOffScreenWindows ? 1 : 0
}

;--------------------------------------------------------------------------------
; SaveConfigGuiValues
SaveConfigGuiValues(userConfig)
{
	global general_cascadeGutterSize
	global general_columnGutterSize
	global general_gridGutterSize
	global general_spanMonitorGutterSize
	global startup_restoreWindowPositions
	global startup_restoreDesktopIcons
	global menuControl_windowPositionsMenuLocation
	global menuControl_windowPositionsMenuLocationChoice
	global menuControl_desktopIconsMenuLocation
	global menuControl_desktopIconsMenuLocationChoice
	global windowPositions_IncludeOffScreenWindows
	global windowPositions_AutoSave
	global windowPositions_AutoSaveIntervalLabel
	global windowPositions_AutoSaveIntervalMinutes
	global windowPositions_AutoSaveNotify
	
	global MenuLocationValues

	if (!userConfig)
		return

	userConfig.General_CascadeGutterSize               := general_cascadeGutterSize
	userConfig.General_ColumnGutterSize                := general_columnGutterSize
	userConfig.General_GridGutterSize                  := general_gridGutterSize
	userConfig.General_SpanMonitorGutterSize           := general_spanMonitorGutterSize
	userConfig.Startup_RestoreWindowPositions          := startup_restoreWindowPositions
	userConfig.Startup_RestoreDesktopIcons             := startup_restoreDesktopIcons
	userConfig.MenuControl_WindowPositionsMenuLocation := MenuLocationValues[menuControl_windowPositionsMenuLocation]
	userConfig.MenuControl_DesktopIconsMenuLocation    := MenuLocationValues[menuControl_desktopIconsMenuLocation]
	userConfig.WindowPositions_AutoSave                := windowPositions_AutoSave
	userConfig.WindowPositions_AutoSaveIntervalMinutes := windowPositions_AutoSaveIntervalMinutes
	userConfig.WindowPositions_AutoSaveNotify          := windowPositions_AutoSaveNotify
	userConfig.WindowPositions_IncludeOffScreenWindows := windowPositions_IncludeOffScreenWindows
	
	userConfig.Save()
	
	OnUserConfigUpdated()
}

;--------------------------------------------------------------------------------
; BuildConfigGui - Build the Config Gui
BuildConfigGui()
{
	global AppName
	global MenuLocationItems
	
	global general_cascadeGutterSize
	global general_columnGutterSize
	global general_gridGutterSize
	global general_spanMonitorGutterSize
	global startup_restoreWindowPositions
	global startup_restoreDesktopIcons
	global menuControl_windowPositionsMenuLocation
	global menuControl_windowPositionsMenuLocationChoice
	global menuControl_desktopIconsMenuLocation
	global menuControl_desktopIconsMenuLocationChoice
	global windowPositions_IncludeOffScreenWindows
	global windowPositions_AutoSave
	global windowPositions_AutoSaveIntervalLabel
	global windowPositions_AutoSaveIntervalEdit
	global windowPositions_AutoSaveIntervalMinutes
	global windowPositions_AutoSaveNotify

	menuLocationItemsText := JoinItems("|", MenuLocationItems)

	marginSize := 5
	indentSize := 20
	col1 := 20
	col1Indent := col1 + indentSize
	col2 := 220
	col2Indent := col2 + indentSize
	tabHeight := 40
	rowHeight := 30
	textOffSet := 3
	
	row1 := tabHeight + (rowHeight * 0)
	row2 := tabHeight + (rowHeight * 1)
	row3 := tabHeight + (rowHeight * 2)
	row4 := tabHeight + (rowHeight * 3)
	
	row1t := row1 + textOffset
	row2t := row2 + textOffset
	row3t := row3 + textOffset
	row4t := row4 + textOffset

	; Start Gui
	Gui, Config:New, -SysMenu, %AppName% Configuration
	Gui, Config:Margin, %marginSize%, %marginSize%
	;Gui, Config:Add, Tab3, -Wrap w370 h230, General|Startup|Menu Control|Window Positions|Desktop Icons
	Gui, Config:Add, Tab3, -Wrap w370 h230, General|Startup|Menu Control|Window Positions
	
	; Tab 1 - General
	Gui, Config:Tab, 1
	; Row 1
	Gui, Config:Add, Text, x%col1% y%row1t%, C&ascade Gutter Size:
	Gui, Config:Add, Edit, x%col2% y%row1% w80 x%col2%
	Gui, Config:Add, UpDown, vgeneral_cascadeGutterSize Range0-100, %general_cascadeGutterSize%
	; Row 2
	Gui, Config:Add, Text, x%col1% y%row2t%, C&olumn Gutter Size:
	Gui, Config:Add, Edit, w80 x%col2% y%row2%
	Gui, Config:Add, UpDown, vgeneral_columnGutterSize Range0-100, %general_columnGutterSize%
	; Row 3
	Gui, Config:Add, Text, x%col1% y%row3t%, &Grid Gutter Size:
	Gui, Config:Add, Edit, w80 x%col2% y%row3%
	Gui, Config:Add, UpDown, vgeneral_gridGutterSize Range0-100, %general_gridGutterSize%
	; Row 4
	Gui, Config:Add, Text, x%col1% y%row4t%, Span &Monitor Gutter Size:
	Gui, Config:Add, Edit, w80 x%col2% y%row4%
	Gui, Config:Add, UpDown, vgeneral_spanMonitorGutterSize Range0-100, %general_spanMonitorGutterSize%
	
	; Tab 2 - Startup
	Gui, Config:Tab, 2
	; Row 1
	Gui, Config:Add, Checkbox, x%col1% y%row1t% vstartup_restoreWindowPositions Checked%startup_restoreWindowPositions%, Restore Window &Positions on Startup
	; Row 2
	Gui, Config:Add, Checkbox, x%col1% y%row2t% vstartup_restoreDesktopIcons Checked%startup_restoreDesktopIcons%, Restore Desktop &Icons on Startup

	; Tab 3 - Menu Control
	Gui, Config:Tab, 3
	; Row 1
	Gui, Config:Add, Text, x%col1% y%row1t%, Window &Positions Menu Location:
	Gui, Config:Add, DropDownList, x%col2% y%row1% vmenuControl_windowPositionsMenuLocation AltSubmit Choose%menuControl_windowPositionsMenuLocationChoice%, %menuLocationItemsText%
	; Row 2
	Gui, Config:Add, Text, x%col1% y%row2t%, Desktop &Icons Menu Location:
	Gui, Config:Add, DropDownList, x%col2% y%row2% vmenuControl_desktopIconsMenuLocation AltSubmit Choose%menuControl_desktopIconsMenuLocationChoice%, %menuLocationItemsText%

	; Tab 4 - Window Positions
	Gui, Config:Tab, 4
	; Row 1
	Gui, Config:Add, Checkbox, x%col1% y%row1t% vwindowPositions_AutoSave gwindowPositions_AutoSave_Checked Checked%windowPositions_AutoSave%, Auto-Save Window Positions ?
	Gui, Config:Add, Text, x%col1Indent% y%row2t% vwindowPositions_AutoSaveIntervalLabel, Auto-Save interval (minutes)
	Gui, Config:Add, Edit, w80 x%col2% y%row2% vwindowPositions_AutoSaveIntervalEdit
	Gui, Config:Add, UpDown, vwindowPositions_AutoSaveIntervalMinutes Range1-360, %windowPositions_AutoSaveIntervalMinutes%
	Gui, Config:Add, Checkbox, x%col1Indent% y%row3% vwindowPositions_AutoSaveNotify Checked%windowPositions_AutoSaveNotify%, Notify when Auto-Saving ?
	; Row 2
	Gui, Config:Add, Checkbox, x%col1% y%row4t% vwindowPositions_IncludeOffScreenWindows Checked%windowPositions_IncludeOffScreenWindows%, Include Off-Screen Windows

	; Tab 5 - Desktop Icons
	;Gui, Config:Tab, 5
	; Row 1
	;Gui, Config:Add, Text, x%col1% y%row1t%, Number of saved files to &keep :
	;Gui, Config:Add, Edit, w80 x%col2% y%row1%
	;Gui, Config:Add, UpDown, vdesktopIcons_NumberOfFilesToKeep Range0-100, %desktopIcons_NumberOfFilesToKeep%

	; Button Bar
	Gui, Config:Tab
	Gui, Config:Add, Button, default x205 y240 w80, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
	Gui, Config:Add, Button, x295 y240 w80, Cancel ; The label ButtonCancel (if it exists) will be run when the button is pressed.
	
	;--------------------------------------------------------------------------------
	; Fire Events to ensure control consistency
	windowPositions_AutoSave_Checked()
}

;--------------------------------------------------------------------------------
; windowPositions_AutoSave_Checked - When Auto-Save is checked
windowPositions_AutoSave_Checked()
{
	GuiControlGet, windowPositions_AutoSave
	enabled := windowPositions_AutoSave ? 1 : 0
	
	GuiControl, Enable%enabled%, windowPositions_AutoSaveIntervalLabel
	GuiControl, Enable%enabled%, windowPositions_AutoSaveIntervalEdit
	GuiControl, Enable%enabled%, windowPositions_AutoSaveIntervalMinutes
	GuiControl, Enable%enabled%, windowPositions_AutoSaveNotify
}

;--------------------------------------------------------------------------------
; DestroyConfigGui - Destroy the Config Gui
DestroyConfigGui()
{
	Gui, Config:Destroy
}

;--------------------------------------------------------------------------------
; ShowUserConfigGui - Build, Populate and Show the Config Gui
ShowConfigGui()
{
	global G_UserConfig
	
	LoadConfigGuiValues(G_UserConfig)
	
	BuildConfigGui()
	
	Gui, Config:Show
}

ConfigGuiEscape:
{
	DestroyConfigGui()
	return
}

ConfigGuiClose:
{
	DestroyConfigGui()
	return
}

ConfigButtonCancel:
{
	DestroyConfigGui()
	return
}

ConfigButtonOK:
{
	global G_UserConfig

	Gui, Config:Submit
	
	SaveConfigGuiValues(G_UserConfig)
		
	DestroyConfigGui()
	return
}	
