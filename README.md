# openclaw-health-agent

> **This repo is written for agents, not humans.**
> Point your OpenClaw agent at it and say: *"Set up the health agent from github.com/ihorkatkov/health-agent"*
> The agent reads AGENTS.md → CHECKLIST.md → executes each step → your health agent is running.

No manual configuration. No copy-pasting. The agent reads the spec and applies it to your setup.

---

## What you get

- Morning briefing at 7:30 AM: sleep, HRV, resting HR, recovery score, workout window
- Stress sentinel every 30 min: silent unless something is actually wrong
- 30-day data retention, automatic cleanup
- Everything local — no cloud, no subscriptions

## Cost

- $5 one-time: Health Auto Export app
- $0: Everything else (OpenClaw is open-source, Apple Watch data is yours)

## Stack

- [OpenClaw](https://github.com/openclaw/openclaw) — agent runtime
- Apple Watch + Health Auto Export — data source
- Tailscale — private network (iPhone → server)
- Your calendar (Google Calendar via gog CLI, or any OpenClaw connector)

## How to use

Tell your OpenClaw agent:

```
Set up the health agent from github.com/ihorkatkov/health-agent.
Read AGENTS.md first, then follow CHECKLIST.md step by step.
```

The agent handles the rest.

## Background

Built by [@ihor_katkov](https://x.com/ihor_katkov).
