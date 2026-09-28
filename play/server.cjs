// Local playable client. Only explicitly listed public game resources are served.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const routes = {
  '/': ['play/index.html', 'text/html; charset=utf-8'],
  '/hud-review.html': ['play/index.html', 'text/html; charset=utf-8'],
  '/hud-review.js': ['qa/hud-review.js', 'text/javascript; charset=utf-8'],
  '/laser-review.html': ['play/index.html', 'text/html; charset=utf-8'],
  '/laser-review.js': ['qa/laser-review.js', 'text/javascript; charset=utf-8'],
  '/favicon-32.png': ['play/assets/favicon-32.png', 'image/png'],
  '/apple-touch-icon.png': ['play/assets/apple-touch-icon.png', 'image/png'],
  '/sound.js': ['play/sound.js', 'text/javascript; charset=utf-8'],
  '/audio-approved.json': ['native-ios/Resources/audio-approved.json', 'application/json'],
  '/Audio-Credits.txt': ['native-ios/Resources/Audio-Credits.txt', 'text/plain; charset=utf-8'],
  '/game.js': ['play/game.js', 'text/javascript; charset=utf-8'],
  '/renderer.js': ['play/renderer.js', 'text/javascript; charset=utf-8'],
  '/presentation.js': ['play/presentation.js', 'text/javascript; charset=utf-8'],
  '/menu.css': ['play/menu.css', 'text/css; charset=utf-8'],
  '/hud.css': ['play/hud.css', 'text/css; charset=utf-8'],
  '/ink-hud-ribbon.png': ['native-ios/Resources/ink-hud-ribbon.png', 'image/png'],
  '/menu-components.js': ['play/menu-components.js', 'text/javascript; charset=utf-8'],
  '/menu-layout.js': ['play/menu-layout.js', 'text/javascript; charset=utf-8'],
  '/menu-panel.png': ['play/assets/menu/panel.png', 'image/png'],
  '/menu-components.png': ['play/assets/menu/components.png', 'image/png'],
  '/ink-wave-orb-v058.png': ['native-ios/Resources/ink-wave-orb-v058.png', 'image/png'],
  '/core.js': ['native-ios/Resources/classic-core.js', 'text/javascript; charset=utf-8'],
  '/approved-orbs.json': ['native-ios/Resources/approved-orbs.json', 'application/json'],
};
for (const name of ['menu-skin', 'menu-lettering-en', 'menu-lettering-es'])
  routes[`/${name}.png`] = [`play/assets/${name}.png`, 'image/png'];
routes['/Knewave-Regular.ttf'] = ['play/assets/Knewave-Regular.ttf', 'font/ttf'];
for (const name of ['ink-tide-arena', 'ink-tide-sprites', 'orb-glass-v03', 'ink-tide-approved-orbs'])
  routes[`/${name}.png`] = [`native-ios/Resources/${name}.png`, 'image/png'];
const audioCatalog = JSON.parse(fs.readFileSync(path.join(__dirname,'../native-ios/Resources/audio-approved.json')));
const orbCatalog = JSON.parse(fs.readFileSync(path.join(__dirname,'../native-ios/Resources/approved-orbs.json')));
for (const region of Object.values(orbCatalog.regions)) if (region.image)
  routes[`/${region.image}.png`] = [`native-ios/Resources/${region.image}.png`, 'image/png'];
for (const asset of Object.values(audioCatalog.assets)) for (const item of [asset,...(asset.pitchVariants||[])]) routes['/'+item.file]=['native-ios/Resources/'+item.file,item.file.endsWith('.mp3')?'audio/mpeg':'audio/wav'];
const port = Number(process.env.TILT_PLAY_PORT || 4294);
http.createServer((req, res) => {
  const route = routes[new URL(req.url, 'http://127.0.0.1').pathname];
  if (!route || !['GET', 'HEAD'].includes(req.method)) { res.writeHead(404); res.end(); return; }
  fs.readFile(path.join(__dirname, '..', route[0]), (error, data) => {
    if (error) { res.writeHead(500); res.end('Resource unavailable'); return; }
    res.writeHead(200, {'Content-Type': route[1], 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff'});
    if (new URL(req.url, 'http://127.0.0.1').pathname === '/hud-review.html')
      data = data.toString().replace('src="/game.js"', 'src="/hud-review.js"');
    if (new URL(req.url, 'http://127.0.0.1').pathname === '/laser-review.html')
      data = data.toString().replace('src="/game.js"', 'src="/laser-review.js"');
    res.end(req.method === 'HEAD' ? undefined : data);
  });
}).listen(port, '127.0.0.1', () => console.log(`Tilt Arena: http://127.0.0.1:${port}`));
