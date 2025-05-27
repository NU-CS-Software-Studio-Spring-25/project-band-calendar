// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "controllers"


if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
      navigator.serviceWorker.register('/service_worker.js')
        .then(function(reg) {
          console.log("Service Worker registered: ", reg.scope);
        })
        .catch(function(err) {
          console.error("Service Worker registration failed: ", err);
        });
    });
  }