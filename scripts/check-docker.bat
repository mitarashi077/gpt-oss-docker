@echo off
echo ========================================
echo Docker環境チェック
echo ========================================

echo.
echo [1] Docker Desktop起動確認...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Desktopが起動していません
    echo.
    echo 🔧 解決方法:
    echo 1. スタートメニューから「Docker Desktop」を起動
    echo 2. システムトレイ（右下）にDockerアイコンが表示されるまで待つ
    echo 3. アイコンが「Docker Desktop is running」になったら再度実行
    echo.
    echo 💡 ヒント:
    echo - 初回起動は2-3分かかる場合があります
    echo - WSL2が有効になっている必要があります
    echo - 仮想化がBIOS/UEFIで有効になっている必要があります
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Docker Desktop起動確認OK
)

echo.
echo [2] Dockerバージョン情報:
docker version

echo.
echo [3] Docker Compose確認...
docker-compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Composeが利用できません
    echo - Docker Desktopに含まれています
    echo - Docker Desktopを再起動してみてください
) else (
    echo ✅ Docker Compose確認OK
    echo バージョン情報:
    docker-compose version
)

echo.
echo [4] Docker システム情報:
docker system info 2>nul || echo ❌ Dockerシステム情報取得失敗

echo.
echo [5] 実行中のコンテナ:
docker ps

echo.
echo [6] Dockerイメージ一覧:
docker images

echo.
echo [7] ディスク使用量:
docker system df 2>nul || echo ❌ ディスク情報取得失敗

echo.
echo ========================================
echo ✅ チェック完了
echo ========================================
echo.
echo すべて緑色のチェックマーク(✅)が表示されていれば
echo GPT-OSS Docker環境を起動する準備ができています。
echo.
echo 次の手順: scripts\start.bat を実行してください
echo.
pause