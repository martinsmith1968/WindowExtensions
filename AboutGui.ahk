
BuildAboutGui()
{
    Global AppName, AppTitle, AppDescription, AppNotes, AppURL, AppVersion
    
    Gui, About:New, -SysMenu +OwnDialogs
    Gui, About:Add, Picture, x10 y10, %A_ScriptFullPath%
    Gui, About:Add, Text, x52 y10, %AppTitle% v%AppVersion%
    Gui, About:Add, Text, x52 y30, %AppDescription%
    Gui, About:Add, Text, x52 y50 h60 w280, %AppNotes%
    Gui, About:Add, Link, x52 y120, <a href="%AppURL%">%AppURL%</a>
    Gui, About:Add, Button, default x135 y150 w80, OK
}

DestroyAboutGui()
{
    Gui, About:Destroy
}

ShowAboutGui()
{
    Global AppName, AppTitle, AppDescription, AppNotes, AppURL, AppVersion
    
    BuildAboutGui()
    
    Gui, About:Show, w350 h180, About... %AppTitle%
}

AboutGuiEscape:
{
    DestroyAboutGui()
    return
}

AboutGuiClose:
{
    DestroyAboutGui()
    return
}

AboutButtonOK:
{
    DestroyAboutGui()
    return
}    
