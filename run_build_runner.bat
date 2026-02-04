@echo off
set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "FLUTTER_DIR=C:\Users\Ahmed Mekawi\flutter"
set "PUB_CACHE_DIR=C:\Users\Ahmed Mekawi\AppData\Local\Pub\Cache"
set "FLUTTER_DRIVE=Y:"
set "PROJECT_DRIVE=Z:"
set "PUB_CACHE_DRIVE=X:"

if exist %FLUTTER_DRIVE%\ subst %FLUTTER_DRIVE% /D >nul 2>&1
if exist %PROJECT_DRIVE%\ subst %PROJECT_DRIVE% /D >nul 2>&1
if exist %PUB_CACHE_DRIVE%\ subst %PUB_CACHE_DRIVE% /D >nul 2>&1

if exist "%FLUTTER_DIR%" (
    subst %FLUTTER_DRIVE% "%FLUTTER_DIR%"
) else (
    echo Flutter directory not found at %FLUTTER_DIR%.
    exit /b 1
)

if exist "%PUB_CACHE_DIR%" (
    subst %PUB_CACHE_DRIVE% "%PUB_CACHE_DIR%"
) else (
    echo Pub Cache directory not found at %PUB_CACHE_DIR%.
    exit /b 1
)

subst %PROJECT_DRIVE% "%PROJECT_DIR%"

set "OLDPATH=%PATH%"
set "PATH=%FLUTTER_DRIVE%\bin;%PATH%"
set "PUB_CACHE=%PUB_CACHE_DRIVE%"

pushd %PROJECT_DRIVE%\
echo Running build_runner on %PROJECT_DRIVE%...
call flutter pub get
call dart run build_runner build --delete-conflicting-outputs
set "EXIT_CODE=%ERRORLEVEL%"
popd

subst %FLUTTER_DRIVE% /D >nul 2>&1
subst %PROJECT_DRIVE% /D >nul 2>&1
subst %PUB_CACHE_DRIVE% /D >nul 2>&1

exit /b %EXIT_CODE%
