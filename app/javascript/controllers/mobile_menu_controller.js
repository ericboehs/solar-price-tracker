import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  connect() {
    this.expanded = false
    console.log("Mobile menu controller connected", this.element)
  }

  toggle() {
    console.log("Mobile menu toggle clicked")
    this.expanded = !this.expanded

    // Update aria-expanded on the button
    const button = this.element.querySelector('button[aria-controls="mobile-menu"]')
    if (button) {
      button.setAttribute('aria-expanded', this.expanded)
    }

    // Toggle menu visibility
    if (this.expanded) {
      this.menuTarget.classList.remove('hidden')
      console.log("Menu opened")
    } else {
      this.menuTarget.classList.add('hidden')
      console.log("Menu closed")
    }

    // Toggle icons
    if (this.expanded) {
      this.openIconTarget.classList.add('hidden')
      this.closeIconTarget.classList.remove('hidden')
    } else {
      this.openIconTarget.classList.remove('hidden')
      this.closeIconTarget.classList.add('hidden')
    }
  }
}
