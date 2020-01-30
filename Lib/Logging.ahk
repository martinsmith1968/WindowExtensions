LogFile := 

;--------------------------------------------------------------------------------
; LogInit - Initialise logging (explicit call, rather than relying on include)
LogInit()
{
    global LogFile
    
    LogFile := A_Temp

    SplitPath A_ScriptFullPath, , ScriptFilePath, , ScriptFileNameNoExt

    ; Initialise Log
    LogFileSuffix := ""
    IfNotEqual, A_IsCompiled, 1
    {
        LogFileSuffix := ".Debug"
    }

    LogFile := A_Temp . "\" . ScriptFileNameNoExt . LogFileSuffix . ".log"
    LogStart()
}

;--------------------------------------------------------------------------------
; LogText - Debug Text to a file
LogText(text)
{
    global LogFile
    
    if (LogFile)
    {
        FormatTime now,, yyy-MM-dd HH:mm.ss
        FileAppend %now% %text%`r`n, %LogFile%
    }
}

;--------------------------------------------------------------------------------
; LogStart - Begin a logging session
LogStart()
{
    global LogFile
    
    if (LogFile)
    {
        IfNotEqual, A_IsCompiled, 1
        {
            FileDelete, LogFile
            file := FileOpen(LogFile, "w")
            if IsObject(file)
            {
                file.Close()
            }
        }
    }
    
    LogText("------------------------------------------------------------------------------------------------------------------------")
    LogText("Starting...")
}
