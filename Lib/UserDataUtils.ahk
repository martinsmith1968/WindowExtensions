#Include Lib\Logging.ahk
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
