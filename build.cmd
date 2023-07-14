@echo off
@setlocal enableextensions
@echo:

set ILC_EXE="%USERPROFILE%\.nuget\packages\runtime.win-x64.microsoft.dotnet.ilcompiler\7.0.9\tools\ilc.exe"

if not exist "%ILC_EXE%" (
   dotnet restore noruntime.csproj
)

for /f "usebackq tokens=*" %%a in (`call "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -prerelease -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
   set "VSINSTALLPATH=%%a"
)

if exist "%VSINSTALLPATH%\VC\Auxiliary\Build\vcvarsall.bat" (
   call "%VSINSTALLPATH%\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64
)

if exist "bin" ( rmdir /S /Q "bin" )
if exist "obj" ( rmdir /S /Q "obj" )
@del zerosharp.exe >nul 2>&1
@del zerosharp.cil >nul 2>&1
@del zerosharp.map >nul 2>&1
@del zerosharp.obj >nul 2>&1

"csc.exe" zerosharp.cs /DEBUG:FULL /DETERMINISTIC+ /DEFINE:WINDOWS /LANGVERSION:10 /NOCONFIG /NOSTDLIB /PATHMAP:"%cd%"=\ /RUNTIMEMETADATAVERSION:v4.0.30319 /UNSAFE /OUT:zerosharp.cil

"%ILC_EXE%" zerosharp.cil -g -o zerosharp.obj --systemmodule zerosharp --map zerosharp.map -O

"link.exe" zerosharp.obj /BREPRO /DEBUG:FULL /FILEALIGN:0x1000 /RELEASE /PDBALTPATH:zerosharp.exe /ENTRY:__managed__Main kernel32.lib /INCREMENTAL:NO /SUBSYSTEM:CONSOLE

:end
pause
