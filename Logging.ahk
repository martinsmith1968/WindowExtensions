LogFile := A_Temp

;--------------------------------------------------------------------------------
; LogText - Debug Text to a file
LogText(text)
{
	global LogFile
	
	FormatTime now,, yyy-MM-dd HH:mm.ss
	FileAppend %now% %text%`n, %LogFile%
}

;--------------------------------------------------------------------------------
; LogText - Debug Text to a file
LogStart()
{
	global LogFile
	
	IfNotEqual, A_IsCompiled, 1
	{
		FileDelete, LogFile
		file := FileOpen(LogFile, "w")
		if IsObject(file)
		{
			file.Close()
		}
	}
	
	LogText("------------------------------------------------------------------------------------------------------------------------")
	LogText("Starting...")
}
