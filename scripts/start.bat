@echo off
echo Starting GPT-OSS Docker environment...
cd /d "%~dp0\.."

echo Building and starting Docker containers...
docker-compose -f docker/docker-compose.yml up -d

echo Waiting for Ollama to start...
timeout /t 10 /nobreak >nul

echo Pulling Ollama models...
docker exec gpt-oss-ollama ollama pull llama2:7b
docker exec gpt-oss-ollama ollama pull codellama:7b

echo GPT-OSS Docker environment is ready!
echo Access Ollama at: http://localhost:11434
pause