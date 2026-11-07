import { test, before, beforeEach, after } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createServer } from 'node:http';
import { PGlite } from '@electric-sql/pglite';
import { rankingService, SupabaseStore, ApiError, hash, clientHash } from '../lib/ranking.mjs';
import { handler } from '../lib/http.mjs';
let db, service, store;
const version = '0.3.4';
before(async () => {
  db = new PGlite();
  await db.exec('create role anon; create role authenticated; create role service_role;');
  await db.exec(await readFile(new URL('../../supabase/migrations/202611070001_global_ranking.sql', import.meta.url), 'utf8'));
  store = new SupabaseStore({ SUPABASE_URL: 'https://example.supabase.co', SUPABASE_SERVICE_ROLE_KEY: 'test-server-key' }, async (url, request) => {
    const name = new URL(url).pathname.split('/').pop();
    assert.ok(['cb_start_run', 'cb_submit_score', 'cb_leaderboard'].includes(name));
    const values = Object.values(JSON.parse(request.body));
    try {
      const { rows } = await db.query('select public.' + name + '(' + values.map((_, i) => '$' + (i + 1)).join(',') + ') as result', values);
      return Response.json(rows[0].result);
    } catch (error) { return Response.json({ message: error.message }, { status: 400 }); }
  });
  service = rankingService(store);
});
beforeEach(async () => { await db.exec('truncate craftbunny_private.scores,craftbunny_private.run_sessions'); });
after(async () => db.close());
async function begin(client = 'a'.repeat(64)) {
  const run = await service.start({ game_version: version }, client);
  await db.query("update craftbunny_private.run_sessions set started_at=now()-interval '90 seconds' where id=$1", [run.run_id]);
  return run;
}
function score(run, changes = {}) {
  return { run_id: run.run_id, token: run.token, game_version: version, initials: 'ABC', carrots: 24, won: true, duration_ms: 60000, ...changes };
}
test('migration denies anonymous table and RPC access', async () => {
  for (const role of ['anon','authenticated']) {
    const { rows } = await db.query("select has_schema_privilege($1,'craftbunny_private','usage') as tables,has_function_privilege($1,'public.cb_submit_score(uuid,text,text,integer,boolean,integer,text)','execute') as write,has_function_privilege($1,'public.cb_leaderboard(text,text)','execute') as read", [role]);
    assert.deepEqual(rows[0], { tables: false, write: false, read: false });
  }
  const { rows } = await db.query("select has_function_privilege('service_role','public.cb_start_run(uuid,text,text,text)','execute') as allowed");
  assert.equal(rows[0].allowed, true);
});
test('starts a unique run and stores hash instead of the bearer token', async () => {
  const run = await begin();
  const { rows } = await db.query('select token_hash,client_hash from craftbunny_private.run_sessions');
  assert.equal(rows[0].token_hash, hash(run.token));
  assert.notEqual(rows[0].token_hash, run.token);
  assert.equal(run.token.length, 43);
});
test('accepts a score, returns only public fields in the ranking', async () => {
  const run = await begin(); assert.equal((await service.submit(score(run))).accepted, true);
  const board = await service.list(); assert.equal(board.total, 1);
  assert.equal(board.entries[0].initials, 'ABC');
  assert.deepEqual(Object.keys(board.entries[0]).sort(), ['position','initials','carrots','won','game_version','created_at'].sort());
});
test('same result is idempotent; altered result conflicts', async () => {
  const run = await begin(); await service.submit(score(run));
  assert.equal((await service.submit(score(run))).duplicate, true);
  await assert.rejects(service.submit(score(run, { carrots: 25 })), error => error.status === 409);
  assert.equal((await service.list()).total, 1);
});
test('parallel retries produce a single persisted record', async () => {
  const run = await begin();
  const results = await Promise.all([service.submit(score(run)),service.submit(score(run))]);
  assert.equal(results.filter(r => !r.duplicate).length, 1);
  assert.equal((await service.list()).total, 1);
});
test('rejects bad token and expired run', async () => {
  const run = await begin();
  await assert.rejects(service.submit(score(run, { token: 'x'.repeat(43) })), error => error.status === 401);
  await db.query("update craftbunny_private.run_sessions set expires_at=now()-interval '1 second' where id=$1", [run.run_id]);
  await assert.rejects(service.submit(score(run)), error => error.status === 410);
});
test('rejects impossible scores, invalid initials, coercions and unsupported builds', async () => {
  const run = await begin();
  for (const change of [{ carrots: 140 }, { carrots: -1 }, { carrots: '24' }, { carrots: 1.5 }, { initials: '<X>' }, { initials: 'abc' }, { won: 'true' }, { duration_ms: 0 }, { game_version: '0.0.0' }]) {
    await assert.rejects(service.submit(score(run, change)), error => error.status === 422);
  }
  assert.equal((await service.list()).total, 0);
});
test('database constraints and RPC independently reject bypassed API checks', async () => {
  const run = await begin();
  await assert.rejects(store.rpc('cb_submit_score', { p_id: run.run_id,p_token_hash: hash(run.token),p_initials:'AAA',p_carrots:140,p_won:false,p_duration_ms:60000,p_game_version:version }), error => error.status === 422);
  await assert.rejects(db.query("insert into craftbunny_private.scores values($1,'<X>',1,false,60000,'0.3.4',now())",[run.run_id]));
});
test('server rejects future duration, instant submissions and too-fast victory', async () => {
  const run = await begin();
  await assert.rejects(service.submit(score(run, { duration_ms: 120000 })), error => error.status === 422);
  await assert.rejects(service.submit(score(run, { duration_ms: 20000 })), error => error.status === 422);
  await db.query('update craftbunny_private.run_sessions set started_at=now() where id=$1',[run.run_id]);
  await assert.rejects(service.submit(score(run, { duration_ms: 1000, won: false })), error => error.status === 422);
});
test('limits bursts transactionally and does not group different client hashes', async () => {
  for (let i=0;i<6;i++) await service.start({ game_version:version }, 'a'.repeat(64));
  await assert.rejects(service.start({ game_version:version }, 'a'.repeat(64)), error => error.status === 429);
  assert.ok((await service.start({ game_version:version }, 'b'.repeat(64))).run_id);
});
test('stable order, seven-day filter and victory filter work in SQL', async () => {
  const one = await begin(); await service.submit(score(one,{initials:'ONE',carrots:50,won:false}));
  await db.query("update craftbunny_private.scores set created_at=now()-interval '8 days' where run_id=$1",[one.run_id]);
  const two = await begin(); await service.submit(score(two,{initials:'TWO',carrots:50}));
  const three = await begin(); await service.submit(score(three,{initials:'THR',carrots:70}));
  assert.deepEqual((await service.list()).entries.map(r=>r.initials),['THR','ONE','TWO']);
  assert.equal((await service.list('week')).total,2);
  assert.equal((await service.list('all','victory')).total,2);
  await assert.rejects(service.list('yesterday'), error=>error.status===422);
});
test('retention cleans expired unsubmitted sessions but preserves published results', async () => {
  const run = await begin(); await service.submit(score(run));
  await db.query("update craftbunny_private.run_sessions set started_at=now()-interval '3 days',expires_at=now()-interval '2 days'");
  await service.start({game_version:version},'b'.repeat(64));
  const {rows}=await db.query('select client_hash from craftbunny_private.run_sessions where id=$1',[run.run_id]);
  assert.equal(rows[0].client_hash,'0'.repeat(64));
  assert.equal((await service.list()).total,1);
});
test('network hashes are secret-keyed and ignore spoofed forwarding headers locally', () => {
  const env={RATE_LIMIT_SECRET:'k'.repeat(32)};
  const a=clientHash({headers:{'x-forwarded-for':'attacker'},socket:{remoteAddress:'127.0.0.1'}},env);
  const b=clientHash({headers:{},socket:{remoteAddress:'127.0.0.1'}},env);
  assert.equal(a,b); assert.match(a,/^[0-9a-f]{64}$/);
  assert.throws(()=>clientHash({headers:{}},{}),ApiError);
});
async function httpCall(action, options = {}, deps = {}) {
  const server=createServer(handler(action,{store,env:{RATE_LIMIT_SECRET:'k'.repeat(32),ALLOWED_ORIGINS:'https://craft.test'},...deps}));
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  try {
    const response=await fetch('http://127.0.0.1:'+server.address().port+(options.path||'/api/leaderboard'),options);
    const text=await response.text(); return {status:response.status,headers:response.headers,body:text?JSON.parse(text):null};
  } finally {server.closeAllConnections();await new Promise(resolve=>server.close(resolve));}
}
test('HTTP method, JSON, body size and browser origin are checked', async () => {
  assert.equal((await httpCall('list',{method:'POST'})).status,405);
  assert.equal((await httpCall('start',{method:'POST',body:'hello'})).status,415);
  assert.equal((await httpCall('start',{method:'POST',headers:{'content-type':'application/json'},body:'{'})).status,400);
  assert.equal((await httpCall('start',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({data:'a'.repeat(3000)})})).status,413);
  assert.equal((await httpCall('start',{method:'POST',headers:{origin:'https://evil.example','content-type':'application/json'},body:'{}'})).status,403);
  assert.equal((await httpCall('start',{method:'OPTIONS',headers:{origin:'https://craft.test'}})).status,204);
});
test('HTTP routes execute against PostgreSQL and cache successful reads only', async () => {
  const run=await httpCall('start',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({game_version:version})});
  assert.equal(run.status,201);
  await db.query("update craftbunny_private.run_sessions set started_at=now()-interval '90 seconds' where id=$1",[run.body.run_id]);
  const submitted=await httpCall('submit',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify(score(run.body))});
  assert.equal(submitted.status,200);assert.equal(submitted.headers.get('cache-control'),'no-store');
  const board=await httpCall('list');assert.equal(board.body.total,1);assert.match(board.headers.get('cache-control'),/s-maxage=30/);
});
test('missing config and database failures fail closed without leaking internals', async () => {
  const result=await httpCall('list',{}, {store:null,env:{}});
  assert.equal(result.status,503);assert.equal(result.body.error,'not_configured');
  assert.equal(result.headers.get('cache-control'),'no-store');
  const bad=new SupabaseStore({SUPABASE_URL:'https://example.supabase.co',SUPABASE_SERVICE_ROLE_KEY:'PRIVATE'},async()=>Response.json({message:'PRIVATE SQL password leaked'},{status:500}));
  const response=await httpCall('list',{}, {store:bad});
  assert.equal(response.status,503);assert.ok(!JSON.stringify(response.body).includes('PRIVATE'));
});
test('new Supabase secret keys use apikey, never JWT bearer authorization', async () => {
  const modern=new SupabaseStore({SUPABASE_URL:'https://example.supabase.co',SUPABASE_SECRET_KEY:'sb_secret_test_only'},async (_url,request)=>{
    assert.equal(request.headers.apikey,'sb_secret_test_only');
    assert.equal(request.headers.Authorization,undefined);
    return Response.json({entries:[],total:0});
  });
  assert.equal((await rankingService(modern).list()).total,0);
});
test('TOP 100 cap preserves total and does not expose duration or run identifiers', async () => {
  await db.exec("insert into craftbunny_private.run_sessions(id,token_hash,client_hash,game_version) select gen_random_uuid(),repeat('a',64),repeat('b',64),'0.3.4' from generate_series(1,105); insert into craftbunny_private.scores(run_id,initials,carrots,won,duration_ms,game_version) select id,'TOP',100,false,60000,'0.3.4' from craftbunny_private.run_sessions;");
  const board=await service.list();
  assert.equal(board.entries.length,100);assert.equal(board.total,105);
  assert.equal(board.entries[99].position,100);
  assert.equal(board.entries[0].run_id,undefined);assert.equal(board.entries[0].duration_ms,undefined);
});
