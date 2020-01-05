#define AppName "WindowExtensions"
#define AppTitle "Window Extensions"
#define AppVersion "1.6.2"

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
AppCopyright=Copyright © 2020 Martin Smith
DefaultDirName={commonpf}\DNXSolutions\{#AppName}
OutputDir=.
OutputBaseFilename={#AppName}_Install_v{#AppVersion}
AppendDefaultDirName=False
DisableProgramGroupPage=yes
PrivilegesRequired=lowest

[Files]
Source: "..\{#AppName}.exe"; DestDir: "{app}"
Source: "..\{#AppName}.icl"; DestDir: "{app}"

[Icons]
Name: "{userstartup}\{#AppTitle}"; Filename: "{app}\{#AppName}.exe"; Flags: excludefromshowinnewinstall; Tasks: startup

[Tasks]
Name: "startup"; Description: "Automatically start on login"; GroupDescription: "{cm:AdditionalIcons}"

[Run]
Filename: "{app}\{#AppName}.exe"; Flags: postinstall skipifdoesntexist nowait runascurrentuser; Description: "Run {#AppTitle} now ?"
