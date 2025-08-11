# GPT-OSS Docker Environment

無料のローカルLLM環境をDockerで簡単に構築できるプロジェクトです。

## 概要

このプロジェクトは、OllamaベースのローカルLLM環境をDockerで提供します。完全に無料で使用でき、プライバシーを重視したオフライン環境でのAI開発が可能です。

## 特徴

- 🐳 **Docker対応**: ワンクリックでローカルLLM環境を構築
- 🔒 **プライバシー重視**: データは外部に送信されません
- 💰 **完全無料**: すべてのコンポーネントが無料で利用可能
- 🚀 **簡単セットアップ**: バッチファイルで瞬時に起動
- 📦 **複数モデル対応**: llama2、codellama等をサポート

## 前提条件

- Docker Desktop (Windows)
- Git
- 最低8GB RAM推奨

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

### 3. 動作確認

```bash
scripts\test.bat
```

## ディレクトリ構造

```
gpt-oss-docker/
├── docker/              # Docker設定ファイル
│   ├── Dockerfile
│   └── docker-compose.yml
├── config/              # 設定ファイル
│   ├── ollama/         # Ollama設定
│   └── mcp/            # MCP設定
├── scripts/            # 実行スクリプト
│   ├── start.bat       # 環境起動
│   ├── stop.bat        # 環境停止
│   └── test.bat        # 動作確認
├── data/               # データ永続化
├── logs/               # ログファイル
├── .env.example        # 環境変数設定例
└── README.md
```

## 使用方法

### 環境の起動

```bash
scripts\start.bat
```

### API使用例

```bash
# モデル一覧の確認
curl http://localhost:11434/api/tags

# チャット実行
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "llama2:7b",
  "prompt": "Hello, how are you?",
  "stream": false
}'
```

### 環境の停止

```bash
scripts\stop.bat
```

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
- `llama2:7b` - 汎用チャットモデル
- `codellama:7b` - コード生成特化モデル
- `mistral:7b` - 高性能軽量モデル

## トラブルシューティング

### Dockerコンテナが起動しない

1. Docker Desktopが起動していることを確認
2. ポート11434が使用されていないことを確認
3. メモリ不足の場合は、より軽量なモデルを使用

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