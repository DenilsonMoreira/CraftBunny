import { mkdir,readFile,writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { homedir } from 'node:os';
import { TOTP,Secret } from 'otpauth';
import QRCode from 'qrcode';

const directory=process.env.CRAFT_BUNNY_PRIVATE_DIR||join(process.env.LOCALAPPDATA||join(homedir(),'.local','share'),'CraftBunnyDownload');
await mkdir(directory,{recursive:true,mode:0o700});
const envPath=join(directory,'.env.download.local');
let secret;
try{
  const existing=await readFile(envPath,'utf8');
  secret=existing.match(/^DOWNLOAD_TOTP_SECRET=([A-Z2-7]+)$/m)?.[1];
  if(!secret)throw new Error('Existing private configuration is invalid; not overwriting.');
}catch(error){
  if(error.code!=='ENOENT')throw error;
  secret=new Secret({size:20}).base32;
  await writeFile(envPath,'DOWNLOAD_TOTP_SECRET='+secret+'\n',{flag:'wx',mode:0o600});
}
const totp=new TOTP({issuer:'Craft Bunny',label:'Downloads de teste',algorithm:'SHA1',digits:6,period:30,secret});
const qr=await QRCode.toDataURL(totp.toString(),{width:280,margin:2});
const html='<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><meta http-equiv="Content-Security-Policy" content="default-src \'none\'; img-src data:; style-src \'unsafe-inline\'; base-uri \'none\'"><title>Configuração privada Craft Bunny</title><body style="font:16px/1.6 system-ui;max-width:720px;margin:40px auto;padding:20px;background:#f8f2df;color:#244d35"><h1>Seu autenticador de downloads</h1><p>Esta página é privada e local. Não compartilhe o QR nem a chave abaixo.</p><ol><li>Google Authenticator → + → Ler QR code.</li><li>Escaneie este QR para adicionar Craft Bunny / Downloads de teste.</li><li>Na Vercel, configure DOWNLOAD_TOTP_SECRET com a chave abaixo e faça Redeploy.</li></ol><img alt="QR privado do autenticador" src="'+qr+'"><p>Somente para colar no ambiente privado da Vercel:</p><textarea readonly rows="2" style="width:100%;font:16px monospace">'+secret+'</textarea><p>Compartilhe com testadores somente o código de seis dígitos atual. Nunca compartilhe esta página, o QR ou a chave.</p></body></html>';
const htmlPath=join(directory,'authenticator.html');
await writeFile(htmlPath,html,{mode:0o600});
console.log('Configuração privada pronta. Abra localmente: '+htmlPath);
console.log('Chave salva fora do repositório; nenhum segredo foi impresso.');
