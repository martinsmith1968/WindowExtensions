#include Lib\StringUtils.ahk

;--------------------------------------------------------------------------------
; CombinePaths - Append path2 to path1, ensuring the correct delimiters are in place
CombinePaths(path1, path2)
{
    return EnsureEndsWith(path1, "\") . path2
}

;--------------------------------------------------------------------------------
; CombinePaths - Append multiple paths together, ensuring the correct delimiters are in place
CombinePathA(paths*)
{
    newPath := 

    Loop, %path%
    {
        if (newPath = "")
        {
            newPath := path
        }
        else
        {
            newPath := EnsureEndsWith(newPath, "\") . path
        }
    }

    return newPath
}

;--------------------------------------------------------------------------------
; FileExists - Determines if a file exists
FileExists(fileName)
{
    fileAttribute := FileExist(fileName)
    
    exists := (fileAttribute && fileAttribute != "X")
	
	return exists
}

;--------------------------------------------------------------------------------
; FolderExists - Determines if a folder exists
FolderExists(folderName)
{
    folderAttribute := FileExist(folderName)
    
    exists := (folderAttribute && InStr(folderAttribute, "D"))
	
	return exists
}
