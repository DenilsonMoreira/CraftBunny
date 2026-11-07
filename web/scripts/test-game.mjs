import { PGlite } from '@electric-sql/pglite';
import { readFile } from 'node:fs/promises';
import { createServer } from 'node:http';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { SupabaseStore } from '../lib/ranking.mjs';
import { handler } from '../lib/http.mjs';
if (!process.env.GODOT_BIN) throw new Error('Set GODOT_BIN to the Godot 4.7.2 console executable.');
const db=new PGlite();
let server;
try {
  await db.exec('create role anon;create role authenticated;create role service_role;');
  await db.exec(await readFile(new URL('../../supabase/migrations/202611070001_global_ranking.sql',import.meta.url),'utf8'));
  const store=new SupabaseStore({SUPABASE_URL:'https://example.supabase.co',SUPABASE_SECRET_KEY:'sb_secret_test_only'},async (url,request)=>{
    const name=new URL(url).pathname.split('/').pop();
    if (!['cb_start_run','cb_submit_score','cb_leaderboard'].includes(name)) throw new Error('Unknown RPC');
    const args=Object.values(JSON.parse(request.body));
    try {
      const result=await db.query('select public.'+name+'('+args.map((_,i)=>'$'+(i+1)).join(',')+') as result',args);
      return Response.json(result.rows[0].result);
    } catch(error){return Response.json({message:error.message},{status:400});}
  });
  const deps={store,env:{RATE_LIMIT_SECRET:'local-test-secret-'.repeat(3)}};
  const routes={'/api/runs':handler('start',deps),'/api/scores':handler('submit',deps),'/api/leaderboard':handler('list',deps)};
  server=createServer((req,res)=>{const route=routes[new URL(req.url,'http://localhost').pathname];if(route)return route(req,res);res.writeHead(404);res.end();});
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  const child=spawn(process.env.GODOT_BIN,['--headless','--path',fileURLToPath(new URL('../../game',import.meta.url)),'--script','res://tools/test_global_ranking.gd'],{
    stdio:'inherit',env:{...process.env,CRAFT_BUNNY_API_URL:'http://127.0.0.1:'+server.address().port},timeout:45000
  });
  const exit=await new Promise((resolve,reject)=>{child.on('error',reject);child.on('exit',resolve);});
  if(exit!==0)throw new Error('Godot integration test failed: '+exit);
  const {rows}=await db.query('select count(*)::int as total from craftbunny_private.scores');
  if(rows[0].total!==1)throw new Error('Expected exactly one published test result.');
  console.log('GODOT_API_POSTGRES=PASS; exactly one result stored.');
} finally {
  if(server){server.closeAllConnections();await new Promise(resolve=>server.close(resolve));}
  await db.close();
}
