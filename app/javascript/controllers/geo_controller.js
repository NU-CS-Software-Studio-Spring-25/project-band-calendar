import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="geo"
export default class extends Controller {
  findLocation() {
    console.log("Button clicked: attempting to geolocate");
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition((position) => {
        const lat = position.coords.latitude;
        const lon = position.coords.longitude;
        const radius = 10;
        const url = new URL(window.location.href);
        url.searchParams.set("lat", lat);
        url.searchParams.set("lon", lon);
        url.searchParams.set("radius", radius);
        console.log("Redirecting to:", url.toString());
        window.location.href = url.toString();
      }, () => {
        alert("Location access denied.");
      });
    } else {
      alert("Geolocation not supported by this browser.");
    }
  }
}
