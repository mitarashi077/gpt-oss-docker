@echo off
echo ========================================
echo GPT-OSS Docker Easy Start
echo ========================================

echo.
echo [1] Checking Docker Desktop status...
docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker Desktop is already running
    goto :start_environment
)

echo [!] Docker Desktop is not running
echo.

echo [2] Attempting to start Docker Desktop...
echo.

REM Check common Docker Desktop installation paths
set "DOCKER_PATH="
if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    set "DOCKER_PATH=C:\Program Files\Docker\Docker\Docker Desktop.exe"
) else if exist "%USERPROFILE%\AppData\Local\Docker\Docker Desktop.exe" (
    set "DOCKER_PATH=%USERPROFILE%\AppData\Local\Docker\Docker Desktop.exe"
) else if exist "C:\Users\%USERNAME%\AppData\Local\Docker\Docker Desktop.exe" (
    set "DOCKER_PATH=C:\Users\%USERNAME%\AppData\Local\Docker\Docker Desktop.exe"
)

if "%DOCKER_PATH%"=="" (
    echo [X] Docker Desktop not found
    echo.
    echo Please start Docker Desktop manually:
    echo 1. Search "Docker Desktop" in Start Menu
    echo 2. Start Docker Desktop
    echo 3. Wait for system tray icon to turn green
    echo 4. Run this script again
    echo.
    echo Manual startup steps:
    echo 1. Start Docker Desktop
    echo 2. Wait for system tray icon (2-3 minutes)
    echo 3. Run this script again
    echo.
    pause
    exit /b 1
)

echo Starting Docker Desktop: "%DOCKER_PATH%"
start "" "%DOCKER_PATH%"

echo.
echo Waiting for Docker Desktop to start...
echo (First-time startup may take 3-5 minutes)
echo.

REM Wait for Docker Desktop to start (max 180 seconds)
set /a counter=0
set /a max_wait=180

:wait_loop
timeout /t 5 /nobreak >nul
docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker Desktop started successfully!
    goto :start_environment
)

set /a counter=%counter%+5
if %counter% lss %max_wait% (
    echo Waiting... (%counter%/%max_wait% seconds)
    goto :wait_loop
)

echo.
echo [X] Docker Desktop startup timeout
echo.
echo Troubleshooting:
echo 1. Check system tray for Docker icon
echo 2. If icon is red, click it to see errors
echo 3. Close Docker Desktop and restart
echo 4. Verify WSL2 is properly installed
echo.
echo Please start Docker Desktop manually, then run scripts\start.bat
pause
exit /b 1

:start_environment
echo.
echo ========================================
echo Starting GPT-OSS Docker Environment
echo ========================================
echo.

REM Verify Docker environment once more
call "%~dp0check-docker.bat" >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Docker environment has issues
    echo Run check-docker.bat for detailed information
    pause
    exit /b 1
)

echo Docker environment verified - Starting RAG environment...
echo.

REM Start GPT-OSS Docker environment
call "%~dp0start.bat"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Startup Complete!
    echo ========================================
    echo.
    echo Available services:
    echo - Ollama LLM:      http://localhost:11434
    echo - Qdrant DB:       http://localhost:6333
    echo - Embeddings API:  http://localhost:8001
    echo.
    echo Next steps:
    echo 1. scripts\upload_doc.bat - Upload documents
    echo 2. scripts\rag_test.bat   - Start RAG chat
    echo.
) else (
    echo.
    echo [X] Environment startup failed
    echo Check the logs for error details
)

echo.
pause