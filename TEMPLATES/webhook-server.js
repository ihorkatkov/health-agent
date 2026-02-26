// Health webhook server for OpenClaw
// Receives Apple Watch data from Health Auto Export app
// Place at: workspace/health/webhook-server.js

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.HEALTH_WEBHOOK_PORT || 8090;
const DATA_DIR = path.join(__dirname, 'data');
const MAX_BODY_BYTES = 10 * 1024 * 1024; // 10MB safety cap

if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }));
  }

  if (req.method === 'POST' && (req.url === '/health-data' || req.url === '/api/data')) {
    let body = '';
    let size = 0;
    req.on('data', chunk => {
      size += chunk.length;
      if (size > MAX_BODY_BYTES) { req.destroy(); return; }
      body += chunk;
    });
    req.on('end', () => {
      try {
        const cleaned = body.replace(/^\uFEFF/, '').trim(); // Strip BOM
        const data = JSON.parse(cleaned);
        const ts = new Date().toISOString().replace(/[:.]/g, '-');
        const filename = `health-${ts}.json`;
        fs.writeFileSync(path.join(DATA_DIR, filename), JSON.stringify(data, null, 2));
        const today = new Date().toISOString().slice(0, 10);
        fs.appendFileSync(
          path.join(DATA_DIR, `daily-${today}.jsonl`),
          JSON.stringify({ received: new Date().toISOString(), ...data }) + '\n'
        );
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', file: filename }));
      } catch (e) {
        const ts = new Date().toISOString().replace(/[:.]/g, '-');
        fs.writeFileSync(path.join(DATA_DIR, `raw-${ts}.txt`), body.slice(0, 1000));
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON' }));
      }
    });
    return;
  }

  res.writeHead(404);
  res.end('Not found');
});

server.listen(PORT, '0.0.0.0', () => console.log(`Health webhook :${PORT}`));
