import { TOTP } from 'otpauth';
import { head, issueSignedToken, presignUrl } from '@vercel/blob';
import { ApiError, SupabaseStore, clientHash, hash } from './ranking.mjs';
import { allowOrigin, readBody } from './http.mjs';

export function downloadConfig(env=process.env) {
  const secret=env.DOWNLOAD_TOTP_SECRET || '';
  const pathname=env.APK_BLOB_PATH || '';
  const version=env.APK_DOWNLOAD_VERSION || '';
  const sha256=env.APK_DOWNLOAD_SHA256 || '';
  if(!/^[A-Z2-7]{32,128}$/.test(secret) ||
     !/^[a-zA-Z0-9_./-]+[.]apk$/.test(pathname) || pathname.startsWith('/') || pathname.split('/').includes('..') ||
     !/^[0-9]+[.][0-9]+[.][0-9]+[-a-zA-Z0-9.]{0,20}$/.test(version) ||
     (sha256 && !/^[a-fA-F0-9]{64}$/.test(sha256)) ||
     (!env.BLOB_READ_WRITE_TOKEN && !(env.BLOB_STORE_ID && env.VERCEL))) {
    throw new ApiError(503,'download_not_configured','A versão de testes ainda está sendo preparada.');
  }
  return {secret,pathname,version,sha256};
}
export function validateDownloadCode(secret,code,timestamp=Date.now()) {
  if(typeof code!=='string' || !/^[0-9]{6}$/.test(code)) throw new ApiError(422,'invalid_code','Digite os 6 dígitos do Authenticator.');
  const totp=new TOTP({secret,algorithm:'SHA1',digits:6,period:30});
  const delta=totp.validate({token:code,timestamp,window:1});
  if(delta===null)throw new ApiError(401,'invalid_code','Código inválido ou expirado. Solicite o código atual.');
  return Math.floor(timestamp/30000)+delta;
}
export async function signPrivateApk(config,env=process.env,sdk={head,issueSignedToken,presignUrl}) {
  const auth=env.BLOB_READ_WRITE_TOKEN?{token:env.BLOB_READ_WRITE_TOKEN}:{storeId:env.BLOB_STORE_ID};
  const blob=await sdk.head(config.pathname,auth);
  if(!new URL(blob.url).hostname.endsWith('.private.blob.vercel-storage.com') || blob.pathname!==config.pathname) {
    throw new ApiError(503,'private_store_required','O download ainda não está disponível.');
  }
  const validUntil=Date.now()+60000;
  const material=await sdk.issueSignedToken({...auth,pathname:config.pathname,operations:['get'],validUntil,abortSignal:AbortSignal.timeout(8000)});
  const signed=await sdk.presignUrl(material,{operation:'get',pathname:config.pathname,access:'private',validUntil});
  if(new URL(signed.presignedUrl).hostname!==new URL(blob.url).hostname)throw new Error('Unexpected download host');
  return {url:signed.presignedUrl,size:blob.size,expires_at:new Date(validUntil).toISOString()};
}
export function downloadHandler({env=process.env,store,signer=signPrivateApk,now=Date.now}={}) {
  return async(req,res)=>{
    res.setHeader('Content-Type','application/json; charset=utf-8');
    res.setHeader('Cache-Control','private, no-store');
    res.setHeader('Referrer-Policy','no-referrer');
    res.setHeader('X-Content-Type-Options','nosniff');
    try{
      allowOrigin(req,res,env,false);
      if(req.method==='OPTIONS'){res.statusCode=204;res.end();return;}
      if(!['GET','POST'].includes(req.method)){
        res.setHeader('Allow','GET, POST, OPTIONS');
        throw new ApiError(405,'method_not_allowed','Método não permitido.');
      }
      let config;
      try{config=downloadConfig(env);}
      catch(error){
        if(req.method==='GET'){res.statusCode=200;res.end(JSON.stringify({available:false,message:error.message}));return;}
        throw error;
      }
      if(req.method==='GET'){
        res.statusCode=200;res.end(JSON.stringify({available:true,version:config.version,sha256:config.sha256}));return;
      }
      const body=await readBody(req);
      const db=store||new SupabaseStore(env);
      await db.rpc('cb_download_attempt',{p_client_hash:clientHash(req,env)});
      if(body.expected_version!==config.version)throw new ApiError(409,'version_changed','A versão de teste mudou. Feche a janela e abra novamente.');
      const step=validateDownloadCode(config.secret,body.code,now());
      // Generate only an exact-object GET link; never expose signing material.
      const download=await signer(config,env);
      await db.rpc('cb_download_use_code',{p_secret_tag:hash(config.secret),p_time_step:step,p_apk_version:config.version});
      res.statusCode=200;
      res.end(JSON.stringify({download_url:download.url,version:config.version,sha256:config.sha256,size:download.size,expires_at:download.expires_at}));
    }catch(error){
      const known=error instanceof ApiError;
      res.statusCode=known?error.status:503;
      if(res.statusCode===429)res.setHeader('Retry-After','60');
      res.end(JSON.stringify({error:known?error.code:'download_unavailable',message:known?error.message:'Download indisponível. Tente novamente mais tarde.'}));
    }
  };
}
