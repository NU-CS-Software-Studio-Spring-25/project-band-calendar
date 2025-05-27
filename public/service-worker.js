self.addEventListener('install', function(event) {
    console.log('[Service Worker] Install');
  
    event.waitUntil(
      caches.open('rails-pwa-cache').then(function(cache) {
        return cache.addAll([
          '/',
          '/offline.html'
        ]);
      })
    );
  });
  
  self.addEventListener('fetch', function(event) {
    event.respondWith(
      caches.match(event.request).then(function(response) {
        return response || fetch(event.request);
      }).catch(function() {
        return caches.match('/offline.html');
      })
    );
  });
  