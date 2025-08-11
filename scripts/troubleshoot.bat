@echo off
echo ========================================
echo 🔧 GPT-OSS Docker トラブルシューティング
echo ========================================
echo.
echo このスクリプトは、Dockerに関する一般的な問題を
echo 診断して解決策を提示します。
echo.
pause

echo ========================================
echo 🔍 問題診断を開始します
echo ========================================
echo.

echo [1] Docker Desktopインストール確認...
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Desktopがインストールされていません
    echo.
    echo 🔧 解決策:
    echo 1. https://www.docker.com/products/docker-desktop/ を開く
    echo 2. "Download for Windows"をダウンロード
    echo 3. インストール時に「WSL 2を使用」を選択
    echo.
    goto :end
) else (
    echo ✅ Docker Desktopインストール済み
)

echo.
echo [2] Docker Daemon起動確認...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Daemonが起動していません
    echo.
    echo 🔧 解決策:
    echo 1. スタートメニューから「Docker Desktop」を起動
    echo 2. システムトレイのアイコンが緑色になるまで待つ
    echo 3. 数分待ってから再試行
    echo.
    echo 🔍 詳細診断を続けます...
) else (
    echo ✅ Docker Daemon起動中
    goto :running_check
)

echo.
echo [3] プロセス確認...
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>nul | find /I "Docker Desktop.exe" >nul
if %errorlevel% equ 0 (
    echo ⚠️  Docker Desktopプロセスは実行中ですが、Daemonが応答しません
    echo.
    echo 🔧 解決策:
    echo 1. システムトレイのDockerアイコンを右クリック
    echo 2. "Restart"を選択
    echo 3. 完全に起動するまで3-5分待つ
    echo.
) else (
    echo ❌ Docker Desktopプロセスが実行されていません
    echo.
    echo 🔧 解決策:
    echo 1. Docker Desktopを起動してください
    echo.
)

echo.
echo [4] WSL2状態確認...
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ WSL2が正しく設定されていません
    echo.
    echo 🔧 解決策（PowerShellを管理者として実行）:
    echo   wsl --install
    echo   wsl --set-default-version 2
    echo   （再起動が必要な場合があります）
    echo.
) else (
    echo ✅ WSL2設定確認OK
)

echo.
echo [5] Hyper-V/仮想化確認...
systeminfo | find "Hyper-V" >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Hyper-V情報を取得できません
    echo.
    echo 🔧 確認事項:
    echo 1. タスクマネージャー → パフォーマンス → CPU
    echo 2. 「仮想化: 有効」になっているか確認
    echo 3. 無効の場合、BIOS/UEFIで仮想化を有効化
    echo    - Intel: VT-x (Intel Virtualization Technology)
    echo    - AMD: AMD-V (AMD Virtualization)
    echo.
) else (
    echo ✅ Hyper-V利用可能
)

goto :solutions

:running_check
echo.
echo ========================================
echo 🎯 Docker実行時の問題診断
echo ========================================

echo.
echo [6] コンテナ起動状況...
docker ps -a
echo.

echo [7] ポート使用状況確認...
netstat -ano | findstr ":11434" >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  ポート11434が使用されています
    echo.
    echo 使用中のポート一覧:
    netstat -ano | findstr ":11434"
    echo.
) else (
    echo ✅ ポート11434は空いています
)

netstat -ano | findstr ":6333" >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  ポート6333が使用されています（Qdrant用）
    echo.
    echo 使用中のポート一覧:
    netstat -ano | findstr ":6333"
    echo.
) else (
    echo ✅ ポート6333は空いています
)

netstat -ano | findstr ":8001" >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  ポート8001が使用されています（Embeddings用）
    echo.
    echo 使用中のポート一覧:
    netstat -ano | findstr ":8001"
    echo.
) else (
    echo ✅ ポート8001は空いています
)

echo.
echo [8] Docker Composeファイル確認...
if exist "docker-compose.yml" (
    echo ✅ docker-compose.yml存在確認OK
    docker-compose config >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ docker-compose.yml構文確認OK
    ) else (
        echo ❌ docker-compose.yml構文エラー
        echo.
        echo 🔧 解決策:
        echo   docker-compose config でエラー詳細を確認
        echo.
    )
) else (
    echo ❌ docker-compose.ymlが見つかりません
    echo.
    echo 🔧 解決策:
    echo   プロジェクトのルートディレクトリで実行してください
    echo.
)

:solutions
echo.
echo ========================================
echo 💡 一般的な解決策
echo ========================================
echo.
echo 🔧 Docker Desktop起動しない場合:
echo   1. Windows Updateを最新に
echo   2. 再起動後にDocker Desktopを起動
echo   3. ウイルス対策ソフトの除外設定を確認
echo.
echo 🔧 WSL2の問題:
echo   1. Windows機能から「Linux用Windowsサブシステム」を有効化
echo   2. 「仮想マシンプラットフォーム」を有効化
echo   3. 再起動後にWSL2をインストール
echo.
echo 🔧 メモリ不足の問題:
echo   1. Docker Desktopの設定で使用メモリを調整
echo   2. より軽量なモデル（7B）を使用
echo   3. 不要なアプリケーションを終了
echo.
echo 🔧 ポート競合の問題:
echo   1. 競合しているアプリケーションを終了
echo   2. docker-compose.ymlでポート番号を変更
echo   3. Windows Defenderファイアウォールの設定確認
echo.

:end
echo ========================================
echo 🎯 次のステップ
echo ========================================
echo.
echo 問題が解決したら、以下のコマンドを試してください:
echo.
echo   scripts\check-docker.bat    - Docker環境確認
echo   scripts\easy-start.bat      - 自動起動試行
echo   scripts\setup-guide.bat     - セットアップガイド
echo.
echo まだ問題がある場合:
echo   1. Docker Desktopを完全に終了
echo   2. Windowsを再起動
echo   3. Docker Desktopを起動
echo   4. このスクリプトを再実行
echo.
pause