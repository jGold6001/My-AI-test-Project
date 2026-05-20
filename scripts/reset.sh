#!/usr/bin/env bash
set -euo pipefail
PROJECT_NAME="myownai"

echo "⚠️  This will stop containers and remove local Qdrant storage."
read -r -p "Continue? [y/N] " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

docker compose -p "$PROJECT_NAME" down --remove-orphans
sudo rm -rf qdrant_storage
mkdir -p qdrant_storage

echo "✅ Reset done. Run: ./deploy.sh"
