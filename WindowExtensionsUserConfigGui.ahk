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

	cascadeGutterSize := windowExtensionsUserConfig.CascadeGutterSize
	columnGutterSize := windowExtensionsUserConfig.ColumnGutterSize
	gridGutterSize := windowExtensionsUserConfig.GridGutterSize
	spanMonitorGutterSize := windowExtensionsUserConfig.SpanMonitorGutterSize
	restoreDesktopIconsOnStartup := windowExtensionsUserConfig.RestoreDesktopIconsOnStartup ? 1 : 0
	restoreWindowPositionsOnStartup := windowExtensionsUserConfig.RestoreWindowPositionsOnStartup ? 1 : 0

	Gui, Config:New, -SysMenu
	Gui, Config:Add, Text,, Cascade Gutter Size:
	Gui, Config:Add, Text,, Column Gutter Size:
	Gui, Config:Add, Text,, Grid Gutter Size:
	Gui, Config:Add, Text,, Span Monitor Gutter Size:
	Gui, Config:Add, Text,, Restore Desktop Icons on Startup:
	Gui, Config:Add, Text,, Restore Window Positions on Startup:
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
	Gui, Config:Add, Button, default x50 y180 w80, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
	Gui, Config:Add, Button, x140 y180 w80, Cancel ; The label ButtonCancel (if it exists) will be run when the button is pressed.
}

DestroyConfigGui()
{
	Gui, Config:Destroy
}

ShowUserConfig()
{
	global G_UserConfig
	
	BuildUserConfigGui(G_UserConfig)
	
	Gui, Config:Show,,%AppName% Configuration
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
	global cascadeGutterSize
	global columnGutterSize
	global gridGutterSize
	global spanMonitorGutterSize

	Gui, Config:Submit
	
	G_UserConfig.CascadeGutterSize := cascadeGutterSize
	G_UserConfig.ColumnGutterSize := columnGutterSize
	G_UserConfig.GridGutterSize := gridGutterSize
	G_UserConfig.SpanMonitorGutterSize := spanMonitorGutterSize
	G_UserConfig.RestoreDesktopIconsOnStartup := restoreDesktopIconsOnStartup
	G_UserConfig.RestoreWindowPositionsOnStartup := restoreWindowPositionsOnStartup
	G_UserConfig.Save()
	
	DestroyConfigGui()
	return
}	

