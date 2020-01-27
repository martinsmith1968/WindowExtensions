#Include Lib\Logging.ahk
#Include Lib\ArrayUtils.ahk
#Include Lib\StringUtils.ahk
#Include Lib\IOClasses.ahk
#Include Lib\WindowObjects.ahk
#Include Lib\WindowFunctions.ahk
#Include Lib\MathUtils.ahk
#Include Lib\IOUtils.ahk
#Include Lib\UserDataUtils.ahk
#Include Lib\HashingFunctions.ahk
#Include Lib\PleasantNotify.ahk
#Include Lib\WindowExtensionsClasses.ahk

;--------------------------------------------------------------------------------
; Globals
WindowPositionsBaseFileName := ""
WindowPositionsFileExt := "dat"

;--------------------------------------------------------------------------------
; Initialisation
WindowPositions_OnInit()
{
    global WindowPositionsBaseFileName
    global WindowPositionsFileExt
    
    WindowPositionsBaseFileName := "WindowPositions"
    WindowPositionsFileExt := "dat"
    
    allFiles := GetWindowPositionsDataFiles("")
    for index, item in allFiles
    {
        if (!item.FileTimestamp)
        {
            sourceFileName := item.FullFileName
            destFileName := item.BuildFileName()
            
            try FileMove, %sourceFileName%, %destFileName%, 0
        }
    }
}

;--------------------------------------------------------------------------------
; WindowPositionsDataFile - 
class WindowPositionsDataFile extends WindowExtensionsDataFile
{
	__New(fullFileName)
	{
        base.__New(fullFileName)
    }
    
    IsValid()
    {
        global WindowPositionsBaseFileName
        global WindowPositionsFileExt
        
        isValid := (this.BaseFileName && (this.BaseFileName = WindowPositionsBaseFileName)) && (this.DesktopSizeDescription) && (this.Timestamp) && (this.Extension && (this.Extension = WindowPositionsFileExt))
        
        return isValid
    }
}

;--------------------------------------------------------------------------------
; BuildWindowPositionsDataFileName - Build the filename for a WindowPositions data file or pattern
BuildWindowPositionsDataFileName(desktopSize, isNew := false, isPattern := false)
{
    global WindowPositionsBaseFileName
    global WindowPositionsFileExt
    
    dimensions := desktopSize.DimensionsText

    fileNamePattern := WindowPositionsBaseFileName
    if (dimensions != "")
    {
        fileNamePattern .= "-" . dimensions
    }
    
    if (isPattern)
    {
        fileNamePattern .= "*"
    }
    else if (isNew)
    {
        dateTime := A_Now
        
        FormatTime, fileDateTime, dateTime, yyyyMMddHHmmss
        fileNamePattern .= "-" . fileDateTime
    }
    
    fileNamePattern .= "." . WindowPositionsFileExt
    
    return fileNamePattern
}

;--------------------------------------------------------------------------------
; GetWindowPositionsDataFileNames - Get all the WindowPositions data files for the desktop size
GetWindowPositionsDataFileNames(desktopSize)
{
    global WindowPositionsBaseFileName
    global WindowPositionsFileExt
    
    pattern := BuildWindowPositionsDataFileName(desktopSize, false, true)
    
    files := GetUserDataFileNames(pattern, -1)
    
    return files
}

;--------------------------------------------------------------------------------
; GetWindowPositionsDataFiles - Get all the WindowPositions instances for the desktop size
GetWindowPositionsDataFiles(desktopSize)
{
    files := GetWindowPositionsDataFileNames(desktopSize)
    
    instances := []
    for index, item in files
    {
        instance := new WindowPositionsDataFile(item)
        instances.push(instance)
    }
    
    return instances
}

;--------------------------------------------------------------------------------
; HasSavedWindowPositionsFile - Is there a file of saved Window Positions
HasSavedWindowPositionsFile(desktopSize)
{
    fileNames := GetWindowPositionsDataFileNames(desktopSize)
    
    return (fileNames.length() > 0)
}

;--------------------------------------------------------------------------------
; HasMultipleSavedWindowPositionsFiles - Is there more than 1 file of saved Window Positions
HasMultipleSavedWindowPositionsFiles(desktopSize)
{
    fileNames := GetWindowPositionsDataFileNames(desktopSize)
    
    return (fileNames.length() > 1)
}

;--------------------------------------------------------------------------------
; GetLatestWindowPositionsDataFileName - Get the appropriate saved Window Positions filename
GetLatestWindowPositionsDataFileName(desktopSize)
{
    files := GetWindowPositionsDataFileNames(desktopSize)
    
    dataFileName := files.length() > 0
        ? files[1]
        : ""

    return dataFileName
}

;--------------------------------------------------------------------------------
; BuildWindowFromDefinition - Build a Window Definition from a text string
BuildWindowFromDefinition(text, separator := "|")
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

;--------------------------------------------------------------------------------
; GetWindowDefinition - Create a text representation of a Window Definition
GetWindowDefinition(window, separator := "|")
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
; SaveWindowPositions - Save all the current window positions to a file
SaveWindowPositions(includeOffScreenWindows, notify)
{
    desktopSize := GetDesktopSize()
    
    fileName := GetUserDataFileName(BuildWindowPositionsDataFileName(desktopSize, true))

    saveCount := 0
    WinGet windows, List

    Loop %windows%
    {
        windowHandle := windows%A_Index%
        
        window := new Window(windowHandle)
        LogText(A_Index . ": " . window.Description)

        isVisible := IsWindowVisible(windowHandle)
        if (!isVisible)
        {
            LogText("Ignoring InVisible: " . window.Description)
            continue
        }
        isOnScreen := IsWindowOnScreen(windowHandle)
        if (!isOnScreen && !includeOffScreenWindows)
        {
            LogText("Ignoring Off-Screen: " . window.Description)
            continue
        }

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
    
    if (notify)
    {
        notifyText := "No Window Positions saved"
        If saveCount > 0
        {
            notifyText := saveCount . " Window Positions saved"
        }

        new PleasantNotify("Window Positions", notifyText, 250, 100, "b r")
    }
}

;--------------------------------------------------------------------------------
; RestoreWindowPositions - Restores window positions from a file
RestoreWindowPositions(fileName, includeOffScreenWindows)
{
    LogText("RestoreWindowPositions: Using fileName: " . fileName)
    If (!FileExists(fileName))
    {
        MsgBox, 48, Restore Window Positions, Unable to locate file %fileName%
        return
    }

    ; Read the file into an array
    savedWindows := []
    Loop, Read, %fileName%
    {
        if (A_LoopReadLine = "")
            break
        
        savedWindow := BuildWindowFromDefinition(A_LoopReadLine)
        if (!savedWindow)
            continue
        
        if (!IsRectOnScreen(savedWindow) && !includeOffScreenWindows)
        {
            LogText("Ignoring Off-Screen: " . savedWindow.Description)
            continue
        }

        savedWindows.Push(savedWindow)
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
    
        If (HasWindowMoved(savedWindow, currentWindow))
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
    
	textParts := []
	textParts.push(restoreCount . " windows restored")
	textParts.push(moveCount . " windows moved")
    
    LogText("WindowPositions: " . JoinItems(", ", textParts))

    new PleasantNotify("Window Positions", JoinItems("`r`n", textParts), 350, 125, "b r")
}

;--------------------------------------------------------------------------------
; RestoreWindowPositionsFromFile - Show the dialog to select the file to restore window positions from
RestoreWindowPositionsFromFile(desktopSize)
{
	global G_SelectableWindowPositions
	
	columns := [ "Desktop Resolution", "Date Created", "Hash", "Window Count" ]
	columnOptions := [ "AutoHdr NoSort", "Auto NoSort", "Auto NoSort Right", "AutoHdr Integer NoSort" ]

	G_SelectableWindowPositions := GetWindowPositionsDataFiles(desktopSize)

	items := []
	for index, item in G_SelectableWindowPositions
	{
		itemTimestamp := item.Timestamp
		FormatTime, timestamp, %itemTimestamp%, yyyy-MM-dd HH:mm.ss
		row := [ item.DesktopSizeDescription, timestamp, item.Adler32, item.LineCount ]
		items.push(row)
	}

	selector := new ListViewSelector()
	selector.Title := "Restore Window Positions..."
	selector.ColumnNames := columns
	selector.ColumnOptions := columnOptions
	selector.Items := items
	selector.ListViewWidth := 400
	selector.MinRowCountSize := 6
	selector.SelectedIndex := 1
	selector.OnSuccess := "OnWindowPositionsSelected"

	selector.ShowDialog()
}

;--------------------------------------------------------------------------------
; OnWindowPositionSelected - Restore selected Window Positions
OnWindowPositionsSelected(listViewSelector)
{
	global G_SelectableWindowPositions
	
	item := G_SelectableWindowPositions[listViewSelector.SelectedIndex]
	
	if (!item)
		return
	
	RestoreWindowPositions(item.FullFileName, G_UserConfig.WindowPositions_IncludeOffScreenWindows)
}
