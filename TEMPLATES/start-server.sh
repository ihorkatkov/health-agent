#!/bin/bash
# Start the health webhook server
# Place at: workspace/health/start-server.sh

cd "$(dirname "$0")"

if [ -f server.pid ] && kill -0 "$(cat server.pid)" 2>/dev/null; then
  echo "Health webhook already running (pid: $(cat server.pid))"
  exit 0
fi

node webhook-server.js >> server.log 2>&1 &
echo $! > server.pid
echo "Health webhook started (pid: $!)"
