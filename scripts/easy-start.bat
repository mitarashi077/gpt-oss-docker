@echo off
echo ========================================
echo 🚀 GPT-OSS Docker 簡易起動
echo ========================================

echo.
echo [1] Docker Desktop起動状態の確認...
docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Docker Desktopは既に起動しています
    goto :start_environment
)

echo ⚠️  Docker Desktopが起動していません
echo.

echo [2] Docker Desktopの自動起動を試みます...
echo.

REM 一般的なDocker Desktopインストール場所を確認
set "DOCKER_PATH="
if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    set "DOCKER_PATH=C:\Program Files\Docker\Docker\Docker Desktop.exe"
) else if exist "%USERPROFILE%\AppData\Local\Docker\Docker Desktop.exe" (
    set "DOCKER_PATH=%USERPROFILE%\AppData\Local\Docker\Docker Desktop.exe"
) else if exist "C:\Users\%USERNAME%\AppData\Local\Docker\Docker Desktop.exe" (
    set "DOCKER_PATH=C:\Users\%USERNAME%\AppData\Local\Docker\Docker Desktop.exe"
)

if "%DOCKER_PATH%"=="" (
    echo ❌ Docker Desktopが見つかりません
    echo.
    echo 手動でDocker Desktopを起動してから、このスクリプトを再実行してください。
    echo.
    echo 📋 手動起動手順:
    echo 1. スタートメニューから「Docker Desktop」を検索
    echo 2. Docker Desktopを起動
    echo 3. システムトレイのアイコンが緑色になるまで待つ
    echo 4. このスクリプトを再実行
    echo.
    pause
    exit /b 1
)

echo 🔄 Docker Desktopを起動中: "%DOCKER_PATH%"
start "" "%DOCKER_PATH%"

echo.
echo ⏱️  Docker Desktopの起動を待機中...
echo （初回起動の場合、最大3-5分かかることがあります）
echo.

REM Docker Desktopの起動待機（最大180秒）
set /a counter=0
set /a max_wait=180

:wait_loop
timeout /t 5 /nobreak >nul
docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Docker Desktop起動完了！
    goto :start_environment
)

set /a counter=%counter%+5
if %counter% lss %max_wait% (
    echo 待機中... (%counter%/%max_wait%秒)
    goto :wait_loop
)

echo.
echo ❌ Docker Desktopの起動タイムアウト
echo.
echo 🔧 トラブルシューティング:
echo 1. システムトレイのDockerアイコンを確認
echo 2. アイコンが赤色の場合、クリックしてエラーを確認
echo 3. Docker Desktopを一度終了して再起動
echo 4. WSL2が正しくインストールされているか確認
echo.
echo 手動で起動を確認後、scripts\start.bat を実行してください
pause
exit /b 1

:start_environment
echo.
echo ========================================
echo 🎯 GPT-OSS Docker環境を起動します
echo ========================================
echo.

REM 念のため、もう一度Docker状態を確認
call "%~dp0check-docker.bat" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker環境に問題があります
    echo 詳細確認のため check-docker.bat を実行してください
    pause
    exit /b 1
)

echo Docker環境確認OK - RAG環境を起動中...
echo.

REM GPT-OSS Docker環境の起動
call "%~dp0start.bat"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 🎉 起動完了！
    echo ========================================
    echo.
    echo 利用可能なサービス:
    echo • Ollama LLM:      http://localhost:11434
    echo • Qdrant DB:       http://localhost:6333
    echo • Embeddings API:  http://localhost:8001
    echo.
    echo 📋 次のステップ:
    echo 1. scripts\upload_doc.bat - 文書アップロード
    echo 2. scripts\rag_test.bat - RAGチャット開始
    echo.
) else (
    echo.
    echo ❌ 環境起動に失敗しました
    echo ログを確認して問題を解決してください
)

echo.
pause