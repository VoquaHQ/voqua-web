import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "message"]

  connect() {
    this.hideTimeout = null
  }

  show(message, duration = 3000) {
    this.messageTarget.textContent = message
    this.containerTarget.classList.remove("translate-x-full")
    
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
    
    this.hideTimeout = setTimeout(() => {
      this.hide()
    }, duration)
  }

  hide() {
    this.containerTarget.classList.add("translate-x-full")
  }
}
