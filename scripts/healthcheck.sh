#!/usr/bin/env bash
set -euo pipefail

check_url() {
  local name="$1"
  local url="$2"
  local attempts="${3:-20}"
  local sleep_seconds="${4:-2}"

  for i in $(seq 1 "$attempts"); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "✅ $name OK: $url"
      return 0
    fi
    sleep "$sleep_seconds"
  done

  echo "❌ $name не відповідає: $url"
  return 1
}

check_url "Backend" "http://localhost:8000/health" 30 2
check_url "Frontend" "http://localhost:5173" 20 2
check_url "Qdrant" "http://localhost:6333/collections" 20 2
