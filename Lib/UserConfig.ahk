#Include Lib\UserDataUtils.ahk
#Include Lib\Logging.ahk

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
		
		LogText("Getting Value: [" . section . "]." . key . ", default:" . defaultValue)
		IniRead, readValue, %dataFileName%, %section%, %key%, %defaultValue%
		
		LogText("Got Value: " . readValue)
		
		if (type <> "")
		{
			; TODO - Support other types
			if (type = "integer")
			{
				if readValue is not integer
				{
					readValue := defaultValue
				}
			}
		}
		
		return readValue
	}
	
	SetValue(section, key, value)
	{
		dataFileName := this.DataFileName
		
		LogText("Setting Value: [" . section . "]." . key . ", value:" . value)
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
