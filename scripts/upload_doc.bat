@echo off
echo ===============================================
echo GPT-OSS Docker - Document Upload Tool
echo ===============================================

:input
set /p filepath="Enter file path to upload: "
if "%filepath%"=="" goto input

echo.
echo Uploading document: %filepath%
echo Please wait...

curl -X POST "http://localhost:8001/upload" -F "file=@%filepath%" 2>nul

if %ERRORLEVEL% equ 0 (
    echo.
    echo [OK] Upload completed successfully!
) else (
    echo.
    echo [X] Upload failed. Please check:
    echo    - File path is correct
    echo    - RAG services are running
    echo    - Try running: scripts\start.bat
)

echo.
echo Press any key to continue...
pause >nul