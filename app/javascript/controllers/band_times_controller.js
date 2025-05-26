import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["timeFields"];

  connect() {
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Listen for changes in band selection
    document.addEventListener("band-selection:changed", (event) => {
      const selectedBands = event.detail.bands || [];
      this.updateBandTimeFields(selectedBands);
    });
  }

  updateBandTimeFields(selectedBands) {
    const container = document.getElementById("band-times-fields");
    const noSelectedAlert = document.getElementById("no-bands-selected-alert");

    if (selectedBands.length === 0) {
      // Show alert when no bands are selected
      if (!noSelectedAlert) {
        container.innerHTML = `
          <div class="alert alert-info" id="no-bands-selected-alert">
            <p class="mb-0 text-center">Select bands first to set their performance times.</p>
          </div>
        `;
      }
      return;
    }

    // Remove alert if it exists
    if (noSelectedAlert) {
      noSelectedAlert.remove();
    }

    // Get existing fields to preserve data
    const existingFields = {};
    document.querySelectorAll(".band-time-entry").forEach((entry) => {
      const bandId = entry.dataset.bandId;
      if (bandId) {
        existingFields[bandId] = {
          position: entry.querySelector('input[name$="[set_position]"]')?.value,
          startTime: entry.querySelector('input[name$="[start_time]"]')?.value,
          endTime: entry.querySelector('input[name$="[end_time]"]')?.value,
          notes: entry.querySelector('textarea[name$="[notes]"]')?.value,
        };
      }
    });

    // Update fields for each selected band
    selectedBands.forEach((band, index) => {
      const bandId = band.id;
      const existingData = existingFields[bandId] || {};

      // Check if the entry already exists
      let entry = document.querySelector(
        `.band-time-entry[data-band-id="${bandId}"]`
      );
      if (!entry) {
        entry = document.createElement("div");
        entry.className = "band-time-entry card mb-3";
        entry.dataset.bandId = bandId;

        // Create entry content
        entry.innerHTML = `
          <div class="card-header bg-light">
            <h4 class="h6 mb-0">
              <img src="${band.image_url || "https://via.placeholder.com/30"}" 
                   class="band-img me-2" alt="${
                     band.name
                   }" width="30" height="30">
              ${band.name}
            </h4>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-3 mb-3">
                <label class="form-label">Set Position</label>
                <input type="number" name="band_times[${bandId}][set_position]" 
                       class="form-control" value="${
                         existingData.position || index + 1
                       }" min="1">
              </div>
              <div class="col-md-3 mb-3">
                <label class="form-label">Start Time</label>
                <input type="time" name="band_times[${bandId}][start_time]" 
                       class="form-control" value="${
                         existingData.startTime || ""
                       }">
              </div>
              <div class="col-md-3 mb-3">
                <label class="form-label">End Time</label>
                <input type="time" name="band_times[${bandId}][end_time]" 
                       class="form-control" value="${
                         existingData.endTime || ""
                       }">
              </div>
              <div class="col-md-12">
                <label class="form-label">Notes</label>
                <textarea name="band_times[${bandId}][notes]" 
                          class="form-control" rows="2">${
                            existingData.notes || ""
                          }</textarea>
              </div>
            </div>
          </div>
        `;

        container.appendChild(entry);
      }
    });

    // Remove entries for bands no longer selected
    document.querySelectorAll(".band-time-entry").forEach((entry) => {
      const bandId = entry.dataset.bandId;
      if (!selectedBands.some((band) => band.id == bandId)) {
        entry.remove();
      }
    });
  }
}
