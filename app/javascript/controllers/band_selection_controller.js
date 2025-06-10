import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "search",
    "results",
    "list",
    "noMessage",
    "idsContainer",
    "loading",
    "count",
  ];
  static values = {
    searchUrl: String,
    artistInfoUrl: String,
    newBandUrl: String,
  };

  connect() {
    this.selectedBands = new Set();
    this.bandsData = new Map(); // Store band data for event emitting
    this.searchTimeout = null;
    this.searchDropdown = null;
    this.currentFocusIndex = -1; // For keyboard navigation
    this.updateSelectedCount();
    this.updateNoBandsMessage();

    // Add keyboard event listeners
    this.searchTarget.addEventListener(
      "keydown",
      this.handleSearchKeydown.bind(this)
    );

    // Handle when focus leaves the search input
    this.searchTarget.addEventListener("blur", (e) => {
      // Small delay to check if focus moved to a search result
      setTimeout(() => {
        if (
          !this.searchDropdown ||
          !this.searchDropdown.contains(document.activeElement)
        ) {
          // Focus left the search area, close dropdown after delay
          // Only close if focus didn't move to a dropdown item
          setTimeout(() => {
            if (
              !this.searchDropdown ||
              !this.searchDropdown.contains(document.activeElement)
            ) {
              this.closeSearchDropdown();
            }
          }, 150);
        }
      }, 50);
    });

    // Pre-populate bands if they exist
    const prePopulatedBands = JSON.parse(this.element.dataset.bands || "[]");
    prePopulatedBands.forEach((band) => {
      this.addBand(band);
    });

    // Emit initial event with pre-populated bands
    this.emitBandsChangedEvent();
  }

  disconnect() {
    // Clean up event listeners
    this.searchTarget.removeEventListener(
      "keydown",
      this.handleSearchKeydown.bind(this)
    );
    // Note: blur event listener will be automatically cleaned up when element is removed
  }

  handleSearchKeydown(event) {
    if (!this.searchDropdown) return;

    const resultItems = this.searchDropdown.querySelectorAll(
      ".search-result-item"
    );

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        this.currentFocusIndex = Math.min(
          this.currentFocusIndex + 1,
          resultItems.length - 1
        );
        this.updateFocus(resultItems);
        break;
      case "ArrowUp":
        event.preventDefault();
        this.currentFocusIndex = Math.max(this.currentFocusIndex - 1, -1);
        this.updateFocus(resultItems);
        break;
      case "Enter":
        event.preventDefault();
        if (
          this.currentFocusIndex >= 0 &&
          resultItems[this.currentFocusIndex]
        ) {
          resultItems[this.currentFocusIndex].click();
        }
        break;
      case "Escape":
        event.preventDefault();
        this.closeSearchDropdown();
        this.currentFocusIndex = -1;
        break;
      case "Tab":
        // Let tab work naturally through focusable elements in the dropdown
        if (resultItems.length > 0) {
          // If we're tabbing forward and no item is focused yet, focus the first item
          if (this.currentFocusIndex === -1 && !event.shiftKey) {
            event.preventDefault();
            this.currentFocusIndex = 0;
            this.updateFocus(resultItems);
            resultItems[0].focus();
          }
        }
        break;
    }
  }

  updateFocus(resultItems) {
    // Remove focus from all items
    resultItems.forEach((item, index) => {
      item.classList.remove("keyboard-focused");
      if (index === this.currentFocusIndex) {
        item.classList.add("keyboard-focused");
        item.scrollIntoView({ block: "nearest" });
      }
    });
  }

  search() {
    const query = this.searchTarget.value.trim();
    this.currentFocusIndex = -1; // Reset focus index

    // Clear any existing timeout
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }

    // If query is empty, close dropdown and return
    if (query === "") {
      this.closeSearchDropdown();
      return;
    }

    // Show loading indicator inside dropdown
    const dropdown = this.createSearchDropdown();
    this.showLoadingInDropdown(dropdown);

    // Set a timeout to prevent too many API calls
    this.searchTimeout = setTimeout(() => {
      // Call Spotify API
      fetch(`${this.searchUrlValue}?query=${encodeURIComponent(query)}`)
        .then((response) => response.json())
        .then((data) => {
          this.renderSearchResults(data);
        })
        .catch((error) => {
          console.error("Error searching artists:", error);

          // Show error in dropdown
          const dropdown = this.createSearchDropdown();
          dropdown.innerHTML =
            '<div class="p-3 text-center"><p class="text-danger mb-0">Error searching for artists</p></div>';
        });
    }, 500); // 500ms delay
  }

  searchFocus(event) {
    const query = event.currentTarget.value.trim();
    this.currentFocusIndex = -1; // Reset focus index

    if (query !== "") {
      // Show loading in dropdown
      const dropdown = this.createSearchDropdown();
      this.showLoadingInDropdown(dropdown);

      fetch(`${this.searchUrlValue}?query=${encodeURIComponent(query)}`)
        .then((response) => response.json())
        .then((data) => {
          this.renderSearchResults(data);
        })
        .catch((error) => {
          console.error("Error searching artists:", error);
          const dropdown = this.createSearchDropdown();
          dropdown.innerHTML =
            '<div class="p-3 text-center"><p class="text-danger mb-0">Error searching for artists</p></div>';
        });
    }
  }

  selectBand(event) {
    const spotifyId = event.currentTarget.dataset.spotifyId;

    // Close dropdown immediately when a band is selected
    this.closeSearchDropdown();
    this.searchTarget.value = "";
    this.currentFocusIndex = -1;

    // Create a loading indicator that appears directly in the form area
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = "block";
    }

    // Get detailed artist info
    fetch(
      `${this.artistInfoUrlValue}?spotify_id=${encodeURIComponent(spotifyId)}`
    )
      .then((response) => response.json())
      .then((data) => {
        if (data.band_id && !this.selectedBands.has(data.band_id.toString())) {
          this.addBand({
            id: data.band_id,
            name: data.name,
            image_url: data.photo_url,
          });
        }
        // Hide loading indicator
        if (this.hasLoadingTarget) {
          this.loadingTarget.style.display = "none";
        }
      })
      .catch((error) => {
        console.error("Error fetching artist info:", error);
        if (this.hasLoadingTarget) {
          this.loadingTarget.style.display = "none";
        }
      });
  }

  // Show loading spinner inside the dropdown
  showLoadingInDropdown(dropdown) {
    dropdown.innerHTML = `
      <div class="spinner-container">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>
    `;
  }

  createNewBand() {
    window.location.href = this.newBandUrlValue;
  }

  removeBand(event) {
    const bandId = event.currentTarget.dataset.id;
    this.selectedBands.delete(bandId.toString());
    this.bandsData.delete(bandId.toString());

    // Remove visual item
    const item = document.getElementById(`band-item-${bandId}`);
    if (item) item.remove();

    // Remove hidden input
    const input = document.getElementById(`band-input-${bandId}`);
    if (input) input.remove();

    // Update no bands message
    this.updateNoBandsMessage();
    this.updateSelectedCount();

    // Emit bands changed event
    this.emitBandsChangedEvent();
  }

  // Helper methods
  closeSearchDropdown() {
    if (this.searchDropdown) {
      this.searchDropdown.remove();
      this.searchDropdown = null;
      this.currentFocusIndex = -1;
    }
  }

  createSearchDropdown() {
    // Remove existing dropdown if it exists
    this.closeSearchDropdown();

    // Create new dropdown
    this.searchDropdown = document.createElement("div");
    this.searchDropdown.className = "search-results-dropdown";
    this.searchDropdown.setAttribute("role", "listbox");
    this.searchDropdown.setAttribute("aria-label", "Search results");
    this.resultsTarget.appendChild(this.searchDropdown);

    // Close dropdown when clicking outside
    document.addEventListener(
      "click",
      (e) => {
        if (
          !this.resultsTarget.contains(e.target) &&
          !this.searchTarget.contains(e.target)
        ) {
          this.closeSearchDropdown();
        }
      },
      { once: true }
    );

    return this.searchDropdown;
  }

  renderSearchResults(results) {
    // Clear existing results and create dropdown container
    const dropdown = this.createSearchDropdown();

    if (results.length === 0) {
      // No results found message
      const noResultsMessage = document.createElement("div");
      noResultsMessage.className = "p-3 text-center";
      noResultsMessage.innerHTML =
        '<p class="text-muted mb-0">No bands found matching your search.</p>';
      dropdown.appendChild(noResultsMessage);
    } else {
      // Show search results
      const resultsContainer = document.createElement("div");

      results.forEach((band, index) => {
        const item = document.createElement("div");
        item.className = "band-search-result-item search-result-item";
        item.dataset.action = "click->band-selection#selectBand";
        item.dataset.spotifyId = band.spotify_id;

        // Make the item focusable
        item.setAttribute("tabindex", "0");
        item.setAttribute("role", "option");
        item.setAttribute("aria-label", `Select band ${band.name}`);

        // Add keyboard event listeners for individual items
        item.addEventListener("keydown", (e) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            item.click();
          }
        });

        // Add focus and blur event listeners
        item.addEventListener("focus", () => {
          this.currentFocusIndex = index;
          this.updateFocus(dropdown.querySelectorAll(".search-result-item"));
        });

        // Band image
        const img = document.createElement("img");
        img.className = "band-img";
        img.src = band.image_url || "https://via.placeholder.com/40";
        img.alt = band.name;
        img.onerror = function () {
          this.src = "https://via.placeholder.com/40";
        };

        // Band name
        const bandInfo = document.createElement("div");
        bandInfo.className = "band-info";
        bandInfo.textContent = band.name;

        item.appendChild(img);
        item.appendChild(bandInfo);
        resultsContainer.appendChild(item);
      });

      dropdown.appendChild(resultsContainer);
    }

    // Always add "Create New" as the last option - make it sticky
    const createNewItem = document.createElement("div");
    createNewItem.className =
      "band-search-result-item search-result-item create-new";
    createNewItem.innerHTML =
      '<i class="fas fa-plus-circle me-2"></i> None found? Create New';
    createNewItem.dataset.action = "click->band-selection#createNewBand";

    // Make the create new item focusable
    createNewItem.setAttribute("tabindex", "0");
    createNewItem.setAttribute("role", "option");
    createNewItem.setAttribute("aria-label", "Create new band");

    // Add keyboard event listeners for create new item
    createNewItem.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        createNewItem.click();
      }
    });

    // Add focus event listener for create new item
    createNewItem.addEventListener("focus", () => {
      this.currentFocusIndex = results.length; // Position after all results
      this.updateFocus(dropdown.querySelectorAll(".search-result-item"));
    });

    dropdown.appendChild(createNewItem);
  }

  addBand(band) {
    if (this.selectedBands.has(band.id.toString())) return;

    this.selectedBands.add(band.id.toString());
    this.bandsData.set(band.id.toString(), band);

    // Add to visual list
    const item = document.createElement("div");
    item.className = "selected-band-item";
    item.id = `band-item-${band.id}`;

    // Band image
    const img = document.createElement("img");
    img.className = "band-img";
    img.src = band.image_url || "https://via.placeholder.com/40";
    img.alt = band.name;
    img.onerror = function () {
      this.src = "https://via.placeholder.com/40";
    };

    // Band name and remove button container
    const itemContent = document.createElement("div");
    itemContent.className =
      "d-flex justify-content-between align-items-center w-100 ms-2";

    // Band name
    const bandName = document.createElement("span");
    bandName.textContent = band.name;

    // Remove button with text
    const removeBtn = document.createElement("button");
    removeBtn.type = "button";
    removeBtn.className = "btn btn-sm btn-danger";
    removeBtn.innerHTML = "Remove";
    removeBtn.dataset.id = band.id;
    removeBtn.dataset.action = "click->band-selection#removeBand";
    removeBtn.setAttribute("title", "Remove band");

    // Add elements to item
    itemContent.appendChild(bandName);
    itemContent.appendChild(removeBtn);
    item.appendChild(img);
    item.appendChild(itemContent);

    this.listTarget.appendChild(item);

    // Add hidden input
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = "event[band_ids][]";
    input.value = band.id;
    input.id = `band-input-${band.id}`;
    this.idsContainerTarget.appendChild(input);

    // Update no bands message and count
    this.updateNoBandsMessage();
    this.updateSelectedCount();

    // Emit bands changed event
    this.emitBandsChangedEvent();
  }

  updateNoBandsMessage() {
    if (this.selectedBands.size === 0) {
      this.noMessageTarget.style.display = "block";
    } else {
      this.noMessageTarget.style.display = "none";
    }
  }

  updateSelectedCount() {
    if (this.hasCountTarget) {
      this.countTarget.textContent = this.selectedBands.size;
      this.countTarget.style.display =
        this.selectedBands.size > 0 ? "inline-block" : "none";
    }
  }

  // Emit an event whenever the selected bands change
  emitBandsChangedEvent() {
    const selectedBandsArray = Array.from(this.bandsData.values());
    const event = new CustomEvent("band-selection:changed", {
      bubbles: true,
      detail: {
        bands: selectedBandsArray,
      },
    });
    this.element.dispatchEvent(event);
  }
}
