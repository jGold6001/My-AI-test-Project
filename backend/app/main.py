import os
import time
from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from langchain_ollama import ChatOllama, OllamaEmbeddings
from langchain_qdrant import QdrantVectorStore
from langchain_core.documents import Document
from qdrant_client import QdrantClient, models


OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
QDRANT_URL = os.getenv("QDRANT_URL", "http://localhost:6333")
COLLECTION_NAME = os.getenv("COLLECTION_NAME", "myownai_docs")
LLM_MODEL = os.getenv("LLM_MODEL", "llama3")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "nomic-embed-text")
VECTOR_SIZE = int(os.getenv("VECTOR_SIZE", "768"))  # nomic-embed-text uses 768-dimensional vectors

app = FastAPI(title="MyOwnAI Test Project")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class AskRequest(BaseModel):
    question: str


class IngestRequest(BaseModel):
    texts: List[str]


embeddings = OllamaEmbeddings(
    model=EMBEDDING_MODEL,
    base_url=OLLAMA_BASE_URL,
)

client = QdrantClient(url=QDRANT_URL)


def wait_for_qdrant(retries: int = 20, delay_seconds: float = 1.0) -> None:
    """Wait until Qdrant HTTP API is ready."""
    last_error = None
    for _ in range(retries):
        try:
            client.get_collections()
            return
        except Exception as exc:  # Qdrant container may still be starting
            last_error = exc
            time.sleep(delay_seconds)
    raise RuntimeError(f"Qdrant is not ready: {last_error}")


def ensure_collection_exists() -> None:
    """Create the Qdrant collection on first startup if it does not exist yet."""
    wait_for_qdrant()

    if client.collection_exists(collection_name=COLLECTION_NAME):
        return

    client.create_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=models.VectorParams(
            size=VECTOR_SIZE,
            distance=models.Distance.COSINE,
        ),
    )


ensure_collection_exists()

vector_store = QdrantVectorStore.from_existing_collection(
    embedding=embeddings,
    collection_name=COLLECTION_NAME,
    url=QDRANT_URL,
)

llm = ChatOllama(
    model=LLM_MODEL,
    base_url=OLLAMA_BASE_URL,
    temperature=0.2,
)


@app.get("/health")
def health():
    return {
        "status": "ok",
        "stack": ["React", "FastAPI", "Ollama", "Llama 3", "LangChain", "Qdrant", "Docker"],
        "qdrant_collection": COLLECTION_NAME,
        "embedding_model": EMBEDDING_MODEL,
        "vector_size": VECTOR_SIZE,
    }


@app.post("/ingest")
def ingest(payload: IngestRequest):
    docs = [Document(page_content=text) for text in payload.texts if text.strip()]
    if not docs:
        return {"message": "No valid texts provided", "added": 0}

    try:
        vector_store.add_documents(docs)
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=(
                "Failed to add documents. Make sure Ollama is running and the embedding model "
                f"'{EMBEDDING_MODEL}' is pulled. Original error: {exc}"
            ),
        )

    return {"message": "Documents added", "added": len(docs)}


@app.post("/ask")
def ask(payload: AskRequest):
    question = payload.question.strip()
    if not question:
        return {"answer": "Please provide a question.", "sources": []}

    try:
        docs = vector_store.similarity_search(question, k=3)
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=(
                "Failed to search documents. Make sure Ollama is running and the embedding model "
                f"'{EMBEDDING_MODEL}' is pulled. Original error: {exc}"
            ),
        )

    if not docs:
        return {
            "answer": "I do not have any indexed documents yet. Add text using the Ingest form first.",
            "sources": [],
        }

    context = "\n\n".join([doc.page_content for doc in docs])

    prompt = f"""
You are a helpful local AI assistant.
Answer using the context below. If the answer is not in the context, say that you do not know.

Context:
{context}

Question:
{question}
"""

    try:
        response = llm.invoke(prompt)
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=(
                "Failed to call the LLM. Make sure Ollama is running and the model "
                f"'{LLM_MODEL}' is pulled. Original error: {exc}"
            ),
        )

    return {
        "answer": response.content,
        "sources": [doc.page_content for doc in docs],
    }
