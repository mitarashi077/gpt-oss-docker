# GPT-OSS Docker RAG Environment

無料のローカルRAG（検索拡張生成）環境をDockerで簡単に構築できるプロジェクトです。

## 概要

このプロジェクトは、OllamaベースのローカルLLM + RAGシステムをDockerで提供します。完全に無料で使用でき、プライバシーを重視したオフライン環境でのAI開発が可能です。

## 特徴

- 🐳 **Docker対応**: ワンクリックでローカルRAG環境を構築
- 🔍 **RAGシステム**: 文書検索 + 生成で高精度な回答
- 🗄️ **ベクトルDB**: Qdrantによる高速文書検索
- 🔒 **プライバシー重視**: データは外部に送信されません
- 💰 **完全無料**: すべてのコンポーネントが無料で利用可能
- 🚀 **簡単セットアップ**: バッチファイルで瞬時に起動
- 📦 **複数モデル対応**: llama2、codellama等をサポート

## RAGシステム構成

### アーキテクチャ
1. **文書管理**: PDFやテキストファイルをアップロード
2. **ベクトル化**: Sentence Transformersでエンベディング生成
3. **インデックス**: Qdrantベクトルデータベースに保存
4. **検索**: クエリと類似する文書チャンクを検索
5. **生成**: 検索結果を参考にOllamaで高精度回答を生成

### サービス構成
- **Ollama** (ポート:11434): LLM推論エンジン
- **Qdrant** (ポート:6333): ベクトルデータベース
- **Embeddings API** (ポート:8001): テキストエンベディング処理

## 前提条件

- Docker Desktop (Windows)
- Git
- Python 3.7+ (RAG機能用)
- 最低8GB RAM推奨

## 🔧 Docker Desktopセットアップ

### 初回セットアップ（初心者向け）

**自動セットアップガイド**を使用する場合：
```bash
scripts\setup-guide.bat
```

**手動セットアップ**の場合：

#### 1. Docker Desktopのインストール
1. [Docker Desktop公式サイト](https://www.docker.com/products/docker-desktop/)からダウンロード
2. インストール時に「**WSL 2を使用**」を選択
3. インストール後、再起動が必要な場合があります

#### 2. WSL2の設定確認
PowerShellを**管理者として**実行し、以下を実行：
```powershell
# WSL2のインストール
wsl --install

# WSL2を既定のバージョンに設定  
wsl --set-default-version 2
```

#### 3. Docker Desktopの起動確認
```bash
# Docker環境チェック
scripts\check-docker.bat

# 問題がある場合のトラブルシューティング
scripts\troubleshoot.bat
```

#### 4. 簡易起動（推奨）
Docker Desktopの自動起動とRAG環境の起動：
```bash
scripts\easy-start.bat
```

### トラブルシューティング

**Docker Daemonエラーが発生する場合：**
1. `scripts\troubleshoot.bat` を実行して問題を診断
2. Docker Desktopを手動で起動
3. システムトレイのアイコンが緑色になるまで待つ（2-3分）
4. `scripts\check-docker.bat` で動作確認

**よくある問題と解決策：**
- **起動しない**: BIOS/UEFIで仮想化を有効化
- **WSL2エラー**: Windows機能で「Linux用Windowsサブシステム」を有効化
- **メモリ不足**: Docker Desktopの設定でメモリ使用量を調整

## クイックスタート

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/gpt-oss-docker.git
cd gpt-oss-docker
```

### 2. 環境の起動

```bash
scripts\start.bat
```

### 3. RAGシステムのテスト

```bash
# 文書のアップロード
scripts\upload_doc.bat

# RAG対話の開始
scripts\rag_test.bat
```

## ディレクトリ構造

```
gpt-oss-docker/
├── docker/                    # Docker設定ファイル
│   ├── Dockerfile            # Ollama用
│   ├── Dockerfile.embeddings # Embeddings API用
│   └── docker-compose.yml    # 全サービス設定
├── config/                   # 設定ファイル
│   ├── ollama/              # Ollama設定
│   ├── mcp/                 # MCP設定
│   └── embeddings/          # Embeddings設定
├── scripts/                 # 実行スクリプト
│   ├── start.bat           # 環境起動（RAG対応）
│   ├── stop.bat            # 環境停止
│   ├── test.bat            # 動作確認
│   ├── upload_doc.bat      # 文書アップロード
│   ├── search_doc.bat      # 文書検索
│   ├── rag_test.bat        # RAG対話テスト
│   ├── setup-guide.bat     # セットアップガイド
│   ├── check-docker.bat    # Docker環境確認
│   ├── easy-start.bat      # 簡易起動（推奨）
│   ├── troubleshoot.bat    # トラブルシューティング
│   ├── embeddings_server.py # Embeddingsサーバー
│   └── rag_query.py        # RAGクエリスクリプト
├── documents/              # アップロード用文書フォルダ
│   ├── sample_tech_doc.md  # 技術仕様書サンプル
│   ├── sample_manual.txt   # マニュアルサンプル
│   └── README.txt          # 文書フォルダ説明
├── data/                   # データ永続化
│   ├── ollama/            # Ollamaモデルデータ
│   └── qdrant/            # Qdrantベクトルデータ
├── logs/                   # ログファイル
├── .env.example            # 環境変数設定例
└── README.md
```

## 使用方法

### 1. 環境の起動

```bash
scripts\start.bat
```

起動後、以下のサービスが利用可能になります：
- Ollama LLM: http://localhost:11434
- Qdrant DB: http://localhost:6333
- Embeddings API: http://localhost:8001

### 2. 文書のアップロード

```bash
# バッチファイルを使用（推奨）
scripts\upload_doc.bat

# または直接cURLコマンド
curl -X POST "http://localhost:8001/upload" -F "file=@documents/sample_tech_doc.md"
```

### 3. RAG対話の実行

```bash
# 対話型RAGセッション（推奨）
scripts\rag_test.bat

# またはコマンドライン経由
python scripts\rag_query.py "Ollamaについて教えて"
```

### 4. 文書検索のテスト

```bash
# バッチファイルを使用
scripts\search_doc.bat

# または直接API呼び出し
curl -X POST "http://localhost:8001/search?query=Docker&limit=3"
```

### 5. 環境の停止

```bash
scripts\stop.bat
```

## RAG使用例

### 基本的な流れ
1. `scripts\start.bat` でシステム起動
2. `scripts\upload_doc.bat` で文書をアップロード
3. `scripts\rag_test.bat` で対話開始
4. 文書に関する質問を入力
5. システムが関連情報を検索して回答生成

### 対話コマンド
- `/health` - サービス状態確認
- `/upload` - 文書アップロード
- `/clear` - データベースクリア
- `/quit` - 終了

## 設定

### 環境変数

`.env.example`をコピーして`.env`として使用:

```bash
cp .env.example .env
```

主な設定項目:
- `OLLAMA_HOST`: Ollamaのホスト設定
- `DEFAULT_MODEL`: デフォルトのLLMモデル
- `LOG_LEVEL`: ログレベル

### モデルの追加

```bash
docker exec gpt-oss-ollama ollama pull [MODEL_NAME]
```

利用可能なモデル:
- `llama2:7b` - 汎用チャットモデル（RAG推奨）
- `codellama:7b` - コード生成特化モデル
- `mistral:7b` - 高性能軽量モデル

### サポートファイル形式
- PDF (.pdf)
- テキストファイル (.txt)
- Markdown (.md)
- その他テキスト系ファイル

## トラブルシューティング

### Dockerコンテナが起動しない

1. Docker Desktopが起動していることを確認
2. ポート11434、6333、8001が使用されていないことを確認
3. メモリ不足の場合は、より軽量なモデルを使用

### RAGサービスにアクセスできない

1. すべてのコンテナが起動していることを確認: `docker ps`
2. ヘルスチェック: `curl http://localhost:8001/health`
3. ログの確認: `docker logs gpt-oss-embeddings`

### 文書アップロードが失敗する

1. ファイルパスが正しいことを確認
2. ファイルがUTF-8エンコーディングであることを確認
3. ファイルサイズが適切であることを確認（推奨: 10MB以下）

### 検索結果が出ない

1. 文書が正常にアップロードされていることを確認
2. 検索クエリを変更してみる
3. データベースをクリア: `/clear` コマンド使用

### モデルのダウンロードが失敗する

1. インターネット接続を確認
2. Dockerコンテナの状態を確認: `docker ps`
3. 手動でモデルをダウンロード: `docker exec gpt-oss-ollama ollama pull llama2:7b`

## 開発

### 新機能の追加

1. ブランチを作成: `git checkout -b feature/new-feature`
2. 変更を実装
3. テストを実行: `scripts\test.bat`
4. プルリクエストを作成

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 貢献

プルリクエストやイシューの報告を歓迎します。

## サポート

問題が発生した場合は、GitHubのIssuesで報告してください。