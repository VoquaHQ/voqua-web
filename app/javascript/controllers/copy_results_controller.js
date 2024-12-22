import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    const text = this.sourceTarget.value
    navigator.clipboard.writeText(text).then(() => {
      // Show feedback
      const originalText = this.buttonTarget.textContent
      this.buttonTarget.textContent = "Copied!"
      this.buttonTarget.classList.remove("bg-blue-600", "hover:bg-blue-700")
      this.buttonTarget.classList.add("bg-green-600")

      // Reset after 2 seconds
      setTimeout(() => {
        this.buttonTarget.textContent = originalText
        this.buttonTarget.classList.remove("bg-green-600")
        this.buttonTarget.classList.add("bg-blue-600", "hover:bg-blue-700")
      }, 2000)
    })
  }
}
