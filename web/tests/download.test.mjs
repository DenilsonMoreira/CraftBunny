import {test,before,beforeEach,after} from 'node:test';
import assert from 'node:assert/strict';
import {readFile,mkdtemp,unlink,rmdir} from 'node:fs/promises';
import {join} from 'node:path';
import {tmpdir} from 'node:os';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {createServer} from 'node:http';
import {TOTP} from 'otpauth';
import {PGlite} from '@electric-sql/pglite';
import {SupabaseStore} from '../lib/ranking.mjs';
import {downloadConfig,validateDownloadCode,signPrivateApk,downloadHandler} from '../lib/download.mjs';

// RFC 6238 public example key, never a production authenticator.
const secret='GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';
const env={DOWNLOAD_TOTP_SECRET:secret,APK_BLOB_PATH:'releases/CraftBunny-Android-0.3.5.apk',APK_DOWNLOAD_VERSION:'0.3.5',BLOB_READ_WRITE_TOKEN:'test-only',RATE_LIMIT_SECRET:'test-download-secret-'.repeat(2),ALLOWED_ORIGINS:'https://craft.test'};
let db,store;
before(async()=>{
 db=new PGlite();
 await db.exec('create role anon;create role authenticated;create role service_role;');
 for(const file of ['202611070001_global_ranking.sql','202611070002_private_download.sql'])await db.exec(await readFile(new URL('../../supabase/migrations/'+file,import.meta.url),'utf8'));
 store=new SupabaseStore({SUPABASE_URL:'https://example.supabase.co',SUPABASE_SECRET_KEY:'sb_secret_test_only'},async(url,request)=>{
  const name=new URL(url).pathname.split('/').pop();
  assert.ok(['cb_download_attempt','cb_download_use_code'].includes(name));
  const args=Object.values(JSON.parse(request.body));
  try{
   const {rows}=await db.query('select public.'+name+'('+args.map((_,i)=>'$'+(i+1)).join(',')+') as result',args);
   return Response.json(rows[0].result);
  }catch(error){return Response.json({message:error.message},{status:400});}
 });
});
beforeEach(async()=>{await db.exec('truncate craftbunny_private.download_attempts,craftbunny_private.download_codes');});
after(async()=>db.close());
const currentCode=()=>new TOTP({secret,algorithm:'SHA1',digits:6,period:30}).generate();
const signer=async config=>({url:'https://test.private.blob.vercel-storage.com/'+config.pathname+'?test-signed',size:79741400,expires_at:new Date(Date.now()+60000).toISOString()});
async function call(options={},deps={}) {
 const server=createServer(downloadHandler({env,store,signer,...deps}));
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
 try{
  const response=await fetch('http://127.0.0.1:'+server.address().port+'/api/download',options);
  return {status:response.status,headers:response.headers,body:await response.json()};
 }finally{server.closeAllConnections();await new Promise(resolve=>server.close(resolve));}
}
const post=body=>({method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({expected_version:env.APK_DOWNLOAD_VERSION,...body})});
test('download migration works without the ranking schema and keeps it private',async()=>{
 const standalone=new PGlite();
 try{
  await standalone.exec('create role anon;create role authenticated;create role service_role;');
  await standalone.exec(await readFile(new URL('../../supabase/migrations/202611070002_private_download.sql',import.meta.url),'utf8'));
  const {rows}=await standalone.query("select to_regclass('craftbunny_private.download_codes')::text as name, has_schema_privilege('anon','craftbunny_private','USAGE') as accessible");
  assert.equal(rows[0].name,'craftbunny_private.download_codes');
  assert.equal(rows[0].accessible,false);
 }finally{await standalone.close();}
});

test('download database failures identify setup and permissions without leaking provider details',async()=>{
 for(const [providerCode,status,expected] of [['PGRST202',404,'download_migration_required'],['42P01',400,'download_migration_required'],['3F000',400,'download_migration_required'],['42883',404,'download_migration_required'],['42501',403,'download_database_permissions'],['XX000',500,'download_database_unavailable']]){
  const failing=new SupabaseStore({SUPABASE_URL:'https://example.supabase.co',SUPABASE_SECRET_KEY:'sb_secret_test_only'},async()=>Response.json({code:providerCode,message:'PRIVATE provider details'},{status}));
  const result=await call(post({code:'invalid'}),{store:failing,signer:async()=>{throw new Error('Signer must not run');}});
  assert.equal(result.status,503);assert.equal(result.body.error,expected);
  assert.ok(!JSON.stringify(result.body).includes('PRIVATE'));
  assert.ok(!result.body.message.includes('ranking'));
 }
});

test('TOTP follows RFC 6238 six-digit vector and rejects malformed/expired codes',()=>{
 assert.equal(validateDownloadCode(secret,'287082',59000),1);
 assert.equal(validateDownloadCode(secret,'287082',89000),1);
 assert.throws(()=>validateDownloadCode(secret,'287082',119000),error=>error.status===401);
 for(const code of ['12345','1234567','abcdef',123456])assert.throws(()=>validateDownloadCode(secret,code),error=>error.status===422);
});
test('download configuration fails closed for missing key, public URL or path traversal',()=>{
 assert.throws(()=>downloadConfig({}));
 assert.throws(()=>downloadConfig({...env,APK_BLOB_PATH:'../secret.apk'}));
 assert.throws(()=>downloadConfig({...env,APK_BLOB_PATH:'https://public.example/game.apk'}));
 assert.throws(()=>downloadConfig({...env,APK_DOWNLOAD_VERSION:'<script>'}));
 assert.equal(downloadConfig(env).version,'0.3.5');
});
test('metadata exposes version only, and unconfigured download does not expose file or secrets',async()=>{
 const ready=await call();assert.equal(ready.status,200);assert.equal(ready.body.version,'0.3.5');
 assert.equal(ready.body.available,true);
 assert.ok(!JSON.stringify(ready.body).includes(secret));assert.equal(ready.body.pathname,undefined);
 const missing=await call({}, {env:{}});assert.equal(missing.body.available,false);
 assert.equal((await call(post({code:'123456'}),{env:{}})).status,503);
 assert.match(missing.headers.get('cache-control'),/no-store/);
});
test('correct code unlocks exact configured release; client cannot select another file',async()=>{
 let configSeen;
 const result=await call(post({code:currentCode(),pathname:'another.apk',version:'9.9.9'}),{signer:async config=>{configSeen=config;return signer(config);}});
 assert.equal(result.status,200);assert.equal(configSeen.pathname,env.APK_BLOB_PATH);
 assert.equal(result.body.version,'0.3.5');assert.equal(result.body.size,79741400);
 assert.ok(!JSON.stringify(result.body).includes(secret));
 const {rows}=await db.query('select count(*)::int as count from craftbunny_private.download_codes');assert.equal(rows[0].count,1);
});
test('same TOTP cannot unlock a second download; concurrent attempts allow only one',async()=>{
 const request=post({code:currentCode()});
 const results=await Promise.all([call(request),call(request)]);
 assert.deepEqual(results.map(r=>r.status).sort(),[200,409]);
});
test('changing release requires reopening the dialog and does not consume the OTP',async()=>{
 const code=currentCode();
 const stale=await call(post({code,expected_version:'0.3.4'}));
 assert.equal(stale.status,409);assert.equal(stale.body.error,'version_changed');
 assert.equal((await call(post({code}))).status,200);
});
test('wrong codes never call file signer, and guesses are rate-limited in PostgreSQL',async()=>{
 let calls=0;
 const badSigner=async()=>{calls++;throw new Error('Must not reach Blob');};
 for(let i=0;i<5;i++)assert.equal((await call(post({code:'wrong'}),{signer:badSigner})).status,422);
 const blocked=await call(post({code:currentCode()}),{signer:badSigner});
 assert.equal(blocked.status,429);assert.equal(calls,0);
 assert.equal(blocked.headers.get('retry-after'),'60');
});
test('invalid current six-digit code rejected without consuming a valid time step',async()=>{
 const expected=currentCode();
 let invalid='000000';
 if(invalid===expected)invalid='999999';
 const result=await call(post({code:invalid}));
 assert.equal(result.status,401);
 const {rows}=await db.query('select count(*)::int as count from craftbunny_private.download_codes');assert.equal(rows[0].count,0);
});
test('storage failures do not consume code and do not leak errors or secrets',async()=>{
 const code=currentCode();
 const failed=await call(post({code}),{signer:async()=>{throw new Error('PRIVATE credential '+secret);}});
 assert.equal(failed.status,503);assert.ok(!JSON.stringify(failed.body).includes(secret));
 assert.equal((await call(post({code}))).status,200);
});
test('methods, browser origin, JSON and payload size remain guarded',async()=>{
 assert.equal((await call({method:'PUT'})).status,405);
 assert.equal((await call({...post({code:currentCode()}),headers:{'Content-Type':'application/json',Origin:'https://evil.test'}})).status,403);
 assert.equal((await call({method:'POST',headers:{'Content-Type':'application/json'},body:'{'})).status,400);
 assert.equal((await call(post({code:'x'.repeat(2500)}))).status,413);
});
test('anonymous roles cannot invoke download RPCs or read limiter records',async()=>{
 for(const role of ['anon','authenticated']){
  const {rows}=await db.query("select has_function_privilege($1,'public.cb_download_attempt(text)','execute') as attempt,has_function_privilege($1,'public.cb_download_use_code(text,bigint,text)','execute') as unlock,has_table_privilege($1,'craftbunny_private.download_codes','select') as read",[role]);
  assert.deepEqual(rows[0],{attempt:false,unlock:false,read:false});
 }
 assert.equal((await db.query('select count(*)::int as count from craftbunny_private.scores')).rows[0].count,0);
});
test('private file signing scopes GET to one exact APK and sixty seconds',async()=>{
 const config=downloadConfig(env);let issueOptions,signOptions;
 const before=Date.now();
 const result=await signPrivateApk(config,env,{
  head:async()=>({url:'https://test.private.blob.vercel-storage.com/'+config.pathname,pathname:config.pathname,size:79741400}),
  issueSignedToken:async options=>{issueOptions=options;return {clientSigningToken:'PRIVATE',delegationToken:'SCOPED'};},
  presignUrl:async(material,options)=>{assert.equal(material.clientSigningToken,'PRIVATE');signOptions=options;return {presignedUrl:'https://test.private.blob.vercel-storage.com/'+options.pathname+'?temporary'};}
 });
 assert.deepEqual(issueOptions.operations,['get']);assert.equal(issueOptions.pathname,env.APK_BLOB_PATH);
 assert.equal(signOptions.access,'private');assert.equal(signOptions.operation,'get');
 assert.ok(issueOptions.validUntil>=before+60000 && issueOptions.validUntil<=Date.now()+60000);
 assert.equal(result.size,79741400);assert.ok(!JSON.stringify(result).includes('PRIVATE'));
 await assert.rejects(signPrivateApk(config,env,{head:async()=>({url:'https://test.public.blob.vercel-storage.com/file.apk',pathname:config.pathname})}),error=>error.status===503);
});
test('setup QR stays local, never prints the key, and rerunning preserves the authenticator',async()=>{
 const directory=await mkdtemp(join(tmpdir(),'craftbunny-download-test-'));
 try{
  const script=fileURLToPath(new URL('../scripts/setup-download.mjs',import.meta.url));
  const run=()=>spawnSync(process.execPath,[script],{env:{...process.env,CRAFT_BUNNY_PRIVATE_DIR:directory},encoding:'utf8'});
  const first=run();assert.equal(first.status,0);
  const privateEnv=await readFile(join(directory,'.env.download.local'),'utf8');
  const generated=privateEnv.match(/DOWNLOAD_TOTP_SECRET=([A-Z2-7]+)/)[1];
  assert.equal(generated.length,32);assert.ok(!first.stdout.includes(generated));
  const html=await readFile(join(directory,'authenticator.html'),'utf8');
  assert.ok(html.includes('data:image/png;base64,'));assert.ok(!html.includes('https://'));
  assert.equal(run().status,0);
  assert.equal(await readFile(join(directory,'.env.download.local'),'utf8'),privateEnv);
 }finally{
  await unlink(join(directory,'authenticator.html'));await unlink(join(directory,'.env.download.local'));await rmdir(directory);
 }
});
