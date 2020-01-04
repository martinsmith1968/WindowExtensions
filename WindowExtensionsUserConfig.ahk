#Include Lib\UserConfig.ahk

MenuLocationNone := 0
MenuLocationWindowMenu := 1
MenuLocationTrayMenu := 2
MenuLocationAll := MenuLocationWindowMenu | MenuLocationTrayMenu

MenuLocationItems := []

MenuLocationValues := []

;--------------------------------------------------------------------------------
; Initialisation
WindowExtensionsUserConfig_OnInit()
{
	global MenuLocationNone
	global MenuLocationWindowMenu
	global MenuLocationTrayMenu
	global MenuLocationAll
	
	global MenuLocationItems
	global MenuLocationValues

	MenuLocationNone := 0
	MenuLocationWindowMenu := 1
	MenuLocationTrayMenu := 2
	MenuLocationAll := MenuLocationWindowMenu | MenuLocationTrayMenu

	MenuLocationItems := []
	MenuLocationItems.push("None")
	MenuLocationItems.push("Window Menu")
	MenuLocationItems.push("Tray Menu")
	MenuLocationItems.push("Both")

	MenuLocationValues := []
	MenuLocationValues.push(MenuLocationNone)
	MenuLocationValues.push(MenuLocationWindowMenu)
	MenuLocationValues.push(MenuLocationTrayMenu)
	MenuLocationValues.push(MenuLocationAll)
	
	UserConfig_OnInit()
}

;--------------------------------------------------------------------------------
; OnStartup
WindowExtensionsUserConfig_OnStartup()
{
	global G_UserConfig
	
	if (G_UserConfig.RestoreDesktopIconsOnStartup)
	{
		RestoreDesktopIcons()
	}
	if (G_UserConfig.RestoreWindowPositionsOnStartup)
	{
		RestoreWindowPositions(G_UserConfig.WindowPositions_IncludeOffScreenWindows)
	}
}

class WindowExtensionsUserConfig extends UserConfig
{
DefaultCascadeGutterSize := 30
DefaultColumnGutterSize := 5
DefaultGridGutterSize := 5
DefaultSpanMonitorGutterSize := 5
DefaultRestoreDesktopIconsOnStartup := false
DefaultRestoreWindowPositionsOnStartup := false
DefaultWindowPositionsMenuLocation := 2
DefaultDesktopIconsMenuLocation := 2
DefaultWindowPositions_IncludeOffScreenWindows := false

	InitDefaults()
	{
		global MenuLocationTrayMenu
		
		this.DefaultWindowPositionsMenuLocation := MenuLocationTrayMenu
		this.DefaultDesktopIconsMenuLocation := MenuLocationTrayMenu
	}

	__New()
	{
		global AppName
		
		this.InitDefaults()
		
		fileName := GetUserDataFileName(AppName . ".dat")
		
		base.__New(fileName)
		
		this.Properties.push("CascadeGutterSize")
		this.Properties.push("ColumnGutterSize")
		this.Properties.push("GridGutterSize")
		this.Properties.push("SpanMonitorGutterSize")
		this.Properties.push("RestoreDesktopIconsOnStartup")
		this.Properties.push("RestoreWindowPositionsOnStartup")
		this.Properties.push("WindowPositionsMenuLocation")
		this.Properties.push("DesktopIconsMenuLocation")
		this.Properties.push("WindowPositions_IncludeOffScreenWindows")
	}
	
	CascadeGutterSize
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultCascadeGutterSize, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	ColumnGutterSize
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultColumnGutterSize, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	GridGutterSize
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultGridGutterSize, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	SpanMonitorGutterSize
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultSpanMonitorGutterSize, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	RestoreDesktopIconsOnStartup
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultRestoreDesktopIconsOnStartup, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	RestoreWindowPositionsOnStartup
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultRestoreWindowPositionsOnStartup, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	WindowPositionsMenuLocation
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultWindowPositionsMenuLocation, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	DesktopIconsMenuLocation
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultDesktopIconsMenuLocation, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	WindowPositions_IncludeOffScreenWindows
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultWindowPositions_IncludeOffScreenWindows, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
} 
