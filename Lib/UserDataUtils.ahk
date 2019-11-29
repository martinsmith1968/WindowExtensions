#Include Lib\Logging.ahk
#Include Lib\StringUtils.ahk
#Include Lib\PathUtils.ahk

;--------------------------------------------------------------------------------
; Initialisation
SplitPath A_ScriptFullPath, , , , AppName

UserDataPath := CombinePaths(A_AppData, AppName)

If !DirectoryExists(UserDataPath)
{    
    LogText("Creating UserDataPath: " . UserDataPath)
    FileCreateDir, %UserDataPath%
}

GetUserDataFileName(dataFileName)
{
	global UserDataPath
	
    fileName := CombinePaths(UserDataPath, dataFileName)
	
	return fileName
}
