# Local CI/CD для MyOwnAI

Це простий локальний deploy flow для тестового AI/RAG проєкту.

## Одна команда для деплою

З кореня проєкту:

```bash
./deploy.sh
```

Або через Makefile:

```bash
make deploy
```

Команда робить:

1. Перевіряє Docker і Docker Compose.
2. Зупиняє старі контейнери.
3. Перезбирає images.
4. Запускає backend, frontend, Qdrant, Ollama.
5. Перевіряє health endpoints.
6. Показує статус контейнерів.

## Перший запуск моделей Ollama

```bash
make pull-models
```

Або вручну:

```bash
docker exec -it myownai-ollama ollama pull llama3
docker exec -it myownai-ollama ollama pull nomic-embed-text
```

## Корисні команди

```bash
make logs          # всі логи
make backend-logs  # тільки backend
make frontend-logs # тільки frontend
make health        # перевірка сервісів
make down          # зупинити проєкт
make reset         # скинути Qdrant storage
```

## URLs

```text
Frontend: http://localhost:5173
Backend:  http://localhost:8000/docs
Qdrant:   http://localhost:6333/dashboard
```

## Як використовувати після кожного фіксу

1. Вносиш зміни в код.
2. Зберігаєш файли.
3. Запускаєш:

```bash
./deploy.sh
```

Це і є локальний CI/CD для development середовища.


## Clean rebuild

Якщо змінив `requirements.txt` або Dockerfile і треба повністю перезібрати образи:

```bash
./deploy.sh --no-cache
# або
make deploy-clean
```
