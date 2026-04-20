import crypto from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const gatewayRoot = path.resolve(__dirname, '..');
const backendRoot = path.resolve(gatewayRoot, '..');
const workspaceRoot = path.resolve(backendRoot, '..');

dotenv.config({ path: path.join(workspaceRoot, '.env') });
dotenv.config({ path: path.join(backendRoot, '.env'), override: false });
dotenv.config({ path: path.join(gatewayRoot, '.env'), override: false });

const port = Number.parseInt(process.env.PORT ?? '8787', 10);
const pythonTwinUrl = process.env.PYTHON_TWIN_URL ?? 'http://127.0.0.1:8000';

const app = express();

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/api/health', (_request, response) => {
  response.json({ ok: true, proxy: 'ts-gateway', pythonTwinUrl });
});

app.post('/api/chat', async (request, response) => {
  const sessionId =
    typeof request.body?.sessionId === 'string' &&
        request.body.sessionId.trim().length > 0
      ? request.body.sessionId.trim()
      : crypto.randomUUID();
  const message =
    typeof request.body?.message === 'string' ? request.body.message.trim() : '';
  const retrievalContext =
    typeof request.body?.retrievalContext === 'string'
      ? request.body.retrievalContext
      : '';

  if (message.length == 0) {
    response.status(400).json({ error: 'message is required' });
    return;
  }

  try {
    const upstreamResponse = await fetch(`${pythonTwinUrl}/twin/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        sessionId,
        message,
        retrievalContext,
      }),
    });

    const payload = await upstreamResponse.json();
    if (!upstreamResponse.ok) {
      const detail =
        payload && typeof payload === 'object' && typeof payload.detail === 'string'
          ? payload.detail
          : 'The python twin backend could not complete the request.';
      response.status(upstreamResponse.status).json({ error: detail });
      return;
    }

    const reply = payload && typeof payload.reply === 'string' ? payload.reply.trim() : '';
    if (reply.length === 0) {
      response.status(502).json({ error: 'The python twin backend returned an empty reply.' });
      return;
    }

    response.json({
      sessionId,
      reply,
    });
  } catch (error) {
    console.error('Twin gateway request failed', error);
    response.status(502).json({
      error: 'The python twin backend could not complete the request.',
    });
  }
});

app.listen(port, () => {
  console.log(`Twin gateway listening on http://localhost:${port} -> ${pythonTwinUrl}`);
});