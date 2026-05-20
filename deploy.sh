command -v docker >/dev/null 2>&1 || fail "Docker is not installed or not available"
docker compose version >/dev/null 2>&1 || fail "Docker Compose plugin is not installed"

[[ -f "$COMPOSE_FILE" ]] || fail "$COMPOSE_FILE not found. Run the script from the project root."

log "Checking Docker daemon..."
docker info >/dev/null 2>&1 || fail "Docker daemon is not running. Try: sudo systemctl start docker"

log "Stopping old containers..."
docker compose -p "$PROJECT_NAME" down --remove-orphans

if [[ "$BUILD_MODE" == "--no-cache" ]]; then
  log "Building images without cache..."
  docker compose -p "$PROJECT_NAME" build --no-cache
else
  log "Building images using Docker cache..."
  docker compose -p "$PROJECT_NAME" build
fi

log "Starting services..."

log "Waiting for backend/frontend to become available..."

log "Checking health..."

log "Current container status:"

log "Done. Open:"