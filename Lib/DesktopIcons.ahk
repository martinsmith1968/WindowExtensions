#Include Lib\Logging.ahk
#Include Lib\StringUtils.ahk
#Include Lib\IOUtils.ahk
#Include Lib\WindowObjects.ahk
#Include Lib\MathUtils.ahk
#Include Lib\UserDataUtils.ahk
#Include Lib\PleasantNotify.ahk
#Include Lib\WindowExtensionsClasses.ahk

; Inspired by : https://autohotkey.com/board/topic/60982-deskicons-getset-desktop-icon-positions/

;--------------------------------------------------------------------------------
; Constants
global MEM_COMMIT := 0x1000, MEM_RESERVE := 0x2000, MEM_RELEASE := 0x8000
global PAGE_READWRITE := 0x04
global LVM_GETITEMCOUNT := 0x00001004, LVM_GETITEMPOSITION := 0x00001010, LVM_SETITEMPOSITION := 0x0000100F, WM_SETREDRAW := 0x000B

;--------------------------------------------------------------------------------
; Globals
DesktopIconsBaseFileName := ""
DesktopIconsFileExt := "dat"

;--------------------------------------------------------------------------------
; Initialisation
DesktopIcons_OnInit()
{
    global MEM_COMMIT
    global PAGE_READWRITE
    global LVM_GETITEMCOUNT
    global DesktopIconsBaseFileName
    global DesktopIconsFileExt

    MEM_COMMIT := 0x1000, MEM_RESERVE := 0x2000, MEM_RELEASE := 0x8000
    PAGE_READWRITE := 0x04
    LVM_GETITEMCOUNT := 0x00001004, LVM_GETITEMPOSITION := 0x00001010, LVM_SETITEMPOSITION := 0x0000100F, WM_SETREDRAW := 0x000B
    
    DesktopIconsBaseFileName := "DesktopIcons"
    DesktopIconsFileExt := "dat"

    allFiles := GetDesktopIconsDataFiles("")
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
; DesktopIconsDataFile - 
class DesktopIconsDataFile extends WindowExtensionsDataFile
{
    __New(fullFileName)
    {
        base.__New(fullFileName)
    }
    
    IsValid()
    {
        global DesktopIconsBaseFileName
        global DesktopIconsFileExt
        
        isValid := (this.BaseFileName && (this.BaseFileName = DesktopIconsBaseFileName)) && (this.DesktopSizeDescription) && (this.Timestamp) && (this.Extension && (this.Extension = DesktopIconsFileExt))
        
        return isValid
    }
}

;--------------------------------------------------------------------------------
; BuildDesktopIconsDataFileName - Build the filename for a DesktopIcons data file or pattern
BuildDesktopIconsDataFileName(desktopSize, isNew := false, isPattern := false)
{
    global DesktopIconsBaseFileName
    global DesktopIconsFileExt
    
    dimensions := desktopSize.DimensionsText

    fileNamePattern := DesktopIconsBaseFileName
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
    
    fileNamePattern .= "." . DesktopIconsFileExt
    
    return fileNamePattern
}

;--------------------------------------------------------------------------------
; GetDesktopIconsDataFileNames - Get all the DesktopIcons data files for the desktop size
GetDesktopIconsDataFileNames(desktopSize)
{
    global DesktopIconsBaseFileName
    global DesktopIconsFileExt
    
    pattern := BuildDesktopIconsDataFileName(desktopSize, false, true)
    
    files := GetUserDataFileNames(pattern, -1)
    
    return files
}

;--------------------------------------------------------------------------------
; GetDesktopIconsDataFiles - Get all the DesktopIcons instances for the desktop size
GetDesktopIconsDataFiles(desktopSize)
{
    files := GetDesktopIconsDataFileNames(desktopSize)
    
    instances := []
    for index, item in files
    {
        instance := new DesktopIconsDataFile(item)
        instances.push(instance)
    }
    
    return instances
}

;--------------------------------------------------------------------------------
; HasSavedDesktopIconsFile - Is there a file of saved Desktop Icons
HasSavedDesktopIconsFile(desktopSize)
{
    fileNames := GetDesktopIconsDataFileNames(desktopSize)
    
    return (fileNames.length() > 0)
}

;--------------------------------------------------------------------------------
; HasMultipleSavedDesktopIconsFiles - Is there more than 1 file of saved Desktop Icons
HasMultipleSavedDesktopIconsFiles(desktopSize)
{
    fileNames := GetDesktopIconsDataFileNames(desktopSize)
    
    return (fileNames.length() > 1)
}

;--------------------------------------------------------------------------------
; GetLatestDesktopIconsDataFileName - Get the appropriate saved Window Positions filename
GetLatestDesktopIconsDataFileName(desktopSize)
{
    files := GetDesktopIconsDataFileNames(desktopSize)
    
    dataFileName := files.length() > 0
        ? files[1]
        : ""

    return dataFileName
}

;--------------------------------------------------------------------------------
; BuildDesktopIconFromDefinition - Build a Desktop Icon Definition from a text string
BuildDesktopIconFromDefinition(text, separator := "|")
{
    parts := StrSplit(text, separator)
    
    icon := new IconPosition(parts[1], parts[2])
    icon.Title := parts[3]
    
    return icon
}

;--------------------------------------------------------------------------------
; GetIconPositionDefinition - Create a text representation of a Desktop Icon
GetIconPositionDefinition(iconPosition, separator := "|")
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
        
        hProcess := DllCall("OpenProcess"   , "UInt",   0x438            ; PROCESS-OPERATION|READ|WRITE|QUERY_INFORMATION
                                            , "Int",    FALSE            ; inherit = false
                                            , "UInt",   desktop.SysListView32Window.ProcessId)

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
; SaveDesktopIcons - Save all the current desktop icons to a file
SaveDesktopIcons(notify)
{
    desktop := new Desktop()
    if (!desktop.IsValid)
        return
    
    desktopSize := GetDesktopSize()
    
    iconPositions := GetDesktopIconPositions(desktop)
    
    fileName := GetUserDataFileName(BuildDesktopIconsDataFileName(desktopSize, true))
    
    saveCount := 0
    for i, iconPosition in iconPositions
    {
        data := GetIconPositionDefinition(iconPosition)
    
        FileAppend , % data . "`r`n", %fileName%
        saveCount += 1
    }
    
    LogText("DesktopIcons: " . saveCount . " icons written to " . fileName)
    
    if (notify)
    {
        notifyText := "No Desktop Icons saved"
        If saveCount > 0
        {
            notifyText := saveCount . " Desktop Icons saved"
        }
        
        new PleasantNotify("Desktop Icons", notifyText, 250, 100, "b r")
    }
}

;--------------------------------------------------------------------------------
; RestoreDesktopIcons - Restores desktop icons from a file
RestoreDesktopIcons(fileName)
{
    LogText("RestoreDesktopIcons: Using fileName: " . fileName)
    If (!FileExists(fileName))
    {
        MsgBox, 48, Restore Desktop Icons, Unable to locate file %fileName%
        return
    }

    desktop := new Desktop()
    if (!desktop.IsValid)
        return
    
    desktopSize := GetDesktopSize()
    
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

    textParts := []
    textParts.push(restoreCount . " icons restored")
    textParts.push(moveCount . " icons moved")

    LogText("DesktopIcons: " . JoinItems(", ", textParts))
    
    new PleasantNotify("Desktop Icons", JoinItems("`r`n", textParts), 300, 125, "b r")
}

;--------------------------------------------------------------------------------
; RestoreDesktopIconsFromFile - Show the dialog to select the file to restore desktop icons from
RestoreDesktopIconsFromFile(desktopSize)
{
    global G_SelectableDesktopIcons
    
    columns := [ "Desktop Resolution", "Date Created", "Hash", "Icon Count" ]
    columnOptions := [ "AutoHdr NoSort", "Auto NoSort", "Auto NoSort Right", "AutoHdr Integer NoSort" ]

    G_SelectableDesktopIcons := GetDesktopIconsDataFiles(desktopSize)

    items := []
    for index, item in G_SelectableDesktopIcons
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
    selector.OnSuccess := "OnDesktopIconsSelected"

    selector.ShowDialog()
}

;--------------------------------------------------------------------------------
; OnDesktopIconsSelected - Restore selected Window Positions
OnDesktopIconsSelected(listViewSelector)
{
    global G_SelectableDesktopIcons
    
    item := G_SelectableDesktopIcons[listViewSelector.SelectedIndex]
    
    if (!item)
        return
    
    RestoreDesktopIcons(item.FullFileName)
}
