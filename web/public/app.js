const $ = id => document.getElementById(id);
let entries = [], total = 0, page = 0, period = 'all', request, sequence = 0, loaded = false;
const size = 10;
function notice(title, description) {
  $('notice').hidden = false;
  $('notice').querySelector('h3').textContent = title;
  $('notice').querySelector('p').textContent = description;
  $('table-wrap').hidden = true;
}
function cell(text, className) {
  const td = document.createElement('td'); td.textContent = text; td.className = className || ''; return td;
}
function render() {
  const search = $('search').value.trim().toUpperCase();
  const filtered = entries.filter(row => row.initials.includes(search));
  const pages = Math.max(1, Math.ceil(filtered.length / size));
  page = Math.max(0, Math.min(page, pages - 1));
  $('entries').replaceChildren();
  for (const row of filtered.slice(page * size, page * size + size)) {
    const tr = document.createElement('tr');
    tr.append(cell(String(row.position).padStart(2, '0'), 'position' + (row.position === 1 ? ' champion' : '')));
    const name = cell('', 'initials'), avatar = document.createElement('span');
    avatar.className = 'avatar'; avatar.textContent = row.initials[0]; avatar.setAttribute('aria-hidden', 'true');
    name.append(avatar, document.createTextNode(row.initials)); tr.append(name);
    const score = cell(String(row.carrots), 'numeric score'), carrot = document.createElement('span');
    carrot.className = 'tiny-carrot'; carrot.setAttribute('aria-hidden', 'true'); score.append(carrot); tr.append(score);
    const journey = cell(''), badge = document.createElement('span');
    badge.textContent = row.won ? 'Chegou à casa' : 'Fim da tentativa'; badge.className = 'badge' + (row.won ? '' : ' ended');
    journey.append(badge); tr.append(journey);
    const date = new Date(row.created_at);
    tr.append(cell(Number.isFinite(date.getTime()) ? date.toLocaleDateString('pt-BR') : '—', 'date-cell'));
    $('entries').append(tr);
  }
  if (filtered.length) { $('notice').hidden = true; $('table-wrap').hidden = false; }
  else notice(search ? 'Nenhum apelido encontrado' : 'A floresta espera seu recorde', search ? 'A busca considera as 100 melhores tentativas deste filtro.' : 'Termine uma tentativa no jogo e escolha compartilhar sua colheita.');
  $('result-info').textContent = filtered.length ? ((page * size + 1) + '–' + Math.min((page + 1) * size, filtered.length) + ' de ' + filtered.length + ' no TOP 100') : 'Nenhum resultado neste filtro.';
  $('page').textContent = (page + 1) + ' / ' + pages;
  $('previous').disabled = page === 0; $('next').disabled = page >= pages - 1;
}
async function load() {
  request?.abort(); request = new AbortController(); const current = ++sequence;
  loaded = false;
  $('refresh').disabled = true; $('connection').textContent = 'Atualizando…';
  $('status-dot').classList.remove('ready');
  notice('Buscando os recordes…', 'Estamos abrindo o quadro da floresta.');
  try {
    const response = await fetch('/api/leaderboard?' + new URLSearchParams({ period, outcome: $('outcome').value }), { signal: request.signal });
    const data = await response.json();
    if (current !== sequence) return;
    if (!response.ok) {
      const preparing = data.error === 'not_configured';
      notice(preparing ? 'O quadro está sendo preparado' : 'A floresta está sem conexão', preparing ? 'Os recordes globais estarão disponíveis em breve. Seus recordes locais continuam no jogo.' : 'Não conseguimos buscar os recordes agora. Tente atualizar em instantes.');
      entries = []; total = 0; $('total').textContent = '—'; $('best').textContent = '—';
      $('connection').textContent = preparing ? 'Em preparação' : 'Temporariamente indisponível';
      $('result-info').textContent = 'Seu ranking local permanece no aparelho.';
      $('previous').disabled = true; $('next').disabled = true; $('page').textContent = '—';
      return;
    }
    if (!Array.isArray(data.entries) || !Number.isInteger(data.total)) throw new Error('invalid_response');
    entries = data.entries; total = data.total; page = 0; loaded = true;
    $('total').textContent = total.toLocaleString('pt-BR');
    $('best').textContent = entries.length ? entries[0].carrots.toLocaleString('pt-BR') : '0';
    $('connection').textContent = 'Atualizado às ' + new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
    $('status-dot').classList.add('ready'); render();
  } catch (error) {
    if (error.name === 'AbortError' || current !== sequence) return;
    entries = []; $('total').textContent = '—'; $('best').textContent = '—';
    $('connection').textContent = 'Temporariamente indisponível';
    notice('A floresta está sem conexão', 'Não conseguimos buscar os recordes agora. Tente atualizar em instantes.');
    $('result-info').textContent = 'Nenhum recorde foi alterado.';
    $('previous').disabled = true; $('next').disabled = true; $('page').textContent = '—';
  } finally { if (current === sequence) $('refresh').disabled = false; }
}
document.querySelectorAll('[data-period]').forEach(button => button.addEventListener('click', () => {
  period = button.dataset.period;
  document.querySelectorAll('[data-period]').forEach(tab => {
    const selected = tab === button; tab.classList.toggle('selected', selected); tab.setAttribute('aria-pressed', selected);
  }); load();
}));
$('outcome').addEventListener('change', load);
$('search').addEventListener('input', () => { page = 0; if (loaded) render(); });
$('refresh').addEventListener('click', load);
$('previous').addEventListener('click', () => { page--; render(); });
$('next').addEventListener('click', () => { page++; render(); });
load();

const downloadDialog=$('download-dialog'),downloadCode=$('download-code'),downloadConfirm=$('confirm-download');
let downloadAvailable=false,downloadBusy=false,downloadRequest,downloadVersion='';
$('open-download').addEventListener('click',async()=>{
  downloadDialog.showModal();downloadCode.value='';downloadAvailable=false;downloadVersion='';
  downloadConfirm.disabled=true;downloadCode.disabled=true;
  $('download-status').textContent='';$('download-version').textContent='Verificando a versão disponível…';
  downloadRequest?.abort();downloadRequest=new AbortController();
  try{
    const response=await fetch('/api/download',{signal:downloadRequest.signal,cache:'no-store'});
    const data=await response.json();
    if(!response.ok || !data.available){$('download-version').textContent='Download de testes em preparação.';$('download-status').textContent='O responsável ainda está configurando o acesso.';return;}
    downloadAvailable=true;downloadVersion=data.version;downloadConfirm.disabled=false;downloadCode.disabled=false;
    $('download-version').textContent='Versão disponível: '+data.version+' · Android';
    downloadCode.focus();
  }catch(error){
    if(error.name!=='AbortError')$('download-status').textContent='Não foi possível consultar a versão. Tente novamente.';
  }
});
$('close-download').addEventListener('click',()=>downloadDialog.close());
downloadDialog.addEventListener('close',()=>{downloadRequest?.abort();downloadCode.value='';});
$('download-form').addEventListener('submit',async event=>{
  event.preventDefault();
  if(downloadBusy || !downloadAvailable || !/^[0-9]{6}$/.test(downloadCode.value))return;
  downloadBusy=true;downloadConfirm.disabled=true;$('download-status').textContent='Confirmando seu código…';
  const code=downloadCode.value;downloadCode.value='';
  downloadRequest=new AbortController();
  try{
    const response=await fetch('/api/download',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({code,expected_version:downloadVersion}),signal:downloadRequest.signal,cache:'no-store'});
    const data=await response.json();
    if(!response.ok){$('download-status').textContent=data.message||'Não foi possível liberar o download.';downloadCode.focus();return;}
    const url=new URL(data.download_url);
    if(url.protocol!=='https:' || !url.hostname.endsWith('.private.blob.vercel-storage.com'))throw new Error('invalid_download_url');
    $('download-status').textContent='Download liberado. O link expira em 60 segundos.';
    const link=document.createElement('a');
    link.href=url.href;link.rel='noreferrer';link.referrerPolicy='no-referrer';
    link.download='CraftBunny-Android-'+data.version+'.apk';
    document.body.append(link);link.click();link.remove();
  }catch(error){
    if(error.name!=='AbortError')$('download-status').textContent='Não foi possível iniciar o download. Solicite um novo código e tente novamente.';
  }finally{downloadBusy=false;downloadConfirm.disabled=!downloadAvailable;}
});
