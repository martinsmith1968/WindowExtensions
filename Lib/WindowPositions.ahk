#Include Lib\Logging.ahk
#Include Lib\StringUtils.ahk
#Include Lib\PathUtils.ahk
#Include Lib\WindowObjects.ahk

;--------------------------------------------------------------------------------
; Initialisation
SplitPath A_ScriptFullPath, , ScriptFilePath, , ScriptFileNameNoExt

;--------------------------------------------------------------------------------
; Configuration
UserDataPath := CombinePaths(A_AppData, ScriptFileNameNoExt)
UserDataFileName := "WindowPositions"
UserDataFile := CombinePaths(UserDataPath, UserDataFileName . ".dat")

If !DirectoryExists(UserDataPath)
{    
    LogText("Creating UserDataPath: " . UserDataPath)
    FileCreateDir, %UserDataPath%
}

;--------------------------------------------------------------------------------
SaveWindowPositions()
{
    global UserDataPath
    global UserDataFile
    
    If FileExist(UserDataFile)
    {
        LogText("Removing old Data File: " . UserDataFile)
        FileDelete , %UserDataFile%
    }

    saveCount := 0
    WinGet windows, List

    Loop %windows%
    {
        windowHandle := windows%A_Index%
        
        window := new Window(windowHandle)

        LogText(A_Index . ": " . window.Description)

        If window.Status = -1   ; Minimized
        {
            if !window.IsValid
            {
                WinRestore, ahk_id %windowHandle%
                WinGetPos, x, y, w, h, ahk_id %windowHandle%
                WinMinimize, ahk_id %windowHandle%
                
                window.Left := x
                window.Top := y
                window.Width := w
                window.Height := h
            }
        }

        if window.Title && window.IsValid
        {
            saveCount += 1
            data := window.WindowHandle . "," . window.ProcessName . "," . window.Title . "," . window.Left . "," . window.Top . "," . window.Width . "," . window.Height . "`n"
            LogText("Saving: " . data)
            FileAppend , %data%, %UserDataFile%
        }
    }
    
    If saveCount > 0
    {
        TrayTip , UserDataFileName, "No Window Positions saved", 3, 2
    }
    else
    {
        TrayTip , UserDataFileName, saveCount . " Window Positions saved", 3, 1
    }
}

;--------------------------------------------------------------------------------
RestoreWindowPositions()
{

}

;--------------------------------------------------------------------------------
WinGetNormalPos(hwnd, ByRef x, ByRef y, ByRef w="", ByRef h="")
{
    VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", hwnd, "uint", &wp)
    x := NumGet(wp, 28, "int")
    y := NumGet(wp, 32, "int")
    w := NumGet(wp, 36, "int") - x
    h := NumGet(wp, 40, "int") - y
}
