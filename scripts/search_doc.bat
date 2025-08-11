@echo off
echo ===============================================
echo GPT-OSS Docker - Document Search Tool
echo ===============================================

:input
set /p query="Enter search query: "
if "%query%"=="" goto input

echo.
echo Searching for: "%query%"
echo Please wait...

curl -X POST "http://localhost:8001/search?query=%query%&limit=5" 2>nul

if %ERRORLEVEL% equ 0 (
    echo.
    echo [OK] Search completed successfully!
) else (
    echo.
    echo [X] Search failed. Please check:
    echo    - RAG services are running
    echo    - Try running: scripts\start.bat
)

echo.
echo Press any key to continue...
pause >nul