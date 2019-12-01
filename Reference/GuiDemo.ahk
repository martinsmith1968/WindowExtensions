;Gui, Add, ListBox, h100 multi vColorChoice, Red|Green|Blue|Black|White
;Gui, Show


; http://www.autohotkey.com/board/topic/90723-achieve-rainmeter-style-gui-via-gdip-library/?p=573445
Width := 210
Gui, +LastFound
WinSet, Transparent, 180
Gui, Color, 808080
Gui, Margin, 0, 0
Gui, Font, s11 cD0D0D0 Bold
Gui, Add, Progress, % "x-1 y-1 w" (Width+2) " h31 Background404040 Disabled hwndHPROG"
Control, ExStyle, -0x20000, , ahk_id %HPROG% ; propably only needed on Win XP
Gui, Add, Text, % "x0 y0 w" Width " h30 BackgroundTrans Center 0x200 gGuiMove vCaption", Example
Gui, Font, s8
Gui, Add, Text, x7 y+10 w196 r1 +0x4000 vTX1 gGeorge, George Harrison
Gui, Add, Text, x7 y+10 w196 r1 +0x4000 vTX2 gJohn, John Lennon
Gui, Add, Text, x7 y+10 w196 r1 +0x4000 vTX3 gPaul, Paul McCartney
Gui, Add, Text, x7 y+10 w196 r1 +0x4000 vTX4 gRingo, Ringo Starr
Gui, Add, Text, x7 y+10 w196 r1 +0x4000 vTX5 gClose, Close
Gui, Add, Text, x7 y+10 w196 h5 vP
GuiControlGet, P, Pos
H := PY + PH
;Gui, -Caption
WinSet, Region, 0-0 w%Width% h%H% r6-6
Gui, Show, % "w" Width " NA" " x" (A_ScreenWidth - Width) " y150"
WinSet AlwaysOnTop
return

GuiMove:
   PostMessage, 0xA1, 2
return

George:
MsgBox, You clicked George (%A_GuiControl%).
return

John:
MsgBox, You clicked John (%A_GuiControl%).
return

Paul:
MsgBox, You clicked Paul (%A_GuiControl%).
return

Ringo:
MsgBox, You clicked Ringo (%A_GuiControl%).
return

Close:
ExitApp
