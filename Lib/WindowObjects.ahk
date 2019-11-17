#Include Lib\WindowFunctions.ahk

Class Coordinate
{
	X := 0
	Y := 0
	
	__New(x, y)
	{
		this.X := x
		this.Y := y
	}
	
	Left
	{
		get
		{
			return this.X 
		}
		set
		{
			this.X := value
		}
	}
	
	Top
	{
		get
		{
			return this.Y
		}
		set
		{
			this.Y := value
		}
	}
	
	Description
	{
		get
		{
			return "Left: " . this.Left . ", Top: " . this.Top . ", MonitorIndex: " . this.MonitorIndex
		}
	}
	
	IsInRectangle(rect)
	{
		if (this.X < rect.Left)
			return false
		if (this.X > rect.Right)
			return false
		if (this.Y < rect.Top)
			return false
		if (this.Y > rect.Bottom)
			return false
		
		return true		
	}
	
	MonitorIndex
	{
		get
		{
			SysGet, primaryMonitorIndex, MonitorPrimary

			index := GetMonitorIndexAt(this.X, this.Y, primaryMonitorIndex)
			
			return index
		}
	}
}

Class Rectangle extends Coordinate
{
	Width := 0
	Height := 0
	
	__New(x, y, width, height)
	{
		base.__New(x, y)
		
		this.Width  := width
		this.Height := height
	}
	
	Right
	{
		get
		{
			return this.X + this.Width
		}
	}
	
	Bottom
	{
		get
		{
			return this.Y + this.Height
		}
	}
	
	Description
	{
		get
		{
			return "Left: " . this.Left . ", Top: " . this.Top . ", Width: " . this.Width . ", Height: " . this.Height . ", Right: " . this.Right . ", Bottom: " . this.Bottom
		}
	}
}

Class Rectangle2 extends Coordinate
{
	Right := 0
	Bottom := 0
	
	__New(x, y, right, bottom)
	{
		base.__New(x, y)
		
		this.Right := right
		this.Bottom := bottom
	}
	
	Width
	{
		get
		{
			return this.Right - this.X
		}
	}
	
	Height
	{
		get
		{
			return this.Bottom - this.Y
		}
	}
	
	Description
	{
		get
		{
			return "Left: " . this.Left . ", Top: " . this.Top . ", Right: " . this.Right . ", Bottom: " . this.Bottom . ", Width: " . this.Width . ", Height: " . this.Height
		}
	}
}

Class Window extends Rectangle
{
	WindowHandle :=
	
	__New(windowHandle)
	{
		WinGetPos, left, top, width, height, ahk_id %windowHandle%
		
		base.__New(left, top, width, height)
		
		this.WindowHandle := windowHandle
	}
	
	Status
	{
		get
		{
			windowHandle := this.WindowHandle
			WinGet, status, MinMax, ahk_id %windowHandle%
			
			return status
		}
	}

	ProcessName
	{
		get
		{
			windowHandle := this.WindowHandle
			WinGet, name, ProcessName, ahk_id %windowHandle%
			
			return name
		}
	}
	
	ProcessPath
	{
		get
		{
			windowHandle := this.WindowHandle
			WinGet, path, ProcessPath, ahk_id %windowHandle%
			
			return path
		}
	}
	
	Title
	{
		get
		{
			windowHandle := this.WindowHandle
			WinGetTitle, title, ahk_id %windowHandle%
			
			return title
		}
	}
	
	MonitorIndex
	{
		get
		{
			monitorIndex := GetMonitorIndexAt(this.Left, this.Top)
			if (monitorIndex < 0)
			{
				midX := theWindowLeft + (theWindowWidth / 2)
				midY := theWindowTop + (theWindowHeight / 2)
				
				monitorIndex := GetMonitorIndexAt(midX, midY)
				if (monitorIndex < 0)
				{
					monitorIndex := GetMonitorIndexAt(theWindowRight, theWindowTop)
					if (monitorIndex < 0)
					{
						monitorIndex = GetMonitorIndexAt(theWindowRight, theWindowBottom)
						if (monitorIndex < 0)
						{
							SysGet, monitorIndex, MonitorPrimary
						}
					}
				}
			}
			
			return monitorIndex
		}
	}
	
	IsValid
	{
		get
		{
			return this.Width > 0 && this.Height > 0
		}
	}
	
	GetHitArea(hitHeight)
	{
		area := new Rectangle(this.Left + (this.Width / 2), this.Top, (this.Width / 2), hitHeight)
		
		return area
	}
	
	Description
	{
		get
		{
			return "Handle: " . this.WindowHandle . ", Left: " . this.Left . ", Top: " . this.Top . ", Width: " . this.Width . ", Height: " . this.Height . ", Right: " . this.Right . ", Bottom: " . this.Bottom . ", ProcessName: " . this.ProcessName . ", Title: " . this.Title
		}
	}
}

Class Monitor extends Rectangle2
{
	MonitorIndex := -1

	__New(index)
	{
		SysGet, mon, Monitor, %index%
		
		base.__New(monLeft, monTop, monRight, monBottom)
		
		this.MonitorIndex := index
	}
	
	WorkArea
	{
		get
		{
			index := this.MonitorIndex
			SysGet, area, MonitorWorkArea, %index%
			
			rect := new Rectangle2(areaLeft, areaTop, areaRight, areaBottom)
			
			return rect
		}
	}
	
	Description
	{
		get
		{
			return "MonitorIndex: " . this.MonitorIndex . ", " . base.Description
		}
	}
}
