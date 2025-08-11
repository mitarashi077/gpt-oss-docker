from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
import PyPDF2
import io
import uuid
import os
import time
from typing import List
import numpy as np
import logging

# ログ設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Local RAG Embeddings Server", version="1.0.0")

# CORS設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# グローバル変数
model = None
qdrant = None
COLLECTION_NAME = "documents"

# 初期化
def initialize():
    global model, qdrant
    try:
        logger.info("Initializing SentenceTransformer model...")
        model = SentenceTransformer('all-MiniLM-L6-v2')
        logger.info("Model loaded successfully")
        
        qdrant_host = os.getenv("QDRANT_HOST", "http://localhost:6333").replace("http://", "")
        logger.info(f"Connecting to Qdrant at {qdrant_host}")
        qdrant = QdrantClient(host=qdrant_host.split(':')[0], port=int(qdrant_host.split(':')[1]) if ':' in qdrant_host else 6333)
        logger.info("Qdrant client initialized")
        
        # コレクションの作成（存在しない場合）
        try:
            qdrant.create_collection(
                collection_name=COLLECTION_NAME,
                vectors_config=VectorParams(size=384, distance=Distance.COSINE)
            )
            logger.info(f"Collection '{COLLECTION_NAME}' created")
        except Exception as e:
            logger.info(f"Collection '{COLLECTION_NAME}' already exists or error: {e}")
            
    except Exception as e:
        logger.error(f"Initialization error: {e}")
        raise e

@app.on_event("startup")
async def startup_event():
    """起動時の初期化"""
    max_retries = 5
    for attempt in range(max_retries):
        try:
            initialize()
            logger.info("Server initialized successfully")
            break
        except Exception as e:
            if attempt < max_retries - 1:
                logger.warning(f"Initialization attempt {attempt + 1} failed: {e}. Retrying in 5 seconds...")
                time.sleep(5)
            else:
                logger.error(f"Failed to initialize after {max_retries} attempts: {e}")
                raise e

@app.get("/health")
async def health():
    """ヘルスチェックエンドポイント"""
    try:
        if model is None or qdrant is None:
            return JSONResponse(
                status_code=503,
                content={"status": "unhealthy", "error": "Services not initialized"}
            )
        
        # Qdrantの接続確認
        qdrant.get_collection(COLLECTION_NAME)
        
        return {
            "status": "healthy",
            "qdrant": "connected",
            "model": "loaded",
            "collection": COLLECTION_NAME
        }
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={"status": "unhealthy", "error": str(e)}
        )

@app.post("/upload")
async def upload_document(file: UploadFile = File(...)):
    """文書をアップロードしてベクトル化"""
    try:
        if model is None or qdrant is None:
            raise HTTPException(status_code=503, detail="Services not initialized")
        
        logger.info(f"Uploading file: {file.filename}")
        
        # ファイル内容の読み取り
        content = await file.read()
        
        if file.filename.lower().endswith('.pdf'):
            # PDFの処理
            try:
                pdf_reader = PyPDF2.PdfReader(io.BytesIO(content))
                text = ""
                for page_num, page in enumerate(pdf_reader.pages):
                    page_text = page.extract_text()
                    text += f"\n--- Page {page_num + 1} ---\n" + page_text
            except Exception as e:
                logger.error(f"PDF processing error: {e}")
                raise HTTPException(status_code=400, detail=f"PDF processing failed: {e}")
        else:
            # テキストファイルの処理
            try:
                text = content.decode('utf-8')
            except UnicodeDecodeError:
                try:
                    text = content.decode('cp932')  # Shift-JIS
                except UnicodeDecodeError:
                    text = content.decode('utf-8', errors='ignore')
        
        # テキストが空の場合のチェック
        if not text.strip():
            raise HTTPException(status_code=400, detail="Document contains no readable text")
        
        # チャンク分割（改良版）
        chunk_size = 500
        overlap = 50
        chunks = []
        
        # 段落単位での分割を試行
        paragraphs = text.split('\n\n')
        current_chunk = ""
        
        for paragraph in paragraphs:
            if len(current_chunk) + len(paragraph) <= chunk_size:
                current_chunk += paragraph + "\n\n"
            else:
                if current_chunk.strip():
                    chunks.append(current_chunk.strip())
                current_chunk = paragraph + "\n\n"
        
        if current_chunk.strip():
            chunks.append(current_chunk.strip())
        
        # チャンクが少ない場合は固定サイズで分割
        if len(chunks) < 2:
            chunks = []
            for i in range(0, len(text), chunk_size - overlap):
                chunk = text[i:i + chunk_size]
                if chunk.strip():
                    chunks.append(chunk.strip())
        
        logger.info(f"Split into {len(chunks)} chunks")
        
        # エンベディング生成
        embeddings = model.encode(chunks, show_progress_bar=False)
        
        # Qdrantに保存
        points = []
        for i, (chunk, embedding) in enumerate(zip(chunks, embeddings)):
            points.append(PointStruct(
                id=str(uuid.uuid4()),
                vector=embedding.tolist(),
                payload={
                    "text": chunk,
                    "source": file.filename,
                    "chunk_id": i,
                    "upload_timestamp": time.time()
                }
            ))
        
        qdrant.upsert(collection_name=COLLECTION_NAME, points=points)
        logger.info(f"Uploaded {len(chunks)} chunks from {file.filename}")
        
        return JSONResponse({
            "message": f"Successfully uploaded {len(chunks)} chunks from {file.filename}",
            "chunks": len(chunks),
            "filename": file.filename
        })
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Upload error: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {e}")

@app.post("/search")
async def search_documents(query: str, limit: int = 5, min_score: float = 0.0):
    """類似文書を検索"""
    try:
        if model is None or qdrant is None:
            raise HTTPException(status_code=503, detail="Services not initialized")
        
        logger.info(f"Searching for: '{query}' with limit {limit}")
        
        # クエリのベクトル化
        query_vector = model.encode(query).tolist()
        
        # Qdrantで検索
        results = qdrant.search(
            collection_name=COLLECTION_NAME,
            query_vector=query_vector,
            limit=limit,
            score_threshold=min_score
        )
        
        search_results = []
        for hit in results:
            search_results.append({
                "text": hit.payload["text"],
                "score": hit.score,
                "source": hit.payload.get("source", "unknown"),
                "chunk_id": hit.payload.get("chunk_id", 0)
            })
        
        logger.info(f"Found {len(search_results)} results")
        
        return {
            "query": query,
            "results": search_results,
            "count": len(search_results)
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Search error: {e}")
        raise HTTPException(status_code=500, detail=f"Search failed: {e}")

@app.get("/collections")
async def get_collections():
    """コレクション情報を取得"""
    try:
        if qdrant is None:
            raise HTTPException(status_code=503, detail="Qdrant not initialized")
        
        collection_info = qdrant.get_collection(COLLECTION_NAME)
        return {
            "collection_name": COLLECTION_NAME,
            "points_count": collection_info.points_count,
            "status": collection_info.status
        }
        
    except Exception as e:
        logger.error(f"Collection info error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get collection info: {e}")

@app.delete("/collections/clear")
async def clear_collection():
    """コレクションをクリア"""
    try:
        if qdrant is None:
            raise HTTPException(status_code=503, detail="Qdrant not initialized")
        
        qdrant.delete_collection(COLLECTION_NAME)
        
        # コレクションを再作成
        qdrant.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(size=384, distance=Distance.COSINE)
        )
        
        logger.info(f"Collection '{COLLECTION_NAME}' cleared and recreated")
        
        return {"message": f"Collection '{COLLECTION_NAME}' cleared successfully"}
        
    except Exception as e:
        logger.error(f"Clear collection error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to clear collection: {e}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)