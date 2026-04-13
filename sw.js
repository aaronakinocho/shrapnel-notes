const CACHE = 'shrapnel-v16b';

// Only cache static assets, never HTML pages
const ASSETS = ['/manifest.json', '/icon-192.png', '/icon-512.png'];

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

  // Never intercept HTML navigation — let the network handle routing
  if (e.request.mode === 'navigate') {
    e.respondWith(fetch(e.request));
    return;
  }

  // Cache static assets only
  if (ASSETS.some(a => url.pathname === a)) {
    e.respondWith(
      caches.match(e.request).then(r => r || fetch(e.request))
    );
    return;
  }

  // Everything else goes straight to network
  e.respondWith(fetch(e.request));
});

self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') self.skipWaiting();
});
