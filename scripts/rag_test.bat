@echo off
echo ===============================================
echo GPT-OSS Docker - RAG Testing Tool
echo ===============================================

echo Checking Python installation...
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [X] Python is not installed or not in PATH
    echo Please install Python 3.7+ and try again
    pause
    exit /b 1
)

echo Installing required Python packages...
pip install requests >nul 2>&1

echo.
echo Testing RAG Pipeline...
echo ===============================================

echo.
echo 1. Testing service health...
curl -s "http://localhost:8001/health"
echo.

echo.
echo 2. Testing Ollama connection...
curl -s "http://localhost:11434/api/tags"
echo.

echo.
echo 3. Starting interactive RAG session...
echo (Type /quit to exit, /health to check status)
echo ===============================================

python scripts\rag_query.py

echo.
echo RAG test completed.
pause