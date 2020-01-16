#include Lib\StringUtils.ahk
#include Lib\HashingFunctions.ahk

;--------------------------------------------------------------------------------
; CombinePaths - Append path2 to path1, ensuring the correct delimiters are in place
CombinePaths(path1, path2)
{
    return EnsureEndsWith(path1, "\") . path2
}

;--------------------------------------------------------------------------------
; CombinePaths - Append multiple paths together, ensuring the correct delimiters are in place
CombineAllPaths(paths*)
{
    newPath := 

    For index, path in paths
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
; SetFileExtension - Set the extension on a filename
SetFileExtension(fileName, extension)
{
    pos := InStr(fileName, ".", false, -1)
    if (pos)
        fileName := SubStr(fileName, 1, pos)
    
    fileName := EnsureEndsWith(fileName, ".") . extension
    
    return fileName
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

;--------------------------------------------------------------------------------
; FileReadContent - Read the entire contents of a file into a variable
FileReadContent(fileName)
{
    FileRead, content, %fileName%
    
    return content
}

;--------------------------------------------------------------------------------
; FileReadContentLines - Read every line of a file into an array
FileReadContentLines(fileName)
{
    lines := []
    
    Loop, Read, %fileName%
    {
        lines.push(A_LoopReadLine)
    }
    
    return lines
}
