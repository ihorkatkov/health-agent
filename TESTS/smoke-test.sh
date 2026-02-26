#!/bin/bash
# Smoke test — run after setup to verify everything works
# Usage: bash TESTS/smoke-test.sh

WEBHOOK_URL="${HEALTH_WEBHOOK_URL:-http://localhost:8090}"
PASS=0
FAIL=0

check() {
  local name="$1"
  local result="$2"
  if [ "$result" = "ok" ]; then
    echo "✅ $name"
    PASS=$((PASS+1))
  else
    echo "❌ $name: $result"
    FAIL=$((FAIL+1))
  fi
}

# 1. Webhook health check
status=$(curl -sf "$WEBHOOK_URL/health" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('status','fail'))" 2>/dev/null || echo "unreachable")
check "Webhook is running" "$status"

# 2. Webhook accepts POST
post_result=$(curl -sf -X POST "$WEBHOOK_URL/health-data" \
  -H "Content-Type: application/json" \
  -d @TESTS/sample-payload.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('status','fail'))" 2>/dev/null || echo "fail")
check "Webhook accepts health data" "$post_result"

# 3. Data directory exists
DATA_DIR="/home/node/.openclaw/workspace/health/data"
[ -d "$DATA_DIR" ] && check "Data directory exists" "ok" || check "Data directory exists" "missing: $DATA_DIR"

# 4. Baselines file exists
BASELINES="/home/node/.openclaw/workspace/health/baselines.json"
[ -f "$BASELINES" ] && check "Baselines file exists" "ok" || check "Baselines file exists" "missing — copy from TEMPLATES/baselines.json"

# 5. At least one health export exists
count=$(ls "$DATA_DIR"/health-*.json 2>/dev/null | wc -l)
[ "$count" -gt 0 ] && check "Health data exported ($count files)" "ok" || check "Health data exported" "0 files — trigger Health Auto Export manually"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && echo "✅ All checks passed — setup complete." || echo "⚠️  Fix the failed checks before continuing."
