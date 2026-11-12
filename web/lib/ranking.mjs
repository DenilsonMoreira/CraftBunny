import { createHash, createHmac, randomBytes, randomUUID } from 'node:crypto';

export const GAME_VERSION = '0.4.0';
export const MAX_CARROTS = 200;
export const VERSION_LIMITS = Object.freeze({'0.3.4':139,'0.4.0':200});
export class ApiError extends Error {
  constructor(status, code, message) { super(message); this.status = status; this.code = code; }
}
export const hash = token => createHash('sha256').update(token).digest('hex');
export function validateVersion(body) {
  if (typeof body.game_version!=='string' || !Object.hasOwn(VERSION_LIMITS,body.game_version)) throw new ApiError(422, 'unsupported_version', 'Atualize o jogo para enviar seu recorde.');
}
export function validateScore(body) {
  validateVersion(body);
  if (typeof body.initials !== 'string' || !/^[A-Z]{3}$/.test(body.initials) ||
      !Number.isInteger(body.carrots) || body.carrots < 1 || body.carrots > VERSION_LIMITS[body.game_version] ||
      typeof body.won !== 'boolean' || !Number.isInteger(body.duration_ms) ||
      body.duration_ms < 1000 || body.duration_ms > 21600000 ||
      typeof body.run_id !== 'string' || !/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(body.run_id) ||
      typeof body.token !== 'string' || !/^[A-Za-z0-9_-]{43}$/.test(body.token)) {
    throw new ApiError(422, 'invalid_score', 'Os dados do recorde são inválidos.');
  }
}
export class SupabaseStore {
  constructor(env = process.env, fetcher = fetch) {
    const url = env.SUPABASE_URL;
    const key = env.SUPABASE_SECRET_KEY || env.SUPABASE_SERVICE_ROLE_KEY;
    if (!url || !key || key === 'CONFIGURE_NO_SERVIDOR' || !url.startsWith('https://') || url.includes('SEU-PROJETO')) {
      throw new ApiError(503, 'not_configured', 'O ranking global ainda está sendo preparado.');
    }
    this.url = new URL(url).origin; this.key = key; this.fetcher = fetcher;
  }
  async rpc(name, params) {
    const downloading=['cb_download_attempt','cb_download_use_code'].includes(name);
    let response;
    try {
      const headers = { apikey: this.key, 'Content-Type': 'application/json' };
      if (!this.key.startsWith('sb_secret_')) headers.Authorization = 'Bearer ' + this.key;
      response = await this.fetcher(this.url + '/rest/v1/rpc/' + name, {
        method: 'POST', headers,
        body: JSON.stringify(params), signal: AbortSignal.timeout(8000)
      });
    } catch { throw new ApiError(503, downloading?'download_database_unavailable':'unavailable', downloading?'Não foi possível conectar ao banco do download. Tente novamente em instantes.':'Ranking indisponível. Tente novamente em instantes.'); }
    let data;
    try { data = await response.json(); } catch { throw new ApiError(503, downloading?'download_database_unavailable':'unavailable', downloading?'O banco do download retornou uma resposta inválida.':'Resposta inválida do serviço de ranking.'); }
    if (!response.ok) {
      const errors = {
        rate_limited: [429, 'Muitas tentativas. Aguarde um pouco.'],
        invalid_run: [401, 'A tentativa online não é válida.'],
        expired_run: [410, 'A tentativa online expirou.'],
        conflicting_result: [409, 'Esta tentativa já possui outro resultado.'],
        implausible_run: [422, 'O resultado não corresponde à duração da tentativa.'],
        invalid_score: [422, 'Recorde inválido.'], invalid_filter: [422, 'Filtro inválido.'],
        download_rate_limited: [429, 'Muitas tentativas de código. Aguarde alguns minutos.'],
        download_otp_used: [409, 'Este código já foi usado. Aguarde o próximo no Authenticator.']
      };
      const known = errors[data?.message];
      if (known) throw new ApiError(known[0], data.message, known[1]);
      if(downloading){
        if(['PGRST202','42883','42P01','3F000'].includes(data?.code))throw new ApiError(503,'download_migration_required','A configuração do banco do download está incompleta. O responsável deve aplicar a migração de download no Supabase conectado à Vercel.');
        if(response.status===401 || response.status===403 || ['42501','PGRST301','PGRST302'].includes(data?.code))throw new ApiError(503,'download_database_permissions','O servidor não tem permissão para liberar o download. O responsável deve conferir a chave do servidor e as permissões da migração.');
        throw new ApiError(503,'download_database_unavailable','O banco do download está indisponível. Tente novamente em instantes.');
      }
      throw new ApiError(503, 'unavailable', 'Não foi possível acessar o ranking.');
    }
    return data;
  }
}
export function rankingService(store) {
  return {
    async start(body, clientHash) {
      validateVersion(body);
      const token = randomBytes(32).toString('base64url');
      const result = await store.rpc('cb_start_run', {
        p_id: randomUUID(), p_token_hash: hash(token), p_client_hash: clientHash, p_game_version: body.game_version
      });
      return { ...result, token };
    },
    async submit(body) {
      validateScore(body);
      return store.rpc('cb_submit_score', {
        p_id: body.run_id, p_token_hash: hash(body.token), p_initials: body.initials,
        p_carrots: body.carrots, p_won: body.won, p_duration_ms: body.duration_ms, p_game_version: body.game_version
      });
    },
    async list(period = 'all', outcome = 'all') {
      if (!['all', 'week'].includes(period) || !['all', 'victory'].includes(outcome)) {
        throw new ApiError(422, 'invalid_filter', 'Filtro inválido.');
      }
      return store.rpc('cb_leaderboard', { p_period: period, p_outcome: outcome });
    }
  };
}
export function clientHash(req, env = process.env) {
  const secret = env.RATE_LIMIT_SECRET;
  if (!secret || secret.length < 32 || secret.startsWith('CONFIGURE_')) throw new ApiError(503, 'not_configured', 'Envio online ainda não configurado.');
  // On Vercel, X-Forwarded-For is replaced by its trusted edge. Locally ignore it.
  const address = env.VERCEL ? String(req.headers['x-forwarded-for'] || '').split(',')[0].trim() : req.socket?.remoteAddress;
  if (!address) throw new ApiError(503, 'unavailable', 'Não foi possível iniciar a tentativa online.');
  return createHmac('sha256', secret).update(address).digest('hex');
}
