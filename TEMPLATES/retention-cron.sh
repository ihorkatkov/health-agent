#!/bin/bash
# Delete health exports older than 30 days
# Schedule as a daily cron job (e.g., 3:00 AM)

DATA_DIR="/home/node/.openclaw/workspace/health/data"
RETENTION_DAYS=30

if [ ! -d "$DATA_DIR" ]; then
  echo "Data directory not found: $DATA_DIR"
  exit 1
fi

deleted=$(find "$DATA_DIR" -name "health-*.json" -mtime +${RETENTION_DAYS} -print -delete | wc -l)
deleted_jsonl=$(find "$DATA_DIR" -name "daily-*.jsonl" -mtime +${RETENTION_DAYS} -print -delete | wc -l)

echo "Retention cleanup: deleted $deleted exports, $deleted_jsonl daily logs older than ${RETENTION_DAYS} days"
