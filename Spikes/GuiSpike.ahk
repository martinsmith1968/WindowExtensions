cascadeGutterSize := 25
columnGutterSize := 10
gridGutterSize := 15
spanMonitorGutterSize := 20
restoreDesktopIconsOnStartup := true
restoreWindowPositionsOnStartup := true
windowPositionsIncludeOffScreenWindows := false
windowPositionsFilesToKeep := 19
desktopIconsFilesToKeep := 21

shit := "This.iscrap"

crap := Instr(shit, ".") ? StrSplit(shit, ".")[2] : shit

MsgBox,,, %crap%


ShowConfigGui()

return

BuildGui()
{
	global cascadeGutterSize
	global columnGutterSize
	global gridGutterSize
	global spanMonitorGutterSize
	global restoreDesktopIconsOnStartup
	global restoreWindowPositionsOnStartup
	global MenuLocationValues
	global windowPositionsIncludeOffScreenWindows
	global windowPositionsFilesToKeep
	global desktopIconsFilesToKeep
	
	menuLocationItemsText := "None|Window Menu|Tray Menu|Both"

	col1 := 20
	col2 := 220
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

	Gui, Config:New, -SysMenu, Configuration
	Gui, Config:Margin, 5, 5
	Gui, Config:Add, Tab3, -Wrap w370 h230, General|Startup|Menu Control|Window Positions|Desktop Icons
	
	; Tab 1 - General
	Gui, Config:Tab, 1
	; Row 1
	Gui, Config:Add, Text, x%col1% y%row1t%, C&ascade Gutter Size:
	Gui, Config:Add, Edit, x%col2% y%row1% w80 x%col2%
	Gui, Config:Add, UpDown, vcascadeGutterSize Range0-100, %cascadeGutterSize%
	; Row 2
	Gui, Config:Add, Text, x%col1% y%row2t%, C&olumn Gutter Size:
	Gui, Config:Add, Edit, w80 x%col2% y%row2%
	Gui, Config:Add, UpDown, vcolumnGutterSize Range0-100, %columnGutterSize%
	; Row 3
	Gui, Config:Add, Text, x%col1% y%row3t%, &Grid Gutter Size:
	Gui, Config:Add, Edit, w80 x%col2% y%row3%
	Gui, Config:Add, UpDown, vgridGutterSize Range0-100, %gridGutterSize%
	; Row 4
	Gui, Config:Add, Text, x%col1% y%row4t%, Span &Monitor Gutter Size:
	Gui, Config:Add, Edit, w80 x%col2% y%row4%
	Gui, Config:Add, UpDown, vspanMonitorGutterSize Range0-100, %spanMonitorGutterSize%
	
	; Tab 2 - Startup
	Gui, Config:Tab, 2
	; Row 1
	Gui, Config:Add, Checkbox, x%col1% y%row1t% vrestoreWindowPositionsOnStartup Checked%restoreWindowPositionsOnStartup%, Restore Window &Positions on Startup
	; Row 2
	Gui, Config:Add, Checkbox, x%col1% y%row2t% vrestoreDesktopIconsOnStartup Checked%restoreDesktopIconsOnStartup%, Restore Desktop &Icons on Startup

	; Tab 3 - Menu Control
	Gui, Config:Tab, 3
	; Row 1
	Gui, Config:Add, Text, x%col1% y%row1t%, Window &Positions Menu Location:
	Gui, Config:Add, DropDownList, x%col2% y%row1% vwindowPositionsMenuLocation AltSubmit Choose%windowPositionsMenuLocationChoice%, %menuLocationItemsText%
	; Row 2
	Gui, Config:Add, Text, x%col1% y%row2t%, Desktop &Icons Menu Location:
	Gui, Config:Add, DropDownList, x%col2% y%row2% vdesktopIconsMenuLocation AltSubmit Choose%desktopIconsMenuLocationChoice%, %menuLocationItemsText%

	; Tab 4 - Window Positions
	Gui, Config:Tab, 4
	; Row 1
	Gui, Config:Add, Text, x%col1% y%row1t%, Number of saved files to &keep :
	Gui, Config:Add, Edit, w80 x%col2% y%row1%
	Gui, Config:Add, UpDown, vwindowPositionsFilesToKeep Range0-100, %windowPositionsFilesToKeep%
	; Row 2
	Gui, Config:Add, Checkbox, x%col1% y%row2t% vwindowPositionsIncludeOffScreenWindows Checked%windowPositionsIncludeOffScreenWindows%, Include Off-Screen Windows

	; Tab 5 - Desktop Icons
	Gui, Config:Tab, 5
	; Row 1
	Gui, Config:Add, Text, x%col1% y%row1t%, Number of saved files to &keep :
	Gui, Config:Add, Edit, w80 x%col2% y%row1%
	Gui, Config:Add, UpDown, vdesktopIconsFilesToKeep Range0-100, %desktopIconsFilesToKeep%

	; Button Bar
	Gui, Config:Tab
	Gui, Config:Add, Button, default x205 y240 w80, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
	Gui, Config:Add, Button, x295 y240 w80, Cancel ; The label ButtonCancel (if it exists) will be run when the button is pressed.
}

DestroyUserConfigGui()
{
	Gui, Config:Destroy
}

ShowConfigGui()
{
	global G_UserConfig
	
	BuildGui()
	
	Gui, Config:Show
}

ConfigGuiEscape:
{
	DestroyUserConfigGui()
	ExitApp
}

ConfigGuiClose:
{
	DestroyUserConfigGui()
	ExitApp
}

ConfigButtonCancel:
{
	DestroyUserConfigGui()
	ExitApp
}

ConfigButtonOK:
{
	global cascadeGutterSize
	global columnGutterSize
	global gridGutterSize
	global spanMonitorGutterSize
	global restoreDesktopIconsOnStartup
	global restoreWindowPositionsOnStartup
	global MenuLocationValues
	global windowPositionsIncludeOffScreenWindows

	Gui, Config:Submit
	
	G_UserConfig.CascadeGutterSize := cascadeGutterSize
	G_UserConfig.ColumnGutterSize := columnGutterSize
	G_UserConfig.GridGutterSize := gridGutterSize
	G_UserConfig.SpanMonitorGutterSize := spanMonitorGutterSize
	G_UserConfig.RestoreDesktopIconsOnStartup := restoreDesktopIconsOnStartup
	G_UserConfig.RestoreWindowPositionsOnStartup := restoreWindowPositionsOnStartup
	G_UserConfig.DesktopIconsMenuLocation := MenuLocationValues[desktopIconsMenuLocation]
	G_UserConfig.WindowPositionsMenuLocation := MenuLocationValues[windowPositionsMenuLocation]
	G_UserConfig.WindowPositions_IncludeOffScreenWindows := windowPositionsIncludeOffScreenWindows
	G_UserConfig.Save()
	
	DestroyUserConfigGui()
	
	ExitApp
}	
