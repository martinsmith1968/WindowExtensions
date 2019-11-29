; From : https://www.autohotkey.com/boards/viewtopic.php?t=6056
/*
#SingleInstance force
#NoEnv

new PleasantNotify("PleasantNotify", "Permanent" , 600, 210, "t r", "P")

new PleasantNotify("PleasantNotify", "position vc hc, 3 seconds" , 600, 210, "vc hc", 6)
;Sleep, 3000
;pn_mod_title("you can change titles")
;pn_mod_msg("Also messages")
;Sleep, 3000
new PleasantNotify("PleasantNotify", "position t hc" , 600, 210, "t hc", 3)
new PleasantNotify("PleasantNotify", "position b hc" , 600, 210, "b hc", 3)
;Sleep, 3000
new PleasantNotify("PleasantNotify", "position default, b r" , 600, 210, "b r", 3)
new PleasantNotify("PleasantNotify", "position b l" , 600, 210, "b l", 3)
new PleasantNotify("PleasantNotify", "position t l" , 600, 210, "t l", 3)
new PleasantNotify("PleasantNotify", "position t r" , 600, 210, "t r", 3)
return
*/

Class PleasantNotify {
	__New(title
			,message
			,pnW=700
			,pnH=300
			,position="b r"
			,time=5
			,backgroundColor="0xC0C0C0"
			,titleFontName="Segoe UI"
			,titleFontDetails="cBlue s16 wBold"
			,textFontName="Segoe UI"
			,textFontDetails="cBlack s12 wRegular") {
		Critical
		lastfound := WinExist()
		
		Gui, New, % "HwndPN_hwnd"
		this.PN_hwnd := PN_hwnd
		Gui, % PN_hwnd ": Default"
		Gui, % PN_hwnd ": +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound"
		;WinSet, ExStyle, +0x20
		WinSet, Transparent, 0
		Gui, % PN_hwnd ": Color", % backgroundColor
		Gui, % PN_hwnd ": Font", % titleFontDetails, % titleFontName
		Gui, % PN_hwnd ": Add", Text, % " x" 20 " y" 12 " w" pnW-20 " hwndTitleHwnd", % title
		this.TitleHwnd := TitleHwnd
		Gui, % PN_hwnd ": Font", % textFontDetails, % textFontName
		Gui, % PN_hwnd ": Add", Text, % " x" 20 " y" 56 " w" pnW-20 " h" pnH-56 " hwndMessageHwnd", % message
		if (time = "P"){
			Gui, % PN_hwnd ": Add", Button, % " x" pnW - 80 " y" pnH - 50 " w50 h25 ", OK
			; When OK is clicked, call this instance of the class
			fn := bind("_NotifyOK", this)
			GuiControl +g, OK, %fn%
		}
		this.MessageHwnd := MessageHwnd
		RealW := pnW + 50
		RealH := pnH + 20
		Gui, % PN_hwnd ": Show", W%RealW% H%RealH% NoActivate
		this.WinMove(PN_hwnd, position)
		;Gui, % PN_Hwnd ": +Parent" A_ScriptHwnd
		if A_ScreenDPI = 96
			WinSet, Region,0-0 w%pnW% h%pnH% R40-40,%A_ScriptName%
		/* For Screen text size 125%
		if A_ScreenDPI = 120
			WinSet, Region, 0-0 w800 h230 R40-40, %A_ScriptName%
		*/
		Critical Off
		this.winfade("ahk_id " PN_hwnd,210,5)
		if (time != "P")
		{
			; Bind this class to the timer.
			fn := bind("_NotifyTimer", this)
			SetTimer %fn%, % time * -1000
		}
		
		if (WinExist(lastfound)){
			Gui, % lastfound ":Default"
		}
	}
	
	__Delete(){
		this.Destroy()
	}
	
	TimerExpired(){
		this.winfade("ahk_id " this.PN_hwnd,0,5)
		Gui, % this.PN_hwnd ": Destroy"
	}
	
	OKClicked(){
		this.Destroy()
	}
	
	Destroy(){
		this.winfade("ahk_id " PN_hwnd,0,5)
		try
		{
			Gui, % this.PN_hwnd ": Destroy"
		}
		catch e
		{
		}
	}

	WinMove(hwnd,position) {
	   SysGet, Mon, MonitorWorkArea
	   WinGetPos,ix,iy,w,h, ahk_id %hwnd%
	   x := InStr(position,"l") ? MonLeft : InStr(position,"hc") ?  (MonRight-w)/2 : InStr(position,"r") ? MonRight - w : ix
	   y := InStr(position,"t") ? MonTop : InStr(position,"vc") ?  (MonBottom-h)/2 : InStr(position,"b") ? MonBottom - h : iy
	   WinMove, ahk_id %hwnd%,,x,y
	}

	winfade(w:="",t:=128,i:=1,d:=10) {
		w:=(w="")?("ahk_id " WinActive("A")):w
		t:=(t>255)?255:(t<0)?0:t
		WinGet,s,Transparent,%w%
		s:=(s="")?255:s ;prevent trans unset bug
		WinSet,Transparent,%s%,%w%
		i:=(s<t)?abs(i):-1*abs(i)
		while(k:=(i<0)?(s>t):(s<t)&&WinExist(w)) {
			WinGet,s,Transparent,%w%
			s+=i
			WinSet,Transparent,%s%,%w%
			sleep %d%
		}
	}

}

; Obj is the instance of the class that the timer expired on.
_NotifyTimer(obj){
	obj.TimerExpired()
}

; Obj is the instance of the class that OK was clicked in.
_NotifyOK(obj){
	obj.OKClicked()
}

pn_mod_title(title) {
    global pn_title
    GuiControl, Notify: Text,pn_title, % title
}

pn_mod_msg(message) {
    global pn_msg
    GuiControl, Notify: Text,pn_msg, % message
}

; bind v1.1 by Lexikos
; Requires test build of AHK? Will soon become part of AHK
; See http://ahkscript.org/boards/viewtopic.php?f=24&t=5802
bind(fn, args*) {
    try bound := fn.bind(args*)  ; Func.Bind() not yet implemented.
    return bound ? bound : new BoundFunc(fn, args*)
}

class BoundFunc {
    __New(fn, args*) {
        this.fn := IsObject(fn) ? fn : Func(fn)
        this.args := args
    }
    __Call(callee) {
        if (callee = "" || callee = "call" || IsObject(callee)) {  ; IsObject allows use as a method.
            fn := this.fn
            return %fn%(this.args*)
        }
    }
}
