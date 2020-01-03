#Include Lib/StringUtils.ahk
#Include Lib/ArrayUtils.ahk
#Include WindowExtensionsUserConfig.ahk

cascadeGutterSize := 0
columnGutterSize := 0
gridGutterSize := 0
spanMonitorGutterSize := 0

BuildUserConfigGui(windowExtensionsUserConfig)
{
	global cascadeGutterSize
	global columnGutterSize
	global gridGutterSize
	global spanMonitorGutterSize
	global restoreDesktopIconsOnStartup
	global restoreWindowPositionsOnStartup
	global desktopIconsMenuLocation
	global windowPositionsMenuLocation
	
	global MenuLocationValues
	global MenuLocationItems

	cascadeGutterSize := windowExtensionsUserConfig.CascadeGutterSize
	columnGutterSize := windowExtensionsUserConfig.ColumnGutterSize
	gridGutterSize := windowExtensionsUserConfig.GridGutterSize
	spanMonitorGutterSize := windowExtensionsUserConfig.SpanMonitorGutterSize
	restoreDesktopIconsOnStartup := windowExtensionsUserConfig.RestoreDesktopIconsOnStartup ? 1 : 0
	restoreWindowPositionsOnStartup := windowExtensionsUserConfig.RestoreWindowPositionsOnStartup ? 1 : 0
	desktopIconsMenuLocation := windowExtensionsUserConfig.DesktopIconsMenuLocation
	windowPositionsMenuLocation := windowExtensionsUserConfig.WindowPositionsMenuLocation
	
	desktopIconsMenuLocationChoice := IndexOf(MenuLocationValues, desktopIconsMenuLocation)
	windowPositionsMenuLocationChoice := IndexOf(MenuLocationValues, windowPositionsMenuLocation)

	menuLocationItemsText := JoinItems("|", MenuLocationItems)

	Gui, Config:New, -SysMenu
	Gui, Config:Add, Text,, Cascade Gutter Size:
	Gui, Config:Add, Text,, Column Gutter Size:
	Gui, Config:Add, Text,, Grid Gutter Size:
	Gui, Config:Add, Text,, Span Monitor Gutter Size:
	Gui, Config:Add, Text,, Restore Desktop Icons on Startup:
	Gui, Config:Add, Text,, Restore Window Positions on Startup:
	Gui, Config:Add, Text,, Save / Restore Window Positions Menu Location:
	Gui, Config:Add, Text,, Save / Restore Desktop Icons Menu Location:
	Gui, Config:Add, Edit, ym w80
	Gui, Config:Add, UpDown, vcascadeGutterSize Range0-100, %cascadeGutterSize%
	Gui, Config:Add, Edit, w80
	Gui, Config:Add, UpDown, vcolumnGutterSize Range0-100, %columnGutterSize%
	Gui, Config:Add, Edit, w80
	Gui, Config:Add, UpDown, vgridGutterSize Range0-100, %gridGutterSize%
	Gui, Config:Add, Edit, w80
	Gui, Config:Add, UpDown, vspanMonitorGutterSize Range0-100, %spanMonitorGutterSize%
	Gui, Config:Add, Checkbox, vrestoreDesktopIconsOnStartup Checked%restoreDesktopIconsOnStartup%,
	Gui, Config:Add, Checkbox, vrestoreWindowPositionsOnStartup Checked%restoreWindowPositionsOnStartup%, `n
	Gui, Config:Add, DropDownList, vwindowPositionsMenuLocation AltSubmit Choose%windowPositionsMenuLocationChoice%, %menuLocationItemsText%
	Gui, Config:Add, DropDownList, vdesktopIconsMenuLocation AltSubmit Choose%desktopIconsMenuLocationChoice%, %menuLocationItemsText%
	Gui, Config:Add, Button, default x240 y230 w80, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
	Gui, Config:Add, Button, x330 y230 w80, Cancel ; The label ButtonCancel (if it exists) will be run when the button is pressed.
}

DestroyUserConfigGui()
{
	Gui, Config:Destroy
}

ShowUserConfigGui()
{
	global G_UserConfig
	
	BuildUserConfigGui(G_UserConfig)
	
	Gui, Config:Show,,%AppName% Configuration
}

ConfigGuiEscape:
{
	DestroyUserConfigGui()
	return
}

ConfigGuiClose:
{
	DestroyUserConfigGui()
	return
}

ConfigButtonCancel:
{
	DestroyUserConfigGui()
	return
}

ConfigButtonOK:
{
	global cascadeGutterSize
	global columnGutterSize
	global gridGutterSize
	global spanMonitorGutterSize
	
	global MenuLocationValues

	Gui, Config:Submit
	
	G_UserConfig.CascadeGutterSize := cascadeGutterSize
	G_UserConfig.ColumnGutterSize := columnGutterSize
	G_UserConfig.GridGutterSize := gridGutterSize
	G_UserConfig.SpanMonitorGutterSize := spanMonitorGutterSize
	G_UserConfig.RestoreDesktopIconsOnStartup := restoreDesktopIconsOnStartup
	G_UserConfig.RestoreWindowPositionsOnStartup := restoreWindowPositionsOnStartup
	G_UserConfig.DesktopIconsMenuLocation := MenuLocationValues[desktopIconsMenuLocation]
	G_UserConfig.WindowPositionsMenuLocation := MenuLocationValues[windowPositionsMenuLocation]
	G_UserConfig.Save()
	
	OnUserConfigUpdated()
	
	DestroyUserConfigGui()
	return
}	
