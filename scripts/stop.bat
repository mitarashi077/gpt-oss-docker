@echo off
echo Stopping GPT-OSS Docker environment...
cd /d "%~dp0\.."

echo Stopping Docker containers...
docker-compose down

echo GPT-OSS Docker environment stopped.
pause