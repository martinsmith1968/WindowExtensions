#Include Lib\UserConfig.ahk

class WindowExtensionsUserConfig extends UserConfig
{
DefaultCascadeGutterSize := 30
DefaultColumnGutterSize := 5
DefaultGridGutterSize := 5
DefaultSpanMonitorGutterSize := 5

	__New()
	{
		global AppName
		
		fileName := GetUserDataFileName(AppName . ".dat")
		
		base.__New(fileName)
		
		this.Properties.push("CascadeGutterSize")
		this.Properties.push("ColumnGutterSize")
		this.Properties.push("GridGutterSize")
		this.Properties.push("SpanMonitorGutterSize")
	}
	
	CascadeGutterSize
	{
		get
		{
			return base.GetValue("General", base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultCascadeGutterSize, "integer")
		}
		set
		{
			base.SetValue("General", base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	ColumnGutterSize
	{
		get
		{
			return base.GetValue("General", base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultColumnGutterSize, "integer")
		}
		set
		{
			base.SetValue("General", base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	GridGutterSize
	{
		get
		{
			return base.GetValue("General", base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultGridGutterSize, "integer")
		}
		set
		{
			base.SetValue("General", base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
	
	SpanMonitorGutterSize
	{
		get
		{
			return base.GetValue("General", base.GetPropertyNameFromFunc(A_ThisFunc), this.DefaultSpanMonitorGutterSize, "integer")
		}
		set
		{
			base.SetValue("General", base.GetPropertyNameFromFunc(A_ThisFunc), value)
		}
	}
} 
