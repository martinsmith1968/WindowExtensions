#Include Lib\UserDataUtils.ahk
#Include Lib\Logging.ahk
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
	Properties := []
	DataFileName :=

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
	
	GetPropertyNameFromFunc(func)
	{
		bits := StrSplit(func, ".")
		
		propertyName := bits[2]
		
		if (propertyName =)
			propertyName := func
		
		return propertyName
	}
	
	Save()
	{
		for index, propertyName in this.Properties
		{
			value := this[propertyName]
			this[propertyName] := value
		}
	}
}
