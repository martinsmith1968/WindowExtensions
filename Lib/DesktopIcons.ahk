#Include Lib\Logging.ahk
#Include Lib\StringUtils.ahk
#Include Lib\PathUtils.ahk
#Include Lib\WindowObjects.ahk
#Include Lib\MathUtils.ahk
#Include Lib\UserDataUtils.ahk

; Inspired by : https://autohotkey.com/board/topic/60982-deskicons-getset-desktop-icon-positions/

;--------------------------------------------------------------------------------
; Constants
global MEM_COMMIT := 0x1000, MEM_RESERVE := 0x2000, MEM_RELEASE := 0x8000
global PAGE_READWRITE := 0x04
global LVM_GETITEMCOUNT := 0x00001004, LVM_GETITEMPOSITION := 0x00001010, LVM_SETITEMPOSITION := 0x0000100F, WM_SETREDRAW := 0x000B

;--------------------------------------------------------------------------------
; Configuration
DesktopIconsBaseFileName := "DesktopIcons"

;--------------------------------------------------------------------------------
HasSavedDesktopIconsFile(desktopSize)
{
    fileName := GetDesktopIconsDataFileName(desktopSize)
    
    return FileExist(fileName)
}

;--------------------------------------------------------------------------------
GetDesktopIconsDataFileName(desktopSize)
{
    global DesktopIconsBaseFileName
    
    dimensions := desktopSize.DimensionsText

    fileName := DesktopIconsBaseFileName
    if (dimensions != "")
    {
        fileName =  %fileName%-%dimensions%
    }
    
    fileName = %fileName%.dat

    dataFileName := GetUserDataFileName(fileName)

    return dataFileName
}

;--------------------------------------------------------------------------------
BuildDesktopIconFromDefinition(text, separator = "|")
{
    parts := StrSplit(text, separator)
    
    icon := new IconPosition(parts[1], parts[2])
	icon.Title := parts[3]
    
    return icon
}

;--------------------------------------------------------------------------------
GetIconPositionDefinition(iconPosition, separator = "|")
{
    parts := []
    parts.Push(iconPosition.Left)
    parts.Push(iconPosition.Top)
    parts.Push(iconPosition.Title)

    definition := JoinItems(separator, parts)

    return definition
}    

;--------------------------------------------------------------------------------
GetDesktopIconPositions(desktop)
{
	icons := []
	
	try
	{
		listViewHandle := desktop.SysListView32Window.WindowHandle
		
		SendMessage, %LVM_GETITEMCOUNT%, , , , ahk_id %listViewHandle%
		iconCount := ErrorLevel
		
		iconNames := []
		ControlGet, items, list, Col1
		Loop, Parse, items, `n
		{
			iconNames.push(A_LoopField)
		}
		
		hProcess := DllCall("OpenProcess"	, "UInt",	0x438			; PROCESS-OPERATION|READ|WRITE|QUERY_INFORMATION
											, "Int",	FALSE			; inherit = false
											, "UInt",	desktop.SysListView32Window.ProcessId)

		VarSetCapacity(iCoord, 8)
		pItemCoord := DllCall("VirtualAllocEx", "UInt", hProcess, "UInt", 0, "UInt", 8, "UInt", MEM_COMMIT | MEM_RESERVE, "UInt", PAGE_READWRITE)
		Loop, %iconCount%
		{
			index := A_Index - 1
			
			DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", pItemCoord, "UInt", &iCoord, "UInt", 8, "UIntP", cbReadWritten)
			SendMessage, %LVM_GETITEMPOSITION%, %index%, %pItemCoord%
			DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", pItemCoord, "UInt", &iCoord, "UInt", 8, "UIntP", cbReadWritten)
			
			x := (NumGet(iCoord) & 0xFFFF)
			y := (NumGet(iCoord, 4, "UInt") & 0xFFFF)
			title := iconNames[index + 1]
			
			iconPosition := new IconPosition(x, y)
			iconPosition.Index := index
			iconPosition.Title := title
			
			icons.push(iconPosition)
		}
		DllCall("VirtualFreeEx", "UInt", hProcess, "UInt", pItemCoord, "UInt", 0, "UInt", MEM_RELEASE)
	}
	catch e
	{
		LogText("Exception: " . e.Message . ", What: " . e.What . ", Extra: " . e.Extra)
	}
	finally
	{
		DllCall("CloseHandle", "UInt", hProcess)
	}
	
	return icons
}

;--------------------------------------------------------------------------------
HasIconMoved(icon1, icon2)
{
    if (icon1.Left <> icon2.Left)
        return True
    if (icon1.Top <> icon2.Top)
        return True
    
    return False
}

;--------------------------------------------------------------------------------
SaveDesktopIcons()
{
	desktop := new Desktop()
	if (!desktop.IsValid)
		return
	
	desktopSize := GetDesktopSize()
	
    fileName := GetDesktopIconsDataFileName(desktopSize)
    
    If FileExist(fileName)
    {
        LogText("Removing old Data File: " . fileName)
        FileDelete , %fileName%
    }
	
	iconPositions := GetDesktopIconPositions(desktop)
	
	saveCount := 0
	for i, iconPosition in iconPositions
	{
		xx := iconPositions[i]
		
		data := GetIconPositionDefinition(iconPosition)
	
		FileAppend , % data . "`r`n", %fileName%
		saveCount += 1
	}
    
    LogText("DesktopIcons: " . saveCount . " icons written to " . fileName)
    
    If saveCount > 0
    {
        TrayTip , %fileName%, % saveCount . " Desktop Icons saved", 3, 1
    }
    else
    {
        TrayTip , %fileName%, "No Desktop Icons saved", 3, 2
    }
}

;--------------------------------------------------------------------------------
RestoreDesktopIcons()
{
	desktop := new Desktop()
	if (!desktop.IsValid)
		return
	
    desktopSize := GetDesktopSize()
    
    fileName := GetDesktopIconsDataFileName(desktopSize)
    
    If !FileExist(fileName)
    {
        MsgBox , 48, Restore Desktop Icons, Unable to locate file %fileName%
        return
    }

    ; Read the file into an array
    savedIcons := []
    Loop, Read, %fileName%
    {
        if (A_LoopReadLine = "")
            break
        
        savedIcon := BuildDesktopIconFromDefinition(A_LoopReadLine)
        if savedIcon
        {
            savedIcons.Push(savedIcon)
        }
    }
	
	currentIcons := GetDesktopIconPositions(desktop)

    restoreCount := 0
    moveCount := 0
	for key, currentIcon in currentIcons
	{
		foundIcon :=
		for x, savedIcon in savedIcons
		{
			if (savedIcon.Title = currentIcon.Title)
			{
				foundIcon := savedIcon
				break
			}
		}
		
		if (!foundIcon)
		{
			LogText("No saved Icon for : " . currentIcon.Title)
			continue
		}
		
        If (HasIconMoved(foundIcon, currentIcon))
        {
			index := currentIcon.Index
			
            LogText("Moving: " . currentIcon.Description)
            LogText("To: " . foundIcon.Description)
            
			pItemCoord := (foundIcon.Top << 16) | foundIcon.Left
			LogText("pItemCoord: " . pItemCoord)
			
			SendMessage, %LVM_SETITEMPOSITION%, %index%, %pItemCoord%
			
            moveCount += 1
        }
        restoreCount += 1
	}
    
	text := "DesktopIcons: " . restoreCount . " icons restored, " . moveCount . " icons moved"
    LogText(text)
    TrayTip , %fileName%, %text%, 3, 1
}
