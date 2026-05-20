.PHONY: deploy deploy-clean up down logs backend-logs frontend-logs health reset pull-models

deploy:
	./deploy.sh

deploy-clean:
	./deploy.sh --no-cache

up:
	docker compose -p myownai up -d --build

down:
	docker compose -p myownai down --remove-orphans

logs:
	./scripts/logs.sh

backend-logs:
	./scripts/logs.sh backend

frontend-logs:
	./scripts/logs.sh frontend

health:
	./scripts/healthcheck.sh

reset:
	./scripts/reset.sh

pull-models:
	docker exec -it myownai-ollama ollama pull llama3
	docker exec -it myownai-ollama ollama pull nomic-embed-text
