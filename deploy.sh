#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="myownai"
COMPOSE_FILE="docker-compose.yml"
BUILD_MODE="${1:-}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[deploy]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
fail() { echo -e "${RED}[error]${NC} $1"; exit 1; }

cd "$(dirname "$0")"

command -v docker >/dev/null 2>&1 || fail "Docker не встановлений або недоступний"
docker compose version >/dev/null 2>&1 || fail "Docker Compose plugin не встановлений"

[[ -f "$COMPOSE_FILE" ]] || fail "Не знайдено $COMPOSE_FILE. Запусти скрипт з кореня проєкту."

log "Перевіряю Docker daemon..."
docker info >/dev/null 2>&1 || fail "Docker daemon не запущений. Спробуй: sudo systemctl start docker"

log "Зупиняю старі контейнери..."
docker compose -p "$PROJECT_NAME" down --remove-orphans

if [[ "$BUILD_MODE" == "--no-cache" ]]; then
  log "Збираю images без кешу..."
  docker compose -p "$PROJECT_NAME" build --no-cache
else
  log "Збираю images з Docker cache..."
  docker compose -p "$PROJECT_NAME" build
fi

log "Стартую сервіси..."
docker compose -p "$PROJECT_NAME" up -d

log "Чекаю, поки backend/frontend піднімуться..."
sleep 5

log "Перевіряю health..."
bash scripts/healthcheck.sh

log "Поточний статус контейнерів:"
docker compose -p "$PROJECT_NAME" ps

log "Готово. Відкрий:"
echo "  Frontend: http://localhost:5173"
echo "  Backend:  http://localhost:8000/docs"
echo "  Qdrant:   http://localhost:6333/dashboard"
