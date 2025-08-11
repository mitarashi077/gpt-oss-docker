Documents フォルダについて

このフォルダは、RAGシステムでインデックス化する文書を保存するためのフォルダです。

サポートされるファイル形式：
- PDF (.pdf)
- テキストファイル (.txt) 
- Markdown (.md)
- その他のテキスト形式

サンプル文書：
- sample_tech_doc.md: 技術仕様書のサンプル
- sample_manual.txt: 操作マニュアルのサンプル

これらのサンプル文書を使って RAG システムをテストできます。

アップロード方法：
1. scripts\upload_doc.bat を実行
2. ファイルパスを入力（例：documents\sample_tech_doc.md）
3. アップロード完了後、scripts\rag_test.bat で質問してテスト

注意：
- ファイルサイズが大きいとアップロードに時間がかかります
- 日本語ファイルはUTF-8エンコーディングで保存してください