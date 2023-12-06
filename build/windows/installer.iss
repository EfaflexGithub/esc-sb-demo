; -- 64Bit.iss --
; Demonstrates installation of a program built for the x64 (a.k.a. AMD64)
; architecture.
; To successfully run this installation and the program it installs,
; you must have a "x64" edition of Windows.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

[Setup]
PrivilegesRequired=lowest
AppName=EFAFLEX SmartBuilding Demo
AppVersion=1.0.0
WizardStyle=modern
; LicenseFile=..\..\LICENSE.md
DefaultDirName={autopf}\EFAFLEX SmartBuilding Demo
DefaultGroupName=EFAFLEX SmartBuilding Demo
UninstallDisplayIcon={app}\efa_smartconnect_modbus_demo.exe
Compression=lzma2
SolidCompression=yes
OutputDir=installer
OutputBaseFilename=EfaflexSmartBuildingUserSetup-x64-{#SetupSetting("AppVersion")}
; "ArchitecturesAllowed=x64" specifies that Setup cannot run on
; anything but x64.
ArchitecturesAllowed=x64
; "ArchitecturesInstallIn64BitMode=x64" requests that the install be
; done in "64-bit mode" on x64, meaning it should use the native
; 64-bit Program Files directory and the 64-bit view of the registry.
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\EFAFLEX SmartBuilding Demo"; Filename: "{app}\efa_smartconnect_modbus_demo.exe"
