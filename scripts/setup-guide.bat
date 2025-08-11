@echo off
echo ========================================
echo GPT-OSS Docker Setup Guide
echo ========================================
echo.
echo This guide will help you set up the
echo GPT-OSS Docker RAG environment.
echo.
echo ========================================
echo Requirements
echo ========================================
echo - Windows 10/11 (64-bit)
echo - 8GB+ RAM recommended
echo - 20GB+ free disk space
echo - Internet connection (first time only)
echo.
echo ========================================
echo Step 1: Check Docker Desktop Installation
echo ========================================
echo.
echo Checking Docker Desktop installation...

where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [X] Docker Desktop is NOT installed
    echo.
    echo Installation instructions:
    echo 1. Visit: https://www.docker.com/products/docker-desktop/
    echo 2. Click "Download for Windows"
    echo 3. Run the downloaded installer
    echo 4. Select "Use WSL 2" during installation
    echo 5. Restart computer if prompted
    echo.
    echo After installation, run this script again.
    pause
    exit /b 1
) else (
    echo [OK] Docker Desktop is installed
)

echo.
echo ========================================
echo Step 2: Start Docker Desktop
echo ========================================
echo.
echo Follow these steps to start Docker Desktop:
echo.
echo 1. Search "Docker Desktop" in Start Menu
echo 2. Click to start Docker Desktop
echo 3. Wait for Docker icon in system tray (bottom-right)
echo 4. Icon should show "Docker Desktop is running"
echo.
echo Note: First startup may take 2-3 minutes
echo.
pause

echo.
echo ========================================
echo Step 3: Verify Docker Environment
echo ========================================
echo.
echo Running Docker environment check...
echo.
call "%~dp0check-docker.bat"

if %errorlevel% neq 0 (
    echo.
    echo [X] Docker environment check failed
    echo Please ensure Docker Desktop is started and
    echo run this script again.
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 4: Check WSL2 Configuration
echo ========================================
echo.
echo Checking WSL2 configuration...

wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] WSL2 might not be properly configured
    echo.
    echo To fix this, run PowerShell as Administrator:
    echo.
    echo   wsl --install
    echo   wsl --set-default-version 2
    echo.
    echo Then restart your computer.
    pause
) else (
    echo [OK] WSL2 configuration is correct
)

echo.
echo ========================================
echo Step 5: Start GPT-OSS Docker Environment
echo ========================================
echo.
echo All prerequisites are ready!
echo.
echo Would you like to start the GPT-OSS Docker RAG environment?
echo.
choice /C YN /M "Start environment now? (Y/N)"
if %errorlevel% equ 1 (
    echo.
    echo Starting RAG environment...
    call "%~dp0start.bat"
    goto :end
)

:skip_start
echo.
echo To start manually later, run:
echo   scripts\start.bat

:end
echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Available commands:
echo   scripts\start.bat        - Start environment
echo   scripts\stop.bat         - Stop environment
echo   scripts\upload_doc.bat   - Upload documents
echo   scripts\rag_test.bat     - Test RAG chat
echo   scripts\check-docker.bat - Check Docker status
echo.
echo Usage:
echo 1. Upload documents: scripts\upload_doc.bat
echo 2. Start RAG chat: scripts\rag_test.bat
echo 3. Stop environment: scripts\stop.bat
echo.
pause