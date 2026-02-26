# CHECKLIST.md — Sequential Setup Steps

Execute these steps in order. Each step has a verification command.

---

## Step 1: Create webhook server

Copy `TEMPLATES/webhook-server.js` to `workspace/health/webhook-server.js`.
Copy `TEMPLATES/start-server.sh` to `workspace/health/start-server.sh`.
Run: `chmod +x workspace/health/start-server.sh`

**Verify:** `curl http://localhost:8090/health` returns `{"status":"ok"}`

---

## Step 2: Expose port in docker-compose

Apply the patch from `TEMPLATES/docker-compose.patch` to your `docker-compose.yml`.
The patch adds port 8090 and auto-starts the webhook server.

Restart the container: `docker-compose restart`

**Verify:** Webhook responds from outside the container.

---

## Step 3: Configure Health Auto Export

On iPhone: Health Auto Export → Automations → Add Automation
- URL: `http://YOUR_TAILSCALE_IP:8090/health-data`
- Interval: every 3 hours
- Metrics: see SPEC.md § Metrics

Run once manually to test. Check `workspace/health/data/` for a new JSON file.

**Verify:** `ls workspace/health/data/` shows a `health-*.json` file.

---

## Step 4: Set your baselines

Copy `TEMPLATES/baselines.json` to `workspace/health/baselines.json`.
Edit the file with your personal values.

If you have no prior data, track for 2 weeks first and ask your agent to compute averages from the exported files.

**Verify:** `cat workspace/health/baselines.json` shows your personal values.

---

## Step 5: Configure morning briefing cron job

In OpenClaw, create a cron job:
- Schedule: `30 7 * * *` (7:30 AM — set `tz` to your timezone, e.g. `Europe/Amsterdam`)
- Prompt: contents of `PROMPTS/morning-briefing.txt`
- Session: isolated

**Verify:** Trigger the job manually and confirm you receive a briefing on Telegram.

---

## Step 6: Configure stress sentinel cron job

In OpenClaw, create a cron job:
- Schedule: every 30 minutes during waking hours
- Prompt: contents of `PROMPTS/stress-sentinel.txt`
- Session: isolated

**Verify:** Trigger manually. Confirm it runs silently when metrics are normal.

---

## Step 7: Configure data retention

Add `TEMPLATES/retention-cron.sh` as a daily cron job (any time, e.g. 3 AM).
It deletes health exports older than 30 days.

**Verify:** `bash TEMPLATES/retention-cron.sh` runs without errors.

---

## Step 8: Run smoke tests

```bash
bash TESTS/smoke-test.sh
```

All checks should pass. If any fail, see SPEC.md for troubleshooting.

---

## Step 9: Harden the setup

Read `SECURITY.md` and apply the recommended settings.

---

## Done

Your health agent is running. It will:
- Brief you every morning at 7:30
- Monitor stress signals every 30 minutes (silently unless something's wrong)
- Delete exports older than 30 days automatically
- Never expose your data to the public internet
