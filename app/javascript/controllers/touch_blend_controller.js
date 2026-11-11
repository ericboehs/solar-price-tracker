import { Controller } from "@hotwired/stimulus"

// On touch devices in dark mode, show product images at full strength while pressed
// (the hover classes that do this on desktop don't fire on iOS).
export default class extends Controller {
  static targets = ["image"]

  press() { this.set("normal", "1") }
  release() { this.set("multiply", "0.9") }

  set(blend, opacity) {
    if (!window.matchMedia("(prefers-color-scheme: dark)").matches) return
    this.imageTargets.forEach((img) => {
      img.style.mixBlendMode = blend
      img.style.opacity = opacity
    })
  }
}
