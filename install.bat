@echo off
setlocal

REM Keep as const values for updater script to parse

set "JAVA_URL=https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.zip"
set "JAVA_PATH=bin\java.exe"

REM Defined externally
set "RELEASE_ID="
set "JAR_URL="

:: Install

set "caller_dir=%cd%"

set "app_dir=%LOCALAPPDATA%\notarb"
mkdir "%app_dir%" 2>nul
cd /d "%app_dir%"

echo %cd%

echo.
echo Downloading Java...
echo %JAVA_URL%

rmdir /s /q "java" 2>nul

mkdir java

cd java

set "temp_jdk_archive=java_archive_%RANDOM%.zip"

curl -Lo "%temp_jdk_archive%" "%JAVA_URL%"
if %ERRORLEVEL% neq 0 (
    echo.
    echo Failed to download Java!
    exit /b 1
)

for /f "tokens=1 delims=/" %%i in ('tar -tf "%temp_jdk_archive%" ^| findstr /r "^jdk"') do (
    set "jdk_folder_name=%%i"
    goto :found
)
:found

tar -xf "%temp_jdk_archive%"
if %ERRORLEVEL% neq 0 (
    echo.
    echo Failed to extract Java archive!
    exit /b 1
)

move /y "%temp_jdk_archive%" "%jdk_folder_name%.tmp" >nul

cd ..

echo.
echo Downloading NotArb...
echo %JAR_URL%

del /f /q .notarb-*.jar 2>nul

set "jar_file=.notarb-%RELEASE_ID%.jar"

curl -Lo "%jar_file%" "%JAR_URL%"
if %ERRORLEVEL% neq 0 (
    echo.
    echo Failed to download NotArb!
    exit /b 1
)

echo.

:: TODO change org. to com. after upgrade
"java\%jdk_folder_name%\%JAVA_PATH%" -cp "%jar_file%" org.notarb.Main finish-install "%caller_dir%" "%cd%" "%jdk_folder_name%" "%JAVA_PATH%" "%jar_file%"