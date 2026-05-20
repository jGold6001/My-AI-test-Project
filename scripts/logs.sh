#!/usr/bin/env bash
set -euo pipefail
SERVICE="${1:-}"
PROJECT_NAME="myownai"

if [[ -z "$SERVICE" ]]; then
  docker compose -p "$PROJECT_NAME" logs -f --tail=200
else
  docker compose -p "$PROJECT_NAME" logs -f --tail=200 "$SERVICE"
fi
