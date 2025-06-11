import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

import "controllers" // pulls in your geo_controller if importmap is pinned

const application = Application.start()
application.debug = true
window.Stimulus = application

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