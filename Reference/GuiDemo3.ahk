return

#q::
myGui()
return

myGui()
{
	static thisVar, thatVar
	gui, SomeGuiName: new
	gui,Default
	gui,+LastFound
	gui, add, groupbox, w250 h130,example
	gui, add, text, xm12 ym30 section, this Label
	gui, add, text, xm12 yp+30, that label
	gui, add, button, yp+30 gDone, Ok
	gui, add, edit, ys ym30 vthisVar,
	gui, add, edit, yp+30  vthatVar,
	gui, add, button, yp+30  gguiclose, cancel
	gui, show,, gui in a function

	return winexist()

	Done:
	{
		gui,submit,nohide
		ListVars
		msgbox your values `nthisVar :%thisVar%`nthatVar :%thatVar%
		gui,destroy
		return
	}

	guiclose:
	{
		gui,destroy
		ExitApp
		return
	}
}
