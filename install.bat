@echo off
setlocal

set "JAVA_URL=https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.zip"

REM Fetch latest release (assumes single .jar asset)
for /f "tokens=1,* delims=|" %%a in ('powershell -NoProfile -Command "$r = Invoke-RestMethod 'https://api.github.com/repos/NotArb/Release/releases/latest'; $jar = ($r.assets | Where-Object { $_.name -like '*.jar' }); Write-Output \"$($jar.name)|$($jar.browser_download_url)\""') do (
    set "JAR_NAME=%%a"
    set "JAR_URL=%%b"
)

if "%JAR_URL%"=="" (
    echo Failed to fetch latest release!
    exit /b 1
)

:: Install

set "caller_dir=%cd%"

set "notarb_home=%LOCALAPPDATA%\notarb"
mkdir "%notarb_home%" 2>nul
cd /d "%notarb_home%"

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

set "java_home=%cd%\%jdk_folder_name%"

cd ..

echo.
echo Downloading NotArb...
echo %JAR_URL%

del /f /q .notarb-*.jar 2>nul

set "jar_file=.%JAR_NAME%"

curl -Lo "%jar_file%" "%JAR_URL%"
if %ERRORLEVEL% neq 0 (
    echo.
    echo Failed to download NotArb!
    exit /b 1
)

echo.

cd "%caller_dir%"

"%java_home%\bin\java.exe" -cp "%notarb_home%\%jar_file%" com.notarb.Main finish-install