# SPEC.md — Technical Specification

## System Overview

Three components:
1. **Webhook server** — receives Apple Watch data from Health Auto Export app
2. **Morning briefing** — daily cron job at 7:30, reads data + calendar, sends recovery score + workout window
3. **Stress sentinel** — 30-minute heartbeat, alerts only on combined HR spike + HRV drop

## Data Flow

```
Apple Watch → Health app → Health Auto Export → HTTP POST → webhook (:8090)
                                                              ↓
                                                    workspace/health/data/
                                                              ↓
                                              Cron jobs read + analyze
                                                              ↓
                                             Summary → LLM → Telegram
```

## Metrics to Export

Required metrics in Health Auto Export:
- `heart_rate` — individual readings (array)
- `resting_heart_rate` — daily value
- `heart_rate_variability` — HRV SDNN
- `blood_oxygen_saturation` — SpO2
- `sleep_analysis` — stages: totalSleep, deep, rem, core, awake, sleepStart, sleepEnd
- `respiratory_rate`
- `apple_sleeping_wrist_temperature`
- `step_count`
- `active_energy`

## Data Model

### Export file: `health-YYYY-MM-DDTHH-MM-SS-mmmZ.json`
Each export from Health Auto Export. Format varies by version — use field names above.

### Daily log: `daily-YYYY-MM-DD.jsonl`
One JSON object per export, timestamped. Used for trend analysis.

### Baselines: `workspace/health/baselines.json`
```json
{
  "resting_hr": { "baseline": 52, "alert_above": 60 },
  "hrv": { "baseline": 120, "alert_below": 80 },
  "spo2": { "baseline": 97, "alert_below": 95 },
  "sleep_hours": { "target": 7.5, "alert_below": 7.0 }
}
```

## Known Issues

### HRV/RHR export delay
Apple Health writes HRV and resting HR with a 2-3 day delay in some configurations.
**Workaround:** Use sleep quality and wrist temperature for daily decisions. Use HRV for weekly trends.

### BOM character in JSON
Health Auto Export sometimes prefixes JSON with a UTF-8 BOM (`\uFEFF`).
**Workaround:** Strip it in the webhook: `body.replace(/^\uFEFF/, '')`

### iPhone network connectivity
The webhook must be reachable from iPhone.
**Solution:** Use Tailscale. The iPhone and server must both be on the same Tailscale network.

## Storage

- Each export: 500KB–5MB
- At 3 exports/day: ~5–15MB/day
- Retention: 30 days → max ~450MB
- Run retention cron daily to clean up old files
