#Include Lib\Logging.ahk
#Include Lib\UserConfig.ahk

MenuLocationNone := 0
MenuLocationWindowMenu := 1
MenuLocationTrayMenu := 2
MenuLocationAll := MenuLocationWindowMenu | MenuLocationTrayMenu

MenuLocationItems := []

MenuLocationValues := []

WindowPositions_TimerEnabled := false
WindowPositions_TimerIntervalMinutes := 0
DesktopIcons_TimerEnabled := false
DesktopIcons_TimerIntervalMinutes := 0

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

	global WindowPositions_TimerEnabled
	global WindowPositions_TimerIntervalMinutes
	global DesktopIcons_TimerEnabled
	global DesktopIcons_TimerIntervalMinutes

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
	
	WindowPositions_TimerEnabled := false
	WindowPositions_TimerIntervalMinutes := 0
	DesktopIcons_TimerEnabled := false
	DesktopIcons_TimerIntervalMinutes := 0
	
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
	
	WindowExtensionsUserConfig_OnConfigUpdated()
}

;--------------------------------------------------------------------------------
; OnConfigUpdated
WindowExtensionsUserConfig_OnConfigUpdated()
{
	global G_UserConfig
	
	WindowPositionsConfigureTimer(G_UserConfig.WindowPositions_AutoSave, G_UserConfig.WindowPositions_AutoSaveIntervalMinutes)
	DesktopIconsConfigureTimer(G_UserConfig.DesktopIcons_AutoSave, G_UserConfig.DesktopIcons_AutoSaveIntervalMinutes)
}

;--------------------------------------------------------------------------------
; WindowPositionsConfigureTimer - Configure the timer
WindowPositionsConfigureTimer(enabled, intervalMinutes)
{
	global WindowPositions_TimerEnabled
	global WindowPositions_TimerIntervalMinutes
	
	if (enabled = WindowPositions_TimerEnabled && intervalMinutes = WindowPositions_TimerIntervalMinutes)
	{
		return
	}
	
	LogText("Deleting WindowPositionsAutoSave_OnTimer")
	Try SetTimer, WindowPositionsAutoSave_OnTimer, Delete
	
	if (enabled)
	{
		milliseconds := (intervalMinutes * 60) * 1000
		
		LogText("Setting WindowPositionsAutoSave_OnTimer for : " . milliseconds)
		SetTimer, WindowPositionsAutoSave_OnTimer, %milliseconds%
	}
}

;--------------------------------------------------------------------------------
; DesktopIconsConfigureTimer - Configure the timer
DesktopIconsConfigureTimer(enabled, intervalMinutes)
{
	global DesktopIcons_TimerEnabled
	global DesktopIcons_TimerIntervalMinutes
	
	if (enabled = DesktopIcons_TimerEnabled && intervalMinutes = DesktopIcons_TimerIntervalMinutes)
	{
		return
	}
	
	LogText("Deleting DesktopIconsAutoSave_OnTimer")
	Try SetTimer, DesktopIconsAutoSave_OnTimer, Delete
	
	if (enabled)
	{
		milliseconds := (intervalMinutes * 60) * 1000
		
		LogText("Setting DesktopIconsAutoSave_OnTimer for : " . milliseconds)
		SetTimer, DesktopIconsAutoSave_OnTimer, %milliseconds%
	}
}

;--------------------------------------------------------------------------------
; WindowPositionsAutoSave_OnTimer - Timer execute
WindowPositionsAutoSave_OnTimer()
{
	global G_UserConfig
	
	LogText("Executing: " . A_ThisFunc)
	
	SaveWindowPositions(G_UserConfig.WindowPositions_IncludeOffScreenWindows, G_UserConfig.WindowPositions_AutoSaveNotify)
}

;--------------------------------------------------------------------------------
; DesktopIconsAutoSave_OnTimer - Timer execute
DesktopIconsAutoSave_OnTimer()
{
	global G_UserConfig
	
	LogText("Executing: " . A_ThisFunc)
	
	SaveDesktopIcons(G_UserConfig.DesktopIcons_AutoSaveNotify)
}

;--------------------------------------------------------------------------------
; WindowExtensionsUserConfig class
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
Default_WindowPositions_AutoSave := false
Default_WindowPositions_AutoSaveIntervalMinutes := 5
Default_WindowPositions_AutoSaveNotify := false
Default_DesktopIcons_AutoSave := false
Default_DesktopIcons_AutoSaveIntervalMinutes := 5
Default_DesktopIcons_AutoSaveNotify := false

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
		this.Properties.push("WindowPositions_AutoSave")
		this.Properties.push("WindowPositions_AutoSaveIntervalMinutes")
		this.Properties.push("WindowPositions_AutoSaveNotify")
		this.Properties.push("DesktopIcons_AutoSave")
		this.Properties.push("DesktopIcons_AutoSaveIntervalMinutes")
		this.Properties.push("DesktopIcons_AutoSaveNotify")
		
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
	
	WindowPositions_AutoSave
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_WindowPositions_AutoSave, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	WindowPositions_AutoSaveIntervalMinutes
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_WindowPositions_AutoSaveIntervalMinutes, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	WindowPositions_AutoSaveNotify
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_WindowPositions_AutoSaveNotify, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	DesktopIcons_AutoSave
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_DesktopIcons_AutoSave, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	DesktopIcons_AutoSaveIntervalMinutes
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_DesktopIcons_AutoSaveIntervalMinutes, "integer")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	DesktopIcons_AutoSaveNotify
	{
		get
		{
			return base.GetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), this.Default_DesktopIcons_AutoSaveNotify, "boolean")
		}
		set
		{
			base.SetValue(base.GetSectionNameFromFunc(A_ThisFunc), base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
}
