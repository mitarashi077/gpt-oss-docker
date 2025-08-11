import requests
import json
import sys
import time
from typing import List, Dict

class RAGClient:
    def __init__(self, 
                 embeddings_url: str = "http://localhost:8001",
                 ollama_url: str = "http://localhost:11434",
                 model: str = "llama2:7b"):
        self.embeddings_url = embeddings_url
        self.ollama_url = ollama_url
        self.model = model
    
    def check_health(self) -> Dict:
        """サービスのヘルスチェック"""
        try:
            # Embeddings APIの確認
            embeddings_response = requests.get(f"{self.embeddings_url}/health", timeout=10)
            embeddings_status = embeddings_response.json() if embeddings_response.status_code == 200 else {"status": "unhealthy"}
            
            # Ollama APIの確認
            try:
                ollama_response = requests.get(f"{self.ollama_url}/api/tags", timeout=10)
                ollama_status = "healthy" if ollama_response.status_code == 200 else "unhealthy"
            except:
                ollama_status = "unhealthy"
            
            return {
                "embeddings": embeddings_status,
                "ollama": ollama_status
            }
        except Exception as e:
            return {"error": str(e)}
    
    def upload_document(self, file_path: str) -> Dict:
        """文書をアップロード"""
        try:
            with open(file_path, 'rb') as f:
                files = {"file": (file_path.split("\\")[-1], f)}
                response = requests.post(f"{self.embeddings_url}/upload", files=files, timeout=30)
                
                if response.status_code == 200:
                    return response.json()
                else:
                    return {"error": f"Upload failed: {response.text}"}
        except Exception as e:
            return {"error": str(e)}
    
    def search_documents(self, query: str, limit: int = 3, min_score: float = 0.3) -> List[Dict]:
        """関連文書を検索"""
        try:
            params = {
                "query": query,
                "limit": limit,
                "min_score": min_score
            }
            response = requests.post(f"{self.embeddings_url}/search", params=params, timeout=10)
            
            if response.status_code == 200:
                return response.json().get("results", [])
            else:
                print(f"Search failed: {response.text}")
                return []
        except Exception as e:
            print(f"Search error: {e}")
            return []
    
    def generate_with_ollama(self, prompt: str, stream: bool = False) -> str:
        """Ollamaでテキスト生成"""
        try:
            payload = {
                "model": self.model,
                "prompt": prompt,
                "stream": stream
            }
            
            response = requests.post(f"{self.ollama_url}/api/generate", json=payload, timeout=60)
            
            if response.status_code == 200:
                result = response.json()
                return result.get("response", "")
            else:
                return f"Generation failed: {response.text}"
        except Exception as e:
            return f"Generation error: {e}"
    
    def query_with_context(self, question: str, context_limit: int = 3) -> Dict:
        """RAGクエリを実行"""
        print(f"🔍 Searching for relevant context...")
        
        # 1. ベクトル検索で関連文書を取得
        contexts = self.search_documents(question, limit=context_limit)
        
        if not contexts:
            print("⚠️ No relevant context found. Generating answer without context.")
            prompt = f"質問: {question}\n\n回答:"
        else:
            print(f"📄 Found {len(contexts)} relevant document chunks")
            
            # 2. コンテキストを含むプロンプトを作成
            context_text = ""
            for i, context in enumerate(contexts, 1):
                context_text += f"\n[参考資料 {i}] (スコア: {context['score']:.3f}, 出典: {context['source']})\n"
                context_text += context['text'] + "\n"
            
            prompt = f"""以下の参考資料を基に、質問に正確に答えてください。参考資料に関連する情報がない場合は、「参考資料には該当する情報がありません」と回答してください。

参考資料:
{context_text}

質問: {question}

回答:"""
        
        print("🤖 Generating response...")
        
        # 3. Ollamaでテキスト生成
        answer = self.generate_with_ollama(prompt)
        
        return {
            "question": question,
            "answer": answer,
            "contexts": contexts,
            "context_count": len(contexts)
        }
    
    def interactive_mode(self):
        """対話モード"""
        print("="*60)
        print("🚀 RAG Interactive Mode")
        print("="*60)
        print("Commands:")
        print("  /health    - Check service status")
        print("  /upload    - Upload a document")
        print("  /clear     - Clear document collection")
        print("  /quit      - Exit")
        print("  Or just ask a question!")
        print("-"*60)
        
        while True:
            try:
                user_input = input("\n💬 You: ").strip()
                
                if not user_input:
                    continue
                
                if user_input == "/quit":
                    print("👋 Goodbye!")
                    break
                
                elif user_input == "/health":
                    health = self.check_health()
                    print("🔧 Service Status:")
                    print(json.dumps(health, indent=2))
                
                elif user_input == "/upload":
                    file_path = input("📁 Enter file path: ").strip().strip('"')
                    if file_path:
                        print("📤 Uploading...")
                        result = self.upload_document(file_path)
                        print("📋 Upload Result:")
                        print(json.dumps(result, indent=2, ensure_ascii=False))
                
                elif user_input == "/clear":
                    try:
                        response = requests.delete(f"{self.embeddings_url}/collections/clear", timeout=10)
                        if response.status_code == 200:
                            print("🧹 Collection cleared successfully")
                        else:
                            print(f"❌ Clear failed: {response.text}")
                    except Exception as e:
                        print(f"❌ Clear error: {e}")
                
                else:
                    # 通常の質問として処理
                    result = self.query_with_context(user_input)
                    
                    print(f"\n🤖 Assistant: {result['answer']}")
                    
                    if result['contexts']:
                        print(f"\n📚 Based on {result['context_count']} document(s):")
                        for i, ctx in enumerate(result['contexts'], 1):
                            print(f"  [{i}] {ctx['source']} (score: {ctx['score']:.3f})")
            
            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                break
            except Exception as e:
                print(f"❌ Error: {e}")

def main():
    rag = RAGClient()
    
    if len(sys.argv) > 1:
        # コマンドライン引数がある場合は単発クエリ
        question = " ".join(sys.argv[1:])
        result = rag.query_with_context(question)
        
        print("="*60)
        print(f"質問: {result['question']}")
        print("-"*60)
        print(f"回答: {result['answer']}")
        
        if result['contexts']:
            print(f"\n参考資料 ({result['context_count']}件):")
            for i, ctx in enumerate(result['contexts'], 1):
                print(f"  [{i}] {ctx['source']} (スコア: {ctx['score']:.3f})")
        print("="*60)
    else:
        # 対話モード
        rag.interactive_mode()

if __name__ == "__main__":
    main()