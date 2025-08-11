FROM ubuntu:22.04

# パッケージの更新とOllamaの依存関係をインストール
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Ollamaをインストール
RUN curl -fsSL https://ollama.com/install.sh | sh

# 作業ディレクトリを設定
WORKDIR /app

# Ollamaのポートを公開
EXPOSE 11434

# Ollamaサーバーを起動
CMD ["ollama", "serve"]