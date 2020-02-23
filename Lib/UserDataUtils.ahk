#Include Lib\Logging.ahk
#Include Lib\ArrayUtils.ahk
#Include Lib\StringUtils.ahk
#Include Lib\IOUtils.ahk

;--------------------------------------------------------------------------------
; Globals
UserDataPath := ""

;--------------------------------------------------------------------------------
; Initialisation
UserDataUtils_OnInit()
{
    global AppName
    global UserDataPath
    
    SplitPath A_ScriptFullPath, , , , AppName

    UserDataPath := CombinePaths(A_AppData, AppName)

    If (!FolderExists(UserDataPath))
    {    
        LogText("Creating UserDataPath: " . UserDataPath)
        FileCreateDir, %UserDataPath%
    }
}

;--------------------------------------------------------------------------------
; GetUserDataFileName : Build an appropriate file name for the specified User data
GetUserDataFileName(dataFileName)
{
    global UserDataPath
    
    fileName := CombinePaths(UserDataPath, dataFileName)
    
    return fileName
}

;--------------------------------------------------------------------------------
; GetUserDataFileNames : Get a list of appropriate file names for the specified User Data
GetUserDataFileNames(dataFilePattern, sortOrder := 0)
{
    global UserDataPath
    
    filePattern := CombinePaths(UserDataPath, dataFilePattern)
        
    files := []
    
    Loop, Files, %filePattern%
    {
        files.push(A_LoopFileFullPath)
    }
    
    if (sortOrder != 0)
    {
        files := SortArray(files)
        
        if (sortOrder < 0)
        {
            files := ReverseArray(files)
        }
    }
    
    return files
}

;--------------------------------------------------------------------------------
; ConsolidateUserDataFilesByCRC32 : Consolidate User Data files by removing those with a duplicate CRC32
GroupFilesByCRC32(allFiles)
{
    allFileNamesByHash := []

    fileCount := allFiles.Length()
    LogText("fileCount: " . fileCount)

    Loop, % fileCount
    {
        fileName := allFiles[A_Index]
        
        userDataFile := new DataFile(fileName)
        fileHash := userDataFile.CRC32
        
        items := allFileNamesByHash[fileHash]
        if (!items)
        {
            allFileNamesByHash[fileHash] := []
        }
        LogText("Hash: " . fileHash . " - " . fileName)
        allFileNamesByHash[fileHash].push(userDataFile)
    }
    
    return allFileNamesByHash
}

;--------------------------------------------------------------------------------
; ConsolidateUserDataFilesByCRC32 : Consolidate User Data files by removing those with a duplicate CRC32
ConsolidateUserDataFilesByCRC32(allFiles)
{
    deleteCount := 0
    
    allFileNamesByHash := GroupFilesByCRC32(allFiles)
    
    For hash, hashItems in allFileNamesByHash
    {
        hashCount := hashItems.Length()
        if (hashCount < 2)
        {
            LogText("Hash: " . hash . " - skipping for count: " . hashCount)
            continue
        }
        
        Loop, % hashCount
        {
            hashFile := hashItems[A_Index]
            hashFileName := hashFile.FullFileName
            
            if (A_Index < 2)
            {
                LogText("Hash: " . fileHash . " - keeping: " . hashFileName)
                continue
            }

            LogText("Hash: " . fileHash . " - deleting: " . hashFileName)
            FileDelete, %hashFileName%
            deleteCount += 1
        }
    }
    
    return deleteCount
}
