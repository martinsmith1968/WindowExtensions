#Include Lib\Logging.ahk
#Include Lib\MenuFunctions.ahk

;--------------------------------------------------------------------------------
; Globals
TrayMenuName :=

;--------------------------------------------------------------------------------
; Initialisation
TrayMenu_OnInit()
{
	global TrayMenuName
	
	TrayMenuName := "Tray"
}

;--------------------------------------------------------------------------------
; OnStartup
TrayMenu_OnStartup()
{
	BuildTrayMenu()
}

;--------------------------------------------------------------------------------
; Setup Tray Menu
BuildTrayMenu()
{
	global AppTitle
	global G_UserConfig
	global MenuLocationTrayMenu
	global TrayMenuName
	global IconLibraryFileName
	
	desktopSize := GetDesktopSize()
	
	menuIndex := 0
	
	ResetMenu(TrayMenuName)
	
	Menu, %TrayMenuName%, NoStandard
	Menu, %TrayMenuName%, Tip, %AppTitle%

	menuIndex := AddMenuItemWithIcon(TrayMenuName, "Con&figure...", "TrayConfigureHandler", A_ScriptFullPath, 0, menuIndex)
	
	; Window Positions
	if (ContainsFlag(G_UserConfig.MenuControl_WindowPositionsMenuLocation, MenuLocationTrayMenu))
	{
		menuIndex := AddMenuItemSeparator(TrayMenuName, menuIndex)

		saveTitle := "Save Window &Positions (" . desktopSize.DimensionsText . ")"
		menuIndex := AddMenuItemWithIcon(TrayMenuName, saveTitle, "SaveWindowPositionsHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_SAVE"), menuIndex)

		restoreTitle := "Restore Last Window &Positions (" . desktopSize.DimensionsText . ")"
		menuIndex := AddMenuItemWithIcon(TrayMenuName, restoreTitle, "RestoreWindowPositionsHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_RESTORE"), menuIndex)

		restoreEnabled := HasSavedWindowPositionFile(desktopSize)
		EnableMenuItem(TrayMenuName, restoreTitle, restoreEnabled)

		if (HasMultipleSavedWindowPositionFiles(desktopSize))
		{
			restoreTitle := "Restore Window &Positions (" . desktopSize.DimensionsText . ")..."
			
			menuIndex := AddMenuItemWithIcon(TrayMenuName, restoreTitle, "RestoreMultipleWindowPositionsHandler", IconLibraryFileName, GetIconLibraryIndex("POSITION_RESTORE"), menuIndex)
		}
	}

	; Desktop Icons
	if (ContainsFlag(G_UserConfig.MenuControl_DesktopIconsMenuLocation, MenuLocationTrayMenu))
	{
		menuIndex := AddMenuItemSeparator(TrayMenuName, menuIndex)

		saveTitle := "Save &Desktop Icons (" . desktopSize.DimensionsText . ")"
		menuIndex := AddMenuItemWithIcon(TrayMenuName, saveTitle, "SaveDesktopIconsHandler", IconLibraryFileName, GetIconLibraryIndex("DESKTOPICONS_SAVE"), menuIndex)

		restoreTitle := "Restore &Desktop Icons (" . desktopSize.DimensionsText . ")"
		menuIndex := AddMenuItemWithIcon(TrayMenuName, restoreTitle, "RestoreDesktopIconsHandler", IconLibraryFileName, GetIconLibraryIndex("DESKTOPICONS_RESTORE"), menuIndex)

		restoreEnabled := HasSavedDesktopIconsFile(desktopSize)
		EnableMenuItem(TrayMenuName, restoreTitle, restoreEnabled)
	}

	menuIndex := AddMenuItemSeparator(TrayMenuName, menuIndex)
	menuIndex := AddMenuItem(TrayMenuName, "&About...", "TrayAboutHandler", menuIndex)
	
	menuIndex := AddMenuItemSeparator(TrayMenuName, menuIndex)
	menuIndex := AddMenuItem(TrayMenuName, "Exit", "TrayExitHandler", menuIndex)
}

;--------------------------------------------------------------------------------
TrayConfigureHandler:
ShowConfigGui()
return

;--------------------------------------------------------------------------------
TrayAboutHandler:
ShowAboutGui()
return

;--------------------------------------------------------------------------------
TrayExitHandler:
ExitApp
return
