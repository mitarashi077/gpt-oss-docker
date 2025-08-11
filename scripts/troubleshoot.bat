@echo off
echo ========================================
echo GPT-OSS Docker Troubleshooting
echo ========================================
echo.
echo This script will diagnose common Docker issues
echo and provide solutions.
echo.
pause

echo ========================================
echo Starting Problem Diagnosis
echo ========================================
echo.

echo [1] Checking Docker Desktop installation...
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Docker Desktop is not installed
    echo.
    echo Solution:
    echo 1. Visit: https://www.docker.com/products/docker-desktop/
    echo 2. Download "Docker Desktop for Windows"
    echo 3. Install with "Use WSL 2" option selected
    echo.
    goto :end
) else (
    echo [OK] Docker Desktop is installed
)

echo.
echo [2] Checking Docker Daemon status...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Docker Daemon is not running
    echo.
    echo Solution:
    echo 1. Start "Docker Desktop" from Start Menu
    echo 2. Wait for system tray icon to turn green
    echo 3. Wait 2-3 minutes for full startup
    echo.
    echo Continuing with detailed diagnosis...
) else (
    echo [OK] Docker Daemon is running
    goto :running_check
)

echo.
echo [3] Checking Docker Desktop process...
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>nul | find /I "Docker Desktop.exe" >nul
if %errorlevel% equ 0 (
    echo [!] Docker Desktop process is running but Daemon is not responding
    echo.
    echo Solution:
    echo 1. Right-click Docker icon in system tray
    echo 2. Select "Restart"
    echo 3. Wait 3-5 minutes for complete startup
    echo.
) else (
    echo [X] Docker Desktop process is not running
    echo.
    echo Solution:
    echo 1. Start Docker Desktop application
    echo.
)

echo.
echo [4] Checking WSL2 status...
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] WSL2 is not properly configured
    echo.
    echo Solution (run in PowerShell as Administrator):
    echo   wsl --install
    echo   wsl --set-default-version 2
    echo   (Computer restart may be required)
    echo.
) else (
    echo [OK] WSL2 configuration is correct
)

echo.
echo [5] Checking virtualization support...
systeminfo | find "Hyper-V" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Cannot verify Hyper-V information
    echo.
    echo Check manually:
    echo 1. Task Manager -> Performance -> CPU
    echo 2. Verify "Virtualization: Enabled"
    echo 3. If disabled, enable in BIOS/UEFI:
    echo    - Intel: VT-x (Intel Virtualization Technology)
    echo    - AMD: AMD-V (AMD Virtualization)
    echo.
) else (
    echo [OK] Hyper-V is available
)

goto :solutions

:running_check
echo.
echo ========================================
echo Docker Runtime Issue Diagnosis
echo ========================================

echo.
echo [6] Container status...
docker ps -a
echo.

echo [7] Port usage check...
netstat -ano | findstr ":11434" >nul 2>&1
if %errorlevel% equ 0 (
    echo [!] Port 11434 is in use (Ollama)
    echo.
    echo Currently using port 11434:
    netstat -ano | findstr ":11434"
    echo.
) else (
    echo [OK] Port 11434 is available
)

netstat -ano | findstr ":6333" >nul 2>&1
if %errorlevel% equ 0 (
    echo [!] Port 6333 is in use (Qdrant)
    echo.
    echo Currently using port 6333:
    netstat -ano | findstr ":6333"
    echo.
) else (
    echo [OK] Port 6333 is available
)

netstat -ano | findstr ":8001" >nul 2>&1
if %errorlevel% equ 0 (
    echo [!] Port 8001 is in use (Embeddings)
    echo.
    echo Currently using port 8001:
    netstat -ano | findstr ":8001"
    echo.
) else (
    echo [OK] Port 8001 is available
)

echo.
echo [8] Docker Compose configuration check...
if exist "docker-compose.yml" (
    echo [OK] docker-compose.yml exists
    docker-compose config >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] docker-compose.yml syntax is valid
    ) else (
        echo [X] docker-compose.yml syntax error
        echo.
        echo Solution:
        echo   Run: docker-compose config
        echo   Fix syntax errors shown
        echo.
    )
) else (
    echo [X] docker-compose.yml not found
    echo.
    echo Solution:
    echo   Run from project root directory
    echo.
)

:solutions
echo.
echo ========================================
echo Common Solutions
echo ========================================
echo.
echo Docker Desktop won't start:
echo   1. Update Windows to latest version
echo   2. Restart computer and try again
echo   3. Check antivirus exclusions for Docker
echo.
echo WSL2 issues:
echo   1. Enable "Windows Subsystem for Linux" in Windows Features
echo   2. Enable "Virtual Machine Platform" in Windows Features
echo   3. Restart computer after enabling features
echo.
echo Memory issues:
echo   1. Adjust Docker Desktop memory settings
echo   2. Use lighter models (7B instead of larger)
echo   3. Close unnecessary applications
echo.
echo Port conflicts:
echo   1. Stop applications using conflicting ports
echo   2. Modify port numbers in docker-compose.yml
echo   3. Check Windows Defender Firewall settings
echo.

:end
echo ========================================
echo Next Steps
echo ========================================
echo.
echo After resolving issues, try these commands:
echo.
echo   scripts\check-docker.bat    - Verify Docker environment
echo   scripts\easy-start.bat      - Automatic startup
echo   scripts\setup-guide.bat     - Full setup guide
echo.
echo If problems persist:
echo   1. Completely close Docker Desktop
echo   2. Restart Windows
echo   3. Start Docker Desktop
echo   4. Run this troubleshooting script again
echo.
pause