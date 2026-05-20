# MyOwnAI Test Project

Test local AI/RAG project using:

- Frontend: React + Vite
- Backend: FastAPI
- LLM Runtime: Ollama
- Model: Llama 3
- RAG: LangChain
- Vector DB: Qdrant
- Infra: Docker Compose

## Start

```bash
docker compose up --build
```

## Pull models inside Ollama container

In a second terminal:

```bash
docker exec -it myownai-ollama ollama pull llama3
docker exec -it myownai-ollama ollama pull nomic-embed-text
```

## Open

Frontend:

```text
http://localhost:5173
```

Backend docs:

```text
http://localhost:8000/docs
```

Qdrant dashboard/API:

```text
http://localhost:6333/dashboard
```

## How to test

1. Open frontend.
2. Click `Add to Qdrant`.
3. Click `Ask AI`.
4. The backend will search Qdrant and ask Llama 3 through Ollama.

## Notes

First model pull can take time and disk space. If your machine is weak, use a smaller Ollama model, for example `llama3.2:3b`, and change `LLM_MODEL` in `docker-compose.yml`.


## Fix notes

The backend now creates the Qdrant collection `myownai_docs` automatically on startup.
For `nomic-embed-text`, the default vector size is `768`. If you change the embedding model, update `VECTOR_SIZE` in `docker-compose.yml`.

If you already started the old version and Qdrant storage contains a broken/incompatible collection, reset it with:

```bash
docker compose down
sudo rm -rf qdrant_storage
docker compose up --build
```

## Local CI/CD

Deploy after every fix with one command:

```bash
./deploy.sh
```

Or:

```bash
make deploy
```

More commands are documented in `README_CICD.md`.
