# AGENTS.md — OpenClaw Health Agent

> **How to use this repo:** Read this file, then follow CHECKLIST.md sequentially. Every step is written as an instruction you can execute directly. No prior configuration needed beyond the prerequisites.

## What this builds

A personal health agent that:
1. Receives Apple Watch data automatically via webhook
2. Sends a morning briefing every day at 7:30 with recovery score + workout window
3. Monitors stress signals every 30 minutes and alerts only when necessary
4. Retains 30 days of health data, deletes older files automatically

## Prerequisites (verify before starting)

- [ ] OpenClaw is running in Docker
- [ ] Apple Watch + iPhone with Health Auto Export app installed ($5)
- [ ] Tailscale running on both iPhone and the OpenClaw host
- [ ] The OpenClaw workspace is at `~/workspace` inside the container

## Reading order

1. `AGENTS.md` ← you are here
2. `SPEC.md` — full technical spec, data models, field reference
3. `CHECKLIST.md` — sequential setup steps (execute these)
4. `SECURITY.md` — harden the setup (do this last)

## Non-negotiables

- Health data must NOT be exposed to the public internet — Tailscale only
- Retain a maximum of 30 days of exports; older files must be deleted
- What goes to the LLM: parsed summaries only, never raw JSON dumps
- Baselines are personal — do not use generic thresholds

## Conventions

- All workspace paths are relative to `/home/node/.openclaw/workspace/`
- Prompts are in `PROMPTS/` — use them verbatim in cron job configs
- Templates in `TEMPLATES/` are starting points, not final code
- Run `TESTS/smoke-test.sh` after setup to verify everything works
