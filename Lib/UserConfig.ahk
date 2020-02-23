#Include Lib\Logging.ahk
#Include Lib\UserDataUtils.ahk
#Include Lib\WindowPositions.ahk

;--------------------------------------------------------------------------------
; Initialisation
UserConfig_OnInit()
{
    UserDataUtils_OnInit()
}

;--------------------------------------------------------------------------------
; UserConfig base class
class UserConfig
{
    DataFileName :=
    Properties := []
    ObsoleteProperties := []

    __New(fileName)
    {
        LogText("Setting DataFileName: " . fileName)
        this.DataFileName := fileName
    }
    
    GetValue(section, key, defaultValue, type="")
    {
        dataFileName := this.DataFileName
        
        LogText("Getting Value: [" . section . "]." . key . ", default: " . defaultValue)
        IniRead, readValue, %dataFileName%, %section%, %key%, %defaultValue%
        
        LogText("Got Value: " . readValue)
        
        if (type <> "")
        {
            if (type = "integer")
            {
                if readValue is not integer
                {
                    readValue := defaultValue
                }
            }
            else if (type == "boolean")
            {
                readValue := (readValue) ? true : false
            }
            ; TODO - Support other types as necessary
        }
        
        return readValue
    }
    
    SetValue(section, key, value)
    {
        dataFileName := this.DataFileName
        
        LogText("Setting Value: [" . section . "]." . key . ", value: " . value)
        IniWrite, %value%, %dataFileName%, %section%, %key%
    }
    
    GetSectionNameFromFunc(func, defaultName := "General")
    {
        sectionName := Instr(func, ".") ? StrSplit(func, ".")[2] : func
        
        if (sectionName =)
            sectionName := func
        
        nameParts := StrSplit(sectionName, "_")
        if (nameParts.length() > 1)
            sectionName := nameParts[1]
        else
            sectionName := defaultName
        
        return sectionName
    }
    
    GetPropertyNameFromFunc(func)
    {
        propertyName := Instr(func, ".") ? StrSplit(func, ".")[2] : func
        
        if (propertyName =)
            propertyName := func
        
        nameParts := StrSplit(propertyName, "_")
        if (nameParts.length() > 1)
            propertyName := nameParts[2]
        
        return propertyName
    }
    
    RemoveProperty(section, propertyName)
    {
        dataFileName := this.DataFileName
        
        LogText("Removing: [" . section . "]." . propertyName)
        IniDelete, %dataFileName%, %section%, %propertyName%
    }
    
    Save()
    {
        for index, propertyName in this.Properties
        {
            value := this[propertyName]
            this[propertyName] := value
        }
        for index, propertyName in this.ObsoleteProperties
        {
            this.RemoveProperty(this.GetSectionNameFromFunc(propertyName), this.GetPropertyNameFromFunc(propertyName))
        }
    }
}
