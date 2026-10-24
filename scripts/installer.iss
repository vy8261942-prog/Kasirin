; ============================================================
; Inno Setup script — POS Retail (AnjayRetailSoft)
; Compiled with: ISCC.exe
; Build entry: python scripts/build_installer.py
; ============================================================

; Provide defaults so the script also compiles standalone.
; The build script overrides these via /D defines (AppVersion, SourceDir, OutputDir).
#ifndef AppVersion
#define AppVersion "0.5.0"
#endif
#ifndef SourceDir
#define SourceDir "dist\POS"
#endif
#ifndef OutputDir
#define OutputDir "build\installer"
#endif

[Setup]
AppName=Kasirin
AppVersion={#AppVersion}
AppPublisher=AnjaySoft Dev
AppPublisherURL=
AppSupportURL=
AppUpdatesURL=
DefaultDirName={commonpf}\Kasirin
DefaultGroupName=Kasirin
AllowNoIcons=yes
LicenseFile=
OutputDir={#OutputDir}
OutputBaseFilename=Kasirin
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=commandline dialog
UninstallDisplayIcon={app}\POS.exe
ChangesAssociations=no
SetupIconFile=
UninstallIconFile={app}\POS.exe
MinVersion=6.1
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

[Dirs]
Name: "{app}"; Permissions: users-full

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Kasirin"; Filename: "{app}\POS.exe"
Name: "{group}\Uninstall Kasirin"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\POS.exe"; Description: "{cm:LaunchProgram,Kasirin}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{sys}\taskkill.exe"; Parameters: "/IM POS.exe /F"; Flags: runascurrentuser; RunOnceId: "TerminatePOS"

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;

