@echo off
REM Script to manually extract Firebase C++ SDK for Windows
REM This script fixes the path issues in the original scripts

setlocal enabledelayedexpansion

set PROJECT_DIR=%CD%
set TEMP_DIR=%TEMP%\firebase_manual_extract
set SDK_ZIP=%TEMP%\firebase_cpp_sdk_windows_11.10.0.zip
set DEST_DIR=%PROJECT_DIR%\build\windows\extracted\firebase_cpp_sdk_windows

echo ========================================
echo Firebase C++ SDK Manual Extraction
echo ========================================
echo.
echo Project Directory: %PROJECT_DIR%
echo Temporary Directory: %TEMP_DIR%
echo SDK Zip File: %SDK_ZIP%
echo Destination Directory: %DEST_DIR%
echo.

REM Step 1: Check if the zip file exists
echo [Step 1/4] Checking for existing zip file...
if exist "%SDK_ZIP%" (
    echo Found existing zip file: %SDK_ZIP%
    for %%I in ("%SDK_ZIP%") do set SIZE=%%~zI
    set /a SIZE_MB=!SIZE! / 1048576
    echo File size: !SIZE_MB! MB

    if !SIZE_MB! LSS 10 (
        echo Warning: Downloaded file seems too small. It might be corrupted.
        set /p CONTINUE="Do you want to continue? (Y/N): "
        if /i not "!CONTINUE!"=="Y" (
            echo Exiting...
            pause
            exit /b 1
        )
    )
) else (
    echo Error: Zip file not found: %SDK_ZIP%
    echo.
    echo Please download the Firebase C++ SDK from:
    echo https://dl.google.com/firebase/sdk/cpp/firebase_cpp_sdk_windows_11.10.0.zip
    echo.
    echo And save it to: %SDK_ZIP%
    echo.
    echo Or run download_and_extract_firebase.bat to download it automatically.
    pause
    exit /b 1
)

REM Step 2: Create temporary directory
echo.
echo [Step 2/4] Creating temporary directory...
if exist "%TEMP_DIR%" (
    echo Removing existing temporary directory...
    rmdir /s /q "%TEMP_DIR%"
)
mkdir "%TEMP_DIR%"
echo Temporary directory created: %TEMP_DIR%

REM Step 3: Extract the zip file
echo.
echo [Step 3/4] Extracting zip file...
echo Using PowerShell Expand-Archive...
powershell -Command "& {Expand-Archive -Path '%SDK_ZIP%' -DestinationPath '%TEMP_DIR%' -Force}"

if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to extract zip file
    pause
    exit /b 1
)

REM List the extracted files
echo.
echo Extracted files:
dir /s /b "%TEMP_DIR%"
echo.

REM Step 4: Copy to destination directory
echo.
echo [Step 4/4] Copying to destination directory...
if exist "%DEST_DIR%" (
    echo Removing existing destination directory...
    rmdir /s /q "%DEST_DIR%"
)
mkdir "%DEST_DIR%"

REM Find the firebase_cpp_sdk_windows directory and copy its contents
for /d %%D in ("%TEMP_DIR%\firebase_cpp_sdk_windows*") do (
    echo Found source directory: %%D
    echo Copying to: %DEST_DIR%
    xcopy /E /I /Y "%%D\*" "%DEST_DIR%"

    if %ERRORLEVEL% NEQ 0 (
        echo Error: Failed to copy files
        pause
        exit /b 1
    )
)

REM Verification
echo.
echo ========================================
echo Verifying Installation
echo ========================================
echo.

if exist "%DEST_DIR%\CMakeLists.txt" (
    echo [OK] CMakeLists.txt found!
) else (
    echo [WARNING] CMakeLists.txt not found in the SDK directory
)

if exist "%DEST_DIR%\include\firebase\app.h" (
    echo [OK] Firebase header files found!
) else (
    echo [WARNING] Firebase header files not found
)

if exist "%DEST_DIR%\libs\windows\VS2019\MD\x64\Release" (
    echo [OK] MD Release libraries directory found!
    dir "%DEST_DIR%\libs\windows\VS2019\MD\x64\Release"
) else (
    echo [WARNING] MD Release libraries directory not found
    echo Expected path: %DEST_DIR%\libs\windows\VS2019\MD\x64\Release
)

if exist "%DEST_DIR%\libs\windows\VS2019\MD\x64\Debug" (
    echo [OK] MD Debug libraries directory found!
    dir "%DEST_DIR%\libs\windows\VS2019\MD\x64\Debug"
) else (
    echo [WARNING] MD Debug libraries directory not found
    echo Expected path: %DEST_DIR%\libs\windows\VS2019\MD\x64\Debug
)

echo.
echo ========================================
echo Extraction Complete!
echo ========================================
echo.
echo SDK Location: %DEST_DIR%
echo.
echo To permanently set the FIREBASE_CPP_SDK_DIR environment variable, run:
echo setx FIREBASE_CPP_SDK_DIR "%DEST_DIR%"
echo.
pause
