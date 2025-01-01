import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    autoDismiss: { type: Boolean, default: true },
    dismissAfter: { type: Number, default: 5000 }
  }

  connect() {
    // Setup close button
    this.btn = this.element.querySelector(".close")
    if (this.btn) {
      this.onClick = this.onClick.bind(this)
      this.btn.addEventListener("click", this.onClick)
    }

    // Auto dismiss if enabled
    if (this.autoDismissValue) {
      this.dismissTimeout = setTimeout(() => {
        this.dismiss()
      }, this.dismissAfterValue)
    }
  }

  disconnect() {
    if (this.btn) {
      this.btn.removeEventListener("click", this.onClick)
    }
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
    }
  }

  onClick() {
    this.dismiss()
  }

  dismiss() {
    // Add the hiding class to trigger the slide-out animation
    this.element.dataset.show = "false"

    // Remove the element after the animation completes
    setTimeout(() => {
      this.element.remove()
    }, 500) // Match this with the CSS transition duration
  }
}
