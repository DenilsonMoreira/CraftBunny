import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';
import leaderboard from '../api/leaderboard.js';
import runs from '../api/runs.js';
import scores from '../api/scores.js';
import download from '../api/download.js';
const routes = { '/api/leaderboard': leaderboard, '/api/runs': runs, '/api/scores': scores, '/api/download':download };
const root = resolve('public');
const types = { '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'text/javascript', '.png': 'image/png', '.ttf': 'font/ttf', '.txt': 'text/plain' };
const server = createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  if (routes[url.pathname]) return routes[url.pathname](req, res);
  try {
    let path = resolve(root, '.' + decodeURIComponent(url.pathname === '/' ? '/index.html' : url.pathname));
    if (!path.startsWith(root + sep) || !(await stat(path)).isFile()) throw new Error('not_found');
    if (!['GET', 'HEAD'].includes(req.method)) { res.writeHead(405); res.end(); return; }
    res.setHeader('Content-Type', types[extname(path)] || 'application/octet-stream');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.end(req.method === 'HEAD' ? undefined : await readFile(path));
  } catch { res.writeHead(404); res.end('Not found'); }
});
const port = Number(process.env.PORT || 3000);
server.listen(port, '127.0.0.1', () => console.log('Craft Bunny: http://localhost:' + port));
