@echo off
echo Testing GPT-OSS Docker environment...
cd /d "%~dp0\.."

echo Checking Docker containers status...
docker-compose -f docker/docker-compose.yml ps

echo Testing Ollama API connection...
curl -s http://localhost:11434/api/tags

echo Testing model availability...
docker exec gpt-oss-ollama ollama list

echo Environment test completed.
pause