import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="alert"
export default class extends Controller {
  connect() {
    // Auto-dismiss after 5 seconds if dismissible
    if (this.element.querySelector('button[data-action*="alert#dismiss"]')) {
      this.autoDismissTimeout = setTimeout(() => {
        this.dismiss()
      }, 5000)
    }
  }

  disconnect() {
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
  }

  dismiss() {
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
    
    // Add fade-out animation
    this.element.style.transition = "opacity 0.3s ease-out"
    this.element.style.opacity = "0"
    
    // Remove element after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}