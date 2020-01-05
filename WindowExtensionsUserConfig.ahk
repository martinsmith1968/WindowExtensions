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
	
	if (G_UserConfig.Startup_RestoreDesktopIcons)
	{
        RestoreDesktopIcons()
	}
	if (G_UserConfig.Startup_RestoreWindowPositions)
	{
        RestoreWindowPositions(G_UserConfig.WindowPositions_IncludeOffScreenWindows)
	}
}

class WindowExtensionsUserConfig extends UserConfig
{
Default_About_Version := ""
Default_General_CascadeGutterSize := 30
Default_General_ColumnGutterSize := 5
Default_General_GridGutterSize := 5
Default_General_SpanMonitorGutterSize := 5
Default_Startup_RestoreDesktopIcons := false
Default_Startup_RestoreWindowPositions := false
Default_MenuControl_WindowPositionsMenuLocation := 0
Default_MenuControl_DesktopIconsMenuLocation := 0
Default_WindowPositions_IncludeOffScreenWindows := false

	InitDefaults()
	{
		global AppVersion
		global MenuLocationTrayMenu
		
		this.Default_About_Version := AppVersion
		this.Default_MenuControl_WindowPositionsMenuLocation := MenuLocationTrayMenu
		this.Default_MenuControl_DesktopIconsMenuLocation := MenuLocationTrayMenu
	}

	__New()
	{
		global AppName
		
		this.InitDefaults()
		
		fileName := GetUserDataFileName(AppName . ".dat")
		
		base.__New(fileName)
		
		this.Properties.push("About_Version")
		this.Properties.push("General_CascadeGutterSize")
		this.Properties.push("General_ColumnGutterSize")
		this.Properties.push("General_GridGutterSize")
		this.Properties.push("General_SpanMonitorGutterSize")
		this.Properties.push("Startup_RestoreDesktopIcons")
		this.Properties.push("Startup_RestoreWindowPositions")
		this.Properties.push("MenuControl_WindowPositionsMenuLocation")
		this.Properties.push("MenuControl_DesktopIconsMenuLocation")
		this.Properties.push("WindowPositions_IncludeOffScreenWindows")
		
		this.ObsoleteProperties.push("General_RestoreDesktopIconsOnStartup")
		this.ObsoleteProperties.push("General_RestoreWindowPositionsOnStartup")
		this.ObsoleteProperties.push("General_DesktopIconsMenuLocation")
		this.ObsoleteProperties.push("General_WindowPositionsMenuLocation")
	}
	
	About_Version
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_General_CascadeGutterSize, "string")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_About_Version)
		}
	}
	
	General_CascadeGutterSize
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_General_CascadeGutterSize, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	General_ColumnGutterSize
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_General_ColumnGutterSize, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	General_GridGutterSize
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_General_GridGutterSize, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	General_SpanMonitorGutterSize
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_General_SpanMonitorGutterSize, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	Startup_RestoreDesktopIcons
	{
		get
		{
			oldValue1 := base.GetValue("General", "RestoreDesktopIconsOnStartup", this.Default_Startup_RestoreDesktopIcons, "boolean")
			
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), oldValue1, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	Startup_RestoreWindowPositions
	{
		get
		{
			oldValue1 := base.GetValue("General", "RestoreWindowPositionsOnStartup", this.Default_Startup_RestoreWindowPositions, "boolean")
			
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), oldValue1, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	MenuControl_WindowPositionsMenuLocation
	{
		get
		{
			oldValue1 := base.GetValue("General", "WindowPositionsMenuLocation", this.Default_MenuControl_WindowPositionsMenuLocation, "integer")
			
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), oldValue1, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	MenuControl_DesktopIconsMenuLocation
	{
		get
		{
			oldValue1 := base.GetValue("General", "DesktopIconsMenuLocation", this.Default_MenuControl_WindowPositionsMenuLocation, "integer")
			
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), oldValue1, "integer")
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
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_WindowPositions_IncludeOffScreenWindows, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
} 
