#Include Lib\Logging.ahk

;--------------------------------------------------------------------------------
; ResetMenu - Remove all items from a Menu
ResetMenu(menuName)
{
	try Menu, %menuName%, DeleteAll
}

;--------------------------------------------------------------------------------
; AddMenuItem - Add a Menu Item to a Menu
AddMenuItem(menuName, text, handler, menuIndex := 0)
{
	If (text = "")
	{
		LogText("Adding Menu Separator: " . menuName)
		Menu, %menuName%, Add
	}
	else
	{
		LogText("Adding Menu: " . menuName . " - " . text . " = " . handler)
		Menu, %menuName%, Add, %text%, %handler%
	}
	
	return menuIndex + 1
}

;--------------------------------------------------------------------------------
; AddMenuItem - Add a Menu Item to a Menu, and set its Icon
AddMenuItemWithIcon(menuName, text, handler, iconFileName, iconIndex, menuIndex := 0)
{
	menuIndex := AddMenuItem(menuName, text, handler, menuIndex)
	
	if (iconIndex > 0)
	{
		try Menu, %menuName%, Icon, %text%,  %iconFileName%, %iconIndex%
	}
	
	return menuIndex + 1
}

;--------------------------------------------------------------------------------
; AddMenuItemSeparator - Add a Menu Item separator to a Menu
AddMenuItemSeparator(menuName, menuIndex)
{
	AddMenuItem(menuName, "", "", menuIndex)
}

;--------------------------------------------------------------------------------
; EnableMenuItem - Enable / Disable a menu item
EnableMenuItem(menuName, menuTitle, enabled)
{
	state := enabled ? "Enable" : "Disable"
	LogText("Enabling: " . menuName . " - " . menuTitle . ", with " . enabled . " = " . state)
	
	Menu, %menuName%, %state%, %menuTitle%
}
