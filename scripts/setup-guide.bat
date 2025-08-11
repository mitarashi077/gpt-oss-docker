@echo off
echo ========================================
echo 🐳 GPT-OSS Docker セットアップガイド
echo ========================================
echo.
echo このガイドでは、GPT-OSS Docker RAG環境の
echo セットアップ手順を説明します。
echo.
echo ========================================
echo 📋 必要な環境
echo ========================================
echo ✅ Windows 10/11 (64-bit)
echo ✅ 8GB以上のRAM推奨
echo ✅ 20GB以上の空きディスク容量
echo ✅ インターネット接続（初回のみ）
echo.
echo ========================================
echo 🔧 手順1: Docker Desktopのインストール確認
echo ========================================
echo.
echo Docker Desktopがインストールされているか確認中...

where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ Docker Desktopがインストールされていません
    echo.
    echo 📥 インストール手順:
    echo 1. https://www.docker.com/products/docker-desktop/ を開く
    echo 2. "Download for Windows"をクリック
    echo 3. ダウンロードしたファイルを実行
    echo 4. インストール時に「WSL 2を使用」を選択
    echo 5. インストール後、再起動が必要な場合があります
    echo.
    echo インストール後、このスクリプトを再実行してください。
    pause
    exit /b 1
) else (
    echo ✅ Docker Desktopインストール済み
)

echo.
echo ========================================
echo 🚀 手順2: Docker Desktopを起動
echo ========================================
echo.
echo 以下の手順でDocker Desktopを起動してください:
echo.
echo 1. スタートメニューから「Docker Desktop」を検索
echo 2. Docker Desktopをクリックして起動
echo 3. システムトレイ（右下）にDockerアイコンが表示されるまで待つ
echo 4. アイコンが「Docker Desktop is running」になったら完了
echo.
echo ⏱️  初回起動時は2-3分かかる場合があります
echo.
pause

echo.
echo ========================================
echo 🔍 手順3: Docker環境確認
echo ========================================
echo.
echo Docker環境の確認を実行します...
echo.
call "%~dp0check-docker.bat"

if %errorlevel% neq 0 (
    echo.
    echo ❌ Docker環境の確認に失敗しました
    echo 上記の手順を確認して、Docker Desktopを起動してから
    echo このスクリプトを再実行してください。
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo 🔧 手順4: WSL2設定確認（自動実行）
echo ========================================
echo.
echo WSL2の設定を確認中...

wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ⚠️  WSL2が適切に設定されていない可能性があります
    echo.
    echo 手動で以下のコマンドをPowerShell（管理者）で実行してください:
    echo.
    echo   wsl --install
    echo   wsl --set-default-version 2
    echo.
    echo その後、システムを再起動してください。
    pause
) else (
    echo ✅ WSL2設定確認OK
)

echo.
echo ========================================
echo 🎯 手順5: GPT-OSS Docker環境起動
echo ========================================
echo.
echo すべての準備が完了しました！
echo.
echo GPT-OSS Docker RAG環境を起動しますか？
echo.
set /p choice="Y/N (デフォルト: Y): "
if /i "%choice%"=="N" goto :skip_start
if /i "%choice%"=="n" goto :skip_start

echo.
echo 🚀 GPT-OSS Docker環境を起動中...
call "%~dp0start.bat"

goto :end

:skip_start
echo.
echo 手動で起動する場合は、以下のコマンドを実行してください:
echo   scripts\start.bat

:end
echo.
echo ========================================
echo 🎉 セットアップ完了！
echo ========================================
echo.
echo 📚 利用可能なコマンド:
echo   scripts\start.bat      - 環境起動
echo   scripts\stop.bat       - 環境停止
echo   scripts\upload_doc.bat - 文書アップロード
echo   scripts\rag_test.bat   - RAGテスト
echo   scripts\check-docker.bat - Docker確認
echo.
echo 💡 使い方:
echo 1. 文書をアップロード: scripts\upload_doc.bat
echo 2. RAGチャット開始: scripts\rag_test.bat
echo 3. 環境停止: scripts\stop.bat
echo.
pause