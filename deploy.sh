#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="myownai"
COMPOSE_FILE="docker-compose.yml"
BUILD_MODE="${1:-}"

log() { echo "[deploy] $*"; }
fail() { echo "[deploy] ERROR: $*" >&2; exit 1; }

command -v docker >/dev/null 2>&1 || fail "Docker is not installed or not available"
docker compose version >/dev/null 2>&1 || fail "Docker Compose plugin is not installed"

[[ -f "$COMPOSE_FILE" ]] || fail "$COMPOSE_FILE not found. Run the script from the project root."

log "Checking Docker daemon..."
docker info >/dev/null 2>&1 || fail "Docker daemon is not running. Try: sudo systemctl start docker"

log "Stopping old containers..."
docker compose -p myaitestproject down --remove-orphans 2>/dev/null || true
docker compose -p "$PROJECT_NAME" down --remove-orphans

if [[ "$BUILD_MODE" == "--no-cache" ]]; then
  log "Building images without cache..."
  docker compose -p "$PROJECT_NAME" build --no-cache
else
  log "Building images using Docker cache..."
  docker compose -p "$PROJECT_NAME" build
fi

log "Starting services..."
docker compose -p "$PROJECT_NAME" up -d

log "Waiting for backend/frontend to become available..."
./scripts/healthcheck.sh

log "Current container status:"
docker compose -p "$PROJECT_NAME" ps

log "Done. Open:"
log "  Frontend: http://localhost:5173"
log "  Backend:  http://localhost:8000"
log "  Qdrant:   http://localhost:6333"
