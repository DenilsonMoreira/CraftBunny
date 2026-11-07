import { ApiError, SupabaseStore, clientHash, rankingService } from './ranking.mjs';

export async function readBody(req) {
  if (Number(req.headers['content-length'] || 0) > 2048) throw new ApiError(413, 'too_large', 'Envio muito grande.');
  const type = String(req.headers['content-type'] || '').split(';')[0].trim().toLowerCase();
  if (type !== 'application/json') throw new ApiError(415, 'content_type', 'Envie JSON.');
  let raw = req.body;
  if (raw === undefined) {
    let size = 0; const chunks = [];
    for await (const chunk of req) {
      size += Buffer.byteLength(chunk);
      if (size > 2048) throw new ApiError(413, 'too_large', 'Envio muito grande.');
      chunks.push(Buffer.from(chunk));
    }
    raw = Buffer.concat(chunks).toString('utf8');
  }
  if (Buffer.byteLength(typeof raw === 'string' ? raw : JSON.stringify(raw)) > 2048) throw new ApiError(413, 'too_large', 'Envio muito grande.');
  let body;
  try { body = typeof raw === 'string' ? JSON.parse(raw) : raw; }
  catch { throw new ApiError(400, 'invalid_json', 'JSON inválido.'); }
  if (!body || typeof body !== 'object' || Array.isArray(body)) throw new ApiError(400, 'invalid_json', 'Envie um objeto JSON.');
  return body;
}
function allowOrigin(req, res, env, reading) {
  if (reading) { res.setHeader('Access-Control-Allow-Origin', '*'); return; }
  const origin = req.headers.origin;
  if (!origin) return; // Native Godot clients do not send browser Origin.
  const allowed = (env.ALLOWED_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean);
  for (const host of [env.VERCEL_PROJECT_PRODUCTION_URL, env.VERCEL_URL]) if (host) allowed.push('https://' + host);
  if (!allowed.includes(origin)) throw new ApiError(403, 'origin_forbidden', 'Origem não autorizada.');
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Vary', 'Origin');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}
export function handler(action, { env = process.env, store } = {}) {
  return async (req, res) => {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    try {
      const reading = action === 'list';
      allowOrigin(req, res, env, reading);
      if (req.method === 'OPTIONS') { res.statusCode = 204; res.end(); return; }
      if (req.method !== (reading ? 'GET' : 'POST')) {
        res.setHeader('Allow', reading ? 'GET, OPTIONS' : 'POST, OPTIONS');
        throw new ApiError(405, 'method_not_allowed', 'Método não permitido.');
      }
      const body = reading ? null : await readBody(req);
      const url = new URL(req.url, 'https://ranking.local');
      const service = rankingService(store || new SupabaseStore(env));
      const result = reading ? await service.list(url.searchParams.get('period') || 'all', url.searchParams.get('outcome') || 'all') :
        action === 'start' ? await service.start(body, clientHash(req, env)) : await service.submit(body);
      if (reading) res.setHeader('Cache-Control', 'public, s-maxage=30, stale-while-revalidate=60');
      res.statusCode = action === 'start' ? 201 : 200;
      res.end(JSON.stringify(result));
    } catch (error) {
      const known = error instanceof ApiError;
      res.statusCode = known ? error.status : 503;
      if (res.statusCode === 429) res.setHeader('Retry-After', '60');
      res.end(JSON.stringify({ error: known ? error.code : 'unavailable', message: known ? error.message : 'Ranking indisponível. Tente novamente.' }));
    }
  };
}
