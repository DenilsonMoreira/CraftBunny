// Local-only browser fixture. Never imported by production API functions.
import { PGlite } from '@electric-sql/pglite';
import { readFile, stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import { resolve, extname, sep } from 'node:path';
import { SupabaseStore } from '../lib/ranking.mjs';
import { handler } from '../lib/http.mjs';
if(process.env.VERCEL)throw new Error('QA fixtures must never run in Vercel.');
const db=new PGlite();
await db.exec('create role anon;create role authenticated;create role service_role;');
await db.exec(await readFile(new URL('../../supabase/migrations/202611070001_global_ranking.sql',import.meta.url),'utf8'));
const names=['BUN','HOP','FOX','OAK','LEA','SUN','SKY','RED','LOG','NUT','ASH','ELM','IVY','DEW'];
for(let i=0;i<names.length;i++){
 const {rows}=await db.query("insert into craftbunny_private.run_sessions(id,token_hash,client_hash,game_version) values(gen_random_uuid(),repeat('a',64),repeat('b',64),'0.3.4') returning id");
 await db.query("insert into craftbunny_private.scores(run_id,initials,carrots,won,duration_ms,game_version,created_at) values($1,$2,$3,$4,60000,'0.3.4',now()-($5::integer * interval '1 day'))",[rows[0].id,names[i],139-i*5,i%3===0,i>10?8:0]);
}
const store=new SupabaseStore({SUPABASE_URL:'https://example.supabase.co',SUPABASE_SECRET_KEY:'sb_secret_test_only'},async (_url,request)=>{
 const body=JSON.parse(request.body);
 const {rows}=await db.query('select public.cb_leaderboard($1,$2) as result',[body.p_period,body.p_outcome]);
 return Response.json(rows[0].result);
});
const api=handler('list',{store});
const root=resolve('public');
const types={'.html':'text/html; charset=utf-8','.css':'text/css','.js':'text/javascript','.png':'image/png','.ttf':'font/ttf'};
createServer(async(req,res)=>{
 const url=new URL(req.url,'http://localhost');
 if(url.pathname==='/api/leaderboard')return api(req,res);
 try{
  const path=resolve(root,'.'+decodeURIComponent(url.pathname==='/'?'/index.html':url.pathname));
  if(!path.startsWith(root+sep)||!(await stat(path)).isFile())throw new Error('not_found');
  let content=await readFile(path);
  if(extname(path)==='.html')content=Buffer.from(content.toString().replace('<body>','<body><p style="padding:8px;background:#ffe39d;text-align:center;font-weight:bold;font-size:12px">PRÉVIA LOCAL · DADOS FICTÍCIOS DE TESTE</p>'));
  res.setHeader('Content-Type',types[extname(path)]||'application/octet-stream');res.end(content);
 }catch{res.writeHead(404);res.end();}
}).listen(3001,'127.0.0.1',()=>console.log('QA only: http://localhost:3001 — fictitious test scores.'));
