@echo off
setlocal EnableDelayedExpansion

rem ----------------------------------------------------------------------------
rem Activates the MSVC x64 toolchain in this cmd session via vswhere, then
rem executes whatever arguments follow. VS Code invokes this from tasks that
rem need cl.exe / link.exe (i.e. all the build-*.bat wrappers).
rem ----------------------------------------------------------------------------

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo [msvc-env] vswhere.exe not found at "%VSWHERE%".
    echo [msvc-env] Install Visual Studio 2019+ or VS Build Tools.
    exit /b 1
)

set "VSINSTALL="
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSINSTALL=%%i"
if "%VSINSTALL%"=="" (
    echo [msvc-env] No VS installation with the x64 C++ toolset found.
    exit /b 1
)

call "%VSINSTALL%\VC\Auxiliary\Build\vcvarsall.bat" x64
if errorlevel 1 (
    echo [msvc-env] vcvarsall.bat x64 failed.
    exit /b 1
)

rem Run whatever the caller passed as arguments. Use cmd /c so chained
rem commands and &&/|| work naturally.
cmd /c %*
exit /b %ERRORLEVEL%
