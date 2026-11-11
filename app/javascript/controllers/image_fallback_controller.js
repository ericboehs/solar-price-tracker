import { Controller } from "@hotwired/stimulus"

// Swap a broken product image for its placeholder sibling.
// <img data-controller="image-fallback" data-action="error->image-fallback#swap">
export default class extends Controller {
  connect() {
    // The image may have failed before Stimulus connected.
    if (this.element.complete && this.element.naturalWidth === 0 && this.element.src) this.swap()
  }

  swap() {
    this.element.style.display = "none"
    const placeholder = this.element.nextElementSibling
    if (placeholder) placeholder.style.display = "flex"
  }
}
