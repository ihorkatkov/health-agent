# SECURITY.md — Hardening Guide

## Non-negotiables

1. **Private network only** — the webhook (port 8090) must NOT be exposed to the public internet
2. **Tailscale** — use Tailscale for iPhone → server connectivity, not port forwarding
3. **Encryption at rest** — enable full-disk encryption on the server (FileVault / LUKS)
4. **30-day retention** — run `TEMPLATES/retention-cron.sh` daily

## What goes to the LLM

The agent sends summaries, not raw data:
- ✅ Parsed metric values (numbers, dates)
- ✅ Recovery assessment text
- ❌ Raw JSON exports — never sent to LLM API
- ❌ Health history dumps

## Webhook hardening

- Port 8090 should only be accessible via Tailscale IP or your private network
- Add `MAX_BODY_BYTES` cap in webhook-server.js (included in template)
  
## Telegram delivery

Morning briefings and alerts go to Telegram. The message contains:
- Recovery score (🟢/🟡/🔴)
- Key metrics (HR, HRV, sleep hours)
- Calendar summary
- Workout suggestion

Health data is summarized, not raw. No biometric JSON in messages.

## What does NOT apply here

This is a personal, local-first setup. HIPAA/GDPR compliance is your responsibility if you extend this to other users.
