#Include Lib\Logging.ahk
#Include Lib\StringUtils.ahk
#Include Lib\PathUtils.ahk
#Include Lib\WindowObjects.ahk
#Include Lib\MathUtils.ahk
#Include Lib\UserDataUtils.ahk

;--------------------------------------------------------------------------------
; Constants
Critical
static MEM_COMMIT := 0x1000, PAGE_READWRITE := 0x04, MEM_RELEASE := 0x8000
static LVM_GETITEMPOSITION := 0x00001010, LVM_SETITEMPOSITION := 0x0000100F, WM_SETREDRAW := 0x000B

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

GetDesktopListView()
{
	shellWindowHandle := DllCall("User32.dll\GetShellWindow", "UPtr")
	
	Winget, defViewHandle, ID, ahk_class Progman
	
	Winget, defViewHandle2, ID, ahk_class SHELLDLL_DefView
	
	ControlGet, defViewHandl2, HWND, , SHELLDLL_DefView, ahk_id %defViewHandle%
	
	ControlGet, defViewHandle, HWND,, SysListView321, ahk_id %shellWindowHandle%
	
	ControlGet, listViewHandle, HWND,, SysListView321, ahk_id %shellWindowHandle%
	
	
	return listViewHandle
}

GetListViewItemCount(handle)
{
	SendMessage, 0xC, 0, &MyVar, ClassNN, WinTitle  
}

/*
--------------------------------------------------------------------------------
	Save and Load desktop icon positions
	based on save/load desktop icon positions by temp01 (http://www.autohotkey.com/forum/viewtopic.php?t=49714)
	
	Example:
		; save positions
		coords := DeskIcons()
		MsgBox now move the icons around yourself
		; load positions
		DeskIcons(coords)
	
	Plans:
		handle more settings (icon sizes, sort order, etc)
			- http://msdn.microsoft.com/en-us/library/ff485961%28v=VS.85%29.aspx
	
--------------------------------------------------------------------------------
; From : https://autohotkey.com/board/topic/60982-deskicons-getset-desktop-icon-positions/
*/
DeskIcons(coords="")
{
	
	
	handleShellWindow := DllCall("User32.dll\GetShellWindow", "UPtr")
	handleDefViewParent := handleShellWindow
	handleDefView := 

	ControlGet, hwWindow, HWND,, SysListView32, ahk_class Progman
	if !hwWindow ; #D mode
		ControlGet, hwWindow, HWND,, SysListView32, A
	if !hwWindow
		ControlGet, hwWindow, HWND,, SysListView321, ahk_class WorkerW
	
	;hwWindow := DllCall("User32.dll\GetDesktopWindow", "UPtr")
	
	IfWinExist ahk_id %hwWindow% ; last-found window set
		WinGet, iProcessID, PID
	hProcess := DllCall("OpenProcess"	, "UInt",	0x438			; PROCESS-OPERATION|READ|WRITE|QUERY_INFORMATION
										, "Int",	FALSE			; inherit = false
										, "UInt",	iProcessID)
	
	if hwWindow and hProcess
	{	
		ControlGet, list, list,Col1			
		if !coords
		{
			VarSetCapacity(iCoord, 8)
			pItemCoord := DllCall("VirtualAllocEx", "UInt", hProcess, "UInt", 0, "UInt", 8, "UInt", MEM_COMMIT, "UInt", PAGE_READWRITE)
			Loop, Parse, list, `n
			{
				SendMessage, %LVM_GETITEMPOSITION%, % A_Index-1, %pItemCoord%
				DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", pItemCoord, "UInt", &iCoord, "UInt", 8, "UIntP", cbReadWritten)
				ret .= A_LoopField ":" (NumGet(iCoord) & 0xFFFF) | ((Numget(iCoord, 4) & 0xFFFF) << 16) "`n"
			}
			DllCall("VirtualFreeEx", "UInt", hProcess, "UInt", pItemCoord, "UInt", 0, "UInt", MEM_RELEASE)
		}
		else
		{
			SendMessage, %WM_SETREDRAW%,0,0
			Loop, Parse, list, `n
				If RegExMatch(coords,"\Q" A_LoopField "\E:\K.*",iCoord_new)
					SendMessage, %LVM_SETITEMPOSITION%, % A_Index-1, %iCoord_new%
			SendMessage, %WM_SETREDRAW%,1,0
			ret := true
		}
	}
	DllCall("CloseHandle", "UInt", hProcess)
	return ret
}

GetDesktopIconPositions(desktop)
{
	icons := []
	
	
	return icons
}

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
	
	icons := GetDesktopIconPositions(desktop)
	
	FileAppend , %icons%, %fileName%	
	
	
	saveCount := 0
	For key, icon in icons
	{
		
		
		data := icon
		FileAppend , %data%, %fileName%
		
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

RestoreDesktopIcons()
{
}
