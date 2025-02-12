import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fadeIn"]

  connect() {
    // Subtle fade in for main header
    this.fadeInTarget.setAttribute("data-show", "true")
  }
}
