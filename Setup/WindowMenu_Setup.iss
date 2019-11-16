[Setup]
AppName=WindowMenu
AppVersion=1.0
AppCopyright=Copyright © 2016 DNX Solutions Ltd
DefaultDirName={pf}\DNXSolutions\WindowMenu
OutputDir=.
OutputBaseFilename=WindowMenu_Setup
AppendDefaultDirName=False
DisableProgramGroupPage=yes

[Files]
Source: "..\WindowMenu.exe"; DestDir: "{app}"
Source: "..\WindowMenu.icl"; DestDir: "{app}"

[Icons]
Name: "{userstartup}\WindowMenu"; Filename: "{app}\WindowMenu.exe"; Flags: excludefromshowinnewinstall; Tasks: startup

[Tasks]
Name: startup; Description: "Automatically start on login"; GroupDescription: "{cm:AdditionalIcons}"
