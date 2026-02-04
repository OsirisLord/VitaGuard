@echo off
set "PROJECT_DIR=%~dp0"
:: Remove trailing backslash if present (dp0 usually has it)
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

:: Hardcoded assumption based on error logs, can be adjusted or dynamic
set "FLUTTER_DIR=C:\Users\Ahmed Mekawi\flutter"
set "FLUTTER_DRIVE=Y:"
set "PROJECT_DRIVE=Z:"

:: Cleanup prev mounts if any
if exist %FLUTTER_DRIVE%\ subst %FLUTTER_DRIVE% /D >nul 2>&1
if exist %PROJECT_DRIVE%\ subst %PROJECT_DRIVE% /D >nul 2>&1

:: Subst Flutter
if exist "%FLUTTER_DIR%" (
    subst %FLUTTER_DRIVE% "%FLUTTER_DIR%"
) else (
    echo Flutter directory not found at %FLUTTER_DIR%. Cannot apply workaround.
    exit /b 1
)

:: Subst Project
subst %PROJECT_DRIVE% "%PROJECT_DIR%"

if not exist %FLUTTER_DRIVE%\ (
    echo Failed to mount Flutter drive.
    exit /b 1
)

if not exist %PROJECT_DRIVE%\ (
    echo Failed to mount Project drive.
    exit /b 1
)

:: Update PATH to prefer Y:\bin
set "OLDPATH=%PATH%"
set "PATH=%FLUTTER_DRIVE%\bin;%PATH%"

:: Run tests
pushd %PROJECT_DRIVE%\
echo Running tests on %PROJECT_DRIVE% with Flutter from %FLUTTER_DRIVE%...
:: Verify flutter path
where flutter

call flutter test
set "EXIT_CODE=%ERRORLEVEL%"
popd

:: Cleanup
subst %FLUTTER_DRIVE% /D >nul 2>&1
subst %PROJECT_DRIVE% /D >nul 2>&1

exit /b %EXIT_CODE%
