import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];
  static values = {
    submitText: String,
    submittingText: String,
  };

  connect() {
    this.setupValidation();
    this.addCustomValidationMessages();
    this.selectedBands = new Set();

    // Listen for band selection changes
    this.element.addEventListener("band-selection:changed", (event) => {
      this.selectedBands = new Set(
        event.detail.bands.map((band) => band.id.toString())
      );
      this.validateBandSelection();
    });
  }

  setupValidation() {
    // Disable browser default validation
    this.formTarget.setAttribute("novalidate", true);

    // Add event listeners
    this.formTarget.addEventListener("submit", this.handleSubmit.bind(this));

    // Add real-time validation on input/blur
    const inputs = this.formTarget.querySelectorAll("input, select, textarea");
    inputs.forEach((input) => {
      input.addEventListener("blur", () => this.validateField(input));
      input.addEventListener("input", () => this.clearFieldErrors(input));
    });
  }

  handleSubmit(event) {
    event.preventDefault();

    if (this.validateForm()) {
      this.showSubmittingState();
      // Allow form to submit normally
      this.formTarget.submit();
    }
  }

  validateForm() {
    let isValid = true;
    const inputs = this.formTarget.querySelectorAll("input, select, textarea");

    // Validate all form fields
    inputs.forEach((input) => {
      const fieldValid = this.validateField(input);
      if (!fieldValid) {
        isValid = false;
      }
    });

    // Validate band selection for events
    const bandValidationResult = this.validateBandSelection();
    if (!bandValidationResult) {
      isValid = false;
    }

    return isValid;
  }

  validateField(field) {
    // Skip validation for hidden fields and band selection related fields
    if (
      field.type === "hidden" ||
      (field.name && field.name.includes("band_ids")) ||
      field.type === "submit"
    ) {
      return true;
    }

    this.clearFieldErrors(field);

    const validators = [
      this.validateRequired,
      this.validateEmail,
      this.validateUrl,
      this.validatePhone,
      this.validateNumber,
      this.validateMinLength,
      this.validateMaxLength,
      this.validateDate,
    ];

    for (const validator of validators) {
      const result = validator.call(this, field);
      if (!result.isValid) {
        this.showFieldError(field, result.message);
        return false;
      }
    }

    // Only show success state if field has a value
    if (field.value.trim()) {
      this.showFieldSuccess(field);
    }

    return true;
  }

  validateBandSelection() {
    const bandSelectionContainer = this.element.querySelector(
      '[data-controller*="band-selection"]'
    );

    // Only validate bands for event forms
    if (!this.isEventForm()) {
      return true;
    }

    if (!bandSelectionContainer) {
      return true;
    }

    const hasSelectedBands = this.selectedBands.size > 0;

    if (!hasSelectedBands) {
      this.showBandSelectionError(
        bandSelectionContainer,
        "At least one band must be selected for the event"
      );
      return false;
    } else {
      this.showBandSelectionSuccess(bandSelectionContainer);
      return true;
    }
  }

  isEventForm() {
    // Check if this is an event form by looking for event-specific fields
    return this.element.querySelector("#event_name") !== null;
  }

  showBandSelectionError(container, message) {
    container.classList.add("is-invalid");
    container.classList.remove("is-valid");

    // Remove existing error message
    this.clearBandSelectionErrors(container);

    // Add error message
    const errorDiv = document.createElement("div");
    errorDiv.className = "invalid-feedback band-selection-error d-block";
    errorDiv.textContent = message;
    errorDiv.style.display = "block";
    errorDiv.style.color = "#dc3545";
    errorDiv.style.fontSize = "0.875rem";
    errorDiv.style.marginTop = "0.25rem";

    // Insert error message at the end of the card body for better positioning
    const cardBody = container.querySelector(".card-body");
    if (cardBody) {
      cardBody.appendChild(errorDiv);
    } else {
      container.appendChild(errorDiv);
    }
  }

  showBandSelectionSuccess(container) {
    container.classList.add("is-valid");
    container.classList.remove("is-invalid");
    this.clearBandSelectionErrors(container);
  }

  clearBandSelectionErrors(container) {
    container.classList.remove("is-invalid", "is-valid");

    // Remove existing error messages
    const existingError = container.querySelector(".band-selection-error");
    if (existingError) {
      existingError.remove();
    }
  }

  validateRequired(field) {
    if (field.hasAttribute("required") && !field.value.trim()) {
      return {
        isValid: false,
        message: `${this.getFieldLabel(field)} is required`,
      };
    }
    return { isValid: true };
  }

  validateEmail(field) {
    if (field.type === "email" && field.value.trim()) {
      const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailPattern.test(field.value)) {
        return {
          isValid: false,
          message: "Please enter a valid email address",
        };
      }
    }
    return { isValid: true };
  }

  validateUrl(field) {
    if (field.type === "url" && field.value.trim()) {
      try {
        new URL(field.value);
      } catch {
        return {
          isValid: false,
          message: "Please enter a valid URL (e.g., https://example.com)",
        };
      }
    }
    return { isValid: true };
  }

  validatePhone(field) {
    if (field.type === "tel" && field.value.trim()) {
      const phonePattern = /^[\+]?[1-9][\d]{0,15}$|^[\(]?[\d\s\-\(\)]{10,}$/;
      if (!phonePattern.test(field.value.replace(/[\s\-\(\)]/g, ""))) {
        return {
          isValid: false,
          message: "Please enter a valid phone number",
        };
      }
    }
    return { isValid: true };
  }

  validateNumber(field) {
    if (field.type === "number" && field.value.trim()) {
      const num = parseFloat(field.value);
      if (isNaN(num)) {
        return {
          isValid: false,
          message: "Please enter a valid number",
        };
      }

      if (
        field.hasAttribute("min") &&
        num < parseFloat(field.getAttribute("min"))
      ) {
        return {
          isValid: false,
          message: `Must be at least ${field.getAttribute("min")}`,
        };
      }

      if (
        field.hasAttribute("max") &&
        num > parseFloat(field.getAttribute("max"))
      ) {
        return {
          isValid: false,
          message: `Must be no more than ${field.getAttribute("max")}`,
        };
      }
    }
    return { isValid: true };
  }

  validateDate(field) {
    // Only validate date fields for events (check if it's an event date field)
    if (
      field.type === "date" &&
      field.value.trim() &&
      field.id &&
      field.id.includes("event_date")
    ) {
      const selectedDate = new Date(field.value);
      const today = new Date();

      // Set today to start of day to only compare dates, not times
      today.setHours(0, 0, 0, 0);
      selectedDate.setHours(0, 0, 0, 0);

      if (selectedDate < today) {
        return {
          isValid: false,
          message: "Event date cannot be in the past",
        };
      }
    }
    return { isValid: true };
  }

  validateMinLength(field) {
    if (field.hasAttribute("minlength") && field.value.length > 0) {
      const minLength = parseInt(field.getAttribute("minlength"));
      if (field.value.length < minLength) {
        return {
          isValid: false,
          message: `Must be at least ${minLength} characters long`,
        };
      }
    }
    return { isValid: true };
  }

  validateMaxLength(field) {
    if (field.hasAttribute("maxlength") && field.value.length > 0) {
      const maxLength = parseInt(field.getAttribute("maxlength"));
      if (field.value.length > maxLength) {
        return {
          isValid: false,
          message: `Must be no more than ${maxLength} characters long`,
        };
      }
    }
    return { isValid: true };
  }

  showFieldError(field, message) {
    field.classList.add("is-invalid");
    field.classList.remove("is-valid");

    // Remove existing error message first
    this.clearFieldErrors(field);

    // Add error message with inline styles to ensure visibility
    const errorDiv = document.createElement("div");
    errorDiv.className = "invalid-feedback d-block";
    errorDiv.textContent = message;
    errorDiv.style.display = "block";
    errorDiv.style.color = "#dc3545";
    errorDiv.style.fontSize = "0.875rem";
    errorDiv.style.marginTop = "0.25rem";

    // Smart positioning based on field type and structure
    this.insertErrorMessage(field, errorDiv);
  }

  insertErrorMessage(field, errorDiv) {
    // Special handling for venue select (which is in a d-flex container)
    if (field.id === "event_venue_id") {
      const formGroup = field.closest(".form-group");
      if (formGroup) {
        formGroup.appendChild(errorDiv);
        return;
      }
    }

    // Default behavior - insert after field
    const parent = field.parentNode;
    if (field.nextSibling) {
      parent.insertBefore(errorDiv, field.nextSibling);
    } else {
      parent.appendChild(errorDiv);
    }
  }

  showFieldSuccess(field) {
    // Only show success for fields that have meaningful content
    if (field.value.trim()) {
      field.classList.add("is-valid");
      field.classList.remove("is-invalid");
    }
  }

  clearFieldErrors(field) {
    field.classList.remove("is-invalid", "is-valid");

    // For venue field, look in the form-group container
    if (field.id === "event_venue_id") {
      const formGroup = field.closest(".form-group");
      if (formGroup) {
        const existingError = formGroup.querySelector(".invalid-feedback");
        if (existingError) {
          existingError.remove();
        }
      }
      return;
    }

    // Default cleanup - check both parent and siblings
    const parent = field.parentNode;
    const existingError = parent.querySelector(".invalid-feedback");
    if (existingError) {
      existingError.remove();
    }

    // Also check for any error messages that might be siblings
    let sibling = field.nextElementSibling;
    while (sibling) {
      if (sibling.classList.contains("invalid-feedback")) {
        sibling.remove();
        break;
      }
      sibling = sibling.nextElementSibling;
    }
  }

  showSubmittingState() {
    const submitButton = this.formTarget.querySelector(
      'input[type="submit"], button[type="submit"]'
    );
    if (submitButton) {
      submitButton.disabled = true;
      const originalText = submitButton.value || submitButton.textContent;

      if (this.submittingTextValue) {
        if (submitButton.tagName === "INPUT") {
          submitButton.value = this.submittingTextValue;
        } else {
          submitButton.textContent = this.submittingTextValue;
        }
      }

      // Restore button after a delay (in case form submission fails)
      setTimeout(() => {
        submitButton.disabled = false;
        if (submitButton.tagName === "INPUT") {
          submitButton.value = originalText;
        } else {
          submitButton.textContent = originalText;
        }
      }, 3000);
    }
  }

  getFieldLabel(field) {
    const label = this.formTarget.querySelector(`label[for="${field.id}"]`);
    if (label) {
      return label.textContent.replace("*", "").trim();
    }

    // Fallback to placeholder or field name
    return field.placeholder || field.name || "This field";
  }

  addCustomValidationMessages() {
    // Add any custom validation rules specific to your forms
    const venueTypeSelect = this.formTarget.querySelector(
      'select[name*="venue_type"]'
    );
    if (venueTypeSelect) {
      venueTypeSelect.addEventListener("blur", () => {
        if (venueTypeSelect.value === "") {
          this.showFieldError(venueTypeSelect, "Please select a venue type");
        }
      });
    }
  }
}
