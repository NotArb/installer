@echo off
setlocal

REM Keep as const values for updater script to parse

set "JAVA_URL=https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.zip"
set "JAVA_PATH=bin\java.exe"

set "JAR_URL=" REM defined externally

:: Install

set "CALLER_DIR=%cd%"

set "APP_DIR=%LOCALAPPDATA%\notarb"
mkdir "%APP_DIR%" 2>nul
cd /d "%APP_DIR%"

echo %cd%

echo.
echo Downloading Java...
echo %JAVA_URL%

set "TEMP_JAVA_ARCHIVE=java_archive_%RANDOM%.zip"

curl -Lo "%TEMP_JAVA_ARCHIVE%" "%JAVA_URL%"
if %ERRORLEVEL% neq 0 (
    echo.
    echo Failed to download Java!
    exit /b 1
)

for /f "tokens=1 delims=/" %%i in ('tar -tf "%TEMP_JAVA_ARCHIVE%" ^| findstr /r "^jdk"') do (
    set "JAVA_FOLDER=%%i"
    goto :found
)
:found

rmdir /s /q "%JAVA_FOLDER%" 2>nul

tar -xf "%TEMP_JAVA_ARCHIVE%"
if %ERRORLEVEL% neq 0 (
    echo.
    echo Failed to extract Java archive!
    exit /b 1
)

move /y "%TEMP_JAVA_ARCHIVE%" "%JAVA_FOLDER%.tmp" >nul

echo.
echo Downloading NotArb...
echo %JAR_URL%

del /f "notarb.jar" 2>nul

curl -Lo "notarb.jar" "%JAR_URL%"
if %ERRORLEVEL% neq 0 (
    echo.
    echo Failed to download NotArb!
    exit /b 1
)

echo.

:: TODO change org. to com. after upgrade
"%JAVA_FOLDER%\%JAVA_PATH%" -cp notarb.jar org.notarb.Main finish-install "%CALLER_DIR%" "%cd%" %JAVA_FOLDER%" "%JAVA_PATH%"