@echo off
echo ========================================
echo Docker Environment Check
echo ========================================

echo.
echo [1] Checking Docker Desktop status...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Docker Desktop is not running
    echo.
    echo Solution:
    echo 1. Start "Docker Desktop" from Start Menu
    echo 2. Wait for icon in system tray (bottom-right)
    echo 3. Run this script again when "Docker Desktop is running"
    echo.
    echo Hints:
    echo - First startup takes 2-3 minutes
    echo - WSL2 must be enabled
    echo - Virtualization must be enabled in BIOS
    echo.
    pause
    exit /b 1
) else (
    echo [OK] Docker Desktop is running
)

echo.
echo [2] Docker Version Information:
docker version

echo.
echo [3] Checking Docker Compose...
docker-compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Docker Compose is not available
    echo - Docker Compose is included with Docker Desktop
    echo - Try restarting Docker Desktop
) else (
    echo [OK] Docker Compose is ready
    echo Version information:
    docker-compose version
)

echo.
echo [4] Docker System Information:
docker system info 2>nul || echo [X] Could not get Docker system info

echo.
echo [5] Running Containers:
docker ps

echo.
echo [6] Available Docker Images:
docker images

echo.
echo [7] Disk Usage:
docker system df 2>nul || echo [X] Could not get disk usage info

echo.
echo ========================================
echo Check Complete
echo ========================================
echo.
echo If all items show [OK], you are ready to
echo start the GPT-OSS Docker environment.
echo.
echo Next step: Run scripts\start.bat
echo.
pause