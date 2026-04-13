const CACHE = 'shrapnel-v13b';
const ASSETS = ['/index.html', '/manifest.json', '/icon-192.png', '/icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  // Laisse passer les navigations vers / et landing.html directement au réseau
  if (e.request.mode === 'navigate' && (url.pathname === '/' || url.pathname === '/landing.html')) {
    e.respondWith(fetch(e.request));
    return;
  }

  // Pour tout le reste : cache d'abord, puis réseau
  e.respondWith(
    caches.match(e.request).then(r => r || fetch(e.request).catch(() => caches.match('/index.html')))
  );
});

self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') self.skipWaiting();
});
