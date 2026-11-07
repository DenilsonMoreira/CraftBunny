import { access, readFile } from 'node:fs/promises';
for (const file of ['public/index.html', 'public/app.js', 'public/style.css', 'public/assets/forest.png', 'public/assets/pixel.ttf']) await access(file);
const html = await readFile('public/index.html', 'utf8');
if (!html.includes('id="ranking"')) throw new Error('Ranking markup missing');
await import('../api/leaderboard.js');
await import('../api/runs.js');
await import('../api/scores.js');
await import('../api/download.js');
console.log('Static site and Vercel API modules validated.');
