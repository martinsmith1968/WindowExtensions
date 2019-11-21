#Include Lib\Logging.ahk
#Include Lib\StringUtils.ahk
#Include Lib\PathUtils.ahk
#Include Lib\WindowObjects.ahk
#Include Lib\WindowFunctions.ahk
#Include Lib\MathUtils.ahk

; TODO Support Minimized / Maximized

;--------------------------------------------------------------------------------
BuildWindowFromDefinition(text, separator = "|")
{
    parts := StrSplit(text, separator)
    
    window := new Window(parts[1])
    window.Left := parts[2]
    window.Top := parts[3]
    window.Width := parts[4]
    window.Height := parts[5]
    window.WindowStatus := parts[6]
    isVisible := parts[7]
    window.ProcessName := parts[8]
    title := parts[9]
    
    return window
}

GetWindowDefinition(window, separator = "|")
{
    parts := []
    parts.Push(window.WindowHandle)
    parts.Push(window.Left)
    parts.Push(window.Top)
    parts.Push(window.Width)
    parts.Push(window.Height)
    parts.Push(window.WindowStatus)
    parts.Push(window.IsVisible)
    parts.Push(window.ProcessName)
    parts.Push(window.Title)

    definition := JoinItems(separator, parts)

    return definition
}    

;--------------------------------------------------------------------------------
; Initialisation
SplitPath A_ScriptFullPath, , ScriptFilePath, , ScriptFileNameNoExt

;--------------------------------------------------------------------------------
; Configuration
UserDataPath := CombinePaths(A_AppData, ScriptFileNameNoExt)
UserDataFileName := "WindowPositions"
;UserDataFile := CombinePaths(UserDataPath, UserDataFileName . ".dat")

If !DirectoryExists(UserDataPath)
{    
    LogText("Creating UserDataPath: " . UserDataPath)
    FileCreateDir, %UserDataPath%
}

;--------------------------------------------------------------------------------
GetDimensions(rectangle)
{
    return rectangle.Width . "x" . rectangle.Height
}

;--------------------------------------------------------------------------------
GetUserDataFileName(desktopSize)
{
    global UserDataPath
    global UserDataFileName
    
    dimensions := GetDimensions(desktopSize)
    
    fileName := CombinePaths(UserDataPath, UserDataFileName)
    
    if (dimensions != "")
    {
        fileName =  %fileName%-%dimensions%
    }
    
    fileName = %fileName%.dat
    
    return fileName
}

;--------------------------------------------------------------------------------
GetDesktopSize()
{
    SysGet, monitorCount, MonitorCount
	
    desktopSize := new Rectangle2(0, 0)
    desktopSize.Right := 0
    desktopSize.Bottom := 0
    
	Loop, %monitorCount%
	{
		; Get Monitor Details
		monitor := new Monitor(A_Index)
        
        desktopSize.Left   := MinOf(monitor.Left, desktopSize.Left)
        desktopSize.Right  := MaxOf(monitor.Right, desktopSize.Right)
        desktopSize.Top    := MinOf(monitor.Top, desktopSize.Top)
        desktopSize.Bottom := MaxOf(monitor.Bottom, desktopSize.Bottom)
    }
    
    return desktopSize
}

;--------------------------------------------------------------------------------
HasSavedWindowPositionFile(desktopSize)
{
    fileName := GetUserDataFileName(desktopSize)
    
    return FileExist(fileName)
}

;--------------------------------------------------------------------------------
SaveWindowPositions()
{
    desktopSize := GetDesktopSize()
    
    fileName := GetUserDataFileName(desktopSize)
    
    If FileExist(fileName)
    {
        LogText("Removing old Data File: " . fileName)
        FileDelete , %fileName%
    }

    saveCount := 0
    WinGet windows, List

    Loop %windows%
    {
        windowHandle := windows%A_Index%
        
        window := new Window(windowHandle)
        LogText(A_Index . ": " . window.Description)

        isVisible := IsWindowVisible(windowHandle)

        restored := GetWindowNormalPosition(windowHandle)
        if (!restored.IsValid)
        {
            WinRestore, ahk_id %windowHandle%
            WinGetPos, x, y, w, h, ahk_id %windowHandle%
            SetWindowStatus(window, window.WindowStatus)
            
            restored := new Rectangle(x, y, w, h)
        }
        
        if (restored.IsValid)
        {
            window.Left := restored.Left
            window.Top := restored.Top
            window.Width := restored.Width
            window.Height := restored.Height
        }

        if (window.Title && window.IsValid && isVisible)
        {
            saveCount += 1
            data := GetWindowDefinition(window)
            LogText("Saving: " . data)
            FileAppend , % data . "`r`n", %fileName%
        }
    }
    
    LogText("WindowPositions: " . saveCount . " windows written to " . fileName)
    
    If saveCount > 0
    {
        TrayTip , %fileName%, "No Window Positions saved", 3, 2
    }
    else
    {
        TrayTip , %fileName%, % saveCount . " Window Positions saved", 3, 1
    }
}

;--------------------------------------------------------------------------------
RestoreWindowPositions()
{
    desktopSize := GetDesktopSize()
    
    fileName := GetUserDataFileName(desktopSize)
    
    If !FileExist(fileName)
    {
        MsgBox , 48, Restore Window Positions, Unable to locate file %fileName%
        return
    }

    ; Read the file into an array
    savedWindows := []
    Loop, Read, %fileName%
    {
        if (A_LoopReadLine = "")
            break
        
        savedWindow := BuildWindowFromDefinition(A_LoopReadLine)
        if savedWindow
        {
            savedWindows.Push(savedWindow)
        }
    }

    restoreCount := 0
    moveCount := 0
    For key, savedWindow in savedWindows
    {
        currentWindow := new Window(savedWindow.WindowHandle)
        if (currentWindow.ProcessName <> savedWindow.ProcessName)
        {
            ; Find current window for appname
            currentWindow := FindCurrentWindowForProcessName(savedWindow.ProcessName)
            if (!currentWindow.IsValid)
                continue
        }
        
        restoredPosition := GetWindowNormalPosition(currentWindow.WindowHandle)
        if (restoredPosition.IsValid)
        {
            currentWindow.Left := restoredPosition.Left
            currentWindow.Top := restoredPosition.Top
            currentWindow.Width := restoredPosition.Width
            currentWindow.Height := restoredPosition.Height
        }
    
        If (HasMoved(savedWindow, currentWindow))
        {
            LogText("Moving: " . currentWindow.Description)
            LogText("To: " . savedWindow.Description)
            SetWindowStatus(currentWindow, 0)
            MoveAndSizeWindow(currentWindow, savedWindow.Left, savedWindow.Top, savedWindow.Width, savedWindow.Height)
            SetWindowStatus(currentWindow, savedWindow.WindowStatus)
            
            moveCount += 1
        }
        restoreCount += 1
    }
    
    LogText("WindowPositions: " . restoreCount . " windows restored, " . moveCount . " windows moved")
    
    TrayTip , %fileName%, % restoreCount . " Window Positions restored, " . moveCount . " windows moved", 3, 1
}

HasMoved(window1, window2)
{
    if (window1.Left <> window2.Left)
        return True
    if (window1.Top <> window2.Top)
        return True
    if (window1.Width <> window2.Width)
        return True
    if (window1.Height <> window2.Height)
        return True
    if (window1.WindowStatus <> window2.WindowStatus)
        return True
    
    return False
}

FindCurrentWindowForProcessName(processName)
{
    WinGet windows, List

    Loop %windows%
    {
        windowHandle := windows%A_Index%
        
        window := new Window(windowHandle)
        if (window.ProcessName = processName)
        {
            return window
        }
    }
    
    return
}
