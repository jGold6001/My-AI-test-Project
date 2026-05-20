#!/usr/bin/env bash
set -euo pipefail

docker compose -p myaitestproject down --remove-orphans 2>/dev/null || true
docker compose -p myownai up -d
