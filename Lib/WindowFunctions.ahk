#Include Lib\Logging.ahk
#Include Lib\WindowObjects.ahk

G_RollupList := Object()

;--------------------------------------------------------------------------------
; MoveAndSizeWindow - Set the Window position and size
MoveAndSizeWindow(theWindow, winLeft, winTop, winWidth, winHeight)
{
	windowHandle := theWindow.WindowHandle
	
    LogText("Window: " . theWindow.ProcessName . " (" . windowHandle . ") Left: " . winLeft . ", Top: " . winTop . ", Width: " . winWidth . ", Height: " . winHeight)

	WinMove , ahk_id %windowHandle%, , winLeft, winTop, winWidth, winHeight
	WinActivate, ahk_id %windowHandle%
    WinShow, ahk_id %windowHandle%
}

;--------------------------------------------------------------------------------
; MoveAndSizeWindow - Set the Window position
MoveWindow(theWindow, winLeft, winTop)
{
	windowHandle := theWindow.WindowHandle
	
	WinGet, theProcess, ProcessName, ahk_id %theWindow%
    LogText("Window: " . theWindow.ProcessName . " (" . windowHandle . ") Left: " . winLeft . ", Top: " . winTop)

	WinMove , ahk_id %windowHandle%, , winLeft, winTop
	WinActivate, ahk_id %windowHandle%
	WinShow, ahk_id %windowHandle%
}

;--------------------------------------------------------------------------------
; SetWindowStatus - Set the Window Minimized / Maximized status
SetWindowStatus(theWindow, status)
{
	windowHandle := theWindow.WindowHandle
	
	LogText("Window: " . theWindow.ProcessName . " (" . windowHandle . ") Status: " . status)
	If (status = 1)
	{
		WinMaximize, ahk_id %windowHandle%
	}
	else if (status = -1)
	{
		WinMinimize, ahk_id %windowHandle%
	}
	else
	{
		WinRestore , ahk_id %windowHandle%
	}
}

;--------------------------------------------------------------------------------
; SetWindowToCentre - Centre the window on its Monitor
SetWindowToCentre(theWindow)
{
	monitor := new Monitor(theWindow.MonitorIndex)
	monitorWorkArea := monitor.WorkArea
	
	winLeft := monitorWorkArea.Left + (monitorWorkArea.Width - theWindow.Width) / 2
	winTop  := monitorWorkArea.Top + (monitorWorkArea.Height- theWindow.Height) / 2

	MoveWindow(theWindow, winLeft, winTop)
}

;--------------------------------------------------------------------------------
; SetWindowTop - Set the Window TopMost setting
SetWindowTop(theWindow, top)
{
	windowHandle := theWindow.WindowHandle
	
	if (top = 1)
		WinSet, AlwaysOnTop, On, ahk_id %windowHandle%
	else if (top = 0)
		WinSet, AlwaysOnTop, Off, ahk_id %windowHandle%
	else
		WinSet, AlwaysOnTop, Toggle, ahk_id %windowHandle%
}

;--------------------------------------------------------------------------------
; SetWindowTransparency - Set the Window Transparency setting
SetWindowTransparency(theWindow, transparency)
{
	windowHandle := theWindow.WindowHandle
	
	WinSet, Transparent, transparency, ahk_id %windowHandle%
}

;--------------------------------------------------------------------------------
; SetWindowByGutter - Set the Window position including a gutter
SetWindowByGutter(theWindow, gutterSize)
{
	LogText("gutterSize: " . gutterSize)
	
	monitor := new Monitor(theWindow.MonitorIndex)
	monitorWorkArea := monitor.WorkArea

	winLeft   := monitorWorkArea.Left + gutterSize
	winTop    := monitorWorkArea.Top + gutterSize
	winWidth  := monitorWorkArea.Width - (gutterSize * 2)
	winHeight := monitorWorkArea.Height - (gutterSize * 2)
	
	MoveAndSizeWindow(theWindow, winLeft, winTop, winWidth, winHeight)
}

;--------------------------------------------------------------------------------
; SetWindowByColumn - Set the Window position by column, including a gutter
SetWindowByColumn(theWindow, column, maxColumns, gutterSize = 0)
{
	SetWindowByGrid(theWindow, 1, column, 1, maxColumns, gutterSize)
}

;--------------------------------------------------------------------------------
; SetWindowByRow - Set the Window position by row, including a gutter
SetWindowByRow(theWindow, row, maxRows, gutterSize = 0)
{
	SetWindowByGrid(theWindow, row, 1, maxRows, 1, gutterSize)
}

;--------------------------------------------------------------------------------
; SetWindowByGutter - Set the Window position by column, including a gutter
SetWindowByGrid(theWindow, row, column, maxRows, maxColumns, gutterSize = 0)
{
	LogText("Row: " . row . " / " . maxRows . ", Column: " . column . " / " . maxColumns . ", gutterSize: " . gutterSize)
	
	monitor := new Monitor(theWindow.MonitorIndex)
	monitorWorkArea := monitor.WorkArea

	columnWidth := (monitorWorkArea.Width - (gutterSize * 2)) / maxColumns
	columnLeft  := monitorWorkArea.Left + (columnWidth * (column - 1)) + gutterSize

	rowHeight   := (monitorWorkArea.Height - (gutterSize * 2)) / maxRows
	rowTop      := monitorWorkArea.Top + (rowHeight * (row - 1)) + gutterSize

	MoveAndSizeWindow(theWindow, columnLeft, rowTop, columnWidth, rowHeight)
}

;--------------------------------------------------------------------------------
; SetWindowByGutter - Set the Window position by column, including a gutter
SetWindowSpanMonitors(theWindow, alignLeft, alignTop, alignRight, alignBottom, gutterSize = 0)
{
	windowSpan := new Rectangle2(alignLeft, alignTop, alignRight, alignBottom)
	
	SysGet, monitorCount, MonitorCount
	
	Loop, %monitorCount%
	{
		; Get Monitor Details
		monitor := new Monitor(A_Index)
		monitorWorkArea := monitor.WorkArea
		
		if alignLeft =
		{
			if (windowSpan.Left = "" || monitorWorkArea.Left < windowSpan.Left)
			{
				windowSpan.Left := monitorWorkArea.Left
			}
		}
		
		if alignRight =
		{
			if (windowSpan.Right = "" || monitorWorkArea.Right > windowSpan.Right)
			{
				windowSpan.Right := monitorWorkArea.Right
			}
		}
		
		if alignTop =
		{
			if (windowSpan.Top = "" || monitorWorkArea.Top < windowSpan.Top)
			{
				windowSpan.Top := monitorWorkArea.Top
			}
		}

		if alignBottom =
		{
			if (windowSpan.Bottom = "" || monitorWorkArea.Bottom > windowSpan.Bottom)
			{
				windowSpan.Bottom := monitorWorkArea.Bottom
			}
		}		
		
		LogText("Span: " . windowSpan.Description)
	}

	MoveAndSizeWindow(theWindow, windowSpan.Left, windowSpan.Top, windowSpan.Width, windowSpan.Height)
}

;--------------------------------------------------------------------------------
; IsWindowTopMost - Detect if a window is set on top
IsWindowTopMost(windowHandle)
{
	WinGet, winStyle, ExStyle, ahk_id %windowHandle%
	if (winStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
	{
		return true
	}
	
	return false
}

;--------------------------------------------------------------------------------
; IsWindowVisible - Detect if a window is visible
IsWindowVisible(windowHandle)
{
	WinGet, Style, Style, ahk_id %windowHandle%
	Transform, result, BitAnd, %Style%, 0x10000000 ; 0x10000000 is WS_VISIBLE.
	
	return result <> 0
}

;--------------------------------------------------------------------------------
; GetWindowNormalPosition - Get the restored position of a window
GetWindowNormalPosition(windowHandle)
{
    VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", windowHandle, "uint", &wp)
	
    x := NumGet(wp, 28, "int")
    y := NumGet(wp, 32, "int")
    w := NumGet(wp, 36, "int") - x
    h := NumGet(wp, 40, "int") - y
	
	rect := new Rectangle(x, y, w, h)
	
	return rect
}

;--------------------------------------------------------------------------------
; GetDesktopSize - Get the size of the whole desktop surface, all monitors combined
GetDesktopSize()
{
    SysGet, monitorCount, MonitorCount
	
    desktopSize := new Rectangle2(0, 0)
    desktopSize.Right := 0
    desktopSize.Bottom := 0
    
	Loop, %monitorCount%
	{
		; Get Monitor Details
		monitor := new Monitor(A_Index)
        
        desktopSize.Left   := MinOf(monitor.Left, desktopSize.Left)
        desktopSize.Right  := MaxOf(monitor.Right, desktopSize.Right)
        desktopSize.Top    := MinOf(monitor.Top, desktopSize.Top)
        desktopSize.Bottom := MaxOf(monitor.Bottom, desktopSize.Bottom)
    }
    
    return desktopSize
}

;--------------------------------------------------------------------------------
; RollupToggleWindow - Roll up a window to just its title bar
RollupToggleWindow(theWindow, rollupHeight)
{
	global G_RollupList
	
	windowHandle := theWindow.WindowHandle
	
	for ruWindowId, ruHeight in G_RollupList
	{
		IfEqual, ruWindowId, %windowHandle%
		{
			WinMove, ahk_id %windowHandle%,,,,, %ruHeight%
			G_RollupList.Delete(windowHandle)
			return
		}
	}

	WinGetPos,,,, wsHeight, ahk_id %windowHandle%
	G_RollupList[windowHandle] := wsHeight

	WinMove, ahk_id %windowHandle%,,,,, %rollupHeight%
}

;--------------------------------------------------------------------------------
; RollupWindow - Roll up a window to just its title bar
RestoreRollupWindows()
{
	global G_RollupList
	
	Loop, Parse, G_RollupList, |
	{
		if A_LoopField =  ; First field in list is normally blank.
			continue      ; So skip it.
		StringTrimRight, ws_Height, ws_Window%A_LoopField%, 0
		WinMove, ahk_id %A_LoopField%,,,,, %ws_Height%
	}
}

;--------------------------------------------------------------------------------
; SendWindowToBack - Send a Window to the back of the zorder
SendWindowToBack(theWindow)
{
	windowHandle := theWindow.WindowHandle
	WinSet, Bottom, , ahk_id %windowHandle%`
}

;--------------------------------------------------------------------------------
; GetMonitorIndexAt - Get the index of the monitor containing the specified x and y co-ordinates. 
GetMonitorIndexAt(x, y, defaultMonitor = -1) 
{
	coordinate := new Coordinate(x, y)
	;LogText("GetMonitorIndexAt: " . coordinate.Description)
	
    SysGet, monitorCount, MonitorCount
	
    ; Iterate through all monitors.
    Loop, %monitorCount%
    {
		; Get Monitor details
		monitor := new Monitor(A_Index)
		;LogText("Monitor: " . monitor.Description)
		
		; Check if the coordinates are on this monitor.
        if (coordinate.IsInRectangle(monitor))
            return A_Index
    }

    return defaultMonitor
}

;--------------------------------------------------------------------------------
; FindCurrentWindowForProcessName - Find the first main window for the given process name
FindCurrentWindowForProcessName(processName)
{
    WinGet windows, List

    Loop %windows%
    {
        windowHandle := windows%A_Index%
        
        window := new Window(windowHandle)
        if (window.ProcessName = processName)
        {
            return window
        }
    }
    
    return
}
