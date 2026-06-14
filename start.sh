#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="myownai"

echo "[start] Starting containers..."

docker compose -p "$PROJECT_NAME" up -d

echo "[start] Containers started"

echo "Frontend: http://localhost:5173"
echo "Backend:  http://localhost:8000/docs"
echo "Qdrant:   http://localhost:6333/dashboard"