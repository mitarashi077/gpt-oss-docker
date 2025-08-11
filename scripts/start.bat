@echo off
echo ===============================================
echo Starting GPT-OSS Docker RAG Environment...
echo ===============================================
cd /d "%~dp0\.."

echo 🐳 Building and starting Docker containers...
docker-compose -f docker/docker-compose.yml up -d

echo ⏳ Waiting for services to initialize...
timeout /t 15 /nobreak >nul

echo 🤖 Pulling Ollama models...
docker exec gpt-oss-ollama ollama pull llama2:7b
docker exec gpt-oss-ollama ollama pull codellama:7b

echo ✅ Checking service health...
echo Ollama API:
curl -s http://localhost:11434/api/tags >nul && echo "✅ Ollama: Ready" || echo "❌ Ollama: Not ready"

echo Qdrant Database:
curl -s http://localhost:6333/collections >nul && echo "✅ Qdrant: Ready" || echo "❌ Qdrant: Not ready"

echo Embeddings API:
curl -s http://localhost:8001/health >nul && echo "✅ Embeddings: Ready" || echo "❌ Embeddings: Not ready"

echo.
echo ===============================================
echo 🚀 GPT-OSS Docker RAG Environment is ready!
echo ===============================================
echo Available services:
echo   • Ollama LLM:      http://localhost:11434
echo   • Qdrant DB:       http://localhost:6333  
echo   • Embeddings API:  http://localhost:8001
echo   • RAG Interface:   python scripts\rag_query.py
echo.
echo Quick commands:
echo   • Upload document: scripts\upload_doc.bat
echo   • Search docs:     scripts\search_doc.bat
echo   • RAG chat:        scripts\rag_test.bat
echo   • Stop services:   scripts\stop.bat
echo ===============================================
pause